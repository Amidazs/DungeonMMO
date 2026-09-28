--!strict
-- Dungeon-side access to persistent Adventure quest snapshots and tracking.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestDefinitions = require(
    ReplicatedStorage.Core.Shared:WaitForChild("QuestDefinitions")
)

local DungeonQuestRuntime = {}
DungeonQuestRuntime.__index = DungeonQuestRuntime

local ACTION_COOLDOWN_SECONDS = 0.20

--[[
Sends persistent Adventure quest state to one admitted Dungeon player.

Args:
    player (Player): Authenticated player receiving the snapshot.

Returns:
    nil: Fires the existing QuestSnapshot remote to that client.
]]
function DungeonQuestRuntime:send_snapshot(player: Player)
    local snapshot = self._quests:build_snapshot(player.UserId)

    self._snapshot:FireClient(player, {
        Definitions = QuestDefinitions.adventures(),
        State = snapshot,
    })
end

--[[
Handles Dungeon-safe quest presentation actions.

The Dungeon may read quest state and change which existing Adventure quest is
tracked. It may not start quests or claim rewards.

Args:
    player (Player): Authenticated request owner.
    action (any): Snapshot or Track.
    quest_id (any): Active quest identifier for Track.

Returns:
    nil: Sends action/snapshot responses to the caller.
]]
function DungeonQuestRuntime:handle_action(
    player: Player,
    action: any,
    quest_id: any
)
    if not self._is_ready(player) then
        self._result:FireClient(player, {
            ok = false,
            reason = "ProfileNotReady",
        })
        return
    end

    if action == "Snapshot" then
        self:send_snapshot(player)
        return
    end

    if action ~= "Track" or type(quest_id) ~= "string" then
        self._result:FireClient(player, {
            ok = false,
            reason = "InvalidQuestAction",
        })
        return
    end

    local now = os.clock()
    local last = self._last_request[player.UserId] or -math.huge

    if now - last < ACTION_COOLDOWN_SECONDS then
        self._result:FireClient(player, {
            ok = false,
            reason = "QuestRequestCooldown",
        })
        return
    end

    self._last_request[player.UserId] = now

    local result = self._quests:set_tracked(
        player.UserId,
        quest_id
    )
    self._result:FireClient(player, result)
    self:send_snapshot(player)
end

--[[
Binds Dungeon quest snapshot/tracking behavior to shared quest remotes.

Args:
    options (any): Remotes, QuestService and readiness callback.

Returns:
    any: Attached runtime retained by remote connections.
]]
function DungeonQuestRuntime.attach(options: any): any
    assert(options.remotes ~= nil)
    assert(options.quests ~= nil)
    assert(options.is_ready ~= nil)

    local self = setmetatable({
        _quests = options.quests,
        _is_ready = options.is_ready,
        _request = options.remotes:WaitForChild(
            "QuestActionRequest"
        ),
        _result = options.remotes:WaitForChild(
            "QuestActionResult"
        ),
        _snapshot = options.remotes:WaitForChild(
            "QuestSnapshot"
        ),
        _last_request = {},
    }, DungeonQuestRuntime)

    self._request.OnServerEvent:Connect(
        function(player: Player, action: any, quest_id: any)
            self:handle_action(player, action, quest_id)
        end
    )

    Players.PlayerRemoving:Connect(function(player: Player)
        self._last_request[player.UserId] = nil
    end)

    return self
end

return table.freeze(DungeonQuestRuntime)
