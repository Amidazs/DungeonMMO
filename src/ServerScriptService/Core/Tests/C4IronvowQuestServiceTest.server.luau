--!strict
-- Independent Ironroot Oath test: profile, personal drops and ordered
-- server-only proof. This fixture is not a live NPC/dungeon journey.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Sources = require(Shared.C4OriginalFirstTransferQuestStages)
local Rules = require(Shared.C4OriginalQuestProgressRules)
local Inventory = require(SSS.Core.Services.InventoryService)
local Adapter = require(SSS.Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(SSS.Core.Services.ProfileService)
local Selection = require(SSS.Core.Services.C4FirstTransferSelectionService)
local QuestService = require(
    SSS.Core.Services.C4OriginalFirstTransferQuestService
)

local CHECKS = 0
local USER_ID = 837920

--[[
Asserts one real profile or server-only quest condition.

Args:
    condition (boolean): Observed service result or authoritative item.
    message (string): A concise failure message.

Returns:
    nil: Counts verified statements without bypassing the service.
]]
local function check(condition: boolean, message: string)
    CHECKS += 1
    assert(condition, "[Ironvow Quest] " .. message)
end

--[[
Creates a deliberately isolated trusted-world adapter for service testing.

Args:
    None.

Returns:
    any: Accepts ONLY test-injected server evidence for this exact branch.
]]
local function verified_world(): any
    return {
        available = function(_self: any, quest: any): boolean
            return quest.BranchId == "HumanWarrior"
        end,
        verify = function(
            _self: any, user_id: number, event: any,
            quest: any, state: any
        ): boolean
            return quest.BranchId == "HumanWarrior"
                and event.ServerVerified == true
                and event.ActorUserId == user_id
                and state.BranchId == quest.BranchId
        end,
    }
end

--[[
Builds one unique source-stage event as if emitted by trusted world code.

Args:
    stage (number): Ordered source step in the actual saved quest.
    count (number): Separate physical monster life at this step.

Returns:
    any: A genuine per-life receipt shape for the isolated server fixture.
]]
local function event_for(stage: number, count: number): any
    local quest = assert(Sources.get("HumanWarrior"))
    local step = quest.Steps[stage]
    local proof = if stage == 3
        then {IronrootToken = true}
        elseif stage == 5 then {RidgebreakerSigil = true} else {}
    return {
        Kind = step.Kind, TargetId = step.TargetId,
        ActorUserId = USER_ID, ServerVerified = true,
        EventId = "IronrootWorld:" .. stage .. ":" .. count,
        MonsterReceiptId = if step.Kind == "QuestMonsterDefeat"
            then "IronrootEnemy:" .. stage .. ":" .. count else nil,
        VerifiedProofIds = proof,
    }
end

--[[
Creates the real saved Human Fighter and chooses the original Warrior path.

Args:
    profiles (any): Real exclusive in-memory profile writer.

Returns:
    nil: Starts a legitimate Base quest without awarding a new class.
]]
local function start_quest(profiles: any)
    check(profiles:load(USER_ID), "Character must have loaded profile")
    check(profiles:mutate(USER_ID, function(profile: any)
        local owner = profile.Characters.Slot1
        owner.Level = 18
        owner.Identity = {
            Version = 1, RaceId = "Human",
            BaseClassId = "Fighter", ClassId = "Fighter",
            CreationStage = "Complete",
        }
    end), "Create original Human Fighter in a disposable profile")
    check(Selection.new(profiles, "Base"):choose(
        USER_ID, "HumanWarrior"
    ).ok, "Original Warrior class choice is saved, not awarded")
end

--[[
Runs the personal monster-proof stages through actual quest transactions.

Args:
    profiles (any): Current exclusive personal profile service.
    service (any): Real server-first quest progression authority.

Returns:
    nil: Verifies separate enemy lives and actual bound item turn-ins.
]]
local function complete_quest(profiles: any, service: any)
    check(service:start(USER_ID).ok, "Quest can start with world adapter")
    check(service:record_world_event(
        USER_ID, event_for(2, 1)
    ).reason == "OriginalQuestWrongStage",
        "Cannot skip the first physical watch officer")
    for stage = 1, 2 do
        check(service:record_world_event(
            USER_ID, event_for(stage, 1)
        ).ok, "Ordered physical NPC stage accepted")
    end
    local first = event_for(3, 1)
    first.VerifiedProofIds = {}
    check(service:record_world_event(
        USER_ID, first
    ).reason == "OriginalQuestLootProofRequired",
        "A damage receipt without an earned marker is insufficient")
    for count = 1, 4 do
        local accepted = event_for(3, count)
        check(service:record_world_event(
            USER_ID, accepted
        ).ok, "Every distinct physical life grants one personal marker")
        check(service:record_world_event(
            USER_ID, accepted
        ).reason == "OriginalQuestEventAlreadyApplied",
            "Repeating identical monster event cannot grant extra markers")
    end
    local owner = assert(profiles:get_character(USER_ID))
    check(Inventory.count_item(
        owner, "ironroot_dispatch_marker"
    ) == 4 and owner.ClassAdvancement
        .OriginalFirstTransferQuest.Proofs.IronrootToken4 == true,
        "Four bound dispatch markers and proof belong to the actual owner")
    check(service:record_world_event(
        USER_ID, event_for(4, 1)
    ).ok, "Authentic Smith Orla receives four marked dispatches")
    check(Inventory.count_item(
        profiles:get_character(USER_ID), "ironroot_dispatch_marker"
    ) == 0, "Four consumed personal markers cannot be spent twice")
    local boss = event_for(5, 1)
    boss.VerifiedProofIds = {}
    check(service:record_world_event(
        USER_ID, boss
    ).reason == "OriginalQuestLootProofRequired",
        "Boss life without its unique recovered seal cannot progress")
    check(service:record_world_event(
        USER_ID, event_for(5, 1)
    ).ok, "Genuine unique boss life grants one personal oath seal")
    check(Inventory.count_item(
        profiles:get_character(USER_ID), "ridgebreaker_oath_seal"
    ) == 1, "Boss seal is actually held before final mentor turn-in")
    check(service:record_world_event(
        USER_ID, event_for(6, 1)
    ).ok, "Personal seal turn-in completes exactly the ordered quest")
    owner = assert(profiles:get_character(USER_ID))
    local state = owner.ClassAdvancement.OriginalFirstTransferQuest
    check(state.Ready == true and state.Step == 7
        and state.Proofs.IronrootToken4 == true
        and state.Proofs.RidgebreakerSigil == true,
        "Two distinct earned proofs survive a fully completed source quest")
    check(Inventory.count_item(owner, "ridgebreaker_oath_seal") == 0
        and owner.Identity.ClassId == "Fighter",
        "Completed source quest consumes seal without awarding class")
end

--[[
Checks that the genuine profile save/reload retains personal quest proofs.

Args:
    profiles (any): Exclusive writer with a fully completed source quest.

Returns:
    nil: Proves restart cannot regenerate or re-spend bound source items.
]]
local function verify_reload(profiles: any)
    check(profiles:save(USER_ID, "IronrootOriginalQuest"),
        "Completed first-transfer quest must be saved")
    check(profiles:release(USER_ID, "IronrootOriginalQuest"),
        "Exclusive character writer releases before reload")
    check(profiles:load(USER_ID), "Saved Warrior quest must reload")
    local state = QuestService.new(
        profiles, "Base", verified_world()
    ):build_snapshot(USER_ID)
    check(state.Ready == true and state.ClassAwarded == false,
        "Quest completion is persisted independently of class award")
    local character = profiles:get_character(USER_ID)
    check(Inventory.count_item(
        character, "ironroot_dispatch_marker"
    ) == 0 and Inventory.count_item(
        character, "ridgebreaker_oath_seal"
    ) == 0, "Spent bound items must never reappear on reload")
end

--[[
Executes the complete source quest in isolated actual profile services.

Args:
    None.

Returns:
    nil: Reports backend-only pass without claiming live client travel.
]]
local function main()
    local profiles = Profiles.new(Adapter.new())
    start_quest(profiles)
    local without_world = QuestService.new(profiles, "Base", nil)
    check(not without_world:start(USER_ID).ok,
        "Unbound production quest refuses an unsupported world")
    local service = QuestService.new(
        profiles, "Base", verified_world()
    )
    complete_quest(profiles, service)
    verify_reload(profiles)
    print(("[Ironvow Quest] PASS: %d assertions"):format(CHECKS))
end

main()
