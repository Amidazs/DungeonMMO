--!strict
-- Server-owned Human Wizard companion lifecycle and pet-skill authority.

local Workspace = game:GetService("Workspace")

local SPIRIT_ORE_ITEM_ID = "emberweaver_spirit_ore"
local SOURCE_SPIRIT_ORE_ID = 1458
local TICK_SECONDS = 1

local C4SourceCompanionService = {}
C4SourceCompanionService.__index = C4SourceCompanionService

--[[
Builds a placeholder server companion model.

The model deliberately carries source NPC identity but not invented C4 NPC
combat stats. Final meshes/stats can replace this factory without changing
summon, lifetime, reagent, heal or recharge authority.

Args:
    owner (any): Server-owned player.
    plan (any): Exact source summon plan.
    role (string): Creative companion role.

Returns:
    Model: Spawned placeholder companion model.
]]
local function default_model_factory(
    owner: any,
    plan: any,
    role: string
): Model
    local model = Instance.new("Model")
    model.Name = "EmberweaverCompanion"

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(2, 2, 2)
    root.Anchored = false
    root.CanCollide = true
    root.Parent = model

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = humanoid.MaxHealth
    humanoid.Parent = model

    model.PrimaryPart = root
    model:SetAttribute("C4CompanionOwnerUserId", owner.UserId)
    model:SetAttribute("C4SourceNpcId", plan.SourceNpcId)
    model:SetAttribute("C4CompanionRole", role)
    model:SetAttribute("C4CompanionMana", 100)
    model:SetAttribute("C4CompanionMaxMana", 100)
    model:SetAttribute("C4RechargeMpRate", 1)
    model:SetAttribute("C4CompanionActive", false)
    model:SetAttribute("C4SourceNpcStatsPending", true)

    local character = owner.Character
    local owner_root = character
        and character:FindFirstChild("HumanoidRootPart")
    if owner_root and owner_root:IsA("BasePart") then
        model:PivotTo(owner_root.CFrame * CFrame.new(3, 0, 3))
    end

    model.Parent = Workspace
    return model
end

--[[
Returns a finite nonnegative numeric model attribute.

Args:
    model (Model): Server-owned companion model.
    name (string): Attribute name.
    fallback (number): Value used only when the attribute is absent.

Returns:
    number: Validated model value.
]]
local function numeric_attribute(
    model: Model,
    name: string,
    fallback: number
): number
    local value = model:GetAttribute(name)
    if type(value) ~= "number"
        or value ~= value
        or value < 0
        or value >= math.huge
    then
        return fallback
    end
    return value
end

--[[
Creates the companion authority.

Args:
    inventory (any): InventoryService-compatible reagent authority.
    combat (any): C4 source calculation provider.
    options (any?): Optional model factory and delayed-callback provider.

Returns:
    any: Server-owned companion authority.
]]
function C4SourceCompanionService.new(
    inventory: any,
    combat: any,
    options: any?
): any
    local config = options or {}

    assert(
        inventory
            and type(inventory.consume_item) == "function",
        "Companion service requires inventory consumption authority"
    )
    assert(
        combat
            and type(combat.companion_summon_plan) == "function"
            and type(combat.companion_heal_plan) == "function"
            and type(combat.companion_recharge_plan) == "function",
        "Companion service requires source companion calculations"
    )

    return setmetatable({
        _inventory = inventory,
        _combat = combat,
        _model_factory =
            config.ModelFactory or default_model_factory,
        _delay = config.DelayProvider or task.delay,
        _records = {},
        _next_serial = 0,
    }, C4SourceCompanionService)
end

--[[
Returns the current valid companion record for one owner.

Args:
    owner (any): Server-owned player.

Returns:
    any?: Current live record, otherwise nil.
]]
function C4SourceCompanionService:_record(owner: any): any?
    local record = self._records[owner]
    if not record then
        return nil
    end

    local model = record.Model
    if typeof(model) ~= "Instance"
        or not model:IsA("Model")
        or model.Parent == nil
    then
        self._records[owner] = nil
        return nil
    end

    return record
end

--[[
Destroys one exact companion generation.

Args:
    owner (any): Companion owner.
    serial (number): Exact generation receipt.
    reason (string): Server-owned teardown reason.

Returns:
    boolean: True when the current generation was removed.
]]
function C4SourceCompanionService:_remove_generation(
    owner: any,
    serial: number,
    reason: string
): boolean
    local record = self._records[owner]
    if not record or record.Serial ~= serial then
        return false
    end

    self._records[owner] = nil
    local model = record.Model
    if typeof(model) == "Instance" and model.Parent ~= nil then
        model:SetAttribute("C4CompanionRemovalReason", reason)
        model:Destroy()
    end
    return true
end

