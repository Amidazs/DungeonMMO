--!strict
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
local UiComponents = require(
    shared:WaitForChild("UiComponents")
)
local UiTheme = require(
    shared:WaitForChild("UiTheme")
)
local UiOrnament = require(
    shared:WaitForChild("UiOrnament")
)

local inventory_snapshot = remotes:WaitForChild(
    "InventorySnapshot"
) :: RemoteEvent
local profile_snapshot = remotes:WaitForChild(
    "ProfileSnapshot"
) :: RemoteEvent

local WindowController = require(
    script.Parent:WaitForChild("HudWindowController")
)

local player_gui = player:WaitForChild("PlayerGui")
local old = player_gui:FindFirstChild("InventoryPanelUi")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "InventoryPanelUi"
gui.ResetOnSpawn = false
gui.DisplayOrder = 170
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player_gui

local backdrop = Instance.new("TextButton")
backdrop.Name = "Backdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = UiTheme.PALETTE.Backdrop
backdrop.BackgroundTransparency = 0.28
backdrop.Text = ""
backdrop.AutoButtonColor = false
backdrop.Visible = false
backdrop.ZIndex = 10
backdrop.Parent = gui

local modal = UiComponents.modal(
    gui,
    "InventoryPanel",
    "Inventory",
    "Browse carried equipment, materials and consumables.",
    UDim2.fromOffset(800, 570)
)
local panel = modal.Root
panel.Visible = false
panel.ZIndex = 11
modal.Header.ZIndex = 12
modal.Title.ZIndex = 12
modal.Subtitle.ZIndex = 12
modal.Close.ZIndex = 12
modal.Body.ZIndex = 12
UiTheme.bind_responsive_scale(
    panel,
    1366,
    0.35,
    1
)

local tab_strip = Instance.new("Frame")
tab_strip.Name = "CategoryTabs"
tab_strip.Size = UDim2.new(1, 0, 0, 38)
tab_strip.BackgroundTransparency = 1
tab_strip.ZIndex = 12
tab_strip.Parent = modal.Body

local tab_layout = Instance.new("UIListLayout")
tab_layout.FillDirection = Enum.FillDirection.Horizontal
tab_layout.Padding = UDim.new(0, 7)
tab_layout.SortOrder = Enum.SortOrder.LayoutOrder
tab_layout.Parent = tab_strip

local summary = UiComponents.label(
    modal.Body,
    "Summary",
    "Loading inventory...",
    "Muted"
)
summary.Position = UDim2.fromOffset(2, 48)
summary.Size = UDim2.new(1, -4, 0, 24)
summary.ZIndex = 12

local list = Instance.new("ScrollingFrame")
list.Name = "ItemList"
list.Position = UDim2.fromOffset(0, 80)
list.Size = UDim2.new(1, 0, 1, -80)
list.CanvasSize = UDim2.fromOffset(0, 0)
list.AutomaticCanvasSize = Enum.AutomaticSize.None
list.ZIndex = 12
UiTheme.style_scroll(list)
list.Parent = modal.Body

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = list

