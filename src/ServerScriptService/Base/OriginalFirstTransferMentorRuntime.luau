--!strict
-- Physical, server-verified first-transfer mentors in the hub.
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local FirstTransfers = require(
    RS.Core.Shared.OriginalFirstTransferDefinitions
)
local TransferService = require(
    game:GetService("ServerScriptService")
        .Core.Services.OriginalFirstTransferService
)

local Runtime = {}
Runtime.__index = Runtime

local MAX_RANGE = 10
local OFFSETS = table.freeze({
    HumanRogue = Vector3.new(-31, 2.5, 17),
    ElvenScout = Vector3.new(31, 2.5, 17),
})

--[[
Checks that one live player really stands next to this server-owned mentor.

Args:
    player (Player): Authenticated actual prompt owner.
    mentor (BasePart): Registered physical mentor part in the hub.

Returns:
    boolean: Whether the avatar is alive, connected and in prompt range.
]]
local function nearby(player: Player, mentor: BasePart): boolean
    if player.Parent ~= Players
        or not mentor:IsDescendantOf(workspace)
    then
        return false
    end
    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    local root = character
        and character:FindFirstChild("HumanoidRootPart")
    return humanoid ~= nil and humanoid.Health > 0
        and root ~= nil and root:IsA("BasePart")
        and (root.Position - mentor.Position).Magnitude <= MAX_RANGE
end

--[[
Creates separate mentor parts without touching existing original NPCs.

Args:
    self (any): Attached Base-only original mentor runtime.
    definition (any): Exact registered new first-transfer career.
    spawn (BasePart): Existing authenticated Base player-spawn anchor.

Returns:
    BasePart: Real server-owned named mentor with two physical prompts.
]]
local function make_mentor(
    self: any, definition: any, spawn: BasePart
): BasePart
    local part = Instance.new("Part")
    part.Name = definition.MentorId
    part.Size = Vector3.new(3, 5, 3)
    part.Anchored = true
    part.CanCollide = false
    part.Color = if definition.RaceId == "Human"
        then Color3.fromRGB(131, 92, 59)
        else Color3.fromRGB(70, 140, 119)
    part.Material = Enum.Material.Wood
    part.CFrame = spawn.CFrame * CFrame.new(
        OFFSETS[definition.BranchId]
    )
    part:SetAttribute("TrainerId", definition.TrainerId)
    part.Parent = self._folder

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "FirstTransferMentorPrompt"
    prompt.ObjectText = definition.MentorName
    prompt.ActionText = "Advance"
    prompt.HoldDuration = 0.4
    prompt.RequiresLineOfSight = true
    prompt.MaxActivationDistance = MAX_RANGE
    prompt.Parent = part
    prompt.Triggered:Connect(function(player: Player)
        self:_claim(player, definition)
    end)

    local training_prompt = Instance.new("ProximityPrompt")
    training_prompt.Name = "ProgressionTrainerPrompt"
    training_prompt.ObjectText = definition.MentorName
    training_prompt.ActionText = "Train"
    training_prompt.HoldDuration = 0.4
    training_prompt.RequiresLineOfSight = true
    training_prompt.MaxActivationDistance = MAX_RANGE
    training_prompt.Parent = part

    return part
end

--[[
Wires two authenticated physical mentors to a private transfer service.

Args:
    options (any): Real Base environment, exclusive profile writer,
        readiness guard and existing profile/UI changed callback.

Returns:
    any: Retained server runtime and its exact two local hub actors.
]]
function Runtime.attach(options: any): any
    assert(options.environment and options.profiles
        and options.is_ready and options.on_progress)
    local spawn = assert(options.environment:get("Base.PlayerSpawn"),
        "First transfer mentors need the actual Base player spawn")
    local self = setmetatable({
        _profiles = options.profiles,
        _is_ready = options.is_ready,
        _on_progress = options.on_progress,
        _parts = {},
        _pending = {},
    }, Runtime)
    local folder = Instance.new("Folder")
    folder.Name = "OriginalFirstTransferMentors"
    folder.Parent = workspace
    self._folder = folder
    self._service = TransferService.new(options.profiles, "Base", self)
    for _, definition in ipairs(FirstTransfers.all()) do
        self._parts[definition.BranchId] = make_mentor(
            self, definition, spawn
        )
    end
    Players.PlayerRemoving:Connect(function(player: Player)
        self._pending[player.UserId] = nil
    end)
    return self
