--!strict
-- First world-boss backend milestone: calendar, trusted instance admission,
-- authenticated party, real-boss proof and saved per-character weekly reward.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")

local Window = require(
    ReplicatedStorage.Core.Shared:WaitForChild("WeeklyWorldBossWindow")
)
local Core = SSS:WaitForChild("Core")
local Profiles = require(Core.Services.ProfileService)
local Adapter = require(Core.Adapters.InMemoryProfileAdapter)
local WorldBoss = require(Core.Services.WeeklyWorldBossService)

local WEEK_SECONDS = 604800
local WEEK_START = 345600 + WEEK_SECONDS * 3000
local START_AT = WEEK_START + 3600
local END_AT = START_AT + 3600
local FIRST_USER = 81001
local SECOND_USER = 81002
local OUTSIDER = 81003

local assertions = 0
local now = START_AT + 60

-- Args:
--   condition: boolean; expected weekly event invariant.
--   description: string; identifies the failed rule.
-- Returns:
--   nil: records success or raises an actionable failure.
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[Weekly World Boss] " .. description)
end

-- Args:
--   instance_id: string; trusted server instance identity.
--   boss_id: string; expected registered world-boss identity.
-- Returns:
--   Model: disposable, authoritative dead boss model for proof.
local function create_boss(
    instance_id: string,
    boss_id: string
): Model
    local model = Instance.new("Model")
    model.Name = "WeeklyWorldBossTest_TEMP"
    model:SetAttribute("WorldBossId", boss_id)
    model:SetAttribute("WorldBossInstanceId", instance_id)
    local humanoid = Instance.new("Humanoid")
    humanoid.BreakJointsOnDeath = false
    humanoid.Parent = model
    model.Parent = workspace
    humanoid.Health = 0
    CollectionService:AddTag(model, "DungeonMMOWeeklyWorldBoss")
    return model
end

-- Args:
--   service: any; server world-boss lifecycle.
--   instance_id: string; unique server-issued instance identity.
--   members: {number}; group of independently loaded profile IDs.
--   start_at: number; current event window start.
--   end_at: number; exclusive event window end.
-- Returns:
--   any: the server-issued entry snapshot, failing if rejected.
local function begin(
    service: any,
    instance_id: string,
    members: {number},
    start_at: number,
    end_at: number
): any
    local entry = service:begin_instance(
        instance_id, members, start_at, end_at)
    check(entry.ok and entry.instance_id == instance_id,
        "authorized group must receive a server-owned entry snapshot")
    return entry
end

check(Window.week_start(START_AT) == WEEK_START,
    "weekly reward reset must be Monday 00:00 UTC")
check(Window.week_start(START_AT + WEEK_SECONDS)
    == WEEK_START + WEEK_SECONDS,
    "following Monday must have a distinct reward identity")
check(Window.week_start(0) == -259200,
    "the UTC reset calculation must handle the Unix epoch")
check(Window.week_start(math.huge) == nil,
    "invalid timestamps cannot create a weekly entitlement")
check(Window.resolve(START_AT - 1, START_AT, END_AT).reason
    == "WorldBossEntryClosed",
    "entry before the event start must be denied")
check(Window.resolve(END_AT, START_AT, END_AT).reason
    == "WorldBossEntryClosed",
    "event end is exclusive, and late entry must be denied")
check(Window.resolve(now, START_AT, END_AT + 3601).reason
    == "InvalidWorldBossWindow",
    "configured event length cannot exceed two hours")
check(Window.resolve(WEEK_START + WEEK_SECONDS - 100,
    WEEK_START + WEEK_SECONDS - 200,
    WEEK_START + WEEK_SECONDS + 100).reason == "CrossesWeeklyReset",
    "a single event cannot straddle the weekly reward reset")
check(Window.resolve(now, START_AT, END_AT).ok,
    "entry inside the active authorized window must be allowed")

local adapter = Adapter.new()
local profiles = Profiles.new(adapter)
check(profiles:load(FIRST_USER) ~= nil
    and profiles:load(SECOND_USER) ~= nil
    and profiles:load(OUTSIDER) ~= nil,
    "each participant requires an independent loaded in-memory profile")
local service = WorldBoss.new(profiles, function()
    return now
end)

check(service:begin_instance(
    "early", {FIRST_USER}, START_AT + 100, END_AT).reason
    == "WorldBossEntryClosed",
    "future event cannot be opened early")
check(service:begin_instance(
    "invalid", {FIRST_USER, FIRST_USER}, START_AT, END_AT).reason
    == "InvalidWorldBossParty",
    "duplicate participant IDs cannot join one instance")
check(service:begin_instance(
    "missing", {99999}, START_AT, END_AT).reason
    == "ProfileNotLoaded",
    "unloaded players cannot be admitted into a reward instance")

local first = begin(service, "instance-a",
    {FIRST_USER, SECOND_USER}, START_AT, END_AT)
check(first.week_start == WEEK_START
    and first.boss_id == "AncientGuardian",
    "weekly identity and boss must be frozen at entry")
