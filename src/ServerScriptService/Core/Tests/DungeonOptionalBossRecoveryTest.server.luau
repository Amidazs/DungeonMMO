--!strict
-- Persists an eligible secret route through a lost connection and a new
-- controller/service instance. Actual network rejoin is a separate live gate.
local Core = game:GetService("ServerScriptService"):WaitForChild("Core")
local Dungeon = game:GetService("ServerScriptService"):WaitForChild("Dungeon")
local Sessions = require(Core.Services.DungeonSessionService)
local Map = require(Core.Adapters.InMemoryMapAdapter)
local Controller = require(Dungeon.DungeonEncounterRuntimeController)
local Discovery = require(Core.Services.DungeonSecretDiscoveryService)

local assertions = 0
local function check(ok: boolean, reason: string)
    assertions += 1
    assert(ok, "[Optional Boss Recovery Tests] " .. reason)
end

local now = 1000
local map = Map.new(function() return now end)
local original = Sessions.new(map, function() return now end)
local user_id = 99234
local peer_id = 99235
local created = assert(original:create("TestDungeon", {user_id, peer_id}, 0,
    "optional-recovery-test", "Depth1"))
local id = created.SessionId
assert(original:mark_connected(id, user_id).ok)
assert(original:mark_connected(id, peer_id).ok)

local encounters = {
    {Id = "First", Kind = "Combat", RoomSlotId = "Room1"},
    {Id = "Event", Kind = "EventBoss", BossId = "TempleEventBoss",
        RoomSlotId = "EventArena"},
    {Id = "Second", Kind = "Combat", RoomSlotId = "Room2"},
    {Id = "Secret", Kind = "SecretBoss", BossId = "TempleSecretBoss",
        RoomSlotId = "SecretArena", CompletionRequired = false},
    {Id = "Final", Kind = "Boss", RoomSlotId = "Room3"},
}
assert(original:set_instance_state(id, {
    OptionalBossEnabled = true,
    OptionalBossEventActive = true,
    OptionalBossEventId = "TempleEclipse",
    OptionalBossEventWindows = {
        TempleEclipse = {StartUnix = 900, EndUnix = 1200},
    },
    OptionalBossSecretUnlocked = true,
    OptionalBossSecretUnlocks = {TempleHiddenSanctum = true},
    EncounterPlan = encounters,
}).ok)
local initial = assert(Controller.new({
    session_service = original, session_id = id,
    base_sequence = encounters, optional_encounters = {},
}))
for _, name in ipairs({"First", "Event", "Second"}) do
    check(initial:start(name).ok, name .. " starts")
    check(initial:clear(name).ok, name .. " clears")
end
local service = Discovery.new(original)
local discovered = service:discover(id, user_id, "Secret", 1)
check(discovered.ok and not discovered.already_discovered,
    "valid nearby member discovers secret before disconnection")
check(initial:start("Secret").ok, "secret becomes active")
local before = original:get(id)
check(before.InstanceState.EncounterRuntime.EncounterStates.Secret == "Active",
    "active encounter is persisted before disconnection")
check(original:mark_disconnected(id, user_id).ok,
    "member is marked disconnected in saved session")
local peer_session = assert(original:get(id))
check(peer_session.Members[tostring(peer_id)].Connected == true
    and peer_session.InstanceState.EncounterRuntime.ActiveEncounterId
        == "Secret",
    "disconnect retains connected peer and active optional encounter")
check(not service:discover(id, peer_id, "Secret", 0).ok,
    "peer cannot restart the active optional boss")
check(not service:discover(id, user_id, "Secret", 0).ok,
    "disconnected player cannot retrigger secret")

local recovered_sessions = Sessions.new(map, function() return now end)
local recovered = assert(recovered_sessions:get(id))
local state = recovered.InstanceState
check(state.OptionalBossEventWindows.TempleEclipse.StartUnix == 900
    and state.OptionalBossEventWindows.TempleEclipse.EndUnix == 1200,
    "original event window is not rerolled on reconnect")
check(state.OptionalBossSecretDiscoveries.TempleHiddenSanctum == true,
    "discovery is persisted across service reconstruction")
check(state.EncounterPlan[4].BossId == "TempleSecretBoss",
    "same immutable secret boss encounter is restored")
check(recovered.Members[tostring(peer_id)].Connected == true
    and recovered.Members[tostring(user_id)].Connected == false,
    "recovery preserves independent party connection states")
local resumed = assert(Controller.new({
    session_service = recovered_sessions, session_id = id,
    base_sequence = encounters, optional_encounters = {},
}))
check(resumed:next_id() == "Secret"
    and resumed:state_of("Secret") == "Pending",
    "interrupted boss recovers as the same pending encounter")
check(resumed:state_of("Event") == "Cleared"
    and resumed:state_of("Second") == "Cleared",
    "previously cleared encounters must not be replayed")
assert(recovered_sessions:mark_connected(id, user_id).ok)
check(recovered_sessions:get(id).Members[tostring(peer_id)].Connected,
    "rejoining member must not disconnect the active party member")
check(Discovery.new(recovered_sessions):discover(
    id, peer_id, "Secret", 0
).already_discovered == true,
    "peer shares the once-only persisted secret discovery")
check(Discovery.new(recovered_sessions):discover(
    id, user_id, "Secret", 0
).already_discovered == true, "reconnect cannot discover twice")
check(resumed:start("Secret").ok and resumed:clear("Secret").ok,
    "recoverable secret boss can be completed once")
local next_controller = assert(Controller.new({
    session_service = Sessions.new(map, function() return now end),
    session_id = id, base_sequence = encounters,
    optional_encounters = {},
}))
check(next_controller:state_of("Secret") == "Cleared"
    and next_controller:next_id() == "Final",
    "defeated secret is not respawned after another reload")
print(string.format("[Optional Boss Recovery Tests] PASS: %d assertions.",
    assertions))
