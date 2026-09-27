--!strict
-- Server-owned, non-stacking C4 NPC accuracy weakening.

local C4NpcAccuracyDebuffService = {}

export type AccuracyRecord = {
    penalty: number,
    expires_at: number,
}

local records: {[Model]: AccuracyRecord} = {}

--[[
Returns the current process time or a deterministic test timestamp.

Args:
    supplied_now (number?): Optional deterministic timestamp.

Returns:
    number: Time used for source debuff expiry.
]]
local function resolve_now(supplied_now: number?): number
    return supplied_now or os.clock()
end

--[[
Clears one NPC accuracy debuff and its diagnostic attributes.

Args:
    target (Model): NPC whose current-life status is removed.

Returns:
    nil: Clears only this server-owned status generation.
]]
function C4NpcAccuracyDebuffService.clear(target: Model)
    records[target] = nil

    if target.Parent then
        target:SetAttribute("C4AccuracyPenalty", 0)
        target:SetAttribute("C4AccuracyPenaltyEndsAt", 0)
    end
end

--[[
Returns the current live accuracy record.

Args:
    target (Model): Candidate living NPC.

Returns:
    AccuracyRecord?: Active record or nil after expiry/death/removal.
]]
local function active(target: Model): AccuracyRecord?
    local record = records[target]
    if not record then
        return nil
    end

    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if not target.Parent
        or not humanoid
        or humanoid.Health <= 0
        or os.clock() >= record.expires_at
    then
        C4NpcAccuracyDebuffService.clear(target)
        return nil
    end

    return record
end

--[[
Clears one delayed generation only when it remains current.

Args:
    target (Model): NPC owning the status.
    record (AccuracyRecord): Generation captured by the callback.

Returns:
    nil: Clears only a matching expired generation.
]]
local function clear_if_current(
    target: Model,
    record: AccuracyRecord
)
    if records[target] ~= record
        or os.clock() < record.expires_at
    then
        return
    end

    C4NpcAccuracyDebuffService.clear(target)
end

--[[
Applies or refreshes one C4 accuracy penalty.

A stronger current penalty is never reduced by a weaker reapplication.
Duration is extended to at least the newly requested expiry.

Args:
    target (Model): Living NPC receiving the debuff.
    penalty (number): Positive additive accuracy reduction.
    duration_seconds (number): Positive source duration.
    supplied_now (number?): Optional deterministic test timestamp.

Returns:
    boolean: True when a valid status is active.
]]
function C4NpcAccuracyDebuffService.apply(
    target: Model,
    penalty: number,
    duration_seconds: number,
    supplied_now: number?
): boolean
    local amount = tonumber(penalty)
    local duration = tonumber(duration_seconds)

    if not amount
        or amount ~= amount
        or amount <= 0
        or amount >= math.huge
        or not duration
        or duration ~= duration
        or duration <= 0
        or duration >= math.huge
    then
        return false
    end

    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if not target.Parent or not humanoid or humanoid.Health <= 0 then
        return false
    end

    local now = resolve_now(supplied_now)
    local current = active(target)
    local record: AccuracyRecord = {
        penalty = amount,
        expires_at = now + duration,
    }

    if current then
        record.penalty = math.max(
            current.penalty,
            record.penalty
        )
        record.expires_at = math.max(
            current.expires_at,
            record.expires_at
        )
    end

    records[target] = record
    target:SetAttribute("C4AccuracyPenalty", record.penalty)
    target:SetAttribute(
        "C4AccuracyPenaltyEndsAt",
        record.expires_at
    )

    if supplied_now == nil then
        task.delay(
            math.max(0, record.expires_at - now),
            function()
                clear_if_current(target, record)
            end
        )
    end

    return true
end

--[[
Returns the active additive C4 accuracy reduction.

Args:
    target (Model): NPC whose outgoing hit is being resolved.

Returns:
    number: Positive penalty, otherwise zero.
]]
function C4NpcAccuracyDebuffService.get_penalty(
    target: Model
): number
    local record = active(target)
    return if record then record.penalty else 0
end

--[[
Decorates one detached NPC source boundary with the current accuracy penalty.

The immutable reference boundary is never mutated. Accuracy may become
negative because C4 hit chance supports negative attacker accuracy deltas.

Args:
    target (Model): Live NPC owning the runtime debuff.
    boundary (any): Detached reviewed NPC source boundary.

Returns:
    any: Boundary copy with current ACCURACY_COMBAT, or the original boundary.
]]
function C4NpcAccuracyDebuffService.decorate_boundary(
    target: Model,
    boundary: any
): any
    if type(boundary) ~= "table"
        or type(boundary.SourceStatCandidate) ~= "table"
    then
        return boundary
    end

    local penalty =
        C4NpcAccuracyDebuffService.get_penalty(target)
    if penalty <= 0 then
        return boundary
    end

    local stats = table.clone(boundary.SourceStatCandidate)
    local base = tonumber(stats.ACCURACY_COMBAT)
    if not base then
        return boundary
    end

    stats.ACCURACY_COMBAT = base - penalty

    local decorated = table.clone(boundary)
    decorated.SourceStatCandidate = table.freeze(stats)
    return table.freeze(decorated)
end

return table.freeze(C4NpcAccuracyDebuffService)
