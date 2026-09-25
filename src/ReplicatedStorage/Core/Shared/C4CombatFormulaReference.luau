--!strict
-- Pure Chronicle 4 combat formula transcription for deterministic tests.
-- Runtime integration comes only after equipment/stat calculator migration.
local C4CombatFormulaReference = {}

local SOURCE_COMMIT =
    "07f8536384e799f128d44198dd7ab23519660eea"
local FORMULAS_URL =
    "https://github.com/Neco-spain/"
    .. "l2jadmins_C4-Scions-of-Destiny/blob/"
    .. SOURCE_COMMIT
    .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
    .. "character/skills/stats/Formulas.java"
local HEAL_URL =
    "https://github.com/Neco-spain/"
    .. "l2jadmins_C4-Scions-of-Destiny/blob/"
    .. SOURCE_COMMIT
    .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/manager/"
    .. "character/skills/effects/type/EffectHeal.java"

local CONFIG_URL =
    "https://github.com/Neco-spain/"
    .. "l2jadmins_C4-Scions-of-Destiny/blob/"
    .. SOURCE_COMMIT
    .. "/L2jAdmins_Core/src/l2j/Config.java"

local CHARACTER_URL =
    "https://github.com/Neco-spain/"
    .. "l2jadmins_C4-Scions-of-Destiny/blob/"
    .. SOURCE_COMMIT
    .. "/L2jAdmins_Core/src/l2j/gameserver/model/actor/"
    .. "L2Character.java"
local RND_URL =
    "https://github.com/Neco-spain/"
    .. "l2jadmins_C4-Scions-of-Destiny/blob/"
    .. SOURCE_COMMIT
    .. "/L2jAdmins_Core/src/l2j/util/Rnd.java"

local PERFECT_SHIELD_CONFIG_RATE = 5

--[[
Checks one finite positive numeric combat argument.

Args:
    value (number): Formula input.
    label (string): Error label.

Returns:
    number: Validated unchanged value.
]]
local function positive(value: number, label: string): number
    assert(type(value) == "number"
        and value == value
        and value > 0
        and value < math.huge,
        label .. " must be finite and positive")
    return value
end

--[[
Computes Chronicle 4 physical damage before external race/item effects.

This implements calcPhysDam's main arithmetic exactly when callers
provide the already-calculated P.Atk/P.Def and explicit multipliers.
Random weapon variance is passed in, allowing deterministic tests.

Args:
    values (any): PAtk/PDef, optional skill power, shield, shots,
        critical modifiers, vulnerabilities, random and PvP multipliers.

Returns:
    number: C4 physical formula result before HP rounding/application.
]]
function C4CombatFormulaReference.physical_damage(values: any): number
    local p_atk = positive(values.PAtk, "PAtk")
    local p_def = positive(values.PDef, "PDef")
    local skill_power = tonumber(values.SkillPower) or 0
    assert(skill_power >= 0 and skill_power < math.huge,
        "SkillPower must be finite and nonnegative")
    p_atk += skill_power

    if values.Soulshot == true then
        p_atk *= 2
    end
    if values.Shield == true then
        if values.PerfectShield == true then
            return 1
        end
        p_def += math.max(tonumber(values.ShieldDefense) or 0, 0)
    end

    if values.Critical == true then
        local critical_power = tonumber(
            values.CriticalPowerMultiplier
        ) or 1
        local critical_add = tonumber(values.CriticalPowerAdd) or 0
        p_atk = 2 * critical_power * ((70 * p_atk) / p_def)
        p_atk += (critical_add * 70) / p_def
    else
        p_atk = (70 * p_atk) / p_def
    end

    p_atk *= tonumber(values.WeaponVulnerabilityMultiplier) or 1
    p_atk *= tonumber(values.RandomDamageMultiplier) or 1
    p_atk *= tonumber(values.RaceMultiplier) or 1
    p_atk = math.max(p_atk, 0)
    p_atk *= tonumber(values.PvpMultiplier) or 1
    if values.NoblePvp == true then
        p_atk *= 1.05
    end
    return p_atk
end

--[[
Computes Chronicle 4 magical damage main formula.

Args:
    values (any): MAtk/MDef, source skill power, shot state, magic
        critical and already-resolved failure/element/PvP multipliers.

Returns:
    number: C4 magic damage result before target HP application.
]]
function C4CombatFormulaReference.magic_damage(values: any): number
    local m_atk = positive(values.MAtk, "MAtk")
    local m_def = positive(values.MDef, "MDef")
    local power = positive(values.SkillPower, "SkillPower")

    if values.BlessedSpiritshot == true then
        m_atk *= 4
    elseif values.Spiritshot == true then
        m_atk *= 2
    end

    local damage = ((91 * math.sqrt(m_atk)) / m_def) * power
    if values.Failure == "Resisted" then
        damage = 1
    elseif values.Failure == "Half" then
        damage /= 2
    elseif values.MagicCritical == true then
        damage *= 4
    end

    damage *= tonumber(values.PvpMultiplier) or 1
    if values.NoblePvp == true then
        damage *= 1.05
    end
    damage *= tonumber(values.ElementalMultiplier) or 1
    return damage
