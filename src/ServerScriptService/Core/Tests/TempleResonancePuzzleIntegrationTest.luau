--!strict
-- Real-service acceptance for the Temple resonance item + puzzle Adventure.

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
local Puzzles = require(Core.Services.DungeonPuzzleService)

local USER_ONE = 967301
local USER_TWO = 967302
local checks = 0

local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Temple Resonance Puzzle] " .. label)
end

local function install_character(
    profiles: any,
    quests: any,
    user_id: number
)
    check(profiles:load(user_id), "profile loads")

    check(
        profiles:mutate(user_id, function(profile: any)
            local character = profile.Characters.Slot1
            character.Level = 11
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
                    RuinSurvey = true,
                },
            }
        end),
        "eligible level-eleven character installs"
    )

    check(
        quests:start(user_id, "TempleResonancePuzzle").ok,
        "Resonant Seal Adventure starts"
    )
end

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

local function quest_state(
    quests: any,
    user_id: number
): any
    local snapshot = quests:build_snapshot(user_id)
    return assert(snapshot.Active.TempleResonancePuzzle)
end

local function item_count(
    profiles: any,
    user_id: number,
    item_id: string
): number
    local character = assert(
        profiles:get_character(user_id, 1)
    )
    return Inventory.count_item(character, item_id)
end

