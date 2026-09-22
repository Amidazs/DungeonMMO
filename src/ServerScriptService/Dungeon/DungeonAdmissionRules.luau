--!strict
local DungeonAdmissionRules = {}

local function result(ok: boolean, reason: string?): any
    return {ok = ok, reason = reason}
end

function DungeonAdmissionRules.validate(
    session: any,
    teleport_data: any,
    user_id: number,
    expected_dungeon_id: string
): any
    if type(session) ~= "table" then
        return result(false, "SessionNotFound")
    end
    if type(session.InstanceState) == "table"
        and session.InstanceState.WeeklyWorldBoss ~= nil
    then
        return result(false, "WorldBossDedicatedPlaceRequired")
    end
    if type(teleport_data) ~= "table" then
        return result(false, "MissingTeleportData")
    end
    if teleport_data.SessionId ~= session.SessionId then
        return result(false, "SessionIdMismatch")
    end
    if teleport_data.DungeonId ~= expected_dungeon_id or session.DungeonId ~= expected_dungeon_id then
        return result(false, "DungeonIdMismatch")
    end
    if session.State ~= "Creating" and session.State ~= "Active" then
        return result(false, "SessionNotActive")
    end
    local member = type(session.Members) == "table"
        and session.Members[tostring(user_id)]
    if type(member) ~= "table" then
        return result(false, "NotMember")
    end
    if member.Abandoned == true then
        return result(false, "MemberAbandoned")
    end
    return result(true, nil)
end

-- Determines whether the same running Dungeon server may admit a
-- previously connected member after their original handoff nonce was
-- consumed. The caller must still authenticate the Roblox Player,
-- validate join routing, and claim the profile lease independently.
--
-- Args:
--   session (any): Persisted server-owned dungeon session.
--   user_id (number): Authenticated Roblox Player.UserId.
--   active_session_id (string?): Current server's bound session ID.
--
-- Returns:
--   any: Allowed operation or an explicit fail-closed reason.
function DungeonAdmissionRules.same_server_reconnect(
    session: any,
    user_id: number,
    active_session_id: string?
): any
    if type(session) ~= "table"
        or session.State ~= "Active"
        or type(active_session_id) ~= "string"
        or active_session_id == ""
        or active_session_id ~= session.SessionId
    then
        return result(false, "NotCurrentDungeonServer")
    end

    local member = type(session.Members) == "table"
        and session.Members[tostring(user_id)]
    if type(member) ~= "table"
        or member.UserId ~= user_id
        or member.Abandoned == true
    then
        return result(false, "NotEligibleMember")
    end

    if member.Connected ~= false
        or type(member.LastConnectedAt) ~= "number"
        or type(member.LastDisconnectedAt) ~= "number"
    then
        return result(false, "MemberNotDisconnected")
    end

    return result(true, nil)
end

return table.freeze(DungeonAdmissionRules)
