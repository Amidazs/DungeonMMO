--!strict
-- Server-owned C4 Fear movement state for supported NPC AI.

local C4NpcFearService = {}

export type FearRecord = {
    Caster: Model,
    ExpiresAt: number,
    ActionSeconds: number,
    ActionCount: number,
    ActionsIssued: number,
    NextActionAt: number,
    FleeStuds: number,
    Destination: Vector3?,
}

local records: {[Model]: FearRecord} = {}

--[[
Returns process time or a deterministic test timestamp.

Args:
    supplied_now (number?): Optional deterministic timestamp.

Returns:
    number: Time used for Fear timing.
]]
local function resolve_now(supplied_now: number?): number
    return supplied_now or os.clock()
end

--[[
Returns one living model root.

Args:
    model (Model): Candidate combat model.

Returns:
    BasePart?: Living model root, otherwise nil.
]]
local function living_root(model: Model): BasePart?
    if not model.Parent then
        return nil
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    local root = model:FindFirstChild("HumanoidRootPart")
    if not humanoid
        or humanoid.Health <= 0
        or not root
        or not root:IsA("BasePart")
    then
        return nil
    end

    return root
end

--[[
Clears active C4 Fear state from one NPC.

Args:
    target (Model): NPC whose Fear state is removed.

Returns:
    nil: Clears server state and diagnostic attributes.
]]
function C4NpcFearService.clear(target: Model)
    records[target] = nil

    if target.Parent then
        target:SetAttribute("C4Feared", false)
        target:SetAttribute("C4FearEndsAt", 0)
        target:SetAttribute("C4FearActionsIssued", 0)
    end
end

--[[
Applies or refreshes one exact C4 Fear generation.

Args:
    target (Model): Living reviewed NPC receiving Fear.
    caster (Model): Living server-owned caster character.
    action_count (number): Exact source Fear action count.
    action_seconds (number): Exact source action interval.
    flee_range_source_units (number): Exact source X/Z flee step.
    source_units_per_stud (number): Server source-to-world scale.
    supplied_now (number?): Optional deterministic timestamp.

Returns:
    (boolean, string?): Applied state or strict denial reason.
]]
function C4NpcFearService.apply(
    target: Model,
    caster: Model,
    action_count: number,
    action_seconds: number,
    flee_range_source_units: number,
    source_units_per_stud: number,
    supplied_now: number?
): (boolean, string?)
    if not living_root(target) or not living_root(caster) then
        return false, "C4FearActorUnavailable"
    end
    if type(action_count) ~= "number"
        or action_count % 1 ~= 0
        or action_count <= 0
        or type(action_seconds) ~= "number"
        or action_seconds <= 0
        or type(flee_range_source_units) ~= "number"
        or flee_range_source_units <= 0
        or type(source_units_per_stud) ~= "number"
        or source_units_per_stud <= 0
    then
        return false, "InvalidC4FearPlan"
    end

    local now = resolve_now(supplied_now)
    local record: FearRecord = {
        Caster = caster,
        ExpiresAt = now + action_count * action_seconds,
        ActionSeconds = action_seconds,
        ActionCount = action_count,
        ActionsIssued = 0,
        NextActionAt = now,
        FleeStuds = flee_range_source_units / source_units_per_stud,
        Destination = nil,
    }
    records[target] = record

    target:SetAttribute("C4Feared", true)
    target:SetAttribute("C4FearEndsAt", record.ExpiresAt)
    target:SetAttribute("C4FearActionsIssued", 0)

    if supplied_now == nil then
        task.delay(action_count * action_seconds, function()
            if records[target] == record then
                C4NpcFearService.clear(target)
            end
        end)
    end

    return true, nil
end

--[[
Reports whether one NPC remains under source Fear.

Args:
    target (Model): Reviewed NPC.

Returns:
    boolean: True only for a living unexpired Fear generation.
]]
function C4NpcFearService.is_feared(target: Model): boolean
    local record = records[target]
    if not record then
        return false
    end

    if not living_root(target)
        or not living_root(record.Caster)
        or os.clock() >= record.ExpiresAt
    then
        C4NpcFearService.clear(target)
        return false
    end

    return true
end

--[[
Returns the current C4 Fear flee destination.

The source EffectFear handler updates its movement intention once per effect
action. Roblox uses X/Z as the horizontal plane, so C4 X/Y movement maps to
Roblox X/Z while preserving the source's independent axis signs.

Args:
    target (Model): Feared NPC.
    supplied_now (number?): Optional deterministic action time.

Returns:
    Vector3?: Current forced destination, otherwise nil.
]]
function C4NpcFearService.flee_destination(
    target: Model,
    supplied_now: number?
): Vector3?
    local record = records[target]
    if not record then
        return nil
    end

    local now = resolve_now(supplied_now)
    if now >= record.ExpiresAt then
        C4NpcFearService.clear(target)
        return nil
    end

    local target_root = living_root(target)
    local caster_root = living_root(record.Caster)
    if not target_root or not caster_root then
        C4NpcFearService.clear(target)
        return nil
    end

    if record.ActionsIssued < record.ActionCount
        and now >= record.NextActionAt
    then
        local target_position = target_root.Position
        local caster_position = caster_root.Position
        local x_sign = if target_position.X > caster_position.X
            then 1 else -1
        local z_sign = if target_position.Z > caster_position.Z
            then 1 else -1

        record.Destination = target_position + Vector3.new(
            x_sign * record.FleeStuds,
            0,
            z_sign * record.FleeStuds
        )
        record.ActionsIssued += 1
        record.NextActionAt = now + record.ActionSeconds
        target:SetAttribute(
            "C4FearActionsIssued",
            record.ActionsIssued
        )
    end

    return record.Destination
end

return table.freeze(C4NpcFearService)
