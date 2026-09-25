--!strict
-- Authenticated all-nine-path C4 resource cutover boundary regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared

local Careers = require(Shared.OriginalFirstTransferDefinitions)
local ProfileSchema = require(Shared.ProfileSchema)
local QuestStages = require(Shared.C4OriginalFirstTransferQuestStages)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local TEST_OWNER = 938176
local checks = 0

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
Checks exact level-30 source HP/MP/CP for every supported original path.

Args:
    None.

Returns:
    nil: Confirms exact source vitals while live cutover stays blocked.
]]
local function check_nine_paths()
    local vectors = {
        {"Human", "Fighter", 922, 319, 418},
        {"Human", "Mage", 699, 466, 366},
        {"Elf", "Fighter", 792, 324, 353},
        {"Elf", "Mage", 666, 469, 348},
        {"Human", "Ironvow", 1070, 320, 849},
        {"Human", "Oathguard", 1018, 320, 610},
        {"Human", "Ashenblade", 983, 320, 399},
        {"Elf", "GreenwardWarden", 902, 325, 453},
        {"Elf", "GreenwardScout", 874, 325, 354},
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
                and not plan.CanApplyLive
                and not plan.LiveHealthIntegrated
                and not plan.LiveManaIntegrated
                and not plan.LiveCPIntegrated,
            row[2] .. " exact source values remain fail-closed"
        )
        check(
            #plan.ActivationBlockers == 2
                and plan.OriginalOwnedPassiveMappingIntegrated
                and plan.SourceStatCandidateReady,
            row[2] .. " leaves only active-effect and CP blockers"
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
            and reviewed.ReviewedSourceItemIds.Gloves == 63
            and reviewed.ReviewedSourceItemIds.Feet == 38,
        "reviewed current six-slot gear exposes exact source item IDs"
    )
    check(
        reviewed.OriginalEquipmentExpertiseReady
            and reviewed.OriginalInventoryIntegrated
            and reviewed.OriginalOwnedPassiveMappingIntegrated
            and reviewed.SourceStatCandidateReady
            and not reviewed.CanApplyLive
            and #reviewed.ActivationBlockers == 2,
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
            and not blocked.OriginalEquipmentExpertiseReady
            and not blocked.OriginalInventoryIntegrated
            and blocked.OriginalEquipmentExpertiseReason
                == "OriginalEquipmentGradeExpertiseRequired"
            and blocked.OriginalOwnedPassiveMappingIntegrated
            and #blocked.ActivationBlockers == 3,
        "level-19 D-grade equipment keeps migration fail-closed"
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
            and #plan.ActivationBlockers == 3,
        "unmapped owned combat passive adds the passive migration blocker"
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
    check_nine_paths()
    check_reviewed_equipment_boundary()
    check_owned_passive_boundary()
    check_denials()

    print((
        "[C4 Resource Boundary] SOURCE_ONLY_PASS: %d assertions "
        .. "nine_paths=9 live=false blockers=2"
    ):format(checks))
end

main()
