--!strict
-- Contextual Starting Base dungeon UI. Server remains authoritative.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local EnvironmentAnchorClient = require(
    shared:WaitForChild("EnvironmentAnchorClient")
)

local entry_request = remotes:WaitForChild(
    "DungeonEntryRequest"
) :: RemoteEvent
local entry_result = remotes:WaitForChild(
    "DungeonEntryResult"
) :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "BaseUi"
gui.ResetOnSpawn = false
gui.DisplayOrder = 150
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 1)
panel.Position = UDim2.fromScale(0.5, 0.96)
panel.Size = UDim2.fromOffset(440, 132)
panel.BackgroundColor3 = Color3.fromRGB(26, 28, 34)
panel.BackgroundTransparency = 0.08
panel.Visible = false
panel.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 0, 34)
title.Position = UDim2.fromOffset(12, 8)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(245, 245, 245)
title.TextScaled = true
title.Text = "Temple Dungeon"
title.Parent = panel

local close = Instance.new("TextButton")
close.Position = UDim2.fromOffset(390, 8)
close.Size = UDim2.fromOffset(38, 34)
close.Text = "X"
close.Parent = panel

local button = Instance.new("TextButton")
button.Name = "EnterDungeon"
button.Position = UDim2.fromOffset(18, 52)
button.Size = UDim2.fromOffset(178, 48)
button.TextScaled = true
button.Text = "Enter Temple"
button.Selectable = true
button.Parent = panel

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(206, 50)
status.Size = UDim2.fromOffset(216, 72)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(220, 220, 220)
status.TextWrapped = true
status.TextScaled = true
status.Text = "Solo entry • server-authoritative routing"
status.Parent = panel

local pending = false

local function set_pending(value: boolean)
    pending = value
    button.Active = not value
    button.AutoButtonColor = not value
    button.Text = if value then "Entering..." else "Enter Temple"
end

local function request_entry()
    if pending then
        return
    end
    set_pending(true)
    panel.Visible = true
    status.Text = "Requesting Temple dungeon..."
    entry_request:FireServer("TestDungeon")
end

button.Activated:Connect(request_entry)
close.Activated:Connect(function()
    if not pending then
        panel.Visible = false
    end
end)

entry_result.OnClientEvent:Connect(function(payload)
    if type(payload) ~= "table" then
        return
    end

    if payload.ok == true then
        status.Text = "Teleporting to reserved Temple..."
        set_pending(true)
    else
        local reason = tostring(payload.reason or "EntryFailed")
        if reason == "PublishedTeleportRequired" then
            status.Text =
                "Studio: published teleport is not used from the Base test."
        else
            status.Text = "Entry blocked: " .. reason
        end
        set_pending(false)
    end
end)

task.spawn(function()
    local board = EnvironmentAnchorClient.wait_for(
        "Base",
        "Base.DungeonBoard",
        15
    )
    if board then
        local prompt = board:FindFirstChild("DungeonBoardPrompt")
        if prompt and prompt:IsA("ProximityPrompt") then
            prompt.Triggered:Connect(function()
                panel.Visible = true
                status.Text =
                    "Temple training dungeon • inspect gear and skills before entry."
            end)
        end
    end

    local portal = EnvironmentAnchorClient.wait_for(
        "Base",
        "Base.TemplePortal",
        15
    )
    if portal then
        local prompt = portal:FindFirstChild("DungeonEntryPrompt")
        if prompt and prompt:IsA("ProximityPrompt") then
            prompt.Triggered:Connect(request_entry)
        end
    end
end)
