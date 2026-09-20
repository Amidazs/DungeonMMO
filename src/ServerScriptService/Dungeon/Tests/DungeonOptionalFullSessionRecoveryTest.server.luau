--!strict
-- An in-memory server recreation exercises persisted optional-run recovery.
-- This is a service-level contract, not a real same-account network rejoin.

local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local Services = Core:WaitForChild("Services")

local SessionService = require(Services.DungeonSessionService)
local MapAdapter = require(Core.Adapters.InMemoryMapAdapter)
local ProfileAdapter = require(Core.Adapters.InMemoryProfileAdapter)
local ProfileService = require(Services.ProfileService)
local ProgressionService = require(Services.ProgressionService)
local InventoryService = require(Services.InventoryService)
local RewardService = require(Services.RewardService)
local Controller = require(Dungeon.DungeonEncounterRuntimeController)
local EncounterFlow = require(Dungeon.DungeonEncounterFlow)
local Gates = require(Dungeon.DungeonOptionalEntranceGates)

local assertions = 0

-- Checks an invariant and records it for the focused Studio runner.
-- Args: passed (boolean): Required test invariant.
--       message (string): Explanation displayed if the assertion fails.
-- Returns: nil: Raises on a failed invariant.
local function check(passed: boolean, message: string)
    assertions += 1
    assert(passed, "[Optional Full Recovery] " .. message)
end

-- Makes the real controller use the run's persisted, frozen encounter plan.
-- Args: sessions (any): Session service connected to shared test storage.
--       session_id (string): Persistent run identifier.
--       plan ({any}): The original run's materialized encounter plan.
-- Returns: any: New controller representing one reconstructed server.
local function restart_controller(
    sessions: any, session_id: string, plan: {any}
): any
    local controller, reason = Controller.new({
        session_service = sessions,
        session_id = session_id,
        base_sequence = plan,
        optional_encounters = {},
    })
    check(controller ~= nil and reason == nil,
        "recovered controller must reconstruct: " .. tostring(reason))
    return controller
end

-- Builds the detached placeholder-gate fixture with real gate metadata.
-- Args: None.
-- Returns: Folder, BasePart, BasePart: Root, Event and Secret gates.
local function make_gates(): (Folder, BasePart, BasePart)
    local root = Instance.new("Folder")
    root.Name = "DungeonMMOPlaceholderPhysicalContent"
    root:SetAttribute("DungeonMMODungeonId", "TestDungeon")
    local gates = {}
    for _, item in ipairs({
        {bridge = "EventBridge", slot = "EventArena"},
        {bridge = "SecretBridge", slot = "SecretArena"},
    }) do
        local bridge = Instance.new("Model")
        bridge.Name = item.bridge
        bridge.Parent = root
        local gate = Instance.new("Part")
        gate.Name = "EntranceGate"
        gate:SetAttribute("DungeonMMOOptionalEntranceGate", true)
        gate:SetAttribute("DungeonMMOOptionalArena", item.slot)
        gate.Parent = bridge
        gates[item.slot] = gate
    end
    return root, gates.EventArena, gates.SecretArena
end

-- Adapts the frozen plan to the existing encounter-flow binding contract.
-- Args: plan ({any}): Frozen, materialized encounter descriptors.
-- Returns: any: Valid detached bindings for the live flow/gate modules.
local function make_bindings(plan: {any}): any
    local result = {
        ok = true,
        by_slot = {},
        by_encounter = {},
        by_runtime = {},
        ordered = {},
    }
    for index, encounter in ipairs(plan) do
        local binding = {
            PlanEncounterId = encounter.Id,
            RuntimeEncounterId = encounter.Id,
            RoomSlotId = encounter.RoomSlotId,
            Kind = encounter.Kind,
            CheckpointId = "EncounterStart:" .. encounter.Id,
            CheckpointSequence = index,
        }
        result.by_slot[binding.RoomSlotId] = binding
        result.by_encounter[binding.PlanEncounterId] = binding
        result.by_runtime[binding.RuntimeEncounterId] = binding
        table.insert(result.ordered, binding)
    end
    return result
end

