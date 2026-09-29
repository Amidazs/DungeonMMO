--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ACTIVE_SLOT_COUNT = 6
local SLOT_TINTS = table.freeze({
    Color3.fromRGB(29, 82, 148),
    Color3.fromRGB(103, 47, 151),
    Color3.fromRGB(173, 104, 30),
    Color3.fromRGB(34, 105, 137),
    Color3.fromRGB(152, 105, 35),
    Color3.fromRGB(136, 43, 54),
})

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")
local combat_shared = ReplicatedStorage
    :WaitForChild("Combat")
    :WaitForChild("Shared")

local ProgressionClientState = require(
    script.Parent.Parent
        :WaitForChild("Core")
        :WaitForChild("ProgressionClientState")
)
local ProgressionConfig = require(
    shared:WaitForChild("ProgressionConfig")
)
local SkillDefinitions = require(
    combat_shared:WaitForChild("SkillDefinitions")
)
local UiArt = require(shared:WaitForChild("UiArt"))
local UiComponents = require(
    shared:WaitForChild("UiComponents")
)
local UiTheme = require(shared:WaitForChild("UiTheme"))

local progression_snapshot = remotes:WaitForChild(
    "ProgressionSnapshot"
) :: RemoteEvent

local player_gui = player:WaitForChild("PlayerGui")
local existing = player_gui:FindFirstChild("LobbyActionBar")
if existing then
    existing:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "LobbyActionBar"
gui.ResetOnSpawn = false
gui.DisplayOrder = 124
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player_gui

local root = Instance.new("Frame")
root.Name = "ActionBar"
root.AnchorPoint = Vector2.new(0.5, 1)
root.Position = UDim2.new(0.5, 0, 1, -8)
root.Size = UDim2.fromOffset(768, 134)
root.BackgroundTransparency = 1
root.BorderSizePixel = 0
root.Parent = gui
UiTheme.bind_responsive_scale(root, 1366, 0.68, 1)

local action_bar_art = UiArt.background(
    root,
    "ActionBar",
    1
)
action_bar_art.Name = "ActionBarArt"

local slots = Instance.new("Frame")
slots.Name = "Slots"
slots.AnchorPoint = Vector2.new(0.5, 0)
slots.Position = UDim2.new(0.5, 0, 0, 16)
slots.Size = UDim2.fromOffset(414, 78)
slots.BackgroundTransparency = 1
slots.BorderSizePixel = 0
slots.ZIndex = 2
slots.Parent = root

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 6)
layout.Parent = slots

local slot_names: {[number]: TextLabel} = {}
local slot_sigils: {[number]: TextLabel} = {}

local progression_text = UiComponents.label(
    root,
    "ProgressionText",
    "Lv. 1",
    "Caption"
)
progression_text.AnchorPoint = Vector2.new(0.5, 1)
progression_text.Position = UDim2.new(0.5, 0, 1, -2)
progression_text.Size = UDim2.fromOffset(430, 15)
progression_text.TextXAlignment = Enum.TextXAlignment.Center
progression_text.TextColor3 = UiTheme.PALETTE.Text
progression_text.TextStrokeColor3 = UiTheme.PALETTE.Backdrop
progression_text.TextStrokeTransparency = 0.18
progression_text.TextSize = 9
progression_text.ZIndex = 4

