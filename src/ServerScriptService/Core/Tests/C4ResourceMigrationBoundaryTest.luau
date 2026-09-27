--!strict
-- Authenticated C4 resource cutover boundary regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared

local Careers = require(Shared.OriginalFirstTransferDefinitions)
local ProfileSchema = require(Shared.ProfileSchema)
local QuestStages = require(Shared.C4OriginalFirstTransferQuestStages)
local Boundary = require(Shared.C4ResourceMigrationBoundary)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)
local CombatPoints = require(
    ServerScriptService.Core.Services.C4CombatPointRuntime
)

local TEST_OWNER = 938176
local checks = 0
local active_snapshot: any = {
    SourceRanks = {},
    UnresolvedEffects = {},
    ActiveCount = 0,
    ResolvedCount = 0,
    Ready = true,
    Authoritative = true,
}

--[[
Returns deterministic active source state for this disposable test owner.

Args:
    user_id (number): Runtime owner requesting the migration boundary.

Returns:
    any?: Current test snapshot for TEST_OWNER, otherwise nil.
]]
local function active_snapshot_for_test(user_id: number): any?
    if user_id ~= TEST_OWNER then
        return nil
    end

    return active_snapshot
end

Runtime.set_c4_active_effect_snapshot_provider(
    active_snapshot_for_test
)

