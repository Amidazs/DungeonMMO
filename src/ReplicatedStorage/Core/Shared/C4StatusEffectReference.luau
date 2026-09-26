--!strict
-- Exact C4 hostile periodic-effect planning and land-rate arithmetic.

local SkillEffects = require(script.Parent.C4SkillEffectSource)

local C4StatusEffectReference = {}

local SUPPORTED_EFFECTS = table.freeze({
    BLEED = table.freeze({
        EffectNames = table.freeze({"Bleed"}),
        SaveVs = "CON",
        VulnerabilityStat = "BLEED_VULN",
    }),
    POISON = table.freeze({
        EffectNames = table.freeze({"Poison", "DamOverTime"}),
        SaveVs = "MEN",
        VulnerabilityStat = "POISON_VULN",
    }),
})

--[[
Returns Java-style positive integer division.

All call sites use nonnegative numerator values and positive divisors. Keeping
this explicit preserves the integer arithmetic in C4 Formulas.calcEffectSuccess.

Args:
    numerator (number): Nonnegative integer numerator.
    denominator (number): Positive integer denominator.

Returns:
    number: Truncated integer quotient.
]]
local function integer_divide(
    numerator: number,
    denominator: number
): number
    return math.floor(numerator / denominator)
end

--[[
Returns the C4 level modifier used by hostile-effect success.

C4 doubles level growth above 69 by mapping 70 -> 72, 71 -> 74, and so on.

Args:
    level (number): Positive integer character level.

Returns:
    number: Source level modifier.
]]
local function effect_level_modifier(level: number): number
    if level >= 70 then
        return ((level - 69) * 2) + 70
    end

    return level
end

--[[
Builds one exact reviewed Bleed or Poison periodic plan.

Only DEBUFF source ranks whose effect type, save stat and effect row match the
reviewed C4 definitions are accepted.

Args:
    source_skill_id (number): Historical C4 skill identifier.
    source_rank (number): Historical source skill level.

Returns:
    (any?, string?): Frozen periodic plan or strict source-data reason.
]]
function C4StatusEffectReference.periodic_plan(
    source_skill_id: number,
    source_rank: number
): (any?, string?)
    local rank = SkillEffects.get_rank(
        source_skill_id,
        source_rank
    )
    if not rank then
        return nil, "UnknownOriginalStatusSkillRank"
    end

    local sets = rank.Sets
    local effect_type = sets.effectType
    local supported = SUPPORTED_EFFECTS[effect_type]

    if sets.skillType ~= "DEBUFF" or not supported then
        return nil, "UnsupportedOriginalPeriodicStatusType"
    end
    if sets.saveVs ~= supported.SaveVs then
        return nil, "OriginalPeriodicStatusSaveStatMismatch"
    end
    if type(sets.effectPower) ~= "number"
        or sets.effectPower <= 0
    then
        return nil, "OriginalPeriodicStatusPowerUnavailable"
    end

    local matched = nil
    for _, effect in ipairs(rank.Effects) do
        local name_supported = false
        for _, effect_name in ipairs(supported.EffectNames) do
            if effect.name == effect_name then
                name_supported = true
                break
            end
        end

        if name_supported then
            if matched ~= nil then
                return nil, "DuplicateOriginalPeriodicStatusEffect"
            end
            matched = effect
        end
    end

    if not matched
        or type(matched.val) ~= "number"
        or matched.val <= 0
        or type(matched.count) ~= "number"
        or matched.count % 1 ~= 0
        or matched.count <= 0
        or type(matched.time) ~= "number"
        or matched.time <= 0
    then
        return nil, "OriginalPeriodicStatusEffectUnavailable"
    end

    local magic_level = tonumber(sets.magicLvl) or 0
    if magic_level < 0 or magic_level % 1 ~= 0 then
        return nil, "OriginalPeriodicStatusMagicLevelInvalid"
    end

    return table.freeze({
        SourceSkillId = source_skill_id,
        SourceRank = source_rank,
        EffectType = effect_type,
        SaveVs = supported.SaveVs,
        VulnerabilityStat = supported.VulnerabilityStat,
        EffectPower = sets.effectPower,
        IsMagic = sets.isMagic == true,
        MagicLevel = magic_level,
        TickDamage = matched.val,
        TickCount = matched.count,
        TickSeconds = matched.time,
        Nonlethal = true,
    }), nil
end

