--!strict
-- Base-only, server-authoritative story quest requests.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local QuestDefinitions = require(
    ReplicatedStorage.Core.Shared:WaitForChild("QuestDefinitions")
)

local BaseQuestRuntime = {}
BaseQuestRuntime.__index = BaseQuestRuntime

local ACTION_COOLDOWN_SECONDS = 0.25

-- Sends a character's persisted quest progress and public story catalogue.
--
-- Args:
--   player (Player): Authenticated quest board visitor.
-- Returns:
--   nil: Sends the current server-owned quest state to the caller.
function BaseQuestRuntime:send_snapshot(player: Player)
    local snapshot = self._quests:build_snapshot(player.UserId)
    self._snapshot:FireClient(player, {
        Definitions = QuestDefinitions.adventures(),
        State = snapshot,
    })
end

-- Handles one authenticated quest action, without accepting client rewards
-- or client-authored progress events.
--
-- Args:
--   player (Player): Caller whose profile is being modified.
--   action (any): Snapshot, Start or Claim.
--   quest_id (any): Server-defined adventure quest identifier.
-- Returns:
--   nil: Sends an operation result and updated quest state.
function BaseQuestRuntime:handle_action(
    player: Player,
    action: any,
    quest_id: any
)
    if not self._is_ready(player) then
        self._result:FireClient(player, {
            ok = false, reason = "ProfileNotReady",
        })
        return
    end

    if action == "Snapshot" then
        self:send_snapshot(player)
        return
    end

    local definition = if type(quest_id) == "string"
        then QuestDefinitions.get(quest_id)
        else nil
    if (action ~= "Start" and action ~= "Claim")
        or not definition
        or definition.Kind ~= "Adventure"
    then
        self._result:FireClient(player, {
            ok = false, reason = "InvalidQuestAction",
        })
        return
    end

    local now = os.clock()
    local last = self._last_request[player.UserId] or -math.huge
    if now - last < ACTION_COOLDOWN_SECONDS then
        self._result:FireClient(player, {
            ok = false, reason = "QuestRequestCooldown",
        })
        return
    end
    self._last_request[player.UserId] = now

    local result = if action == "Start"
        then self._quests:start(player.UserId, quest_id)
        else self._quests:claim_reward(player.UserId, quest_id)
    self._result:FireClient(player, result)
    self:send_snapshot(player)
end

-- Binds the existing QuestService to the Base remotes.
--
-- Args:
--   options (any): Remotes, quests and authoritative readiness callback.
-- Returns:
--   any: The runtime controller, retained by Base's event connections.
function BaseQuestRuntime.attach(options: any): any
    assert(options.remotes and options.quests and options.is_ready,
        "Base quest runtime dependencies are required")

    local self = setmetatable({
        _quests = options.quests,
        _is_ready = options.is_ready,
        _request = options.remotes:WaitForChild("QuestActionRequest"),
        _result = options.remotes:WaitForChild("QuestActionResult"),
        _snapshot = options.remotes:WaitForChild("QuestSnapshot"),
        _last_request = {},
    }, BaseQuestRuntime)

    self._request.OnServerEvent:Connect(function(player, action, quest_id)
        self:handle_action(player, action, quest_id)
    end)
    Players.PlayerRemoving:Connect(function(player)
        self._last_request[player.UserId] = nil
    end)
    return self
end

return table.freeze(BaseQuestRuntime)
