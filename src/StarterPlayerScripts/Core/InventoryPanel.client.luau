--!strict
-- Full read-only tabbed inventory browser shared by Base and Dungeon.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local InventoryPresentation = require(
    shared:WaitForChild("InventoryPresentation")
)
local inventory_snapshot = remotes:WaitForChild(
    "InventorySnapshot"
) :: RemoteEvent
local profile_snapshot = remotes:WaitForChild(
    "ProfileSnapshot"
) :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "InventoryPanelUi"
gui.ResetOnSpawn = false
gui.DisplayOrder = 170
gui.Parent = player:WaitForChild("PlayerGui")

local toggle = Instance.new("TextButton")
toggle.Name = "InventoryToggle"
toggle.Position = UDim2.fromOffset(16, 66)
toggle.Size = UDim2.fromOffset(154, 34)
toggle.BackgroundColor3 = Color3.fromRGB(29, 32, 38)
toggle.BackgroundTransparency = 0.08
toggle.TextColor3 = Color3.fromRGB(244, 244, 244)
toggle.Text = "Inventory [I]"
toggle.Parent = gui

local panel = Instance.new("Frame")
panel.Name = "InventoryPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(780, 560)
panel.BackgroundColor3 = Color3.fromRGB(23, 25, 31)
panel.BackgroundTransparency = 0.03
panel.Visible = false
panel.Parent = gui

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(18, 10)
title.Size = UDim2.new(1, -90, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(246, 246, 246)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextScaled = true
title.Text = "Inventory"
title.Parent = panel

local close = Instance.new("TextButton")
close.Position = UDim2.new(1, -56, 0, 10)
close.Size = UDim2.fromOffset(40, 38)
close.Text = "X"
close.Parent = panel

local tab_strip = Instance.new("Frame")
tab_strip.Name = "CategoryTabs"
tab_strip.Position = UDim2.fromOffset(18, 58)
tab_strip.Size = UDim2.new(1, -36, 0, 38)
tab_strip.BackgroundTransparency = 1
tab_strip.Parent = panel

local tab_layout = Instance.new("UIListLayout")
tab_layout.FillDirection = Enum.FillDirection.Horizontal
tab_layout.Padding = UDim.new(0, 6)
tab_layout.SortOrder = Enum.SortOrder.LayoutOrder
tab_layout.Parent = tab_strip

local summary = Instance.new("TextLabel")
summary.Position = UDim2.fromOffset(18, 100)
summary.Size = UDim2.new(1, -36, 0, 28)
summary.BackgroundTransparency = 1
summary.TextColor3 = Color3.fromRGB(205, 208, 214)
summary.TextXAlignment = Enum.TextXAlignment.Left
summary.Text = "0 item types"
summary.Parent = panel

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(18, 132)
list.Size = UDim2.new(1, -36, 1, -150)
list.BackgroundTransparency = 0.15
list.BorderSizePixel = 0
list.ScrollBarThickness = 8
list.CanvasSize = UDim2.fromOffset(0, 0)
list.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = list

local latest_entries: any = {}
local selected_tab = "All"
local tab_buttons: {[string]: TextButton} = {}

local function clear_rows()
    for _, child in ipairs(list:GetChildren()) do
        if child ~= layout then
            child:Destroy()
        end
    end
end

local function add_item_row(row: any)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 58)
    frame.BackgroundColor3 = Color3.fromRGB(37, 40, 47)
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel = 0
    frame.Parent = list

    local name = Instance.new("TextLabel")
    name.Position = UDim2.fromOffset(12, 6)
    name.Size = UDim2.new(1, -130, 0, 24)
    name.BackgroundTransparency = 1
    name.TextColor3 = Color3.fromRGB(245, 245, 245)
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Text = tostring(row.Name)
    name.Parent = frame

    local detail = Instance.new("TextLabel")
    detail.Position = UDim2.fromOffset(12, 31)
    detail.Size = UDim2.new(1, -130, 0, 20)
    detail.BackgroundTransparency = 1
    detail.TextColor3 = Color3.fromRGB(185, 190, 198)
    detail.TextXAlignment = Enum.TextXAlignment.Left
    detail.Text = string.format(
        "%s  •  %s%s",
        tostring(row.CategoryName or "Other"),
        tostring(row.Rarity or "Unknown"),
        if row.ItemCategory
            then "  •  " .. tostring(row.ItemCategory)
            else ""
    )
    detail.Parent = frame

    local quantity = Instance.new("TextLabel")
    quantity.Position = UDim2.new(1, -110, 0, 10)
    quantity.Size = UDim2.fromOffset(94, 36)
    quantity.BackgroundTransparency = 1
    quantity.TextColor3 = Color3.fromRGB(240, 240, 240)
    quantity.TextXAlignment = Enum.TextXAlignment.Right
    quantity.TextScaled = true
    quantity.Text = "x" .. tostring(row.Quantity)
    quantity.Parent = frame
