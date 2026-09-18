--!strict
-- Base transport/orchestration for server-local party state.
local Players = game:GetService("Players")

local PartyService = require(script.Parent:WaitForChild("PartyService"))
local PartyEntryCoordinator = require(script.Parent:WaitForChild("PartyEntryCoordinator"))

local PartyRuntime = {}

local function action_result(remote: RemoteEvent, player: Player, action: string, result: any)
    remote:FireClient(player, {
        ok = result.ok == true,
        reason = result.reason,
        Action = action,
        MemberUserId = result.MemberUserId,
        MemberName = result.MemberName,
        DungeonId = result.DungeonId,
        DifficultyId = result.DifficultyId,
    })
end

function PartyRuntime.attach(options: any): any
    assert(type(options) == "table", "options required")
    local remotes = options.remotes
    local party_action_request = remotes:WaitForChild("PartyActionRequest") :: RemoteEvent
    local party_snapshot = remotes:WaitForChild("PartySnapshot") :: RemoteEvent
    local party_action_result = remotes:WaitForChild("PartyActionResult") :: RemoteEvent
    local entry_result = remotes:WaitForChild("DungeonEntryResult") :: RemoteEvent

    local party = PartyService.new({
        invite_seconds = 30,
        is_valid_dungeon = options.is_valid_dungeon,
        default_difficulty = options.default_difficulty,
        is_valid_difficulty = options.is_valid_difficulty,
    })

    local entry = PartyEntryCoordinator.new({
        party_service = party,
        player_provider = function(user_id: number): Player?
            return Players:GetPlayerByUserId(user_id)
        end,
        validate_member = options.validate_member,
        coordinator = options.coordinator,
        place_id_provider = options.place_id_provider,
        is_studio = options.is_studio == true,
    })

    local last_entry_request: {[number]: number} = {}
    local ENTRY_RATE_LIMIT_SECONDS = 2

    local function is_ready_player(player: Player): boolean
        if type(options.is_player_ready) ~= "function" then
            return true
        end
        return options.is_player_ready(player) == true
    end

    local function build_snapshot(player: Player): any
        local snapshot = party:snapshot_for(player.UserId, os.clock())
        local available = {}
        for _, candidate in ipairs(Players:GetPlayers()) do
            if candidate ~= player and is_ready_player(candidate) and party:party_size(candidate.UserId) == 0 then
                table.insert(available, {
                    UserId = candidate.UserId,
                    Name = candidate.Name,
                    DisplayName = candidate.DisplayName,
                })
            end
        end
        table.sort(available, function(a: any, b: any): boolean
            return string.lower(a.Name) < string.lower(b.Name)
        end)
        snapshot.AvailablePlayers = available
        return snapshot
    end

    local function send_snapshot(player: Player)
        if player.Parent then
            party_snapshot:FireClient(player, build_snapshot(player))
        end
    end

    local function broadcast()
        for _, player in ipairs(Players:GetPlayers()) do
            send_snapshot(player)
        end
    end

    local function send_entry_to_players(result: any)
        local recipients = result.Players or {}
        if #recipients == 0 and type(result.session) == "table" and type(result.session.MemberUserIds) == "table" then
            for _, user_id in ipairs(result.session.MemberUserIds) do
                local player = Players:GetPlayerByUserId(user_id)
                if player then table.insert(recipients, player) end
            end
        end
        for _, player in ipairs(recipients) do
            entry_result:FireClient(player, {
                ok = result.ok == true,
                reason = result.reason,
                SessionId = if result.session then result.session.SessionId else nil,
                DungeonId = result.DungeonId or (if result.session then result.session.DungeonId else nil),
                DifficultyId = result.DifficultyId
                    or (if result.session and result.session.Difficulty
                        then result.session.Difficulty.Id
                        else nil),
            })
        end
    end

    local function handle_start_entry(player: Player): any
        local size = party:party_size(player.UserId)
        if size <= 1 then
            return {ok = false, reason = "SoloEntryUsesDungeonRequest"}
        end

        local now = os.clock()
        local previous = last_entry_request[player.UserId]
        if previous and now - previous < ENTRY_RATE_LIMIT_SECONDS then
            return {ok = false, reason = "EntryRateLimited"}
        end
        last_entry_request[player.UserId] = now

        local result = entry:start(player)
        if result.ok and result.reason == "StudioPartyEntryProof" then
            local names = {}
            for _, member in ipairs(result.Players) do
                table.insert(names, string.format("%s(%d)", member.Name, member.UserId))
            end
            print(string.format(
                "[Party Entry Studio Proof] Dungeon=%s Difficulty=%s Members=%s",
                tostring(result.DungeonId),
                tostring(result.DifficultyId),
                table.concat(names, ",")
            ))
            send_entry_to_players(result)
        elseif result.ok then
            send_entry_to_players(result)
        end
        return result
    end

    party_action_request.OnServerEvent:Connect(function(player: Player, payload: any)
        if type(payload) ~= "table" or type(payload.Action) ~= "string" then
            action_result(party_action_result, player, "Unknown", {ok = false, reason = "InvalidRequest"})
            return
        end

        local action = payload.Action
        if action ~= "RequestSnapshot" and not is_ready_player(player) then
            action_result(party_action_result, player, action, {ok = false, reason = "ProfileNotReady"})
            return
        end

        local result: any
        if action == "RequestSnapshot" then
            send_snapshot(player)
            return
        elseif action == "Create" then
            result = party:create(player)
        elseif action == "Invite" then
            local target_id = tonumber(payload.TargetUserId)
            local target = target_id and Players:GetPlayerByUserId(target_id) or nil
            if not target or not is_ready_player(target) then
                result = {ok = false, reason = "TargetUnavailable"}
            else
                result = party:invite(player, target, os.clock())
            end
        elseif action == "AcceptInvite" then
            result = party:accept_invite(player, os.clock())
        elseif action == "DeclineInvite" then
            result = party:decline_invite(player)
        elseif action == "SetReady" then
            result = party:set_ready(player, payload.Ready == true)
        elseif action == "SelectDungeon" then
            result = party:select_dungeon(
                player,
                tostring(payload.DungeonId or "")
            )
        elseif action == "SelectDifficulty" then
            result = party:select_difficulty(
                player,
                tostring(payload.DifficultyId or "")
            )
        elseif action == "Kick" then
            local target_id = tonumber(payload.TargetUserId)
            result = if target_id then party:kick(player, target_id) else {ok = false, reason = "InvalidTarget"}
        elseif action == "Leave" then
            result = party:leave(player)
        elseif action == "StartEntry" then
            result = handle_start_entry(player)
        else
            result = {ok = false, reason = "UnknownAction"}
        end

        action_result(party_action_result, player, action, result)
        if action ~= "StartEntry" and result.ok then
            broadcast()
        elseif action == "StartEntry" and not result.ok then
            entry_result:FireClient(player, {
                ok = false,
                reason = result.reason,
                DungeonId = result.DungeonId,
                DifficultyId = result.DifficultyId,
            })
        end
    end)

    Players.PlayerRemoving:Connect(function(player: Player)
        party:remove_player(player.UserId)
        last_entry_request[player.UserId] = nil
        task.defer(broadcast)
    end)

    task.spawn(function()
        while true do
            task.wait(1)
            local expired = party:expire_invites(os.clock())
            if #expired > 0 then
                broadcast()
            end
        end
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        task.defer(send_snapshot, player)
    end

    return {
        party_size = function(_: any, user_id: number): number
            return party:party_size(user_id)
        end,
        service = party,
        broadcast = broadcast,
    }
end

return PartyRuntime