end

--[[
Computes the Chronicle 4 instant heal amount in EffectHeal.

The C4 handler applies skill/effect power directly, with ordinary
Spiritshot x1.3 or Blessed Spiritshot x1.5. It does not multiply
this effect by the caster's M.Atk in the reviewed C4 source.

Args:
    power (number): Historical heal effect power.
    spiritshot (boolean): Ordinary Spiritshot state.
    blessed_spiritshot (boolean): Blessed Spiritshot state.

Returns:
    number: Exact source heal amount before MaxHP clamping.
]]
function C4CombatFormulaReference.heal_amount(
    power: number, spiritshot: boolean,
    blessed_spiritshot: boolean
): number
    local amount = positive(power, "Heal power")
    if blessed_spiritshot then
        return amount * 1.5
    end
    if spiritshot then
        return amount * 1.3
    end
    return amount
end

--[[
Returns C4 normal-attack delay in milliseconds from physical attack speed.

Args:
    physical_attack_speed (number): Final source attack-speed stat.

Returns:
    number: Source attack delay, truncated like the Java integer cast.
]]
function C4CombatFormulaReference.physical_attack_delay(
    physical_attack_speed: number
): number
    positive(physical_attack_speed, "Physical attack speed")
    if physical_attack_speed < 2 then
        return 2700
    end
    return math.floor(470000 / physical_attack_speed)
end

--[[
Returns C4 skill animation/cast time after attack/cast speed scaling.

Args:
    source_time_ms (number): Authored source skill time.
    attack_speed (number): Final physical or magical attack speed.

Returns:
    number: Positive Java integer-division equivalent in milliseconds.
]]
function C4CombatFormulaReference.skill_cast_time(
    source_time_ms: number, attack_speed: number
): number
    positive(source_time_ms, "Source skill time")
    positive(attack_speed, "Attack speed")
    return math.floor(
        math.floor(source_time_ms * 333) / attack_speed
    )
end

--[[
Returns the C4 raw hit chance before positional condition multiplier.

The source stores the chance in thousandths: 905 means 90.5%.

Args:
    accuracy (number): Final attacker accuracy.
    evasion (number): Final target evasion.

Returns:
    number: Bounded source hit chance from 275 to 980 per thousand.
]]
function C4CombatFormulaReference.hit_chance_per_thousand(
    accuracy: number, evasion: number
): number
    local delta = math.floor(accuracy - evasion)
    if delta >= 10 then return 980 end
    local exact = {
        [9] = 975, [8] = 970, [7] = 965, [6] = 960,
        [5] = 955, [4] = 945, [3] = 935, [2] = 925,
        [1] = 915, [0] = 905, [-1] = 890, [-2] = 875,
        [-3] = 860, [-4] = 845, [-5] = 830, [-6] = 815,
        [-7] = 800, [-8] = 785, [-9] = 770, [-10] = 755,
        [-11] = 735, [-12] = 715, [-13] = 695,
        [-14] = 675, [-15] = 655, [-16] = 625,
        [-17] = 595, [-18] = 565, [-19] = 535,
        [-20] = 505, [-21] = 455, [-22] = 405,
        [-23] = 355, [-24] = 305,
    }
    return exact[delta] or 275
end

--[[
Applies the C4 hit-condition multiplier and final source caps.

The historical source multiplies the raw Accuracy/Evasion chance by the
server-calculated positional/environment condition bonus, then clamps the
result to 27.5%-98%. A neutral multiplier of 1 represents no condition bonus.

Args:
    accuracy (number): Final attacker source accuracy.
    evasion (number): Final defender source evasion.
    condition_multiplier (number): Server-owned source condition multiplier.

Returns:
    number: Final bounded C4 hit chance per thousand.
]]
function C4CombatFormulaReference.hit_chance_with_condition(
    accuracy: number,
    evasion: number,
    condition_multiplier: number
): number
    assert(
        type(condition_multiplier) == "number"
            and condition_multiplier == condition_multiplier
            and condition_multiplier >= 0
            and condition_multiplier < math.huge,
        "Hit condition multiplier must be finite and nonnegative"
    )

    local chance = C4CombatFormulaReference.hit_chance_per_thousand(
        accuracy,
        evasion
    ) * condition_multiplier

    return math.max(math.min(chance, 980), 275)