--[[
Creates one display-only action slot for the Base lobby.

Args:
    slot (number): One-based loadout slot.

Returns:
    None.
]]
local function create_slot(slot: number)
    local frame = Instance.new("Frame")
    frame.Name = "Slot" .. tostring(slot)
    frame.Size = UDim2.fromOffset(64, 78)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ZIndex = 2
    frame.Parent = slots

    local slot_art = UiArt.image(
        frame,
        "SlotArt",
        "HotbarSlot",
        2
    )
    slot_art.Size = UDim2.fromOffset(62, 78)
    slot_art.Position = UDim2.fromOffset(1, 0)

    local icon_well = Instance.new("Frame")
    icon_well.Name = "IconWell"
    icon_well.Position = UDim2.fromOffset(8, 8)
    icon_well.Size = UDim2.fromOffset(48, 52)
    icon_well.BackgroundColor3 =
        SLOT_TINTS[slot]
        or Color3.fromRGB(41, 69, 105)
    icon_well.BorderSizePixel = 0
    icon_well.ZIndex = 3
    icon_well.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(
            0,
            icon_well.BackgroundColor3:Lerp(
                Color3.new(1, 1, 1),
                0.22
            )
        ),
        ColorSequenceKeypoint.new(
            1,
            icon_well.BackgroundColor3:Lerp(
                Color3.new(0, 0, 0),
                0.56
            )
        ),
    })
    gradient.Rotation = 90
    gradient.Parent = icon_well

    local sigil = UiComponents.label(
        icon_well,
        "Sigil",
        "·",
        "Title"
    )
    sigil.Size = UDim2.fromScale(1, 1)
    sigil.TextXAlignment = Enum.TextXAlignment.Center
    sigil.TextColor3 = UiTheme.PALETTE.Text
    sigil.TextStrokeColor3 = UiTheme.PALETTE.Backdrop
    sigil.TextStrokeTransparency = 0.1
    sigil.TextSize = 25
    sigil.ZIndex = 4
    slot_sigils[slot] = sigil

    local name = UiComponents.label(
        frame,
        "SkillName",
        "Empty",
        "Caption"
    )
    name.AnchorPoint = Vector2.new(0.5, 1)
    name.Position = UDim2.new(0.5, 0, 1, -4)
    name.Size = UDim2.new(1, -8, 0, 14)
    name.TextXAlignment = Enum.TextXAlignment.Center
    name.TextColor3 = UiTheme.PALETTE.TextMuted
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.TextSize = 8
    name.ZIndex = 5
    slot_names[slot] = name

    local key = UiComponents.key_hint(
        frame,
        tostring(slot)
    )
    key.Position = UDim2.fromOffset(-3, -3)
    key.Size = UDim2.fromOffset(19, 18)
    key.TextSize = 9
    key.ZIndex = 6
end

--[[
Refreshes the displayed action slots from progression state.

Args:
    snapshot (any): Current authoritative progression snapshot.

Returns:
    None.
]]
local function render(snapshot: any)
    local loadout = if type(snapshot) == "table"
        and type(snapshot.Loadout) == "table"
        then snapshot.Loadout
        else {}

    for slot = 1, ACTIVE_SLOT_COUNT do
        local skill_id = loadout[slot]
        local definition = if type(skill_id) == "string"
            then SkillDefinitions.get(skill_id)
            else nil
        local display_name = if definition
            then tostring(definition.DISPLAY_NAME)
            else "Empty"

        slot_names[slot].Text = display_name
        slot_names[slot].TextColor3 = if definition
            then UiTheme.PALETTE.Text
            else UiTheme.PALETTE.TextMuted
        slot_sigils[slot].Text = if definition
            then string.sub(display_name, 1, 1)
            else "·"
    end

    local level = tonumber(snapshot.Level) or 1
    local xp = tonumber(snapshot.XP) or 0
    local required = ProgressionConfig.get_required_xp(level)

    progression_text.Text = if required
        then string.format(
            "Lv. %d   %d / %d XP",
            level,
            xp,
            required
        )
        else string.format("Lv. %d   MAX LEVEL", level)
end

--[[
Builds the Base-only display bar and requests fresh progression data.

Args:
    None.

Returns:
    None.
]]
local function main()
    for slot = 1, ACTIVE_SLOT_COUNT do
        create_slot(slot)
    end

    ProgressionClientState.subscribe(render)
    render(ProgressionClientState.get_snapshot())

    task.defer(function()
        progression_snapshot:FireServer("Request")
    end)
end

main()
