--!strict
-- Authoritative, party-only multi-target C4 Mystic healing.
-- A Dungeon session provider is installed by DungeonRuntime, not a remote.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local MageHealService = require(script.Parent.MageHealService)

local PartyHealService = {}
local MAX_TARGETS = 4
local roster_provider: ((Player) -> {Player})? = nil

--[[
Installs the Dungeon runtime's server-owned active session member lookup.

Args:
    provider (((Player) -> {Player})?): Session membership resolver,
        returning only connected, non-abandoned, active allied players.

Returns:
    nil: Replaces the internal provider; nil disables all party healing.
]]
function PartyHealService.set_roster_provider(
    provider: ((Player) -> {Player})?
)
    roster_provider = provider
end

--[[
Resolves eligible active-party players through the server-only provider.

Args:
    caster (Player): Authenticated caster to locate in the live session.

Returns:
    {Player}: Up to four genuine, unique and connected party members.
]]
local function session_members(
    caster: Player,
    minimum_size: number
): {Player}
    if not roster_provider or caster.Parent ~= Players then
        return {}
    end

    local roster = roster_provider(caster)
    if type(roster) ~= "table"
        or #roster < minimum_size
        or #roster > MAX_TARGETS
    then
        return {}
    end

    local members = {}
    local seen: {[number]: boolean} = {}
    local includes_caster = false

    for _, member in ipairs(roster) do
        if typeof(member) ~= "Instance"
            or not member:IsA("Player")
            or member.Parent ~= Players
            or Players:GetPlayerByUserId(member.UserId) ~= member
            or seen[member.UserId]
        then
            return {}
        end

        seen[member.UserId] = true
        includes_caster = includes_caster or member == caster
        table.insert(members, member)
    end

    return if includes_caster then members else {}
end

--[[
Resolves a real two-to-four-player party for group healing.

Args:
    caster (Player): Authenticated caster in the active Dungeon session.

Returns:
    {Player}: Validated party members, or an empty table when solo/invalid.
]]
local function party_members(caster: Player): {Player}
    return session_members(caster, 2)
end

--[[
Resolves source TARGET_PARTY candidates.

C4 TARGET_PARTY always includes the living caster, including a solo caster,
then adds living party members inside the source radius. Unlike the existing
party-heal targeting rules, the source target handler does not perform a
line-of-sight check.

Args:
    caster (Player): Authenticated source caster in the active session.

Returns:
    {Player}: One-to-four validated active session members.
]]
local function support_members(caster: Player): {Player}
    return session_members(caster, 1)
end

--[[
Rejects dead, out-of-range and obstructed players in the same party.

Args:
    caster (Player): Living party Mystic using the skill.
    target (Player): Server-confirmed active session member.
    range_studs (number): Authored maximum 3D healing radius.

Returns:
    boolean: Whether this party member can receive healing right now.
]]
--[[
Checks the exact live-player subset for C4 TARGET_PARTY support effects.

The source target handler includes the caster and living party members within
radius. It does not require injury and does not perform a line-of-sight test.

Args:
    caster (Player): Living source caster.
    target (Player): Validated active session member.
    range_studs (number): Converted source skill radius.

Returns:
    boolean: Whether this member belongs in the current source target list.
]]
local function is_living_in_range(
    caster: Player,
    target: Player,
    range_studs: number
): boolean
    local source = caster.Character
    local character = target.Character
    local source_humanoid = source
        and source:FindFirstChildOfClass("Humanoid")
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    local source_root = source
        and source:FindFirstChild("HumanoidRootPart")
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    return source ~= nil
        and character ~= nil
        and source_humanoid ~= nil
        and source_humanoid.Health > 0
        and humanoid ~= nil
        and humanoid.Health > 0
        and source_root ~= nil
        and source_root:IsA("BasePart")
        and root ~= nil
        and root:IsA("BasePart")
        and (source_root.Position - root.Position).Magnitude <= range_studs
end

