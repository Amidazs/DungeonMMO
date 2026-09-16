--!strict
-- Server-local Base party state. This intentionally does not persist to Profile/DataStore.
local PartyService = {}
PartyService.__index = PartyService

export type PartyMember = {
    UserId: number,
    Name: string,
    DisplayName: string,
    Ready: boolean,
    JoinOrder: number,
}

export type Party = {
    PartyId: string,
    LeaderUserId: number,
    SelectedDungeonId: string,
    Members: {PartyMember},
}

local function result(ok: boolean, reason: string?, extra: any?): any
    local out = extra or {}
    out.ok = ok
    out.reason = reason
    return out
end

local function clone_member(member: PartyMember): PartyMember
    return {
        UserId = member.UserId,
        Name = member.Name,
        DisplayName = member.DisplayName,
        Ready = member.Ready,
        JoinOrder = member.JoinOrder,
    }
end

local function clone_party(party: Party): Party
    local members = {}
    for _, member in ipairs(party.Members) do
        table.insert(members, clone_member(member))
    end
    return {
        PartyId = party.PartyId,
        LeaderUserId = party.LeaderUserId,
        SelectedDungeonId = party.SelectedDungeonId,
        Members = members,
    }
end

local function player_name(player: any): string
    return tostring(player.Name or ("Player" .. tostring(player.UserId)))
end

local function display_name(player: any): string
    return tostring(player.DisplayName or player.Name or ("Player" .. tostring(player.UserId)))
end

function PartyService.new(options: any?): any
    options = options or {}
    return setmetatable({
        _parties = {},
        _party_by_user = {},
        _invites = {},
        _next_party_id = 0,
        _next_join_order = 0,
        _invite_seconds = tonumber(options.invite_seconds) or 30,
        _is_valid_dungeon = options.is_valid_dungeon or function(dungeon_id: string): boolean
            return dungeon_id == "TestDungeon" or dungeon_id == "AbandonedMine"
        end,
    }, PartyService)
end

function PartyService:_now(now: number?): number
    return now or os.clock()
end

function PartyService:_party_for_user(user_id: number): Party?
    local party_id = self._party_by_user[user_id]
    if not party_id then
        return nil
    end
    return self._parties[party_id]
end

function PartyService:party_for_user(user_id: number): Party?
    local party = self:_party_for_user(user_id)
    return if party then clone_party(party) else nil
end

function PartyService:party_size(user_id: number): number
    local party = self:_party_for_user(user_id)
    return if party then #party.Members else 0
end

function PartyService:_member(party: Party, user_id: number): PartyMember?
    for _, member in ipairs(party.Members) do
        if member.UserId == user_id then
            return member
        end
    end
    return nil
end

function PartyService:_clear_readiness(party: Party)
    for _, member in ipairs(party.Members) do
        member.Ready = false
    end
end

function PartyService:_cancel_party_invites(party_id: string): {number}
    local affected = {}
    for target_user_id, invite in pairs(self._invites) do
        if invite.PartyId == party_id then
            self._invites[target_user_id] = nil
            table.insert(affected, target_user_id)
        end
    end
    return affected
end

function PartyService:_new_member(player: any): PartyMember
    self._next_join_order += 1
    return {
        UserId = player.UserId,
        Name = player_name(player),
        DisplayName = display_name(player),
        Ready = false,
        JoinOrder = self._next_join_order,
    }
end

function PartyService:create(player: any): any
    local user_id = player.UserId
    if self._party_by_user[user_id] then
        return result(false, "AlreadyInParty")
    end

    self._next_party_id += 1
    local party_id = "Party-" .. tostring(self._next_party_id)
    local party: Party = {
        PartyId = party_id,
        LeaderUserId = user_id,
        SelectedDungeonId = "TestDungeon",
        Members = {self:_new_member(player)},
    }
    self._parties[party_id] = party
    self._party_by_user[user_id] = party_id
    self._invites[user_id] = nil

    return result(true, nil, {
        party = clone_party(party),
        affected_user_ids = {user_id},
    })
end

