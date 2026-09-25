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
            #plan.ActivationBlockers == 4,
            row[2] .. " keeps all coordinated migration blockers"
        )

        Runtime.clear_character(TEST_OWNER)
    end
end

--[[
Checks forged advancement and unsupported levels cannot expose a cutover plan.

Args:
    None.

Returns:
    nil: Confirms server-owned identity remains mandatory.
]]
--[[
Checks reviewed core gear is surfaced while extra paperdoll slots stay blocked.

Args:
    None.

Returns:
    nil: Confirms source gear can be previewed without enabling live cutover.
]]
local function check_reviewed_equipment_boundary()
    local character = original_character("Human", "Oathguard", 30)
    character.Equipment = {
        Weapon = "marauder_sword",
        Body = "stonewatch_d_grade_armor",
        OffHand = "marauder_shield",
    }
    Runtime.set_character(TEST_OWNER, character)

    local reviewed = assert(
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)
    )
    check(
        reviewed.ReviewedCoreLoadoutReady
            and reviewed.ReviewedSourceItemIds.Weapon == 1
            and reviewed.ReviewedSourceItemIds.Body == 352
            and reviewed.ReviewedSourceItemIds.OffHand == 102,
        "reviewed current core gear exposes exact source item IDs"
    )
    check(
        not reviewed.OriginalInventoryIntegrated
            and not reviewed.CanApplyLive,
        "reviewed core gear does not prematurely close inventory migration"
    )

    character.Equipment.Helmet = "marauder_helmet"
    Runtime.set_character(TEST_OWNER, character)
    local blocked = assert(
        Runtime.get_c4_resource_migration_boundary(TEST_OWNER)
    )
    check(
        not blocked.ReviewedCoreLoadoutReady
            and blocked.ReviewedCoreLoadoutReason
                == "AdditionalCreativeEquipmentSlotsNotIntegrated",
        "unintegrated helmet prevents a complete source loadout claim"
    )

    Runtime.clear_character(TEST_OWNER)
end

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
    check_denials()

    print((
        "[C4 Resource Boundary] SOURCE_ONLY_PASS: %d assertions "
        .. "nine_paths=9 live=false blockers=4"
    ):format(checks))
end

main()
