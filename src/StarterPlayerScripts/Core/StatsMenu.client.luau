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
local attribute_commit = remotes:WaitForChild(
    "AttributeCommitRequest"
) :: RemoteEvent
local progression_result = remotes:WaitForChild(
    "ProgressionActionResult"
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
UiArt.reference_background(
    panel,
    "Stats",
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
local attribute_buttons: {[string]: TextButton} = {}
local latest_snapshot: any = {}
local preview_attributes: {[string]: number} = {}

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
    label.Size = UDim2.new(1, -154, 0, 20)
    label.ZIndex = 14

    local abbreviation_label = UiComponents.label(
        row,
        "Abbreviation",
        abbreviation,
        "Caption"
    )
    abbreviation_label.Position = UDim2.fromOffset(56, 28)
    abbreviation_label.Size = UDim2.new(1, -154, 0, 16)
    abbreviation_label.TextColor3 = UiTheme.PALETTE.TextMuted
    abbreviation_label.ZIndex = 14

    local value = UiComponents.label(
        row,
        "Value",
        "0",
        "Title"
    )
    value.AnchorPoint = Vector2.new(1, 0.5)
    value.Position = UDim2.new(1, -52, 0.5, 0)
    value.Size = UDim2.fromOffset(48, 32)
    value.TextXAlignment = Enum.TextXAlignment.Right
    value.TextColor3 = UiTheme.PALETTE.AccentBright
    value.TextSize = 22
    value.ZIndex = 14
    attribute_values[name] = value

    local plus = UiComponents.button(
        row,
        "AddPoint",
        "+",
        "Primary"
    )
    plus.AnchorPoint = Vector2.new(1, 0.5)
    plus.Position = UDim2.new(1, -8, 0.5, 0)
    plus.Size = UDim2.fromOffset(32, 32)
    plus.TextSize = 20
    plus.ZIndex = 15
    attribute_buttons[name] = plus
end

for index, row in ipairs(ATTRIBUTE_ROWS) do
    create_attribute_row(
        row[1],
        row[2],
        row[3],
        index
    )
end

local points_label = UiComponents.label(
    attributes_panel,
    "AvailablePoints",
    "Available Attribute Points: 0",
    "Heading"
)
points_label.Position = UDim2.fromOffset(16, 365)
points_label.Size = UDim2.new(1, -32, 0, 24)
points_label.TextColor3 = UiTheme.PALETTE.AccentBright
points_label.ZIndex = 13

local apply_button = UiComponents.button(
    attributes_panel,
    "ApplyAttributes",
    "Apply Attribute Points",
    "Primary"
)
apply_button.Position = UDim2.fromOffset(16, 398)
apply_button.Size = UDim2.new(0.62, -20, 0, 40)
apply_button.ZIndex = 13
UiArt.paint_button(apply_button, "Primary")

local reset_button = UiComponents.button(
    attributes_panel,
    "ResetPreview",
    "Reset",
    "Ghost"
)
reset_button.AnchorPoint = Vector2.new(1, 0)
reset_button.Position = UDim2.new(1, -16, 0, 398)
reset_button.Size = UDim2.new(0.38, -4, 0, 40)
reset_button.ZIndex = 13
UiArt.paint_button(reset_button, "Secondary")

local attribute_status = UiComponents.label(
    attributes_panel,
    "AttributeStatus",
    "Spend points here. Skills are trained separately at class trainers.",
    "Muted"
)
attribute_status.Position = UDim2.fromOffset(16, 448)
attribute_status.Size = UDim2.new(1, -32, 0, 62)
attribute_status.TextWrapped = true
attribute_status.TextYAlignment = Enum.TextYAlignment.Top
attribute_status.ZIndex = 13

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
Copies authoritative attribute values into the editable preview.

Args:
    snapshot (any): Latest progression snapshot.

Returns:
    None.
]]
local function reset_attribute_preview(snapshot: any)
    preview_attributes = {}

    local attributes = if type(snapshot) == "table"
        and type(snapshot.Attributes) == "table"
        then snapshot.Attributes
        else {}

    for _, row in ipairs(ATTRIBUTE_ROWS) do
        local name = row[1]
        preview_attributes[name] = math.floor(
            tonumber(attributes[name]) or 0
        )
    end