--[[
Consumes one exact source reagent amount from creative inventory.

Args:
    owner (any): Server-owned player.
    source_item_id (number): Historical source reagent ID.
    count (number): Positive source quantity.

Returns:
    (boolean, string?): Success or strict inventory denial reason.
]]
function C4SourceCompanionService:_consume_source_item(
    owner: any,
    source_item_id: number,
    count: number
): (boolean, string?)
    if count <= 0 then
        return true, nil
    end
    if source_item_id ~= SOURCE_SPIRIT_ORE_ID then
        return false, "C4CompanionSourceReagentUnmapped"
    end

    local result = self._inventory:consume_item(
        owner.UserId,
        SPIRIT_ORE_ITEM_ID,
        count
    )
    if type(result) ~= "table" or result.ok ~= true then
        return false, "C4CompanionSourceReagentInsufficient"
    end

    return true, nil
end

--[[
Schedules the next exact one-second source lifetime tick.

Args:
    owner (any): Companion owner.
    serial (number): Exact generation receipt.

Returns:
    nil: Queues one server-owned callback.
]]
function C4SourceCompanionService:_schedule_tick(
    owner: any,
    serial: number
)
    self._delay(TICK_SECONDS, function()
        self:_run_tick(owner, serial)
    end)
end

--[[
Runs one source summon-lifetime tick.

Idle/active time loss and over-time reagent thresholds mirror the reviewed
C4 summon lifecycle. Reagent failure unsummons the companion immediately.

Args:
    owner (any): Companion owner.
    serial (number): Exact generation receipt.

Returns:
    nil: Mutates only the current companion generation.
]]
function C4SourceCompanionService:_run_tick(
    owner: any,
    serial: number
)
    local record = self._records[owner]
    if not record or record.Serial ~= serial then
        return
    end

    local model = record.Model
    if typeof(model) ~= "Instance" or model.Parent == nil then
        self._records[owner] = nil
        return
    end

    local old_remaining = record.TimeRemainingMs
    local active = model:GetAttribute("C4CompanionActive") == true
    local lost = if active
        then record.TimeLostActiveMs
        else record.TimeLostIdleMs
    record.TimeRemainingMs -= lost

    if record.TimeRemainingMs < 0 then
        self:_remove_generation(owner, serial, "LifetimeExpired")
        return
    end

    local next_consume = record.NextItemConsumeRemainingMs
    if next_consume
        and record.TimeRemainingMs <= next_consume
        and old_remaining > next_consume
    then
        record.NextItemConsumeRemainingMs -=
            record.ItemConsumeIntervalMs

        local consumed = self:_consume_source_item(
            owner,
            record.ItemConsumeIdOverTime,
            record.ItemConsumeCountOverTime
        )
        if not consumed then
            self:_remove_generation(
                owner,
                serial,
                "SourceReagentDepleted"
            )
            return
        end
    end

    model:SetAttribute(
        "C4CompanionTimeRemainingMs",
        record.TimeRemainingMs
    )
    self:_schedule_tick(owner, serial)
end

--[[
Summons one reviewed owned Human Wizard companion.

Args:
    owner (any): Server-owned player.
    creative_skill_id (string): Reviewed summon skill.
    creative_rank (number): Server-resolved purchased rank.
    role (string): Creative Mana or Combat role.

Returns:
    (any?, string?): Summon evidence or strict denial reason.
]]
function C4SourceCompanionService:summon(
    owner: any,
    creative_skill_id: string,
    creative_rank: number,
    role: string
): (any?, string?)
    if self:_record(owner) then
        return nil, "C4CompanionAlreadySummoned"
    end
    if role ~= "Mana" and role ~= "Combat" then
        return nil, "InvalidC4CompanionRole"
    end

    local plan, plan_reason =
        self._combat.companion_summon_plan(
            owner.UserId,
            creative_skill_id,
            creative_rank
        )
    if not plan then
        return nil, plan_reason
    end

    local initial_ok, initial_reason =
        self:_consume_source_item(
            owner,
            plan.ItemConsumeId,
            plan.ItemConsumeCount
        )
    if not initial_ok then
        return nil, initial_reason
    end

    local model = self._model_factory(owner, plan, role)
    if typeof(model) ~= "Instance" or not model:IsA("Model") then
        return nil, "C4CompanionModelFactoryFailed"
    end

    self._next_serial += 1
    local interval = nil
    local next_consume = nil
    if plan.ItemConsumeIdOverTime > 0
        and plan.ItemConsumeCountOverTime > 0
        and plan.ItemConsumeSteps > 0
    then
        interval =
            plan.TotalLifeTimeMs / (plan.ItemConsumeSteps + 1)
        next_consume = plan.TotalLifeTimeMs - interval
    end

    local record = {
        Serial = self._next_serial,
        Model = model,
        CreativeSkillId = creative_skill_id,
        CreativeRank = creative_rank,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = plan.SourceRank,
        SourceNpcId = plan.SourceNpcId,
        Role = role,
        ExpPenalty = plan.ExpPenalty,
        TimeRemainingMs = plan.TotalLifeTimeMs,
        TimeLostIdleMs = plan.TimeLostIdleMs,
        TimeLostActiveMs = plan.TimeLostActiveMs,
        ItemConsumeIdOverTime = plan.ItemConsumeIdOverTime,
        ItemConsumeCountOverTime =
            plan.ItemConsumeCountOverTime,
        ItemConsumeIntervalMs = interval or 0,
        NextItemConsumeRemainingMs = next_consume,
    }
    self._records[owner] = record

    model:SetAttribute(
        "C4CompanionTimeRemainingMs",
        record.TimeRemainingMs
    )
    model:SetAttribute("C4CompanionExpPenalty", plan.ExpPenalty)
    self:_schedule_tick(owner, record.Serial)

    return {
        Applied = true,
        Model = model,
        Role = role,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = plan.SourceRank,
        SourceNpcId = plan.SourceNpcId,
        ExpPenalty = plan.ExpPenalty,
        TimeRemainingMs = record.TimeRemainingMs,
        InitialReagentConsumed = plan.ItemConsumeCount,
        OverTimeReagentCount = plan.ItemConsumeCountOverTime,
        OverTimeReagentSteps = plan.ItemConsumeSteps,
    }, nil
