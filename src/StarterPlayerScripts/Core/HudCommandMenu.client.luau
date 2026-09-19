--!strict
-- A compact, anchored menu for existing functional player windows.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player_gui = Players.LocalPlayer:WaitForChild("PlayerGui")
local shared = ReplicatedStorage:WaitForChild("Core")
    :WaitForChild("Shared")
local UiComponents = require(shared:WaitForChild("UiComponents"))
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

local frame = Instance.new("Frame")
frame.Name = "CommandBar"
frame.AnchorPoint = Vector2.new(1, 1)
frame.Position = UDim2.new(1, -16, 1, -18)
frame.Size = UDim2.fromOffset(160, 76)
UiTheme.style_panel(frame, true)
frame.Parent = gui
UiTheme.bind_responsive_scale(frame, 1366, 0.55, 1)

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 6)
layout.Parent = frame

local buttons: {[string]: TextButton} = {}
local actions = {
    {name = "Inventory", text = "BAG\nI"},
    {name = "Skills", text = "SKILLS\nK"},
}

-- Guild is only loaded in the Base place.
if script.Parent.Parent:FindFirstChild("Base") then
    table.insert(actions, {name = "Guild", text = "GUILD\nJ"})
    frame.Size = UDim2.fromOffset(228, 76)
end

-- Creates one icon-ready command button with a working destination.
for index, action in ipairs(actions) do
    local button = UiComponents.button(
        frame, action.name .. "Command", action.text, "Secondary"
    )
    button.LayoutOrder = index
    button.Size = UDim2.fromOffset(66, 58)
    button.TextSize = 12
    button.Activated:Connect(function()
        Controller.toggle(action.name)
    end)
    buttons[action.name] = button
end

-- Keeps the command highlight synchronized with keyboard and close controls.
local function update_selection(active_name: string?)
    for name, button in pairs(buttons) do
        UiTheme.style_button(
            button, if name == active_name then "Primary" else "Secondary"
        )
    end
end

Controller.Changed:Connect(update_selection)
update_selection(Controller.active())

-- Escape closes only a window managed by this menu.
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Escape then
        local active = Controller.active()
        if active then
            Controller.set_visible(active, false)
        end
    end
end)