end

--[[
Resolves one exact C4 normal-attack hit roll.

The source draws an integer in the inclusive 0-999 range and misses only when
the final hit chance is strictly lower than that roll. A roll equal to the
chance still lands.

Args:
    accuracy (number): Final attacker source accuracy.
    evasion (number): Final defender source evasion.
    condition_multiplier (number): Server-owned source condition multiplier.
    roll (number): Server-owned integer random roll from 0 through 999.

Returns:
    any: Detached hit/miss result containing chance and roll evidence.
]]
function C4CombatFormulaReference.resolve_normal_attack_hit(
    accuracy: number,
    evasion: number,
    condition_multiplier: number,
    roll: number
): any
    assert(
        type(roll) == "number"
            and roll % 1 == 0
            and roll >= 0
            and roll <= 999,
        "Hit roll must be an integer from 0 through 999"
    )

    local chance = C4CombatFormulaReference.hit_chance_with_condition(
        accuracy,
        evasion,
        condition_multiplier
    )
    local missed = chance < roll

    return {
        ChancePerThousand = chance,
        Roll = roll,
        Hit = not missed,
        Miss = missed,
    }
end

--[[
Returns the exact C4 shield-block rate before the source 0-99 roll.

The source multiplies final SHIELD_DEFENCE_RATE by the defender's DEX bonus.
A bow attacker then multiplies that result by 1.3. The source does not clamp
the resulting rate before comparing it with Rnd.get(100).

Args:
    shield_defence_rate (number): Final source shield-rate stat.
    dex_bonus (number): Authenticated source DEX bonus.
    attacker_is_bow (boolean): Whether the reviewed source weapon is a bow.

Returns:
    number: Exact source shield-block comparison rate.
]]
function C4CombatFormulaReference.shield_block_rate(
    shield_defence_rate: number,
    dex_bonus: number,
    attacker_is_bow: boolean
): number
    assert(
        type(shield_defence_rate) == "number"
            and shield_defence_rate == shield_defence_rate
            and shield_defence_rate >= 0
            and shield_defence_rate < math.huge,
        "Shield defence rate must be finite and nonnegative"
    )
    positive(dex_bonus, "DEX bonus")
    assert(
        type(attacker_is_bow) == "boolean",
        "Attacker bow state must be boolean"
    )

    local rate = shield_defence_rate * dex_bonus
    if attacker_is_bow then
        rate *= 1.3
    end
    return rate
end

--[[
Resolves the C4 shield-block comparison after facing eligibility is known.

The source exits before rolling when the shield rate is zero or the defender
is outside the source shield-facing angle. Rnd.get(100) yields 0 through 99,
and a block succeeds only when the effective rate is strictly greater.

Args:
    shield_defence_rate (number): Final source shield-rate stat.
    dex_bonus (number): Authenticated source DEX bonus.
    attacker_is_bow (boolean): Whether the source attacker weapon is a bow.
    facing_eligible (boolean): Server-resolved source-angle eligibility.
    roll (number): Server-owned integer roll from 0 through 99.

Returns:
    any: Detached source block result and comparison evidence.
]]
function C4CombatFormulaReference.resolve_shield_block(
    shield_defence_rate: number,
    dex_bonus: number,
    attacker_is_bow: boolean,
    facing_eligible: boolean,
    roll: number
): any
    assert(
        type(facing_eligible) == "boolean",
        "Shield facing eligibility must be boolean"
    )
    assert(
        type(roll) == "number"
            and roll % 1 == 0
            and roll >= 0
            and roll <= 99,
        "Shield roll must be an integer from 0 through 99"
    )

    local rate = C4CombatFormulaReference.shield_block_rate(
        shield_defence_rate,
        dex_bonus,
        attacker_is_bow
    )

    local blocked = shield_defence_rate > 0
        and facing_eligible
        and rate > roll

    return {
        EffectiveRate = rate,
        Roll = roll,
        FacingEligible = facing_eligible,
        Blocked = blocked,
    }
end

--[[
Resolves the pinned C4 perfect-shield roll used after a normal shield block.

The reviewed source checks:
(100 - AltPerfectShieldBlockRate) < Rnd.get(100)
with the default config value 5. Because the comparison is strict, rolls
96-99 succeed while 95 does not.

Args:
    roll (number): Server-owned integer roll from 0 through 99.

Returns:
    any: Exact perfect-shield result and source threshold evidence.
]]
function C4CombatFormulaReference.resolve_perfect_shield(
    roll: number
): any
    assert(
        type(roll) == "number"
            and roll % 1 == 0
            and roll >= 0
            and roll <= 99,
        "Perfect-shield roll must be an integer from 0 through 99"
    )

    local threshold = 100 - PERFECT_SHIELD_CONFIG_RATE
    return {
        ConfigRate = PERFECT_SHIELD_CONFIG_RATE,
        Threshold = threshold,
        Roll = roll,
        PerfectShield = threshold < roll,
    }
