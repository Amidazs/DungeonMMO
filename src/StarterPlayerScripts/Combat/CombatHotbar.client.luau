--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if UserInputService.TouchEnabled
    and not UserInputService.KeyboardEnabled then
    return
end

local DISPLAY_SLOT_COUNT = 8

local SLOT_TINTS = table.freeze({
    Color3.fromRGB(29, 82, 148),
    Color3.fromRGB(103, 47, 151),
    Color3.fromRGB(173, 104, 30),
    Color3.fromRGB(34, 105, 137),
    Color3.fromRGB(152, 105, 35),
    Color3.fromRGB(136, 43, 54),
    Color3.fromRGB(55, 65, 77),
    Color3.fromRGB(55, 65, 77),
})

local player = Players.LocalPlayer
local combat = ReplicatedStorage:WaitForChild("Combat")
local combat_shared = combat:WaitForChild("Shared")
local core_shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local CombatTypes = require(
    combat_shared:WaitForChild("CombatTypes")
)
local HotbarConfig = require(
    combat_shared:WaitForChild("HotbarConfig")
)
local SkillDefinitions = require(
    combat_shared:WaitForChild("SkillDefinitions")
)
local ProgressionClientState = require(
    script.Parent.Parent
        :WaitForChild("Core")
        :WaitForChild("ProgressionClientState")
)
local ProgressionConfig = require(
    core_shared:WaitForChild("ProgressionConfig")
)
local ClientCombatController = require(
    script.Parent:WaitForChild("ClientCombatController")
)
local UiArt = require(
    core_shared:WaitForChild("UiArt")
)
local UiComponents = require(
    core_shared:WaitForChild("UiComponents")
)
local UiTheme = require(
    core_shared:WaitForChild("UiTheme")
)

local State = CombatTypes.State

local cooldown_ends: {[number]: number} = {}
local slot_frames: {[number]: Frame} = {}
local slot_wells: {[number]: Frame} = {}
local slot_sigils: {[number]: TextLabel} = {}
local slot_overlays: {[number]: Frame} = {}
local slot_cooldowns: {[number]: TextLabel} = {}

local player_gui = player:WaitForChild("PlayerGui")
local old = player_gui:FindFirstChild("CombatHotbarGui")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "CombatHotbarGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 125
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player_gui

local root = Instance.new("Frame")
root.Name = "Hotbar"
root.AnchorPoint = Vector2.new(0.5, 1)
root.Position = UDim2.new(0.5, 0, 1, -8)
root.Size = UDim2.fromOffset(760, 114)
root.BackgroundTransparency = 1
root.BorderSizePixel = 0
root.Parent = gui
UiTheme.bind_responsive_scale(root, 1366, 0.64, 1)

UiArt.actionbar_background(root, 1)

local slots = Instance.new("Frame")
slots.Name = "Slots"
slots.Position = UDim2.fromOffset(85, 13)
slots.Size = UDim2.fromOffset(535, 62)
slots.BackgroundTransparency = 1
slots.BorderSizePixel = 0
slots.ZIndex = 2
slots.Parent = root

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = slots

local xp_track = Instance.new("Frame")
xp_track.Name = "ExperienceTrack"
xp_track.Position = UDim2.fromOffset(86, 80)
xp_track.Size = UDim2.fromOffset(598, 9)
xp_track.BackgroundColor3 = Color3.fromRGB(25, 9, 33)
xp_track.BackgroundTransparency = 0.05
xp_track.BorderSizePixel = 0
xp_track.ClipsDescendants = true
xp_track.ZIndex = 2
UiTheme.add_corner(xp_track, 4)
xp_track.Parent = root

local xp_fill = Instance.new("Frame")
xp_fill.Name = "ExperienceFill"
xp_fill.Size = UDim2.fromScale(0, 1)
xp_fill.BackgroundColor3 = Color3.fromRGB(196, 27, 224)
xp_fill.BorderSizePixel = 0
xp_fill.ZIndex = 3
UiTheme.add_corner(xp_fill, 4)
UiTheme.add_gradient(
    xp_fill,
    Color3.fromRGB(236, 47, 255),
    Color3.fromRGB(128, 19, 175)
)
xp_fill.Parent = xp_track

