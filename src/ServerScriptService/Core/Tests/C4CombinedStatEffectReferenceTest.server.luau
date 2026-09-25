--!strict
-- C4 shared calculator ordering for passives, timed buffs and toggles.

local Shared = game:GetService("ReplicatedStorage").Core.Shared

local Combined = require(Shared.C4CombinedStatEffectReference)
local Unified = require(Shared.C4UnifiedStatReference)

local checks = 0

--[[
Counts one combined source-effect assertion.

Args:
    valid (boolean): Expected exact source-order or stack condition.
    label (string): Diagnostic description for a failed assertion.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Combined Effects] " .. label)
end

--[[
Builds a compact source-stat dictionary for ordering tests.

Args:
    None.

Returns:
    any: Numerical source stat inputs with all tested base fields.
]]
local function base_stats(): any
    return {
        PHYSICAL_ATTACK = 100,
        PHYSICAL_DEFENCE = 100,
        MAGICAL_DEFENCE = 80,
        ACCURACY_COMBAT = 20,
        EVASION_RATE = 15,
        RUN_SPEED = 120,
        MAX_HP = 1000,
        MAX_MP = 500,
        MAX_CP = 400,
    }
end

--[[
Checks passive and active operations share one global C4 order.

Args:
    None.

Returns:
    nil: Confirms active 0x30 runs before passive 0x40.
]]
local function check_shared_order()
    local result = assert(Combined.apply(
        base_stats(),
        {},
        {
            {SkillId = 141, Rank = 3},
        },
        {
            {SkillId = 78, Rank = 1},
        }
    ))

    check(
        math.abs(result.Stats.PHYSICAL_ATTACK - 134.2) < 0.0001,
        "War Cry 0x30 runs before Weapon Mastery 0x40 add"
    )
    check(
        result.AppliedModifiers == 3,
        "one passive family and one active buff contribute three functions"
    )
end

--[[
Checks C4 named stack groups select only the strongest active effect.

Args:
    None.

Returns:
    nil: Confirms weaker pAtk stack member does not also multiply stats.
]]
local function check_stack_group()
    local result = assert(Combined.apply(
        base_stats(),
        {},
        {},
        {
            {SkillId = 77, Rank = 2},
            {SkillId = 1068, Rank = 1},
        }
    ))

    check(
        math.abs(result.Stats.PHYSICAL_ATTACK - 112) < 0.0001,
        "Attack Aura rank 2 wins pAtk stack over Might rank 1"
    )
    check(
        #result.SelectedActiveEffects == 1
            and result.SelectedActiveEffects[1].StackType == "pAtk"
            and result.SelectedActiveEffects[1].StackOrder == 1.12,
        "source stack winner retains exact pAtk stack metadata"
    )
end

--[[
Checks active add, subtract and neutral-base source statistics.

Args:
    None.

Returns:
    nil: Confirms Majesty, Accuracy, Vicious Stance and Deflect Arrow.
]]
local function check_active_operations()
    local result = assert(Combined.apply(
        base_stats(),
        {},
        {},
        {
            {SkillId = 82, Rank = 1},
            {SkillId = 256, Rank = 1},
            {SkillId = 312, Rank = 3},
            {SkillId = 112, Rank = 1},
        }
    ))

    check(
        math.abs(result.Stats.PHYSICAL_DEFENCE - 107) < 0.0001
            and result.Stats.EVASION_RATE == 13,
        "Majesty applies 0x30 P.Def then 0x40 Evasion penalty"
    )
    check(
        result.Stats.ACCURACY_COMBAT == 23,
        "Accuracy toggle applies exact +3 source Accuracy"
    )
    check(
        result.Stats.PHYSICAL_CRITICAL_POWER_ADD == 64,
        "Vicious Stance rank 3 uses exact flat critical-power source stat"
    )
    check(
        math.abs(result.Stats.BOW_WPN_VULN - 0.84) < 0.0001,
        "Deflect Arrow starts from neutral bow vulnerability one"
    )
end

--[[
Checks timed source effects modify resources and additive defences exactly.

Args:
    None.

Returns:
    nil: Confirms Battle Roar and Ultimate Defence source operations.
]]
local function check_resource_and_defence_effects()
    local result = assert(Combined.apply(
        base_stats(),
        {},
        {},
        {
            {SkillId = 121, Rank = 1},
            {SkillId = 110, Rank = 1},
        }
    ))

    check(
        math.abs(result.Stats.MAX_HP - 1100) < 0.0001,
        "Battle Roar rank 1 applies exact +10 percent max HP"
    )
    check(
        result.Stats.PHYSICAL_DEFENCE == 1900
            and result.Stats.MAGICAL_DEFENCE == 1430,
        "Ultimate Defence rank 1 adds exact 1800/1350 P.Def/M.Def"
    )
end

--[[
Checks the unified item/passive/effect source calculator preserves ordering.

Args:
    None.

Returns:
    nil: Confirms item, passive and active stages compose without live claims.
]]
local function check_unified_effect_snapshot()
    local result = assert(Unified.get_with_source_effects(
        "Human",
        "Ironvow",
        28,
        {
            Weapon = 291,
            Body = 352,
            Gloves = 63,
        },
        {},
        {
            {SkillId = 121, Rank = 1},
            {SkillId = 256, Rank = 1},
            {SkillId = 312, Rank = 3},
        }
    ))

    check(
        result.ActiveEffectOrderingIntegrated
            and not result.ActiveEffectStateAuthoritative
            and not result.LiveCombatIntegrated,
        "unified source ordering does not claim live active-state authority"
    )
    check(
        result.EquippedStats.MAX_HP > result.Naked.MaxHP
            and result.EquippedStats.ACCURACY_COMBAT
                == result.Naked.Accuracy - 3 + 3,
        "Battle Roar and Accuracy compose on reviewed source gear"
    )
end

--[[
Checks invalid mixed snapshots fail closed.

Args:
    None.

Returns:
    nil: Confirms duplicate active skills and passive misuse are rejected.
]]
local function check_denials()
    local _, duplicate = Combined.apply(
        base_stats(),
        {},
        {},
        {
            {SkillId = 78, Rank = 1},
            {SkillId = 78, Rank = 1},
        }
    )
    check(
        duplicate == "DuplicateOrInvalidActiveSourceSkill",
        "same active source skill cannot be stacked twice"
    )

    local _, passive_as_active = Combined.apply(
        base_stats(),
        {},
        {},
        {
            {SkillId = 141, Rank = 1},
        }
    )
    check(
        passive_as_active == "PassiveRankInActiveSnapshot",
        "passive rank cannot enter the active-effect snapshot"
    )
end

--[[
Runs combined passive/active source-order acceptance.

Args:
    None.

Returns:
    nil: Prints a bounded source-only success marker.
]]
local function main()
    check_shared_order()
    check_stack_group()
    check_active_operations()
    check_resource_and_defence_effects()
    check_unified_effect_snapshot()
    check_denials()

    print((
        "[C4 Combined Effects] SOURCE_ONLY_PASS: %d assertions "
        .. "shared_order=true stack_groups=true live=false"
    ):format(checks))
end

main()
