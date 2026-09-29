--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

if UserInputService.TouchEnabled
    and not UserInputService.KeyboardEnabled then
    return
end

local player = Players.LocalPlayer
local combat = ReplicatedStorage:WaitForChild("Combat")
local combat_shared = combat:WaitForChild("Shared")
local core_shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local CombatConfig = require(
    combat_shared:WaitForChild("CombatConfig")
)
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
local UiComponents = require(
    core_shared:WaitForChild("UiComponents")
)
local UiTheme = require(
    core_shared:WaitForChild("UiTheme")
)
local UiArt = require(
    core_shared:WaitForChild("UiArt")
)

local State = CombatTypes.State
local cooldown_ends: {[number]: number} = {}
local slot_frames: {[number]: Frame} = {}
local slot_names: {[number]: TextLabel} = {}
local slot_cooldowns: {[number]: TextLabel} = {}
local slot_overlays: {[number]: Frame} = {}
local slot_sigils: {[number]: TextLabel} = {}

local SLOT_TINTS = table.freeze({
    Color3.fromRGB(29, 82, 148),
    Color3.fromRGB(103, 47, 151),
    Color3.fromRGB(173, 104, 30),
    Color3.fromRGB(34, 105, 137),
    Color3.fromRGB(152, 105, 35),
    Color3.fromRGB(136, 43, 54),
})

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
root.Size = UDim2.fromOffset(768, 134)
root.BackgroundTransparency = 1
root.BorderSizePixel = 0
root.Parent = gui
UiTheme.bind_responsive_scale(root, 1366, 0.68, 1)