end

--[[
Reports whether the requested branch has its actual existing mentor.

Args:
    definition (any): Supported immutable DungeonMMO transfer definition.

Returns:
    boolean: Real mentor exists with the correct physical name.
]]
function Runtime:available(definition: any): boolean
    local part = definition
        and self._parts[definition.BranchId]
    return part ~= nil and part:IsDescendantOf(workspace)
        and part.Name == definition.MentorId
end

--[[
Consumes one one-use mentor event created by the actual prompt callback.

Args:
    user_id (number): Roblox-reported Player who held the prompt.
    evidence (any): Exact minted event table, not a client payload.
    definition (any): Correct class and mentor linked to the event.

Returns:
    boolean: Physical proximity, character and event ownership verified.
]]
function Runtime:verify(
    user_id: number, evidence: any, definition: any
): boolean
    local pending = self._pending[user_id]
    self._pending[user_id] = nil
    local player = Players:GetPlayerByUserId(user_id)
    local part = definition
        and self._parts[definition.BranchId]
    return pending ~= nil and pending.Event == evidence
        and pending.BranchId == definition.BranchId
        and player ~= nil and part ~= nil and nearby(player, part)
        and evidence.ActorUserId == user_id
        and evidence.Kind == "OriginalFirstTransfer"
        and evidence.TargetId == definition.MentorId
        and evidence.EventId == pending.EventId
end

--[[
Claims a class only from an actual server-reported physical mentor prompt.

Args:
    player (Player): Live Roblox ProximityPrompt.Triggered player.
    definition (any): Branch permanently assigned to this mentor part.

Returns:
    any: Authoritative award or refusal, without exposing a new remote.
]]
function Runtime:_claim(player: Player, definition: any): any
    local part = self._parts[definition.BranchId]
    if not part or not nearby(player, part)
        or not self._is_ready(player)
    then
        return {ok = false, reason = "TransferMentorUnavailable"}
    end
    local event_id = "FirstTransfer:"
        .. HttpService:GenerateGUID(false)
    local event = {
        Kind = "OriginalFirstTransfer",
        TargetId = definition.MentorId,
        ActorUserId = player.UserId,
        EventId = event_id,
    }
    self._pending[player.UserId] = {
        Event = event,
        EventId = event_id,
        BranchId = definition.BranchId,
    }
    local outcome = self._service:claim(player.UserId, event)
    self._pending[player.UserId] = nil
    if outcome.ok then
        local saved, reason = self._profiles:save(
            player.UserId, "OriginalFirstTransfer"
        )
        if not saved then
            warn("[First Transfer] Profile save failed: "
                .. tostring(reason))
        end
        self._on_progress(player)
    end
    return outcome
end

--[[
Reports a current class transfer for the existing advancement UI.

Args:
    user_id (number): Current loaded character's Roblox UserId.

Returns:
    any: Service-owned class award eligibility and mentor details.
]]
function Runtime:build_snapshot(user_id: number): any
    return self._service:build_snapshot(user_id)
end

--[[
Checks actual physical trainer proximity for advanced training remotes.

Args:
    player (Player): Live authenticated trainer request originator.
    trainer_id (string): Exact catalogued first-transfer mentor trainer.

Returns:
    boolean: Whether a matching registered trainer is within range.
]]
function Runtime:nearby_trainer(
    player: Player, trainer_id: string
): boolean
    for _, definition in ipairs(FirstTransfers.all()) do
        if definition.TrainerId == trainer_id then
            local part = self._parts[definition.BranchId]
            return part ~= nil and nearby(player, part)
        end
    end
    return false
end

return table.freeze(Runtime)
