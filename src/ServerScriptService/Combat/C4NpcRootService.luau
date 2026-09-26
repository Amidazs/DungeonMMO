--!strict
-- Server-owned C4 root state for NPC combat targets.

local C4NpcRootService = {}

export type RootRecord = {
    expires_at: number,
}

local records: {[Model]: RootRecord} = {}

--[[
Returns process time or a deterministic test timestamp.

Args:
    supplied_now (number?): Optional deterministic timestamp.

Returns:
    number: Time used for root expiry checks.
]]
local function resolve_now(supplied_now: number?): number
    return supplied_now or os.clock()
end

--[[
Clears active C4 root state from one NPC.

Args:
    target (Model): NPC whose root state is removed.

Returns:
    nil: Clears server state and diagnostic attributes.
]]
function C4NpcRootService.clear(target: Model)
    records[target] = nil

    if target.Parent then
        target:SetAttribute("C4Rooted", false)
        target:SetAttribute("C4RootEndsAt", 0)
    end
end

--[[
Clears one root callback only when it still owns the active generation.

Args:
    target (Model): NPC whose root may have expired.
    record (RootRecord): Exact scheduled generation.

Returns:
    nil: Clears only the matching expired root.
]]
local function clear_if_current(
    target: Model,
    record: RootRecord
)
    if records[target] ~= record then
        return
    end
    if os.clock() < record.expires_at then
        return
    end

    C4NpcRootService.clear(target)
end

--[[
Applies or refreshes one non-stacking C4 root.

Root stops movement but deliberately does not suppress attacks, casting or
damage reactions. A shorter refresh never shortens an existing root.

Args:
    target (Model): Living reviewed NPC receiving root.
    duration_seconds (number): Positive source root duration.
    supplied_now (number?): Optional deterministic test timestamp.

Returns:
    boolean: True when a meaningful root is active.
]]
function C4NpcRootService.apply(
    target: Model,
    duration_seconds: number,
    supplied_now: number?
): boolean
    local duration = tonumber(duration_seconds)
    if not duration
        or duration ~= duration
        or duration <= 0
        or duration >= math.huge
    then
        return false
    end

    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end

    local now = resolve_now(supplied_now)
    local current = records[target]
    local expires_at = now + duration

    if current and current.expires_at > now then
        expires_at = math.max(current.expires_at, expires_at)
    end

    local record = {
        expires_at = expires_at,
    }
    records[target] = record
    target:SetAttribute("C4Rooted", true)
    target:SetAttribute("C4RootEndsAt", expires_at)
    humanoid:Move(Vector3.zero)

    if supplied_now == nil then
        task.delay(math.max(0, expires_at - now), function()
            clear_if_current(target, record)
        end)
    end

    return true
end

--[[
Returns whether one NPC is currently rooted.

Expired, destroyed or dead targets clear stale state and fail neutral.

Args:
    target (Model): NPC being checked by server AI.

Returns:
    boolean: True only while the source root remains active.
]]
function C4NpcRootService.is_rooted(target: Model): boolean
    local record = records[target]
    if not record then
        return false
    end

    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if not target.Parent
        or not humanoid
        or humanoid.Health <= 0
        or os.clock() >= record.expires_at
    then
        C4NpcRootService.clear(target)
        return false
    end

    return true
end

return table.freeze(C4NpcRootService)
