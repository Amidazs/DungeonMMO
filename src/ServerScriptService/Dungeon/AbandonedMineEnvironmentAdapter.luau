--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Definitions = require(
    ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared"):WaitForChild("EnvironmentAnchorDefinitions")
)
local Resolver = require(
    ServerScriptService:WaitForChild("Core"):WaitForChild("Environment"):WaitForChild("EnvironmentAnchorResolver")
)

local AbandonedMineEnvironmentAdapter = {}
AbandonedMineEnvironmentAdapter.__index = AbandonedMineEnvironmentAdapter

local ALIASES = table.freeze({
    ["Temple.EntrySpawn"] = "Mine.EntrySpawn",
    ["Temple.Room1.Checkpoint"] = "Mine.Room1.Checkpoint",
    ["Temple.Room1.Trigger"] = "Mine.Room1.Trigger",
    ["Temple.Room1.ExitBarrier"] = "Mine.Room1.ExitBarrier",
    ["Temple.Room2.Checkpoint"] = "Mine.Room2.Checkpoint",
    ["Temple.Room2.Trigger"] = "Mine.Room2.Trigger",
    ["Temple.Room2.ExitBarrier"] = "Mine.Room2.ExitBarrier",
    ["Temple.Room3.Checkpoint"] = "Mine.Room3.Checkpoint",
    ["Temple.Room3.Trigger"] = "Mine.Room3.Trigger",
    ["Temple.Room3.CaptainSpawn"] = "Mine.Room3.ForemanSpawn",
    ["Temple.CompletionPosition"] = "Mine.CompletionPosition",
    ["Temple.ReturnToBase"] = "Mine.ReturnToBase",
})

local GROUP_BY_ROOM = table.freeze({
    Room1 = "MineRoom1EnemySpawns",
    Room2 = "MineRoom2EnemySpawns",
})
local BARRIER_BY_ROOM = table.freeze({
    Room1 = "Mine.Room1.ExitBarrier",
    Room2 = "Mine.Room2.ExitBarrier",
})

function AbandonedMineEnvironmentAdapter.resolve(
    root: Instance,
    contract: any?
): any
    local resolved = Resolver.resolve(
        root,
        contract or Definitions.ABANDONED_MINE
    )
    if not resolved.ok then return resolved end
    return setmetatable({
        ok = true,
        root = root,
        anchors = resolved.by_id,
        groups = resolved.groups,
    }, AbandonedMineEnvironmentAdapter)
end

function AbandonedMineEnvironmentAdapter:get(anchor_id: string): BasePart?
    return self.anchors[ALIASES[anchor_id] or anchor_id]
end

function AbandonedMineEnvironmentAdapter:get_group(group_name: string): {BasePart}
    return self.groups[group_name] or {}
end

function AbandonedMineEnvironmentAdapter:checkpoint_cframe(anchor_id: string): CFrame
    local anchor = assert(self:get(anchor_id), "Missing Mine checkpoint anchor " .. anchor_id)
    return anchor.CFrame + Vector3.new(0, 3, 0)
end

function AbandonedMineEnvironmentAdapter:enemy_spawn_cframes(room_id: string): {CFrame}
    local group_name = assert(GROUP_BY_ROOM[room_id], "Unknown Mine room " .. room_id)
    local result = {}
    for _, anchor in ipairs(self:get_group(group_name)) do table.insert(result, anchor.CFrame) end
    return result
end

function AbandonedMineEnvironmentAdapter:captain_spawn_cframe(): CFrame
    return assert(self:get("Mine.Room3.ForemanSpawn"), "Mine foreman spawn missing").CFrame
end

function AbandonedMineEnvironmentAdapter:set_exit_open(room_id: string, open: boolean): any
    local anchor_id = BARRIER_BY_ROOM[room_id]
    if not anchor_id then return {ok = false, reason = "UnknownMineRoom"} end
    local barrier = self:get(anchor_id)
    if not barrier then return {ok = true, barrier_present = false} end
    barrier.CanCollide = not open
    barrier.Transparency = 1
    return {ok = true, barrier_present = true}
end

local function marker(parent: Instance, name: string, position: Vector3, color: Color3)
    local part = Instance.new("Part")
    part.Name = name
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Size = Vector3.new(1.5, 4, 1.5)
    part.CFrame = CFrame.new(position)
    part.Parent = parent
end

function AbandonedMineEnvironmentAdapter:apply_instance_state(instance_state: any)
    local previous = self.root:FindFirstChild("MineInstanceStatePresentation")
    if previous then previous:Destroy() end
    local folder = Instance.new("Folder")
    folder.Name = "MineInstanceStatePresentation"
    folder.Parent = self.root

    local room1 = assert(self:get("Mine.Room1.Checkpoint"))
    local room2 = assert(self:get("Mine.Room2.Checkpoint"))
    folder:SetAttribute("Module1Id", tostring(instance_state and instance_state.Module1Id or "OreGallery"))
    folder:SetAttribute("Module2Id", tostring(instance_state and instance_state.Module2Id or "WinchChamber"))
    folder:SetAttribute("RareStateId", instance_state and instance_state.RareStateId or nil)
    folder:SetAttribute("EventId", instance_state and instance_state.EventId or nil)

    if instance_state and instance_state.RareStateId == "CrystalBloom" then
        for index = 1, 7 do
            marker(folder, "CrystalBloom_" .. tostring(index),
                room2.Position + Vector3.new((index - 4) * 4, 2, if index % 2 == 0 then 10 else -10),
                Color3.fromRGB(79, 214, 232))
        end
    end
    if instance_state and instance_state.EventActive == true then
        for index = 1, 5 do
            marker(folder, "DeepEcho_" .. tostring(index),
                room1.Position + Vector3.new((index - 3) * 6, 1.5, -12),
                Color3.fromRGB(171, 92, 255))
        end
    end
end

return AbandonedMineEnvironmentAdapter
