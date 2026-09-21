--!strict
-- Actual Base return and old-session index release contract. No
-- client teleport or production profile storage is touched.
local SSS = game:GetService("ServerScriptService")
local Core = SSS:WaitForChild("Core")
local Base = SSS:WaitForChild("Base")

local MapAdapter = require(Core.Adapters.InMemoryMapAdapter)
local Sessions = require(Core.Services.DungeonSessionService)
local ReturnRules = require(Base.BaseReturnAdmissionRules)
local Reconnect = require(Base.BaseReconnectRouting)
local Gateway = require(Base.WorldBossBaseRuntime)

local assertions = 0
local FIRST_ID = 95401
local SECOND_ID = 95402

-- Args:
--   success: boolean; required world-boss return rule.
--   message: string; identifies a broken Base admission invariant.
-- Returns:
--   nil: records a passing assertion or raises.
local function check(success: boolean, message: string)
    assertions += 1
    assert(success, "[Weekly Boss Base Return] " .. message)
end

check(Gateway.validate_config({Enabled = false}).reason
    == "WorldBossDisabled",
    "optional Base entry is disabled until explicitly authorized")
check(Gateway.validate_config({
    Enabled = true, PlaceId = 12345, StartAt = 0, EndAt = 1,
}).reason == "PublishedTeleportRequired",
    "unpublished Studio cannot initiate live event travel")

local sessions = Sessions.new(MapAdapter.new())
local session, reason = sessions:create(
    "TestDungeon", {FIRST_ID, SECOND_ID}, 0,
    "WorldBossReturnReserved_TEMP", "Depth1")
check(session ~= nil and reason == nil,
    "existing session authority issues a valid party transport")
local id = session.SessionId
check(sessions:set_instance_state(id, {
    WeeklyWorldBoss = {
        BossId = "AncientGuardian",
        DestinationPlaceId = 912345678,
        WeekStart = 0,
        WindowStart = 0,
        WindowEnd = 1000,
        Members = {FIRST_ID, SECOND_ID},
        Defeated = false,
    },
}).ok, "world-boss session must have durable state")
check(sessions:mark_connected(id, FIRST_ID).ok,
    "an arrived boss-party member activates the session")
check(sessions:set_world_boss_return_pending(
    id, FIRST_ID, true).reason == "WorldBossNotReturnable",
    "players cannot return through reward portal while boss is alive")

local updated = sessions:update_instance_state(id, function(state)
    state.WeeklyWorldBoss.Defeated = true
    return state, nil
end)
check(updated.ok, "defeat was saved in the actual session map")
check(sessions:set_world_boss_return_pending(id, FIRST_ID, true).ok,
    "defeated member may begin the authenticated Base return")
session = sessions:get(id)
local data = {
    SessionId = id,
    DungeonId = session.DungeonId,
    WorldBoss = true,
}
check(ReturnRules.validate(session, data, FIRST_ID).ok,
    "Base must accept a server-marked defeated boss return")
check(ReturnRules.validate(session, {
    SessionId = id, DungeonId = session.DungeonId,
}, FIRST_ID).reason == "SessionNotReturnable",
    "normal dungeon routing cannot masquerade as an active boss return")
check(ReturnRules.validate(session, data, SECOND_ID).reason
    == "SessionNotReturnable",
    "a party member without their own return handoff cannot leave")
check(Reconnect.decide(session, FIRST_ID).route == "Base",
    "returning member must not immediately rejoin the boss")
check(Reconnect.decide(session, SECOND_ID).route == "Dungeon",
    "other party members remain recoverable in their boss instance")
check(sessions:get_for_user(FIRST_ID).SessionId == id,
    "old index remains until a confirmed Base arrival")
check(sessions:release_world_boss_return_index(
    id, FIRST_ID).ok,
    "Base may release the returned member's existing dungeon index")
check(sessions:get_for_user(FIRST_ID) == nil,
    "returned player may start new gameplay from Base")
check(sessions:get_for_user(SECOND_ID).SessionId == id,
    "clearing first index cannot evict other party members")
check(sessions:release_world_boss_return_index(
    id, FIRST_ID).reason == "WorldBossReturnIndexMismatch",
    "duplicate Base cleanup cannot release unrelated future sessions")

print(string.format(
    "[Weekly Boss Base Return] PASS: %d assertions.", assertions))