local progression_text = UiComponents.label(
    root,
    "ProgressionText",
    "Lv. 1",
    "Heading"
)
progression_text.Position = UDim2.fromOffset(246, 89)
progression_text.Size = UDim2.fromOffset(235, 22)
progression_text.TextXAlignment = Enum.TextXAlignment.Center
progression_text.TextColor3 = Color3.fromRGB(248, 237, 211)
progression_text.TextStrokeColor3 = Color3.new(0, 0, 0)
progression_text.TextStrokeTransparency = 0.18
progression_text.TextSize = 15
progression_text.ZIndex = 4

--[[
Returns a compact keyboard label for one hotbar slot.

Args:
    slot (number): One-based hotbar slot.

Returns:
    string: Player-facing keyboard label.
]]
local function key_label(slot: number): string
    local key = HotbarConfig.get_default_key(slot)
    if not key then
        return tostring(slot)
    end

    local names = {
        One = "1",
        Two = "2",
        Three = "3",
        Four = "4",
        Five = "5",
        Six = "6",
        Seven = "7",
        Eight = "8",
    }

    return names[key.Name] or key.Name
end

--[[
Creates one reference-derived combat hotbar slot.

Args:
    slot (number): One-based display slot.

Returns:
    None.
]]
local function create_slot(slot: number)
    local frame = Instance.new("Frame")
    frame.Name = "Slot" .. tostring(slot)
    frame.LayoutOrder = slot
    frame.Size = UDim2.fromOffset(62, 62)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ZIndex = 2
    frame.Parent = slots

    UiArt.action_slot(frame, 2)

    local icon_well = Instance.new("Frame")
    icon_well.Name = "IconWell"
    icon_well.Position = UDim2.fromOffset(7, 8)
    icon_well.Size = UDim2.fromOffset(48, 46)
    icon_well.BackgroundColor3 = SLOT_TINTS[slot]
    icon_well.BackgroundTransparency = 0.62
    icon_well.BorderSizePixel = 0
    icon_well.ClipsDescendants = true
    icon_well.ZIndex = 3
    icon_well.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(
        SLOT_TINTS[slot]:Lerp(
            Color3.new(1, 1, 1),
            0.18
        ),
        SLOT_TINTS[slot]:Lerp(
            Color3.new(0, 0, 0),
            0.56
        )
    )
    gradient.Rotation = 115
    gradient.Parent = icon_well

    local sigil = UiComponents.label(
        icon_well,
        "Sigil",
        "·",
        "Title"
    )
    sigil.Size = UDim2.fromScale(1, 1)
    sigil.TextXAlignment = Enum.TextXAlignment.Center
    sigil.TextColor3 = Color3.fromRGB(247, 232, 196)
    sigil.TextStrokeColor3 = Color3.new(0, 0, 0)
    sigil.TextStrokeTransparency = 0.14
    sigil.TextSize = 24
    sigil.ZIndex = 4

    local overlay = Instance.new("Frame")
    overlay.Name = "CooldownOverlay"
    overlay.AnchorPoint = Vector2.new(0, 1)
    overlay.Position = UDim2.fromScale(0, 1)
    overlay.Size = UDim2.new(1, 0, 0, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(5, 5, 6)
    overlay.BackgroundTransparency = 0.14
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 5
    overlay.Parent = icon_well

    local cooldown = UiComponents.label(
        icon_well,
        "Cooldown",
        "",
        "Heading"
    )
    cooldown.Size = UDim2.fromScale(1, 1)
    cooldown.TextXAlignment = Enum.TextXAlignment.Center
    cooldown.TextColor3 = UiTheme.PALETTE.Text
    cooldown.TextStrokeTransparency = 0.08
    cooldown.TextSize = 16
    cooldown.ZIndex = 6

    local key = UiComponents.key_hint(
        frame,
        key_label(slot)
    )
    key.Position = UDim2.fromOffset(2, 1)
    key.Size = UDim2.fromOffset(18, 17)
    key.TextSize = 9
    key.ZIndex = 7

    slot_frames[slot] = frame
    slot_wells[slot] = icon_well
    slot_sigils[slot] = sigil
    slot_overlays[slot] = overlay
    slot_cooldowns[slot] = cooldown
end

--[[
Starts local cooldown presentation for a confirmed skill.

Args:
    skill_id (string): Skill entering its active sequence.

Returns:
    None.
]]
local function begin_cooldown(skill_id: string)
    for slot = 1, HotbarConfig.ACTIVE_SLOT_COUNT do
        if ProgressionClientState.get_skill_for_slot(slot)
            == skill_id then
            local definition = SkillDefinitions.get(skill_id)
            if definition then
                cooldown_ends[slot] = os.clock()
                    + definition.COOLDOWN_SECONDS
            end
            return
        end
    end
end

--[[
Refreshes hotbar skills and the XP plaque.

Args:
    None.

Returns:
    None.
]]
local function refresh_loadout()
    local snapshot = ProgressionClientState.get_snapshot()

    for slot = 1, DISPLAY_SLOT_COUNT do
        local skill_id = if slot <= HotbarConfig.ACTIVE_SLOT_COUNT
            then ProgressionClientState.get_skill_for_slot(slot)
            else nil
        local definition = if skill_id
            then SkillDefinitions.get(skill_id)
            else nil

        slot_sigils[slot].Text = if definition
            then string.sub(definition.DISPLAY_NAME, 1, 1)
            else "·"
        slot_sigils[slot].TextTransparency =
            if slot <= HotbarConfig.ACTIVE_SLOT_COUNT then 0 else 0.55
        slot_wells[slot].BackgroundTransparency =
            if definition then 0.08 else 0.62
    end

    local level = tonumber(snapshot.Level) or 1
    local xp = tonumber(snapshot.XP) or 0
    local required = ProgressionConfig.get_required_xp(level)

    if required and required > 0 then
        progression_text.Text = string.format(
            "Lv. %d   %,d / %,d",
            level,
            xp,
            required
        )
        UiTheme.set_bar_ratio(
            xp_fill,
            xp / required
        )
    else
        progression_text.Text = string.format(
            "Lv. %d   MAX LEVEL",
            level
        )
        UiTheme.set_bar_ratio(xp_fill, 1)
    end
end

--[[
Refreshes cooldown overlays and disabled presentation.

Args:
    None.

Returns:
    None.
]]
local function refresh_runtime()
    local now = os.clock()
    local state = ClientCombatController.get_state()
    local disabled = state == State.DEAD
        or state == State.GUARD_BREAK

    for slot = 1, DISPLAY_SLOT_COUNT do
        local active = slot <= HotbarConfig.ACTIVE_SLOT_COUNT
        local remaining = 0
        local total = 1

        if active then
            local skill_id = ProgressionClientState
                .get_skill_for_slot(slot)
            local definition = if skill_id
                then SkillDefinitions.get(skill_id)
                else nil

            remaining = math.max(
                0,
                (cooldown_ends[slot] or 0) - now
            )
            total = if definition
                then math.max(
                    0.01,
                    definition.COOLDOWN_SECONDS
                )
                else 1
        end

        local ratio = math.clamp(
            remaining / total,
            0,
            1
        )
        slot_overlays[slot].Size = UDim2.new(
            1,
            0,
            ratio,
            0
        )
        slot_cooldowns[slot].Text = if remaining > 0
            then string.format("%.1f", remaining)
            else ""

        local art = slot_frames[slot]:FindFirstChild("SlotArt")
        if art and art:IsA("ImageLabel") then
            art.ImageTransparency = if disabled and active
                then 0.35
                else 0
        end
    end
end

for slot = 1, DISPLAY_SLOT_COUNT do
    create_slot(slot)
end

ProgressionClientState.subscribe(function()
    refresh_loadout()
end)

ClientCombatController.on_server_state_changed(function(
    server_state: string,
    skill_or_attack_id: string,
    _server_timestamp: number
)
    if server_state == State.DEAD then
        table.clear(cooldown_ends)
        return
    end

    if SkillDefinitions.get(skill_or_attack_id)
        and (
            server_state == State.MENDING
            or server_state == State.WIND_UP
        ) then
        begin_cooldown(skill_or_attack_id)
    end
end)

RunService.RenderStepped:Connect(refresh_runtime)

refresh_loadout()
refresh_runtime()