--[[
Builds the reviewed C4 movement-slow side effect for Ice Bolt.

This is intentionally separate from periodic Bleed/Poison planning because
the source skill also deals direct MDAM and its Debuff effect changes movement
speed rather than scheduling damage ticks.

Args:
    source_skill_id (number): Historical C4 skill identifier.
    source_rank (number): Historical source skill level.

Returns:
    (any?, string?): Frozen movement-slow plan or strict source-data reason.
]]
function C4StatusEffectReference.movement_slow_plan(
    source_skill_id: number,
    source_rank: number
): (any?, string?)
    if source_skill_id ~= 1184 then
        return nil, "UnsupportedOriginalMovementSlowSkill"
    end

    local rank = SkillEffects.get_rank(
        source_skill_id,
        source_rank
    )
    if not rank then
        return nil, "UnknownOriginalMovementSlowSkillRank"
    end

    local sets = rank.Sets
    if sets.skillType ~= "MDAM"
        or sets.effectType ~= "DEBUFF"
        or sets.saveVs ~= "WIT"
        or sets.isMagic ~= true
        or type(sets.effectPower) ~= "number"
        or sets.effectPower <= 0
    then
        return nil, "OriginalMovementSlowContractMismatch"
    end

    local matched = nil
    for _, effect in ipairs(rank.Effects) do
        local speed_multiplier = nil

        for _, modifier in ipairs(effect.Modifiers or {}) do
            if modifier.Operation == "mul"
                and modifier.stat == "RUN_SPEED"
            then
                speed_multiplier = modifier.val
            end
        end

        if speed_multiplier ~= nil then
            if matched ~= nil then
                return nil, "DuplicateOriginalMovementSlowEffect"
            end
            matched = {
                SpeedMultiplier = speed_multiplier,
                Count = effect.count,
                DurationSeconds = effect.time,
                StackType = effect.stackType,
                StackOrder = effect.stackOrder,
            }
        end
    end

    if not matched
        or type(matched.SpeedMultiplier) ~= "number"
        or matched.SpeedMultiplier <= 0
        or matched.SpeedMultiplier >= 1
        or matched.Count ~= 1
        or type(matched.DurationSeconds) ~= "number"
        or matched.DurationSeconds <= 0
        or matched.StackType ~= "RunSpeedDown"
        or matched.StackOrder ~= matched.SpeedMultiplier
    then
        return nil, "OriginalMovementSlowEffectUnavailable"
    end

    local magic_level = tonumber(sets.magicLvl) or 0
    if magic_level < 0 or magic_level % 1 ~= 0 then
        return nil, "OriginalMovementSlowMagicLevelInvalid"
    end

    return table.freeze({
        SourceSkillId = source_skill_id,
        SourceRank = source_rank,
        EffectType = sets.effectType,
        SaveVs = sets.saveVs,
        EffectPower = sets.effectPower,
        IsMagic = true,
        MagicLevel = magic_level,
        SpeedMultiplier = matched.SpeedMultiplier,
        SlowFraction = 1 - matched.SpeedMultiplier,
        DurationSeconds = matched.DurationSeconds,
        StackType = matched.StackType,
        StackOrder = matched.StackOrder,
    }), nil
end

--[[
Builds the reviewed C4 Sleep control plan.

Sleep is a magical WIT-resisted DEBUFF with one duration effect. It is kept
separate from periodic statuses because it suppresses movement/actions and
breaks on normal damage instead of scheduling damage ticks.

Args:
    source_skill_id (number): Historical C4 skill identifier.
    source_rank (number): Historical source skill level.

Returns:
    (any?, string?): Frozen Sleep plan or strict source-data reason.
]]
function C4StatusEffectReference.sleep_plan(
    source_skill_id: number,
    source_rank: number
): (any?, string?)
    if source_skill_id ~= 1069 then
        return nil, "UnsupportedOriginalSleepSkill"
    end

    local rank = SkillEffects.get_rank(
        source_skill_id,
        source_rank
    )
    if not rank then
        return nil, "UnknownOriginalSleepSkillRank"
    end

    local sets = rank.Sets
    if sets.skillType ~= "DEBUFF"
        or sets.effectType ~= "SLEEP"
        or sets.saveVs ~= "WIT"
        or sets.isMagic ~= true
        or type(sets.effectPower) ~= "number"
        or sets.effectPower <= 0
        or sets.target ~= "TARGET_ONE"
    then
        return nil, "OriginalSleepContractMismatch"
    end

    local matched = nil
    for _, effect in ipairs(rank.Effects) do
        if effect.name == "Sleep"
            and effect.abnormal == "SLEEP"
        then
            if matched ~= nil then
                return nil, "DuplicateOriginalSleepEffect"
            end
            matched = effect
        end
    end

    if not matched
        or matched.count ~= 1
        or type(matched.time) ~= "number"
        or matched.time <= 0
    then
        return nil, "OriginalSleepEffectUnavailable"
    end

    local magic_level = tonumber(sets.magicLvl) or 0
    if magic_level < 0 or magic_level % 1 ~= 0 then
        return nil, "OriginalSleepMagicLevelInvalid"
    end

    return table.freeze({
        SourceSkillId = source_skill_id,
        SourceRank = source_rank,
        EffectType = "SLEEP",
        SaveVs = "WIT",
        EffectPower = sets.effectPower,
        IsMagic = true,
        MagicLevel = magic_level,
        DurationSeconds = matched.time,
        BreaksOnDamage = true,
        StopsMovement = true,
        StopsAttacks = true,
        StopsCasting = true,
    }), nil
