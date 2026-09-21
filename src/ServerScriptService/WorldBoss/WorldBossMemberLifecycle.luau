--!strict
-- Shared per-member death/respawn state for the isolated world boss.
-- It deliberately reuses DungeonSessionService member modes.
local WorldBossMemberLifecycle = {}
WorldBossMemberLifecycle.__index = WorldBossMemberLifecycle

-- Args:
--   sessions: any; authoritative DungeonSessionService.
-- Returns:
--   any: lifecycle helper for one isolated world-boss runtime.
function WorldBossMemberLifecycle.new(sessions: any): any
    assert(sessions ~= nil,
        "World boss lifecycle requires DungeonSessionService")
    return setmetatable({
        _sessions = sessions,
    }, WorldBossMemberLifecycle)
end

-- Args:
--   session_id: string; active server-issued world-boss session.
--   user_id: number; authenticated member who has a live character.
-- Returns:
--   any: session mutation result.
function WorldBossMemberLifecycle:mark_active(
    session_id: string,
    user_id: number
): any
    return self._sessions:set_member_mode(
        session_id, user_id, "Active")
end

-- Args:
--   session_id: string; active world-boss session.
--   user_id: number; authenticated member whose Humanoid died.
-- Returns:
--   any: persisted dead-state mutation result.
function WorldBossMemberLifecycle:mark_dead(
    session_id: string,
    user_id: number
): any
    return self._sessions:set_member_mode(
        session_id, user_id, "Dead")
end

-- Args:
--   session_id: string; stored world-boss session.
--   user_id: number; member considered for a server respawn.
-- Returns:
--   boolean: true only for a connected, non-abandoned dead member.
function WorldBossMemberLifecycle:can_respawn(
    session_id: string,
    user_id: number
): boolean
    local session = self._sessions:get(session_id)
    if not session or session.State ~= "Active" then
        return false
    end
    local member = session.Members
        and session.Members[tostring(user_id)]
    if not member or member.Connected ~= true
        or member.Abandoned == true
        or member.Mode ~= "Dead"
    then
        return false
    end
    return type(session.InstanceState) == "table"
        and type(session.InstanceState.WeeklyWorldBoss) == "table"
end

return table.freeze(WorldBossMemberLifecycle)
