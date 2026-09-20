--!strict
-- A failed persisted Event start must not strand the entire dungeon run.
local Dungeon = game:GetService("ServerScriptService"):WaitForChild(
    "Dungeon"
)
local Controller = require(
    Dungeon:WaitForChild("DungeonEncounterRuntimeController")
)
local Sequencer = require(
    Dungeon:WaitForChild("DungeonEncounterSequencer")
)

local plan = {
    {Id = "Event", Kind = "EventBoss", CompletionRequired = true},
    {Id = "Room2", Kind = "Combat", CompletionRequired = true},
}
local sequencer = Sequencer.new(plan)
local store_available = false
local controller = setmetatable({
    _sequencer = sequencer,
    _persist = function()
        return if store_available then {ok = true}
            else {ok = false, reason = "SimulatedStoreOutage"}
    end,
}, Controller)

local failed = controller:start("Event")
assert(failed.ok == false and failed.reason == "SimulatedStoreOutage",
    "Event startup should report persistence failure")
assert(sequencer:state_of("Event") == "Pending"
    and sequencer:next_id() == "Event"
    and sequencer:snapshot().ActiveEncounterId == nil,
    "failed Event persistence must not strand active encounter")
store_available = true
assert(controller:start("Event").ok,
    "Event encounter must be retryable when persistence recovers")
assert(controller:clear("Event").ok,
    "recovered Event must clear exactly once")
assert(controller:start("Room2").ok and controller:clear("Room2").ok,
    "the following required room must remain playable")
assert(controller:is_complete(), "normal run should complete")
-- The optional Secret skip must also roll back if its save is rejected.
local skip_plan = {
    {Id = "Secret", Kind = "SecretBoss", CompletionRequired = false},
    {Id = "Final", Kind = "Boss", CompletionRequired = true},
}
local skip_controller = setmetatable({
    _encounters = skip_plan,
    _sequencer = Sequencer.new(skip_plan),
    _persist = function()
        return if store_available then {ok = true}
            else {ok = false, reason = "SimulatedStoreOutage"}
    end,
}, Controller)
store_available = false
local failed_skip = skip_controller:skip("Secret")
assert(failed_skip.ok == false
    and failed_skip.reason == "SimulatedStoreOutage",
    "Secret bypass should report its failed persistent save")
assert(skip_controller:state_of("Secret") == "Pending"
    and skip_controller:next_id() == "Secret",
    "failed Secret skip must not advance the required route")
store_available = true
assert(skip_controller:skip("Secret").ok
    and skip_controller:next_id() == "Final",
    "Secret skip should succeed after persistence recovers")
assert(skip_controller:start_skipped_secret("Secret").ok
    and skip_controller:clear("Secret").ok,
    "saved skip must still permit deferred Secret backtracking")
assert(skip_controller:start("Final").ok
    and skip_controller:clear("Final").ok
    and skip_controller:is_complete(),
    "recovered bypass must leave final completion intact")
print("[Optional Boss Start Failure Tests] PASS: 11 assertions.")
