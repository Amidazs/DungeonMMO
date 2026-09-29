--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player_gui = Players.LocalPlayer:WaitForChild("PlayerGui")
local shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local UiArt = require(
    shared:WaitForChild("UiArt")
)
local UiTheme = require(
    shared:WaitForChild("UiTheme")
)
local Controller = require(
    script.Parent:WaitForChild("HudWindowController")
)

local previous = player_gui:FindFirstChild("HudCommandMenu")
if previous then
    previous:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "HudCommandMenu"
gui.ResetOnSpawn = false
gui.DisplayOrder = 140
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player_gui

local frame = Instance.new("Frame")
frame.Name = "CommandBar"
frame.AnchorPoint = Vector2.new(1, 1)
frame.Position = UDim2.new(1, -18, 1, -18)
frame.Size = UDim2.fromOffset(354, 82)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Parent = gui
UiTheme.bind_responsive_scale(frame, 1600, 0.58, 1)

UiArt.command_strip(frame, 1)

local ACTIONS = {
    "Guild",
    "Skills",
    "Stats",
    "Inventory",
    "Map",
}

local buttons: {[string]: TextButton} = {}
local highlights: {[string]: Frame} = {}

--[[
Creates one transparent hit target over the painted command strip.

Args:
    name (string): Managed window name.
    order (number): One-based command-strip position.

Returns:
    None.
]]
local function create_command(
    name: string,
    order: number
)
    local button = Instance.new("TextButton")
    button.Name = name .. "Command"
    button.Position = UDim2.fromScale(
        (order - 1) / #ACTIONS,
        0
    )
    button.Size = UDim2.fromScale(
        1 / #ACTIONS,
        1
    )
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 3
    button.Parent = frame

    local highlight = Instance.new("Frame")
    highlight.Name = "SelectionGlow"
    highlight.Position = UDim2.fromOffset(5, 5)
    highlight.Size = UDim2.new(1, -10, 1, -10)
    highlight.BackgroundColor3 = Color3.fromRGB(245, 191, 76)
    highlight.BackgroundTransparency = 1
    highlight.BorderSizePixel = 0
    highlight.ZIndex = 2
    UiTheme.add_corner(highlight, 5)
    highlight.Parent = button

    button.MouseEnter:Connect(function()
        if Controller.active() ~= name then
            highlight.BackgroundTransparency = 0.88
        end
    end)

    button.MouseLeave:Connect(function()
        if Controller.active() ~= name then
            highlight.BackgroundTransparency = 1
        end
    end)

    button.Activated:Connect(function()
        Controller.set_visible(name, true)
    end)

    buttons[name] = button
    highlights[name] = highlight
end

--[[
Synchronises the selected command with the active managed window.

Args:
    active_name (string?): Current managed window name.

Returns:
    None.
]]
local function update_selection(active_name: string?)
    for name, highlight in pairs(highlights) do
        highlight.BackgroundTransparency =
            if name == active_name then 0.82 else 1
    end
end

for index, name in ipairs(ACTIONS) do
    create_command(name, index)
end

Controller.Changed:Connect(update_selection)
update_selection(Controller.active())