end

--[[
Returns the C4 unarmed random-damage percentage range.

The reviewed source uses 5 + (int) sqrt(level) when no active weapon exists.

Args:
    level (number): Positive integer attacker level.

Returns:
    number: Integer percentage range used for the source random roll.
]]
function C4CombatFormulaReference.unarmed_random_damage_range(
    level: number
): number
    assert(
        type(level) == "number"
            and level % 1 == 0
            and level >= 1,
        "Unarmed random-damage level must be a positive integer"
    )

    return 5 + math.floor(math.sqrt(level))
end

--[[
Returns one exact C4 physical random-damage multiplier.

The source rolls an inclusive integer from -random_damage through
+random_damage, then returns 1 + roll / 100.

Args:
    random_damage (number): Weapon or unarmed percentage range.
    roll (number): Server-owned integer roll inside that exact range.

Returns:
    number: Source multiplier applied after weapon vulnerability.
]]
function C4CombatFormulaReference.physical_random_damage_multiplier(
    random_damage: number,
    roll: number
): number
    assert(
        type(random_damage) == "number"
            and random_damage % 1 == 0
            and random_damage >= 0,
        "Random damage range must be a nonnegative integer"
    )
    assert(
        type(roll) == "number"
            and roll % 1 == 0
            and roll >= -random_damage
            and roll <= random_damage,
        "Random damage roll must be inside the source range"
    )

    return 1 + (roll / 100)
end

--[[
Returns the C4 normal physical critical chance in thousandths.

The reviewed source truncates the calculated PHYSICAL_CRITICAL_RATE to an
integer, then caps it at Config.MaxPCritRate=500 before calcCrit performs its
0-999 roll. Negative rates are equivalent to zero chance.

Args:
    critical_rate (number): Final source physical critical-rate stat.

Returns:
    number: Integer source critical chance from 0 through 500 per thousand.
]]
function C4CombatFormulaReference.physical_critical_rate_per_thousand(
    critical_rate: number
): number
    assert(
        type(critical_rate) == "number"
            and critical_rate == critical_rate
            and math.abs(critical_rate) < math.huge,
        "Physical critical rate must be finite"
    )

    local truncated = math.floor(critical_rate)
    return math.min(math.max(truncated, 0), 500)
end

--[[
Resolves one exact C4 normal physical critical roll.

The source uses calcCrit(rate), which returns true only when the capped source
rate is strictly greater than an integer random roll from 0 through 999. A
roll equal to the critical rate is therefore not a critical hit.

Args:
    critical_rate (number): Final source physical critical-rate stat.
    roll (number): Server-owned integer random roll from 0 through 999.

Returns:
    any: Detached critical result containing chance and roll evidence.
]]
function C4CombatFormulaReference.resolve_physical_critical(
    critical_rate: number,
    roll: number
): any
    assert(
        type(roll) == "number"
            and roll % 1 == 0
            and roll >= 0
            and roll <= 999,
        "Physical critical roll must be an integer from 0 through 999"
    )

    local chance =
        C4CombatFormulaReference.physical_critical_rate_per_thousand(
            critical_rate
        )
    local critical = chance > roll

    return {
        ChancePerThousand = chance,
        Roll = roll,
        Critical = critical,
    }
end

--[[
Returns the C4 pre-random magic success threshold.

Source success compares a 0-9999-like random value against this
rounded resistance threshold. This function avoids inventing a Roblox
status chance while preserving the exact level-difference arithmetic.

Args:
    target_level (number): Target character level.
    magic_level (number): Skill magic level, or attacker level fallback.

Returns:
    number: Rounded C4 resistance threshold.
]]
function C4CombatFormulaReference.magic_resist_threshold(
    target_level: number, magic_level: number
): number
    local difference = target_level - magic_level
    return math.floor((1.3 ^ difference) * 100 + 0.5)
end

--[[
Returns pinned source provenance for formula audits.

Args:
    None.

Returns:
    any: Pinned C4 source commit and formula/heal file URLs.
]]
function C4CombatFormulaReference.sources(): any
    return {
        SourceCommit = SOURCE_COMMIT,
        FormulasUrl = FORMULAS_URL,
        HealUrl = HEAL_URL,
        ConfigUrl = CONFIG_URL,
        CharacterUrl = CHARACTER_URL,
        RndUrl = RND_URL,
    }
end

return table.freeze(C4CombatFormulaReference)
