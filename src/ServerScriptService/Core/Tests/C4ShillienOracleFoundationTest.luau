--!strict
-- Duskseer Shillien Oracle foundation regression before skill mapping.

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
Counts one Duskseer foundation assertion.

Args:
    condition (boolean): Observed backend condition.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Duskseer Foundation] " .. label)
end

--[[
Checks the independent Duskseer identity before its skill tree is mapped.

Args:
    None.

Returns:
    nil: Prints bounded foundation evidence.
]]
local function check_identity()
    local career = assert(Careers.for_branch("ShillienOracle"))
    local class = assert(Classes.get("Duskseer"))
    local trainer = assert(Trainers.get("DuskseerTrainer"))
    local quest = assert(QuestStages.get("ShillienOracle"))

    check(
        career.Id == "Duskseer"
            and career.RaceId == "DarkElf"
            and career.BaseClassId == "Mage"
            and career.TrainerId == "DuskseerTrainer",
        "Shillien Oracle resolves only to the Duskseer career"
    )
    check(
        class.FreshCreationAllowed == false
            and class.OriginalFirstTransferClass == true
            and #class.TeachableSkills == 26
            and #trainer.Skills == 26,
        "Duskseer class and trainer expose exactly 26 source families"
    )
    check(
        quest.BranchId == "ShillienOracle"
            and quest.StartLevel == 18
            and quest.TransferLevel == 20
            and quest.TransferNpcId == career.MentorId
            and #quest.RequiredProofIds == 2,
        "Duskseer owns a separate level-18 advancement trial"
    )
end

--[[
Checks exact class-42 primary stats and level-30 resource growth.

Args:
    None.

Returns:
    nil: Confirms the pinned Shillien Oracle template.
]]
local function check_primary_stats()
    local reference = assert(
        PrimaryStats.get("DarkElf", "Duskseer")
    )
    local stats = reference.Stats
    local vitals = assert(
        PrimaryStats.get_level_vitals(
            "DarkElf",
            "Duskseer",
            30
        )
    )

    check(
        reference.ScopeId == "ShillienOracle"
            and reference.Template.SourceClassId == 42
            and stats.STR == 23
            and stats.DEX == 23
            and stats.CON == 24
            and stats.INT == 44
            and stats.WIT == 19
            and stats.MEN == 37,
        "Duskseer preserves the exact class-42 primary-stat template"
    )
    check(
        vitals.MaxHP == 732
            and vitals.MaxMP == 482
            and vitals.MaxCP == 368
            and vitals.ConBonus == 0.90
            and vitals.MenBonus == 1.45,
        "Duskseer preserves exact level-30 HP, MP and CP"
    )
end

--[[
Checks the career shell remains fail-closed until all source ranks are mapped.

Args:
    None.

Returns:
    nil: Confirms 92 source rows remain explicitly outstanding.
]]
local function check_launch_gate()
    local audit = assert(Coverage.for_branch("ShillienOracle"))

    check(
        audit.SourceRankEntriesThroughCap == 92
            and audit.TrainerMappedRankEntries == 92
            and audit.MissingRankScheduleEntries == 0
            and audit.SourceRankScheduleMapped,
        "all 92 source rows have exact Duskseer training schedules"
    )
    check(
        audit.CurrentCareerId == "Duskseer"
            and audit.Status == "RankScheduleMappedEffectsPending"
            and not audit.ExactSourceRankCoverageCertified
            and not audit.LaunchSkillCatalogueReady,
        "mapped Duskseer ranks still require live effect acceptance"
    )
end

--[[
Runs the Duskseer class-42 foundation checkpoint.

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
        "[Duskseer Foundation] PASS: %d assertions rows=92 mapped=92"
    ):format(checks))
end

main()