end

local function render_tab_state(counts: any)
    for _, category in ipairs(InventoryPresentation.tabs()) do
        local button = tab_buttons[category]
        if button then
            button.Text = InventoryPresentation.tab_label(category, counts)
            local selected = category == selected_tab
            button.BackgroundTransparency = if selected then 0.05 else 0.35
            button.TextColor3 = if selected
                then Color3.fromRGB(255, 255, 255)
                else Color3.fromRGB(205, 208, 214)
        end
    end
end

local function render()
    clear_rows()

    local rows = InventoryPresentation.build(latest_entries)
    local counts = InventoryPresentation.counts(rows)
    local visible_rows = InventoryPresentation.filter(rows, selected_tab)

    render_tab_state(counts)

    summary.Text = string.format(
        "%s • %d of %d item type%s",
        InventoryPresentation.category_name(selected_tab),
        #visible_rows,
        #rows,
        if #rows == 1 then "" else "s"
    )

    if #visible_rows == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -10, 0, 60)
        empty.BackgroundTransparency = 1
        empty.TextColor3 = Color3.fromRGB(205, 205, 205)
        empty.Text = if #rows == 0
            then "Inventory is empty."
            else "No items in this category."
        empty.Parent = list
    else
        for _, row in ipairs(visible_rows) do
            add_item_row(row)
        end
    end

    list.CanvasPosition = Vector2.new(0, 0)
    task.defer(function()
        list.CanvasSize = UDim2.fromOffset(
            0,
            layout.AbsoluteContentSize.Y + 10
        )
    end)
end

for index, category in ipairs(InventoryPresentation.tabs()) do
    local button = Instance.new("TextButton")
    button.Name = category .. "Tab"
    button.LayoutOrder = index
    button.Size = UDim2.fromOffset(116, 34)
    button.BackgroundColor3 = Color3.fromRGB(42, 46, 54)
    button.BackgroundTransparency = 0.35
    button.TextColor3 = Color3.fromRGB(205, 208, 214)
    button.TextScaled = false
    button.TextSize = 14
    button.Text = InventoryPresentation.category_name(category)
    button.Parent = tab_strip
    tab_buttons[category] = button

    button.Activated:Connect(function()
        selected_tab = category
        render()
    end)
end

local function request_refresh()
    -- Existing server ProfileSnapshot request sends Profile + Inventory + Equipment.
    profile_snapshot:FireServer("Request")
end

local function set_visible(value: boolean)
    panel.Visible = value
    if value then
        request_refresh()
    end
end

toggle.Activated:Connect(function()
    set_visible(not panel.Visible)
end)

close.Activated:Connect(function()
    set_visible(false)
end)

UserInputService.InputBegan:Connect(function(
    input: InputObject,
    processed: boolean
)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.I then
        set_visible(not panel.Visible)
    end
end)

inventory_snapshot.OnClientEvent:Connect(function(entries: any)
    latest_entries = if type(entries) == "table" then entries else {}
    render()
end)

render()
task.defer(request_refresh)
