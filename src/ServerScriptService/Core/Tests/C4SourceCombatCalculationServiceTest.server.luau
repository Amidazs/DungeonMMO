--!strict
-- Authenticated source-only physical, magic and heal calculation regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared

local Formula = require(Shared.C4CombatFormulaReference)
local ProfileSchema = require(Shared.ProfileSchema)
local Combat = require(
    ServerScriptService.Core.Services.C4SourceCombatCalculationService
)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local FIGHTER_ID = 938181
local MAGE_ID = 938182
local TARGET_ID = 938183
local checks = 0

--[[
Returns an empty authoritative active-effect snapshot for test owners.

Args:
    user_id (number): Runtime owner requesting source boundary state.

Returns:
    any?: Empty source-active state for the three disposable test owners.
]]
local function empty_active_snapshot(user_id: number): any?
    if user_id ~= FIGHTER_ID
        and user_id ~= MAGE_ID
        and user_id ~= TARGET_ID
    then
        return nil
    end

    return {
        SourceRanks = {},
        UnresolvedEffects = {},
        ActiveCount = 0,
        ResolvedCount = 0,
        Ready = true,
        Authoritative = true,
    }
end

Runtime.set_c4_active_effect_snapshot_provider(
    empty_active_snapshot
)

--[[
Counts one source-combat provider assertion.

Args:
    valid (boolean): Expected calculation or fail-closed condition.
    label (string): Diagnostic description for a failed assertion.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Source Combat] " .. label)
end

--[[
Builds a complete source-ready starter character.

Args:
    user_id (number): Disposable runtime owner.
    class_id (string): Fighter or Mage starter class.

Returns:
    any: Profile-shaped level-30 original character.
]]
local function starter_character(
    user_id: number,
    class_id: string
): any
    local character = ProfileSchema
        .create_default(user_id).Characters.Slot1

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "Human",
        BaseClassId = class_id,
        ClassId = class_id,
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
    }

    return character
end

--[[
Stores one genuinely owned creative active skill rank.

Args:
    character (any): Mutable server-owned test character.
    skill_id (string): Creative skill identifier.
    rank (number): Purchased creative rank.

Returns:
    nil: Changes only the disposable progression fixture.
]]
local function own_skill(
    character: any,
    skill_id: string,
    rank: number
)
    character.Progression.Skills[skill_id] = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = rank,
        Proficiency = 0,
    }
end

--[[
Compares floating source formula outputs.

Args:
    actual (number): Provider result.
    expected (number): Direct pinned formula result.
    label (string): Diagnostic description.

Returns:
    nil: Adds one assertion and raises outside tolerance.
]]
local function check_close(
    actual: number,
    expected: number,
    label: string
)
    check(
        math.abs(actual - expected) <= 0.00001,
        label
    )
end

--[[
Seeds three authenticated source-ready starter characters.

Args:
    None.

Returns:
    nil: Installs disposable fighter, mage and target runtime snapshots.
]]
local function seed_characters()
    local fighter = starter_character(FIGHTER_ID, "Fighter")
    own_skill(fighter, "IronCleave", 1)

    local mage = starter_character(MAGE_ID, "Mage")
    own_skill(mage, "WindStrike", 1)
    own_skill(mage, "MageHeal", 1)

    Runtime.set_character(FIGHTER_ID, fighter)
    Runtime.set_character(MAGE_ID, mage)
    Runtime.set_character(
        TARGET_ID,
        starter_character(TARGET_ID, "Fighter")
    )
end

--[[
Checks provider default-off behaviour.

Args:
    None.

Returns:
    nil: Confirms source calculation requires explicit server enable.
]]
local function check_default_off()
    local capability = Combat.capability()
    check(
        not Combat.is_enabled()
            and capability.Available
            and capability.DefaultEnabled == false
            and capability.NormalAttackHitResolution
            and capability.NormalAttackHitRollServerOwned
            and not capability.NormalAttackHitConditionIntegrated
            and not capability.LiveDamageApplied,
        "source combat provider starts disabled and non-live"
    )

    local result, reason = Combat.physical_skill(
        FIGHTER_ID,
        TARGET_ID,
        "IronCleave",
        1
    )
    check(
        result == nil
            and reason == "C4SourceCombatCalculationDisabled",
        "disabled provider cannot calculate a source hit"
    )
end

--[[
Checks normal attack hit/miss uses final source Accuracy/Evasion.

The service owns the random roll. The test verifies the returned roll against
the exact source comparison instead of injecting or predicting randomness.

Args:
    None.

Returns:
    nil: Confirms the source chance and server-owned roll relationship.
]]
local function check_normal_attack_hit()
    local attacker = assert(
        Runtime.get_c4_resource_migration_boundary(FIGHTER_ID)
    )
    local defender = assert(
        Runtime.get_c4_resource_migration_boundary(TARGET_ID)
    )

    local result = assert(Combat.normal_attack_hit(
        FIGHTER_ID,
        TARGET_ID
    ))
    local expected_chance =
        Formula.hit_chance_with_condition(
            attacker.SourceStatCandidate.ACCURACY_COMBAT,
            defender.SourceStatCandidate.EVASION_RATE,
            1
        )

    check_close(
        result.ChancePerThousand,
        expected_chance,
        "normal attack hit chance uses final source Accuracy/Evasion"
    )
    check(
        result.Roll >= 0
            and result.Roll <= 999
            and result.Roll % 1 == 0
            and result.Hit
                == (result.ChancePerThousand >= result.Roll)
            and result.Miss ~= result.Hit
            and result.SourceConditionMultiplier == 1
            and not result.SourceConditionIntegrated
            and not result.LiveApplied,
        "normal attack roll is server-owned and source comparison is exact"
    )