--[[
Counts one fail-closed resource-boundary assertion.

Args:
    valid (boolean): Expected source boundary or rejection condition.
    label (string): Diagnostic description for unexpected behavior.

Returns:
    nil: Increments the assertion count or raises on failure.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Resource Boundary] " .. label)
end

--[[
Builds a complete original starter or first-transfer test character.

Args:
    race_id (string): Human or Elf original race.
    class_id (string): Starter or first-transfer creative class ID.
    level (number): Original character level through 30.

Returns:
    any: Profile-shaped authoritative test character.
]]
local function original_character(
    race_id: string,
    class_id: string,
    level: number
): any
    local character = ProfileSchema
        .create_default(TEST_OWNER).Characters.Slot1
    local career = Careers.for_class(class_id)
    local base_class = if career then career.BaseClassId else class_id

    character.Level = level
    character.Identity = {
        Version = 1,
        RaceId = race_id,
        BaseClassId = base_class,
        ClassId = class_id,
        CreationStage = "Complete",
    }

    if career then
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
                "TEMP_C4ResourceBoundaryMentor",
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
    end

    return character
end

--[[
Stores one genuinely owned creative skill rank in a test character.

Args:
    character (any): Mutable server-owned character fixture.
    skill_id (string): Creative skill identifier.
    rank (number): Purchased creative rank.

Returns:
    nil: Mutates only the disposable progression state.
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
Checks exact level-30 source HP/MP/CP for every supported original path.

Args:
    None.

Returns:
    nil: Confirms exact source vitals while live cutover stays blocked.
]]
local function check_reviewed_paths()
    local vectors = {
        {"Human", "Fighter", 922, 319, 418},
        {"Human", "Mage", 699, 466, 366},
        {"Elf", "Fighter", 792, 324, 353},
        {"Elf", "Mage", 666, 469, 348},
        {"Human", "Ironvow", 1070, 320, 849},
        {"Human", "Oathguard", 1018, 320, 610},
        {"Human", "Ashenblade", 983, 320, 399},
        {"Human", "Emberweaver", 705, 492, 355},
        {"Human", "Dawnkeeper", 770, 492, 387},
        {"Elf", "Moonweaver", 682, 495, 343},
        {"Elf", "Lifebinder", 744, 495, 374},
        {"Elf", "GreenwardWarden", 902, 325, 453},
        {"Elf", "GreenwardScout", 874, 325, 354},
        {"DarkElf", "Duskguard", 856, 325, 430},
        {"DarkElf", "Veilblade", 831, 325, 337},
        {"DarkElf", "Nightweaver", 672, 482, 338},
        {"DarkElf", "Duskseer", 732, 482, 368},
    }

    for _, row in ipairs(vectors) do
        Runtime.set_character(
            TEST_OWNER,
            original_character(row[1], row[2], 30)
        )

        local plan, reason =
            Runtime.get_c4_resource_migration_boundary(TEST_OWNER)

        check(
            plan ~= nil and reason == nil,
            row[2] .. " authentic source boundary exists"
        )
        check(
            plan.SourceBaseMaxHealth == row[3]
                and plan.SourceBaseMaxMana == row[4]
                and plan.SourceBaseMaxCP == row[5],
            row[2] .. " exact source base HP/MP/CP"
        )
        check(
            plan.ExactBaseVitalsCertified
                and type(plan.SourceWitBonus) == "number"
                and plan.SourceWitBonus > 0
                and not plan.CanApplyLive
                and not plan.LiveHealthIntegrated
                and not plan.LiveManaIntegrated
                and not plan.LiveCPIntegrated,
            row[2] .. " exact source values remain fail-closed"
        )
        check(
            #plan.ActivationBlockers == 0
                and plan.OriginalOwnedPassiveMappingIntegrated
                and plan.ActiveEffectsIntegrated
                and plan.CombinedSourceStatCandidateReady
                and plan.SourceStatCandidateIncludesActiveEffects
                and plan.CombatPointRuntimeAuthoritative
                and plan.CombatPointRuntimeReady
                and plan.CutoverPrerequisitesReady,
            row[2] .. " has all source cutover prerequisites ready"
        )

        Runtime.clear_character(TEST_OWNER)
    end
end

--[[
Checks the complete current six-slot paperdoll and C4 Expertise boundary.

Args:
    None.

Returns:
    nil: Confirms source-ready gear remains separate from live cutover.
]]
local function check_reviewed_equipment_boundary()
    local character = original_character("Human", "Oathguard", 30)
    character.Equipment = {
        Weapon = "marauder_sword",
        OffHand = "marauder_shield",
        Helmet = "marauder_helmet",
        Body = "stonewatch_d_grade_armor",
        Gloves = "tempered_ironbound_gloves",
        Boots = "marauder_boots",
    }
    Runtime.set_character(TEST_OWNER, character)

    local reviewed = assert(
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)
    )
    check(
        reviewed.ReviewedSixSlotLoadoutReady
            and reviewed.ReviewedSourceItemIds.Weapon == 1
            and reviewed.ReviewedSourceItemIds.OffHand == 102
            and reviewed.ReviewedSourceItemIds.Head == 43
            and reviewed.ReviewedSourceItemIds.Body == 352
            and reviewed.ReviewedSourceItemIds.Legs == 2378
            and reviewed.ReviewedSourceItemIds.Gloves == 63
            and reviewed.ReviewedSourceItemIds.Feet == 38,
        "reviewed six-slot gear exposes exact source chest and hidden legs IDs"
    )
    check(
        reviewed.OriginalEquipmentExpertiseReady
            and reviewed.OriginalBodyLegSemanticsReady
            and reviewed.OriginalInventoryIntegrated
            and reviewed.OriginalOwnedPassiveMappingIntegrated
            and reviewed.SourceStatCandidateReady
            and not reviewed.CanApplyLive
            and reviewed.ActiveEffectsIntegrated
            and reviewed.CombinedSourceStatCandidateReady
            and reviewed.CombatPointRuntimeReady
            and reviewed.CutoverPrerequisitesReady
            and #reviewed.ActivationBlockers == 0,
        "level-30 six-slot inventory migration is source-ready"
    )

    local early = original_character("Human", "Fighter", 19)
    early.Equipment = {
        Body = "stonewatch_d_grade_armor",
    }
    Runtime.set_character(TEST_OWNER, early)
    local blocked = assert(
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)
    )
    check(
        blocked.ReviewedSixSlotLoadoutReady
            and blocked.OriginalBodyLegSemanticsReady
            and not blocked.OriginalEquipmentExpertiseReady
            and not blocked.OriginalInventoryIntegrated
            and blocked.OriginalEquipmentExpertiseReason
                == "OriginalEquipmentGradeExpertiseRequired"
            and blocked.OriginalOwnedPassiveMappingIntegrated
            and blocked.ActiveEffectsIntegrated
            and blocked.CombatPointRuntimeReady
            and not blocked.CutoverPrerequisitesReady
            and #blocked.ActivationBlockers == 1,
        "level-19 D-grade equipment keeps migration fail-closed"
    )

    Runtime.clear_character(TEST_OWNER)
