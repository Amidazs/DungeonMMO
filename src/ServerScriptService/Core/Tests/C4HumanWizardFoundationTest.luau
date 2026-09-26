--!strict
-- Human Wizard first-transfer foundation: creative identity, quest and trainer.

local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared

local Branches = require(Shared.C4FirstTransferBranches)
local Classes = require(Shared.ClassProgressionDefinitions)
local Coverage = require(Shared.C4Level30LaunchCoverage)
local FirstTransfers = require(Shared.OriginalFirstTransferDefinitions)
local ProgressRules = require(Shared.C4OriginalQuestProgressRules)
local SkillMap = require(Shared.C4Level30ClassSkillMap)
local Skills = require(Shared.SkillProgressionDefinitions)
local SourceRanks = require(Shared.C4HumanWizardLevel30Sources)
local Stages = require(Shared.C4OriginalFirstTransferQuestStages)
local Trainers = require(Shared.TrainerCatalogues)

local assertions = 0

--[[
Checks one Human Wizard foundation invariant.

Args:
    condition (boolean): Observed server-side catalogue or gate state.
    label (string): Failure description for focused Studio diagnostics.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    assertions += 1
    assert(condition, "[Human Wizard Foundation] " .. label)
end

--[[
Creates one unadvanced Human Mystic with the selected Wizard quest branch.

Args:
    None.

Returns:
    any: Minimal authoritative character fixture at the quest start level.
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
            OriginalFirstTransferChoiceId = "HumanWizard",
        },
    }
end

--[[
Adds complete server-owned quest proof and a mentor receipt to the fixture.

Args:
    character (any): Human Mystic fixture selected for Human Wizard.

Returns:
    any: Same character mutated into an authentically represented Emberweaver.
]]
local function award_emberweaver(character: any): any
    local quest = assert(Stages.get("HumanWizard"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Identity.ClassId = "Emberweaver"
    character.ClassAdvancement.OriginalFirstTransferClassId =
        "Emberweaver"
    character.ClassAdvancement.OriginalFirstTransferReceiptId =
        "HumanWizardFoundationReceipt"
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
Counts source rows currently backed by a real class skill and trainer entry.

Args:
    None.

Returns:
    (number, number): Mapped and intentionally unmapped rank-row totals.
]]
local function mapped_rank_totals(): (number, number)
    local source = SourceRanks.get()
    local mapped = 0
    local missing = 0
    local trainer = assert(Trainers.get("EmberweaverTrainer"))

    for _, categories in pairs(source.Levels) do
        for category, count in pairs(categories) do
            local skill_id = SkillMap.get("HumanWizard", category)

            if not skill_id then
                missing += count
            else
                local definition = assert(Skills.get(skill_id))
                check(
                    Classes.can_teach("Emberweaver", skill_id),
                    "Mapped Wizard family must belong to Emberweaver"
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
                    "Mapped Wizard family must exist at its real trainer"
                )
                check(
                    definition.AllowedBaseClasses[1] == "Mage",
                    "Mapped Wizard skill must preserve Mystic base family"
                )
                mapped += count
            end
        end
    end

    return mapped, missing
end

--[[
Runs the Human Wizard career, quest, trainer and receipt-bound skill checks.

Args:
    None.

Returns:
    nil: Prints the focused assertion count when every contract passes.
]]
local function main()
    local wizard_paths = assert(Branches.get("Human", "Mage"))
    check(
        #wizard_paths == 2
            and wizard_paths[1].Id == "HumanWizard"
            and wizard_paths[1].GameplayStatus == "Partial",
        "Human Mystic keeps Wizard and Cleric as separate first transfers"
    )

    local quest = assert(Stages.get("HumanWizard"))
    check(
        quest.Id == "EmberglassTrial"
            and quest.StartLevel == 18
            and quest.TransferLevel == 20
            and #quest.Steps == 6,
        "Emberglass quest preserves the level-18 to level-20 structure"
    )
    check(
        quest.Steps[1].TargetId == "MagisterOrwyn"
            and quest.Steps[3].TargetId == "AshveilAcolyte"
            and quest.Steps[5].TargetId == "CinderboundConjurer",
        "Wizard advancement actors use original DungeonMMO identities"
    )

    local definition = assert(
        FirstTransfers.for_branch("HumanWizard")
    )
    check(
        definition.Id == "Emberweaver"
            and definition.BaseClassId == "Mage"
            and definition.TrainerId == "EmberweaverTrainer",
        "Human Wizard branch resolves only to the creative Emberweaver"
    )
    check(
        Classes.get("Emberweaver") ~= nil
            and Trainers.get("EmberweaverTrainer") ~= nil,
        "Emberweaver class and trainer are both registered"
    )

    local starter = starter_character()
    local can_start, reason = ProgressRules.can_start(
        starter,
        "HumanWizard"
    )
    check(
        can_start and reason == nil,
        "Selected level-20 Human Mystic may enter its Wizard quest"
    )

    local spell = assert(Skills.get("EmberweaverEmberBolt"))
    local can_train, locked_reason = require(
        Shared.SkillUnlockRules
    ).can_train(starter, spell, 1)
    check(
        not can_train
            and locked_reason == "OriginalFirstTransferRequired",
        "Bare Human Mystic cannot train Emberweaver skills"
    )

    local awarded = award_emberweaver(starter)
    check(
        FirstTransfers.awarded(awarded) == definition,
        "Quest proof plus mentor receipt authenticates Emberweaver"
    )
    check(
        select(1, require(Shared.SkillUnlockRules).can_train(
            awarded,
            spell,
            1
        )),
        "Authenticated Emberweaver may train its level-20 spell"
    )
    check(
        Trainers.can_offer(
            "EmberweaverTrainer",
            awarded,
            "EmberweaverEmberBolt"
        ).ok,
        "Only the earned class can see its trainer spell"
    )

    local mapped, missing = mapped_rank_totals()
    check(
        mapped == 93 and missing == 0,
        "Human Wizard source schedule must be fully mapped through level 30"
    )
    for _, category in ipairs({
        "ServitorHeal",
        "ServitorRecharge",
        "ManaServitorSummon",
        "CombatServitorSummon",
    }) do
        check(
            SkillMap.get("HumanWizard", category) ~= nil,
            "Companion family must map after server summon authority exists"
        )
    end

    local audit = assert(Coverage.for_branch("HumanWizard"))
    check(
        audit.SourceRankEntriesThroughCap == 93
            and audit.TrainerMappedRankEntries == 93
            and audit.MissingRankScheduleEntries == 0
            and audit.SourceRankScheduleMapped,
        "Launch audit closes Human Wizard level-30 rank coverage"
    )

    print(("[Human Wizard Foundation] PASS: %d assertions")
        :format(assertions))
end

main()
