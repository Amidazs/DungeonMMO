--!strict
-- Compact bottom-right character/system menu inspired by classic MMORPG HUDs.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player_gui = Players.LocalPlayer:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("Core")
    :WaitForChild("Shared")
local UiComponents = require(shared:WaitForChild("UiComponents"))
local UiOrnament = require(shared:WaitForChild("UiOrnament"))
local UiTheme = require(shared:WaitForChild("UiTheme"))
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

local actions = {
    {
        name = "Skills",
        label = "Skills",
        key = "K",
        glyph = "⚔",
        tint = Color3.fromRGB(47, 83, 127),
    },
    {
        name = "Quests",
        label = "Quests",
        key = "L",
        glyph = "✧",
        tint = Color3.fromRGB(104, 71, 33),
    },
    {
        name = "Inventory",
        label = "Inventory",
        key = "I",
        glyph = "▣",
        tint = Color3.fromRGB(93, 61, 31),
    },
}

if script.Parent.Parent:FindFirstChild("Base") then
    table.insert(actions, 1, {
        name = "Guild",
        label = "Guild",
        key = "J",
        glyph = "♜",
        tint = Color3.fromRGB(88, 67, 30),
    })
end

local frame = Instance.new("Frame")
frame.Name = "CommandBar"
frame.AnchorPoint = Vector2.new(1, 1)
frame.Position = UDim2.new(1, -18, 1, -18)
frame.Size = UDim2.fromOffset(
    18 + #actions * 68,
    76
)
frame.BackgroundColor3 = UiTheme.PALETTE.BackdropSoft
frame.BackgroundTransparency = 0.12
frame.BorderSizePixel = 0
UiTheme.add_corner(frame, 2)
UiTheme.add_stroke(
    frame,
    UiTheme.PALETTE.Border,
    0.18
)
frame.Parent = gui
UiOrnament.frame(frame, false)
UiTheme.bind_responsive_scale(frame, 1366, 0.58, 1)

local button_row = Instance.new("Frame")
button_row.Name = "ButtonRow"
button_row.Position = UDim2.fromOffset(8, 5)
button_row.Size = UDim2.new(1, -16, 1, -10)
button_row.BackgroundTransparency = 1
button_row.Parent = frame

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 4)
layout.Parent = button_row

local buttons: {[string]: TextButton} = {}
local icon_frames: {[string]: Frame} = {}

--[[
Creates one functional command icon and its keyboard hint.

Args:
    action (any): Command presentation definition.
    order (number): Horizontal display order.

Returns:
    None.
]]
local function create_command(
    action: any,
    order: number
)
    local button = UiComponents.button(
        button_row,
        action.name .. "Command",
        "",
        "Ghost"
    )
    button.LayoutOrder = order
    button.Size = UDim2.fromOffset(62, 64)
    button.BackgroundTransparency = 1
    button:SetAttribute(
        "DMMOUiBaseTransparency",
        1
    )

    local icon = UiOrnament.icon(
        button,
        "Icon",
        action.glyph,
        action.tint,
        44
    )
    icon.AnchorPoint = Vector2.new(0.5, 0)
    icon.Position = UDim2.new(0.5, 0, 0, 1)

    local label = UiComponents.label(
        button,
        "Label",
        action.label,
        "Caption"
    )
    label.AnchorPoint = Vector2.new(0.5, 1)
    label.Position = UDim2.new(0.5, 0, 1, -1)
    label.Size = UDim2.new(1, -4, 0, 18)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextColor3 = UiTheme.PALETTE.Text

    local key = UiComponents.key_hint(
        button,
        action.key
    )
    key.AnchorPoint = Vector2.new(1, 0)
    key.Position = UDim2.new(1, -3, 0, 1)
    key.Size = UDim2.fromOffset(19, 17)
    key.TextSize = 9
    key.ZIndex = 5

    button.Activated:Connect(function()
        Controller.toggle(action.name)
    end)

    buttons[action.name] = button
    icon_frames[action.name] = icon
end

for index, action in ipairs(actions) do
    create_command(action, index)
end

--[[
Synchronises gold command highlights with managed window visibility.

Args:
    active_name (string?): Name of the currently open managed window.

Returns:
    None.
]]
local function update_selection(
    active_name: string?
)
    for name, button in pairs(buttons) do
        local active = name == active_name
        local icon = icon_frames[name]
        local stroke = icon:FindFirstChildOfClass("UIStroke")

        button.BackgroundTransparency = if active then 0.72 else 1

        if stroke then
            stroke.Color = if active
                then UiTheme.PALETTE.AccentBright
                else UiTheme.PALETTE.Border
            stroke.Thickness = if active then 3 else 2
        end
    end
end

Controller.Changed:Connect(update_selection)
update_selection(Controller.active())

UserInputService.InputBegan:Connect(function(
    input: InputObject,
    processed: boolean
)
    if processed or input.KeyCode ~= Enum.KeyCode.Escape then
        return
    end

    local active = Controller.active()
    if active then
        Controller.set_visible(active, false)
    end
end)
