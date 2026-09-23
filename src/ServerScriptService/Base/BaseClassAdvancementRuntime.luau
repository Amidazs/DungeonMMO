--!strict
-- Base-only entry point for quest-gated class advancement.
local Players = game:GetService("Players")

local BaseClassAdvancementRuntime = {}
BaseClassAdvancementRuntime.__index = BaseClassAdvancementRuntime

local ACTION_COOLDOWN_SECONDS = 0.25

-- Returns the authenticated character's server-owned advancement state.
--
-- Args:
--   player (Player): The current profile owner.
-- Returns:
--   nil: Sends the current advancement state to the player.
function BaseClassAdvancementRuntime:send_snapshot(player: Player)
    local snapshot = self._advancement:build_snapshot(player.UserId)
    snapshot.OriginalFirstTransfer = self._selection:build_snapshot(
        player.UserId
    )
    snapshot.OriginalQuest = if self._original_quest
        then self._original_quest:build_snapshot(player.UserId)
        else {ok = false, reason = "OriginalQuestWorldNotReady"}
    snapshot.OriginalTransfer = if self._original_transfer
        then self._original_transfer:build_snapshot(player.UserId)
        else {ok = false, reason = "OriginalTransferMentorNotReady"}
    self._snapshot:FireClient(player, snapshot)
end

-- Starts or claims the existing class-specific advancement trial.
--
-- Args:
--   player (Player): The authenticated requesting character.
--   action (any): Snapshot, StartTrial or ClaimTrial.
-- Returns:
--   nil: Sends the action result and authoritative progression state.
function BaseClassAdvancementRuntime:handle_action(
    player: Player,
    action: any, class_id: any
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

    if action ~= "StartTrial" and action ~= "ClaimTrial"
        and action ~= "SelectFirstTransfer"
    then
        self._result:FireClient(player, {
            ok = false,
            reason = "InvalidAdvancementAction",
        })
        return
    end

    local now = os.clock()
    local last = self._last_request[player.UserId] or -math.huge
    if now - last < ACTION_COOLDOWN_SECONDS then
        self._result:FireClient(player, {
            ok = false,
            reason = "AdvancementRequestCooldown",
        })
        return
    end
    self._last_request[player.UserId] = now

    local result = if action == "SelectFirstTransfer"
        then self._selection:choose(player.UserId, class_id)
        elseif action == "StartTrial"
        then self._advancement:start_trial(player.UserId)
        else self._advancement:claim(player.UserId)

    self._result:FireClient(player, result)
    self:send_snapshot(player)
end

--[[ 
Attaches real source quest snapshot authority after Base NPC registration.

Args:
    quest_service (any): Server-only original C4 quest service.

Returns:
    nil: Subsequent GUI snapshots include live original quest stage.
]]
function BaseClassAdvancementRuntime:set_original_quest_service(
    quest_service: any
)
    assert(quest_service)
    self._original_quest = quest_service
end

--[[
Attaches authenticated physical first-transfer mentor snapshot authority.

Args:
    mentors (any): Actual registered Base original-transfer mentor runtime.

Returns:
    nil: Adds verified award and level-20 mentor status to future snapshots.
]]
function BaseClassAdvancementRuntime:set_original_transfer_service(
    mentors: any
)
    assert(mentors and type(mentors.build_snapshot) == "function")
    self._original_transfer = mentors
end

-- Connects advancement requests to the existing profile-backed service.
--
-- Args:
--   options (any): Remotes, ClassAdvancementService and readiness guard.
-- Returns:
--   any: Server-owned handler retained by its remote event connections.
function BaseClassAdvancementRuntime.attach(options: any): any
    assert(
        options.remotes and options.advancement and options.selection
            and options.is_ready,
        "Base class advancement dependencies are required"
    )

    local self = setmetatable({
        _advancement = options.advancement,
        _selection = options.selection,
        _is_ready = options.is_ready,
        _request = options.remotes:WaitForChild(
            "ClassAdvancementRequest"
        ),
        _result = options.remotes:WaitForChild(
            "ClassAdvancementResult"
        ),
        _snapshot = options.remotes:WaitForChild(
            "ClassAdvancementSnapshot"
        ),
        _last_request = {},
    }, BaseClassAdvancementRuntime)

    self._request.OnServerEvent:Connect(function(player, action, class_id)
        self:handle_action(player, action, class_id)
    end)
    Players.PlayerRemoving:Connect(function(player)
        self._last_request[player.UserId] = nil
    end)
    return self
end

return table.freeze(BaseClassAdvancementRuntime)