check(service:begin_instance(
    "instance-a", {FIRST_USER}, START_AT, END_AT).reason
    == "InvalidWorldBossInstance",
    "repeated instance IDs cannot reroll encounter membership")
check(service:grant_reward("instance-a", FIRST_USER).reason
    == "WorldBossNotDefeated",
    "joining without defeating the boss cannot grant a reward")
check(service:grant_reward("instance-a", OUTSIDER).reason
    == "NotWorldBossParticipant",
    "an outsider cannot request this instance's weekly reward")

local boss = create_boss("instance-a", "AncientGuardian")
check(service:record_defeat("instance-b", boss).reason
    == "UnknownWorldBossInstance",
    "a fabricated instance cannot complete a boss encounter")
local humanoid = assert(boss:FindFirstChildOfClass("Humanoid"))
humanoid.Health = 100
check(service:record_defeat("instance-a", boss).reason
    == "WorldBossStillAlive",
    "a living boss cannot be marked defeated")
humanoid.Health = 0
boss:SetAttribute("WorldBossInstanceId", "instance-b")
check(service:record_defeat("instance-a", boss).reason
    == "InvalidWorldBossDefeat",
    "another instance's boss cannot complete this encounter")
boss:SetAttribute("WorldBossInstanceId", "instance-a")
local defeated = service:record_defeat("instance-a", boss)
check(defeated.ok and not defeated.already_defeated,
    "matching server-tagged dead boss completes its instance")
check(service:record_defeat("instance-a", boss).already_defeated,
    "duplicate death processing must be idempotent")

local first_reward = service:grant_reward("instance-a", FIRST_USER)
check(first_reward.ok and not first_reward.already_applied
    and first_reward.gold_granted == 100,
    "first eligible player receives the configured weekly gold")
check(assert(profiles:get_character(FIRST_USER, 1)).Gold == 100,
    "world-boss reward must update the loaded authoritative profile")
local duplicate = service:grant_reward("instance-a", FIRST_USER)
check(duplicate.ok and duplicate.already_applied
    and duplicate.gold_granted == 0,
    "repeated completion of one instance cannot duplicate gold")
local second_reward = service:grant_reward("instance-a", SECOND_USER)
check(second_reward.ok and second_reward.gold_granted == 100,
    "other eligible player receives an independent weekly reward")

begin(service, "instance-b", {FIRST_USER, SECOND_USER},
    START_AT, END_AT)
local second_boss = create_boss("instance-b", "AncientGuardian")
check(service:record_defeat("instance-b", second_boss).ok,
    "separate event instance can complete independently")
local other_instance = service:grant_reward("instance-b", FIRST_USER)
check(other_instance.ok and other_instance.already_applied
    and other_instance.gold_granted == 0,
    "a second instance in the SAME week cannot duplicate the reward")
check(assert(profiles:get_character(FIRST_USER, 1)).Gold == 100,
    "second instance cannot change a locked character's gold")

check(profiles:release(FIRST_USER, "WeeklyWorldBossTest"),
    "completed reward must persist when the profile is released")
local reloaded_profiles = Profiles.new(adapter)
check(reloaded_profiles:load(FIRST_USER) ~= nil,
    "same account must reload from the shared persisted test adapter")
local reloaded_service = WorldBoss.new(reloaded_profiles, function()
    return now
end)
begin(reloaded_service, "instance-c", {FIRST_USER},
    START_AT, END_AT)
local third_boss = create_boss("instance-c", "AncientGuardian")
check(reloaded_service:record_defeat("instance-c", third_boss).ok,
    "fresh server-style service can independently complete an instance")
local after_reload = reloaded_service:grant_reward(
    "instance-c", FIRST_USER)
check(after_reload.ok and after_reload.already_applied
    and assert(reloaded_profiles:get_character(FIRST_USER, 1)).Gold
        == 100,
    "weekly lockout must survive profile release and fresh reload")

now = END_AT + 1801
check(reloaded_service:grant_reward("instance-c", FIRST_USER).reason
    == "WorldBossInstanceExpired",
    "completed instance cannot grant a reward after its grace period")
now = START_AT + WEEK_SECONDS + 60
local next_start = START_AT + WEEK_SECONDS
local next_end = END_AT + WEEK_SECONDS
begin(reloaded_service, "instance-next", {FIRST_USER},
    next_start, next_end)
local next_boss = create_boss("instance-next", "AncientGuardian")
check(reloaded_service:record_defeat("instance-next", next_boss).ok,
    "the new weekly window admits its own real-boss proof")
local new_week = reloaded_service:grant_reward(
    "instance-next", FIRST_USER)
check(new_week.ok and not new_week.already_applied
    and assert(reloaded_profiles:get_character(FIRST_USER, 1)).Gold
        == 200,
    "the same character becomes eligible again the following week")

boss:Destroy()
second_boss:Destroy()
third_boss:Destroy()
next_boss:Destroy()
print(string.format(
    "[Weekly World Boss] PASS: %d assertions.", assertions))
