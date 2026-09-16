--!strict
-- Personal profession-node depletion. The server owns claims; this script only
-- hides a node locally after that player's authoritative claim succeeds.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local remotes = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Remotes")

local profession_snapshot = remotes:WaitForChild("ProfessionSnapshot") :: RemoteEvent
local action_result = remotes:WaitForChild("ProfessionActionResult") :: RemoteEvent

local hidden: {[string]: boolean} = {}

local function profession_root(): Instance?
    return Workspace:FindFirstChild("ProfessionRuntime")
end

local function hide_node(node_id: string)
    if hidden[node_id] == true then
        return
    end

    local root = profession_root()
    local model = root and root:FindFirstChild(node_id)
    if not model then
        return
    end

    hidden[node_id] = true

    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.LocalTransparencyModifier = 1
        elseif descendant:IsA("ProximityPrompt") then
            descendant.Enabled = false
        elseif descendant:IsA("BillboardGui") then
            descendant.Enabled = false
        end
    end
end

local function apply_claimed_ids(value: any)
    if type(value) ~= "table" then
        return
    end

    for _, node_id in ipairs(value) do
        if type(node_id) == "string" then
            hide_node(node_id)
        end
    end
end

profession_snapshot.OnClientEvent:Connect(function(payload: any)
    if type(payload) == "table" and payload.ok == true then
        apply_claimed_ids(payload.ClaimedNodeIds)
    end
end)

action_result.OnClientEvent:Connect(function(payload: any)
    if type(payload) ~= "table" then
        return
    end

    if payload.ok == true
        and payload.action == "Gather"
        and type(payload.node_id) == "string"
    then
        hide_node(payload.node_id)
    end
end)

-- Handles reconnects and clients that start before dungeon admission has
-- restored the active session ID. Repeated read-only snapshot requests are
-- cheap and guarantee reconnect depletion is eventually reconstructed.
for _, delay_seconds in ipairs({0, 2, 5}) do
    task.delay(delay_seconds, function()
        profession_snapshot:FireServer("Request")
    end)
end
