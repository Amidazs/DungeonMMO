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
    HumanKnight = table.freeze({
        table.freeze({
            TargetId = "CaptainRowan",
            Name = "Captain Rowan",
            Offset = Vector3.new(-34, 2.5, -42),
            Color = Color3.fromRGB(102, 107, 136),
        }),
        table.freeze({
            TargetId = "QuartermasterDena",
            Name = "Quartermaster Dena",
            Offset = Vector3.new(-47, 2.5, -42),
            Color = Color3.fromRGB(134, 113, 77),
        }),
    }),
    HumanWarrior = table.freeze({
        table.freeze({
            TargetId = "MarshalTorren",
            Name = "Marshal Torren",
            Offset = Vector3.new(-38, 2.5, -17),
            Color = Color3.fromRGB(129, 78, 51),
        }),
        table.freeze({
            TargetId = "SmithOrla",
            Name = "Smith Orla",
            Offset = Vector3.new(-49, 2.5, -17),
            Color = Color3.fromRGB(121, 104, 75),
        }),
    }),
    HumanWizard = table.freeze({
        table.freeze({
            TargetId = "MagisterOrwyn",
            Name = "Magister Orwyn",
            Offset = Vector3.new(-39, 2.5, 30),
            Color = Color3.fromRGB(112, 83, 148),
        }),
        table.freeze({
            TargetId = "ArchivistNeris",
            Name = "Archivist Neris",
            Offset = Vector3.new(-27, 2.5, 30),
            Color = Color3.fromRGB(88, 103, 149),
        }),
    }),
    HumanRogue = table.freeze({
        table.freeze({
            TargetId = "CaptainAshford",
            Name = "Captain Ashford",
            Offset = Vector3.new(-12, 2.5, 10),
            Color = Color3.fromRGB(118, 78, 53),
        }),
        table.freeze({
            TargetId = "Vela",
            Name = "Quartermaster Vela",
            Offset = Vector3.new(-21, 2.5, 10),
            Color = Color3.fromRGB(114, 89, 142),
        }),
    }),
    ElvenKnight = table.freeze({
        table.freeze({
            TargetId = "SentinelIlyra",
            Name = "Sentinel Ilyra",
            Offset = Vector3.new(10, 2.5, -15),
            Color = Color3.fromRGB(67, 130, 98),
        }),
        table.freeze({
            TargetId = "WardenCaer",
            Name = "Warden Caer",
            Offset = Vector3.new(22, 2.5, -15),
            Color = Color3.fromRGB(80, 112, 93),
        }),
    }),
    ElvenScout = table.freeze({
        table.freeze({
            TargetId = "PathfinderElyra",
            Name = "Pathfinder Elyra",
            Offset = Vector3.new(12, 2.5, 10),
            Color = Color3.fromRGB(58, 121, 94),
        }),
        table.freeze({
            TargetId = "WardenThorne",
            Name = "Warden Thorne",
            Offset = Vector3.new(21, 2.5, 10),
            Color = Color3.fromRGB(75, 110, 130),
        }),
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
        _step_parts = {},
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
    for branch_id, source_npcs in pairs(NPCS) do
        self._step_parts[branch_id] = {}
        for step_index, source in ipairs(source_npcs) do
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
            -- The Ironroot NPCs sit beside unfinished hub geometry.
            -- Server-side proximity still requires a living owner
            -- within ten studs; terrain must not hide a valid prompt.
            prompt.RequiresLineOfSight =
                branch_id ~= "HumanWarrior"
                and branch_id ~= "HumanKnight"
            prompt.Parent = part
            self._step_parts[branch_id][step_index] = part
            if step_index == 1 then
                self._parts[branch_id] = part
            end
            prompt.Triggered:Connect(function(player: Player)
                self:_talk(player, branch_id, step_index)
            end)
        end
        -- The same physical mentor accepts a later return only when
        -- this character has actually earned its ordered stage-four proof.
        self._step_parts[branch_id][4] =
            self._step_parts[branch_id][2]
        if branch_id == "HumanWarrior"
            or branch_id == "HumanKnight"
            or branch_id == "HumanWizard"
            or branch_id == "ElvenKnight"
        then
            self._step_parts[branch_id][6] =
                self._step_parts[branch_id][1]
        elseif branch_id == "HumanRogue" then
            -- Stage five is a new ordered report to the real captain,
            -- not a replay of the stage-one quest-start interaction.
            self._step_parts[branch_id][5] =
                self._step_parts[branch_id][1]
            self._step_parts[branch_id][7] =
                self._step_parts[branch_id][1]
        elseif branch_id == "ElvenScout" then
            self._step_parts[branch_id][8] =
                self._step_parts[branch_id][2]
            self._step_parts[branch_id][9] =
                self._step_parts[branch_id][1]
        end
    end
    Players.PlayerRemoving:Connect(function(player: Player)
        self:remove(player)
    end)
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
function Runtime:available(
    quest: any, stage_index: number?
): boolean
    local index = stage_index or 1
    local steps = quest and self._step_parts[quest.BranchId]
    local part = steps and steps[index]
    local source_stage = quest and quest.Steps[index]
    return part ~= nil and part:IsDescendantOf(workspace)
        and source_stage ~= nil and source_stage.Kind == "NpcTalk"
        and part.Name == source_stage.TargetId
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
    local index = state and state.Step or -1
    local parts = quest and self._step_parts[quest.BranchId]
    local part = parts and parts[index]
    local step = quest and quest.Steps[index]
    return pending ~= nil and pending.Event == event
        and pending.BranchId == quest.BranchId
        and pending.Step == index
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
function Runtime:_talk(
    player: Player, branch_id: string, step_index: number?
): any
    local index = step_index or 1
    local character = self._profiles:get_character(player.UserId)
    local advancement = character and character.ClassAdvancement
    local current = advancement
        and advancement.OriginalFirstTransferQuest
    if current and index == 2
        and (current.Step == 4
            or branch_id == "ElvenScout" and current.Step == 8)
    then
        index = current.Step
    elseif current and index == 1
        and (branch_id == "HumanRogue"
            and (current.Step == 5 or current.Step == 7)
            or branch_id == "ElvenScout" and current.Step == 9
            or (branch_id == "HumanWarrior"
                or branch_id == "HumanKnight"
                or branch_id == "HumanWizard"
                or branch_id == "ElvenKnight") and current.Step == 6)
    then
        index = current.Step
    end
    local source_index = if index == 4 or index == 8
        then 2 elseif index == 5 or index == 7 or index == 9
            or (branch_id == "HumanWarrior"
                or branch_id == "HumanKnight"
                or branch_id == "HumanWizard"
                or branch_id == "ElvenKnight") and index == 6
        then 1 else index
    local source = NPCS[branch_id] and NPCS[branch_id][source_index]
    local part = self._step_parts[branch_id]
        and self._step_parts[branch_id][index]
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
    if not advancement
        or advancement.OriginalFirstTransferChoiceId ~= branch_id
    then
        return response(false, "OriginalClassChoiceRequired")
    end
    local quest = Stages.get(branch_id)
    if not quest or not self:available(quest) then
        return response(false, "OriginalQuestWorldNotReady")
    end
    if index == 1
        and type(advancement.OriginalFirstTransferQuest) ~= "table"
    then
        local started = self._quest_service:start(player.UserId)
        if not started.ok then return started end
    end
    local state = self._quest_service:build_snapshot(player.UserId)
    if not state.ok or not state.Started or state.Step ~= index
        or not self:available(quest, index)
    then
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
        -- Only the real ordered Vela stage may enter the transaction that
        -- atomically mints both owner-bound quest trial weapons.
        TrialWeaponsGranted = branch_id == "HumanRogue" and index == 2,
    }
    self._pending[player.UserId] = {
        Event = event, EventId = event_id,
        BranchId = branch_id, Step = index,
        TargetId = source.TargetId,
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
Exposes the actual private quest authority only to server-side Base wiring.

Args:
    None.

Returns:
    any: Source quest state service for existing class-choice snapshots.
]]
function Runtime:quest_service(): any
    return self._quest_service
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
