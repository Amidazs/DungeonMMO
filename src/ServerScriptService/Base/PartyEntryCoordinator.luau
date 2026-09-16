--!strict
-- Thin bridge from Base-local party state into the accepted TeleportCoordinator.
local PartyEntryCoordinator = {}
PartyEntryCoordinator.__index = PartyEntryCoordinator

local function response(ok: boolean, reason: string?, extra: any?): any
    local out = extra or {}
    out.ok = ok
    out.reason = reason
    return out
end

function PartyEntryCoordinator.new(options: any): any
    assert(type(options) == "table", "options required")
    assert(options.party_service, "party_service required")
    assert(type(options.player_provider) == "function", "player_provider required")
    assert(type(options.validate_member) == "function", "validate_member required")
    assert(options.coordinator, "coordinator required")
    assert(type(options.place_id_provider) == "function", "place_id_provider required")

    return setmetatable({
        _party = options.party_service,
        _player_provider = options.player_provider,
        _validate_member = options.validate_member,
        _coordinator = options.coordinator,
        _place_id_provider = options.place_id_provider,
        _is_studio = options.is_studio == true,
    }, PartyEntryCoordinator)
end

function PartyEntryCoordinator:start(requester: any): any
    local prepared = self._party:prepare_entry(requester.UserId)
    if not prepared.ok then
        return prepared
    end

    local players = {}
    for _, user_id in ipairs(prepared.MemberUserIds) do
        local player = self._player_provider(user_id)
        if not player then
            return response(false, "PartyMemberMissing", {
                MemberUserId = user_id,
                DungeonId = prepared.DungeonId,
            })
        end

        local validation = self._validate_member(player)
        if not validation or validation.ok ~= true then
            return response(false, (validation and validation.reason) or "PartyMemberInvalid", {
                MemberUserId = user_id,
                MemberName = player.Name,
                DungeonId = prepared.DungeonId,
            })
        end

        table.insert(players, player)
    end

    if #players < 1 or #players > 4 then
        return response(false, "PlayerCountOutOfRange")
    end

    if self._is_studio and #players > 1 then
        return response(true, "StudioPartyEntryProof", {
            DungeonId = prepared.DungeonId,
            Players = players,
            MemberUserIds = prepared.MemberUserIds,
            PartyId = prepared.PartyId,
        })
    end

    local dungeon_place_id, place_error = self._place_id_provider()
    if not dungeon_place_id then
        return response(false, place_error or "DungeonPlaceIdNotConfigured", {
            DungeonId = prepared.DungeonId,
        })
    end

    local result = self._coordinator:start_dungeon(players, prepared.DungeonId, dungeon_place_id)
    if type(result) ~= "table" then
        return response(false, "DungeonStartFailed")
    end
    return result
end

return PartyEntryCoordinator
