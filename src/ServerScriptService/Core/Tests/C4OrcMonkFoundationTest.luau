--!strict
-- Spiritclaw Orc Monk foundation regression before skill mapping.

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
Counts one Spiritclaw foundation assertion.

Args:
    condition (boolean): Observed backend condition.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Spiritclaw Foundation] " .. label)
end

--[[
Checks the independent Spiritclaw identity before its skill tree is mapped.

Args:
    None.

Returns:
    nil: Confirms the earned class and empty trainer remain fail-closed.
]]
local function check_identity()
    local career = assert(Careers.for_branch("OrcMonk"))
    local class = assert(Classes.get("Spiritclaw"))
    local trainer = assert(Trainers.get("SpiritclawTrainer"))
    local quest = assert(QuestStages.get("OrcMonk"))

    check(
        career.Id == "Spiritclaw"
            and career.RaceId == "Orc"
            and career.BaseClassId == "Fighter"
            and career.TrainerId == "SpiritclawTrainer",
        "Orc Monk resolves only to the Spiritclaw career"
    )
    check(
        class.FreshCreationAllowed == false
            and class.OriginalFirstTransferClass == true
            and #class.TeachableSkills == 10
            and #trainer.Skills == 10,
        "Spiritclaw exposes exactly ten class-47 source families"
    )
    check(
        quest.BranchId == "OrcMonk"
            and quest.StartLevel == 18
            and quest.TransferLevel == 20
            and quest.TransferNpcId == career.MentorId
            and #quest.RequiredProofIds == 2,
        "Spiritclaw owns a separate level-18 advancement trial"
    )
end

--[[
Checks exact class-47 primary stats and level-30 resource growth.

Args:
    None.

Returns:
    nil: Confirms the pinned Orc Monk template.
]]
local function check_primary_stats()
    local reference = assert(
        PrimaryStats.get("Orc", "Spiritclaw")
    )
    local stats = reference.Stats
    local vitals = assert(
        PrimaryStats.get_level_vitals(
            "Orc",
            "Spiritclaw",
            30
        )
    )

    check(
        reference.ScopeId == "OrcMonk"
            and reference.Template.SourceClassId == 47
            and stats.STR == 40
            and stats.DEX == 26
            and stats.CON == 47
            and stats.INT == 18
            and stats.WIT == 12
            and stats.MEN == 27,
        "Spiritclaw preserves the exact class-47 primary-stat template"
    )
    check(
        vitals.MaxHP == 1230
            and vitals.MaxMP == 327
            and vitals.MaxCP == 617
            and vitals.ConBonus == 1.77
            and vitals.MenBonus == 1.31,
        "Spiritclaw preserves exact level-30 HP, MP and CP"
    )
end

--[[
Checks the class shell stays fail-closed until all source ranks are mapped.

Args:
    None.

Returns:
    nil: Confirms 41 source rows remain explicitly outstanding.
]]
local function check_launch_gate()
    local audit = assert(Coverage.for_branch("OrcMonk"))

    check(
        audit.SourceRankEntriesThroughCap == 41
            and audit.TrainerMappedRankEntries == 41
            and audit.MissingRankScheduleEntries == 0
            and audit.SourceRankScheduleMapped,
        "all 41 source rows have exact Spiritclaw training schedules"
    )
    check(
        audit.CurrentCareerId == "Spiritclaw"
            and audit.Status == "RankScheduleMappedEffectsPending"
            and not audit.ExactSourceRankCoverageCertified
            and not audit.LaunchSkillCatalogueReady,
        "mapped Spiritclaw ranks still require live effect acceptance"
    )
end

--[[
Runs the Spiritclaw class-47 foundation checkpoint.

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
        "[Spiritclaw Foundation] PASS: %d assertions rows=41 mapped=41"
    ):format(checks))
end

main()
