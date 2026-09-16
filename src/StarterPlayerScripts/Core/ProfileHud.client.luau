--!strict
-- Read-only Phase 2A profile HUD shared by Base and Dungeon Places.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")
local ProgressionConfig = require(shared:WaitForChild("ProgressionConfig"))
local ProgressionHudRules = require(shared:WaitForChild("ProgressionHudRules"))
local profile_snapshot = remotes:WaitForChild("ProfileSnapshot") :: RemoteEvent
local progression_snapshot = remotes:WaitForChild("ProgressionSnapshot") :: RemoteEvent
local ProgressionClientState = require(script.Parent:WaitForChild("ProgressionClientState"))

local gui = Instance.new("ScreenGui")
gui.Name = "ProfileHud"
gui.ResetOnSpawn = false
gui.DisplayOrder = 120
gui.Parent = player:WaitForChild("PlayerGui")

local summary = Instance.new("TextLabel")
summary.Name = "Summary"
summary.Position = UDim2.fromOffset(16, 16)
summary.Size = UDim2.fromOffset(320, 42)
summary.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
summary.BackgroundTransparency = 0.18
summary.TextColor3 = Color3.fromRGB(245, 245, 245)
summary.TextXAlignment = Enum.TextXAlignment.Left
summary.TextScaled = true
summary.Text = "Level 1 | XP 0/100 | Gold 0 | AP 0 | SP 0"
local last_level=1
local last_xp=0
local last_gold=0
local last_ap=0
local last_sp=0
local function render_summary()
    local required=ProgressionConfig.get_required_xp(last_level)
    summary.Text=ProgressionHudRules.format_summary(
        last_level,
        last_xp,
        last_gold,
        last_ap,
        last_sp,
        required
    )
end
summary.Parent = gui

profile_snapshot.OnClientEvent:Connect(function(payload)
    if type(payload) ~= "table" then return end
    last_level = tonumber(payload.Level) or 1
    last_xp = tonumber(payload.XP) or 0
    last_gold = tonumber(payload.Gold) or 0
    render_summary()
end)

progression_snapshot.OnClientEvent:Connect(function(payload)
    if type(payload) ~= "table" then return end
    ProgressionClientState.apply_snapshot(payload)
    last_level = tonumber(payload.Level) or last_level
    last_xp = tonumber(payload.XP) or last_xp
    last_gold = tonumber(payload.Gold) or last_gold
    last_ap = tonumber(payload.APAvailable) or 0
    last_sp = tonumber(payload.SPAvailable) or 0
    render_summary()
end)

-- Request a fresh server snapshot so joining clients cannot miss an early PlayerAdded push.
task.defer(function()
    profile_snapshot:FireServer("Request")
    progression_snapshot:FireServer("Request")
end)
