--!strict
-- World-boss death/rejoin policy uses the existing durable session modes.
local SSS = game:GetService("ServerScriptService")
local Core = SSS:WaitForChild("Core")
local WorldBoss = SSS:WaitForChild("WorldBoss")

local Adapter = require(Core.Adapters.InMemoryMapAdapter)
local Sessions = require(Core.Services.DungeonSessionService)
local Lifecycle = require(WorldBoss.WorldBossMemberLifecycle)

local assertions = 0
local FIRST_ID = 96101
local SECOND_ID = 96102

-- Args:
--   condition: boolean; required member-lifecycle behavior.
--   message: string; actionable failure context.
-- Returns:
--   nil: records a passing assertion or raises.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[World Boss Member Lifecycle] " .. message)
end

local sessions = Sessions.new(Adapter.new())
local session = assert(sessions:create(
    "TestDungeon", {FIRST_ID, SECOND_ID}, 0,
    "WorldBossLifecycleReserved", "Depth1"))
local id = session.SessionId
check(sessions:set_instance_state(id, {
    WeeklyWorldBoss = {
        BossId = "AncientGuardian",
        Members = {FIRST_ID, SECOND_ID},
        Defeated = false,
    },
}).ok, "weekly event state must exist before member lifecycle")
check(sessions:mark_connected(id, FIRST_ID).ok
    and sessions:mark_connected(id, SECOND_ID).ok,
    "both world-boss members must be connected")

local lifecycle = Lifecycle.new(sessions)
check(lifecycle:mark_active(id, FIRST_ID).ok
    and lifecycle:mark_active(id, SECOND_ID).ok,
    "spawned members become active")
check(lifecycle:mark_dead(id, FIRST_ID).ok,
    "real Humanoid death may persist Dead mode")
check(lifecycle:can_respawn(id, FIRST_ID),
    "connected dead member may respawn into the same encounter")
check(not lifecycle:can_respawn(id, SECOND_ID),
    "living member cannot trigger a duplicate respawn")
check(sessions:mark_disconnected(id, FIRST_ID).ok
    and not lifecycle:can_respawn(id, FIRST_ID),
    "departed client cannot be respawned by a stale delayed callback")
check(sessions:mark_connected(id, FIRST_ID).ok
    and lifecycle:mark_dead(id, FIRST_ID).ok
    and lifecycle:can_respawn(id, FIRST_ID),
    "reconnected member can restore dead-state recovery")
local defeated = sessions:update_instance_state(id, function(state)
    state.WeeklyWorldBoss.Defeated = true
    return state, nil
end)
check(defeated.ok and lifecycle:can_respawn(id, FIRST_ID),
    "dead contributor may still respawn after victory to claim/return")
check(lifecycle:mark_active(id, FIRST_ID).ok
    and not lifecycle:can_respawn(id, FIRST_ID),
    "successful respawn clears Dead mode")

print(string.format(
    "[World Boss Member Lifecycle] PASS: %d assertions.", assertions))
