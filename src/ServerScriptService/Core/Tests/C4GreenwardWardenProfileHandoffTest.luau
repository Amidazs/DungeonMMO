--!strict
-- Separate actual ProfileService instances share one disposable store only.
-- No Roblox TeleportService, real DataStore or production character is used.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Services = SSS.Core.Services

local Memory = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Services.ProfileService)
local Inventory = require(Services.InventoryService)
local Quests = require(Services.C4OriginalFirstTransferQuestService)
local Transfers = require(Services.OriginalFirstTransferService)
local Skills = require(Services.SkillProgressionService)
local Loadout = require(Services.LoadoutService)
local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Source = require(Shared.C4OriginalFirstTransferQuestStages)

local OWNER_ID = 848877
local OTHER_ID = 848878
local BRANCH_ID = "ElvenKnight"
local QUEST = assert(Source.get(BRANCH_ID))
local checks = 0

--[[
Checks one actual saved-profile or quest-state contract.

Args:
    valid (boolean): Expected authoritative owner and state boundary.
    label (string): Exact diagnostic when an acceptance requirement fails.

Returns:
    nil: Increments the passing count or raises on failure.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Warden Handoff] " .. label)
end

--[[
Creates an isolated per-place profile service over the same store.

Args:
    adapter (any): Disposable one-session shared profile storage.

Returns:
    any: Fresh independently cached profile service, never a reused cache.
]]
local function open_place(adapter: any): any
    local profiles = Profiles.new(adapter)
    check(profiles:load(OWNER_ID) ~= nil,
        "New place loads the original owner from saved store")
    check(profiles:load(OTHER_ID) ~= nil,
        "New place loads an independent other player")
    return profiles
end

--[[
Verifies owner reports never become account-shared or copied to party.

Args:
    profiles (any): Current independently loaded profile service.
    expected_count (number): Exactly owned bound patrol report quantity.
    expected_stage (number): Actual persisted original quest stage.

Returns:
    nil: Confirms private item count, chosen class and quest progression.
]]
local function check_reports(
    profiles: any, expected_count: number, expected_stage: number
)
    local owner = assert(profiles:get_character(OWNER_ID))
    local other = assert(profiles:get_character(OTHER_ID))
    local quest = owner.ClassAdvancement.OriginalFirstTransferQuest
    check(Inventory.count_item(owner, "verdant_patrol_report")
            == expected_count and quest.Step == expected_stage,
        "Owner's reports and original quest stage survive a new place")
    check(Inventory.count_item(other, "verdant_patrol_report") == 0
        and Inventory.count_item(other, "verdant_guardian_seal") == 0,
        "Other player never receives owner quest material")
    check(owner.ClassAdvancement.OriginalFirstTransferChoiceId
        == BRANCH_ID, "Original selected Elven Knight survives reload")
end

--[[
Prepares a legitimate-looking personal stage-four saved fixture.

Reports here are test-seeded, not claimed to have been earned in
this focused storage test; the separate v2.38 Play proves three
genuine client-earned report drops in actual dungeon combat.

Args:
    profiles (any): Disposable initial Base profile service.

Returns:
    nil: Saves three individually owned bound reports at stage four.
]]
local function seed_reports(profiles: any)
    check(profiles:mutate(OWNER_ID, function(profile: any)
        local owner = profile.Characters.Slot1
        owner.Level = 18
        owner.Identity = {
            Version = 1, RaceId = "Elf",
            BaseClassId = "Fighter", ClassId = "Fighter",
            CreationStage = "Complete",
        }
        owner.ClassAdvancement.OriginalFirstTransferChoiceId = BRANCH_ID
        owner.ClassAdvancement.OriginalFirstTransferQuest = {
            QuestId = QUEST.Id, BranchId = BRANCH_ID,
            Step = 4, Count = 0, Ready = false,
            AppliedEvents = {}, Proofs = {
                VerdantPatrolReports3 = true,
            },
        }
    end), "Test-only stage-four profile can be persisted")
    check(Inventory.new(profiles):add_item(
        OWNER_ID, "verdant_patrol_report", 3
    ).ok, "Only initial disposable owner receives report materials")
    check_reports(profiles, 3, 4)
end

--[[
Issues one private test-only signed NPC interaction to the real service.

Args:
    profiles (any): Current place's actual profile service.
    npc_id (string): Original source NPC for the current quest stage.

Returns:
    nil: Consumes bound inventory through the normal quest transaction.
]]
local function interact_with_npc(profiles: any, npc_id: string)
    local pending = {}
    local world = {}
    function world:available(quest: any, stage: number): boolean
        return quest.BranchId == BRANCH_ID
            and quest.Steps[stage] ~= nil
    end
    function world:verify(
        user_id: number, event: any, quest: any, state: any
    ): boolean
        local signed = pending[user_id]
        pending[user_id] = nil
        local step = quest.Steps[state.Step]
        return signed == event and step ~= nil
            and event.ActorUserId == user_id
            and event.Kind == "NpcTalk"
            and event.TargetId == step.TargetId
    end
    local event = {
        EventId = "TEMP_WardenHandoffTalk:" .. npc_id,
        ActorUserId = OWNER_ID, Kind = "NpcTalk", TargetId = npc_id,
    }
    local service = Quests.new(profiles, "Base", world)
    check(not service:record_world_event(
        OWNER_ID, event
    ).ok, "Unsigned NPC evidence cannot progress a saved quest")
    pending[OWNER_ID] = event
    check(service:record_world_event(OWNER_ID, event).ok,
        "Only signed owner NPC transaction consumes bound quest items")
end

--[[
Saves and releases one place without retaining its writable cache.

Args:
    profiles (any): Source place's actual profile service.
    label (string): Phase label for save-release diagnostics.

Returns:
    nil: Next place can only see the saved adapter, not this service.
]]
local function close_place(profiles: any, label: string)
    check(profiles:save(OWNER_ID, label),
        "Owner report or advancement transaction saves at " .. label)
    check(profiles:release(OWNER_ID, label),
        "Owner's independent source cache releases at " .. label)
    check(profiles:get_character(OWNER_ID) == nil,
        "Released previous place cannot serve stale owner character")
end

--[[
Uses a signed one-use mentor receipt and actual rank-purchase service.

Args:
    profiles (any): Newly loaded returned Base authoritative owner.

Returns:
    nil: Earns class/skill only after saved completed original quest.
]]
local function award_and_train(profiles: any)
    check(profiles:mutate(OWNER_ID, function(profile: any)
        local owner = profile.Characters.Slot1
        owner.Level = 20
        owner.Progression.SkillPointEntitlement = 2000
        owner.Progression.Skills.ShieldBash = {
            Known = true, PurchasedRank = 3, Proficiency = 0,
        }
    end), "Test owner reaches level-20 mentor prerequisites")
    local event = {
        EventId = "TEMP_WardenHandoffMentor",
        ActorUserId = OWNER_ID,
        Kind = "OriginalFirstTransfer",
        TargetId = "SentinelIlyra",
    }
    local pending = {}
    local world = {}
    function world:available(definition: any): boolean
        return definition.BranchId == BRANCH_ID
    end
    function world:verify(
        user_id: number, receipt: any, definition: any
    ): boolean
        local signed = pending[user_id]
        pending[user_id] = nil
        return signed == receipt
            and receipt.ActorUserId == user_id
            and receipt.TargetId == definition.MentorId
    end
    local service = Transfers.new(profiles, "Base", world)
    check(not service:claim(OWNER_ID, event).ok,
        "Unsigned mentor receipt cannot grant original class")
    pending[OWNER_ID] = event
    check(service:claim(OWNER_ID, event).class_id
        == "GreenwardWarden",
        "Saved quest and one-use mentor earn real Warden class")
    local skills = Skills.new(
        profiles, Inventory.new(profiles), Loadout.new(profiles)
    )
    check(skills:learn_trainer_skill(
        OWNER_ID, "GreenwardWardenSteelTraining"
    ).ok, "Returned original Warden can purchase its own first rank")
end

--[[
Exercises separate Base/Dungeon/Base/rejoin caches on ONE saved store.

Args:
    None.

Returns:
    nil: Prints source-isolated assertions without claiming live teleport.
]]
local function main()
    local adapter = Memory.new()
    local base_one = open_place(adapter)
    seed_reports(base_one)
    close_place(base_one, "BaseToDungeon")
    local dungeon = open_place(adapter)
    check_reports(dungeon, 3, 4)
    close_place(dungeon, "DungeonToBase")
    local base_two = open_place(adapter)
    check_reports(base_two, 3, 4)
    interact_with_npc(base_two, "WardenCaer")
    check_reports(base_two, 0, 5)
    check(Inventory.new(base_two):add_item(
        OWNER_ID, "verdant_guardian_seal"
    ).ok, "Test-only boss seal belongs only to original owner")
    check(base_two:mutate(OWNER_ID, function(profile: any)
        local owner = profile.Characters.Slot1
        owner.ClassAdvancement.OriginalFirstTransferQuest.Step = 6
        owner.ClassAdvancement.OriginalFirstTransferQuest
            .Proofs.VerdantGuardianSeal = true
    end), "Test-only genuine-owner boss stage saves after combat")
    close_place(base_two, "BossToBase")
    local base_three = open_place(adapter)
    check(Inventory.count_item(
        assert(base_three:get_character(OWNER_ID)),
        "verdant_guardian_seal"
    ) == 1, "Boss seal persists through new profile cache")
    interact_with_npc(base_three, "SentinelIlyra")
    check(Inventory.count_item(
        assert(base_three:get_character(OWNER_ID)),
        "verdant_guardian_seal"
    ) == 0, "Signed final NPC consumes only the real owner's seal")
    award_and_train(base_three)
    close_place(base_three, "FinalRejoin")
    local rejoined = open_place(adapter)
    local owner = assert(rejoined:get_character(OWNER_ID))
    local quest = owner.ClassAdvancement.OriginalFirstTransferQuest
    local skill = owner.Progression.Skills.GreenwardWardenSteelTraining
    check(quest.Ready == true and quest.Step == #QUEST.Steps + 1
        and Careers.awarded(owner) ~= nil
        and owner.Identity.ClassId == "GreenwardWarden"
        and skill ~= nil and skill.PurchasedRank == 1,
        "Rejoined original owner retains completed quest, class and rank")
    check_reports(rejoined, 0, #QUEST.Steps + 1)
    print(("[Warden Handoff] PASS: %d assertions")
        :format(checks))
end

main()