function PartyService:invite(leader: any, target: any, now: number?): any
    local leader_id = leader.UserId
    local target_id = target.UserId
    local party = self:_party_for_user(leader_id)
    if not party then
        return result(false, "NotInParty")
    end
    if party.LeaderUserId ~= leader_id then
        return result(false, "LeaderOnly")
    end
    if target_id == leader_id then
        return result(false, "CannotInviteSelf")
    end
    if #party.Members >= 4 then
        return result(false, "PartyFull")
    end
    if self._party_by_user[target_id] then
        return result(false, "TargetAlreadyInParty")
    end

    local current_time = self:_now(now)
    local pending = self._invites[target_id]
    if pending then
        if pending.ExpiresAt <= current_time then
            self._invites[target_id] = nil
        else
            return result(false, "InviteAlreadyPending")
        end
    end

    self._invites[target_id] = {
        PartyId = party.PartyId,
        InviterUserId = leader_id,
        InviterName = player_name(leader),
        ExpiresAt = current_time + self._invite_seconds,
    }

    return result(true, nil, {
        affected_user_ids = {leader_id, target_id},
    })
end

function PartyService:accept_invite(player: any, now: number?): any
    local user_id = player.UserId
    if self._party_by_user[user_id] then
        return result(false, "AlreadyInParty")
    end

    local invite = self._invites[user_id]
    if not invite then
        return result(false, "InviteMissing")
    end

    local current_time = self:_now(now)
    if invite.ExpiresAt <= current_time then
        self._invites[user_id] = nil
        return result(false, "InviteExpired")
    end

    local party: Party? = self._parties[invite.PartyId]
    if not party then
        self._invites[user_id] = nil
        return result(false, "PartyMissing")
    end
    if #party.Members >= 4 then
        self._invites[user_id] = nil
        return result(false, "PartyFull")
    end

    table.insert(party.Members, self:_new_member(player))
    self._party_by_user[user_id] = party.PartyId
    self._invites[user_id] = nil
    self:_clear_readiness(party)

    local affected = {}
    for _, member in ipairs(party.Members) do
        table.insert(affected, member.UserId)
    end

    return result(true, nil, {
        party = clone_party(party),
        affected_user_ids = affected,
    })
end

function PartyService:decline_invite(player: any): any
    local user_id = player.UserId
    if not self._invites[user_id] then
        return result(false, "InviteMissing")
    end
    self._invites[user_id] = nil
    return result(true, nil, {affected_user_ids = {user_id}})
end

function PartyService:set_ready(player: any, ready: boolean): any
    local party = self:_party_for_user(player.UserId)
    if not party then
        return result(false, "NotInParty")
    end
    if #party.Members <= 1 then
        return result(false, "SoloReadyNotRequired")
    end

    local member = self:_member(party, player.UserId)
    if not member then
        return result(false, "NotInParty")
    end
    member.Ready = ready == true

    return result(true, nil, {party = clone_party(party)})
end

function PartyService:select_dungeon(player: any, dungeon_id: string): any
    local party = self:_party_for_user(player.UserId)
    if not party then
        return result(false, "NotInParty")
    end
    if party.LeaderUserId ~= player.UserId then
        return result(false, "LeaderOnly")
    end
    if type(dungeon_id) ~= "string" or not self._is_valid_dungeon(dungeon_id) then
        return result(false, "UnknownDungeon")
    end

    if party.SelectedDungeonId ~= dungeon_id then
        party.SelectedDungeonId = dungeon_id
        self:_clear_readiness(party)
    end
    return result(true, nil, {party = clone_party(party)})
end

function PartyService:kick(leader: any, target_user_id: number): any
    local party = self:_party_for_user(leader.UserId)
    if not party then
        return result(false, "NotInParty")
    end
    if party.LeaderUserId ~= leader.UserId then
        return result(false, "LeaderOnly")
    end
    if target_user_id == leader.UserId then
        return result(false, "CannotKickLeader")
    end

    local found_index: number? = nil
    for index, member in ipairs(party.Members) do
        if member.UserId == target_user_id then
            found_index = index
            break
        end
    end
    if not found_index then
        return result(false, "TargetNotInParty")
    end

    table.remove(party.Members, found_index)
    self._party_by_user[target_user_id] = nil
    self._invites[target_user_id] = nil
    self:_clear_readiness(party)

    return result(true, nil, {
        party = clone_party(party),
        affected_user_ids = {leader.UserId, target_user_id},
    })