end
--[[
Checks Human Wizard Quick Recovery enters the authenticated stat candidate.

Args:
    None.

Returns:
    nil: Confirms owned rank two produces exact magical reuse multiplier.
]]
local function check_human_wizard_reuse_boundary()
    active_snapshot = {
        SourceRanks = {},
        UnresolvedEffects = {},
        ActiveCount = 0,
        ResolvedCount = 0,
        Ready = true,
        Authoritative = true,
    }

    local character = original_character(
        "Human",
        "Emberweaver",
        30
    )
    character.Progression.Skills.EmberweaverQuickWeave = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = 2,
        Proficiency = 0,
    }
    Runtime.set_character(TEST_OWNER, character)

    local plan = assert(
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)
    )
    check(
        plan.SourceStatCandidateReady
            and plan.OriginalOwnedPassiveMappingIntegrated
            and plan.SourceStatCandidate.MAGICAL_SKILL_REUSE == 0.75
            and plan.SourceStatCandidate.SKILL_MASTERY == 0
            and plan.CutoverPrerequisitesReady
            and #plan.ActivationBlockers == 0,
        "owned Quick Recovery rank two reaches final source stat candidate"
    )

    Runtime.clear_character(TEST_OWNER)
end

--[[
Checks all eight Nightweaver passives reach the authenticated stat candidate.

Args:
    None.

Returns:
    nil: Confirms owned Dark Wizard passives survive the runtime boundary.
]]
local function check_nightweaver_passive_boundary()
    active_snapshot = {
        SourceRanks = {},
        UnresolvedEffects = {},
        ActiveCount = 0,
        ResolvedCount = 0,
        Ready = true,
        Authoritative = true,
    }

    local character = original_character(
        "DarkElf",
        "Nightweaver",
        30
    )
    own_skill(character, "NightweaverArcaneResistance", 6)
    own_skill(character, "NightweaverQuickWeave", 2)
    own_skill(character, "NightweaverManaReservoir", 2)
    own_skill(character, "NightweaverRobeTraining", 6)
    own_skill(character, "NightweaverFocusTraining", 5)
    own_skill(character, "NightweaverManaChanneling", 6)
    own_skill(character, "NightweaverFastCasting", 1)
    own_skill(character, "NightweaverManaRecovery", 1)
    Runtime.set_character(TEST_OWNER, character)

    local plan = assert(
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)
    )
    local stats = assert(plan.SourceStatCandidate)

    check(
        plan.ScopeId == "DarkWizard"
            and plan.OwnedPassiveSourceMappingReady
            and plan.OriginalOwnedPassiveMappingIntegrated
            and #plan.ReviewedOwnedSourcePassiveRanks == 8
            and plan.PassiveSourceStatCandidateReady
            and plan.CutoverPrerequisitesReady
            and #plan.ActivationBlockers == 0,
        "all eight Nightweaver passives cross the source boundary"
    )
    check(
        stats.MAGICAL_DEFENCE == 100
            and stats.MAGICAL_SKILL_REUSE == 0.75
            and stats.MAX_MP == 532
            and stats.RECHARGE_MP_RATE == 33
            and math.abs(
                stats.MAGICAL_ATTACK_SPEED - 331.8
            ) < 0.000001
            and math.abs(
                stats.REG_MP_RATE - 3.68825
            ) < 0.000001,
        "Nightweaver boundary preserves exact passive stat values"
    )

    Runtime.clear_character(TEST_OWNER)
