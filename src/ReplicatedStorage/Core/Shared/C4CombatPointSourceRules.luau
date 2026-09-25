--!strict
-- Exact Chronicle 4 Combat Point source rules needed by the server runtime.

local Shared = script.Parent

local C4ResourceRegenSourceRules = require(
    Shared:WaitForChild("C4ResourceRegenSourceRules")
)

local C4CombatPointSourceRules = {}

local SOURCE_COMMIT =
    "07f8536384e799f128d44198dd7ab23519660eea"
local REGEN_PERIOD_SECONDS = 3
local CP_REGEN_MULTIPLIER = 1

--[[
Calculates the source CP regeneration amount for one three-second tick.

The pinned C4 runtime starts from the class template's BaseHpRegen, adds the
integer level band, multiplies by level modifier and CON bonus, then applies
the movement multiplier. The default CpRegenMultiplier is 100%, or 1.0.

Args:
    race_id (string): Original Human or Elf race.
    class_id (string): Supported starter or first-transfer class.
    level (number): Reviewed original character level.
    movement_state (string): Sitting, Standing, Walking or Running.

Returns:
    (number?, string?): CP restored per three-second tick, or denial reason.
]]
function C4CombatPointSourceRules.regen_per_tick(
    race_id: string,
    class_id: string,
    level: number,
    movement_state: string
): (number?, string?)
    local base_stats, base_reason =
        C4ResourceRegenSourceRules.base_calculator_stats(
            race_id,
            class_id,
            level
        )

    if not base_stats then
        if base_reason == "OriginalClassNotVerified" then
            return nil, base_reason
        end
        return nil, base_reason
    end

    local tick, tick_reason =
        C4ResourceRegenSourceRules.apply_movement(
            base_stats,
            movement_state
        )

    if not tick then
        if tick_reason == "InvalidOriginalResourceMovementState" then
            return nil, "InvalidOriginalCPMovementState"
        end
        return nil, tick_reason
    end

    return tick.CP * CP_REGEN_MULTIPLIER, nil
end

--[[
Applies the C4 playable-attacker CP absorption rule to one damage amount.

NPC damage bypasses CP completely. For playable attackers, CP absorbs damage
first and only the remainder reaches HP.

Args:
    current_cp (number): Authoritative current CP before the hit.
    damage (number): Non-negative incoming damage after prior hit resolution.
    attacker_is_playable (boolean): True only for a playable attacker.

Returns:
    (any?, string?): New CP, HP damage and CP absorbed, or denial reason.
]]
function C4CombatPointSourceRules.resolve_damage(
    current_cp: number,
    damage: number,
    attacker_is_playable: boolean
): (any?, string?)
    if type(current_cp) ~= "number"
        or current_cp ~= current_cp
        or current_cp < 0
        or math.abs(current_cp) >= math.huge
        or type(damage) ~= "number"
        or damage ~= damage
        or damage < 0
        or math.abs(damage) >= math.huge
        or type(attacker_is_playable) ~= "boolean"
    then
        return nil, "InvalidOriginalCPDamageInput"
    end

    if not attacker_is_playable or damage == 0 then
        return {
            CurrentCP = current_cp,
            HealthDamage = damage,
            CPAbsorbed = 0,
        }, nil
    end

    local absorbed = math.min(current_cp, damage)

    return {
        CurrentCP = current_cp - absorbed,
        HealthDamage = damage - absorbed,
        CPAbsorbed = absorbed,
    }, nil
end

--[[
Returns immutable provenance and timing metadata for the CP runtime.

Args:
    None.

Returns:
    any: Source semantics required by the server authority boundary.
]]
function C4CombatPointSourceRules.metadata(): any
    return {
        RegenPeriodSeconds = REGEN_PERIOD_SECONDS,
        CpRegenMultiplier = CP_REGEN_MULTIPLIER,
        PlayableAttackerOnly = true,
        NpcDamageBypassesCP = true,
        SourceCommit = SOURCE_COMMIT,
        MovementMultipliers =
            C4ResourceRegenSourceRules.metadata().MovementMultipliers,
        SourceOnly = true,
    }
end

return table.freeze(C4CombatPointSourceRules)
