--!strict
-- Human Cleric first-transfer foundation: creative identity, quest and trainer.

local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared

local Branches = require(Shared.C4FirstTransferBranches)
local Classes = require(Shared.ClassProgressionDefinitions)
local Coverage = require(Shared.C4Level30LaunchCoverage)
local FirstTransfers = require(Shared.OriginalFirstTransferDefinitions)
local ProgressRules = require(Shared.C4OriginalQuestProgressRules)
local SkillMap = require(Shared.C4Level30ClassSkillMap)
local Skills = require(Shared.SkillProgressionDefinitions)
local SourceRanks = require(Shared.C4HumanClericLevel30Sources)
local Stages = require(Shared.C4OriginalFirstTransferQuestStages)
local Trainers = require(Shared.TrainerCatalogues)
local UnlockRules = require(Shared.SkillUnlockRules)

local assertions = 0

--[[
Checks one Human Cleric foundation invariant.

Args:
    condition (boolean): Observed server-side catalogue or gate state.
    label (string): Failure description for focused Studio diagnostics.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    assertions += 1
    assert(condition, "[Human Cleric Foundation] " .. label)
end

--[[
Creates one unadvanced Human Mystic selected for the Cleric branch.

Args:
    None.

Returns:
    any: Minimal authoritative character fixture at transfer level.
]]
local function starter_character(): any
    return {
        Level = 20,
        Identity = {
            Version = 1,
            RaceId = "Human",
            BaseClassId = "Mage",
            ClassId = "Mage",
            CreationStage = "Complete",
        },
        Progression = {
            Skills = {},
        },
        ProfessionSlots = {
            Gathering = "",
            Creation = "",
        },
        ClassAdvancement = {
            Version = 1,
            CompletedByRace = {},
            ActiveClassId = nil,
            OriginalFirstTransferChoiceId = "HumanCleric",
        },
    }
end

--[[
Adds complete quest proof and a mentor receipt to the Cleric fixture.

Args:
    character (any): Human Mystic selected for Human Cleric.

Returns:
    any: Same character mutated into an authenticated Dawnkeeper.
]]
local function award_dawnkeeper(character: any): any
    local quest = assert(Stages.get("HumanCleric"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Identity.ClassId = "Dawnkeeper"
    character.ClassAdvancement.OriginalFirstTransferClassId =
        "Dawnkeeper"
    character.ClassAdvancement.OriginalFirstTransferReceiptId =
        "HumanClericFoundationReceipt"
    character.ClassAdvancement.OriginalFirstTransferQuest = {
        QuestId = quest.Id,
        BranchId = quest.BranchId,
        Step = #quest.Steps + 1,
        Count = 0,
        Ready = true,
        AppliedEvents = {},
        Proofs = proofs,
    }

    return character
end

--[[
Counts source rows backed by a real Dawnkeeper skill and trainer entry.

Args:
    None.

Returns:
    (number, number): Mapped and missing rank-row totals.
]]
local function mapped_rank_totals(): (number, number)
    local source = SourceRanks.get()
    local mapped = 0
    local missing = 0
    local trainer = assert(Trainers.get("DawnkeeperTrainer"))

    for _, categories in pairs(source.Levels) do
        for category, count in pairs(categories) do
            local skill_id = SkillMap.get("HumanCleric", category)

            if not skill_id then
                missing += count
            else
                local definition = assert(Skills.get(skill_id))
                check(
                    Classes.can_teach("Dawnkeeper", skill_id),
                    "Mapped Cleric family must belong to Dawnkeeper"
                )

                local offered = false
                for _, entry in ipairs(trainer.Skills) do
                    if entry.SkillId == skill_id then
                        offered = true
                        break
                    end
                end
                check(
                    offered,
                    "Mapped Cleric family must exist at its trainer"
                )
                check(
                    definition.AllowedBaseClasses[1] == "Mage",
                    "Mapped Cleric skill preserves Human Mystic family"
                )
                mapped += count
            end
        end
    end

    return mapped, missing
end

--[[
Runs Human Cleric career, quest, trainer and rank-schedule checks.

Args:
    None.

Returns:
    nil: Prints the focused assertion count after every contract passes.
]]
local function main()
    local paths = assert(Branches.get("Human", "Mage"))
    check(
        #paths == 2
            and paths[2].Id == "HumanCleric"
            and paths[2].GameplayStatus == "Partial",
        "Human Mystic retains a distinct partial Cleric first transfer"
    )

    local quest = assert(Stages.get("HumanCleric"))
    check(
        quest.Id == "DawnkeeperVigil"
            and quest.StartLevel == 18
            and quest.TransferLevel == 20
            and #quest.Steps == 6,
        "Dawnkeeper quest preserves level-18 to level-20 structure"
    )
    check(
        quest.Steps[1].TargetId == "PriestessElara"
            and quest.Steps[3].TargetId == "GloamCultist"
            and quest.Steps[5].TargetId == "HollowAcolyte",
        "Cleric advancement actors use DungeonMMO identities"
    )

    local definition = assert(
        FirstTransfers.for_branch("HumanCleric")
    )
    check(
        definition.Id == "Dawnkeeper"
            and definition.BaseClassId == "Mage"
            and definition.TrainerId == "DawnkeeperTrainer",
        "Human Cleric resolves only to creative Dawnkeeper"
    )
    check(
        Classes.get("Dawnkeeper") ~= nil
            and Trainers.get("DawnkeeperTrainer") ~= nil,
        "Dawnkeeper class and trainer are registered"
    )

    local starter = starter_character()
    local can_start, reason = ProgressRules.can_start(
        starter,
        "HumanCleric"
    )
    check(
        can_start and reason == nil,
        "Selected level-20 Human Mystic may enter Cleric quest"
    )

    local spell = assert(Skills.get("DawnkeeperHealingLight"))
    local can_train, locked_reason =
        UnlockRules.can_train(starter, spell, 1)
    check(
        not can_train
            and locked_reason == "OriginalFirstTransferRequired",
        "Bare Human Mystic cannot train Dawnkeeper skills"
    )

    local awarded = award_dawnkeeper(starter)
    check(
        FirstTransfers.awarded(awarded) == definition,
        "Quest proof plus mentor receipt authenticates Dawnkeeper"
    )
    check(
        select(1, UnlockRules.can_train(awarded, spell, 1)),
        "Authenticated Dawnkeeper may train its level-20 heal"
    )
    check(
        Trainers.can_offer(
            "DawnkeeperTrainer",
            awarded,
            "DawnkeeperHealingLight"
        ).ok,
        "Earned Dawnkeeper can see its class trainer skill"
    )

    local mapped, missing = mapped_rank_totals()
    check(
        mapped == 88 and missing == 0,
        "Human Cleric source schedule maps all 88 level-30 rows"
    )

    local audit = assert(Coverage.for_branch("HumanCleric"))
    check(
        audit.SourceRankEntriesThroughCap == 88
            and audit.TrainerMappedRankEntries == 88
            and audit.MissingRankScheduleEntries == 0
            and audit.SourceRankScheduleMapped,
        "Launch audit closes Human Cleric rank schedule mapping"
    )

    print((
        "[Human Cleric Foundation] PASS: %d assertions"
    ):format(assertions))
end

main()