end

--[[
Returns whether one owner has a current companion target.

Args:
    owner (any): Server-owned player.

Returns:
    (boolean, string?): Target readiness or strict denial reason.
]]
function C4SourceCompanionService:can_target_owned(
    owner: any
): (boolean, string?)
    local record = self:_record(owner)
    if not record then
        return false, "C4OwnedCompanionUnavailable"
    end

    local humanoid = record.Model:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false, "C4OwnedCompanionUnavailable"
    end

    return true, nil
end

--[[
Applies one reviewed Servitor Heal to the owner's companion.

Args:
    owner (any): Server-owned player.
    creative_skill_id (string): Reviewed pet-heal skill.
    creative_rank (number): Server-resolved purchased rank.

Returns:
    (any?, string?): Heal evidence or strict denial reason.
]]
function C4SourceCompanionService:heal_owned(
    owner: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    local record = self:_record(owner)
    if not record then
        return nil, "C4OwnedCompanionUnavailable"
    end

    local humanoid = record.Model:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return nil, "C4OwnedCompanionUnavailable"
    end

    local plan, reason = self._combat.companion_heal_plan(
        owner.UserId,
        creative_skill_id,
        creative_rank
    )
    if not plan then
        return nil, reason
    end

    local before = humanoid.Health
    humanoid.Health = math.min(
        humanoid.MaxHealth,
        humanoid.Health + plan.Amount
    )

    return {
        Applied = true,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = plan.SourceRank,
        RequestedHeal = plan.Amount,
        EffectiveHeal = humanoid.Health - before,
        HealthBefore = before,
        HealthAfter = humanoid.Health,
        Spiritshot = plan.Spiritshot,
        BlessedSpiritshot = plan.BlessedSpiritshot,
    }, nil
end

--[[
Applies one reviewed Servitor Recharge to the owner's companion.

Args:
    owner (any): Server-owned player.
    creative_skill_id (string): Reviewed pet-recharge skill.
    creative_rank (number): Server-resolved purchased rank.

Returns:
    (any?, string?): Recharge evidence or strict denial reason.
]]
function C4SourceCompanionService:recharge_owned(
    owner: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    local record = self:_record(owner)
    if not record then
        return nil, "C4OwnedCompanionUnavailable"
    end

    local model = record.Model
    local rate = numeric_attribute(
        model,
        "C4RechargeMpRate",
        1
    )
    local plan, reason =
        self._combat.companion_recharge_plan(
            owner.UserId,
            creative_skill_id,
            creative_rank,
            rate
        )
    if not plan then
        return nil, reason
    end

    local maximum = numeric_attribute(
        model,
        "C4CompanionMaxMana",
        0
    )
    local before = numeric_attribute(
        model,
        "C4CompanionMana",
        0
    )
    local after = math.min(maximum, before + plan.Amount)
    model:SetAttribute("C4CompanionMana", after)

    return {
        Applied = true,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = plan.SourceRank,
        RequestedMana = plan.Amount,
        ManaRestored = after - before,
        ManaBefore = before,
        ManaAfter = after,
        RechargeRate = plan.RechargeRate,
    }, nil
end

--[[
Removes the current companion for one owner.

Args:
    owner (any): Server-owned player.
    reason (string?): Optional teardown reason.

Returns:
    boolean: True when a companion was removed.
]]
function C4SourceCompanionService:clear_owner(
    owner: any,
    reason: string?
): boolean
    local record = self._records[owner]
    if not record then
        return false
    end

    return self:_remove_generation(
        owner,
        record.Serial,
        reason or "OwnerCleared"
    )
end

--[[
Returns detached companion state.

Args:
    owner (any): Server-owned player.

Returns:
    any: Current companion snapshot.
]]
function C4SourceCompanionService:snapshot(owner: any): any
    local record = self:_record(owner)
    if not record then
        return {Active = false}
    end

    return {
        Active = true,
        Serial = record.Serial,
        Role = record.Role,
        SourceSkillId = record.SourceSkillId,
        SourceRank = record.SourceRank,
        SourceNpcId = record.SourceNpcId,
        ExpPenalty = record.ExpPenalty,
        TimeRemainingMs = record.TimeRemainingMs,
        Model = record.Model,
    }
end

return C4SourceCompanionService
