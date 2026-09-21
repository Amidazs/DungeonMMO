--!strict
-- Focused contribution contract for the separate weekly boss runtime.
-- Exercise the actual authoritative service response, not a fake shape.
local SSS = game:GetService("ServerScriptService")
local Core = SSS:WaitForChild("Core")
local Adapter = require(Core.Adapters.InMemoryMapAdapter)
local Sessions = require(Core.Services.DungeonSessionService)
local Contributions = require(Core.Services.ContributionService)
local Rules = require(Core.Services.WorldBossContributionRules)

local assertions = 0
local FIRST_ID = 95501
local SECOND_ID = 95502

-- Args:
--   condition: boolean; world-boss contribution requirement.
--   description: string; actionable failure description.
-- Returns:
--   nil: records the check or raises an error.
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[World Boss Contribution] " .. description)
end

check(not Rules.is_eligible(nil)
    and not Rules.is_eligible({ok = false, Damage = 100}),
    "missing or rejected service responses cannot earn a reward")
check(not Rules.is_eligible({ok = true, Damage = math.huge}),
    "non-finite contribution totals cannot authorize a payout")
check(not Rules.is_eligible({ok = true, Damage = 0, Tank = 0,
    Support = 0}), "mere party admission is not contribution")
check(Rules.is_eligible({ok = true, Support = 3}),
    "server-recorded support must count independently of damage")

local sessions = Sessions.new(Adapter.new())
local session, error_message = sessions:create(
    "TestDungeon", {FIRST_ID, SECOND_ID}, 0,
    "WorldBossContributionTestReserved", "Depth1")
check(session ~= nil and error_message == nil,
    "the real session service must create an authorized party")
local session_id = session.SessionId
check(sessions:set_instance_state(session_id, {}).ok,
    "a durable session snapshot must exist")
check(sessions:mark_connected(session_id, FIRST_ID).ok,
    "the first real party member activates this test run")
local contributions = Contributions.new(sessions)

local empty = contributions:get_player_snapshot(
    session_id, FIRST_ID)
check(empty.ok and empty.snapshot == nil
    and not Rules.is_eligible(empty),
    "the real response has top-level channels and starts ineligible")
local applied = contributions:record({
    EventId = "world-boss-damage-1",
    SessionId = session_id,
    UserId = FIRST_ID,
    Type = "DamageDealt",
    Amount = 12,
})
check(applied.ok, "real contribution service must persist damage")
local damage = contributions:get_player_snapshot(
    session_id, FIRST_ID)
check(damage.ok and damage.Damage == 12
    and Rules.is_eligible(damage),
    "actual top-level Damage field must unlock a contributor")
check(not Rules.is_eligible(
    contributions:get_player_snapshot(session_id, SECOND_ID)),
    "non-contributing invited member remains ineligible")
local support = contributions:record({
    EventId = "world-boss-support-1",
    SessionId = session_id,
    UserId = SECOND_ID,
    Type = "EffectiveHealing",
    Amount = 5,
})
check(support.ok, "server-recorded healing must persist independently")
check(Rules.is_eligible(
    contributions:get_player_snapshot(session_id, SECOND_ID)),
    "actual top-level Support field must unlock a support participant")
local recovered = Contributions.new(Sessions.new(
    sessions._map))
check(Rules.is_eligible(
    recovered:get_player_snapshot(session_id, FIRST_ID)),
    "fresh service reading the same durable adapter recovers eligibility")

print(string.format(
    "[World Boss Contribution] PASS: %d assertions.", assertions))