end

--[[
Builds the reviewed C4 elemental-vulnerability debuff plan.

Surrender-style effects are magical WIT-resisted DEBUFFs that temporarily
multiply exactly one elemental vulnerability stat. They do not deal damage.

Args:
    source_skill_id (number): Historical C4 skill identifier.
    source_rank (number): Historical source skill level.

Returns:
    (any?, string?): Frozen vulnerability plan or strict source-data reason.
]]
function C4StatusEffectReference.elemental_vulnerability_plan(
    source_skill_id: number,
    source_rank: number
): (any?, string?)
    if source_skill_id ~= 1083 then
        return nil, "UnsupportedOriginalElementalVulnerabilitySkill"
    end

    local rank = SkillEffects.get_rank(
        source_skill_id,
        source_rank
    )
    if not rank then
        return nil, "UnknownOriginalElementalVulnerabilitySkillRank"
    end

    local sets = rank.Sets
    if sets.skillType ~= "DEBUFF"
        or sets.effectType ~= "DEBUFF"
        or sets.saveVs ~= "WIT"
        or sets.isMagic ~= true
        or sets.target ~= "TARGET_ONE"
        or type(sets.effectPower) ~= "number"
        or sets.effectPower <= 0
    then
        return nil, "OriginalElementalVulnerabilityContractMismatch"
    end

    local matched = nil
    for _, effect in ipairs(rank.Effects) do
        if effect.name == "Debuff" then
            local vulnerability_stat = nil
            local vulnerability_multiplier = nil

            for _, modifier in ipairs(effect.Modifiers or {}) do
                if modifier.Operation == "mul"
                    and modifier.stat == "FIRE_VULN"
                then
                    vulnerability_stat = modifier.stat
                    vulnerability_multiplier = modifier.val
                end
            end

            if vulnerability_stat then
                if matched ~= nil then
                    return nil,
                        "DuplicateOriginalElementalVulnerabilityEffect"
                end
                matched = {
                    Stat = vulnerability_stat,
                    Multiplier = vulnerability_multiplier,
                    Count = effect.count,
                    DurationSeconds = effect.time,
                    StackType = effect.stackType,
                    StackOrder = effect.stackOrder,
                }
            end
        end
    end

    if not matched
        or matched.Count ~= 1
        or type(matched.Multiplier) ~= "number"
        or matched.Multiplier <= 0
        or matched.Multiplier >= math.huge
        or type(matched.DurationSeconds) ~= "number"
        or matched.DurationSeconds <= 0
        or matched.StackType ~= "FireAtr"
        or matched.StackOrder ~= matched.Multiplier
    then
        return nil, "OriginalElementalVulnerabilityEffectUnavailable"
    end

    local magic_level = tonumber(sets.magicLvl) or 0
    if magic_level < 0 or magic_level % 1 ~= 0 then
        return nil, "OriginalElementalVulnerabilityMagicLevelInvalid"
    end

    return table.freeze({
        SourceSkillId = source_skill_id,
        SourceRank = source_rank,
        EffectType = "DEBUFF",
        SaveVs = "WIT",
        EffectPower = sets.effectPower,
        IsMagic = true,
        MagicLevel = magic_level,
        VulnerabilityStat = matched.Stat,
        VulnerabilityMultiplier = matched.Multiplier,
        DurationSeconds = matched.DurationSeconds,
        StackType = matched.StackType,
        StackOrder = matched.StackOrder,
    }), nil
