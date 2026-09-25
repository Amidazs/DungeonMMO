--!strict
-- Deterministic source arithmetic for C4 combat; no live combat mutation.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Derived = require(Shared.C4DerivedStatReference)
local Formula = require(Shared.C4CombatFormulaReference)

local checks = 0
local EPSILON = 0.00001

--[[
Counts one pure C4 formula assertion.

Args:
    valid (boolean): Expected deterministic source result.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Combat Formula] " .. label)
end

--[[
Checks a floating formula output within source arithmetic tolerance.

Args:
    actual (number): C4 calculation output.
    expected (number): Independently calculated value.
    label (string): Formula vector description.

Returns:
    nil: Raises if source transcription differs.
]]
local function check_close(
    actual: number, expected: number, label: string
)
    check(math.abs(actual - expected) <= EPSILON, label)
end

--[[
Runs source physical, magical, heal, timing and hit-chance vectors.

Args:
    None.

Returns:
    nil: Prints formula-only result, not gameplay parity.
]]
local function main()
    local warrior = assert(Derived.get_naked_combat(
        "Human", "Ironvow", 30, true
    ))
    local knight = assert(Derived.get_naked_combat(
        "Human", "Oathguard", 30, true
    ))
    check_close(Formula.physical_damage({
        PAtk = warrior.NakedPAtk,
        PDef = knight.NakedPDef,
        SkillPower = 90,
    }), 70, "Power Smash-style naked no-shot source formula")
    check_close(Formula.physical_damage({
        PAtk = warrior.NakedPAtk,
        PDef = knight.NakedPDef,
        SkillPower = 90,
        Soulshot = true,
    }), 140, "Soulshot doubles physical formula attack before defence")
    check_close(Formula.physical_damage({
        PAtk = 100, PDef = 100,
        SkillPower = 0, Critical = true,
    }), 140, "Default C4 physical critical doubles normal ratio")
    check(Formula.physical_damage({
        PAtk = 100, PDef = 100,
        Shield = true, PerfectShield = true,
    }) == 1, "Perfect shield source branch returns one damage")

    local human_mage = assert(Derived.get_naked_combat(
        "Human", "Mage", 30, true
    ))
    local human_fighter = assert(Derived.get_naked_combat(
        "Human", "Fighter", 30, true
    ))
    local magic = Formula.magic_damage({
        MAtk = human_mage.NakedMAtk,
        MDef = human_fighter.NakedMDef,
        SkillPower = 12,
    })
    check_close(
        magic,
        ((91 * math.sqrt(12)) / 62) * 12,
        "Wind Strike-style source magic formula"
    )
    check_close(Formula.magic_damage({
        MAtk = 100, MDef = 100, SkillPower = 50,
        BlessedSpiritshot = true, MagicCritical = true,
    }), ((91 * math.sqrt(400)) / 100) * 50 * 4,
        "Blessed shot modifies MAtk before x4 magic critical")
    check(Formula.magic_damage({
        MAtk = 100, MDef = 100,
        SkillPower = 50, Failure = "Resisted",
    }) == 1, "Fully resisted source magic damage becomes one")

    check(Formula.heal_amount(95, false, false) == 95,
        "C4 Elemental Heal power is direct reviewed heal effect")
    check_close(Formula.heal_amount(95, true, false), 123.5,
        "Spiritshot increases source heal effect by 30 percent")
    check_close(Formula.heal_amount(95, false, true), 142.5,
        "Blessed Spiritshot increases source heal by 50 percent")

    check(
        Formula.unarmed_random_damage_range(30) == 10,
        "Level-30 unarmed source variance range is ten percent"
    )
    check_close(
        Formula.physical_random_damage_multiplier(10, -10),
        0.90,
        "Source minimum random physical multiplier is exact"
    )
    check_close(
        Formula.physical_random_damage_multiplier(10, 0),
        1,
        "Source zero random physical roll is neutral"
    )
    check_close(
        Formula.physical_random_damage_multiplier(10, 10),
        1.10,
        "Source maximum random physical multiplier is exact"
    )

    check(Formula.physical_attack_delay(330) == 1424,
        "C4 330 PAtkSpd maps to source attack delay")
    check(Formula.skill_cast_time(1000, 333) == 1000,
        "C4 base cast speed keeps authored 1000ms cast")
    check(Formula.skill_cast_time(1000, 386) == 862,
        "Elven Mystic cast speed shortens source cast time")

    check(Formula.hit_chance_per_thousand(60, 60) == 905,
        "Equal accuracy/evasion uses 90.5 percent source chance")
    check(Formula.hit_chance_per_thousand(70, 60) == 980,
        "Source hit chance upper cap is 98 percent")
    check(Formula.hit_chance_per_thousand(30, 60) == 275,
        "Source hit chance lower cap is 27.5 percent")
    check_close(
        Formula.hit_chance_with_condition(60, 60, 1.05),
        950.25,
        "Source side-style condition multiplier applies before final cap"
    )
    check(
        Formula.hit_chance_with_condition(60, 60, 1.10) == 980,
        "Source condition bonus still obeys 98 percent final cap"
    )

    local equal_roll = Formula.resolve_normal_attack_hit(
        60,
        60,
        1,
        905
    )
    check(
        equal_roll.Hit and not equal_roll.Miss,
        "Source roll equal to hit chance still lands"
    )

    local miss_roll = Formula.resolve_normal_attack_hit(
        60,
        60,
        1,
        906
    )
    check(
        miss_roll.Miss and not miss_roll.Hit,
        "Source roll above hit chance misses"
    )

    check(
        Formula.physical_critical_rate_per_thousand(650) == 500,
        "Source physical critical rate obeys the 50 percent cap"
    )
    check(
        Formula.physical_critical_rate_per_thousand(99.9) == 99,
        "Source physical critical rate truncates like Java int cast"
    )

    local critical_roll = Formula.resolve_physical_critical(
        100,
        99
    )
    check(
        critical_roll.Critical
            and critical_roll.ChancePerThousand == 100,
        "Source critical roll below rate succeeds"
    )

    local equal_critical_roll = Formula.resolve_physical_critical(
        100,
        100
    )
    check(
        not equal_critical_roll.Critical,
        "Source critical roll equal to rate does not crit"
    )

    check_close(
        Formula.shield_block_rate(20, 1.1, false),
        22,
        "Source shield rate multiplies by defender DEX bonus"
    )
    check_close(
        Formula.shield_block_rate(20, 1.1, true),
        28.6,
        "Bow attacker multiplies source shield rate by 1.3"
    )

    local shield_block = Formula.resolve_shield_block(
        20,
        1,
        false,
        true,
        19
    )
    check(
        shield_block.Blocked
            and shield_block.EffectiveRate == 20,
        "Source shield roll below effective rate blocks"
    )

    local equal_shield_roll = Formula.resolve_shield_block(
        20,
        1,
        false,
        true,
        20
    )
    check(
        not equal_shield_roll.Blocked,
        "Source shield roll equal to effective rate does not block"
    )

    local wrong_facing = Formula.resolve_shield_block(
        20,
        1,
        false,
        false,
        0
    )
    check(
        not wrong_facing.Blocked,
        "Source shield cannot block outside the facing angle"
    )

    check(
        not Formula.resolve_perfect_shield(95).PerfectShield,
        "Perfect shield strict threshold rejects roll 95"
    )
    check(
        Formula.resolve_perfect_shield(96).PerfectShield,
        "Perfect shield strict threshold accepts roll 96"
    )

    check(Formula.magic_resist_threshold(30, 30) == 100,
        "Equal magic/target level source resistance threshold")
    check(Formula.magic_resist_threshold(31, 30) == 130,
        "One level higher target uses x1.3 source threshold")

    print(("[C4 Combat Formula] SOURCE_FORMULA_PASS: %d assertions, "
        .. "live=false"):format(checks))
end

main()
