--!strict
-- Authenticated original DungeonMMO Scout Cael rescue within a real room.
-- An NPC prompt never becomes a client-owned quest-progress remote.
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Scout = {}
Scout.__index = Scout
local MAX_RANGE = 10

--[[
Creates the server-owned physical rescue actor for a single dungeon run.

Args:
    options (any): Profiles, authenticated active-member callback,
        live session ID and existing profile UI notification callback.

Returns:
    any: Inactive rescue actor awaiting an actual registered room.
]]
function Scout.new(options: any): any
    assert(options.profiles and options.is_member_active)
    assert(type(options.session_id) == "string")
    return setmetatable({
        _profiles = options.profiles,
        _is_member_active = options.is_member_active,
        _on_progress = options.on_progress,
        _session_id = options.session_id,
        _quest_service = nil,
        _actor = nil,
        _encounter_id = nil,
        _pending = {},
    }, Scout)
end

--[[
Attaches the same profile-bound original quest service as the combat ledger.

Args:
    service (any): Existing server-owned Dungeon quest authority.

Returns:
    nil: Enables single-use physically verified prompt submissions.
]]
function Scout:attach_quest_service(service: any)
    assert(service and type(service.record_world_event) == "function")
    self._quest_service = service
end

--[[
Checks actual living player, selected quest and encounter membership.

Args:
    player (Player): Real Roblox Player supplied by a physical prompt.
    part (BasePart): Current authoritative Scout Cael world part.

Returns:
    boolean: Whether this player may personally interact in this room.
]]
function Scout:_nearby(player: Player, part: BasePart): boolean
    if player.Parent ~= Players or not part:IsDescendantOf(workspace)
        or not self._is_member_active(
            player.UserId, self._encounter_id
        )
    then
        return false
    end
    local model = player.Character
    local humanoid = model and model:FindFirstChildOfClass("Humanoid")
    local root = model and model:FindFirstChild("HumanoidRootPart")
    return humanoid ~= nil and humanoid.Health > 0
        and root ~= nil and root:IsA("BasePart")
        and (root.Position - part.Position).Magnitude <= MAX_RANGE
end

--[[
Validates an exact source step and receives an authoritative NPC prompt.

Args:
    player (Player): Real connected dungeon player in physical prompt range.

Returns:
    any: Trusted quest result or explicit rejection without client proof.
]]
function Scout:_talk(player: Player): any
    local part = self._actor
    if not part or not self._quest_service
        or not self:_nearby(player, part)
    then
        return {ok = false, reason = "ScoutCaelUnavailable"}
    end
    local owner = self._profiles:get_character(player.UserId)
    local advancement = owner and owner.ClassAdvancement
    local state = advancement
        and advancement.OriginalFirstTransferQuest
    local step = state and state.Step
    if not state or state.BranchId ~= "ElvenScout"
        or advancement.OriginalFirstTransferChoiceId ~= "ElvenScout"
        or (step ~= 5 and step ~= 7)
    then
        return {ok = false, reason = "ScoutCaelWrongQuestStage"}
    end
    local event = {
        EventId = "Cael:" .. self._session_id .. ":"
            .. HttpService:GenerateGUID(false),
        ActorUserId = player.UserId,
        Kind = "NpcTalk",
        TargetId = "ScoutCael",
    }
    self._pending[player.UserId] = {
        Event = event,
        Step = step,
        EncounterId = self._encounter_id,
    }
    local outcome = self._quest_service:record_world_event(
        player.UserId, event
    )
    self._pending[player.UserId] = nil
    if outcome.ok then
        local saved, reason = self._profiles:save(
            player.UserId, "ScoutCaelRescue"
        )
        if not saved then
            warn("[Scout Cael] Profile save failed: " .. tostring(reason))
        end
        if self._on_progress then
            self._on_progress(player)
        end
    end
    return outcome
end

--[[
Registers one real physical NPC in a participating Scout's combat room.

Args:
    anchor (CFrame): Position next to the current physical room pack.
    encounter_id (string): Current authoritative room encounter ID.
    folder (Instance): Server-created dungeon runtime parent.
    user_ids ({number}): Current connected active session party roster.

Returns:
    boolean: Whether a qualified Scout encounter actor now exists.
]]
function Scout:spawn(
    anchor: CFrame, encounter_id: string, folder: Instance,
    user_ids: {number}
): boolean
    self:clear()
    local eligible = false
    for _, user_id in ipairs(user_ids) do
        local owner = self._profiles:get_character(user_id)
        local advancement = owner and owner.ClassAdvancement
        local state = advancement
            and advancement.OriginalFirstTransferQuest
        if state and state.BranchId == "ElvenScout"
            and advancement.OriginalFirstTransferChoiceId == "ElvenScout"
            and (state.Step == 5 or state.Step == 6 or state.Step == 7)
            and not state.Ready
        then
            eligible = true
            break
        end
    end
    if not eligible then return false end
    local part = Instance.new("Part")
    part.Name = "ScoutCael"
    part.Size = Vector3.new(3, 5, 3)
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Wood
    part.Color = Color3.fromRGB(70, 134, 93)
    part.CFrame = anchor * CFrame.new(-7, 2, 7)
    part.Parent = folder
    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "ScoutCaelQuestPrompt"
    prompt.ActionText = "Talk"
    prompt.ObjectText = "Scout Cael"
    prompt.HoldDuration = 0.4
    prompt.MaxActivationDistance = MAX_RANGE
    prompt.RequiresLineOfSight = false
    prompt.Parent = part
    self._actor = part
    self._encounter_id = encounter_id
    prompt.Triggered:Connect(function(player: Player)
        self:_talk(player)
    end)
    return true
end

--[[
Returns availability only for the actual registered physical rescue actor.

Args:
    quest (any): Server-selected personal original advancement quest.
    step_index (number?): Requested exactly ordered rescue stage.

Returns:
    boolean: True only for a genuine current Scout Cael room interaction.
]]
function Scout:available(quest: any, step_index: number?): boolean
    local part = self._actor
    return quest ~= nil and quest.BranchId == "ElvenScout"
        and (step_index == 5 or step_index == 7)
        and part ~= nil and part:IsDescendantOf(workspace)
end

--[[
Consumes one exact, live, personally earned physical prompt receipt.

Args:
    user_id (number): Authenticated actual player UserId.
    event (any): Exact table created by this server's Prompt.Triggered.
    quest (any): Selected saved personal source-quest definition.
    state (any): Current server-authoritative ordered quest state.

Returns:
    boolean: True only once for the correct nearby stage and owner.
]]
function Scout:verify(
    user_id: number, event: any, quest: any, state: any
): boolean
    local pending = self._pending[user_id]
    self._pending[user_id] = nil
    local player = Players:GetPlayerByUserId(user_id)
    return pending ~= nil and event == pending.Event
        and player ~= nil and self._actor ~= nil
        and self:_nearby(player, self._actor)
        and pending.EncounterId == self._encounter_id
        and pending.Step == state.Step
        and (state.Step == 5 or state.Step == 7)
        and quest.BranchId == "ElvenScout"
        and event.ActorUserId == user_id
        and event.Kind == "NpcTalk"
        and event.TargetId == "ScoutCael"
end

--[[
Invalidates a former room's NPC and all unused world proof receipts.

Args:
    None.

Returns:
    nil: Removes only this run's disposable physical quest actor.
]]
function Scout:clear()
    if self._actor then
        self._actor:Destroy()
    end
    self._actor = nil
    self._encounter_id = nil
    table.clear(self._pending)
end

return table.freeze(Scout)
