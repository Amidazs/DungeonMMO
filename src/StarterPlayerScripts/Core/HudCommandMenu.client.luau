--!strict
-- Compact bottom-right character/system menu inspired by classic MMORPG HUDs.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player_gui = Players.LocalPlayer:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("Core")
    :WaitForChild("Shared")
local UiComponents = require(shared:WaitForChild("UiComponents"))
local UiArt = require(shared:WaitForChild("UiArt"))
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
        name = "Stats",
        label = "Stats",
        key = "C",
        glyph = "✦",
        tint = Color3.fromRGB(98, 76, 38),
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
    #actions * 58,
    76
)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Parent = gui
UiTheme.bind_responsive_scale(frame, 1366, 0.58, 1)

local button_row = Instance.new("Frame")
button_row.Name = "ButtonRow"
button_row.Position = UDim2.fromOffset(0, 0)
button_row.Size = UDim2.fromScale(1, 1)
button_row.BackgroundTransparency = 1
button_row.Parent = frame

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, -1)
layout.SortOrder = Enum.SortOrder.LayoutOrder
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
    button.Size = UDim2.fromOffset(58, 76)
    button.BackgroundTransparency = 1
    button:SetAttribute(
        "DMMOUiBaseTransparency",
        1
    )

    local button_art = UiArt.image(
        button,
        "ButtonArt",
        "CommandButton",
        2
    )
    button_art.Size = UDim2.fromScale(1, 1)

    local icon = Instance.new("Frame")
    icon.Name = "Icon"
    icon.AnchorPoint = Vector2.new(0.5, 0)
    icon.Position = UDim2.new(0.5, 0, 0, 9)
    icon.Size = UDim2.fromOffset(35, 35)
    icon.BackgroundColor3 = action.tint
    icon.BackgroundTransparency = 0.08
    icon.BorderSizePixel = 0
    icon.ZIndex = 3
    icon.Parent = button

    local icon_gradient = Instance.new("UIGradient")
    icon_gradient.Color = ColorSequence.new(
        action.tint:Lerp(Color3.new(1, 1, 1), 0.18),
        action.tint:Lerp(Color3.new(0, 0, 0), 0.54)
    )
    icon_gradient.Rotation = 120
    icon_gradient.Parent = icon

    local glyph = UiComponents.label(
        icon,
        "Glyph",
        action.glyph,
        "Heading"
    )
    glyph.Size = UDim2.fromScale(1, 1)
    glyph.TextXAlignment = Enum.TextXAlignment.Center
    glyph.TextColor3 = UiTheme.PALETTE.AccentBright
    glyph.TextStrokeColor3 = UiTheme.PALETTE.Backdrop
    glyph.TextStrokeTransparency = 0.08
    glyph.TextSize = 21
    glyph.ZIndex = 4

    local label = UiComponents.label(
        button,
        "Label",
        action.label,
        "Caption"
    )
    label.AnchorPoint = Vector2.new(0.5, 1)
    label.Position = UDim2.new(0.5, 0, 1, -7)
    label.Size = UDim2.new(1, -4, 0, 15)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextColor3 = UiTheme.PALETTE.TextMuted
    label.TextSize = 9
    label.ZIndex = 4

    local key = UiComponents.key_hint(
        button,
        action.key
    )
    key.AnchorPoint = Vector2.new(1, 0)
    key.Position = UDim2.new(1, -2, 0, 2)
    key.Size = UDim2.fromOffset(16, 15)
    key.TextSize = 8
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
        button.BackgroundTransparency = 1

        icon.BackgroundTransparency = if active then 0 else 0.08
        local glyph = icon:FindFirstChild("Glyph")
        if glyph and glyph:IsA("TextLabel") then
            glyph.TextColor3 = if active
                then Color3.fromRGB(255, 240, 181)
                else UiTheme.PALETTE.AccentBright
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
