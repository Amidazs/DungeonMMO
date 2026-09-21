--!strict
-- Tests real DungeonSessionService records against a shared map adapter.
-- No published teleport, real DataStore or production event is involved.
local CollectionService = game:GetService("CollectionService")
local SSS = game:GetService("ServerScriptService")
local Core = SSS:WaitForChild("Core")

local ProfileAdapter = require(Core.Adapters.InMemoryProfileAdapter)
local MapAdapter = require(Core.Adapters.InMemoryMapAdapter)
local Profiles = require(Core.Services.ProfileService)
local Sessions = require(Core.Services.DungeonSessionService)
local Weekly = require(Core.Services.WeeklyWorldBossService)
local Bridge = require(Core.Services.WeeklyWorldBossSessionBridge)

local WEEK_SECONDS = 604800
local START_AT = 345600 + WEEK_SECONDS * 3000 + 3600
local END_AT = START_AT + 3600
local FIRST_ID = 822001
local SECOND_ID = 822002
local OUTSIDER_ID = 822003

local now = START_AT + 60
local assertions = 0

-- Args:
--   success: boolean; must hold for safe session recovery.
--   message: string; identifies an incorrect outcome.
-- Returns:
--   nil: tracks the assertion and raises on failure.
local function check(success: boolean, message: string)
    assertions += 1
    assert(success, "[Weekly Boss Session] " .. message)
end

-- Args:
--   sessions: any; shared durable session service.
--   weekly: any; local weekly reward authority.
--   clock: () -> number; fixed trusted event clock.
-- Returns:
--   any: bridge for this simulated server.
local function bridge_for(
    sessions: any,
    weekly: any,
    clock: () -> number
): any
    return Bridge.new(sessions, weekly, clock)
end

-- Args:
--   instance_id: string; session UUID created by session service.
-- Returns:
--   Model: a separate server-authorized, initially living boss.
local function boss_for(instance_id: string): Model
    local boss = Instance.new("Model")
    boss.Name = "WeeklyBossSessionTest_TEMP"
    boss:SetAttribute("WorldBossId", "AncientGuardian")
    boss:SetAttribute("WorldBossInstanceId", instance_id)
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = boss
    boss.Parent = workspace
    CollectionService:AddTag(boss, "DungeonMMOWeeklyWorldBoss")
    return boss
end

local clock = function(): number
    return now
end
local profiles_store = ProfileAdapter.new()
local profiles = Profiles.new(profiles_store)
for _, id in ipairs({FIRST_ID, SECOND_ID, OUTSIDER_ID}) do
    check(profiles:load(id) ~= nil, "initial profile must load")
end

local shared_map = MapAdapter.new(clock)
local sessions = Sessions.new(shared_map, clock)
local weekly = Weekly.new(profiles, clock)
local bridge = bridge_for(sessions, weekly, clock)

local session, create_error = sessions:create(
    "TestDungeon", {FIRST_ID, SECOND_ID}, 0,
    "TEMP_ReservedCodeForWorldBossSession", "Depth1"
)
check(session ~= nil and create_error == nil,
    "create a real, separate server-owned dungeon session")
local session_id = session.SessionId
check(sessions:set_instance_state(session_id, {}).ok,
    "existing session snapshot must be initialized first")

check(bridge:grant_reward(session_id, FIRST_ID).reason
    == "WorldBossNotIssued",
    "ordinary dungeon sessions cannot grant weekly rewards")
local issued = bridge:issue(session_id, START_AT, END_AT)
check(issued.ok and issued.snapshot.BossId == "AncientGuardian",
    "trusted entry must persist a world-boss snapshot")
check(bridge:issue(session_id, START_AT, END_AT).reason
    == "WorldBossAlreadyIssued",
    "repeated event issuance cannot reroll the frozen snapshot")
check(bridge:issue(session_id, START_AT + WEEK_SECONDS,
    END_AT + WEEK_SECONDS).reason == "WorldBossEntryClosed",
    "entry cannot issue a future-week event token")
