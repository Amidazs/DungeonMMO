--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local EnvironmentAnchorClient = require(
    shared:WaitForChild("EnvironmentAnchorClient")
)
local TravelConfig = require(
    shared:WaitForChild("TravelConfig")
)

local snapshot_request =
    remotes:WaitForChild("TravelSnapshotRequest") :: RemoteEvent
local snapshot_remote =
    remotes:WaitForChild("TravelSnapshot") :: RemoteEvent
local travel_request =
    remotes:WaitForChild("TravelRequest") :: RemoteEvent
local action_result =
    remotes:WaitForChild("TravelActionResult") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "TravelPanel"
gui.ResetOnSpawn = false
gui.DisplayOrder = 185
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(440, 410)
panel.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
panel.Visible = false
panel.Parent = gui

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(16, 12)
title.Size = UDim2.fromOffset(340, 38)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(245, 245, 245)
title.TextScaled = true
title.Text = "Travel"
title.Parent = panel

local close = Instance.new("TextButton")
close.Position = UDim2.fromOffset(386, 12)
close.Size = UDim2.fromOffset(38, 34)
close.Text = "X"
close.Parent = panel

local destination_holder = Instance.new("Frame")
destination_holder.Position = UDim2.fromOffset(18, 64)
destination_holder.Size = UDim2.fromOffset(404, 244)
destination_holder.BackgroundTransparency = 1
destination_holder.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = destination_holder

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(18, 322)
status.Size = UDim2.fromOffset(404, 70)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(225, 225, 225)
status.TextScaled = true
status.Text = "Hold E on the Travel Gem to open travel."
status.Parent = panel

local travel_anchor: BasePart? = nil
local pending = false
local buttons: {TextButton} = {}

local FRIENDLY_REASON = {
    TravelCooldown = "Travel Gem is recharging.",
    TeleportPending = "Dungeon travel is already pending.",
    ActiveDungeonSession = "Return to your active dungeon first.",
    TooFarFromTravelService = "Move closer to the Travel Gem.",
    AlreadyAtDestination = "You are already at that destination.",
    DestinationUnavailable = "That destination is unavailable.",
    IdentityIncomplete = "Complete character creation first.",
    CharacterUnavailable = "Character is not ready.",
}

local function clear_buttons()
    for _, button in ipairs(buttons) do
        button:Destroy()
    end
    table.clear(buttons)
end

local function set_pending(value: boolean)
    pending = value
    for _, button in ipairs(buttons) do
        button.Active = not value
        button.AutoButtonColor = not value
    end
end

local function render(snapshot: any)
    clear_buttons()

    local cooldown =
        tonumber(snapshot.CooldownRemaining) or 0

    if cooldown > 0 then
        status.Text = string.format(
            "Travel Gem recharging: %.1fs",
            cooldown
        )
    else
        status.Text = "Choose a destination."
    end

    for _, destination in ipairs(
        snapshot.Destinations or {}
    ) do
        local button = Instance.new("TextButton")
        button.Name = "Travel_" .. tostring(destination.Id)
        button.Size = UDim2.new(1, 0, 0, 52)
        button.TextScaled = true
        button.Text = tostring(destination.Name)
        button.Parent = destination_holder
        table.insert(buttons, button)

        button.Activated:Connect(function()
            if pending then
                return
            end

            set_pending(true)
            status.Text = "Requesting travel..."
            travel_request:FireServer(destination.Id)
        end)
    end

    set_pending(false)
end

close.Activated:Connect(function()
    if not pending then
        panel.Visible = false
    end
end)

snapshot_remote.OnClientEvent:Connect(function(snapshot: any)
    if type(snapshot) ~= "table"
        or snapshot.ok ~= true
    then
        return
    end

    render(snapshot)
    panel.Visible = true
end)

action_result.OnClientEvent:Connect(function(result: any)
    if type(result) ~= "table" then
        return
    end

    set_pending(false)

    if result.ok == true then
        panel.Visible = false
        status.Text = "Travel complete."
        return
    end

    local reason = tostring(result.reason or "TravelFailed")
    status.Text =
        FRIENDLY_REASON[reason]
        or ("Travel blocked: " .. reason)
end)

task.spawn(function()
    travel_anchor = EnvironmentAnchorClient.wait_for(
        "Base",
        "Base.Service.Travel",
        15
    )

    if not travel_anchor then
        return
    end

    local prompt = travel_anchor:FindFirstChild("TravelPrompt")
    if prompt and prompt:IsA("ProximityPrompt") then
        prompt.Triggered:Connect(function()
            if pending then
                return
            end

            panel.Visible = true
            status.Text = "Loading destinations..."
            snapshot_request:FireServer()
        end)
    end
end)

local elapsed = 0
RunService.Heartbeat:Connect(function(delta: number)
    if not panel.Visible or not travel_anchor then
        return
    end

    elapsed += delta
    if elapsed < 0.25 then
        return
    end
    elapsed = 0

    local character = player.Character
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    if not root or not root:IsA("BasePart") then
        panel.Visible = false
        return
    end

    if (
        root.Position - travel_anchor.Position
    ).Magnitude > TravelConfig.ACCESS_DISTANCE then
        panel.Visible = false
        status.Text = "Moved away from the Travel Gem."
        set_pending(false)
    end
end)
