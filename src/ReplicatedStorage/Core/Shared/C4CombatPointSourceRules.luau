--!strict
-- Exact Chronicle 4 Combat Point source rules needed by the server runtime.

local Shared = script.Parent

local C4DerivedStatReference = require(
    Shared:WaitForChild("C4DerivedStatReference")
)
local C4PrimaryStatReference = require(
    Shared:WaitForChild("C4PrimaryStatReference")
)

local C4CombatPointSourceRules = {}

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
    local reference = C4PrimaryStatReference.get(
        race_id,
        class_id
    )
    local template = reference and reference.Template

    if not template then
        return nil, "OriginalClassNotVerified"
    end

    local vitals, vital_reason =
        C4PrimaryStatReference.get_level_vitals(
            race_id,
            class_id,
            level
        )

    if not vitals then
        return nil, vital_reason
    end

    local level_modifier =
        C4DerivedStatReference.level_modifier(level)

    if not level_modifier then
        return nil, "UnreviewedClassOrLevel"
    end

    local movement_multiplier = nil

    if movement_state == "Sitting" then
        movement_multiplier = 1.5
    elseif movement_state == "Standing" then
        movement_multiplier = 1.1
    elseif movement_state == "Walking" then
        movement_multiplier = 1
    elseif movement_state == "Running" then
        movement_multiplier = 0.7
    else
        return nil, "InvalidOriginalCPMovementState"
    end

    local level_add = if level > 10
        then math.floor((level - 1) / 10)
        else 0.5
    local base_regen = template.BaseHpRegen + level_add

    base_regen *= level_modifier * template.ConBonus
    base_regen = math.max(1, base_regen)

    return base_regen
        * CP_REGEN_MULTIPLIER
        * movement_multiplier, nil
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
        SourceOnly = true,
    }
end

return table.freeze(C4CombatPointSourceRules)
