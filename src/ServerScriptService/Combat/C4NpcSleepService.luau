--!strict
-- Server-owned C4 sleep state for NPC combat targets.

local C4NpcSleepService = {}

export type SleepRecord = {
    expires_at: number,
}

local records: {[Model]: SleepRecord} = {}

--[[
Returns the current process time or a deterministic test timestamp.

Args:
    supplied_now (number?): Optional deterministic time.

Returns:
    number: Time used for sleep expiry checks.
]]
local function resolve_now(supplied_now: number?): number
    return supplied_now or os.clock()
end

--[[
Clears active C4 sleep state from one NPC.

Args:
    target (Model): NPC whose sleep state is removed.

Returns:
    nil: Clears server state and replicated diagnostic attributes.
]]
function C4NpcSleepService.clear(target: Model)
    records[target] = nil

    if target.Parent then
        target:SetAttribute("C4Sleeping", false)
        target:SetAttribute("C4SleepEndsAt", 0)
    end
end

--[[
Clears one real-time sleep when its delayed callback is still current.

Args:
    target (Model): NPC whose sleep may have expired.
    record (SleepRecord): Exact generation owned by the callback.

Returns:
    nil: Clears only the matching expired generation.
]]
local function clear_if_current(
    target: Model,
    record: SleepRecord
)
    if records[target] ~= record then
        return
    end

    if os.clock() < record.expires_at then
        return
    end

    C4NpcSleepService.clear(target)
end

--[[
Applies or refreshes a non-stacking C4 sleep effect.

A shorter refresh never reduces an existing sleep duration. Applying sleep
also requests zero Humanoid movement immediately; NPC controllers remain
responsible for suppressing attacks and chase behavior while is_sleeping()
returns true.

Args:
    target (Model): Living reviewed NPC receiving sleep.
    duration_seconds (number): Positive source sleep duration.
    supplied_now (number?): Optional deterministic test timestamp.

Returns:
    boolean: True when a meaningful sleep is active.
]]
function C4NpcSleepService.apply(
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
    target:SetAttribute("C4Sleeping", true)
    target:SetAttribute("C4SleepEndsAt", expires_at)
    humanoid:Move(Vector3.zero)

    if supplied_now == nil then
        task.delay(math.max(0, expires_at - now), function()
            clear_if_current(target, record)
        end)
    end

    return true
end

--[[
Returns whether one NPC is currently sleeping.

Expired, destroyed or dead targets fail neutral and clear stale state.

Args:
    target (Model): NPC being checked by server AI.

Returns:
    boolean: True only while the current source sleep remains active.
]]
function C4NpcSleepService.is_sleeping(target: Model): boolean
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
        C4NpcSleepService.clear(target)
        return false
    end

    return true
end

--[[
Wakes one sleeping NPC because real damage is about to be applied.

The pinned C4 status path removes Sleep before reducing HP whenever damage uses
the normal awake=true path. This method mirrors that ordering.

Args:
    target (Model): NPC receiving positive direct damage.

Returns:
    boolean: True when an active sleep was removed.
]]
function C4NpcSleepService.wake_on_damage(target: Model): boolean
    if not records[target] then
        return false
    end

    C4NpcSleepService.clear(target)
    return true
end

return table.freeze(C4NpcSleepService)
