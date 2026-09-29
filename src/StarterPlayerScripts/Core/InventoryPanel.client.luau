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
local UiArt = require(
    shared:WaitForChild("UiArt")
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
    UDim2.fromOffset(680, 850)
)
local panel = modal.Root
panel.Visible = false
panel.ZIndex = 11
UiArt.clear_frame_chrome(panel)
UiArt.reference_background(
    panel,
    "Inventory",
    11
)

modal.Header.ZIndex = 14
modal.Title.Visible = false
modal.Subtitle.Visible = false
modal.Close.ZIndex = 15
modal.Close.BackgroundTransparency = 1
modal.Close.TextTransparency = 1

local header_band = panel:FindFirstChild("HeaderBand")
if header_band and header_band:IsA("GuiObject") then
    header_band.Visible = false
end

local divider = panel:FindFirstChild("OrnateDivider")
if divider and divider:IsA("GuiObject") then
    divider.Visible = false
end

modal.Body.Position = UiArt.position(
    "Inventory",
    472,
    220
)
modal.Body.Size = UiArt.rect(
    "Inventory",
    472,
    220,
    602,
    1060
)
modal.Body.ZIndex = 14

UiTheme.bind_responsive_scale(
    panel,
    1366,
    0.62,
    1
)

local character_panel = Instance.new("Frame")
character_panel.Name = "CharacterPreview"
character_panel.Position = UiArt.position(
    "Inventory",
    66,
    238
)
character_panel.Size = UiArt.rect(
    "Inventory",
    66,
    238,
    372,
    1012
)
character_panel.BackgroundTransparency = 1
character_panel.ZIndex = 14
character_panel.Parent = panel

local avatar = Instance.new("ImageLabel")
avatar.Name = "Avatar"
avatar.AnchorPoint = Vector2.new(0.5, 0)
avatar.Position = UDim2.new(0.5, 0, 0, 34)
avatar.Size = UDim2.new(0.82, 0, 0.62, 0)
avatar.BackgroundTransparency = 1
avatar.ScaleType = Enum.ScaleType.Fit
avatar.ZIndex = 15
avatar.Parent = character_panel

local character_name = UiComponents.label(
    character_panel,
    "CharacterName",
    player.DisplayName,
    "Title"
)
character_name.AnchorPoint = Vector2.new(0.5, 0)
character_name.Position = UDim2.new(0.5, 0, 0.69, 0)
character_name.Size = UDim2.new(0.9, 0, 0, 28)
character_name.TextXAlignment = Enum.TextXAlignment.Center
character_name.ZIndex = 15

local view_stats = UiComponents.button(character_panel, "ViewStats", "View Stats", "Primary")
view_stats.Position = UDim2.fromScale(0.1, 0.88)
view_stats.Size = UDim2.new(0.8, 0, 0, 36)
view_stats.ZIndex = 16
UiArt.paint_button(view_stats, "Primary")
view_stats.Activated:Connect(function() WindowController.set_visible("Stats", true) end)

local character_hint = UiComponents.label(
    character_panel,
    "CharacterHint",
    "Carried equipment and adventure supplies",
    "Muted"
)
character_hint.AnchorPoint = Vector2.new(0.5, 0)
character_hint.Position = UDim2.new(0.5, 0, 0.75, 0)
character_hint.Size = UDim2.new(0.84, 0, 0, 42)
character_hint.TextWrapped = true
character_hint.TextXAlignment = Enum.TextXAlignment.Center
character_hint.ZIndex = 15

task.spawn(function()
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.AvatarBust,
            Enum.ThumbnailSize.Size420x420
        )
    end)

    if ok then
        avatar.Image = image
    end
end)

local tab_strip = Instance.new("Frame")
tab_strip.Name = "CategoryTabs"
tab_strip.Size = UDim2.new(1, 0, 0, 38)
tab_strip.BackgroundTransparency = 1
tab_strip.ZIndex = 12
tab_strip.Parent = panel
 tab_strip.Position = UiArt.position("Inventory", 68, 185)
 tab_strip.Size = UiArt.rect("Inventory", 0, 0, 985, 62)

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
layout.CellSize = UDim2.fromOffset(50, 62)
layout.CellPadding = UDim2.fromOffset(4, 5)
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
    frame.Size = UDim2.fromOffset(50, 62)
    frame.BackgroundColor3 = UiTheme.PALETTE.SurfaceRaised
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel = 0
    frame.ZIndex = 13
    UiTheme.add_corner(frame, 1)
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
        40
    )
    icon.Position = UDim2.fromOffset(5, 4)

    local name = UiComponents.label(
        frame,
        "Name",
        tostring(row.Name),
        "Heading"
    )
    name.Visible = true
    name.Position = UDim2.fromOffset(2, 43)
    name.Size = UDim2.new(1, -4, 0, 18)
    name.TextSize = 9
    name.TextTruncate = Enum.TextTruncate.AtEnd
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
    detail.Visible = false
    detail.ZIndex = 14

    local quantity = UiComponents.label(
        frame,
        "Quantity",
        "×" .. tostring(row.Quantity),
        "Heading"
    )
    quantity.AnchorPoint = Vector2.new(1, 0.5)
    quantity.Position = UDim2.new(1, -2, 0, 8)
    quantity.Size = UDim2.fromOffset(22, 14)
    quantity.TextSize = 9
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
            UiArt.paint_tab(button, selected)
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
    button.Size = UDim2.fromOffset(114, 32)
    button.ZIndex = 13
    UiArt.paint_tab(button, category == selected_tab)
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

UiArt.align_close(panel, modal.Close, "Inventory")

modal.Close.Activated:Connect(function()
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
        set_visible(true)
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
