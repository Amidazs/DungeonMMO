--!strict
-- Real-service acceptance for the Lost Surveyor escort quest lifecycle.

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
local Escorts = require(Core.Services.DungeonEscortService)
local Definitions = require(Shared.QuestDefinitions)

local USER_ONE = 967201
local USER_TWO = 967202
local checks = 0

--[[
Counts one escort integration assertion.

Args:
    condition (boolean): Expected authoritative result.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Lost Surveyor Integration] " .. label)
end

--[[
Installs one level-nine launch character with Mine Echoes completed.

Args:
    profiles (any): Loaded ProfileService.
    quests (any): Authoritative QuestService.
    user_id (number): Disposable profile owner.

Returns:
    nil: Creates an eligible active escort quest.
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
            character.Level = 9
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
                    MineEchoes = true,
                },
            }
        end),
        "eligible escort character installs"
    )
    check(
        quests:start(user_id, "MineSurveyorEscort").ok,
        "Lost Surveyor Adventure starts"
    )
end

--[[
Sets one persisted encounter state in the disposable dungeon session.

Args:
    sessions (any): Authoritative DungeonSessionService.
    session_id (string): Disposable session identifier.
    encounter_id (string): Encounter state to change.
    value (string): New trusted encounter state.

Returns:
    nil: Raises when the state update fails.
]]
local function set_encounter(
    sessions: any,
    session_id: string,
    encounter_id: string,
    value: string
)
    local updated = sessions:update_instance_state(
        session_id,
        function(state: any): (any, any?)
            state.EncounterRuntime =
                state.EncounterRuntime or {}
            state.EncounterRuntime.EncounterStates =
                state.EncounterRuntime.EncounterStates or {}
            state.EncounterRuntime.EncounterStates[
                encounter_id
            ] = value

            return state, {ok = true}
        end
    )
    check(updated.ok == true, encounter_id .. " state saves")
end

--[[
Returns the active Lost Surveyor quest state.

Args:
    quests (any): Authoritative QuestService.
    user_id (number): Quest owner.

Returns:
    any: Active MineSurveyorEscort state.
]]
local function quest_state(
    quests: any,
    user_id: number
): any
    local snapshot = quests:build_snapshot(user_id)
    return assert(snapshot.Active.MineSurveyorEscort)
end

