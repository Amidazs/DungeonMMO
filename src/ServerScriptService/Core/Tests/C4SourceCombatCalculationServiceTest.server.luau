--!strict
-- FOCUSED_EDIT_ONLY_SINGLETON_TEST
local RunService = game:GetService("RunService")

if RunService:IsRunning() then
    print(
        "[C4 Source Combat] SKIP: singleton regression runs in focused Edit mode"
    )
    return
end
-- Authenticated source-only physical, magic and heal calculation regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared

local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Formula = require(Shared.C4CombatFormulaReference)
local NpcSource = require(Shared.C4NpcSourceReference)
local ProfileSchema = require(Shared.ProfileSchema)
local QuestStages = require(Shared.C4OriginalFirstTransferQuestStages)
local Combat = require(
    ServerScriptService.Core.Services.C4SourceCombatCalculationService
)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local FIGHTER_ID = 938181
local MAGE_ID = 938182
local WIZARD_ID = 938186
local TARGET_ID = 938183
local SHIELD_TARGET_ID = 938184
local BOW_ATTACKER_ID = 938185
local checks = 0

local FRONT_CONTEXT = {
    AttackerPosition = Vector3.new(0, 0, -10),
    DefenderCFrame = CFrame.new(0, 0, 0),
    HeightDeltaSourceUnits = 0,
    IsNight = false,
}

local BACK_CONTEXT = {
    AttackerPosition = Vector3.new(0, 0, 10),
    DefenderCFrame = CFrame.new(0, 0, 0),
    HeightDeltaSourceUnits = 0,
    IsNight = false,
}

local shot_state = {
    Soulshot = false,
    Spiritshot = false,
    BlessedSpiritshot = false,
}

local ShotAuthority = {}

--[[
Consumes the disposable physical shot state for provider integration tests.

Args:
    user_id (number): Ignored authenticated fixture owner.

Returns:
    any: One-use Soulshot state.
]]
function ShotAuthority:consume_physical(user_id: number): any
    local charged = shot_state.Soulshot
    shot_state.Soulshot = false
    return {
        Soulshot = charged,
    }
end

--[[
Consumes the disposable magical shot state with Blessed priority.

Args:
    user_id (number): Ignored authenticated fixture owner.

Returns:
    any: One-use Spiritshot/Blessed Spiritshot state.
]]
function ShotAuthority:consume_magic(user_id: number): any
    if shot_state.BlessedSpiritshot then
        shot_state.BlessedSpiritshot = false
        return {
            Spiritshot = false,
            BlessedSpiritshot = true,
        }
    end

    local charged = shot_state.Spiritshot
    shot_state.Spiritshot = false
    return {
        Spiritshot = charged,
        BlessedSpiritshot = false,
    }
