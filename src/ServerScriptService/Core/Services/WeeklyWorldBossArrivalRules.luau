--!strict
-- Dedicated destination admission: teleport routing is never authority.
-- Session, destination binding and an existing handoff nonce must agree.
local WeeklyWorldBossArrivalRules = {}

-- Args:
--   session: any; record loaded from the server session adapter.
--   teleport_data: any; untrusted join routing values.
--   user_id: number; authenticated Player.UserId.
--   place_id: number; actual running dedicated boss place ID.
-- Returns:
--   any: accepted session routing or a concrete rejection reason.
function WeeklyWorldBossArrivalRules.validate(
    session: any,
    teleport_data: any,
    user_id: number,
    place_id: number
): any
    if type(session) ~= "table"
        or (session.State ~= "Creating" and session.State ~= "Active")
    then
        return {ok = false, reason = "WorldBossSessionNotActive"}
    end
    if type(teleport_data) ~= "table"
        or teleport_data.WorldBoss ~= true
        or teleport_data.SessionId ~= session.SessionId
        or teleport_data.DungeonId ~= session.DungeonId
    then
        return {ok = false, reason = "WorldBossRoutingMismatch"}
    end

    local snapshot = session.InstanceState
        and session.InstanceState.WeeklyWorldBoss
    if type(snapshot) ~= "table"
        or snapshot.BossId ~= "AncientGuardian"
        or snapshot.DestinationPlaceId ~= place_id
        or type(place_id) ~= "number" or place_id <= 0
    then
        return {ok = false, reason = "WorldBossDestinationMismatch"}
    end
    local member = session.Members
        and session.Members[tostring(user_id)]
    if not member or member.Abandoned == true then
        return {ok = false, reason = "NotWorldBossParticipant"}
    end
    local enrolled = false
    for _, member_id in ipairs(snapshot.Members or {}) do
        if member_id == user_id then
            enrolled = true
            break
        end
    end
    if not enrolled then
        return {ok = false, reason = "WorldBossMemberMismatch"}
    end
    if type(session.ReservedAccessCode) ~= "string"
        or session.ReservedAccessCode == ""
    then
        return {ok = false, reason = "WorldBossReservationMissing"}
    end
    return {ok = true, session = session, snapshot = snapshot}
end

return table.freeze(WeeklyWorldBossArrivalRules)
