--!strict
-- Read-only character statistics window for the shared MMORPG HUD.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local ProgressionClientState = require(
    script.Parent:WaitForChild("ProgressionClientState")
)
local UiComponents = require(
    shared:WaitForChild("UiComponents")
)
local UiOrnament = require(
    shared:WaitForChild("UiOrnament")
)
local UiTheme = require(
    shared:WaitForChild("UiTheme")
)
local UiArt = require(
    shared:WaitForChild("UiArt")
)
local WindowController = require(
    script.Parent:WaitForChild("HudWindowController")
)

local progression_snapshot = remotes:WaitForChild(
    "ProgressionSnapshot"
) :: RemoteEvent

local ATTRIBUTE_ROWS = table.freeze({
    {"Strength", "STR", "S"},
    {"Dexterity", "DEX", "D"},
    {"Vitality", "VIT", "V"},
    {"Intellect", "INT", "I"},
    {"Spirit", "SPI", "P"},
})

local player_gui = player:WaitForChild("PlayerGui")
local old = player_gui:FindFirstChild("CharacterStatsMenu")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "CharacterStatsMenu"
gui.ResetOnSpawn = false
gui.DisplayOrder = 172
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
    "StatsPanel",
    "Character",
    "Attributes, progression and current character identity.",
    UDim2.fromOffset(680, 850)
)
local panel = modal.Root
panel.Visible = false
panel.ZIndex = 11
UiArt.clear_frame_chrome(panel)

local old_reference_art = panel:FindFirstChild("ReferenceArt")
if old_reference_art then
    old_reference_art:Destroy()
end

local stats_art = UiArt.background(
    panel,
    "Stats",
    11
)
stats_art.Name = "StatsArt"

UiArt.content_mask(
    panel,
    "Stats",
    "CharacterContentMask",
    60,
    190,
    530,
    1120,
    12
)
UiArt.content_mask(
    panel,
    "Stats",
    "StatContentMask",
    610,
    190,
    442,
    1120,
    12
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
    "Stats",
    60,
    190
)
modal.Body.Size = UiArt.rect(
    "Stats",
    60,
    190,
    992,
    1120
)
modal.Body.ZIndex = 14

UiTheme.bind_responsive_scale(
    panel,
    1366,
    0.62,
    1
)

local identity_card = Instance.new("Frame")
identity_card.Name = "IdentityCard"
identity_card.Size = UDim2.new(0.52, -8, 1, -52)
identity_card.ZIndex = 12
UiTheme.style_inset(identity_card, true)
identity_card.Parent = modal.Body

local portrait_frame = Instance.new("Frame")
portrait_frame.Name = "PortraitFrame"
portrait_frame.AnchorPoint = Vector2.new(0.5, 0)
portrait_frame.Position = UDim2.new(0.5, 0, 0, 18)
portrait_frame.Size = UDim2.fromOffset(224, 260)
portrait_frame.BackgroundColor3 = UiTheme.PALETTE.SurfaceWarm
portrait_frame.BorderSizePixel = 0
portrait_frame.ZIndex = 13
UiTheme.add_stroke(
    portrait_frame,
    UiTheme.PALETTE.AccentBright,
    0.08
)
portrait_frame.Parent = identity_card

local portrait = Instance.new("ImageLabel")
portrait.Name = "Portrait"
portrait.Size = UDim2.fromScale(1, 1)
portrait.BackgroundTransparency = 1
portrait.ScaleType = Enum.ScaleType.Fit
portrait.ZIndex = 14
portrait.Parent = portrait_frame

task.spawn(function()
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.AvatarBust,
            Enum.ThumbnailSize.Size420x420
        )
    end)

    if ok then
        portrait.Image = image
    end
end)

local name_label = UiComponents.label(
    identity_card,
    "PlayerName",
    player.DisplayName,
    "Title"
)
name_label.Position = UDim2.fromOffset(16, 290)
name_label.Size = UDim2.new(1, -32, 0, 30)
name_label.TextXAlignment = Enum.TextXAlignment.Center
name_label.TextSize = 22
name_label.ZIndex = 13

local identity_label = UiComponents.label(
    identity_card,
    "Identity",
    "Adventurer",
    "Muted"
)
identity_label.Position = UDim2.fromOffset(16, 326)
identity_label.Size = UDim2.new(1, -32, 0, 44)
identity_label.TextWrapped = true
identity_label.TextXAlignment = Enum.TextXAlignment.Center
identity_label.ZIndex = 13

UiOrnament.divider(
    identity_card,
    UDim2.fromOffset(18, 380),
    UDim2.new(1, -36, 0, 6),
    13
)

local progression_label = UiComponents.label(
    identity_card,
    "Progression",
    "Level 1",
    "Body"
)
progression_label.Position = UDim2.fromOffset(16, 396)
progression_label.Size = UDim2.new(1, -32, 0, 72)
progression_label.TextWrapped = true
progression_label.TextXAlignment = Enum.TextXAlignment.Center
progression_label.TextYAlignment = Enum.TextYAlignment.Top
progression_label.ZIndex = 13

local attributes_panel = Instance.new("Frame")
attributes_panel.Name = "AttributesPanel"
attributes_panel.Position = UDim2.new(0.52, 8, 0, 0)
attributes_panel.Size = UDim2.new(0.48, -8, 1, -52)
attributes_panel.ZIndex = 12
UiTheme.style_inset(attributes_panel, false)
attributes_panel.Parent = modal.Body

