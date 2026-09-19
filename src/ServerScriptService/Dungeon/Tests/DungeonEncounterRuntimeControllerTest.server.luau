--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local module = Dungeon:FindFirstChild(
    "DungeonEncounterRuntimeController"
)
if not module then
    error(
        "[Dungeon Encounter Runtime Controller Tests] RED: "
            .. "DungeonEncounterRuntimeController is missing."
    )
end

local Controller = require(module)
local InMemoryMapAdapter = require(
    Adapters:WaitForChild("InMemoryMapAdapter")
)
local DungeonSessionService = require(
    Services:WaitForChild("DungeonSessionService")
)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Encounter Runtime Controller Tests] "
                .. message,
            2
        )
    end
end

local now = 6000

local function clock(): number
    return now
end

local sessions = DungeonSessionService.new(
    InMemoryMapAdapter.new(clock),
    clock
)

local session = assert(
    sessions:create(
        "TestDungeon",
        {9201},
        100,
        "encounter-controller",
        "Depth1"
    )
)

assert(sessions:set_instance_state(session.SessionId, {
    EventActive = true,
    RareStateId = "OrdinaryState",
}).ok)
local base_sequence = {
    {
        Id = "CombatRoom1",
        RoomSlotId = "Room1",
        Kind = "Combat",
    },
    {
        Id = "CombatRoom2",
        RoomSlotId = "Room2",
        Kind = "Combat",
    },
    {
        Id = "Depth1Boss",
        RoomSlotId = "Room3",
        Kind = "Boss",
        BossId = "MarauderCaptain",
    },
}

local optional_encounters = {
    {
        InsertAfterId = "CombatRoom1",
        Activation = {
            Type = "InstanceFlag",
            Key = "EventActive",
            Value = true,
        },
        CompletionRequired = true,
        Encounter = {
            Id = "FestivalChampion",
            RoomSlotId = "EventArena",
            Kind = "EventBoss",
            BossId = "FestivalChampion",
        },
    },
    {
        InsertBeforeId = "Depth1Boss",
        Activation = {
            Type = "RareState",
            Id = "HiddenCrypt",
        },
        CompletionRequired = false,
        Encounter = {
            Id = "CryptGuardian",
            RoomSlotId = "SecretRoom",
            Kind = "SecretBoss",
            BossId = "CryptGuardian",
        },
    },
}

local controller = assert(Controller.new({
    session_service = sessions,
    session_id = session.SessionId,
    base_sequence = base_sequence,
    optional_encounters = optional_encounters,
}))

local encounters = controller:encounters()
check(#encounters == 4, "Active event boss must be inserted.")
check(
    encounters[2].Id == "FestivalChampion",
    "Event boss must appear immediately after its anchor."
)
check(
    controller:find_by_room_slot("EventArena").Kind == "EventBoss",
    "Runtime must expose inserted encounter by room slot."
)
check(
    controller:find_by_room_slot("SecretRoom") == nil,
    "Inactive secret encounter must be absent from the run."
)

check(
    controller:start("CombatRoom1").ok == true,
    "First encounter must start."
)
check(
    controller:clear("CombatRoom1").next_encounter_id
        == "FestivalChampion",
    "Event boss must become the next required encounter."
)
check(
    controller:start("CombatRoom2").reason
        == "EncounterOutOfOrder",
    "Later room cannot bypass an inserted required event boss."
)

check(
    controller:start("FestivalChampion").ok == true,
    "Inserted event boss must start normally."
)
local cancelled = controller:cancel_active("FestivalChampion")
check(
    cancelled.ok == true
        and controller:state_of("FestivalChampion") == "Pending",
    "Runtime cancel must return active encounter to Pending."
)
local cancelled_session = assert(sessions:get(session.SessionId))
check(
    cancelled_session.InstanceState.EncounterRuntime.ActiveEncounterId == nil
        and cancelled_session.InstanceState.EncounterRuntime.NextEncounterId
            == "FestivalChampion",
    "Runtime cancel must persist the rollback snapshot."
)
check(
    controller:start("FestivalChampion").ok == true,
    "Cancelled event boss must restart normally."
)

local latest = assert(sessions:get(session.SessionId))
check(
    latest.InstanceState.EncounterRuntime.ActiveEncounterId
        == "FestivalChampion",
    "Active inserted encounter must persist for reconnect."
)

local reconnect = assert(Controller.new({
    session_service = sessions,
    session_id = session.SessionId,
    base_sequence = base_sequence,
    optional_encounters = optional_encounters,
}))

check(
    reconnect:next_id() == "FestivalChampion",
    "Reconnect must restart the interrupted event encounter."
)
check(
    reconnect:state_of("CombatRoom1") == "Cleared",
    "Reconnect must preserve earlier clears."
)
check(
    reconnect:state_of("FestivalChampion") == "Pending",
    "Interrupted active encounter must restart as pending."
)
local persisted_recovery = assert(sessions:get(session.SessionId))
check(
    persisted_recovery.InstanceState.EncounterRuntime.EncounterStates.FestivalChampion
        == "Pending"
        and persisted_recovery.InstanceState.EncounterRuntime.ActiveEncounterId == nil,
    "Interrupted encounter rollback must be saved before trigger checks."
)

check(
    reconnect:start("FestivalChampion").ok == true,
    "Restarted event encounter must start again."
)
check(
    reconnect:clear("FestivalChampion").next_encounter_id
        == "CombatRoom2",
    "Flow must continue to the next ordinary room."
)
check(reconnect:start("CombatRoom2").ok == true, "Room 2 must start.")
check(reconnect:clear("CombatRoom2").ok == true, "Room 2 must clear.")
check(reconnect:start("Depth1Boss").ok == true, "Final boss must start.")

local final_clear = reconnect:clear("Depth1Boss")
check(final_clear.ok == true, "Final boss must clear.")
check(
    final_clear.complete == true
        and reconnect:is_complete() == true,
    "All required encounters must complete the run."
)

print(string.format(
    "[Dungeon Encounter Runtime Controller Tests] PASS: %d assertions.",
    assertion_count
))
