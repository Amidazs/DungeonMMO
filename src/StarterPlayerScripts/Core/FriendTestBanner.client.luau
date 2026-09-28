--!strict
-- Small published-TEST banner with two-player playtest guidance.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")

local shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local TestRelease = require(
    shared:WaitForChild("DungeonTestPlaceholderRelease")
)
local UiTheme = require(shared:WaitForChild("UiTheme"))

local GUI_NAME = "FriendTestBanner"

if not TestRelease.is_test_temple_context() then
    return
end

local old = player_gui:FindFirstChild(GUI_NAME)
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.DisplayOrder = 135
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player_gui

local frame = Instance.new("Frame")
frame.Name = "Banner"
frame.AnchorPoint = Vector2.new(1, 0)
frame.Position = UDim2.new(1, -16, 0, 18)
frame.Size = UDim2.fromOffset(330, 62)
UiTheme.style_panel(frame, true)
UiTheme.bind_responsive_scale(frame, 1366, 0.72, 1)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.fromOffset(12, 8)
title.Size = UDim2.new(1, -24, 0, 18)
title.Text = "FRIEND TEST • TEST DATA"
UiTheme.style_label(title, "Caption")
title.TextColor3 = UiTheme.PALETTE.Accent
title.Parent = frame

local detail = Instance.new("TextLabel")
detail.Name = "Detail"
detail.Position = UDim2.fromOffset(12, 27)
detail.Size = UDim2.new(1, -24, 0, 27)
detail.TextWrapped = true
detail.TextTruncate = Enum.TextTruncate.None
UiTheme.style_label(detail, "Muted")
detail.Parent = frame

if TestRelease.is_test_lobby() then
    detail.Text = "Temple entrance → Create Party → Invite → both Ready → "
        .. "leader starts Depth 1."
else
    detail.Text = "Published TEST Dungeon. Stay together and report anything "
        .. "that feels unclear, broken, or exploitable."
end
