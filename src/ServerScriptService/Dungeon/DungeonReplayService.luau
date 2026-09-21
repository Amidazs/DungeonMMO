--!strict
-- Replays a completed or failed dungeon in a NEW reserved session.
-- Every still-connected party member must explicitly vote to replay.
local DungeonReplayService = {}
DungeonReplayService.__index = DungeonReplayService

-- Args:
--   ok: boolean; whether the requested action succeeded.
--   reason: string?; explanatory rejection for an invalid request.
--   extra: any?; optional response fields.
-- Returns:
--   any: a compact operation result.
local function result(ok: boolean, reason: string?, extra: any?): any
    local response = extra or {}
    response.ok = ok
    response.reason = reason
    return response
end

-- Args:
--   sessions: any; authoritative persisted dungeon session service.
--   coordinator: any; standard new-run teleport and profile handoff.
--   options: any; safe Studio and readiness callbacks.
-- Returns:
--   any: replay coordinator for one Dungeon server.
function DungeonReplayService.new(
    sessions: any,
    coordinator: any,
    options: any
): any
    assert(sessions and coordinator and type(options) == "table",
        "DungeonReplayService requires session and transport services")
    assert(type(options.is_player_ready) == "function",
        "DungeonReplayService requires authoritative player readiness")
    return setmetatable({
        _sessions = sessions,
        _coordinator = coordinator,
        _is_studio = options.is_studio == true,
        _is_player_ready = options.is_player_ready,
        _destination_place_id = options.destination_place_id,
        _votes = {},
        _launching = false,
    }, DungeonReplayService)
end

-- Args:
--   session: any; terminal run whose current party may replay.
--   players: {any}; connected players actually present in this server.
-- Returns:
--   {any}: validated live party, or nil plus a reason.
local function connected_party(
    self: any,
    session: any,
    players: {any}
): ({any}?, string?)
    local party = {}
    for _, player in ipairs(players) do
        local member = session.Members
            and session.Members[tostring(player.UserId)]
        if member and member.Connected == true
            and member.Abandoned ~= true
            and self._is_player_ready(player) == true
        then
            table.insert(party, player)
        end
    end

    for _, member in pairs(session.Members or {}) do
        if member.Connected == true and member.Abandoned ~= true then
            local present = false
            for _, player in ipairs(party) do
                if player.UserId == member.UserId then
                    present = true
                    break
                end
            end
            if not present then
                return nil, "PartyMemberNotReady"
            end
        end
    end
    if #party == 0 then
        return nil, "NoConnectedMembers"
    end
    table.sort(party, function(a, b)
        return a.UserId < b.UserId
    end)
    return party, nil
end

-- Args:
--   session_id: string; existing terminal dungeon session.
--   player: any; requesting player authenticated by OnServerEvent.
--   present_players: {any}; real connected clients on this server.
-- Returns:
--   any: waiting count, simulated outcome or real reserved teleport.
function DungeonReplayService:request(
    session_id: string,
    player: any,
    present_players: {any}
): any
    if self._launching then
        return result(false, "ReplayAlreadyStarting")
    end
    local session = self._sessions:get(session_id)
    if not session then
        return result(false, "SessionNotFound")
    end
    if session.State ~= "Failed"
        and not (session.State == "Complete"
            and session.CompletionRewardsCommitted == true)
    then
        return result(false, "SessionNotReplayable")
    end

    local party, party_error = connected_party(
        self, session, present_players
    )
    if not party then
        return result(false, party_error)
    end

    local requester_is_member = false
    for _, member in ipairs(party) do
        if member.UserId == player.UserId then
            requester_is_member = true
            break
        end
    end
    if not requester_is_member then
        return result(false, "NotConnectedMember")
    end

    self._votes[player.UserId] = true
    local waiting = 0
    for _, member in ipairs(party) do
        if self._votes[member.UserId] ~= true then
            waiting += 1
        end
    end
    if waiting > 0 then
        return result(true, nil, {waiting = waiting})
    end

    if self._is_studio then
        self._launching = true
        return result(true, nil, {
            simulated = true,
            party_size = #party,
        })
    end
    if type(self._destination_place_id) ~= "number"
        or self._destination_place_id <= 0
    then
        return result(false, "DungeonPlaceIdNotConfigured")
    end

    self._launching = true
    local started = self._coordinator:start_dungeon(
        party,
        session.DungeonId,
        self._destination_place_id,
        session.Difficulty and session.Difficulty.Id or nil,
        session.ReturnPlaceId
    )
    if not started or started.ok ~= true then
        self._launching = false
        -- Consent belongs to one launch attempt. After a failure,
        -- every remaining member must explicitly choose replay again.
        self._votes = {}
        return result(false,
            started and started.reason or "ReplayTeleportFailed")
    end
    return result(true, nil, {
        party_size = #party,
        session = started.session,
    })
end

return table.freeze(DungeonReplayService)
