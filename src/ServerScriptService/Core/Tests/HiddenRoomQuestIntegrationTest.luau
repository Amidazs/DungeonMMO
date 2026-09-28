--!strict
-- Real-service acceptance for interaction + hidden-room item collection quests.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local Core = ServerScriptService.Core

local ProfileAdapter = require(Core.Adapters.InMemoryProfileAdapter)
local MapAdapter = require(Core.Adapters.InMemoryMapAdapter)
local Profiles = require(Core.Services.ProfileService)
local Sessions = require(Core.Services.DungeonSessionService)
local Quests = require(Core.Services.QuestService)
local Inventory = require(Core.Services.InventoryService)
local QuestObjects = require(Core.Services.DungeonQuestObjectService)
local Definitions = require(Shared.QuestDefinitions)

local USER_ONE = 967101
local USER_TWO = 967102
local checks = 0

--[[
Counts one hidden-room quest assertion.

Args:
    condition (boolean): Expected authoritative result.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Hidden Room Quest Integration] " .. label)
end

--[[
Installs one eligible launch character and starts the hidden-room Adventure.

Args:
    profiles (any): Loaded ProfileService.
    quests (any): Authoritative QuestService.
    user_id (number): Disposable profile owner.

Returns:
    nil: Mutates only the disposable test profile.
]]
local function install_character(
    profiles: any,
    quests: any,
    user_id: number
)
    check(
        profiles:load(user_id),
        "profile loads for " .. tostring(user_id)
    )
    check(
        profiles:mutate(user_id, function(profile: any)
            local character = profile.Characters.Slot1
            character.Level = 6
            character.Identity = {
                Version = 1,
                RaceId = "Human",
                BaseClassId = "Fighter",
                ClassId = "Fighter",
                CreationStage = "Complete",
            }
            character.Quests = {
                Version = 1,
                Active = {},
                Completed = {
                    WorldrootRelic = true,
                },
            }
        end),
        "eligible character installs"
    )
    check(
        quests:start(user_id, "HiddenWardDiscovery").ok,
        "hidden-room Adventure starts"
    )
end

--[[
Returns one active hidden-room quest snapshot.

Args:
    quests (any): Authoritative QuestService.
    user_id (number): Quest owner.

Returns:
    any: Active HiddenWardDiscovery state.
]]
local function quest_state(
    quests: any,
    user_id: number
): any
    local snapshot = quests:build_snapshot(user_id)
    return assert(snapshot.Active.HiddenWardDiscovery)
end

--[[
Runs the party interaction, personal collection, turn-in and persistence path.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all assertions succeed.
]]
local function main()
    local profile_adapter = ProfileAdapter.new()
    local profiles = Profiles.new(profile_adapter)
    local quests = Quests.new(profiles)

    install_character(profiles, quests, USER_ONE)
    install_character(profiles, quests, USER_TWO)

    local now = 200
    local sessions = Sessions.new(
        MapAdapter.new(function()
            return now
        end),
        function()
            return now
        end
    )
    local session = assert(sessions:create(
        "TestDungeon",
        {USER_ONE, USER_TWO},
        0,
        "hidden-room-test",
        "Depth1"
    ))
    check(
        sessions:mark_connected(
            session.SessionId,
            USER_ONE
        ).ok,
        "first party member connects"
    )
    check(
        sessions:mark_connected(
            session.SessionId,
            USER_TWO
        ).ok,
        "second party member connects"
    )
    check(
        sessions:set_instance_state(session.SessionId, {
            EncounterRuntime = {
                EncounterStates = {
                    CombatRoom1 = "Pending",
                    CombatRoom2 = "Pending",
                    MarauderCaptain = "Pending",
                },
            },
        }).ok,
        "initial encounter state saves"
    )

    local service = QuestObjects.new(
        sessions,
        profiles,
        quests
    )

    local early = service:activate(
        session.SessionId,
        USER_ONE,
        "TempleHiddenPanel",
        2
    )
    check(
        early.ok == false
            and early.reason == "QuestInteractionUnavailable",
        "panel cannot activate before Room 1 clears"
    )

    local pre_collect = service:collect(
        session.SessionId,
        USER_ONE,
        "TempleHiddenWardFragment",
        2
    )
    check(
        pre_collect.ok == false
            and pre_collect.reason == "QuestInteractionRequired",
        "fragment cannot be collected through the sealed room"
    )

    check(
        sessions:update_instance_state(
            session.SessionId,
            function(state: any): (any, any?)
                state.EncounterRuntime.EncounterStates
                    .CombatRoom1 = "Cleared"
                return state, {ok = true}
            end
        ).ok,
        "Room 1 clear state saves"
    )

    local far = service:activate(
        session.SessionId,
        USER_ONE,
        "TempleHiddenPanel",
        13
    )
    check(
        far.ok == false
            and far.reason == "QuestInteractionOutOfRange",
        "distant panel activation is rejected"
    )

    local activated = service:activate(
        session.SessionId,
        USER_ONE,
        "TempleHiddenPanel",
        2
    )
    check(
        activated.ok == true
            and activated.already_activated == false
            and activated.recipient_count == 2,
        "one party interaction opens the room for both active quest owners"
    )
    check(
        quest_state(
            quests,
            USER_ONE
        ).Objectives.ActivateHiddenPanel == 1
            and quest_state(
                quests,
                USER_TWO
            ).Objectives.ActivateHiddenPanel == 1,
        "shared panel activation progresses both party members once"
    )

    local replay = service:activate(
        session.SessionId,
        USER_TWO,
        "TempleHiddenPanel",
        1
    )
    check(
        replay.ok == true
            and replay.already_activated == true,
        "panel replay is idempotent"
    )

    local first_collect = service:collect(
        session.SessionId,
        USER_ONE,
        "TempleHiddenWardFragment",
        2
    )
    check(
        first_collect.ok == true
            and first_collect.already_collected == false,
        "first player collects personal hidden fragment"
    )

    local first_character = assert(
        profiles:get_character(USER_ONE, 1)
    )
    check(
        Inventory.count_item(
            first_character,
            "hidden_ward_fragment"
        ) == 1
            and quest_state(
                quests,
                USER_ONE
            ).Ready == true,
        "personal item enters inventory and readies the quest"
    )
    check(
        quest_state(
            quests,
            USER_TWO
        ).Objectives.CollectHiddenWardFragment == 0,
        "one player's collectible does not complete another player's item goal"
    )

    local duplicate_collect = service:collect(
        session.SessionId,
        USER_ONE,
        "TempleHiddenWardFragment",
        1
    )
    check(
        duplicate_collect.ok == true
            and duplicate_collect.already_collected == true
            and Inventory.count_item(
                assert(profiles:get_character(USER_ONE, 1)),
                "hidden_ward_fragment"
            ) == 1,
        "collectible replay never duplicates the quest item"
    )

    local inventory = Inventory.new(profiles)
    check(
        inventory:consume_item(
            USER_ONE,
            "hidden_ward_fragment",
            1
        ).ok,
        "test removes the turn-in item"
    )
    check(
        quests:claim_reward(
            USER_ONE,
            "HiddenWardDiscovery"
        ).reason == "QuestTurnInItemsMissing",
        "claim fails when the collected item is no longer owned"
    )
    check(
        inventory:add_item(
            USER_ONE,
            "hidden_ward_fragment",
            1
        ).ok,
        "turn-in item is restored"
    )

    local claimed = quests:claim_reward(
        USER_ONE,
        "HiddenWardDiscovery"
    )
    check(
        claimed.ok == true
            and claimed.gold_granted == 50
            and #claimed.items_granted == 1,
        "hidden-room Adventure reward claims atomically"
    )

    first_character = assert(
        profiles:get_character(USER_ONE, 1)
    )
    check(
        Inventory.count_item(
            first_character,
            "hidden_ward_fragment"
        ) == 0
            and Inventory.count_item(
                first_character,
                "warding_essence"
            ) == 1
            and first_character.Gold == 50,
        "quest item is consumed and reward item replaces it"
    )

    check(
        service:collect(
            session.SessionId,
            USER_TWO,
            "TempleHiddenWardFragment",
            2
        ).ok,
        "second party member can collect their own fragment"
    )
    check(
        quest_state(
            quests,
            USER_TWO
        ).Ready == true,
        "second party member independently readies the quest"
    )

    check(
        profiles:save(
            USER_ONE,
            "HiddenRoomQuestIntegration"
        ),
        "completed hidden-room quest saves"
    )
    local restored = Profiles.new(profile_adapter)
    check(restored:load(USER_ONE), "completed profile reloads")

    local restored_character = assert(
        restored:get_character(USER_ONE, 1)
    )
    check(
        restored_character.Quests.Completed.HiddenWardDiscovery == true
            and Inventory.count_item(
                restored_character,
                "hidden_ward_fragment"
            ) == 0
            and Inventory.count_item(
                restored_character,
                "warding_essence"
            ) == 1,
        "completion, turn-in and reward persist after reload"
    )

    local definition = assert(
        Definitions.get("HiddenWardDiscovery")
    )
    check(
        definition.MinimumLevel == 6
            and definition.PrerequisiteQuestId == "WorldrootRelic"
            and definition.Objectives[1].Type == "WorldInteraction"
            and definition.Objectives[2].Type == "ItemCollected",
        "definition preserves the intended interaction-plus-collection pattern"
    )

    print(
        ("[Hidden Room Quest Integration] PASS: %d assertions")
            :format(checks)
    )
end

main()
