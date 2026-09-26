--!strict
-- Deterministic C4 Bleed/Poison source formula regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Status = require(
    ReplicatedStorage.Core.Shared.C4StatusEffectReference
)

local checks = 0

--[[
Counts one C4 status-source assertion.

Args:
    valid (boolean): Expected source-semantic result.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Status Effect] " .. label)
end

--[[
Runs exact periodic plans, success-roll boundaries and nonlethal tick checks.

Args:
    None.

Returns:
    nil: Prints deterministic C4 status-source evidence.
]]
local function main()
    local bleed = assert(Status.periodic_plan(96, 1))
    check(
        bleed.EffectType == "BLEED"
            and bleed.SaveVs == "CON"
            and bleed.VulnerabilityStat == "BLEED_VULN",
        "Bleed rank one keeps source effect identity and CON save"
    )
    check(
        bleed.EffectPower == 100
            and bleed.MagicLevel == 24
            and not bleed.IsMagic,
        "Bleed rank one keeps source land inputs"
    )
    check(
        bleed.TickDamage == 13
            and bleed.TickCount == 4
            and bleed.TickSeconds == 5
            and bleed.Nonlethal,
        "Bleed rank one keeps source 13 x 4 every five seconds"
    )

    local poison = assert(Status.periodic_plan(1168, 1))
    check(
        poison.EffectType == "POISON"
            and poison.SaveVs == "MEN"
            and poison.VulnerabilityStat == "POISON_VULN",
        "Poison rank one keeps source effect identity and MEN save"
    )
    check(
        poison.EffectPower == 70
            and poison.MagicLevel == 7
            and poison.IsMagic,
        "Poison rank one keeps source magical land inputs"
    )
    check(
        poison.TickDamage == 8
            and poison.TickCount == 10
            and poison.TickSeconds == 3
            and poison.Nonlethal,
        "Poison rank one keeps source 8 x 10 every three seconds"
    )

    local frost = assert(Status.movement_slow_plan(1184, 6))
    check(
        frost.SourceSkillId == 1184
            and frost.SourceRank == 6
            and frost.EffectType == "DEBUFF"
            and frost.SaveVs == "WIT"
            and frost.EffectPower == 60
            and frost.MagicLevel == 20
            and frost.IsMagic,
        "Ice Bolt rank six keeps exact WIT-resisted slow inputs"
    )
    check(
        frost.SpeedMultiplier == 0.7
            and math.abs(frost.SlowFraction - 0.3) <= 0.00001
            and frost.DurationSeconds == 120
            and frost.StackType == "RunSpeedDown"
            and frost.StackOrder == 0.7,
        "Ice Bolt rank six keeps exact 30 percent 120-second source slow"
    )

    local sleep = assert(Status.sleep_plan(1069, 6))
    check(
        sleep.SourceSkillId == 1069
            and sleep.SourceRank == 6
            and sleep.EffectType == "SLEEP"
            and sleep.SaveVs == "WIT"
            and sleep.EffectPower == 80
            and sleep.MagicLevel == 30
            and sleep.IsMagic,
        "Sleep rank six keeps exact WIT-resisted source inputs"
    )
    check(
        sleep.DurationSeconds == 30
            and sleep.BreaksOnDamage
            and sleep.StopsMovement
            and sleep.StopsAttacks
            and sleep.StopsCasting,
        "Sleep rank six keeps 30-second action lock and damage wake"
    )

    local fire_vulnerability = assert(
        Status.elemental_vulnerability_plan(1083, 2)
    )
    check(
        fire_vulnerability.SourceSkillId == 1083
            and fire_vulnerability.SourceRank == 2
            and fire_vulnerability.SaveVs == "WIT"
            and fire_vulnerability.EffectPower == 80
            and fire_vulnerability.MagicLevel == 30
            and fire_vulnerability.IsMagic,
        "Surrender to Fire rank two keeps exact WIT land inputs"
    )
    check(
        fire_vulnerability.VulnerabilityStat == "FIRE_VULN"
            and fire_vulnerability.VulnerabilityMultiplier == 1.25
            and fire_vulnerability.DurationSeconds == 15
            and fire_vulnerability.StackType == "FireAtr"
            and fire_vulnerability.StackOrder == 1.25,
        "Surrender to Fire keeps exact 25 percent 15-second vulnerability"
    )

    local attack_weakness = assert(
        Status.physical_attack_weakening_plan(1164, 4)
    )
    check(
        attack_weakness.SourceSkillId == 1164
            and attack_weakness.SourceRank == 4
            and attack_weakness.EffectType == "CONFUSION"
            and attack_weakness.SaveVs == "WIT"
            and attack_weakness.EffectPower == 80
            and attack_weakness.MagicLevel == 30
            and attack_weakness.IsMagic,
        "Curse Weakness rank four keeps exact WIT land inputs"
    )
    check(
        attack_weakness.PhysicalAttackMultiplier == 0.8
            and attack_weakness.PowerReductionFraction == 0.2
            and attack_weakness.DurationSeconds == 15
            and attack_weakness.StackType == "pAtkDown"
            and attack_weakness.StackOrder == 0.8,
        "Curse Weakness keeps exact 20 percent 15-second attack reduction"
    )

    local bleed_rate = assert(Status.effect_success_rate({
        Power = 100,
        TargetStatBonus = 1,
        TargetVulnerability = 1,
        IsMagic = false,
        AttackerLevel = 24,
        TargetLevel = 24,
        MagicLevel = 24,
    }))
    check(
        bleed_rate == 99,
        "equal-level Bleed reaches the source 99 percent cap"
    )

    local bleed_land = assert(Status.resolve_effect_success({
        Power = 100,
        TargetStatBonus = 1,
        TargetVulnerability = 1,
        IsMagic = false,
        AttackerLevel = 24,
        TargetLevel = 24,
        MagicLevel = 24,
    }, 98))
    check(
        bleed_land.Landed,
        "source effect roll below final rate lands"
    )

    local bleed_equal = assert(Status.resolve_effect_success({
        Power = 100,
        TargetStatBonus = 1,
        TargetVulnerability = 1,
        IsMagic = false,
        AttackerLevel = 24,
        TargetLevel = 24,
        MagicLevel = 24,
    }, 99))
    check(
        not bleed_equal.Landed,
        "source effect roll equal to final rate resists"
    )

    local poison_rate = assert(Status.effect_success_rate({
        Power = 70,
        TargetStatBonus = 1,
        TargetVulnerability = 1,
        IsMagic = true,
        AttackerMAtk = 100,
        TargetMDef = 100,
        AttackerLevel = 7,
        TargetLevel = 7,
        MagicLevel = 7,
    }))
    check(
        poison_rate == 72,
        "equal-stat poison preserves source magic and level arithmetic"
    )

    local spiritshot_rate = assert(Status.effect_success_rate({
        Power = 70,
        TargetStatBonus = 1,
        TargetVulnerability = 1,
        IsMagic = true,
        AttackerMAtk = 100,
        TargetMDef = 100,
        Spiritshot = true,
        AttackerLevel = 7,
        TargetLevel = 7,
        MagicLevel = 7,
    }))
    check(
        spiritshot_rate == 83,
        "Spiritshot uses the exact C4 effect-success adjustment"
    )

    local blessed_rate = assert(Status.effect_success_rate({
        Power = 70,
        TargetStatBonus = 1,
        TargetVulnerability = 1,
        IsMagic = true,
        AttackerMAtk = 100,
        TargetMDef = 100,
        BlessedSpiritshot = true,
        AttackerLevel = 7,
        TargetLevel = 7,
        MagicLevel = 7,
    }))
    check(
        blessed_rate == 88,
        "Blessed Spiritshot uses the exact C4 effect-success adjustment"
    )

    local capped_tick = assert(Status.nonlethal_tick(8, 13))
    check(
        capped_tick.AppliedDamage == 7
            and capped_tick.HealthAfter == 1,
        "periodic source damage can reduce HP only to one"
    )

    local one_hp_tick = assert(Status.nonlethal_tick(1, 13))
    check(
        one_hp_tick.AppliedDamage == 0
            and one_hp_tick.HealthAfter == 1,
        "periodic source damage never kills a one-HP target"
    )

    print((
        "[C4 Status Effect] SOURCE_STATUS_PASS: %d assertions "
            .. "bleed=13x4@5 poison=8x10@3 frost=0.7@120 "
            .. "sleep=30@damage_wake fire_vuln=1.25@15 "
            .. "patk=0.8@15 nonlethal=true"
    ):format(checks))
end

main()
