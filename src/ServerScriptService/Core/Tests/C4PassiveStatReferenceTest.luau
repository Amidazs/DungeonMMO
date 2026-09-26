--!strict
-- Original source stat modifiers, NOT live Roblox passive equivalence.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local C4 = require(Shared.C4PassiveStatReference)
local Source = require(Shared.C4SkillEffectSource)

local checks = 0

--[[
Tests one source stat formula using exact original C4 modifier units.

Args:
    condition (boolean): Deterministic passive formula contract.
    label (string): Precise C4 failure location.

Returns:
    nil: Raises on failure, otherwise counts the passed assertion.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Passive Reference] " .. label)
end

--[[
Creates independent naked stats in original C4 names and units.

Args:
    None.

Returns:
    any: Unmodified representative stat vector, not a game player.
]]
local function source_stats(): any
    return {
        PHYSICAL_ATTACK = 100, PHYSICAL_DEFENCE = 100,
        MAGICAL_ATTACK = 100, EVASION_RATE = 10,
    }
end

--[[
Checks original weapon-conditioned passive never leaks to wrong gear.

Args:
    None.

Returns:
    nil: Covers bow, dagger and heavy/light armor conditions.
]]
local function check_equipment_gates()
    local bow = assert(C4.apply(source_stats(), "Bow", {
        {SkillId = 208, Rank = 9},
        {SkillId = 209, Rank = 1},
    }))
    local source_bow = assert(Source.get_rank(208, 9))
    check(bow.AppliedModifiers == 1
        and bow.Stats.PHYSICAL_ATTACK ==
            100 + source_bow.Modifiers[1].val,
        "Bow mastery rank9 applies its exact original bow P.Atk")
    local dagger = assert(C4.apply(source_stats(), "Dagger", {
        {SkillId = 208, Rank = 9},
        {SkillId = 209, Rank = 1},
    }))
    check(dagger.Stats.PHYSICAL_ATTACK == 103.6
        and dagger.AppliedModifiers == 1,
        "Dagger cannot borrow Bow Mastery or another weapon's stats")
    local unarmed = assert(C4.apply(source_stats(), nil, {
        {SkillId = 208, Rank = 9},
        {SkillId = 209, Rank = 1},
    }))
    check(unarmed.Stats.PHYSICAL_ATTACK == 100
        and unarmed.AppliedModifiers == 0,
        "Naked original character receives no weapon-only mastery")
    local heavy = assert(C4.apply(source_stats(), "Heavy", {
        {SkillId = 232, Rank = 1},
        {SkillId = 233, Rank = 1},
    }))
    check(heavy.Stats.PHYSICAL_DEFENCE == 117.7
        and heavy.Stats.EVASION_RATE == 10,
        "Heavy armour grants only actual Knight P.Def, not Light evasion")
    local light = assert(C4.apply(source_stats(), "Light", {
        {SkillId = 232, Rank = 1},
        {SkillId = 233, Rank = 1},
    }))
    check(light.Stats.PHYSICAL_DEFENCE == 101.3
        and light.Stats.EVASION_RATE == 14,
        "Light armour grants source P.Def and flat evasion, not Heavy")
end

--[[
Verifies source operation order and fail-closed active-skill handling.

Args:
    None.

Returns:
    nil: Does not silently execute buffs as permanent passives.
]]
local function check_order_and_denials()
    local mage = assert(C4.apply(source_stats(), nil, {
        {SkillId = 249, Rank = 1},
    }))
    check(math.abs(mage.Stats.PHYSICAL_ATTACK - 146.5) < 0.00001
        and math.abs(mage.Stats.MAGICAL_ATTACK - 118.9) < 0.00001,
        "Original 0x30 multiply precedes 0x40 flat additive mastery")
    local _, active = C4.apply(source_stats(), nil, {
        {SkillId = 77, Rank = 1},
    })
    check(active == "ActiveOrToggleSkillRequiresSeparateExecutor",
        "An active attack aura cannot become an always-on passive")
    local _, duplicate = C4.apply(source_stats(), "Bow", {
        {SkillId = 208, Rank = 1}, {SkillId = 208, Rank = 9},
    })
    check(duplicate == "DuplicateSourcePassive",
        "Different ranks of same mastery must not stack together")
    local _, missing = C4.apply({PHYSICAL_DEFENCE = 100}, nil, {
        {SkillId = 249, Rank = 1},
    })
    check(missing == "MissingOrInvalidOriginalStat:PHYSICAL_ATTACK",
        "Unsupported incomplete stat inputs fail rather than guessing")
end

--[[
Runs pure C4 source arithmetic for all currently shared passive rules.

Args:
    None.

Returns:
    nil: Prints a focused source pass without claiming live integration.
]]
local function main()
    check_equipment_gates()
    check_order_and_denials()
    print(("[C4 Passive Reference] SOURCE_ONLY_PASS: %d assertions")
        :format(checks))
end

main()
