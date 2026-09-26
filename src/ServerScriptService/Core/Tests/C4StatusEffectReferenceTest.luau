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
            .. "bleed=13x4@5 poison=8x10@3 nonlethal=true"
    ):format(checks))
end

main()
