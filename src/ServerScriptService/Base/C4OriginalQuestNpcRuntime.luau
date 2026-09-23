--!strict
-- Genuine C4 first-stage hub NPCs; later historical dungeon/combat
-- proof remains locked until actual instanced quest actors are built.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Stages = require(RS.Core.Shared.C4OriginalFirstTransferQuestStages)
local QuestService = require(
    game:GetService("ServerScriptService").Core.Services
        .C4OriginalFirstTransferQuestService
)

local Runtime = {}
Runtime.__index = Runtime
local MAX_RANGE = 10
local NPCS = table.freeze({
    HumanRogue = table.freeze({
        TargetId = "CaptainBezique",
        Name = "Captain Bezique",
        Offset = Vector3.new(-12, 2.5, 10),
        Color = Color3.fromRGB(118, 78, 53),
    }),
    ElvenScout = table.freeze({
        TargetId = "MasterReisa",
        Name = "Master Reisa",
        Offset = Vector3.new(12, 2.5, 10),
        Color = Color3.fromRGB(58, 121, 94),
    }),
})

local function response(ok: boolean, reason: string?): any
    return {ok = ok, reason = reason}
end

--[[
Verifies one physically present, alive, authenticated player at this NPC.

Args:
    player (Player): Server-resolved actual ProximityPrompt activator.
    part (BasePart): Original server-owned hub NPC placeholder.

Returns:
    boolean: True only for an existing living character within 10 studs.
]]
local function nearby(player: Player, part: BasePart): boolean
    if not player or player.Parent ~= Players
        or not part:IsDescendantOf(workspace)
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
Creates physically registered original NPCs and the sole server world
verifier; no client receives authority to manufacture quest evidence.

Args:
    options (any): Real Base environment, profiles, readiness and UI callback.

Returns:
    any: Real stage-one quest runtime; later combat steps remain unavailable.
]]
function Runtime.attach(options: any): any
    assert(options.environment and options.profiles
        and options.is_ready and options.on_progress)
    local spawn = assert(options.environment:get("Base.PlayerSpawn"),
        "Original C4 NPCs require a resolved Base player spawn")
    local self = setmetatable({
        _profiles = options.profiles,
        _is_ready = options.is_ready,
        _on_progress = options.on_progress,
        _parts = {},
        _pending = {},
        _last_action = {},
        _event_counter = 0,
    }, Runtime)
    local service = QuestService.new(options.profiles, "Base", self)
    self._quest_service = service
    local folder = Instance.new("Folder")
    folder.Name = "C4OriginalSourceQuestNPCs"
    folder.Parent = workspace
    self._folder = folder
    for branch_id, source in pairs(NPCS) do
        local part = Instance.new("Part")
        part.Name = source.TargetId
        part.Size = Vector3.new(3, 5, 3)
        part.Anchored = true
        part.CanCollide = false
        part.Color = source.Color
        part.Material = Enum.Material.Wood
        part.CFrame = spawn.CFrame * CFrame.new(source.Offset)
        part.Parent = folder

        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "C4SourceQuestPrompt"
        prompt.ActionText = "Talk"
        prompt.ObjectText = source.Name
        prompt.HoldDuration = 0.4
        prompt.MaxActivationDistance = MAX_RANGE
        prompt.RequiresLineOfSight = true
        prompt.Parent = part
        self._parts[branch_id] = part
        prompt.Triggered:Connect(function(player: Player)
            self:_talk(player, branch_id)
        end)
    end
    return self
end

--[[
Reports whether the physical FIRST NPC exists; does not assert all
historic quest enemies, drops, rescuable actors or transfer trainers exist.

Args:
    quest (any): A separately researched original source quest.

Returns:
    boolean: Whether the authenticated first-stage interaction can start.
]]
function Runtime:available(quest: any): boolean
    local part = quest and self._parts[quest.BranchId]
    local first = quest and quest.Steps[1]
    return part ~= nil and part:IsDescendantOf(workspace)
        and first ~= nil and first.Kind == "NpcTalk"
        and part.Name == first.TargetId