--[[
Runs start, safe-pause, completion, replay, reward and persistence checks.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after the escort contract succeeds.
]]
local function main()
    local profile_adapter = ProfileAdapter.new()
    local profiles = Profiles.new(profile_adapter)
    local quests = Quests.new(profiles)

    install_character(profiles, quests, USER_ONE)
    install_character(profiles, quests, USER_TWO)

    local now = 300
    local sessions = Sessions.new(
        MapAdapter.new(function()
            return now
        end),
        function()
            return now
        end
    )
    local session = assert(sessions:create(
        "AbandonedMine",
        {USER_ONE, USER_TWO},
        0,
        "lost-surveyor-test",
        "Depth1"
    ))

    check(
        sessions:mark_connected(
            session.SessionId,
            USER_ONE
        ).ok,
        "first escort party member connects"
    )
    check(
        sessions:mark_connected(
            session.SessionId,
            USER_TWO
        ).ok,
        "second escort party member connects"
    )

    set_encounter(
        sessions,
        session.SessionId,
        "CombatRoom1",
        "Pending"
    )
    set_encounter(
        sessions,
        session.SessionId,
        "CombatRoom2",
        "Pending"
    )

    local escorts = Escorts.new(sessions, quests)

    local early = escorts:start(
        session.SessionId,
        USER_ONE,
        "MineSurveyor",
        2
    )
    check(
        early.ok == false
            and early.reason == "EscortStartEncounterIncomplete",
        "escort cannot begin before Room 1 is safe"
    )

    set_encounter(
        sessions,
        session.SessionId,
        "CombatRoom1",
        "Cleared"
    )

    local far = escorts:start(
        session.SessionId,
        USER_ONE,
        "MineSurveyor",
        13
    )
    check(
        far.ok == false
            and far.reason == "EscortStartOutOfRange",
        "remote escort start is rejected"
    )

    local started = escorts:start(
        session.SessionId,
        USER_ONE,
        "MineSurveyor",
        2
    )
    check(
        started.ok == true
            and started.already_started == false
            and started.recipient_count == 2,
        "one nearby party member starts the shared escort"
    )

    local replay_start = escorts:start(
        session.SessionId,
        USER_TWO,
        "MineSurveyor",
        2
    )
    check(
        replay_start.ok == true
            and replay_start.already_started == true,
        "second start is idempotent"
    )

    check(
        escorts:set_phase(
            session.SessionId,
            "MineSurveyor",
            "WaitingForRoom2"
        ).ok,
        "server runtime may persist the safe waiting phase"
    )

    local status = escorts:status(
        session.SessionId,
        "MineSurveyor"
    )
    check(
        status.ok == true
            and status.started == true
            and status.completed == false
            and status.phase == "WaitingForRoom2",
        "escort state is recoverable while waiting"
    )

    local premature = escorts:complete(
        session.SessionId,
        "MineSurveyor"
    )
    check(
        premature.ok == false
            and premature.reason
                == "EscortFinishEncounterIncomplete",
        "escort cannot finish while Room 2 is dangerous"
    )

    check(
        quest_state(
            quests,
            USER_ONE
        ).Ready == false
            and quest_state(
                quests,
                USER_TWO
            ).Ready == false,
        "safe-pause state grants no quest completion"
    )

    set_encounter(
        sessions,
        session.SessionId,
        "CombatRoom2",
        "Cleared"
    )
    check(
        escorts:set_phase(
            session.SessionId,
            "MineSurveyor",
            "ToFinish"
        ).ok,
        "server runtime resumes only after Room 2 clears"
    )

    local completed = escorts:complete(
        session.SessionId,
        "MineSurveyor"
    )
    check(
        completed.ok == true
            and completed.already_completed == false
            and completed.recipient_count == 2,
        "safe destination completion credits both quest owners"
    )

    check(
        quest_state(
            quests,
            USER_ONE
        ).Ready == true
            and quest_state(
                quests,
                USER_TWO
            ).Ready == true,
        "trusted EscortCompleted event readies both party quests"
    )

    local replay_complete = escorts:complete(
        session.SessionId,
        "MineSurveyor"
    )
    check(
        replay_complete.ok == true
            and replay_complete.already_completed == true,
        "escort completion replay remains idempotent"
    )

    local claimed = quests:claim_reward(
        USER_ONE,
        "MineSurveyorEscort"
    )
    check(
        claimed.ok == true
            and claimed.gold_granted == 70
            and #claimed.items_granted == 1,
        "Lost Surveyor grants the reviewed mixed reward"
    )

    local character = assert(
        profiles:get_character(USER_ONE, 1)
    )
    check(
        character.Gold == 70
            and Inventory.count_item(
                character,
                "deep_iron_ore"
            ) == 2,
        "escort reward grants exactly two Deep Iron Ore"
    )

    check(
        profiles:save(
            USER_ONE,
            "LostSurveyorIntegration"
        ),
        "escort completion saves"
    )
    local restored = Profiles.new(profile_adapter)
    check(restored:load(USER_ONE), "escort profile reloads")

    local restored_character = assert(
        restored:get_character(USER_ONE, 1)
    )
    check(
        restored_character.Quests.Completed.MineSurveyorEscort
            == true
            and restored_character.Gold == 70
            and Inventory.count_item(
                restored_character,
                "deep_iron_ore"
            ) == 2,
        "escort completion and reward persist after reload"
    )

    local definition = assert(
        Definitions.get("MineSurveyorEscort")
    )
    check(
        definition.MinimumLevel == 9
            and definition.PrerequisiteQuestId == "MineEchoes"
            and definition.Objectives[1].Type
                == "EscortCompleted",
        "definition preserves the intended escort pattern"
    )

    print(
        ("[Lost Surveyor Integration] PASS: %d assertions")
            :format(checks)
    )
end

main()