end

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
        and user_id ~= WIZARD_ID
        and user_id ~= TARGET_ID
        and user_id ~= SHIELD_TARGET_ID
        and user_id ~= BOW_ATTACKER_ID
    then
        return nil
    end

    if user_id == TARGET_ID then
        return {
            SourceRanks = {
                {
                    SkillId = 112,
                    Rank = 1,
                },
            },
            UnresolvedEffects = {},
            ActiveCount = 1,
            ResolvedCount = 1,
            Ready = true,
            Authoritative = true,
        }
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
Combat.set_shot_authority(ShotAuthority)

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
    local career = Careers.for_class(class_id)
    local base_class = if career then career.BaseClassId else class_id

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "Human",
        BaseClassId = base_class,
        ClassId = class_id,
        CreationStage = "Complete",
    }

    if not career then
        character.ClassAdvancement = {
            Version = 1,
        }
        return character
    end

    local stage = assert(QuestStages.get(career.BranchId))
    local proofs = {}

    for _, proof_id in ipairs(stage.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.ClassAdvancement = {
        Version = 1,
        OriginalFirstTransferChoiceId = career.BranchId,
        OriginalFirstTransferClassId = career.Id,
        OriginalFirstTransferReceiptId =
            "TEMP_C4SourceCombatMentor",
        OriginalFirstTransferQuest = {
            QuestId = stage.Id,
            BranchId = career.BranchId,
            Step = #stage.Steps + 1,
            Count = 0,
            Ready = true,
            AppliedEvents = {},
            Proofs = proofs,
        },
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
Seeds authenticated source-ready starter and transfer characters.

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
    own_skill(mage, "MysticPoisonCurse", 1)

    local wizard = starter_character(WIZARD_ID, "Emberweaver")
    own_skill(wizard, "EmberweaverEmberBolt", 6)

    Runtime.set_character(FIGHTER_ID, fighter)
    Runtime.set_character(MAGE_ID, mage)
    Runtime.set_character(WIZARD_ID, wizard)
    Runtime.set_character(
        TARGET_ID,
        starter_character(TARGET_ID, "Oathguard")
    )

    local shield_target =
        starter_character(SHIELD_TARGET_ID, "Fighter")
    shield_target.Equipment.OffHand = "marauder_shield"
    Runtime.set_character(
        SHIELD_TARGET_ID,
        shield_target
    )

    local bow_attacker =
        starter_character(BOW_ATTACKER_ID, "Fighter")
    bow_attacker.Equipment.Weapon = "apprentice_longbow"
    Runtime.set_character(
        BOW_ATTACKER_ID,
        bow_attacker
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
            and capability.NormalAttackHitConditionIntegrated
            and capability.SpatialConditionInputServerOwned
            and capability.NormalAttackPhysicalCriticalResolution
            and capability.NormalAttackPhysicalCriticalRollServerOwned
            and capability.NormalAttackCriticalPowerIntegrated
            and capability.PhysicalRandomVarianceResolution
            and capability.RandomWeaponVarianceIntegrated
            and capability.UnarmedRandomVarianceIntegrated
            and capability.ShieldSourceResolutionAvailable
            and capability.ShieldRollServerOwned
            and capability.ShieldPhysicalFormulaIntegrated
            and capability.ShieldFacingRuntimeIntegrated
            and capability.ShieldResolutionIntegrated
            and capability.NormalAttackDamageComposition
            and capability.WeaponVulnerabilityIntegrated
            and capability.PvpFormulaModifiersIntegrated
            and capability.PlayerTargetPvpModifiersIntegrated
            and capability.CriticalResolutionIntegrated
            and capability.PhysicalSkillCriticalIntegrated
            and capability.PhysicalSkillCriticalRollServerOwned
            and capability.MagicCriticalIntegrated
            and capability.MagicCriticalRollServerOwned
            and capability.MagicFailureFormulaAvailable
            and capability.MagicFailureResolutionIntegrated
            and not capability.MagicFailuresSourceDefaultEnabled
            and capability.ElementalResolutionIntegrated
            and capability.ElementalPlayerTargetSourceStatsIntegrated
            and capability.ElementalNpcTargetSourceStatsIntegrated
            and capability.NpcTargetSourceBoundaryIntegrated
            and capability.NpcTargetPvpNeutralityIntegrated
            and capability.NpcRacePhysicalModifiersIntegrated
            and capability.ShotsIntegrated
            and capability.ShotAuthorityInstalled
            and capability.PhysicalSoulshotIntegrated
            and capability.MagicSpiritshotIntegrated
            and capability.HealSpiritshotIntegrated
            and capability.PeriodicStatusCalculation
            and capability.PeriodicStatusEffectSuccessIntegrated
            and capability.PeriodicStatusNonlethalSemanticsIntegrated
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
        TARGET_ID,
        FRONT_CONTEXT
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
            and result.SourceConditionIntegrated
            and result.SourcePositionRelation == "Front"
            and result.SourceElevationRelation == "Level"
            and not result.SourceNight
            and not result.LiveApplied,
        "normal attack roll is server-owned and source comparison is exact"
    )
end

--[[
Checks ordinary physical critical chance and power use final source stats.

The provider owns the random roll. The test checks the returned roll against
the exact source strict-greater-than comparison and confirms neutral C4
critical-power calculator bases are present in the authenticated candidate.

Args:
    None.

Returns:
    nil: Confirms source critical rate, roll and critical-power inputs.
]]
local function check_normal_attack_critical()
    local attacker = assert(
        Runtime.get_c4_resource_migration_boundary(FIGHTER_ID)
    )
    local result = assert(Combat.normal_attack_critical(
        FIGHTER_ID,
        TARGET_ID
    ))
    local expected_chance =
        Formula.physical_critical_rate_per_thousand(
            attacker.SourceStatCandidate.CRITICAL_RATE
        )

    check(
        result.ChancePerThousand == expected_chance
            and result.Roll >= 0
            and result.Roll <= 999
            and result.Roll % 1 == 0
            and result.Critical
                == (result.ChancePerThousand > result.Roll),
        "normal physical critical roll matches exact source comparison"
    )
    check(
        result.CriticalPowerMultiplier == 1
            and result.CriticalPowerAdd == 0
            and result.TargetSourceReady
            and not result.TargetSpecificCriticalModifiersIntegrated
            and not result.LiveApplied,
        "normal critical exposes authenticated source power inputs only"
    )
end

--[[
Checks server-owned C4 physical random variance for the unarmed fixture.

The source-ready starter has no reviewed weapon equipped, so level 30 uses
5 + floor(sqrt(30)) = 10 as the inclusive percentage range.

Args:
    None.

Returns:
    nil: Confirms exact range, private roll and source multiplier.
]]
local function check_physical_random_variance()
    local result = assert(Combat.physical_random_variance(
        FIGHTER_ID
    ))

    check(
        result.RandomDamage == 10
            and result.Roll >= -10
            and result.Roll <= 10
            and result.Roll % 1 == 0
            and result.Unarmed
            and result.SourceWeaponId == nil,
        "unarmed level-30 variance uses exact source range"
    )
    check_close(
        result.Multiplier,
        1 + (result.Roll / 100),
        "server-owned random variance roll maps to source multiplier"
    )
end

--[[
Checks one complete ordinary C4 attack against a source bow vulnerability.

Misses preserve the charged physical shot exactly like the reviewed source.
The bounded retry avoids assuming a private random roll while still verifying
the successful composition path.

Args:
    None.

Returns:
    nil: Confirms hit/crit/variance/vulnerability/PvP/shot composition.
]]
local function check_normal_attack_composition()
    local attacker = assert(
        Runtime.get_c4_resource_migration_boundary(BOW_ATTACKER_ID)
    )
    local defender = assert(
        Runtime.get_c4_resource_migration_boundary(TARGET_ID)
    )

    check_close(
        defender.SourceStatCandidate.BOW_WPN_VULN,
        0.84,
        "authoritative Deflect Arrow exposes source bow vulnerability"
    )

    shot_state.Soulshot = true
    local result = nil
    local miss_preserved_charge = true

    for _ = 1, 100 do
        result = assert(Combat.normal_attack(
            BOW_ATTACKER_ID,
            TARGET_ID,
            FRONT_CONTEXT
        ))

        if result.Hit then
            break
        end

        miss_preserved_charge =
            miss_preserved_charge and shot_state.Soulshot
    end

    check(
        result ~= nil and result.Hit,
        "bounded source normal attack eventually produced a hit"
    )
    check(
        miss_preserved_charge and not shot_state.Soulshot,
        "misses preserve Soulshot and successful hit consumes it once"
    )

    local resolved = assert(result)
    local expected = Formula.physical_damage({
        PAtk = attacker.SourceStatCandidate.PHYSICAL_ATTACK,
        PDef = defender.SourceStatCandidate.PHYSICAL_DEFENCE,
        Soulshot = resolved.Soulshot,
        Critical = resolved.Critical,
        CriticalPowerMultiplier =
            resolved.CriticalPowerMultiplier,
        CriticalPowerAdd = resolved.CriticalPowerAdd,
        WeaponVulnerabilityMultiplier =
            resolved.WeaponVulnerabilityMultiplier,
        RandomDamageMultiplier =
            resolved.RandomDamageMultiplier,
        PvpMultiplier = resolved.PvpMultiplier,
    })

    check_close(
        resolved.Amount,
        expected,
        "normal attack composes exact source physical formula inputs"
    )
    check(
        resolved.SourceWeaponId == 13
            and resolved.WeaponKind == "Bow"
            and resolved.WeaponVulnerabilityStat
                == "BOW_WPN_VULN"
            and math.abs(
                resolved.WeaponVulnerabilityMultiplier - 0.84
            ) <= 0.00001
            and resolved.PvpStat == "PVP_PHYSICAL_DMG"
            and resolved.PvpMultiplier == 1
            and resolved.Soulshot
            and resolved.SoulshotConsumed
            and not resolved.LiveApplied,
        "normal attack exposes source vulnerability/PvP/shot evidence"
    )
end

--[[
Checks source shield rate, facing, perfect roll and PDAM formula wiring.

The shield-facing boolean is supplied only by this server-side test call. The
future live executor still has to derive it from authoritative world transforms.

Args:
    None.

Returns:
    nil: Confirms reviewed shield stats and physical formula integration.
]]
local function check_shield_resolution()
    local defender = assert(
        Runtime.get_c4_resource_migration_boundary(
            SHIELD_TARGET_ID
        )
    )

    local wrong_facing = assert(Combat.shield_resolution(
        FIGHTER_ID,
        SHIELD_TARGET_ID,
        BACK_CONTEXT
    ))
    check(
        wrong_facing.ShieldEquipped
            and wrong_facing.ShieldDefenceRate == 20
            and wrong_facing.ShieldDefencePower == 79
            and wrong_facing.ShieldAngleDegrees == 120
            and not wrong_facing.Blocked
            and not wrong_facing.PerfectShield,
        "reviewed source shield cannot block outside server-owned facing"
    )

    local facing = assert(Combat.shield_resolution(
        FIGHTER_ID,
        SHIELD_TARGET_ID,
        FRONT_CONTEXT
    ))
    check(
        facing.Blocked
            == (facing.EffectiveRate > facing.BlockRoll),
        "server-owned shield roll uses exact strict source comparison"
    )
    check(
        if facing.Blocked
            then facing.PerfectShield
                == (facing.PerfectRoll > 95)
            else facing.PerfectRoll == nil
                and not facing.PerfectShield,
        "perfect shield rolls only after a successful source block"
    )

    local missing, missing_reason = Combat.physical_skill(
        FIGHTER_ID,
        SHIELD_TARGET_ID,
        "IronCleave",
        1
    )
    check(
        missing == nil
            and missing_reason == "SourceSpatialContextRequired",
        "shielded PDAM refuses to invent facing state"
    )

    local result = assert(Combat.physical_skill(
        FIGHTER_ID,
        SHIELD_TARGET_ID,
        "IronCleave",
        1,
        FRONT_CONTEXT
    ))
    local attacker = assert(
        Runtime.get_c4_resource_migration_boundary(FIGHTER_ID)
    )
    local expected = Formula.physical_damage({
        PAtk = attacker.SourceStatCandidate.PHYSICAL_ATTACK,
        PDef = defender.SourceStatCandidate.PHYSICAL_DEFENCE,
        SkillPower = 25,
        Shield = result.ShieldBlocked,
        PerfectShield = result.PerfectShield,
        ShieldDefense = result.ShieldDefencePower,
        WeaponVulnerabilityMultiplier =
            result.WeaponVulnerabilityMultiplier,
        RandomDamageMultiplier = result.RandomDamageMultiplier,
        PvpMultiplier = result.PvpMultiplier,
    })

    check_close(
        result.Amount,
        expected,
        "PDAM consumes the exact source shield result"
    )
    check(
        result.ShieldEquipped
            and result.ShieldDefencePower == 79
            and result.ShieldFacingEligible == true,
        "PDAM exposes reviewed shield evidence without live application"
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

    shot_state.Soulshot = true
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
        Soulshot = result.Soulshot,
        WeaponVulnerabilityMultiplier =
            result.WeaponVulnerabilityMultiplier,
        RandomDamageMultiplier = result.RandomDamageMultiplier,
        PvpMultiplier = result.PvpMultiplier,
    })
    if result.PhysicalSkillCritical then
        expected *= 2
    end

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
            and result.Soulshot
            and result.RandomDamage == 10
            and result.RandomDamageRoll >= -10
            and result.RandomDamageRoll <= 10
            and result.Unarmed
            and result.SourceWeaponId == nil
            and result.WeaponVulnerabilityMultiplier == 1
            and result.PvpStat == "PVP_PHYS_SKILL_DMG"
            and result.PvpMultiplier == 1
            and result.SourceSkillBaseCriticalRate == 0
            and result.PhysicalSkillCriticalChancePerThousand == 0
            and result.PhysicalSkillCriticalRoll == nil
            and not result.PhysicalSkillCritical
            and type(result.SourceStrBonus) == "number"
            and result.SourceStrBonus > 0
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

    shot_state.BlessedSpiritshot = true
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
        Spiritshot = result.Spiritshot,
        BlessedSpiritshot = result.BlessedSpiritshot,
        Failure = result.MagicFailure,
        MagicCritical = result.MagicCritical,
        ElementalMultiplier = result.ElementalMultiplier,
        PvpMultiplier = result.PvpMultiplier,
    })

    check_close(
        result.Amount,
        expected,
        "Wind Strike source damage equals pinned formula"
    )
    check(
        attacker.SourceStatCandidate.MAGICAL_CRITICAL_RATE == 8
            and result.SourceMagicalCriticalRate == 8
            and result.MagicCriticalChancePerThousand == 8
            and result.MagicCriticalRoll >= 0
            and result.MagicCriticalRoll <= 999
            and result.MagicCriticalRoll % 1 == 0
            and result.MagicCritical
                == (result.MagicCriticalChancePerThousand
                    > result.MagicCriticalRoll),
        "magic provider uses source base M.Crit and server-owned roll"
    )
    check(
        result.MagicLevel == 1
            and not result.MagicFailureEnabled
            and result.MagicFailure == "None"
            and result.MagicFailureFirstRoll == nil
            and result.MagicFailureSecondRoll == nil
            and result.MagicFailureThreshold
                == Formula.magic_resist_threshold(30, 1),
        "pinned source default keeps optional magic failures disabled"
    )
    check(
        defender.SourceStatCandidate.WIND_VULN == 1
            and result.SourceElement == "WIND"
            and result.ElementalMultiplier == 1
            and result.BlessedSpiritshot
            and not result.Spiritshot
            and result.PvpStat == "PVP_MAGICAL_DMG"
            and result.PvpMultiplier == 1,
        "Wind Strike uses authenticated target WIND vulnerability"
    )
    check(
        result.SourceSkillId == 1177
            and result.SourceRank == 1
            and result.SourceSkillPower == 12
            and result.Kind == "MagicDamage"
            and not result.LiveApplied,
        "magic provider resolves exact source Wind Strike rank"
    )
