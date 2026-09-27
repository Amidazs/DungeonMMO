--!strict
-- Server-owned Spoil/Sweep secondary-salvage state and reward authority.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SalvageConfig = require(
    ReplicatedStorage.Core.Shared.C4DwarfSalvageConfig
)

local C4DwarfSalvageService = {}
C4DwarfSalvageService.__index = C4DwarfSalvageService

local OWNER_ATTRIBUTE = "C4SalvageOwnerUserId"
local SOURCE_SKILL_ATTRIBUTE = "C4SalvageSourceSkillId"
local SOURCE_RANK_ATTRIBUTE = "C4SalvageSourceRank"
local CLAIMED_ATTRIBUTE = "C4SalvageClaimed"
local TABLE_ATTRIBUTE = "C4SalvageTableId"
local DEFAULT_TABLE_ID = "Default"

--[[
Checks one server-owned player-like owner.

Args:
    owner (any): Player or disposable server test owner.

Returns:
    boolean: True when an integral numeric UserId is available.
]]
local function valid_owner(owner: any): boolean
    return (
        type(owner) == "table"
        or typeof(owner) == "Instance"
    )
        and type(owner.UserId) == "number"
        and owner.UserId % 1 == 0
end

--[[
Checks one target model is a non-player creature in the live workspace.

Args:
    model (any): Candidate server-owned creature model.

Returns:
    Humanoid?: Target humanoid when the creature is valid.
]]
local function target_humanoid(model: any): Humanoid?
    if typeof(model) ~= "Instance"
        or not model:IsA("Model")
        or not model:IsDescendantOf(workspace)
        or Players:GetPlayerFromCharacter(model) ~= nil
    then
        return nil
    end

    return model:FindFirstChildOfClass("Humanoid")
end

--[[
Creates a secondary-salvage authority.

Args:
    inventory (any): Existing server-owned inventory service.
    rng (any?): Optional deterministic random provider for tests.

Returns:
    any: Server-owned salvage authority.
]]
function C4DwarfSalvageService.new(
    inventory: any,
    rng: any?
): any
    assert(
        inventory and type(inventory.add_item) == "function",
        "Dwarf salvage requires inventory authority"
    )

    return setmetatable({
        _inventory = inventory,
        _rng = rng or Random.new(),
    }, C4DwarfSalvageService)
end

--[[
Checks whether one living creature can receive this owner's Spoil mark.

Args:
    owner (any): Server-owned skill user.
    model (any): Candidate living enemy.

Returns:
    (boolean, string?): Eligibility or stable refusal.
]]
function C4DwarfSalvageService:can_mark(
    owner: any,
    model: any
): (boolean, string?)
    if not valid_owner(owner) then
        return false, "C4SalvageOwnerInvalid"
    end

    local humanoid = target_humanoid(model)
    if not humanoid or humanoid.Health <= 0 then
        return false, "C4SalvageTargetNotLivingEnemy"
    end

    if model:GetAttribute(CLAIMED_ATTRIBUTE) == true then
        return false, "C4SalvageAlreadyClaimed"
    end

    local current_owner = model:GetAttribute(OWNER_ATTRIBUTE)
    if current_owner ~= nil and current_owner ~= owner.UserId then
        return false, "C4SalvageAlreadyMarked"
    end

    return true, nil
end

--[[
Applies or refreshes one exact source Spoil mark.

Args:
    owner (any): Server-owned skill user.
    model (any): Living enemy being marked.
    source_skill_id (number): Exact source Spoil family ID.
    source_rank (number): Exact authenticated source rank.

Returns:
    (any?, string?): Mark evidence or strict refusal.
]]
function C4DwarfSalvageService:mark(
    owner: any,
    model: any,
    source_skill_id: number,
    source_rank: number
): (any?, string?)
    local ready, reason = self:can_mark(owner, model)
    if not ready then
        return nil, reason
    end

    if (source_skill_id ~= 254 and source_skill_id ~= 302)
        or type(source_rank) ~= "number"
        or source_rank % 1 ~= 0
        or source_rank < 1
    then
        return nil, "C4SalvageSourceRankInvalid"
    end

    local refreshed =
        model:GetAttribute(OWNER_ATTRIBUTE) == owner.UserId

    model:SetAttribute(OWNER_ATTRIBUTE, owner.UserId)
    model:SetAttribute(SOURCE_SKILL_ATTRIBUTE, source_skill_id)
    model:SetAttribute(SOURCE_RANK_ATTRIBUTE, source_rank)
    model:SetAttribute(CLAIMED_ATTRIBUTE, false)

    return {
        Applied = true,
        Refreshed = refreshed,
        OwnerUserId = owner.UserId,
        SourceSkillId = source_skill_id,
        SourceRank = source_rank,
    }, nil