end

--[[
Checks all eight Duskseer passives reach the authenticated stat candidate.

Args:
    None.

Returns:
    nil: Confirms owned Shillien Oracle passives survive the runtime boundary.
]]
local function check_duskseer_passive_boundary()
    active_snapshot = {
        SourceRanks = {},
        UnresolvedEffects = {},
        ActiveCount = 0,
        ResolvedCount = 0,
        Ready = true,
        Authoritative = true,
    }

    local character = original_character(
        "DarkElf",
        "Duskseer",
        30
    )
    own_skill(character, "DuskseerArcaneResistance", 6)
    own_skill(character, "DuskseerQuickPrayer", 2)
    own_skill(character, "DuskseerManaReservoir", 2)
    own_skill(character, "DuskseerFastCasting", 1)
    own_skill(character, "DuskseerManaRecovery", 1)
    own_skill(character, "DuskseerRobeTraining", 6)
    own_skill(character, "DuskseerLightArmorTraining", 6)
    own_skill(character, "DuskseerWeaponTraining", 5)
    Runtime.set_character(TEST_OWNER, character)

    local plan = assert(
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)
    )
    local stats = assert(plan.SourceStatCandidate)

    check(
        plan.ScopeId == "ShillienOracle"
            and plan.SourceBaseMaxHealth == 732
            and plan.SourceBaseMaxMana == 482
            and plan.SourceBaseMaxCP == 368
            and plan.OwnedPassiveSourceMappingReady
            and plan.OriginalOwnedPassiveMappingIntegrated
            and #plan.ReviewedOwnedSourcePassiveRanks == 8
            and plan.PassiveSourceStatCandidateReady
            and plan.CutoverPrerequisitesReady
            and #plan.ActivationBlockers == 0,
        "all eight Duskseer passives cross the source boundary"
    )
    check(
        stats.MAGICAL_DEFENCE == 100
            and stats.MAGICAL_SKILL_REUSE == 0.75
            and stats.MAX_MP == 532
            and stats.RECHARGE_MP_RATE == 1
            and math.abs(
                stats.MAGICAL_ATTACK_SPEED - 331.8
            ) < 0.000001
            and math.abs(
                stats.REG_MP_RATE - 3.68825
            ) < 0.000001,
        "Duskseer boundary preserves exact passive stat values"
    )

    Runtime.clear_character(TEST_OWNER)
end

--[[
Checks Duskseer Empower and Blood Rite enter the authenticated active state.

Args:
    None.

Returns:
    nil: Confirms unique class-42 active modifiers survive resource cutover.
]]
local function check_duskseer_active_buff_boundary()
    active_snapshot = {
        SourceRanks = {
            {SkillId = 1059, Rank = 1},
            {SkillId = 1268, Rank = 1},
        },
        UnresolvedEffects = {},
        ActiveCount = 2,
        ResolvedCount = 2,
        Ready = true,
        Authoritative = true,
    }

    local character = original_character(
        "DarkElf",
        "Duskseer",
        30
    )
    own_skill(character, "DuskseerQuickPrayer", 2)
    Runtime.set_character(TEST_OWNER, character)

    local plan = assert(
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)
    )
    local stats = assert(plan.SourceStatCandidate)

    check(
        plan.ScopeId == "ShillienOracle"
            and plan.ActiveEffectsIntegrated
            and plan.SourceStatCandidateIncludesActiveEffects
            and #plan.ReviewedActiveSourceRanks == 2
            and plan.CutoverPrerequisitesReady
            and #plan.ActivationBlockers == 0,
        "Duskseer unique active buffs cross the resource boundary"
    )
    check(
        stats.ABSORB_DAMAGE_PERCENT == 6
            and stats.MAGICAL_ATTACK > 0
            and plan.ReviewedActiveSourceRanks[1].SkillId == 1059
            and plan.ReviewedActiveSourceRanks[2].SkillId == 1268,
        "Duskseer Empower and Blood Rite reach authenticated source stats"
    )

    Runtime.clear_character(TEST_OWNER)