end

--[[
Builds the reviewed C4 physical-attack weakening debuff plan.

Curse: Weakness is a magical WIT-resisted DEBUFF that temporarily multiplies
the target's physical attack. It does not change attack rate or deal damage.

Args:
    source_skill_id (number): Historical C4 skill identifier.
    source_rank (number): Historical source skill level.

Returns:
    (any?, string?): Frozen weakening plan or strict source-data reason.
]]
function C4StatusEffectReference.physical_attack_weakening_plan(
    source_skill_id: number,
    source_rank: number
): (any?, string?)
    if source_skill_id ~= 1164 then
        return nil, "UnsupportedOriginalPhysicalAttackWeakeningSkill"
    end

    local rank = SkillEffects.get_rank(
        source_skill_id,
        source_rank
    )
    if not rank then
        return nil, "UnknownOriginalPhysicalAttackWeakeningSkillRank"
    end

    local sets = rank.Sets
    if sets.skillType ~= "DEBUFF"
        or sets.effectType ~= "CONFUSION"
        or sets.saveVs ~= "WIT"
        or sets.isMagic ~= true
        or sets.target ~= "TARGET_ONE"
        or type(sets.effectPower) ~= "number"
        or sets.effectPower <= 0
    then
        return nil, "OriginalPhysicalAttackWeakeningContractMismatch"
    end

    local matched = nil
    for _, effect in ipairs(rank.Effects) do
        if effect.name == "Debuff" then
            local multiplier = nil

            for _, modifier in ipairs(effect.Modifiers or {}) do
                if modifier.Operation == "mul"
                    and modifier.stat == "PHYSICAL_ATTACK"
                then
                    multiplier = modifier.val
                end
            end

            if multiplier then
                if matched ~= nil then
                    return nil,
                        "DuplicateOriginalPhysicalAttackWeakeningEffect"
                end
                matched = {
                    Multiplier = multiplier,
                    Count = effect.count,
                    DurationSeconds = effect.time,
                    StackType = effect.stackType,
                    StackOrder = effect.stackOrder,
                }
            end
        end
    end

    if not matched
        or matched.Count ~= 1
        or type(matched.Multiplier) ~= "number"
        or matched.Multiplier <= 0
        or matched.Multiplier > 1
        or type(matched.DurationSeconds) ~= "number"
        or matched.DurationSeconds <= 0
        or matched.StackType ~= "pAtkDown"
        or matched.StackOrder ~= matched.Multiplier
    then
        return nil, "OriginalPhysicalAttackWeakeningEffectUnavailable"
    end

    local magic_level = tonumber(sets.magicLvl) or 0
    if magic_level < 0 or magic_level % 1 ~= 0 then
        return nil, "OriginalPhysicalAttackWeakeningMagicLevelInvalid"
    end

    return table.freeze({
        SourceSkillId = source_skill_id,
        SourceRank = source_rank,
        EffectType = sets.effectType,
        SaveVs = "WIT",
        EffectPower = sets.effectPower,
        IsMagic = true,
        MagicLevel = magic_level,
        PhysicalAttackMultiplier = matched.Multiplier,
        PowerReductionFraction = math.round(
            (1 - matched.Multiplier) * 1000000
        ) / 1000000,
        DurationSeconds = matched.DurationSeconds,
        StackType = matched.StackType,
        StackOrder = matched.StackOrder,
    }), nil
end