local action_bar_art = UiArt.popup_background(
    root,
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

--[[
Creates one reference-art-backed hotbar slot.

Args:
    slot (number): One-based active skill slot.

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
        SLOT_TINTS[slot] or Color3.fromRGB(41, 69, 105)
    icon_well.BorderSizePixel = 0
    icon_well.ZIndex = 3
    icon_well.Parent = frame

    local icon_gradient = Instance.new("UIGradient")
    icon_gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(
            0,
            icon_well.BackgroundColor3:Lerp(
                Color3.new(1, 1, 1),
                0.24
            )
        ),
        ColorSequenceKeypoint.new(
            1,
            icon_well.BackgroundColor3:Lerp(
                Color3.new(0, 0, 0),
                0.58
            )
        ),
    })
    icon_gradient.Rotation = 120
    icon_gradient.Parent = icon_well

    local sigil = UiComponents.label(
        icon_well,
        "Sigil",
        "·",
        "Title"
    )
    sigil.Size = UDim2.fromScale(1, 1)
    sigil.TextXAlignment = Enum.TextXAlignment.Center
    sigil.TextColor3 = UiTheme.PALETTE.AccentBright
    sigil.TextStrokeColor3 = UiTheme.PALETTE.Backdrop
    sigil.TextStrokeTransparency = 0.10
    sigil.TextSize = 30
    sigil.ZIndex = 4
    slot_sigils[slot] = sigil

    local name_back = Instance.new("Frame")
    name_back.Name = "NameBack"
    name_back.AnchorPoint = Vector2.new(0, 1)
    name_back.Position = UDim2.new(0, 7, 1, -8)
    name_back.Size = UDim2.new(1, -14, 0, 16)
    name_back.BackgroundColor3 = UiTheme.PALETTE.Backdrop
    name_back.BackgroundTransparency = 0.18
    name_back.BorderSizePixel = 0
    name_back.ZIndex = 5
    name_back.Parent = frame

    local name = UiComponents.label(
        name_back,
        "SkillName",
        "Empty",
        "Caption"
    )
    name.Size = UDim2.fromScale(1, 1)
    name.TextXAlignment = Enum.TextXAlignment.Center
    name.TextWrapped = false
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.TextSize = 8
    name.TextColor3 = UiTheme.PALETTE.TextMuted
    name.ZIndex = 6

    local key = UiComponents.key_hint(
        frame,
        tostring(slot)
    )
    key.Position = UDim2.fromOffset(1, 1)
    key.Size = UDim2.fromOffset(18, 17)
    key.TextSize = 8
    key.ZIndex = 8

    local overlay = Instance.new("Frame")
    overlay.Name = "CooldownOverlay"
    overlay.AnchorPoint = Vector2.new(0, 1)
    overlay.Position = UDim2.new(0, 8, 1, -8)
    overlay.Size = UDim2.new(1, -16, 0, 0)
    overlay.BackgroundColor3 = UiTheme.PALETTE.Backdrop
    overlay.BackgroundTransparency = 0.12
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 7
    overlay.Parent = frame

    local cooldown = UiComponents.label(
        frame,
        "Cooldown",
        "",
        "Heading"
    )
    cooldown.Size = UDim2.fromScale(1, 1)
    cooldown.TextXAlignment = Enum.TextXAlignment.Center
    cooldown.TextColor3 = UiTheme.PALETTE.Text
    cooldown.TextStrokeTransparency = 0.12
    cooldown.TextSize = 18
    cooldown.ZIndex = 9

    slot_frames[slot] = frame
    slot_names[slot] = name
    slot_overlays[slot] = overlay
    slot_cooldowns[slot] = cooldown
end

for slot = 1, HotbarConfig.ACTIVE_SLOT_COUNT do
    create_slot(slot)
end

local progression_text = UiComponents.label(
    root,
    "ProgressionText",
    "Lv. 1",
    "Caption"
)
progression_text.AnchorPoint = Vector2.new(0.5, 1)
progression_text.Position = UDim2.new(0.5, 0, 1, -1)
progression_text.Size = UDim2.fromOffset(470, 18)
progression_text.TextXAlignment = Enum.TextXAlignment.Center
progression_text.TextColor3 = UiTheme.PALETTE.Text
progression_text.TextStrokeColor3 = UiTheme.PALETTE.Backdrop
progression_text.TextStrokeTransparency = 0.18
progression_text.TextSize = 13
progression_text.ZIndex = 4

--[[
Starts local cooldown presentation for a server-confirmed skill.

Args:
    skill_id (string): Skill that entered its active sequence.

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
Refreshes slot names from the current progression loadout.

Args:
    None.

Returns:
    None.
]]
local function refresh_loadout()
    local snapshot = ProgressionClientState.get_snapshot()

    for slot = 1, HotbarConfig.ACTIVE_SLOT_COUNT do
        local skill_id = ProgressionClientState.get_skill_for_slot(
            slot
        )
        local definition = if skill_id
            then SkillDefinitions.get(skill_id)
            else nil
        local label = slot_names[slot]

        label.Text = if definition
            then definition.DISPLAY_NAME
            else "Empty"
        label.TextColor3 = if definition
            then UiTheme.PALETTE.Text
            else UiTheme.PALETTE.TextFaint
        slot_sigils[slot].Text = if definition
            then string.sub(definition.DISPLAY_NAME, 1, 1)
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
Refreshes cooldown overlays and combat-disabled states.

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

    for slot = 1, HotbarConfig.ACTIVE_SLOT_COUNT do
        local frame = slot_frames[slot]
        local overlay = slot_overlays[slot]
        local cooldown = slot_cooldowns[slot]
        local skill_id = ProgressionClientState.get_skill_for_slot(
            slot
        )
        local definition = if skill_id
            then SkillDefinitions.get(skill_id)
            else nil
        local remaining = math.max(
            0,
            (cooldown_ends[slot] or 0) - now
        )
        local total = if definition
            then math.max(
                0.01,
                definition.COOLDOWN_SECONDS
            )
            else 1
        local ratio = math.clamp(
            remaining / total,
            0,
            1
        )

        overlay.Size = UDim2.new(1, -16, ratio, 0)
        cooldown.Text = if remaining > 0
            then string.format("%.1f", remaining)
            else ""
        frame.BackgroundTransparency = if disabled
            then 0.45
            else 0.04
    end
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
