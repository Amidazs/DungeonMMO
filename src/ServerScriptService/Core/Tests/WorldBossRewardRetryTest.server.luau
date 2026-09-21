--!strict
-- Reproduce a local profile-save failure after a legitimate boss kill.
-- This uses real session/reward/profile services with an in-memory store.
local CollectionService = game:GetService("CollectionService")
local SSS = game:GetService("ServerScriptService")
local Core = SSS:WaitForChild("Core")

local ProfileAdapter = require(Core.Adapters.InMemoryProfileAdapter)
local MapAdapter = require(Core.Adapters.InMemoryMapAdapter)
local Profiles = require(Core.Services.ProfileService)
local Sessions = require(Core.Services.DungeonSessionService)
local Contributions = require(Core.Services.ContributionService)
local ContributionRules = require(Core.Services.WorldBossContributionRules)
local Weekly = require(Core.Services.WeeklyWorldBossService)
local Bridge = require(Core.Services.WeeklyWorldBossSessionBridge)

local WEEK_SECONDS = 604800
local START_AT = 345600 + WEEK_SECONDS * 3000 + 3600
local END_AT = START_AT + 3600
local FIRST_ID = 97401
local SECOND_ID = 97402
local assertions = 0

-- Args:
--   condition: boolean; required reward-retry safety invariant.
--   message: string; reason to report when this invariant fails.
-- Returns:
--   nil: increments the assertion counter or raises an error.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[World Boss Reward Retry] " .. message)
end

-- Args:
--   store: any; ordinary in-memory persistent-profile adapter.
-- Returns:
--   any: adapter that can fail the next N writes without changing data.
local function failing_adapter(store: any): any
    local adapter = {remaining_failures = 0}

    -- Args:
    --   user_id: number; authoritative account being updated.
    --   transform: (any) -> any; existing profile storage mutation.
    -- Returns:
    --   (any?, string?): stored profile or controlled failure.
    function adapter:update(user_id: number, transform: (any) -> any)
        if self.remaining_failures > 0 then
            self.remaining_failures -= 1
            return nil, "SimulatedProfileSaveFailure"
        end
        return store:update(user_id, transform)
    end

    return adapter
end

-- Args:
--   session_id: string; trusted persistent encounter session.
-- Returns:
--   Model: correctly tagged guardian killed only by the test fixture.
local function defeated_guardian(session_id: string): Model
    local boss = Instance.new("Model")
    boss.Name = "WorldBossRewardRetry_TEMP"
    boss:SetAttribute("WorldBossId", "AncientGuardian")
    boss:SetAttribute("WorldBossInstanceId", session_id)
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = boss
    boss.Parent = workspace
    CollectionService:AddTag(boss, "DungeonMMOWeeklyWorldBoss")
    humanoid.Health = 0
    return boss
end

local now = START_AT + 60
local clock = function(): number
    return now
end

local stored = ProfileAdapter.new()
local adapter = failing_adapter(stored)
local profiles = Profiles.new(adapter)
for _, user_id in ipairs({FIRST_ID, SECOND_ID}) do
    check(profiles:load(user_id) ~= nil,
        "both invited characters must have loaded profiles")
end

local shared_map = MapAdapter.new(clock)
local sessions = Sessions.new(shared_map, clock)
local contributions = Contributions.new(sessions)
local weekly = Weekly.new(profiles, clock)
local bridge = Bridge.new(sessions, weekly, clock)

local session = assert(sessions:create(
    "TestDungeon", {FIRST_ID, SECOND_ID}, 0,
    "WorldBossRewardRetryReserved_TEMP", "Depth1"))
local session_id = session.SessionId
check(sessions:set_instance_state(session_id, {}).ok,
    "persistent world-boss state must be initialized")
check(sessions:mark_connected(session_id, FIRST_ID).ok,
    "contributing player must have entered the encounter")
check(bridge:issue(session_id, START_AT, END_AT).ok,
    "entry must issue one frozen weekly entitlement")
local damage = contributions:record({
    EventId = "WorldBossRewardRetryDamage_TEMP",
    SessionId = session_id,
    UserId = FIRST_ID,
    Type = "DamageDealt",
    Amount = 17,
})
check(damage.ok and ContributionRules.is_eligible(
    contributions:get_player_snapshot(session_id, FIRST_ID)),
    "server-recorded positive boss damage must qualify the player")
check(sessions:set_member_completion_eligibility(
    session_id, FIRST_ID, true).ok,
    "contribution authority must certify the actual party member")
local boss = defeated_guardian(session_id)
check(bridge:record_defeat(session_id, boss).ok,
    "only a tagged instance-matching dead guardian may complete")

adapter.remaining_failures = 1
local failed = bridge:grant_reward(session_id, FIRST_ID)
check(not failed.ok
    and failed.reason == "SimulatedProfileSaveFailure",
    "failed persistent write must never report a paid weekly reward")
check(assert(profiles:get_character(FIRST_ID, 1)).Gold == 100,
    "the original writable profile must retain the dirty entitlement")
local observer = Profiles.new(stored)
check(observer:load(FIRST_ID) ~= nil
    and assert(observer:get_character(FIRST_ID, 1)).Gold == 0,
    "a failed save must not have secretly modified persistent storage")

local retry = bridge:grant_reward(session_id, FIRST_ID)
check(retry.ok and retry.already_applied
    and retry.gold_granted == 0,
    "retry must save the pending first reward without adding gold twice")
check(profiles:release(FIRST_ID, "WorldBossRewardRetryTest"),
    "completed reward can release its owner after a successful save")

local reloaded_profiles = Profiles.new(stored)
check(reloaded_profiles:load(FIRST_ID) ~= nil
    and reloaded_profiles:load(SECOND_ID) ~= nil,
    "fresh service must reload both characters from shared storage")
local next_sessions = Sessions.new(shared_map, clock)
local next_bridge = Bridge.new(next_sessions,
    Weekly.new(reloaded_profiles, clock), clock)
check(next_bridge:resume(session_id).ok,
    "fresh server-style service restores the original defeated event")
local rejoined = next_bridge:grant_reward(session_id, FIRST_ID)
check(rejoined.ok and rejoined.already_applied
    and rejoined.gold_granted == 0
    and assert(reloaded_profiles:get_character(FIRST_ID, 1)).Gold
        == 100,
    "rejoining the same week must not duplicate the persisted reward")
check(next_bridge:grant_reward(session_id, SECOND_ID).reason
    == "WorldBossContributionRequired",
    "the second invited member cannot inherit first player's reward")
boss:Destroy()

print(string.format(
    "[World Boss Reward Retry] PASS: %d assertions.", assertions))
