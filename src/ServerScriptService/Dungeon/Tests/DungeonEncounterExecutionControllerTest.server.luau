--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local module = Dungeon:FindFirstChild(
    "DungeonEncounterExecutionController"
)
if not module then
    error(
        "[Dungeon Encounter Execution Controller Tests] RED: "
            .. "DungeonEncounterExecutionController is missing."
    )
end

local Controller = require(module)
local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Encounter Execution Controller Tests] "
                .. message,
            2
        )
    end
end

local flow_calls = {}
local flow: any = {}

local bindings = {
    Room1 = {
        RoomSlotId = "Room1",
        PlanEncounterId = "CombatRoom1",
        RuntimeEncounterId = "CombatRoom1",
        Encounter = {
            Id = "CombatRoom1",
            Kind = "Combat",
            ExecutorId = "CombatPack",
            PackId = "StandardRoom1",
        },
    },
    FutureBoss = {
        RoomSlotId = "FutureBoss",
        PlanEncounterId = "FutureBoss",
        RuntimeEncounterId = "FutureBoss",
        Encounter = {
            Id = "FutureBoss",
            Kind = "FinalBoss",
            ExecutorId = "Boss",
            BossId = "TempleDepth4Boss",
        },
    },
}

function flow:binding_for_slot(room_slot_id: string): any?
    return bindings[room_slot_id]
end

function flow:start_slot(room_slot_id: string): any
    table.insert(flow_calls, "start:" .. room_slot_id)
    return {
        ok = true,
        binding = bindings[room_slot_id],
    }
end

local registry_calls = {}
local registry: any = {
    reject_future_boss = true,
}

function registry:validate(
    encounter: any,
    _binding: any,
    _context: any
): any
    table.insert(registry_calls, "validate:" .. encounter.Id)

    if encounter.Id == "FutureBoss"
        and self.reject_future_boss
    then
        return {
            ok = false,
            reason = "BossContentNotRegistered",
        }
    end

    return {ok = true}
end

function registry:execute(
    encounter: any,
    binding: any,
    context: any
): any
    table.insert(registry_calls, "execute:" .. encounter.Id)
    return {
        ok = true,
        Enemies = {},
        Marker = context.Marker,
        RuntimeEncounterId = binding.RuntimeEncounterId,
    }
end

function registry:cleanup(
    encounter: any,
    _binding: any,
    _execution: any,
    _context: any
): any
    table.insert(registry_calls, "cleanup:" .. encounter.Id)
    return {ok = true}
end

local controller = Controller.new(flow, registry)

local unknown = controller:start_slot(
    "Missing",
    {Marker = "missing"}
)
check(
    unknown.ok == false
        and unknown.reason == "UnknownRoomSlot",
    "Unknown room slots must fail closed."
)
check(
    #flow_calls == 0 and #registry_calls == 0,
    "Unknown slots must not touch flow or executors."
)

local future = controller:start_slot(
    "FutureBoss",
    {Marker = "future"}
)
check(
    future.ok == false
        and future.reason == "BossContentNotRegistered",
    "Unregistered future boss content must fail closed."
)
check(
    #flow_calls == 0,
    "Failed content validation must occur before flow start."
)
check(
    registry_calls[#registry_calls] == "validate:FutureBoss",
    "Future boss must be validated through the registry."
)

local started = controller:start_slot(
    "Room1",
    {Marker = "live"}
)
check(started.ok == true, "Known Room1 content must start.")
check(
    flow_calls[#flow_calls] == "start:Room1",
    "Flow start must follow executor validation."
)
check(
    registry_calls[#registry_calls] == "execute:CombatRoom1",
    "Validated encounter must execute."
)
check(
    started.Binding.PlanEncounterId == "CombatRoom1",
    "Success must expose the authoritative binding."
)
check(
    started.Execution.Marker == "live"
        and started.Execution.RuntimeEncounterId
            == "CombatRoom1",
    "Success must expose the executor result."
)

local abort_flow_calls = {}
local abort_flow: any = {}
function abort_flow:binding_for_slot(_room_slot_id: string): any
    return bindings.Room1
end
function abort_flow:cancel_slot(room_slot_id: string): any
    table.insert(abort_flow_calls, "cancel:" .. room_slot_id)
    return {ok = true}
end

local abort_controller = Controller.new(abort_flow, registry)
local aborted = abort_controller:abort_slot(
    "Room1",
    started.Execution,
    {Marker = "abort"}
)
check(aborted.ok == true, "Abort must succeed after successful execution.")
check(
    registry_calls[#registry_calls] == "cleanup:CombatRoom1",
    "Abort must dispatch executor cleanup."
)
check(
    abort_flow_calls[#abort_flow_calls] == "cancel:Room1",
    "Abort must roll the generic sequence back."
)

local failing_registry: any = {}
function failing_registry:validate(
    _encounter: any,
    _binding: any,
    _context: any
): any
    return {ok = true}
end
function failing_registry:execute(
    _encounter: any,
    _binding: any,
    _context: any
): any
    return {
        ok = false,
        reason = "SyntheticExecutionFailure",
    }
end

local rollback_calls = {}
local rollback_flow: any = {}
function rollback_flow:binding_for_slot(_room_slot_id: string): any
    return bindings.Room1
end
function rollback_flow:start_slot(room_slot_id: string): any
    table.insert(rollback_calls, "start:" .. room_slot_id)
    return {ok = true, binding = bindings.Room1}
end
function rollback_flow:cancel_slot(room_slot_id: string): any
    table.insert(rollback_calls, "cancel:" .. room_slot_id)
    return {ok = true}
end

local rollback_controller =
    Controller.new(rollback_flow, failing_registry)
local failed_execution = rollback_controller:start_slot(
    "Room1",
    {Marker = "failure"}
)
check(
    failed_execution.ok == false
        and failed_execution.reason == "SyntheticExecutionFailure",
    "Executor failure must propagate."
)
check(
    rollback_calls[1] == "start:Room1"
        and rollback_calls[2] == "cancel:Room1",
    "Executor failure must roll generic sequence back to Pending."
)

local rejecting_flow: any = {}

function rejecting_flow:binding_for_slot(_room_slot_id: string): any
    return bindings.Room1
end

function rejecting_flow:start_slot(_room_slot_id: string): any
    return {
        ok = false,
        reason = "EncounterOutOfOrder",
    }
end

local executions_before = #registry_calls
local rejecting_controller =
    Controller.new(rejecting_flow, registry)
local rejected = rejecting_controller:start_slot(
    "Room1",
    {Marker = "out-of-order"}
)
check(
    rejected.ok == false
        and rejected.reason == "EncounterOutOfOrder",
    "Sequencer rejection must propagate."
)
check(
    #registry_calls == executions_before + 1
        and registry_calls[#registry_calls]
            == "validate:CombatRoom1",
    "Out-of-order flow must validate content but never execute it."
)

print(string.format(
    "[Dungeon Encounter Execution Controller Tests] PASS: %d assertions.",
    assertion_count
))