end

--[[
Checks active Concentration reaches the dynamic attack-cancel source offset.

Args:
    None.

Returns:
    nil: Confirms the authoritative active rank enters combined source stats.
]]
local function check_concentration_interrupt_boundary()
    active_snapshot = {
        SourceRanks = {
            {SkillId = 1078, Rank = 2},
        },
        UnresolvedEffects = {},
        ActiveCount = 1,
        ResolvedCount = 1,
        Ready = true,
        Authoritative = true,
    }

    local character = original_character(
        "DarkElf",
        "Nightweaver",
        30
    )
    own_skill(character, "NightweaverQuickWeave", 2)
    Runtime.set_character(TEST_OWNER, character)

    local plan = assert(
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)
    )
    check(
        plan.ActiveEffectsIntegrated
            and plan.SourceStatCandidateIncludesActiveEffects
            and plan.SourceMenBonus == 1.45
            and plan.SourceStatCandidate.ATTACK_CANCEL_RATE == -25
            and plan.ReviewedActiveSourceRanks[1].SkillId == 1078
            and plan.ReviewedActiveSourceRanks[1].Rank == 2
            and plan.CutoverPrerequisitesReady,
        "Concentration rank two supplies exact live interruption offset"
    )

    Runtime.clear_character(TEST_OWNER)
end

--[[
Checks unsupported actually-owned custom passives keep C4 cutover blocked.

Args:
    None.

Returns:
    nil: Confirms source mapping never silently stacks a custom passive.
]]
local function check_owned_passive_boundary()
    local character = original_character("Human", "Mage", 15)
    character.Progression.Skills.MysticRobeCasting = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = 1,
        Proficiency = 0,
    }
    Runtime.set_character(TEST_OWNER, character)

    local plan = assert(
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)
    )
    check(
        not plan.OwnedPassiveSourceMappingReady
            and not plan.OriginalOwnedPassiveMappingIntegrated
            and not plan.SourceStatCandidateReady
            and plan.UnsupportedOwnedCreativePassives[1]
                == "MysticRobeCasting"
            and plan.ActiveEffectsIntegrated
            and plan.CombatPointRuntimeReady
            and not plan.CutoverPrerequisitesReady
            and #plan.ActivationBlockers == 1,
        "unmapped owned combat passive adds the passive migration blocker"
    )

    Runtime.clear_character(TEST_OWNER)
end