local attributes_heading = UiComponents.section_heading(
    attributes_panel,
    "PRIMARY ATTRIBUTES"
)
attributes_heading.Position = UDim2.fromOffset(16, 13)
attributes_heading.Size = UDim2.new(1, -32, 0, 20)
attributes_heading.ZIndex = 13

local attribute_values: {[string]: TextLabel} = {}

--[[
Creates one primary-attribute row.

Args:
    name (string): Snapshot field name.
    abbreviation (string): Three-letter stat abbreviation.
    glyph (string): Short icon glyph.
    order (number): Vertical row order.

Returns:
    None.
]]
local function create_attribute_row(
    name: string,
    abbreviation: string,
    glyph: string,
    order: number
)
    local row = Instance.new("Frame")
    row.Name = name .. "Row"
    row.Position = UDim2.fromOffset(
        16,
        43 + (order - 1) * 62
    )
    row.Size = UDim2.new(1, -32, 0, 54)
    row.ZIndex = 13
    UiTheme.style_inset(row, false)
    row.Parent = attributes_panel

    local icon = UiOrnament.icon(
        row,
        "Icon",
        glyph,
        Color3.fromRGB(82, 60, 31),
        38
    )
    icon.Position = UDim2.fromOffset(8, 8)
    icon.ZIndex = 14

    local label = UiComponents.label(
        row,
        "Label",
        name,
        "Body"
    )
    label.Position = UDim2.fromOffset(56, 7)
    label.Size = UDim2.new(1, -116, 0, 20)
    label.ZIndex = 14

    local abbreviation_label = UiComponents.label(
        row,
        "Abbreviation",
        abbreviation,
        "Caption"
    )
    abbreviation_label.Position = UDim2.fromOffset(56, 28)
    abbreviation_label.Size = UDim2.new(1, -116, 0, 16)
    abbreviation_label.TextColor3 = UiTheme.PALETTE.TextMuted
    abbreviation_label.ZIndex = 14

    local value = UiComponents.label(
        row,
        "Value",
        "0",
        "Title"
    )
    value.AnchorPoint = Vector2.new(1, 0.5)
    value.Position = UDim2.new(1, -12, 0.5, 0)
    value.Size = UDim2.fromOffset(48, 32)
    value.TextXAlignment = Enum.TextXAlignment.Right
    value.TextColor3 = UiTheme.PALETTE.AccentBright
    value.TextSize = 22
    value.ZIndex = 14
    attribute_values[name] = value
end

for index, row in ipairs(ATTRIBUTE_ROWS) do
    create_attribute_row(
        row[1],
        row[2],
        row[3],
        index
    )
end

local footer = UiComponents.label(
    modal.Body,
    "Footer",
    "Character statistics are read-only here. "
        .. "Spend Attribute Points at a class trainer.",
    "Muted"
)
footer.AnchorPoint = Vector2.new(0, 1)
footer.Position = UDim2.new(0, 0, 1, 0)
footer.Size = UDim2.new(1, 0, 0, 38)
footer.TextWrapped = true
footer.ZIndex = 12

--[[
Returns the player-facing class name from an identity snapshot.

Args:
    identity (any): Authoritative identity table.

Returns:
    string: Current class identifier or fallback class name.
]]
local function class_name(identity: any): string
    if type(identity) ~= "table" then
        return "Adventurer"
    end

    if type(identity.ClassId) == "string"
        and identity.ClassId ~= ""
    then
        return identity.ClassId
    end

    if type(identity.BaseClassId) == "string"
        and identity.BaseClassId ~= ""
    then
        return identity.BaseClassId
    end

    return "Adventurer"
end

--[[
Renders the latest authoritative progression snapshot.

Args:
    snapshot (any): Current progression snapshot.

Returns:
    None.
]]
local function render(snapshot: any)
    snapshot = if type(snapshot) == "table"
        then snapshot
        else {}

    local identity = if type(snapshot.Identity) == "table"
        then snapshot.Identity
        else {}
    local attributes = if type(snapshot.Attributes) == "table"
        then snapshot.Attributes
        else {}

    local race = if type(identity.RaceId) == "string"
        then identity.RaceId
        else "Unknown race"
    identity_label.Text = race .. "  •  " .. class_name(identity)

    progression_label.Text = string.format(
        "Level %d\n%d Gold\n%d AP  •  %d SP",
        math.max(1, math.floor(tonumber(snapshot.Level) or 1)),
        math.max(0, math.floor(tonumber(snapshot.Gold) or 0)),
        math.max(0, math.floor(tonumber(snapshot.APAvailable) or 0)),
        math.max(0, math.floor(tonumber(snapshot.SPAvailable) or 0))
    )

    for _, row in ipairs(ATTRIBUTE_ROWS) do
        local name = row[1]
        local value = tonumber(attributes[name]) or 0
        attribute_values[name].Text = tostring(math.floor(value))
    end
end

--[[
Shows or hides the Stats window.

Args:
    visible (boolean): Desired managed-window visibility.

Returns:
    None.
]]
local function apply_visibility(visible: boolean)
    panel.Visible = visible
    backdrop.Visible = visible

    if visible then
        progression_snapshot:FireServer("Request")
    end
end

WindowController.register("Stats", apply_visibility)

modal.Close.Activated:Connect(function()
    WindowController.set_visible("Stats", false)
end)

backdrop.Activated:Connect(function()
    WindowController.set_visible("Stats", false)
end)

UserInputService.InputBegan:Connect(function(
    input: InputObject,
    processed: boolean
)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.C then
        WindowController.toggle("Stats")
    end
end)

ProgressionClientState.subscribe(render)
render(ProgressionClientState.get_snapshot())

task.defer(function()
    progression_snapshot:FireServer("Request")
end)