-- Constructs a fresh reward service with the same persisted profile map.
-- Args: profiles (any): A loaded profile service for the recovered server.
-- Returns: any: Independent reward service and its empty runtime caches.
local function make_rewards(profiles: any): any
    local rng = {
        NextInteger = function(_, low: number)
            return low
        end,
        NextNumber = function(_, low: number)
            return low
        end,
    }
    return RewardService.new(
        profiles,
        ProgressionService.new(profiles),
        InventoryService.new(profiles),
        nil,
        rng,
        function() return 1000 end
    )
end

local now = 1000
local map = MapAdapter.new(function() return now end)
local first = SessionService.new(map, function() return now end)
local first_user = 99581
local second_user = 99582
local session = assert(first:create(
    "TestDungeon", {first_user, second_user}, 0,
    "optional-full-recovery", "Depth1"
))
local session_id = session.SessionId

local plan = {
    {Id = "First", Kind = "Combat", RoomSlotId = "Room1"},
    {Id = "Event", Kind = "EventBoss", RoomSlotId = "EventArena",
        BossId = "TempleEventBoss"},
    {Id = "Second", Kind = "Combat", RoomSlotId = "Room2"},
    {Id = "Secret", Kind = "SecretBoss", RoomSlotId = "SecretArena",
        BossId = "TempleSecretBoss", CompletionRequired = false},
    {Id = "Final", Kind = "Boss", RoomSlotId = "Room3"},
}
check(first:set_instance_state(session_id, {
    EncounterPlan = plan,
    OptionalBossEventActive = true,
    OptionalBossSecretUnlocked = true,
    OptionalBossSecretUnlocks = {TempleHiddenSanctum = true},
    OptionalBossEventWindows = {
        TempleEclipse = {StartUnix = 900, EndUnix = 1200},
    },
}).ok, "frozen optional eligibility is saved once")
check(first:mark_connected(session_id, first_user).ok
    and first:mark_connected(session_id, second_user).ok,
    "both party members start connected")

local controller = restart_controller(first, session_id, plan)
check(controller:start("First").ok and controller:clear("First").ok,
    "first prerequisite must clear once")
check(first:activate_checkpoint(
    session_id, "EncounterStart:Event", 2
).ok, "Event-start checkpoint must persist")
check(controller:start("Event").ok, "Event starts and persists as Active")
check(first:mark_disconnected(session_id, first_user).ok,
    "first party member disconnects during Event")

-- Recreate both the session and encounter controllers from the shared map.
local restored_sessions = SessionService.new(
    map, function() return now end
)
local restored = restart_controller(
    restored_sessions, session_id, plan
)
local restored_session = assert(restored_sessions:get(session_id))
check(restored_session.Checkpoint.Id == "EncounterStart:Event",
    "recovery retains the last checkpoint")
check(restored_session.Members[tostring(second_user)].Connected
    and not restored_session.Members[tostring(first_user)].Connected,
    "peer connection state survives a reconstructed server")
check(restored_session.InstanceState.OptionalBossEventActive
    and restored_session.InstanceState.OptionalBossSecretUnlocked,
    "frozen Event and Secret eligibility survives server reconstruction")
check(restored_session.InstanceState.OptionalBossEventWindows
    .TempleEclipse.EndUnix == 1200,
    "original timed Event window is not rerolled after restart")
check(restored:state_of("First") == "Cleared"
    and restored:state_of("Event") == "Pending"
    and restored:next_id() == "Event",
    "only the interrupted Event resets; Room1 remains cleared")
check(restored_sessions:get(session_id).InstanceState
    .EncounterRuntime.ActiveEncounterId == nil,
    "interrupted Active identity is cleared in persistent storage")

local root, event_gate, secret_gate = make_gates()
local bindings = make_bindings(plan)
local flow = EncounterFlow.new(restored, bindings)
check(Gates.sync(root, bindings, flow).ok
    and not event_gate.CanCollide and secret_gate.CanCollide,
    "reconstructed gates open Event but keep Secret physically closed")
check(not flow:start_slot("SecretArena").ok,
    "Secret cannot spawn before the recovered Room2 prerequisite")

check(restored_sessions:mark_connected(
    session_id, first_user
).ok, "original member can reconnect to the same stored session")
check(restored_sessions:get(session_id)
    .Members[tostring(second_user)].Connected,
    "member reconnect never disconnects the existing peer")
check(flow:start_slot("EventArena").ok,
    "interrupted Event becomes retryable exactly once")