local function main()
    local profile_adapter = ProfileAdapter.new()
    local profiles = Profiles.new(profile_adapter)
    local quests = Quests.new(profiles)

    install_character(profiles, quests, USER_ONE)
    install_character(profiles, quests, USER_TWO)

    local now = 400
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
        "resonance-puzzle-test",
        "Depth1"
    ))

    check(
        sessions:mark_connected(
            session.SessionId,
            USER_ONE
        ).ok,
        "first puzzle party member connects"
    )
    check(
        sessions:mark_connected(
            session.SessionId,
            USER_TWO
        ).ok,
        "second puzzle party member connects"
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

    local quest_objects = QuestObjects.new(
        sessions,
        profiles,
        quests
    )
    local puzzles = Puzzles.new(
        sessions,
        profiles,
        quests
    )

    local early_collect = quest_objects:collect(
        session.SessionId,
        USER_ONE,
        "TempleResonanceShard",
        2
    )
    check(
        early_collect.ok == false
            and early_collect.reason
                == "QuestCollectiblePrerequisiteIncomplete",
        "shard cannot be collected before Room 1 clears"
    )

    set_encounter(
        sessions,
        session.SessionId,
        "CombatRoom1",
        "Cleared"
    )

    local far_collect = quest_objects:collect(
        session.SessionId,
        USER_ONE,
        "TempleResonanceShard",
        11
    )
    check(
        far_collect.ok == false
            and far_collect.reason
                == "QuestCollectibleOutOfRange",
        "remote shard collection is rejected"
    )

    check(
        quest_objects:collect(
            session.SessionId,
            USER_ONE,
            "TempleResonanceShard",
            2
        ).ok,
        "first player collects the bound resonance shard"
    )
    check(
        item_count(
            profiles,
            USER_ONE,
            "temple_resonance_shard"
        ) == 1
            and quest_state(
                quests,
                USER_ONE
            ).Objectives.CollectResonanceShard == 1,
        "personal shard collection updates inventory and quest"
    )

    local early_press = puzzles:press(
        session.SessionId,
        USER_ONE,
        "TempleResonanceLock",
        "MoonRune",
        2
    )
    check(
        early_press.ok == false
            and early_press.reason
                == "PuzzlePrerequisiteIncomplete",
        "runes cannot be solved while Room 2 is dangerous"
    )

    set_encounter(
        sessions,
        session.SessionId,
        "CombatRoom2",
        "Cleared"
    )

    local no_item = puzzles:press(
        session.SessionId,
        USER_TWO,
        "TempleResonanceLock",
        "MoonRune",
        2
    )
    check(
        no_item.ok == false
            and no_item.reason == "PuzzleQuestItemRequired",
        "party member without the resonance shard cannot drive puzzle state"
    )

    local far_press = puzzles:press(
        session.SessionId,
        USER_ONE,
        "TempleResonanceLock",
        "MoonRune",
        11
    )
    check(
        far_press.ok == false
            and far_press.reason == "PuzzleRuneOutOfRange",
        "remote rune activation is rejected"
    )

    local wrong_first = puzzles:press(
        session.SessionId,
        USER_ONE,
        "TempleResonanceLock",
        "FlameRune",
        2
    )
    check(
        wrong_first.ok == true
            and wrong_first.reset == true,
        "wrong first rune resets the ordered sequence"
    )

    local status = puzzles:status(
        session.SessionId,
        "TempleResonanceLock"
    )
    check(
        status.ok == true
            and status.next_index == 1
            and status.reset_count == 1,
        "reset state persists server-side"
    )

    check(
        puzzles:press(
            session.SessionId,
            USER_ONE,
            "TempleResonanceLock",
            "MoonRune",
            2
        ).ok,
        "Moon rune advances sequence"
    )

    local wrong_second = puzzles:press(
        session.SessionId,
        USER_ONE,
        "TempleResonanceLock",
        "FlameRune",
        2
    )
    check(
        wrong_second.ok == true
            and wrong_second.reset == true,
        "wrong second rune also resets the sequence"
    )

    for _, rune_id in ipairs({
        "MoonRune",
        "RootRune",
        "FlameRune",
    }) do
        local pressed = puzzles:press(
            session.SessionId,
            USER_ONE,
            "TempleResonanceLock",
            rune_id,
            2
        )
        check(
            pressed.ok == true,
            rune_id .. " accepts in correct sequence"
        )
    end

    status = puzzles:status(
        session.SessionId,
        "TempleResonanceLock"
    )
    check(
        status.ok == true
            and status.completed == true,
        "correct ordered sequence persists completion"
    )

    check(
        quest_state(
            quests,
            USER_ONE
        ).Ready == true,
        "first player has both item and puzzle objectives"
    )
    check(
        quest_state(
            quests,
            USER_TWO
        ).Objectives.SolveResonanceLock == 1
            and quest_state(
                quests,
                USER_TWO
            ).Ready == false,
        "shared puzzle credits party objective but not missing personal item"
    )

    local replay = puzzles:press(
        session.SessionId,
        USER_ONE,
        "TempleResonanceLock",
        "MoonRune",
        1
    )
    check(
        replay.ok == true
            and replay.completed == true
            and replay.already_completed == true,
        "completed puzzle replay is idempotent"
    )

    check(
        quest_objects:collect(
            session.SessionId,
            USER_TWO,
            "TempleResonanceShard",
            2
        ).ok,
        "second player can collect their personal shard later"
    )
    check(
        quest_state(
            quests,
            USER_TWO
        ).Ready == true,
        "late personal shard collection readies second party quest"
    )

    local claimed = quests:claim_reward(
        USER_ONE,
        "TempleResonancePuzzle"
    )
    check(
        claimed.ok == true
            and claimed.gold_granted == 75
            and #claimed.items_granted == 1,
        "Resonant Seal claims its mixed reward"
    )

    local character = assert(
        profiles:get_character(USER_ONE, 1)
    )
    check(
        Inventory.count_item(
            character,
            "temple_resonance_shard"
        ) == 0
            and Inventory.count_item(
                character,
                "resonant_rune"
            ) == 1
            and character.Gold == 75,
        "turn-in consumes shard and grants one Resonant Rune"
    )

    check(
        profiles:save(
            USER_ONE,
            "TempleResonancePuzzle"
        ),
        "puzzle completion saves"
    )
    local restored = Profiles.new(profile_adapter)
    check(restored:load(USER_ONE), "puzzle profile reloads")

    local restored_character = assert(
        restored:get_character(USER_ONE, 1)
    )
    check(
        restored_character.Quests.Completed
            .TempleResonancePuzzle == true
            and Inventory.count_item(
                restored_character,
                "temple_resonance_shard"
            ) == 0
            and Inventory.count_item(
                restored_character,
                "resonant_rune"
            ) == 1,
        "puzzle quest and turn-in persist after reload"
    )

    print(
        ("[Temple Resonance Puzzle] PASS: %d assertions")
            :format(checks)
    )
end

main()
