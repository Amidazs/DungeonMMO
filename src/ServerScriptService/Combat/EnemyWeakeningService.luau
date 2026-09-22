--!strict
-- Server-owned bounded, non-stacking hostile weakening for NPCs.
-- Only authenticated server combat calls apply; no client remote exists.

local EnemyWeakeningService = {}

type WeakeningRecord = {
    power_fraction: number,
    rate_fraction: number,
    expires_at: number,
}

local records: {[Model]: WeakeningRecord} = {}

--[[
Clears a weakening record and its non-authoritative UI indicators.

Args:
    target (Model): Enemy whose status should be removed.

Returns:
    nil: Clears the status and indicators.
]]
function EnemyWeakeningService.clear(target: Model)
    records[target] = nil
    if target.Parent then
        target:SetAttribute("C4PowerWeakening", 0)
        target:SetAttribute("C4RateWeakening", 0)
        target:SetAttribute("C4WeakeningEndsAt", 0)
    end
end

--[[
Reads live server-only status, rejecting dead and expired targets.

Args:
    target (Instance): NPC whose outgoing attack is being resolved.

Returns:
    WeakeningRecord?: Active status, or nil when inapplicable.
]]
local function active(target: Instance): WeakeningRecord?
    if not target:IsA("Model") then
        return nil
    end
    local record = records[target]
    if not record then
        return nil
    end
    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if not target.Parent or not humanoid or humanoid.Health <= 0
        or os.clock() >= record.expires_at
    then
        EnemyWeakeningService.clear(target)
        return nil
    end
    return record
end

--[[
Applies genuine server-origin NPC power or attack-rate weakness.

Stronger live effects remain in force without multiplying repeated
casts. The status expires after the latest valid application.

Args:
    target (Model): Living NPC hit by an authored projectile.
    power_fraction (number): Outgoing physical damage reduction.
    rate_fraction (number): Reduction to future attack frequency.
    duration_seconds (number): Authored status lifetime in seconds.

Returns:
    boolean: True if an eligible target received a valid status.
]]
function EnemyWeakeningService.apply(
    target: Model,
    power_fraction: number,
    rate_fraction: number,
    duration_seconds: number
): boolean
    local power = tonumber(power_fraction)
    local rate = tonumber(rate_fraction)
    local duration = tonumber(duration_seconds)
    if not power or power ~= power or not rate or rate ~= rate
        or not duration or duration ~= duration
        or power < 0 or power > 0.5 or rate < 0 or rate > 0.5
        or (power == 0 and rate == 0)
        or duration <= 0 or duration > 30 or not target.Parent
    then
        return false
    end
    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end

    local prior = active(target)
    local expires_at = os.clock() + duration
    local record: WeakeningRecord = {
        power_fraction = math.max(
            power, if prior then prior.power_fraction else 0
        ),
        rate_fraction = math.max(
            rate, if prior then prior.rate_fraction else 0
        ),
        expires_at = math.max(
            expires_at, if prior then prior.expires_at else 0
        ),
    }
    records[target] = record
    target:SetAttribute("C4PowerWeakening", record.power_fraction)
    target:SetAttribute("C4RateWeakening", record.rate_fraction)
    target:SetAttribute("C4WeakeningEndsAt", record.expires_at)

    task.delay(record.expires_at - os.clock(), function()
        if records[target] == record
            and os.clock() >= record.expires_at then
            EnemyWeakeningService.clear(target)
        end
    end)
    return true
end

--[[
Returns the genuine reduction applied to outgoing NPC damage.

Args:
    enemy (Instance): Server-controlled attacker.

Returns:
    number: Non-stacking attack multiplier from 0.5 to 1.
]]
function EnemyWeakeningService.get_damage_multiplier(enemy: Instance): number
    local record = active(enemy)
    return if record then 1 - record.power_fraction else 1
end

--[[
Returns the increased next-attack interval for a weakened NPC.

Args:
    enemy (Instance): Server-controlled attacker.

Returns:
    number: Next-attack interval multiplier from 1 to 2.
]]
function EnemyWeakeningService.get_interval_multiplier(enemy: Instance): number
    local record = active(enemy)
    return if record then 1 / (1 - record.rate_fraction) else 1
end

return table.freeze(EnemyWeakeningService)
