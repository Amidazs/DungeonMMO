--!strict
-- Local per-instance lifecycle plus a durable character-level weekly
-- reward gate. No client RemoteEvent is allowed to call this service.
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Window = require(
    ReplicatedStorage.Core.Shared:WaitForChild("WeeklyWorldBossWindow")
)

local WeeklyWorldBossService = {}
WeeklyWorldBossService.__index = WeeklyWorldBossService

local BOSS_ID = "AncientGuardian"
local BOSS_TAG = "DungeonMMOWeeklyWorldBoss"
local REWARD_GOLD = 100
local POST_WINDOW_GRACE_SECONDS = 30 * 60
local WEEK_SECONDS = 7 * 24 * 60 * 60
local MAX_PARTICIPANTS = 4

-- Args:
--   value: any; candidate server-known player UserId.
-- Returns:
--   boolean: whether the ID can represent a real player account.
local function valid_user_id(value: any): boolean
    return type(value) == "number" and value > 0
        and value < math.huge and value % 1 == 0
end

-- Args:
--   users: any; trusted list of invited player IDs.
-- Returns:
--   any?: set of validated participant IDs, or nil if invalid.
local function member_set(users: any): any?
    if type(users) ~= "table" or #users < 1
        or #users > MAX_PARTICIPANTS
    then
        return nil
    end

    local members = {}
    for _, user_id in ipairs(users) do
        if not valid_user_id(user_id) or members[user_id] then
            return nil
        end
        members[user_id] = true
    end
    return members
end

-- Args:
--   character: any; character from a loaded player profile.
--   week_key: string; stable server-owned event/week reward identity.
-- Returns:
--   any?: existing persistent reward receipt, if any.
local function reward_record(character: any, week_key: string): any?
    local history = character.RewardHistory
    local weekly = history and history.WeeklyWorldBoss
    return if type(weekly) == "table" then weekly[week_key] else nil
end

-- Args:
--   profiles: any; existing authoritative ProfileService.
--   clock: (() -> number)?; deterministic test or server Unix clock.
-- Returns:
--   any: a new service with no event enabled until explicitly opened.
function WeeklyWorldBossService.new(
    profiles: any,
    clock: (() -> number)?
): any
    assert(profiles ~= nil, "Weekly world boss requires ProfileService")
    return setmetatable({
        _profiles = profiles,
        _clock = clock or os.time,
        _instances = {},
    }, WeeklyWorldBossService)
end

-- Args:
--   instance_id: string; server-issued unique reserved encounter ID.
--   user_ids: {number}; server-approved players for this instance.
--   start_at: number; trusted scheduled event start in Unix UTC.
--   end_at: number; trusted scheduled event end in Unix UTC.
-- Returns:
--   any: admitted frozen weekly window or a reasoned rejection.
function WeeklyWorldBossService:begin_instance(
    instance_id: string,
    user_ids: {number},
    start_at: number,
    end_at: number
): any
    local now = self._clock()
    local window = Window.resolve(now, start_at, end_at)
    if not window.ok then
        return window
    end
    if type(instance_id) ~= "string" or instance_id == ""
        or #instance_id > 128 or self._instances[instance_id] then
        return {ok = false, reason = "InvalidWorldBossInstance"}
    end

    local members = member_set(user_ids)
    if not members then
        return {ok = false, reason = "InvalidWorldBossParty"}
    end
    for user_id in pairs(members) do
        if not self._profiles:get_character(user_id, 1) then
            return {ok = false, reason = "ProfileNotLoaded"}
        end
    end

    self._instances[instance_id] = {
        BossId = BOSS_ID,
        WeekStart = window.WeekStart,
        WindowEnd = window.WindowEnd,
        Members = members,
        Defeated = false,
    }
    return {
        ok = true,
        instance_id = instance_id,
        boss_id = BOSS_ID,
        week_start = window.WeekStart,
        window_end = window.WindowEnd,
    }
end

-- Args:
--   instance_id: string; server-owned encounter instance identity.
--   boss: Model; authoritative boss model spawned by the server.
-- Returns:
--   any: success only after a tagged, matching boss has actually died.
function WeeklyWorldBossService:record_defeat(
    instance_id: string,
    boss: Model
): any
    local state = self._instances[instance_id]
    if not state then
        return {ok = false, reason = "UnknownWorldBossInstance"}
    end
    if typeof(boss) ~= "Instance" or not boss:IsA("Model")
        or not boss:IsDescendantOf(workspace)
        or not CollectionService:HasTag(boss, BOSS_TAG)
        or boss:GetAttribute("WorldBossInstanceId") ~= instance_id
        or boss:GetAttribute("WorldBossId") ~= state.BossId
    then
        return {ok = false, reason = "InvalidWorldBossDefeat"}
    end

    local humanoid = boss:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health > 0 then
        return {ok = false, reason = "WorldBossStillAlive"}
    end
    state.Defeated = true
    return {ok = true, already_defeated = false}
end

-- Args:
--   user_id: number; authoritative eligible party member.
--   state: any; frozen server-side boss instance admission snapshot.
-- Returns:
--   any: once-only reward result from a single profile mutation.
function WeeklyWorldBossService:_grant_to_member(
    user_id: number,
    state: any
): any
    local key = BOSS_ID .. ":" .. tostring(state.WeekStart)
    local result = nil
    local mutated, reason = self._profiles:mutate(
        user_id,
        function(profile: any)
            local character = profile.Characters.Slot1
            local history = character.RewardHistory
            if type(history.WeeklyWorldBoss) ~= "table" then
                history.WeeklyWorldBoss = {}
            end
            local weekly = history.WeeklyWorldBoss
            local previous = weekly[key]
            if previous then
                result = {
                    ok = true, already_applied = true,
                    gold_granted = 0, week_key = key,
                }
                return
            end
            character.Gold += REWARD_GOLD
            weekly[key] = {
                GrantedAt = self._clock(),
                GoldGranted = REWARD_GOLD,
            }
            result = {
                ok = true, already_applied = false,
                gold_granted = REWARD_GOLD, week_key = key,
            }
        end
    )
    if not mutated then
        return {ok = false, reason = reason or "WorldBossRewardFailed"}
    end
    local saved, save_error = self._profiles:save(
        user_id, "WeeklyWorldBossReward")
    if not saved then
        return {ok = false, reason = save_error or "WorldBossSaveFailed"}
    end
    return result
end

-- Args:
--   instance_id: string; known server-issued instance.
--   user_id: number; authenticated member's UserId, never client input.
-- Returns:
--   any: once-per-week saved reward, or a reasoned rejection.
function WeeklyWorldBossService:grant_reward(
    instance_id: string,
    user_id: number
): any
    local state = self._instances[instance_id]
    if not state then
        return {ok = false, reason = "UnknownWorldBossInstance"}
    end
    if not state.Members[user_id] then
        return {ok = false, reason = "NotWorldBossParticipant"}
    end
    if not state.Defeated then
        return {ok = false, reason = "WorldBossNotDefeated"}
    end
    if self._clock() > state.WindowEnd + POST_WINDOW_GRACE_SECONDS then
        return {ok = false, reason = "WorldBossInstanceExpired"}
    end
    if not self._profiles:get_character(user_id, 1) then
        return {ok = false, reason = "ProfileNotLoaded"}
    end
    return self:_grant_to_member(user_id, state)
end

return table.freeze(WeeklyWorldBossService)
