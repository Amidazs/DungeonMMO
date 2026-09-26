--!strict
-- Full server transaction test for the creative Human Wizard transfer quest.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Shared = RS.Core.Shared
local Services = SSS.Core.Services

local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local FirstTransfers = require(Shared.OriginalFirstTransferDefinitions)
local Inventory = require(Services.InventoryService)
local Profiles = require(Services.ProfileService)
local QuestService = require(Services.C4OriginalFirstTransferQuestService)
local Selection = require(Services.C4FirstTransferSelectionService)
local SkillRules = require(Shared.SkillUnlockRules)
local Skills = require(Shared.SkillProgressionDefinitions)
local Stages = require(Shared.C4OriginalFirstTransferQuestStages)
local TransferService = require(Services.OriginalFirstTransferService)

local assertions = 0
local USER_ID = 99420

--[[
Checks one Human Wizard quest or transfer transaction invariant.

Args:
    condition (boolean): Observed authoritative server state.
    label (string): Failure description for focused Studio diagnostics.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    assertions += 1
    assert(condition, "[Human Wizard Quest] " .. label)
end

--[[
Creates a server-only quest-world verifier used only by this isolated test.

Args:
    None.

Returns:
    any: World adapter accepting only explicitly server-verified evidence.
]]
local function quest_world(): any
    local world = {}

    function world:available(_quest: any, _step: number?): boolean
        return true
    end

    function world:verify(
        user_id: number,
        event: any,
        quest: any,
        state: any
    ): boolean
        return event.ServerVerified == true
            and event.ActorUserId == user_id
            and state.BranchId == quest.BranchId
    end

    return world
end

--[[
Creates a one-use transfer mentor verifier around server-minted evidence.

Args:
    None.

Returns:
    (any, any): Mentor world adapter and its pending receipt table.
]]
local function transfer_world(): (any, any)
    local pending = {}
    local world = {}

    function world:available(_definition: any): boolean
        return true
    end

    function world:verify(
        user_id: number,
        event: any,
        definition: any
    ): boolean
        local expected = pending[user_id]
        pending[user_id] = nil
        return expected == event
            and event.ServerVerified == true
            and event.ActorUserId == user_id
            and event.TargetId == definition.MentorId
            and event.Kind == "OriginalFirstTransfer"
    end

    return world, pending
end

--[[
Creates one ordered quest event with branch-specific personal proof.

Args:
    quest (any): Emberglass source quest definition.
    step_index (number): Current ordered stage.
    count (number): Distinct event within a multi-kill stage.

Returns:
    any: Server-authenticated quest evidence for the current stage.
]]
local function quest_event(
    quest: any,
    step_index: number,
    count: number
): any
    local step = quest.Steps[step_index]
    local proofs = {}

    if step.TargetId == "AshveilAcolyte" then
        proofs.AetherglassShard = true
    elseif step.TargetId == "CinderboundConjurer" then
        proofs.CinderboundEmberSigil = true
    end

    return {
        EventId = ("WizardQuest:%d:%d"):format(step_index, count),
        ActorUserId = USER_ID,
        ServerVerified = true,
        Kind = step.Kind,
        TargetId = step.TargetId,
        MonsterReceiptId = if step.Kind == "QuestMonsterDefeat"
            then ("WizardQuestMonster:%d:%d"):format(step_index, count)
            else nil,
        VerifiedProofIds = proofs,
    }
end

--[[
Seeds a genuine Human Mystic and selects only the Human Wizard branch.

Args:
    profiles (any): Isolated authoritative profile service.

Returns:
    nil: Leaves a level-18 unadvanced Human Mystic with a saved choice.
]]
local function seed_character(profiles: any)
    check(profiles:load(USER_ID) ~= nil, "Profile loads")
    check(profiles:mutate(USER_ID, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 18
        character.Identity = {
            Version = 1,
            RaceId = "Human",
            BaseClassId = "Mage",
            ClassId = "Mage",
            CreationStage = "Complete",
        }
        character.ClassAdvancement = {
            Version = 1,
            CompletedByRace = {},
        }
    end), "Human Mystic identity is saved")

    local choice = Selection.new(profiles, "Base"):choose(
        USER_ID,
        "HumanWizard"
    )
    check(
        choice.ok and choice.class_id == "HumanWizard",
        "Human Mystic explicitly selects the Wizard branch"
    )
end

--[[
Runs every Emberglass quest stage through the actual profile transaction path.

Args:
    profiles (any): Isolated authoritative profile service.
    quest_service (any): Actual original quest progression service.

Returns:
    nil: Leaves the quest complete with consumed personal proof items.
]]
local function complete_quest(
    profiles: any,
    quest_service: any
)
    local quest = assert(Stages.get("HumanWizard"))
    check(quest_service:start(USER_ID).ok, "Emberglass quest starts")

    for step_index, step in ipairs(quest.Steps) do
        for count = 1, step.Required do
            local event = quest_event(quest, step_index, count)
            local outcome = quest_service:record_world_event(
                USER_ID,
                event
            )
            check(
                outcome.ok,
                "Verified Wizard quest stage advances in order"
            )
        end

        local character = assert(profiles:get_character(USER_ID))
        local state =
            character.ClassAdvancement.OriginalFirstTransferQuest

        if step_index == 3 then
            check(
                Inventory.count_item(
                    character,
                    "aetherglass_shard"
                ) == 3
                    and state.Proofs.AetherglassShards3 == true,
                "Three distinct kills mint owned shards and aggregate proof"
            )
        elseif step_index == 4 then
            check(
                Inventory.count_item(
                    character,
                    "aetherglass_shard"
                ) == 0,
                "Archivist turn-in atomically consumes all three shards"
            )
        elseif step_index == 5 then
            check(
                Inventory.count_item(
                    character,
                    "cinderbound_ember_sigil"
                ) == 1
                    and state.Proofs.CinderboundEmberSigil == true,
                "Final conjurer kill grants one personal ember sigil"
            )
        elseif step_index == 6 then
            check(
                Inventory.count_item(
                    character,
                    "cinderbound_ember_sigil"
                ) == 0
                    and state.Ready == true,
                "Final mentor turn-in consumes the sigil and readies transfer"
            )
        end
    end
end

--[[
Claims Emberweaver only after level 20 and one-use mentor evidence.

Args:
    profiles (any): Isolated profile service with a ready Wizard quest.

Returns:
    nil: Verifies class award, receipt authority and skill entitlement.
]]
local function claim_transfer(profiles: any)
    local world, pending = transfer_world()
    local transfer = TransferService.new(profiles, "Base", world)
    local premature = {
        Kind = "OriginalFirstTransfer",
        TargetId = "MagisterOrwyn",
        ActorUserId = USER_ID,
        EventId = "WizardTransferPremature",
        ServerVerified = true,
    }
    pending[USER_ID] = premature
    check(
        transfer:claim(USER_ID, premature).reason
            == "OriginalTransferLevelTooLow",
        "Completed quest cannot award the class before level 20"
    )

    check(profiles:mutate(USER_ID, function(profile: any)
        profile.Characters.Slot1.Level = 20
    end), "Quest owner reaches the source transfer level")

    local event = {
        Kind = "OriginalFirstTransfer",
        TargetId = "MagisterOrwyn",
        ActorUserId = USER_ID,
        EventId = "WizardTransferReceipt",
        ServerVerified = true,
    }
    pending[USER_ID] = event
    local outcome = transfer:claim(USER_ID, event)
    check(
        outcome.ok and outcome.class_id == "Emberweaver",
        "Authenticated mentor awards only Emberweaver"
    )

    local character = assert(profiles:get_character(USER_ID))
    local definition = assert(
        FirstTransfers.for_branch("HumanWizard")
    )
    check(
        FirstTransfers.awarded(character) == definition
            and character.Identity.ClassId == "Emberweaver"
            and character.Identity.BaseClassId == "Mage",
        "Award preserves the original Mystic base family and receipt"
    )

    local spell = assert(Skills.get("EmberweaverEmberBolt"))
    check(
        select(1, SkillRules.can_train(character, spell, 1)),
        "Earned Emberweaver receipt unlocks its level-20 trainer spell"
    )
end

--[[
Executes the complete isolated Human Wizard quest and transfer transaction.

Args:
    None.

Returns:
    nil: Prints the focused assertion count when every transaction passes.
]]
local function main()
    local profiles = Profiles.new(Adapter.new())
    seed_character(profiles)

    local quest_service = QuestService.new(
        profiles,
        "Base",
        quest_world()
    )
    complete_quest(profiles, quest_service)
    claim_transfer(profiles)

    check(
        profiles:save(USER_ID, "HumanWizardTransferTest"),
        "Awarded Wizard profile saves after transfer"
    )

    print(("[Human Wizard Quest] PASS: %d assertions")
        :format(assertions))
end

main()