end

function PartyService:leave(player: any): any
    local user_id = player.UserId
    local party = self:_party_for_user(user_id)
    if not party then
        return result(false, "NotInParty")
    end

    local was_leader = party.LeaderUserId == user_id
    local remove_index: number? = nil
    for index, member in ipairs(party.Members) do
        if member.UserId == user_id then
            remove_index = index
            break
        end
    end
    if not remove_index then
        return result(false, "NotInParty")
    end

    table.remove(party.Members, remove_index)
    self._party_by_user[user_id] = nil
    self._invites[user_id] = nil

    local affected = {user_id}
    if #party.Members == 0 then
        for _, invited_id in ipairs(self:_cancel_party_invites(party.PartyId)) do
            table.insert(affected, invited_id)
        end
        self._parties[party.PartyId] = nil
        return result(true, nil, {destroyed = true, affected_user_ids = affected})
    end

    if was_leader then
        table.sort(party.Members, function(a: PartyMember, b: PartyMember): boolean
            return a.JoinOrder < b.JoinOrder
        end)
        party.LeaderUserId = party.Members[1].UserId
        for _, invited_id in ipairs(self:_cancel_party_invites(party.PartyId)) do
            table.insert(affected, invited_id)
        end
    end

    self:_clear_readiness(party)
    for _, member in ipairs(party.Members) do
        table.insert(affected, member.UserId)
    end

    return result(true, nil, {
        party = clone_party(party),
        affected_user_ids = affected,
    })
end

function PartyService:remove_player(user_id: number): any
    self._invites[user_id] = nil
    local party = self:_party_for_user(user_id)
    if not party then
        return result(true, nil, {affected_user_ids = {user_id}})
    end
    return self:leave({UserId = user_id, Name = tostring(user_id), DisplayName = tostring(user_id)})
end

function PartyService:expire_invites(now: number?): {number}
    local current_time = self:_now(now)
    local affected = {}
    for user_id, invite in pairs(self._invites) do
        if invite.ExpiresAt <= current_time then
            self._invites[user_id] = nil
            table.insert(affected, user_id)
        end
    end
    return affected
end

function PartyService:snapshot_for(user_id: number, now: number?): any
    local current_time = self:_now(now)
    local invite = self._invites[user_id]
    if invite and invite.ExpiresAt <= current_time then
        self._invites[user_id] = nil
        invite = nil
    end

    local party = self:_party_for_user(user_id)
    return {
        Party = if party then clone_party(party) else nil,
        Invite = if invite then {
            PartyId = invite.PartyId,
            InviterUserId = invite.InviterUserId,
            InviterName = invite.InviterName,
            ExpiresAt = invite.ExpiresAt,
        } else nil,
    }
end

function PartyService:prepare_entry(requester_user_id: number): any
    local party = self:_party_for_user(requester_user_id)
    if not party then
        return result(false, "NotInParty")
    end
    if party.LeaderUserId ~= requester_user_id then
        return result(false, "LeaderOnly")
    end
    if #party.Members < 1 or #party.Members > 4 then
        return result(false, "PlayerCountOutOfRange")
    end
    if not self._is_valid_dungeon(party.SelectedDungeonId) then
        return result(false, "UnknownDungeon")
    end

    if #party.Members > 1 then
        for _, member in ipairs(party.Members) do
            if member.Ready ~= true then
                return result(false, "PartyNotReady", {MemberUserId = member.UserId, MemberName = member.Name})
            end
        end
    end

    local member_user_ids = {}
    for _, member in ipairs(party.Members) do
        table.insert(member_user_ids, member.UserId)
    end

    return result(true, nil, {
        PartyId = party.PartyId,
        DungeonId = party.SelectedDungeonId,
        MemberUserIds = member_user_ids,
    })
end

return PartyService