--[[
Checks authoritative active source effects enter the final stat candidate.

Args:
    None.

Returns:
    nil: Confirms resolved effects compose and unresolved/forged rows block.
]]
local function check_active_effect_boundary()
    local character = original_character(
        "Human",
        "Oathguard",
        30
    )
    Runtime.set_character(TEST_OWNER, character)

    active_snapshot = {
        SourceRanks = {
            {SkillId = 82, Rank = 1},
        },
        UnresolvedEffects = {},
        ActiveCount = 1,
        ResolvedCount = 1,
        Ready = true,
        Authoritative = true,
    }

    local active_plan = assert(
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)
    )
    check(
        active_plan.ActiveEffectsIntegrated
            and active_plan.CombinedSourceStatCandidateReady
            and active_plan.SourceStatCandidateIncludesActiveEffects
            and active_plan.ReviewedActiveSourceRanks[1].SkillId == 82
            and active_plan.SourceModifiersApplied == 2
            and active_plan.CombatPointRuntimeReady
            and active_plan.CutoverPrerequisitesReady
            and #active_plan.ActivationBlockers == 0,
        "real Majesty source state composes with CP capability ready"
    )

    active_snapshot = {
        SourceRanks = {},
        UnresolvedEffects = {
            {
                CreativeSkillId = "UnmappedTimedBuff",
                CreativeRank = 1,
                Reason = "CreativeSkillNotActiveSourceCandidate",
            },
        },
        ActiveCount = 1,
        ResolvedCount = 0,
        Ready = false,
        Authoritative = true,
    }

    local unresolved = assert(
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)
    )
    check(
        not unresolved.ActiveEffectsIntegrated
            and not unresolved.CombinedSourceStatCandidateReady
            and unresolved.UnresolvedActiveSourceEffects[1].CreativeSkillId
                == "UnmappedTimedBuff"
            and unresolved.CombatPointRuntimeReady
            and not unresolved.CutoverPrerequisitesReady
            and #unresolved.ActivationBlockers == 1,
        "unresolved live active effect keeps active migration fail-closed"
    )

    active_snapshot = {
        SourceRanks = {
            {SkillId = 312, Rank = 3},
        },
        UnresolvedEffects = {},
        ActiveCount = 1,
        ResolvedCount = 1,
        Ready = true,
        Authoritative = true,
    }

    local forged = assert(
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)
    )
    check(
        not forged.ActiveEffectsIntegrated
            and forged.ActiveEffectSourceStateReason
                == "OriginalActiveNotLearnableByClassOrLevel"
            and forged.CombatPointRuntimeReady
            and not forged.CutoverPrerequisitesReady
            and #forged.ActivationBlockers == 1,
        "source rank valid for another class cannot forge active state"
    )

    active_snapshot = {
        SourceRanks = {},
        UnresolvedEffects = {},
        ActiveCount = 0,
        ResolvedCount = 0,
        Ready = true,
        Authoritative = true,
    }

    local missing_cp = Boundary.blockers()
    local ready = Boundary.blockers(CombatPoints.capability())
    check(
        #missing_cp == 1
            and missing_cp[1] == "LiveCPRuntimeUnavailable"
            and #ready == 0,
        "CP capability closes the final coordinated source blocker"
    )

    Runtime.clear_character(TEST_OWNER)
end

--[[
Checks forged advancement and unsupported levels cannot expose a cutover plan.

Args:
    None.

Returns:
    nil: Confirms server-owned identity remains mandatory.
]]
local function check_denials()
    local missing, missing_reason =
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)

    check(
        missing == nil
            and missing_reason == "OriginalCharacterIdentityNotVerified",
        "missing authoritative owner is denied"
    )

    local forged = original_character(
        "Human",
        "Oathguard",
        30
    )
    forged.ClassAdvancement.OriginalFirstTransferReceiptId = nil
    Runtime.set_character(TEST_OWNER, forged)

    local _, forged_reason =
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)

    check(
        forged_reason == "OriginalCharacterIdentityNotVerified",
        "copied first-transfer class without mentor receipt is denied"
    )

    Runtime.set_character(
        TEST_OWNER,
        original_character("Human", "Fighter", 31)
    )

    local _, level_reason =
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)

    check(
        level_reason == "UnreviewedClassOrLevel",
        "level 31 remains outside the reviewed launch source"
    )

    Runtime.clear_character(TEST_OWNER)
end

--[[
Runs the coordinated resource-boundary source regression.

Args:
    None.

Returns:
    nil: Prints a source-only pass marker after all assertions succeed.
]]
local function main()
    check_reviewed_paths()
    check_reviewed_equipment_boundary()
    check_human_wizard_reuse_boundary()
    check_nightweaver_passive_boundary()
    check_duskseer_passive_boundary()
    check_duskseer_active_buff_boundary()
    check_concentration_interrupt_boundary()
    check_owned_passive_boundary()
    check_active_effect_boundary()
    check_denials()

    print((
        "[C4 Resource Boundary] SOURCE_ONLY_PASS: %d assertions "
        .. "paths=17 prerequisites=true live_cutover=false blockers=0"
    ):format(checks))
end

main()