check(not flow:start_slot("EventArena").ok,
    "repeated Event trigger cannot spawn a second boss")
check(flow:clear_runtime("Event").ok,
    "recovered Event can be cleared by the shared party")
check(restored:state_of("Event") == "Cleared",
    "Event clear persists before starting subsequent encounters")
check(restored:start("Second").ok and restored:clear("Second").ok,
    "recovered party can clear Room2 without replaying Room1")
check(Gates.sync(root, bindings, flow).ok
    and not secret_gate.CanCollide,
    "recovered Room2 clear opens the selected Secret entrance")
check(restored:skip("Secret").ok and restored:start("Final").ok,
    "eligible Secret can be bypassed while the final room begins")

-- A second server interruption during Final must preserve a deferred
-- Secret route and release the partially started final boss.
local last_sessions = SessionService.new(map, function() return now end)
local last = restart_controller(last_sessions, session_id, plan)
local last_flow = EncounterFlow.new(last, bindings)
check(last:state_of("Event") == "Cleared"
    and last:state_of("Second") == "Cleared"
    and last:state_of("Final") == "Pending"
    and last:state_of("Secret") == "Skipped",
    "second recovery retains clears, skip and interrupted Final pending")
check(Gates.sync(root, bindings, last_flow).ok
    and not event_gate.CanCollide and not secret_gate.CanCollide,
    "recreated side barriers preserve eligible backtracking access")
check(last_flow:start_slot("SecretArena").ok,
    "deferred eligible Secret can start before final completion")
check(not last_flow:start_slot("SecretArena").ok,
    "repeated discovery cannot start a duplicate Secret boss")

-- Interrupt the deferred Secret itself. Its recovery state must return
-- to Skipped rather than rewinding the required Final encounter.
local deferred_sessions = SessionService.new(
    map, function() return now end
)
local deferred = restart_controller(
    deferred_sessions, session_id, plan
)
local deferred_flow = EncounterFlow.new(deferred, bindings)
check(deferred:state_of("Secret") == "Skipped"
    and deferred:next_id() == "Final",
    "interrupted backtracked Secret remains available without rewinding")
check(deferred_flow:start_slot("SecretArena").ok
    and deferred_flow:clear_runtime("Secret").ok,
    "Secret can be replayed once and cleared after another recovery")
check(not deferred_flow:start_slot("SecretArena").ok,
    "cleared Secret cannot be started again")
check(deferred:start("Final").ok and deferred:clear("Final").ok,
    "final room remains playable after deferred Secret completion")
check(deferred:is_complete(),
    "all required rooms remain complete after recovery")
check(not deferred_flow:start_slot("SecretArena").ok,
    "completed run cannot restart Secret")

-- The reward history is stored in a separate persistent profile adapter,
-- not in a re-created reward service's ephemeral in-memory cache.
local profile_map = ProfileAdapter.new()
local profiles = ProfileService.new(profile_map)
check(profiles:load(first_user) ~= nil
    and profiles:load(second_user) ~= nil,
    "two profile slots load from the disposable in-memory adapter")
local rewards = make_rewards(profiles)
local transaction = session_id .. ":TempleEventBoss:Event:Boss"
local reward = {XP = 40, GoldMin = 1, GoldMax = 1,
    BossId = "TempleEventBoss"}
local granted = rewards:grant_monster_reward(
    {first_user, second_user}, reward, transaction
)
check(granted.ok and not granted.already_applied,
    "each party member receives its first Event reward")
local previous_gold = profiles:get_character(first_user, 1).Gold
check(profiles:save(first_user, "RecoveryTest")
    and profiles:save(second_user, "RecoveryTest"),
    "both reward histories persist before another server recreation")
local new_profiles = ProfileService.new(profile_map)
check(new_profiles:load(first_user) ~= nil
    and new_profiles:load(second_user) ~= nil,
    "recovered profile service can reload stored member rewards")
local replay = make_rewards(new_profiles):grant_monster_reward(
    {first_user, second_user}, reward, transaction
)
check(replay.ok and replay.already_applied
    and new_profiles:get_character(first_user, 1).Gold == previous_gold,
    "recreated reward service cannot duplicate the same boss reward")
root:Destroy()
print(string.format(
    "[Optional Full Recovery Tests] PASS: %d assertions.", assertions
))