end

--[[
Checks Human Wizard direct magic uses the exact mapped C4 rank and class stats.

Args:
    None.

Returns:
    nil: Confirms Emberweaver rank-six Ember Bolt resolves Blaze rank six.
]]
local function check_human_wizard_magic()
    local attacker = assert(
        Runtime.get_c4_resource_migration_boundary(WIZARD_ID)
    )
    local defender = assert(
        Runtime.get_c4_resource_migration_boundary(TARGET_ID)
    )

    shot_state.Spiritshot = true
    local result = assert(Combat.magic_skill(
        WIZARD_ID,
        TARGET_ID,
        "EmberweaverEmberBolt",
        6
    ))
    local expected = Formula.magic_damage({
        MAtk = attacker.SourceStatCandidate.MAGICAL_ATTACK,
        MDef = defender.SourceStatCandidate.MAGICAL_DEFENCE,
        SkillPower = 38,
        Spiritshot = result.Spiritshot,
        BlessedSpiritshot = result.BlessedSpiritshot,
        Failure = result.MagicFailure,
        MagicCritical = result.MagicCritical,
        ElementalMultiplier = result.ElementalMultiplier,
        PvpMultiplier = result.PvpMultiplier,
    })

    check_close(
        result.Amount,
        expected,
        "Human Wizard Blaze rank six uses exact source magic formula"
    )
    check(
        result.SourceSkillId == 1220
            and result.SourceRank == 6
            and result.SourceSkillPower == 38
            and result.MagicLevel == 30
            and result.SourceElement == "FIRE"
            and result.Spiritshot
            and not result.BlessedSpiritshot
            and result.Kind == "MagicDamage"
            and not result.LiveApplied,
        "Emberweaver Ember Bolt resolves exact Human Wizard source rank"
    )
    check(
        attacker.ScopeId == "HumanWizard"
            and attacker.SourceBaseMaxMana == 492
            and attacker.SourceStatCandidate.MAGICAL_ATTACK > 0
            and attacker.SourceStatCandidate.MAGICAL_CRITICAL_RATE >= 0,
        "Human Wizard direct spell uses its own source class candidate"
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
    shot_state.Spiritshot = true
    local result = assert(Combat.heal_skill(
        MAGE_ID,
        "MageHeal",
        1
    ))

    check_close(
        result.Amount,
        42 * 1.3,
        "source Self Heal applies ordinary Spiritshot x1.3"
    )
    check(
        result.Spiritshot
            and not result.BlessedSpiritshot
            and result.SourceSkillId == 1216
            and result.SourceRank == 1
            and result.SourceHealPower == 42
            and result.Kind == "Heal",
        "source heal consumes authenticated one-use magical charge"
    )
end

--[[
Checks player source formulas against reviewed server NPC boundaries.

Args:
    None.

Returns:
    nil: Confirms NPC hit, PDAM, MDAM, race and PvP semantics.
]]
local function check_npc_targets()
    local marauder = assert(NpcSource.get("Marauder"))
    local wolf = assert(NpcSource.get("Wolf"))
    local fighter = assert(
        Runtime.get_c4_resource_migration_boundary(FIGHTER_ID)
    )
    local mage = assert(
        Runtime.get_c4_resource_migration_boundary(MAGE_ID)
    )

    local hit = assert(Combat.normal_attack_hit(
        FIGHTER_ID,
        marauder,
        FRONT_CONTEXT
    ))
    local expected_hit = Formula.hit_chance_with_condition(
        fighter.SourceStatCandidate.ACCURACY_COMBAT,
        marauder.SourceStatCandidate.EVASION_RATE,
        1
    )
    check(
        hit.TargetKind == "Npc"
            and hit.SourceNpcId == 325
            and hit.SourceNpcRace == "NONE"
            and hit.SourceEvasion == 38
            and hit.ChancePerThousand == expected_hit,
        "normal hit resolution accepts reviewed NPC target stats"
    )

    shot_state.Soulshot = false
    local normal = nil

    for _ = 1, 100 do
        normal = assert(Combat.normal_attack(
            FIGHTER_ID,
            marauder,
            FRONT_CONTEXT
        ))
        if normal.Hit then
            break
        end
    end

    check(
        normal ~= nil
            and normal.Hit
            and normal.TargetKind == "Npc"
            and normal.SourceNpcId == 325
            and normal.SourceNpcRace == "NONE"
            and normal.NpcRaceMultiplier == 1
            and #normal.NpcRaceStats == 0
            and normal.PvpMultiplier == 1
            and not normal.PvpApplied,
        "ordinary player-to-NPC attack uses neutral NONE race and no PvP"
    )

    local resolved_normal = assert(normal)
    local expected_normal = Formula.physical_damage({
        PAtk = fighter.SourceStatCandidate.PHYSICAL_ATTACK,
        PDef = marauder.SourceStatCandidate.PHYSICAL_DEFENCE,
        Soulshot = resolved_normal.Soulshot,
        Critical = resolved_normal.Critical,
        CriticalPowerMultiplier =
            resolved_normal.CriticalPowerMultiplier,
        CriticalPowerAdd = resolved_normal.CriticalPowerAdd,
        WeaponVulnerabilityMultiplier =
            resolved_normal.WeaponVulnerabilityMultiplier,
        RandomDamageMultiplier =
            resolved_normal.RandomDamageMultiplier,
        RaceMultiplier = resolved_normal.NpcRaceMultiplier,
        PvpMultiplier = 1,
    })
    check_close(
        resolved_normal.Amount,
        expected_normal,
        "ordinary player-to-NPC damage equals exact source formula"
    )

    shot_state.Soulshot = false
    local physical = assert(Combat.physical_skill(
        FIGHTER_ID,
        wolf,
        "IronCleave",
        1
    ))
    local expected_physical = Formula.physical_damage({
        PAtk = fighter.SourceStatCandidate.PHYSICAL_ATTACK,
        PDef = wolf.SourceStatCandidate.PHYSICAL_DEFENCE,
        SkillPower = 25,
        Soulshot = physical.Soulshot,
        WeaponVulnerabilityMultiplier =
            physical.WeaponVulnerabilityMultiplier,
        RandomDamageMultiplier =
            physical.RandomDamageMultiplier,
        RaceMultiplier = physical.NpcRaceMultiplier,
        PvpMultiplier = 1,
    })
    if physical.PhysicalSkillCritical then
        expected_physical *= 2
    end

    check_close(
        physical.Amount,
        expected_physical,
        "player-to-Wolf PDAM equals exact source formula"
    )
    check(
        physical.TargetKind == "Npc"
            and physical.SourceNpcId == 525
            and physical.SourceNpcRace == "ANIMAL"
            and physical.NpcRaceMultiplier
                == fighter.SourceStatCandidate.PHYSICAL_ATK_ANIMALS
            and #physical.NpcRaceStats == 1
            and physical.NpcRaceStats[1]
                == "PHYSICAL_ATK_ANIMALS"
            and physical.PvpMultiplier == 1
            and not physical.PvpApplied,
        "Wolf PDAM uses C4 ANIMAL modifier and suppresses PvP multiplier"
    )

    shot_state.BlessedSpiritshot = false
    shot_state.Spiritshot = false
    local magic = assert(Combat.magic_skill(
        MAGE_ID,
        wolf,
        "WindStrike",
        1
    ))
    local expected_magic = Formula.magic_damage({
        MAtk = mage.SourceStatCandidate.MAGICAL_ATTACK,
        MDef = wolf.SourceStatCandidate.MAGICAL_DEFENCE,
        SkillPower = 12,
        Spiritshot = magic.Spiritshot,
        BlessedSpiritshot = magic.BlessedSpiritshot,
        Failure = magic.MagicFailure,
        MagicCritical = magic.MagicCritical,
        ElementalMultiplier = magic.ElementalMultiplier,
        PvpMultiplier = 1,
    })

    check_close(
        magic.Amount,
        expected_magic,
        "player-to-Wolf MDAM equals exact source formula"
    )
    check(
        magic.TargetKind == "Npc"
            and magic.SourceNpcId == 525
            and magic.SourceNpcRace == "ANIMAL"
            and magic.ElementalMultiplier == 1
            and magic.PvpMultiplier == 1
            and not magic.PvpApplied,
        "NPC MDAM uses source target defence/vulnerability without PvP"
    )

    shot_state.Spiritshot = false
    shot_state.BlessedSpiritshot = false
    local poison = assert(Combat.status_skill(
        MAGE_ID,
        marauder,
        "MysticPoisonCurse",
        1
    ))
    check(
        poison.Kind == "PeriodicStatus"
            and poison.TargetKind == "Npc"
            and poison.SourceNpcId == 325
            and poison.SourceSkillId == 1168
            and poison.SourceRank == 1
            and poison.EffectType == "POISON"
            and poison.SaveVs == "MEN"
            and poison.TickDamage == 8
            and poison.TickCount == 10
            and poison.TickSeconds == 3
            and poison.Nonlethal,
        "player-to-NPC poison resolves exact reviewed source periodic plan"
    )
    check(
        poison.Roll >= 0
            and poison.Roll <= 99
            and poison.Roll % 1 == 0
            and poison.Landed == (poison.Roll < poison.Rate)
            and not poison.Spiritshot
            and not poison.BlessedSpiritshot
            and not poison.LiveApplied,
        "poison effect-success roll is private server source state"
    )

    local malformed = table.clone(marauder)
    malformed.SourceCommit = "wrong"
    local denied, denied_reason = Combat.normal_attack_hit(
        FIGHTER_ID,
        malformed,
        FRONT_CONTEXT
    )
    check(
        denied == nil
            and denied_reason == "InvalidC4NpcSourceBoundary",
        "forged NPC boundary provenance fails closed"
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
    check_normal_attack_critical()
    check_physical_random_variance()
    check_normal_attack_composition()
    check_shield_resolution()
    check_physical()
    check_magic()
    check_human_wizard_magic()
    check_heal()
    check_npc_targets()
    check_denials()
    Combat.set_enabled(false)
    Combat.set_shot_authority(nil)

    Runtime.clear_character(FIGHTER_ID)
    Runtime.clear_character(MAGE_ID)
    Runtime.clear_character(WIZARD_ID)
    Runtime.clear_character(TARGET_ID)
    Runtime.clear_character(SHIELD_TARGET_ID)
    Runtime.clear_character(BOW_ATTACKER_ID)

    print((
        "[C4 Source Combat] SOURCE_ONLY_PASS: %d assertions "
        .. "hit=true critical=true variance=true shield=true "
        .. "normal=true vuln=true pvp=true pdamcrit=true "
        .. "magiccrit=true magicfailure=true element=true shots=true "
        .. "status=true pdam=true mdam=true wizard=true "
        .. "heal=true npc=true live=false"
    ):format(checks))
end

main()
