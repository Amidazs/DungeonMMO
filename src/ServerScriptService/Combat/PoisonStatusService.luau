--!strict
-- Server-owned, non-stacking poison for C4-inspired magic and cleansing.
-- No client supplies poison strength, target, expiry or tick damage.
local Players = game:GetService("Players")

local DamageService = require(script.Parent:WaitForChild("DamageService"))

local PoisonStatusService = {}

type PoisonRecord = {
    serial: number,
    tier: number,
    expires_at: number,
    attacker: Player?,
    attacker_character: Model?,
    source_id: string,
}

local records: {[Model]: PoisonRecord} = {}
local next_serial = 0

--[[
Clears only the poison instance matching a captured serial so an old
timer can never erase a refreshed status.

Args:
    target (Model): Server-owned poisoned target.
    serial (number): Unique status application identifier.

Returns:
    nil: Invalidates the matching status and its public indicators.
]]
local function clear_matching(target: Model, serial: number)
    local current = records[target]
    if not current or current.serial ~= serial then
        return
    end
    records[target] = nil
    if target.Parent then
        target:SetAttribute("C4PoisonTier", 0)
        target:SetAttribute("C4PoisonExpiresAt", 0)
    end
end

--[[
Returns whether a live model has a current server-authored poison.

Args:
    target (Model?): Existing Roblox character or NPC model.

Returns:
    boolean: True only for an unexpired authoritative poison record.
]]
function PoisonStatusService.is_poisoned(target: Model?): boolean
    local current = target and records[target]
    return current ~= nil
        and target ~= nil
        and target.Parent ~= nil
        and current.expires_at > os.clock()
end

--[[
Clears a live poison only when its actual server tier is curable.
The replicated status attributes are never trusted as proof of poison.

Args:
    target (Model?): Live friendly or enemy model.
    maximum_tier (number): Authored spell's highest curable tier.

Returns:
    boolean: True only when a real poison record was removed.
]]
function PoisonStatusService.cure(
    target: Model?,
    maximum_tier: number
): boolean
    if not target or not PoisonStatusService.is_poisoned(target) then
        return false
    end
    local current = records[target]
    if not current or current.tier > maximum_tier then
        return false
    end
    clear_matching(target, current.serial)
    return true
end

--[[
Runs one future server-authoritative poison tick. Only the active
serial may damage an existing living target, and the original player
must still own the same live character if this is a player spell.

Args:
    target (Model): The poisoned NPC or player.
    serial (number): Captured authoritative poison application.
    damage (number): Server-authored damage for one tick.
    remaining (number): Remaining ticks, including the current one.
    tick_seconds (number): Bounded interval for future ticks.

Returns:
    nil: Applies one damage tick and schedules the next valid tick.
]]
local function apply_tick(
    target: Model,
    serial: number,
    damage: number,
    remaining: number,
    tick_seconds: number
)
    local current = records[target]
    if not current or current.serial ~= serial then
        return
    end
    local humanoid = target:FindFirstChildOfClass("Humanoid")
    local attacker = current.attacker
    if not target.Parent or not humanoid or humanoid.Health <= 0
        or (attacker and (
            attacker.Parent ~= Players
            or attacker.Character ~= current.attacker_character
        ))
    then
        clear_matching(target, serial)
        return
    end

    DamageService.apply_damage({
        attacker = attacker,
        attacker_character = current.attacker_character,
        target = target,
        source_kind = if attacker then "MagicSkill" else "EnemyMagic",
        source_id = current.source_id,
        attack_id = current.source_id,
        base_damage = damage,
        multiplier = 1,
    })
    if remaining <= 1 then
        clear_matching(target, serial)
    else
        task.delay(tick_seconds, function()
            apply_tick(
                target, serial, damage, remaining - 1, tick_seconds
            )
        end)
    end
end

--[[
Applies a bounded and non-stacking real poison after a trusted
server combat hit or server-owned enemy attack. The player's target
must be an NPC and an NPC's target must be an actual player.

Args:
    target (Model): Living server-validated target model.
    attacker (Player?): Live caster, or nil for server-owned NPCs.
    damage (number): Authored poison damage on each periodic tick.
    tick_count (number): Authored number of ticks, at most six.
    tick_seconds (number): Authored seconds between ticks.
    tier (number): Positive authored status tier.
    source_id (string): Authored skill or NPC attack identifier.

Returns:
    boolean: True when a valid live poison was applied.
]]
function PoisonStatusService.apply(
    target: Model,
    attacker: Player?,
    damage: number,
    tick_count: number,
    tick_seconds: number,
    tier: number,
    source_id: string
): boolean
    local humanoid = target:FindFirstChildOfClass("Humanoid")
    if not target.Parent or not humanoid or humanoid.Health <= 0
        or type(source_id) ~= "string" or source_id == ""
        or type(damage) ~= "number" or damage <= 0 or damage > 25
        or type(tick_count) ~= "number"
        or tick_count % 1 ~= 0 or tick_count < 1 or tick_count > 6
        or type(tick_seconds) ~= "number"
        or tick_seconds < 0.1 or tick_seconds > 3
        or type(tier) ~= "number" or tier % 1 ~= 0
        or tier < 1 or tier > 7
    then
        return false
    end

    local defender = Players:GetPlayerFromCharacter(target)
    if attacker then
        if attacker.Parent ~= Players or defender ~= nil
            or attacker.Character == nil
        then
            return false
        end
    elseif not defender then
        return false
    end

    next_serial += 1
    local serial = next_serial
    local expires_at = os.clock() + tick_count * tick_seconds
    records[target] = {
        serial = serial,
        tier = tier,
        expires_at = expires_at,
        attacker = attacker,
        attacker_character = if attacker then attacker.Character
            else nil,
        source_id = source_id,
    }
    target:SetAttribute("C4PoisonTier", tier)
    target:SetAttribute("C4PoisonExpiresAt", expires_at)
    task.delay(tick_seconds, function()
        apply_tick(target, serial, damage, tick_count, tick_seconds)
    end)
    return true
end

return table.freeze(PoisonStatusService)