check(bridge:grant_reward(session_id, OUTSIDER_ID).reason
    == "NotWorldBossParticipant",
    "session outsiders must never claim a reward")
check(bridge:grant_reward(session_id, FIRST_ID).reason
    == "WorldBossContributionRequired",
    "an invited member must still prove encounter participation")

local guardian = boss_for(session_id)
check(bridge:record_defeat(session_id, guardian).reason
    == "WorldBossStillAlive",
    "an alive boss is never an accepted kill")
local humanoid = assert(guardian:FindFirstChildOfClass("Humanoid"))
humanoid.Health = 0
check(bridge:record_defeat(session_id, guardian).ok,
    "the matching server-tagged dead boss marks durable defeat")
local frozen = assert(sessions:get(session_id)).InstanceState
    .WeeklyWorldBoss
check(frozen.Defeated == true
    and frozen.WindowEnd == END_AT
    and frozen.WeekStart == issued.snapshot.WeekStart,
    "the stored defeat must retain its original immutable event window")
check(bridge:grant_reward(session_id, FIRST_ID).reason
    == "WorldBossContributionRequired",
    "defeating the boss does not pay non-contributing members")

check(sessions:set_member_completion_eligibility(
    session_id, FIRST_ID, true).ok,
    "real session contribution authority certifies first player")
check(sessions:mark_connected(session_id, FIRST_ID).ok,
    "first real session member transitions the run to Active")
local first = bridge:grant_reward(session_id, FIRST_ID)
check(first.ok and not first.already_applied
    and first.gold_granted == 100,
    "certified contributing player receives one weekly reward")
check(bridge:grant_reward(session_id, FIRST_ID).already_applied,
    "same server must not pay a second weekly reward")
check(bridge:grant_reward(session_id, SECOND_ID).reason
    == "WorldBossContributionRequired",
    "another invited member remains ineligible without contribution")

check(profiles:release(FIRST_ID, "WeeklyBossServerHandoffTest"),
    "weekly payout must survive profile release")
local next_profiles = Profiles.new(profiles_store)
check(next_profiles:load(FIRST_ID) ~= nil,
    "next service instance loads same player from the test store")
check(next_profiles:load(SECOND_ID) ~= nil,
    "second player can join a fresh service instance")
local next_sessions = Sessions.new(shared_map, clock)
local next_weekly = Weekly.new(next_profiles, clock)
local next_bridge = bridge_for(next_sessions, next_weekly, clock)
local restored = next_bridge:resume(session_id)
check(restored.ok and restored.snapshot.Defeated == true,
    "new server-style services restore the original defeated event")
local replay = next_bridge:grant_reward(session_id, FIRST_ID)
check(replay.ok and replay.already_applied
    and replay.gold_granted == 0,
    "reconnecting same account cannot re-claim a paid week")

check(next_sessions:set_member_completion_eligibility(
    session_id, SECOND_ID, true).ok,
    "unpaid party member may later satisfy their own contribution")
local second = next_bridge:grant_reward(session_id, SECOND_ID)
check(second.ok and second.gold_granted == 100
    and not second.already_applied,
    "eligible second party member receives their separate payout")
check(assert(next_profiles:get_character(FIRST_ID, 1)).Gold == 100
    and assert(next_profiles:get_character(SECOND_ID, 1)).Gold == 100,
    "reward history and balances remain isolated per account")

now = END_AT + 1801
check(next_bridge:resume(session_id).reason
    == "WorldBossInstanceExpired",
    "stored event cannot re-open beyond its reward grace window")
check(next_bridge:grant_reward(session_id, FIRST_ID).reason
    == "WorldBossInstanceExpired",
    "expired server sessions cannot grant a fresh entitlement")

guardian:Destroy()
print(string.format(
    "[Weekly Boss Session] PASS: %d assertions.", assertions))