--[[
Calculates exact C4 hostile-effect land rate before the final random roll.

This reproduces Formulas.calcEffectSuccess for the reviewed Bleed/Poison scope:
save-stat bonus, optional magical M.Atk/M.Def factor, Spiritshot adjustment,
skill/character level delta, 1-99 clamp, then target vulnerability.

Args:
    args (any): Source-owned effect, attacker and target formula inputs.

Returns:
    (number?, string?): Final source land rate against a 0-99 roll.
]]
function C4StatusEffectReference.effect_success_rate(
    args: any
): (number?, string?)
    if type(args) ~= "table" then
        return nil, "InvalidOriginalEffectSuccessInputs"
    end

    local power = args.Power
    local stat_bonus = args.TargetStatBonus
    local vulnerability = args.TargetVulnerability
    local attacker_level = args.AttackerLevel
    local target_level = args.TargetLevel
    local magic_level = args.MagicLevel

    if type(power) ~= "number"
        or power <= 0
        or type(stat_bonus) ~= "number"
        or stat_bonus <= 0
        or type(vulnerability) ~= "number"
        or vulnerability < 0
        or type(attacker_level) ~= "number"
        or attacker_level % 1 ~= 0
        or attacker_level <= 0
        or type(target_level) ~= "number"
        or target_level % 1 ~= 0
        or target_level <= 0
        or type(magic_level) ~= "number"
        or magic_level % 1 ~= 0
        or magic_level < 0
    then
        return nil, "InvalidOriginalEffectSuccessInputs"
    end

    local rate = math.floor(power * stat_bonus)

    if args.IsMagic == true then
        local magical_attack = args.AttackerMAtk
        local magical_defence = args.TargetMDef
        if type(magical_attack) ~= "number"
            or magical_attack <= 0
            or type(magical_defence) ~= "number"
            or magical_defence <= 0
        then
            return nil, "OriginalEffectMagicStatsUnavailable"
        end

        rate = math.floor(
            rate
                * (
                    magical_attack / magical_defence
                ) ^ 0.2
        )
    end

    local shot_modifier = 100
    if args.BlessedSpiritshot == true then
        shot_modifier = 200
    elseif args.Spiritshot == true then
        shot_modifier = 150
    end

    if shot_modifier ~= 100 then
        local threshold = integer_divide(
            10000,
            100 + shot_modifier
        )
        if rate > threshold then
            rate = 100 - integer_divide(
                (100 - rate) * 100,
                shot_modifier
            )
        else
            rate = integer_divide(
                rate * shot_modifier,
                100
            )
        end
    end

    local attacker_modifier =
        effect_level_modifier(attacker_level)
    local target_modifier =
        effect_level_modifier(target_level)

    local delta
    if magic_level == 0 then
        delta = attacker_modifier - target_modifier
    else
        delta = (
            (magic_level + attacker_modifier) / 2
        ) - target_modifier
    end

    local delta_modifier
    if delta + 3 < 0 then
        if delta <= -20 then
            delta_modifier = 0.05
        else
            delta_modifier = 1 - ((-1) * (delta / 20))
            if delta_modifier >= 1 then
                delta_modifier = 0.05
            end
        end
    else
        delta_modifier = 1 + ((delta + 3) / 75)
    end

    if delta_modifier < 0 then
        delta_modifier *= -1
    end

    rate = math.floor(rate * delta_modifier)
    rate = math.clamp(rate, 1, 99)
    rate = math.floor(rate * vulnerability)

    return rate, nil
end

--[[
Resolves one exact C4 hostile-effect random roll.

Rnd.get(100) produces an integer from 0 through 99 and succeeds only when the
roll is strictly lower than the final source rate.

Args:
    args (any): Inputs accepted by effect_success_rate.
    roll (number): Server-owned integer roll from 0 through 99.

Returns:
    (any?, string?): Land result with rate/roll evidence or strict reason.
]]
function C4StatusEffectReference.resolve_effect_success(
    args: any,
    roll: number
): (any?, string?)
    if type(roll) ~= "number"
        or roll % 1 ~= 0
        or roll < 0
        or roll > 99
    then
        return nil, "InvalidOriginalEffectSuccessRoll"
    end

    local rate, reason =
        C4StatusEffectReference.effect_success_rate(args)
    if rate == nil then
        return nil, reason
    end

    return {
        Rate = rate,
        Roll = roll,
        Landed = roll < rate,
    }, nil
end

--[[
Calculates one exact nonlethal C4 Bleed/Poison tick.

EffectBleed and EffectPoison cap damage at current HP minus one and therefore
cannot kill their target through a periodic tick.

Args:
    current_health (number): Current positive target HP.
    tick_damage (number): Positive source effect value.

Returns:
    (any?, string?): Applied damage and resulting health or strict reason.
]]
function C4StatusEffectReference.nonlethal_tick(
    current_health: number,
    tick_damage: number
): (any?, string?)
    if type(current_health) ~= "number"
        or current_health < 0
        or type(tick_damage) ~= "number"
        or tick_damage < 0
    then
        return nil, "InvalidOriginalPeriodicTickInputs"
    end

    if current_health <= 1 then
        return {
            AppliedDamage = 0,
            HealthAfter = current_health,
        }, nil
    end

    local applied = math.min(
        tick_damage,
        current_health - 1
    )

    return {
        AppliedDamage = applied,
        HealthAfter = current_health - applied,
    }, nil
end

return table.freeze(C4StatusEffectReference)