end

--[[
Returns how many currently available points are staged in the preview.

Args:
    None.

Returns:
    number: Number of uncommitted points added to attributes.
]]
local function preview_spend(): number
    local current = if type(latest_snapshot.Attributes) == "table"
        then latest_snapshot.Attributes
        else {}
    local spent = 0

    for _, row in ipairs(ATTRIBUTE_ROWS) do
        local name = row[1]
        local current_value = math.floor(
            tonumber(current[name]) or 0
        )
        local preview_value = math.floor(
            tonumber(preview_attributes[name]) or current_value
        )
        spent += math.max(0, preview_value - current_value)
    end

    return spent
end

--[[
Refreshes attribute values and spending controls from the local preview.

Args:
    None.

Returns:
    None.
]]
local function render_attribute_preview()
    local available = math.max(
        0,
        math.floor(
            tonumber(latest_snapshot.APAvailable) or 0
        )
    )
    local staged = preview_spend()
    local remaining = math.max(0, available - staged)

    for _, row in ipairs(ATTRIBUTE_ROWS) do
        local name = row[1]
        attribute_values[name].Text = tostring(
            math.floor(
                tonumber(preview_attributes[name]) or 0
            )
        )
        UiTheme.set_button_enabled(
            attribute_buttons[name],
            remaining > 0
        )
    end

    points_label.Text = string.format(
        "Available Attribute Points: %d%s",
        remaining,
        if staged > 0
            then "  •  " .. tostring(staged) .. " staged"
            else ""
    )
    UiTheme.set_button_enabled(apply_button, staged > 0)
    UiTheme.set_button_enabled(reset_button, staged > 0)
end

--[[
Renders the latest authoritative progression snapshot.

Args:
    snapshot (any): Current progression snapshot.

Returns:
    None.
]]
local function render(snapshot: any)
    latest_snapshot = if type(snapshot) == "table"
        then snapshot
        else {}

    local identity = if type(latest_snapshot.Identity) == "table"
        then latest_snapshot.Identity
        else {}

    local race = if type(identity.RaceId) == "string"
        then identity.RaceId
        else "Unknown race"
    identity_label.Text = race .. "  •  " .. class_name(identity)

    progression_label.Text = string.format(
        "Level %d\n%d Gold\n%d AP  •  %d SP",
        math.max(
            1,
            math.floor(tonumber(latest_snapshot.Level) or 1)
        ),
        math.max(
            0,
            math.floor(tonumber(latest_snapshot.Gold) or 0)
        ),
        math.max(
            0,
            math.floor(tonumber(latest_snapshot.APAvailable) or 0)
        ),
        math.max(
            0,
            math.floor(tonumber(latest_snapshot.SPAvailable) or 0)
        )
    )

    reset_attribute_preview(latest_snapshot)
    render_attribute_preview()
end

for _, row in ipairs(ATTRIBUTE_ROWS) do
    local name = row[1]

    attribute_buttons[name].Activated:Connect(function()
        local available = math.max(
            0,
            math.floor(
                tonumber(latest_snapshot.APAvailable) or 0
            )
        )

        if preview_spend() >= available then
            attribute_status.Text =
                "No unspent Attribute Points remain."
            return
        end

        preview_attributes[name] =
            (preview_attributes[name] or 0) + 1
        attribute_status.Text =
            "Point staged. Press Apply Attribute Points to save."
        render_attribute_preview()
    end)
end

apply_button.Activated:Connect(function()
    if preview_spend() <= 0 then
        return
    end

    attribute_status.Text = "Saving attributes..."
    attribute_commit:FireServer(preview_attributes)
end)

reset_button.Activated:Connect(function()
    reset_attribute_preview(latest_snapshot)
    attribute_status.Text = "Staged Attribute Points reset."
    render_attribute_preview()
end)

progression_result.OnClientEvent:Connect(function(payload: any)
    if type(payload) ~= "table"
        or payload.action ~= "AttributeCommit" then
        return
    end

    attribute_status.Text = if payload.ok == true
        then "Attribute Points applied."
        else "Attribute spending blocked: "
            .. tostring(payload.reason or "Unknown")
end)

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

UiArt.align_close(panel, modal.Close, "Stats")

modal.Close.Activated:Connect(function()
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
