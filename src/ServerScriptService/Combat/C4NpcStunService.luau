--!strict
-- Server-owned C4 stun state for reviewed NPC combat targets.

local C4NpcStunService = {}

export type StunRecord = {
    expires_at: number,
}

local records: {[Model]: StunRecord} = {}

--[[
Returns process time or one deterministic test timestamp.

Args:
    supplied_now (number?): Optional deterministic timestamp.

Returns:
    number: Time used for stun expiry checks.
]]
local function resolve_now(supplied_now: number?): number
    return supplied_now or os.clock()
end

--[[
Clears active C4 stun state from one NPC.

Args:
    target (Model): NPC whose stun state is removed.

Returns:
    nil: Clears server state and diagnostic attributes.
]]
function C4NpcStunService.clear(target: Model)
    records[target] = nil

    if target.Parent then
        target:SetAttribute("C4Stunned", false)
        target:SetAttribute("C4StunEndsAt", 0)
    end
end

--[[
Clears one stun callback only when it still owns the active generation.

Args:
    target (Model): NPC whose stun may have expired.
    record (StunRecord): Exact scheduled generation.

Returns:
    nil: Clears only the matching expired stun.
]]
local function clear_if_current(
    target: Model,
    record: StunRecord
)
    if records[target] ~= record then
        return
    end
    if os.clock() < record.expires_at then
        return
    end

    C4NpcStunService.clear(target)
end

--[[
Applies or refreshes one non-stacking C4 stun.

Stun suppresses movement and combat actions for its full source duration and
does not break when the target receives damage. A shorter refresh never
shortens an already active stun.

Args:
    target (Model): Living reviewed NPC receiving stun.
    duration_seconds (number): Positive source stun duration.
    supplied_now (number?): Optional deterministic test timestamp.

Returns:
    boolean: True when a meaningful stun is active.
]]
function C4NpcStunService.apply(
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
    target:SetAttribute("C4Stunned", true)
    target:SetAttribute("C4StunEndsAt", expires_at)
    humanoid:Move(Vector3.zero)

    if supplied_now == nil then
        task.delay(math.max(0, expires_at - now), function()
            clear_if_current(target, record)
        end)
    end

    return true
end

--[[
Returns whether one NPC is currently stunned.

Expired, destroyed or dead targets clear stale state and fail neutral.

Args:
    target (Model): NPC being checked by server AI.

Returns:
    boolean: True only while the source stun remains active.
]]
function C4NpcStunService.is_stunned(target: Model): boolean
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
        C4NpcStunService.clear(target)
        return false
    end

    return true
end

return table.freeze(C4NpcStunService)