local function is_injured_in_range(
    caster: Player, target: Player, range_studs: number
): boolean
    local source = caster.Character
    local character = target.Character
    local source_humanoid = source
        and source:FindFirstChildOfClass("Humanoid")
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    local source_root = source
        and source:FindFirstChild("HumanoidRootPart")
    local root = character
        and character:FindFirstChild("HumanoidRootPart")
    if not source or not character
        or not source_humanoid or source_humanoid.Health <= 0
        or not humanoid or humanoid.Health <= 0
        or humanoid.Health >= humanoid.MaxHealth
        or not source_root or not source_root:IsA("BasePart")
        or not root or not root:IsA("BasePart")
        or (source_root.Position - root.Position).Magnitude > range_studs
    then
        return false
    end
    if target == caster then
        return true
    end

    local origin = source_root.Position + Vector3.new(0, 1.5, 0)
    local destination = root.Position + Vector3.new(0, 1.5, 0)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {source}
    params.IgnoreWater = true
    local hit = Workspace:Raycast(origin, destination - origin, params)
    return hit == nil or hit.Instance:IsDescendantOf(character)
end

--[[
Verifies a real party exists and at least one live member needs healing.

Args:
    caster (Player): Authenticated living Mystic.
    range_studs (number): Authored maximum healing distance.

Returns:
    boolean: True only for a valid party with an eligible injured member.
]]
--[[
Returns C4 TARGET_PARTY player targets using the authoritative Dungeon roster.

The caster is always first when eligible, including solo sessions. Other
members preserve the current server roster order.

Args:
    caster (Player): Authenticated source caster.
    range_studs (number): Converted positive source radius.

Returns:
    {Player}: Living source support targets in range.
]]
function PartyHealService.support_targets(
    caster: Player,
    range_studs: number
): {Player}
    if type(range_studs) ~= "number" or range_studs <= 0 then
        return {}
    end

    local eligible = {}
    local members = support_members(caster)

    if table.find(members, caster)
        and is_living_in_range(caster, caster, range_studs)
    then
        table.insert(eligible, caster)
    end

    for _, member in ipairs(members) do
        if member ~= caster
            and is_living_in_range(caster, member, range_studs)
        then
            table.insert(eligible, member)
        end
    end

    return eligible
end

function PartyHealService.has_injured_member(
    caster: Player, range_studs: number
): boolean
    if type(range_studs) ~= "number" or range_studs <= 0 then
        return false
    end
    for _, member in ipairs(party_members(caster)) do
        if is_injured_in_range(caster, member, range_studs) then
            return true
        end
    end
    return false
end

--[[
Restores actual health to each eligible party member once per cast.

The server-owned MageHealService issues existing contribution and
support-threat callbacks for each *effective* target heal. A missing
or invalid Dungeon roster fails closed instead of healing strangers.

Args:
    caster (Player): Authenticated living party Mystic.
    heal_per_member (number): Rank-scaled effective healing amount.
    range_studs (number): Authored maximum healing distance.
    skill_id (string): Authoritative source skill used for threat/XP.

Returns:
    (boolean, number, number): Success, members healed and actual HP.
]]
function PartyHealService.cast(
    caster: Player, heal_per_member: number,
    range_studs: number, skill_id: string
): (boolean, number, number)
    if type(heal_per_member) ~= "number"
        or heal_per_member <= 0
        or heal_per_member ~= heal_per_member
        or heal_per_member == math.huge
        or range_studs <= 0 or range_studs > 40
        or (
            skill_id ~= "MysticPartyHeal"
            and skill_id ~= "DawnkeeperGroupMend"
        )
    then
        return false, 0, 0
    end
    local members = party_members(caster)
    if #members < 2 then
        return false, 0, 0
    end
    local affected = 0
    local total = 0
    for _, member in ipairs(members) do
        if is_injured_in_range(caster, member, range_studs) then
            local restored = MageHealService.apply_heal(
                caster, member, heal_per_member, skill_id
            )
            if restored > 0 then
                affected += 1
                total += restored
            end
        end
    end
    return affected > 0, affected, total
end

return table.freeze(PartyHealService)