end

--[[
Authenticates one *exact* server-generated prompt event and consumes its
single-use evidence receipt before permitting persistent quest progress.

Args:
    user_id (number): Profile character owner's Roblox UserId.
    event (any): Exact server-issued quest event (not a client payload).
    quest (any): The player's separately selected original C4 quest.
    state (any): Current original quest step from the server profile.

Returns:
    boolean: True only for the real current NPC and this live receipt.
]]
function Runtime:verify(
    user_id: number, event: any, quest: any, state: any
): boolean
    local pending = self._pending[user_id]
    self._pending[user_id] = nil
    local player = Players:GetPlayerByUserId(user_id)
    local part = quest and self._parts[quest.BranchId]
    local step = quest and quest.Steps[state and state.Step or -1]
    return pending ~= nil and pending.Event == event
        and pending.BranchId == quest.BranchId
        and pending.TargetId == event.TargetId
        and player ~= nil
        and part ~= nil and nearby(player, part)
        and step ~= nil and step.Kind == "NpcTalk"
        and step.TargetId == part.Name
        and event.Kind == "NpcTalk"
        and event.ActorUserId == user_id
        and event.EventId == pending.EventId
end

--[[
Attempts a genuine real-NPC original quest start and its first ordered
stage; no future stages or advanced-class skills may be granted here.

Args:
    player (Player): Genuine server ProximityPrompt activator.
    branch_id (string): Fixed source branch bound to this server part.

Returns:
    any: Server-validated quest stage or a safe explicit refusal.
]]
function Runtime:_talk(player: Player, branch_id: string): any
    local source = NPCS[branch_id]
    local part = self._parts[branch_id]
    if not source or not part or not nearby(player, part)
        or not self._is_ready(player)
    then
        return response(false, "OriginalNpcUnavailable")
    end
    local now = os.clock()
    if now - (self._last_action[player.UserId] or -math.huge) < 0.65 then
        return response(false, "OriginalNpcInteractionCooldown")
    end
    self._last_action[player.UserId] = now
    local character = self._profiles:get_character(player.UserId)
    local advancement = character and character.ClassAdvancement
    if not advancement
        or advancement.OriginalFirstTransferChoiceId ~= branch_id
    then
        return response(false, "OriginalClassChoiceRequired")
    end
    local quest = Stages.get(branch_id)
    if not quest or not self:available(quest) then
        return response(false, "OriginalQuestWorldNotReady")
    end
    if type(advancement.OriginalFirstTransferQuest) ~= "table" then
        local started = self._quest_service:start(player.UserId)
        if not started.ok then return started end
    end
    local state = self._quest_service:build_snapshot(player.UserId)
    if not state.ok or state.Step ~= 1 then
        return response(false, "OriginalQuestNextWorldStagePending")
    end
    self._event_counter += 1
    local event_id = "BaseSourceNPC:" .. tostring(self._event_counter)
        .. ":" .. tostring(player.UserId)
    local event = {
        Kind = "NpcTalk",
        TargetId = source.TargetId,
        ActorUserId = player.UserId,
        EventId = event_id,
    }
    self._pending[player.UserId] = {
        Event = event, EventId = event_id,
        BranchId = branch_id, TargetId = source.TargetId,
    }
    local progress = self._quest_service:record_world_event(
        player.UserId, event
    )
    self._pending[player.UserId] = nil
    if progress.ok then
        self._on_progress(player)
    end
    return progress
end

--[[
Releases per-player provisional proof on disconnect or profile teardown.

Args:
    player (Player): Departing authenticated player.

Returns:
    nil: Clears ephemeral evidence without changing persistent quest status.
]]
function Runtime:remove(player: Player)
    self._pending[player.UserId] = nil
    self._last_action[player.UserId] = nil
end

return table.freeze(Runtime)
