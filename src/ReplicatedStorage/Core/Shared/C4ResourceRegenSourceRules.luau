--!strict
-- Pinned C4 HP/MP/CP regeneration calculator inputs and movement timing.

local Shared = script.Parent

local Derived = require(Shared.C4DerivedStatReference)
local Primary = require(Shared.C4PrimaryStatReference)

local C4ResourceRegenSourceRules = {}

local SOURCE_COMMIT =
    "07f8536384e799f128d44198dd7ab23519660eea"
local REGEN_PERIOD_SECONDS = 3
local MOVEMENT_MULTIPLIERS = table.freeze({
    Sitting = 1.5,
    Standing = 1.1,
    Walking = 1,
    Running = 0.7,
})

--[[
Returns the C4 integer level-band addition used by HP and CP regeneration.

Java integer division is intentional above level ten.

Args:
    level (number): Reviewed original character level.

Returns:
    number: Source BaseHpRegen level addition.
]]
local function hp_cp_level_add(level: number): number
    if level <= 10 then
        return 0.5
    end

    return math.floor((level - 1) / 10)
end

--[[
Returns the C4 integer-band addition used by MP regeneration.

Args:
    level (number): Reviewed original character level.

Returns:
    number: Source BaseMpRegen level addition.
]]
local function mp_level_add(level: number): number
    return 0.3 * math.floor((level - 1) / 10)
end

--[[
Builds the source calculator inputs before REG_* skill functions.

These are the exact ordinary-player inputs to C4 calcStat(REG_*_RATE, init)
outside special C4 world zones. Passive/active source functions must be
applied to these values before movement multipliers are applied.

Args:
    race_id (string): Historical Human or Elf race.
    class_id (string): Starter or reviewed first-transfer class.
    level (number): Reviewed source level through the current level-30 cap.

Returns:
    (any?, string?): Base REG_HP/MP/CP_RATE values or source denial reason.
]]
function C4ResourceRegenSourceRules.base_calculator_stats(
    race_id: string,
    class_id: string,
    level: number
): (any?, string?)
    local reference = Primary.get(race_id, class_id)
    local template = reference and reference.Template
    local _, vital_reason = Primary.get_level_vitals(
        race_id,
        class_id,
        level
    )

    if not template or vital_reason then
        return nil, vital_reason or "UnreviewedClassOrLevel"
    end

    local level_modifier = Derived.level_modifier(level)
    if not level_modifier then
        return nil, "UnreviewedClassOrLevel"
    end

    local hp_cp = (
        template.BaseHpRegen + hp_cp_level_add(level)
    ) * level_modifier * template.ConBonus
    local mp = (
        template.BaseMpRegen + mp_level_add(level)
    ) * level_modifier * template.MenBonus

    return {
        REG_HP_RATE = math.max(1, hp_cp),
        REG_MP_RATE = math.max(1, mp),
        REG_CP_RATE = math.max(1, hp_cp),
        SourceCommit = SOURCE_COMMIT,
        SourceOnly = true,
        SpecialWorldBonusesIntegrated = false,
    }, nil
end

--[[
Applies ordinary C4 movement multipliers to source-calculated regen stats.

The supplied REG_* values may already include exact owned passive and active
source functions. C4 festival, clan-hall, siege and Mother Tree bonuses are
not DungeonMMO systems and remain explicitly outside this baseline.

Args:
    source_stats (any): Final source REG_HP/MP/CP_RATE calculator values.
    movement_state (string): Sitting, Standing, Walking or Running.

Returns:
    (any?, string?): Three-second resource gains or strict denial reason.
]]
function C4ResourceRegenSourceRules.apply_movement(
    source_stats: any,
    movement_state: string
): (any?, string?)
    local multiplier = MOVEMENT_MULTIPLIERS[movement_state]

    if not multiplier then
        return nil, "InvalidOriginalResourceMovementState"
    end

    if type(source_stats) ~= "table" then
        return nil, "InvalidOriginalResourceRegenStats"
    end

    for _, stat_name in ipairs({
        "REG_HP_RATE",
        "REG_MP_RATE",
        "REG_CP_RATE",
    }) do
        local value = source_stats[stat_name]
        if type(value) ~= "number"
            or value ~= value
            or value < 0
            or math.abs(value) >= math.huge
        then
            return nil, "InvalidOriginalResourceRegenStats"
        end
    end

    return {
        HP = source_stats.REG_HP_RATE * multiplier,
        MP = source_stats.REG_MP_RATE * multiplier,
        CP = source_stats.REG_CP_RATE * multiplier,
        MovementState = movement_state,
        MovementMultiplier = multiplier,
        PeriodSeconds = REGEN_PERIOD_SECONDS,
        SourceCommit = SOURCE_COMMIT,
        SourceOnly = true,
        SpecialWorldBonusesIntegrated = false,
    }, nil
end

--[[
Returns source metadata used by resource migration acceptance.

Args:
    None.

Returns:
    any: Pinned timing, default multipliers and unsupported world bonuses.
]]
function C4ResourceRegenSourceRules.metadata(): any
    return {
        SourceCommit = SOURCE_COMMIT,
        RegenPeriodSeconds = REGEN_PERIOD_SECONDS,
        HpRegenMultiplier = 1,
        MpRegenMultiplier = 1,
        CpRegenMultiplier = 1,
        SpecialWorldBonusesIntegrated = false,
        MovementMultipliers = table.clone(MOVEMENT_MULTIPLIERS),
        SourceOnly = true,
    }
end

return table.freeze(C4ResourceRegenSourceRules)
