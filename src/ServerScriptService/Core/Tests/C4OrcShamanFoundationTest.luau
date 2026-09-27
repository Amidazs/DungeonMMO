--!strict
-- Ashspeaker Orc Shaman foundation regression before skill mapping.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared
local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Classes = require(Shared.ClassProgressionDefinitions)
local Coverage = require(Shared.C4Level30LaunchCoverage)
local PrimaryStats = require(Shared.C4PrimaryStatReference)
local QuestStages = require(Shared.C4OriginalFirstTransferQuestStages)
local Trainers = require(Shared.TrainerCatalogues)

local checks = 0

--[[
Counts one Ashspeaker foundation assertion.

Args:
    condition (boolean): Observed backend condition.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Ashspeaker Foundation] " .. label)
end

--[[
Checks the independent Ashspeaker identity before its skill tree is mapped.

Args:
    None.

Returns:
    nil: Confirms class, trainer and quest boundaries.
]]
local function check_identity()
    local career = assert(Careers.for_branch("OrcShaman"))
    local class = assert(Classes.get("Ashspeaker"))
    local trainer = assert(Trainers.get("AshspeakerTrainer"))
    local quest = assert(QuestStages.get("OrcShaman"))

    check(
        career.Id == "Ashspeaker"
            and career.RaceId == "Orc"
            and career.BaseClassId == "Mage"
            and career.TrainerId == "AshspeakerTrainer",
        "Orc Shaman resolves only to Ashspeaker"
    )
    check(
        class.FreshCreationAllowed == false
            and class.OriginalFirstTransferClass == true
            and #class.TeachableSkills == 0
            and #trainer.Skills == 0,
        "Ashspeaker cannot bypass mentor or unmapped trainer gate"
    )
    check(
        quest.BranchId == "OrcShaman"
            and quest.StartLevel == 18
            and quest.TransferLevel == 20
            and quest.TransferNpcId == career.MentorId
            and #quest.RequiredProofIds == 2,
        "Ashspeaker owns a separate level-18 advancement trial"
    )
end

--[[
Checks exact class-49 starter and class-50 first-transfer source stats.

Args:
    None.

Returns:
    nil: Confirms exact Orc Mystic/Shaman templates and level-30 vitals.
]]
local function check_primary_stats()
    local starter = assert(PrimaryStats.get("Orc", "Mage"))
    local transfer = assert(
        PrimaryStats.get("Orc", "Ashspeaker")
    )
    local vitals = assert(
        PrimaryStats.get_level_vitals(
            "Orc",
            "Ashspeaker",
            30
        )
    )

    check(
        starter.ScopeId == "OrcMystic"
            and starter.Template.SourceClassId == 49
            and transfer.ScopeId == "OrcShaman"
            and transfer.Template.SourceClassId == 50,
        "Ashspeaker preserves exact class-49 inheritance and class-50 identity"
    )
    check(
        transfer.Stats.STR == 27
            and transfer.Stats.DEX == 24
            and transfer.Stats.CON == 31
            and transfer.Stats.INT == 31
            and transfer.Stats.WIT == 15
            and transfer.Stats.MEN == 42,
        "Ashspeaker preserves the exact class-50 primary-stat template"
    )
    check(
        vitals.MaxHP == 869
            and vitals.MaxMP == 504
            and vitals.MaxCP == 436
            and vitals.ConBonus == 1.10
            and vitals.MenBonus == 1.52,
        "Ashspeaker preserves exact level-30 HP, MP and CP"
    )
end

--[[
Checks the career shell remains fail-closed until all source ranks are mapped.

Args:
    None.

Returns:
    nil: Confirms 77 source rows remain explicitly outstanding.
]]
local function check_launch_gate()
    local audit = assert(Coverage.for_branch("OrcShaman"))

    check(
        audit.SourceRankEntriesThroughCap == 77
            and audit.TrainerMappedRankEntries == 0
            and audit.MissingRankScheduleEntries == 77
            and not audit.SourceRankScheduleMapped,
        "Ashspeaker foundation does not claim any unmapped source rank"
    )
    check(
        audit.CurrentCareerId == "Ashspeaker"
            and audit.Status == "SkillRankParityOutstanding"
            and not audit.ExactSourceRankCoverageCertified
            and not audit.LaunchSkillCatalogueReady,
        "Ashspeaker remains explicitly outside the release gate"
    )
end

--[[
Runs the Ashspeaker class-50 foundation checkpoint.

Args:
    None.

Returns:
    nil: Prints exact source and fail-closed career evidence.
]]
local function main()
    check_identity()
    check_primary_stats()
    check_launch_gate()

    print((
        "[Ashspeaker Foundation] PASS: %d assertions rows=77 mapped=0"
    ):format(checks))
end

main()
