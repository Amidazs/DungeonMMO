--!strict
-- Reserved world-boss transport and arrival contract. All teleport calls
-- use a fake adapter; no Roblox publish or real player transfer occurs.
local SSS = game:GetService("ServerScriptService")
local Core = SSS:WaitForChild("Core")
local Services = Core:WaitForChild("Services")
local Adapters = Core:WaitForChild("Adapters")

local Profiles = require(Services.ProfileService)
local ProfileAdapter = require(Adapters.InMemoryProfileAdapter)
local LeaseService = require(Services.ProfileLeaseService)
local Sessions = require(Services.DungeonSessionService)
local MapAdapter = require(Adapters.InMemoryMapAdapter)
local Weekly = require(Services.WeeklyWorldBossService)
local Bridge = require(Services.WeeklyWorldBossSessionBridge)
local Coordinator = require(Services.TeleportCoordinator)
local Arrival = require(Services.WeeklyWorldBossArrivalRules)

local assertions = 0
local FIRST_ID = 94101
local SECOND_ID = 94102
local BOSS_PLACE_ID = 987654321
local now = os.time()
local week_start = require(
    game:GetService("ReplicatedStorage").Core.Shared.WeeklyWorldBossWindow
).week_start(now)

local START_AT = math.max(now - 5, week_start)
local END_AT = math.min(
    START_AT + 240, week_start + 604800)

-- Args:
--   expected: boolean; required transport/admission invariant.
--   message: string; explains a failed safety gate.
-- Returns:
--   nil: records a passing assertion or raises an error.
local function check(expected: boolean, message: string)
    assertions += 1
    assert(expected, "[Weekly Boss Travel] " .. message)
end

local lease_map = MapAdapter.new()
local session_map = MapAdapter.new()
local leases = LeaseService.new(lease_map, "Base:BossTravelTest")
local profiles = Profiles.new(ProfileAdapter.new(), leases)
for _, user_id in ipairs({FIRST_ID, SECOND_ID}) do
    check(profiles:load(user_id) ~= nil,
        "every traveling party member must have a loaded profile")
end

local sessions = Sessions.new(session_map)
local weekly = Weekly.new(profiles)
local bridge = Bridge.new(sessions, weekly)
local seen = {}
local adapter = {}

-- Args:
--   place_id: number; requested target of the reservation.
-- Returns:
--   (boolean, string): a fixed fake reserved access code.
function adapter:reserve_server(place_id: number): (boolean, string)
    seen.reserved_place_id = place_id
    return true, "WorldBossReservedCode_TEMP"
end

-- Args:
--   place_id: number; destination of the fake handoff.
--   players: {any}; server-selected party.
--   code: string?; access code issued by the reservation.
--   data: any; server-produced routing-only metadata.
-- Returns:
--   (boolean, string?): fake transport result and no error.
function adapter:teleport(
    place_id: number,
    players: {any},
    code: string?,
    data: any
): (boolean, string?)
    seen.place_id = place_id
    seen.players = players
    seen.reserved_code = code
    seen.data = data
    return true, nil
end

-- Args:
--   _handler: any; unused fake teleport failure callback.
-- Returns:
--   nil: real Roblox callbacks are not needed in contract testing.
function adapter:connect_init_failed(_handler: any)
    return nil
end

local coordinator = Coordinator.new(
    adapter, profiles, leases, sessions)
local players = {
    {UserId = FIRST_ID},
    {UserId = SECOND_ID},
}
check(not coordinator:start_weekly_world_boss(
    players, 0, bridge, START_AT, END_AT).ok,
    "an invalid destination must be rejected before reservation")
check(seen.reserved_place_id == nil,
    "invalid destination must not reserve a server")
check(coordinator:start_weekly_world_boss(
    players, BOSS_PLACE_ID, bridge, END_AT + 10,
    END_AT + 40).reason == "WorldBossEntryClosed",
    "a future event must not reserve a server")
check(seen.reserved_place_id == nil,
    "closed/future windows cannot reserve a server")

local result = coordinator:start_weekly_world_boss(
    players, BOSS_PLACE_ID, bridge, START_AT, END_AT)
check(result.ok and result.session ~= nil,
    "a real server party must receive a reserved session")
local session = sessions:get(result.session.SessionId)
check(session and session.ReservedAccessCode
    == "WorldBossReservedCode_TEMP"
    and session.InstanceState.WeeklyWorldBoss.DestinationPlaceId
        == BOSS_PLACE_ID,
    "session snapshot must bind its reserved dedicated destination")
check(seen.place_id == BOSS_PLACE_ID
    and seen.reserved_place_id == BOSS_PLACE_ID
    and seen.reserved_code == "WorldBossReservedCode_TEMP",
    "real coordinator must use the same authorized reserved place")
check(#seen.players == 2 and seen.data.WorldBoss == true,
    "teleport must preserve both approved players and boss routing")
check(seen.data.Gold == nil and seen.data.WeeklyReward == nil
    and seen.data.Members == nil,
    "teleport routing must never carry reward or membership authority")
check(coordinator:is_pending(FIRST_ID)
    and coordinator:is_pending(SECOND_ID),
    "all departing party members have protected handoff tickets")

local accepted = Arrival.validate(
    session, seen.data, FIRST_ID, BOSS_PLACE_ID)
check(accepted.ok and accepted.snapshot.BossId == "AncientGuardian",
    "dedicated place may admit an existing authenticated member")
check(Arrival.validate(
    session, seen.data, FIRST_ID, BOSS_PLACE_ID + 1).reason
        == "WorldBossDestinationMismatch",
    "ordinary or wrong destination cannot accept a boss session")
check(Arrival.validate(
    session, {SessionId = session.SessionId,
        DungeonId = "TestDungeon"}, FIRST_ID, BOSS_PLACE_ID).reason
        == "WorldBossRoutingMismatch",
    "ordinary dungeon teleport data cannot enter boss place")
check(Arrival.validate(
    session, seen.data, 99999, BOSS_PLACE_ID).reason
        == "NotWorldBossParticipant",
    "player cannot use a copied party member's routing information")
check(coordinator:rejoin_session(
    players[1], session, BOSS_PLACE_ID + 1).reason
        == "TeleportAlreadyPending",
    "an active handoff must block duplicate reconnect calls")

coordinator:acknowledge_departure(FIRST_ID)
check(coordinator:rejoin_session(
    players[1], session, BOSS_PLACE_ID + 1).reason
        == "WorldBossDestinationMismatch",
    "reconnection must use the original reserved world-boss place")

print(string.format(
    "[Weekly Boss Travel] PASS: %d assertions.", assertions))
