--!strict
-- Lightweight first-expedition tutorial for low-level Dungeon entrants.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")

local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local TutorialDefinitions = require(
    shared:WaitForChild("TutorialDefinitions")
)
local UiTheme = require(shared:WaitForChild("UiTheme"))
local UiOrnament = require(
    shared:WaitForChild("UiOrnament")
)

local profile_snapshot = remotes:WaitForChild(
    "ProfileSnapshot"
) :: RemoteEvent

local GUI_NAME = "FirstExpeditionTutorial"
local MAX_TUTORIAL_LEVEL = 3

local old = player_gui:FindFirstChild(GUI_NAME)
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.DisplayOrder = 195
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Enabled = false
gui.Parent = player_gui

local panel = Instance.new("Frame")
panel.Name = "TutorialPanel"
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.new(0.5, 0, 0, 24)
panel.Size = UDim2.fromOffset(560, 246)
UiTheme.style_panel(panel, true)
panel.Parent = gui
UiOrnament.frame(panel, true)
UiTheme.bind_responsive_scale(panel, 1366, 0.68, 1)

local eyebrow = Instance.new("TextLabel")
eyebrow.Name = "Eyebrow"
eyebrow.Position = UDim2.fromOffset(22, 12)
eyebrow.Size = UDim2.new(1, -44, 0, 18)
eyebrow.Text = "EXPEDITION TUTORIAL"
UiTheme.style_label(eyebrow, "Caption")
eyebrow.TextColor3 = UiTheme.PALETTE.Accent
eyebrow.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.fromOffset(22, 34)
title.Size = UDim2.new(1, -44, 0, 30)
title.Text = TutorialDefinitions.DUNGEON_TITLE
UiTheme.style_label(title, "Heading")
title.Parent = panel

local body = Instance.new("TextLabel")
body.Name = "Body"
body.Position = UDim2.fromOffset(22, 70)
body.Size = UDim2.new(1, -44, 0, 116)
body.Text = TutorialDefinitions.DUNGEON_TEXT
UiTheme.style_label(body, "Body")
body.TextWrapped = true
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextTruncate = Enum.TextTruncate.None
body.Parent = panel

local dismiss_button = Instance.new("TextButton")
dismiss_button.Name = "Dismiss"
dismiss_button.AnchorPoint = Vector2.new(1, 1)
dismiss_button.Position = UDim2.new(1, -22, 1, -16)
dismiss_button.Size = UDim2.fromOffset(150, 36)
dismiss_button.Text = "Start Expedition"
UiTheme.style_button(dismiss_button, "Primary")
dismiss_button.Parent = panel

local note = Instance.new("TextLabel")
note.Name = "Note"
note.AnchorPoint = Vector2.new(0, 1)
note.Position = UDim2.new(0, 22, 1, -20)
note.Size = UDim2.new(1, -200, 0, 32)
note.Text = "This reminder is shown only to low-level test characters."
UiTheme.style_label(note, "Caption")
note.TextWrapped = true
note.Parent = panel

local decided = false

--[[
Closes the first-expedition tutorial for this Dungeon client.

Args:
    None.

Returns:
    nil: Hides the presentation without changing gameplay state.
]]
local function dismiss()
    gui.Enabled = false
    decided = true
end

--[[
Uses the authoritative profile level to decide whether to show onboarding.

Args:
    payload (any): ProfileSnapshot payload from the Dungeon server.

Returns:
    nil: Shows the tutorial only for low-level characters.
]]
local function handle_profile(payload: any)
    if decided or type(payload) ~= "table" then
        return
    end

    local level = tonumber(payload.Level)
    if not level then
        return
    end

    decided = true
    gui.Enabled = level <= MAX_TUTORIAL_LEVEL
end

dismiss_button.Activated:Connect(dismiss)
profile_snapshot.OnClientEvent:Connect(handle_profile)