end

--[[
Checks PDAM uses authenticated source P.Atk/P.Def and source skill power.

Args:
    None.

Returns:
    nil: Confirms exact Power Strike rank-one arithmetic.
]]
local function check_physical()
    local attacker = assert(
        Runtime.get_c4_resource_migration_boundary(FIGHTER_ID)
    )
    local defender = assert(
        Runtime.get_c4_resource_migration_boundary(TARGET_ID)
    )

    local result = assert(Combat.physical_skill(
        FIGHTER_ID,
        TARGET_ID,
        "IronCleave",
        1
    ))
    local expected = Formula.physical_damage({
        PAtk = attacker.SourceStatCandidate.PHYSICAL_ATTACK,
        PDef = defender.SourceStatCandidate.PHYSICAL_DEFENCE,
        SkillPower = 25,
    })

    check_close(
        result.Amount,
        expected,
        "Power Strike source damage equals pinned formula"
    )
    check(
        result.SourceSkillId == 3
            and result.SourceRank == 1
            and result.SourceSkillPower == 25
            and result.Kind == "PhysicalDamage"
            and not result.LiveApplied,
        "physical provider retains exact source identity without applying HP"
    )
end

--[[
Checks MDAM uses authenticated source M.Atk/M.Def and source power.

Args:
    None.

Returns:
    nil: Confirms exact Wind Strike rank-one arithmetic.
]]
local function check_magic()
    local attacker = assert(
        Runtime.get_c4_resource_migration_boundary(MAGE_ID)
    )
    local defender = assert(
        Runtime.get_c4_resource_migration_boundary(TARGET_ID)
    )

    local result = assert(Combat.magic_skill(
        MAGE_ID,
        TARGET_ID,
        "WindStrike",
        1
    ))
    local expected = Formula.magic_damage({
        MAtk = attacker.SourceStatCandidate.MAGICAL_ATTACK,
        MDef = defender.SourceStatCandidate.MAGICAL_DEFENCE,
        SkillPower = 12,
    })

    check_close(
        result.Amount,
        expected,
        "Wind Strike source damage equals pinned formula"
    )
    check(
        result.SourceSkillId == 1177
            and result.SourceRank == 1
            and result.SourceSkillPower == 12
            and result.Kind == "MagicDamage",
        "magic provider resolves exact source Wind Strike rank"
    )
end

--[[
Checks HEAL uses direct source EffectHeal power, not M.Atk.

Args:
    None.

Returns:
    nil: Confirms Self Heal rank-one source amount.
]]
local function check_heal()
    local result = assert(Combat.heal_skill(
        MAGE_ID,
        "MageHeal",
        1
    ))

    check(
        result.Amount == 42
            and result.SourceSkillId == 1216
            and result.SourceRank == 1
            and result.SourceHealPower == 42
            and result.Kind == "Heal",
        "source Self Heal applies direct reviewed power 42"
    )
end

--[[
Checks wrong skill families and unowned ranks fail closed.

Args:
    None.

Returns:
    nil: Prevents source formulas from accepting arbitrary skill semantics.
]]
local function check_denials()
    local wrong, wrong_reason = Combat.magic_skill(
        FIGHTER_ID,
        TARGET_ID,
        "IronCleave",
        1
    )
    check(
        wrong == nil
            and wrong_reason == "UnsupportedOriginalMagicSkillType",
        "PDAM cannot enter the MDAM source formula"
    )

    local unowned, unowned_reason = Combat.physical_skill(
        FIGHTER_ID,
        TARGET_ID,
        "IronCleave",
        2
    )
    check(
        unowned == nil
            and unowned_reason == "CreativeActiveSkillRankNotOwned",
        "unowned source skill rank cannot be calculated"
    )
end

--[[
Runs authenticated source combat calculation acceptance.

Args:
    None.

Returns:
    nil: Prints a bounded source-only success marker.
]]
local function main()
    seed_characters()
    check_default_off()

    Combat.set_enabled(true)
    check_normal_attack_hit()
    check_physical()
    check_magic()
    check_heal()
    check_denials()
    Combat.set_enabled(false)

    Runtime.clear_character(FIGHTER_ID)
    Runtime.clear_character(MAGE_ID)
    Runtime.clear_character(TARGET_ID)

    print((
        "[C4 Source Combat] SOURCE_ONLY_PASS: %d assertions "
        .. "hit=true pdam=true mdam=true heal=true live=false"
    ):format(checks))
end

main()
