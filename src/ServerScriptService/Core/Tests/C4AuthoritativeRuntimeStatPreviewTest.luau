--!strict
-- Authenticated nine-class C4 HP/MP/CP preview; no player stat mutation.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared

local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Schema = require(Shared.ProfileSchema)
local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Stages = require(Shared.C4OriginalFirstTransferQuestStages)

local TEST_OWNER = 938175
local checks = 0

--[[
Counts an authenticated original class and level-stat assertion.

Args:
    valid (boolean): Expected original-vitals or anti-forgery condition.
    label (string): Precise reason for a regression failure.

Returns:
    nil: Increments success count or raises on unexpected source data.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Runtime Stat Preview] " .. label)
end

--[[
Builds a complete valid original-class source profile for testing.

Only the disposable fixture mints completed source quest proof and
mentor receipt. Production first-transfer eligibility remains intact.

Args:
    race_id (string): Original Elf or Human.
    class_id (string): Starter or first-transfer creative class ID.
    level (number): Current original class level up to 30.

Returns:
    any: Actual profile-shaped owner with appropriate class receipt.
]]
local function original_character(
    race_id: string, class_id: string, level: number
): any
    local character = Schema.create_default(TEST_OWNER).Characters.Slot1
    character.Level = level
    local career = Careers.for_class(class_id)
    local base_class = if career then career.BaseClassId else class_id
    character.Identity = {
        Version = 1, RaceId = race_id,
        BaseClassId = base_class, ClassId = class_id,
        CreationStage = "Complete",
    }
    if career then
        local stage = assert(Stages.get(career.BranchId))
        local proofs = {}
        for _, id in ipairs(stage.RequiredProofIds) do
            proofs[id] = true
        end
        character.ClassAdvancement = {
            Version = 1,
            OriginalFirstTransferChoiceId = career.BranchId,
            OriginalFirstTransferClassId = career.Id,
            OriginalFirstTransferReceiptId = "TEMP_C4SourceOnlyMentor",
            OriginalFirstTransferQuest = {
                QuestId = stage.Id,
                BranchId = career.BranchId,
                Step = #stage.Steps + 1,
                Count = 0, Ready = true,
                AppliedEvents = {}, Proofs = proofs,
            },
        }
    end
    return character
end

--[[
Checks all nine owner-verified class HP/MP/CP level-30 source vectors.

Args:
    None.

Returns:
    nil: Never grants C4 health or mana to the actual live combat loop.
]]
local function check_nine_classes()
    local rows = {
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
    for _, row in ipairs(rows) do
        Runtime.set_character(
            TEST_OWNER, original_character(row[1], row[2], 30)
        )
        local preview, reason = Runtime.get_c4_source_vitals(TEST_OWNER)
        check(preview ~= nil and reason == nil,
            row[2] .. " has a real server-owned original class")
        check(preview.MaxHealth == row[3]
                and preview.MaxMana == row[4]
                and preview.MaxCP == row[5],
            row[2] .. " original level-30 HP/MP/CP matches source")
        check(preview.RaceId == row[1]
                and preview.ClassId == row[2]
                and preview.Level == 30
                and preview.SourceOnly and not preview.LiveApplied,
            row[2] .. " verified identity does not rewrite live stats")
        Runtime.clear_character(TEST_OWNER)
    end
end

--[[
Rejects wrong race, forged class award, unsupported level or no profile.

Args:
    None.

Returns:
    nil: Source-vitals API cannot be used to launder a copied class ID.
]]
local function check_authoritative_denials()
    local missing, missing_reason = Runtime.get_c4_source_vitals(
        TEST_OWNER
    )
    check(missing == nil
        and missing_reason == "OriginalCharacterIdentityNotVerified",
        "Missing server-owned profile has no original C4 vitals")
    local forged = original_character("Elf", "GreenwardWarden", 30)
    forged.ClassAdvancement.OriginalFirstTransferReceiptId = nil
    Runtime.set_character(TEST_OWNER, forged)
    local _, reason = Runtime.get_c4_source_vitals(TEST_OWNER)
    check(reason == "OriginalCharacterIdentityNotVerified",
        "Copied first-transfer class without a mentor receipt is denied")
    forged = original_character("Elf", "GreenwardWarden", 30)
    forged.Identity.RaceId = "Human"
    Runtime.set_character(TEST_OWNER, forged)
    local _, race_reason = Runtime.get_c4_source_vitals(TEST_OWNER)
    check(race_reason == "OriginalCharacterIdentityNotVerified",
        "Wrong race cannot borrow the Warden original source HP curve")
    Runtime.set_character(
        TEST_OWNER, original_character("Human", "Fighter", 31)
    )
    local _, level_reason = Runtime.get_c4_source_vitals(TEST_OWNER)
    check(level_reason == "UnreviewedClassOrLevel",
        "Level 31 cannot borrow an unverified level-30-only reference")
    Runtime.clear_character(TEST_OWNER)
end

--[[
Runs the real server runtime preview and restores its disposable owner.

Args:
    None.

Returns:
    nil: Explicitly distinguishes source-only success from live adoption.
]]
local function main()
    check_nine_classes()
    check_authoritative_denials()
    print(("[C4 Runtime Stat Preview] SOURCE_ONLY_PASS: %d "
        .. "assertions nine_paths=9 live=false"):format(checks))
end

main()
