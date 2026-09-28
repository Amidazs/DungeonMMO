--!strict
-- Real-service acceptance for the Temple defend/survive Adventure.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService.Core

local ProfileAdapter = require(Core.Adapters.InMemoryProfileAdapter)
local MapAdapter = require(Core.Adapters.InMemoryMapAdapter)
local Profiles = require(Core.Services.ProfileService)
local Sessions = require(Core.Services.DungeonSessionService)
local Quests = require(Core.Services.QuestService)
local Inventory = require(Core.Services.InventoryService)
local Defenses = require(Core.Services.DungeonDefenseService)

local USER_ONE = 967401
local USER_TWO = 967402
local checks = 0

local function check(
    condition: boolean,
    label: string
)
    checks += 1
    assert(condition, "[Temple Ward Defense] " .. label)
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
            character.Level = 13
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
                    TempleResonancePuzzle = true,
                },
            }
        end),
        "eligible level-thirteen character installs"
    )

    check(
        quests:start(user_id, "TempleWardDefense").ok,
        "Hold the Resonance Adventure starts"
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
    return assert(snapshot.Active.TempleWardDefense)
end

local function main()
    local profile_adapter = ProfileAdapter.new()
    local profiles = Profiles.new(profile_adapter)
    local quests = Quests.new(profiles)

    install_character(profiles, quests, USER_ONE)
    install_character(profiles, quests, USER_TWO)

    local now = 500
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
        "ward-defense-test",
        "Depth1"
    ))

    check(
        sessions:mark_connected(
            session.SessionId,
            USER_ONE
        ).ok,
        "first defense party member connects"
    )
    check(
        sessions:mark_connected(
            session.SessionId,
            USER_TWO
        ).ok,
        "second defense party member connects"
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

    local defenses = Defenses.new(sessions, quests)

    local early = defenses:start(
        session.SessionId,
        USER_ONE,
        "TempleResonanceWard",
        2
    )
    check(
        early.ok == false
            and early.reason == "DefenseStartEncounterIncomplete",
        "ward defense cannot start before Room 1 is safe"
    )

    set_encounter(
        sessions,
        session.SessionId,
        "CombatRoom1",
        "Cleared"
    )

    local far = defenses:start(
        session.SessionId,
        USER_ONE,
        "TempleResonanceWard",
        11
    )
    check(
        far.ok == false
            and far.reason == "DefenseStartOutOfRange",
        "remote defense start is rejected"
    )

    local started = defenses:start(
        session.SessionId,
        USER_ONE,
        "TempleResonanceWard",
        2
    )
    check(
        started.ok == true
            and started.already_started == false,
        "nearby quest owner starts the defense"
    )

    local duplicate = defenses:start(
        session.SessionId,
        USER_TWO,
        "TempleResonanceWard",
        2
    )
    check(
        duplicate.ok == true
            and duplicate.already_started == true,
        "duplicate party start is idempotent"
    )

    local invalid_tick = defenses:tick(
        session.SessionId,
        "TempleResonanceWard",
        1.25,
        {USER_ONE}
    )
    check(
        invalid_tick.ok == false
            and invalid_tick.reason == "InvalidDefenseTick",
        "oversized fabricated heartbeat is rejected"
    )

    local occupied = defenses:tick(
        session.SessionId,
        "TempleResonanceWard",
        0.5,
        {USER_ONE}
    )
    check(
        occupied.ok == true
            and occupied.occupied == true,
        "active holder advances server defense state"
    )

    for _ = 1, 3 do
        local grace = defenses:tick(
            session.SessionId,
            "TempleResonanceWard",
            0.75,
            {}
        )
        check(
            grace.ok == true
                and grace.reset ~= true,
            "short ward absence stays inside grace window"
        )
    end

    local grace_status = defenses:status(
        session.SessionId,
        "TempleResonanceWard"
    )
    check(
        grace_status.ok == true
            and grace_status.started == true
            and grace_status.unheld_seconds == 2.25,
        "grace time persists without instant failure"
    )

    local reset = defenses:tick(
        session.SessionId,
        "TempleResonanceWard",
        1,
        {}
    )
    check(
        reset.ok == true
            and reset.reset == true,
        "abandoning ward beyond grace resets defense"
    )

    local reset_status = defenses:status(
        session.SessionId,
        "TempleResonanceWard"
    )
    check(
        reset_status.started == false
            and reset_status.failure_count == 1
            and reset_status.held_seconds == 0,
        "failed defense remains restartable with persisted failure count"
    )

    local restarted = defenses:start(
        session.SessionId,
        USER_TWO,
        "TempleResonanceWard",
        1
    )
    check(
        restarted.ok == true
            and restarted.already_started == false,
        "party can restart after a grace-window failure"
    )

    set_encounter(
        sessions,
        session.SessionId,
        "CombatRoom2",
        "Active"
    )

    check(
        defenses:tick(
            session.SessionId,
            "TempleResonanceWard",
            0.5,
            {USER_ONE, USER_TWO}
        ).occupied == true,
        "multiple active holders count as one occupied defense state"
    )

    set_encounter(
        sessions,
        session.SessionId,
        "CombatRoom2",
        "Cleared"
    )

    local completed = defenses:tick(
        session.SessionId,
        "TempleResonanceWard",
        0.25,
        {USER_ONE}
    )
    check(
        completed.ok == true
            and completed.completed == true
            and completed.recipient_count == 2,
        "normal Room-2 clear completes held defense for both quest owners"
    )

    check(
        quest_state(quests, USER_ONE).Ready == true
            and quest_state(quests, USER_TWO).Ready == true,
        "trusted DefenseCompleted event readies both party quests"
    )

    local replay = defenses:tick(
        session.SessionId,
        "TempleResonanceWard",
        0.25,
        {USER_ONE}
    )
    check(
        replay.ok == true
            and replay.completed == true
            and replay.already_completed == true,
        "completed defense heartbeat is idempotent"
    )

    local claimed = quests:claim_reward(
        USER_ONE,
        "TempleWardDefense"
    )
    check(
        claimed.ok == true
            and claimed.gold_granted == 85
            and #claimed.items_granted == 1,
        "Hold the Resonance grants its reviewed mixed reward"
    )

    local character = assert(
        profiles:get_character(USER_ONE, 1)
    )
    check(
        character.Gold == 85
            and Inventory.count_item(
                character,
                "warding_essence"
            ) == 1,
        "defense reward grants exactly one Warding Essence"
    )

    check(
        profiles:save(USER_ONE, "TempleWardDefense"),
        "defense completion saves"
    )
    local restored = Profiles.new(profile_adapter)
    check(restored:load(USER_ONE), "defense profile reloads")

    local restored_character = assert(
        restored:get_character(USER_ONE, 1)
    )
    check(
        restored_character.Quests.Completed.TempleWardDefense
            == true
            and restored_character.Gold == 85
            and Inventory.count_item(
                restored_character,
                "warding_essence"
            ) == 1,
        "defense completion and reward persist after reload"
    )

    print(
        ("[Temple Ward Defense] PASS: %d assertions")
            :format(checks)
    )
end

main()