end

--[[
Checks whether one dead marked creature can be swept by this owner.

Args:
    owner (any): Server-owned skill user.
    model (any): Candidate dead enemy.

Returns:
    (boolean, string?): Claim eligibility or stable refusal.
]]
function C4DwarfSalvageService:can_claim(
    owner: any,
    model: any
): (boolean, string?)
    if not valid_owner(owner) then
        return false, "C4SalvageOwnerInvalid"
    end

    local humanoid = target_humanoid(model)
    if not humanoid or humanoid.Health > 0 then
        return false, "C4SalvageTargetNotDeadEnemy"
    end

    if model:GetAttribute(OWNER_ATTRIBUTE) ~= owner.UserId then
        return false, "C4SalvageNotOwned"
    end
    if model:GetAttribute(CLAIMED_ATTRIBUTE) == true then
        return false, "C4SalvageAlreadyClaimed"
    end

    return true, nil
end

--[[
Claims one secondary salvage roll from an owned spoiled corpse.

The corpse is locked before inventory mutation so two synchronous requests
cannot duplicate the reward. Failed inventory mutation releases the lock.

Args:
    owner (any): Server-owned skill user.
    model (any): Dead enemy spoiled by this owner.

Returns:
    (any?, string?): Claim/reward evidence or strict refusal.
]]
function C4DwarfSalvageService:claim(
    owner: any,
    model: any
): (any?, string?)
    local ready, reason = self:can_claim(owner, model)
    if not ready then
        return nil, reason
    end

    model:SetAttribute(CLAIMED_ATTRIBUTE, true)

    local table_id = model:GetAttribute(TABLE_ATTRIBUTE)
    if type(table_id) ~= "string" or table_id == "" then
        table_id = DEFAULT_TABLE_ID
    end

    local reward, roll_reason = SalvageConfig.roll(
        table_id,
        self._rng
    )
    if roll_reason then
        model:SetAttribute(CLAIMED_ATTRIBUTE, false)
        return nil, roll_reason
    end

    if not reward then
        return {
            Applied = true,
            OwnerUserId = owner.UserId,
            TableId = table_id,
            ItemId = nil,
            Quantity = 0,
        }, nil
    end

    local granted = self._inventory:add_item(
        owner.UserId,
        reward.ItemId,
        reward.Quantity
    )
    if type(granted) ~= "table" or granted.ok ~= true then
        model:SetAttribute(CLAIMED_ATTRIBUTE, false)
        return nil, if type(granted) == "table"
            then granted.reason or "C4SalvageGrantFailed"
            else "C4SalvageGrantFailed"
    end

    return {
        Applied = true,
        OwnerUserId = owner.UserId,
        TableId = table_id,
        ItemId = reward.ItemId,
        Quantity = reward.Quantity,
    }, nil
end

--[[
Returns detached server-owned Spoil/Sweep state for diagnostics.

Args:
    model (any): Candidate creature model.

Returns:
    any: Detached current mark/claim attributes.
]]
function C4DwarfSalvageService:snapshot(model: any): any
    if typeof(model) ~= "Instance" or not model:IsA("Model") then
        return {
            Marked = false,
            Claimed = false,
        }
    end

    local owner_id = model:GetAttribute(OWNER_ATTRIBUTE)
    return {
        Marked = type(owner_id) == "number",
        OwnerUserId = owner_id,
        SourceSkillId = model:GetAttribute(SOURCE_SKILL_ATTRIBUTE),
        SourceRank = model:GetAttribute(SOURCE_RANK_ATTRIBUTE),
        Claimed = model:GetAttribute(CLAIMED_ATTRIBUTE) == true,
        TableId = model:GetAttribute(TABLE_ATTRIBUTE),
    }
end

return C4DwarfSalvageService