local layout = Instance.new("UIGridLayout")
layout.CellSize = UDim2.fromOffset(139, 119)
layout.CellPadding = UDim2.fromOffset(8, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local latest_entries: any = {}
local selected_tab = "All"
local tab_buttons: {[string]: TextButton} = {}

--[[
Returns a presentation colour for one rarity label.

Args:
    rarity (any): Rarity value from inventory presentation.

Returns:
    Color3: Accent colour for the item row.
]]
local function rarity_color(rarity: any): Color3
    local value = string.lower(tostring(rarity or ""))

    if value == "legendary" then
        return Color3.fromRGB(221, 151, 61)
    elseif value == "epic" then
        return Color3.fromRGB(166, 93, 213)
    elseif value == "rare" then
        return Color3.fromRGB(75, 132, 216)
    elseif value == "uncommon" then
        return Color3.fromRGB(76, 166, 98)
    end

    return UiTheme.PALETTE.BorderSoft
end

--[[
Removes generated inventory rows.

Args:
    None.

Returns:
    None.
]]
local function clear_rows()
    for _, child in ipairs(list:GetChildren()) do
        if child ~= layout
            and child ~= padding
            and child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

--[[
Creates one themed inventory row.

Args:
    row (any): Inventory presentation row.

Returns:
    None.
]]
local function add_item_row(row: any)
    local frame = Instance.new("Frame")
    frame.Name = tostring(row.Id or row.Name or "Item")
    frame.Size = UDim2.fromOffset(139, 119)
    frame.BackgroundColor3 = UiTheme.PALETTE.SurfaceRaised
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel = 0
    frame.ZIndex = 13
    UiTheme.add_corner(frame, 7)
    UiTheme.add_stroke(
        frame,
        UiTheme.PALETTE.BorderSoft,
        0.58
    )
    frame.Parent = list

    local rarity = Instance.new("Frame")
    rarity.Name = "Rarity"
    rarity.Size = UDim2.new(1, -14, 0, 3)
    rarity.Position = UDim2.fromOffset(7, 7)
    rarity.BackgroundColor3 = rarity_color(row.Rarity)
    rarity.BorderSizePixel = 0
    rarity.ZIndex = 14
    UiTheme.add_corner(rarity, 2)
    rarity.Parent = frame

    local icon = UiOrnament.icon(
        frame,
        "ItemIcon",
        string.sub(tostring(row.Name), 1, 1),
        rarity_color(row.Rarity):Lerp(
            UiTheme.PALETTE.SurfaceRaised, 0.55
        ),
        42
    )
    icon.Position = UDim2.fromOffset(48, 12)

    local name = UiComponents.label(
        frame,
        "Name",
        tostring(row.Name),
        "Heading"
    )
    name.Position = UDim2.fromOffset(7, 59)
    name.Size = UDim2.new(1, -14, 0, 25)
    name.TextSize = 11
    name.TextXAlignment = Enum.TextXAlignment.Center
    name.ZIndex = 14

    local detail = UiComponents.label(
        frame,
        "Detail",
        string.format(
            "%s   •   %s%s",
            tostring(row.CategoryName or "Other"),
            tostring(row.Rarity or "Unknown"),
            if row.ItemCategory
                then "   •   " .. tostring(row.ItemCategory)
                else ""
        ),
        "Muted"
    )
    detail.Position = UDim2.fromOffset(7, 85)
    detail.Size = UDim2.new(1, -14, 0, 14)
    detail.TextSize = 9
    detail.TextXAlignment = Enum.TextXAlignment.Center
    detail.ZIndex = 14

    local quantity = UiComponents.label(
        frame,
        "Quantity",
        "×" .. tostring(row.Quantity),
        "Heading"
    )
    quantity.AnchorPoint = Vector2.new(1, 0.5)
    quantity.Position = UDim2.new(1, -8, 0, 17)
    quantity.Size = UDim2.fromOffset(31, 20)
    quantity.TextSize = 11
    quantity.TextXAlignment = Enum.TextXAlignment.Right
    quantity.TextColor3 = UiTheme.PALETTE.AccentBright
    quantity.ZIndex = 14
end

--[[
Refreshes tab labels and selected-state styling.

Args:
    counts (any): Item counts by inventory category.

Returns:
    None.
]]
local function render_tab_state(counts: any)
    for _, category in ipairs(
        InventoryPresentation.tabs()
    ) do
        local button = tab_buttons[category]
        if button then
            button.Text = InventoryPresentation.tab_label(
                category,
                counts
            )
            local selected = category == selected_tab
            button.BackgroundColor3 = if selected
                then UiTheme.PALETTE.AccentDark
                else UiTheme.PALETTE.SurfaceRaised
            UiTheme.add_stroke(
                button,
                if selected
                    then UiTheme.PALETTE.Accent
                    else UiTheme.PALETTE.BorderSoft,
                if selected then 0.15 else 0.5
            )
        end
    end
end

--[[
Renders current inventory rows and summary.

Args:
    None.

Returns:
    None.
]]
local function render()
    clear_rows()

    local rows = InventoryPresentation.build(
        latest_entries
    )
    local counts = InventoryPresentation.counts(rows)
    local visible_rows = InventoryPresentation.filter(
        rows,
        selected_tab
    )

    render_tab_state(counts)

    summary.Text = string.format(
        "%s   •   %d shown   •   %d total item type%s",
        InventoryPresentation.category_name(
            selected_tab
        ),
        #visible_rows,
        #rows,
        if #rows == 1 then "" else "s"
    )

    if #visible_rows == 0 then
        local empty = UiComponents.label(
            list,
            "Empty",
            if #rows == 0
                then "Your inventory is empty."
                else "No items in this category.",
            "Muted"
        )
        empty.Size = UDim2.new(1, -12, 0, 72)
        empty.TextXAlignment = Enum.TextXAlignment.Center
        empty.ZIndex = 13
    else
        for _, row in ipairs(visible_rows) do
            add_item_row(row)
        end
    end

    list.CanvasPosition = Vector2.zero
    task.defer(function()
        list.CanvasSize = UDim2.fromOffset(
            0,
            layout.AbsoluteContentSize.Y + 16
        )
    end)
end

--[[
Requests current profile-backed inventory state.

Args:
    None.

Returns:
    None.
]]
local function request_refresh()
    profile_snapshot:FireServer("Request")
end

--[[
Shows or hides the Inventory modal.

Args:
    visible (boolean): Desired modal visibility.

Returns:
    None.
]]
local function apply_visibility(visible: boolean)
    panel.Visible = visible
    backdrop.Visible = visible
    if visible then
        request_refresh()
    end
end

for index, category in ipairs(
    InventoryPresentation.tabs()
) do
    local button = UiComponents.button(
        tab_strip,
        category .. "Tab",
        InventoryPresentation.category_name(category),
        "Secondary"
    )
    button.LayoutOrder = index
    button.Size = UDim2.fromOffset(118, 34)
    button.ZIndex = 13
    tab_buttons[category] = button

    button.Activated:Connect(function()
        selected_tab = category
        render()
    end)
end

WindowController.register("Inventory", apply_visibility)

local function set_visible(visible: boolean)
    WindowController.set_visible("Inventory", visible)
end

modal.Close.Activated:Connect(function()
    set_visible(false)
end)
backdrop.Activated:Connect(function()
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
    latest_entries = if type(entries) == "table"
        then entries
        else {}
    render()
end)

render()
task.defer(request_refresh)
