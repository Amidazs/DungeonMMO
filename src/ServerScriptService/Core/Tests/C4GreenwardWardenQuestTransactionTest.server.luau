--!strict
-- Full isolated Elven Knight quest transaction and class-award acceptance.
-- Physical Dungeon enemy spawning remains a separate Play requirement.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Services = SSS.Core.Services

local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Services.ProfileService)
local Selection = require(Services.C4FirstTransferSelectionService)
local QuestService = require(Services.C4OriginalFirstTransferQuestService)
local TransferService = require(Services.OriginalFirstTransferService)
local Inventory = require(Services.InventoryService)
local Quests = require(Shared.C4OriginalFirstTransferQuestStages)
local Transfers = require(Shared.OriginalFirstTransferDefinitions)
local TransferRules = require(Shared.ItemTransferRules)

local OWNER_ID = 848811
local QUEST = assert(Quests.get("ElvenKnight"))
local assertions = 0

local function check(valid: boolean, label: string)
    assertions += 1
    assert(valid, "[Greenward Warden Quest] " .. label)
end

local function quest_world(): any
    local world = {}
    function world:available(quest: any, index: number?): boolean
        local step = quest and quest.Steps[index or 1]
        return quest ~= nil and quest.BranchId == "ElvenKnight"
            and step ~= nil
    end
    function world:verify(
        user_id: number, event: any, quest: any, state: any
    ): boolean
        local step = quest.Steps[state.Step]
        return user_id == OWNER_ID and event.ServerVerified == true
            and event.ActorUserId == user_id and step ~= nil
            and event.Kind == step.Kind and event.TargetId == step.TargetId
    end
    return world
end

local function mentor_world(): (any, any)
    local pending = {}
    local world = {}
    function world:available(definition: any): boolean
        return definition.BranchId == "ElvenKnight"
    end
    function world:verify(
        user_id: number, event: any, definition: any
    ): boolean
        local expected = pending[user_id]
        pending[user_id] = nil
        return expected == event
            and event.ActorUserId == user_id
            and event.Kind == "OriginalFirstTransfer"
            and event.TargetId == definition.MentorId
    end
    return world, pending
end

local function seed(profiles: any)
    check(profiles:load(OWNER_ID) ~= nil, "Profile loads")
    check(profiles:mutate(OWNER_ID, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 18
        character.Identity = {
            Version = 1,
            RaceId = "Elf",
            BaseClassId = "Fighter",
            ClassId = "Fighter",
            CreationStage = "Complete",
        }
    end), "Elf Fighter identity persists")
    check(Selection.new(profiles, "Base"):choose(
        OWNER_ID, "ElvenKnight"
    ).ok, "Elf selects its own Knight branch")
end

local function evidence(index: number, count: number): any
    local step = QUEST.Steps[index]
    local proof_ids = {}
    if step.TargetId == "RootboundMarauder" then
        proof_ids.VerdantPatrolReport = true
    elseif step.TargetId == "ThornboundColossus" then
        proof_ids.VerdantGuardianSeal = true
    end
    return {
        EventId = "VerdantQuest:" .. tostring(index)
            .. ":" .. tostring(count),
        ActorUserId = OWNER_ID,
        Kind = step.Kind,
        TargetId = step.TargetId,
        ServerVerified = true,
        MonsterReceiptId = if step.Kind == "QuestMonsterDefeat"
            then "VerdantMonster:" .. tostring(index)
                .. ":" .. tostring(count)
            else nil,
        VerifiedProofIds = proof_ids,
    }
end

local function progress_quest(profiles: any, service: any)
    check(service:start(OWNER_ID).ok, "Quest starts at level 18")
    for index, step in ipairs(QUEST.Steps) do
        for count = 1, step.Required do
            local event = evidence(index, count)
            check(service:record_world_event(OWNER_ID, event).ok,
                "Authenticated step advances: " .. tostring(index))
        end
        local owner = assert(profiles:get_character(OWNER_ID))
        if index == 3 then
            check(Inventory.count_item(
                owner, "verdant_patrol_report"
            ) == 3, "Three distinct kills grant three bound reports")
            check(owner.ClassAdvancement.OriginalFirstTransferQuest
                .Proofs.VerdantPatrolReports3 == true,
                "Third report creates aggregate quest proof")
        elseif index == 4 then
            check(Inventory.count_item(
                owner, "verdant_patrol_report"
            ) == 0, "Warden return consumes all three reports")
        elseif index == 5 then
            check(Inventory.count_item(
                owner, "verdant_guardian_seal"
            ) == 1, "Colossus grants exactly one guardian seal")
        elseif index == 6 then
            check(Inventory.count_item(
                owner, "verdant_guardian_seal"
            ) == 0, "Final Sentinel return consumes guardian seal")
        end
    end
    local owner = assert(profiles:get_character(OWNER_ID))
    local state = owner.ClassAdvancement.OriginalFirstTransferQuest
    check(state.Ready == true and state.Step == #QUEST.Steps + 1,
        "Complete ordered quest becomes transfer-ready")
    check(not TransferRules.can_trade("verdant_patrol_report")
        and not TransferRules.can_bank("verdant_patrol_report")
        and not TransferRules.can_trade("verdant_guardian_seal")
        and not TransferRules.can_bank("verdant_guardian_seal"),
        "Quest evidence cannot enter trade or shared storage")
end

local function award_class(profiles: any)
    check(profiles:mutate(OWNER_ID, function(profile: any)
        profile.Characters.Slot1.Level = 20
    end), "Owner reaches transfer level")
    local world, pending = mentor_world()
    local service = TransferService.new(profiles, "Base", world)
    local definition = assert(Transfers.for_branch("ElvenKnight"))
    local event = {
        ActorUserId = OWNER_ID,
        Kind = "OriginalFirstTransfer",
        TargetId = definition.MentorId,
        EventId = "VerdantMentor:1",
    }
    pending[OWNER_ID] = event
    local result = service:claim(OWNER_ID, event)
    check(result.ok and result.class_id == "GreenwardWarden",
        "Only completed quest plus mentor awards Greenward Warden")
    local owner = assert(profiles:get_character(OWNER_ID))
    check(owner.Identity.ClassId == "GreenwardWarden"
        and Transfers.awarded(owner) == definition,
        "Awarded class and immutable receipt validate together")
    pending[OWNER_ID] = event
    check(service:claim(OWNER_ID, event).reason
        == "OriginalTransferAlreadyCompleted",
        "Mentor replay cannot duplicate class advancement")
    check(profiles:save(OWNER_ID, "VerdantQuestTransaction"),
        "Quest completion and class award save together")
end

local function main()
    local profiles = Profiles.new(Adapter.new())
    seed(profiles)
    progress_quest(
        profiles,
        QuestService.new(profiles, "Base", quest_world())
    )
    award_class(profiles)
    print(("[Greenward Warden Quest] PASS: %d assertions")
        :format(assertions))
end

main()
