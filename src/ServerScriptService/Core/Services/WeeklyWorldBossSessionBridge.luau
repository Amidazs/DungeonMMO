--!strict
-- Server-only bridge between the existing durable dungeon session map
-- and the separately authenticated weekly world-boss reward authority.
-- This is NOT a public Base portal or a new dungeon teleport route.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Window = require(
    ReplicatedStorage.Core.Shared:WaitForChild("WeeklyWorldBossWindow")
)

local WeeklyWorldBossSessionBridge = {}
WeeklyWorldBossSessionBridge.__index = WeeklyWorldBossSessionBridge

local BOSS_ID = "AncientGuardian"

-- Args:
--   sessions: any; existing durable DungeonSessionService.
--   weekly: any; existing WeeklyWorldBossService.
--   clock: (() -> number)?; trusted Unix clock for tests or runtime.
-- Returns:
--   any: server-only instance state and reward bridge.
function WeeklyWorldBossSessionBridge.new(
    sessions: any,
    weekly: any,
    clock: (() -> number)?
): any
    assert(sessions ~= nil and weekly ~= nil,
        "World boss bridge requires session and reward services")
    return setmetatable({
        _sessions = sessions,
        _weekly = weekly,
        _clock = clock or os.time,
    }, WeeklyWorldBossSessionBridge)
end

-- Args:
--   session: any; stored dungeon record from authoritative adapter.
-- Returns:
--   {number}?: actual party membership from the frozen session.
local function member_ids(session: any): {number}?
    if type(session) ~= "table"
        or type(session.MemberUserIds) ~= "table"
        or type(session.Members) ~= "table"
    then
        return nil
    end
    local result = {}
    for _, user_id in ipairs(session.MemberUserIds) do
        if not session.Members[tostring(user_id)] then
            return nil
        end
        table.insert(result, user_id)
    end
    return result
end

-- Args:
--   session_id: string; already-created authoritative dungeon session.
--   start_at: number; trusted explicit UTC start of scheduled event.
--   end_at: number; trusted exclusive UTC end of scheduled event.
--   destination_place_id: number?; explicit dedicated world-boss place.
-- Returns:
--   any: once-only durable session snapshot or a reasoned rejection.
function WeeklyWorldBossSessionBridge:issue(
    session_id: string,
    start_at: number,
    end_at: number,
    destination_place_id: number?
): any
    local window = Window.resolve(self._clock(), start_at, end_at)
    if not window.ok then
        return window
    end
    if destination_place_id ~= nil and (
        type(destination_place_id) ~= "number"
        or destination_place_id <= 0
        or destination_place_id % 1 ~= 0
    ) then
        return {ok = false, reason = "InvalidWorldBossPlaceId"}
    end
    local session = self._sessions:get(session_id)
    if not session or (session.State ~= "Creating"
        and session.State ~= "Active")
    then
        return {ok = false, reason = "WorldBossSessionNotActive"}
    end
    local users = member_ids(session)
    if not users then
        return {ok = false, reason = "InvalidWorldBossParty"}
    end
    local current = session.InstanceState
    if type(current) ~= "table" or current.WeeklyWorldBoss then
        return {ok = false, reason = "WorldBossAlreadyIssued"}
    end

    local approved = self._weekly:begin_instance(
        session_id, users, start_at, end_at)
    if not approved.ok then
        return approved
    end
    local snapshot = {
        BossId = BOSS_ID,
        DestinationPlaceId = destination_place_id,
        WeekStart = window.WeekStart,
        WindowStart = start_at,
        WindowEnd = end_at,
        Members = users,
        Defeated = false,
    }
    local issued = false
    local updated = self._sessions:update_instance_state(
        session_id,
        function(state: any)
            if state.WeeklyWorldBoss == nil then
                state.WeeklyWorldBoss = snapshot
                issued = true
            end
            return state, nil
        end
    )
    if not updated.ok then
        return {ok = false, reason = updated.reason}
    end
    if not issued then
        return {ok = false, reason = "WorldBossAlreadyIssued"}
    end
    return {ok = true, snapshot = snapshot, session = updated.session}
end

-- Args:
--   session_id: string; stored authoritative session identity.
-- Returns:
--   any: frozen, validated event snapshot plus current session.
function WeeklyWorldBossSessionBridge:resume(session_id: string): any
    local session = self._sessions:get(session_id)
    if not session or (session.State ~= "Creating"
        and session.State ~= "Active")
    then
        return {ok = false, reason = "WorldBossSessionNotActive"}
    end
    local snapshot = session.InstanceState
        and session.InstanceState.WeeklyWorldBoss
    if type(snapshot) ~= "table" then
        return {ok = false, reason = "WorldBossNotIssued"}
    end
    local members = member_ids(session)
    if not members or type(snapshot.Members) ~= "table"
        or #members ~= #snapshot.Members then
        return {ok = false, reason = "WorldBossMemberMismatch"}
    end
    local enrolled = {}
    for _, user_id in ipairs(snapshot.Members) do
        enrolled[user_id] = true
    end
    for _, user_id in ipairs(members) do
        if not enrolled[user_id] then
            return {ok = false, reason = "WorldBossMemberMismatch"}
        end
    end
    local restored = self._weekly:restore_instance(
        session_id, snapshot)
    if not restored.ok then
        return restored
    end
    return {ok = true, snapshot = snapshot, session = session}
end

-- Args:
--   session_id: string; server-issued session identity.
--   boss: Model; dead, tagged and instance-matching authoritative boss.
-- Returns:
--   any: once-only durable defeat snapshot or a reasoned rejection.
function WeeklyWorldBossSessionBridge:record_defeat(
    session_id: string,
    boss: Model
): any
    local resumed = self:resume(session_id)
    if not resumed.ok then
        return resumed
    end
    local defeated = self._weekly:record_defeat(session_id, boss)
    if not defeated.ok then
        return defeated
    end
    local updated = self._sessions:update_instance_state(
        session_id,
        function(state: any)
            local snapshot = state.WeeklyWorldBoss
            if type(snapshot) == "table" then
                snapshot.Defeated = true
            end
            return state, nil
        end
    )
    return if updated.ok
        then {ok = true, already_defeated = defeated.already_defeated}
        else {ok = false, reason = updated.reason}
end

-- Args:
--   session_id: string; authoritative active encounter.
--   user_id: number; authenticated player ID, not client-supplied.
-- Returns:
--   any: persisted once-per-week reward for a proven participant.
function WeeklyWorldBossSessionBridge:grant_reward(
    session_id: string,
    user_id: number
): any
    local resumed = self:resume(session_id)
    if not resumed.ok then
        return resumed
    end
    local member = resumed.session.Members[tostring(user_id)]
    if not member or member.Abandoned == true then
        return {ok = false, reason = "NotWorldBossParticipant"}
    end
    if member.CompletionEligibleBeforeDeath ~= true then
        return {ok = false, reason = "WorldBossContributionRequired"}
    end
    if resumed.snapshot.Defeated ~= true then
        return {ok = false, reason = "WorldBossNotDefeated"}
    end
    return self._weekly:grant_reward(session_id, user_id)
end

return table.freeze(WeeklyWorldBossSessionBridge)
