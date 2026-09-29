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
local ClientCombatController = require(
    script.Parent:WaitForChild("ClientCombatController")
)
local UiComponents = require(
    core_shared:WaitForChild("UiComponents")
)
local UiTheme = require(
    core_shared:WaitForChild("UiTheme")
)
local UiOrnament = require(
    core_shared:WaitForChild("UiOrnament")
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
root.Position = UDim2.new(0.5, 0, 1, -16)
root.Size = UDim2.fromOffset(510, 100)
root.BackgroundTransparency = 1
root.Parent = gui
UiTheme.bind_responsive_scale(root, 1366, 0.76, 1)

local tray = Instance.new("Frame")
tray.Name = "ActionBarFrame"
tray.Position = UDim2.fromOffset(0, 3)
tray.Size = UDim2.new(1, 0, 0, 80)
UiTheme.style_panel(tray, true)
tray.Parent = root
UiOrnament.frame(tray, true)
UiOrnament.action_bar_wings(tray)

local slots = Instance.new("Frame")
slots.Name = "Slots"
slots.Position = UDim2.fromOffset(10, 5)
slots.Size = UDim2.new(1, -20, 0, 74)
slots.BackgroundTransparency = 1
slots.Parent = root

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 7)
layout.Parent = slots

--[[
Creates one visible hotbar slot.

Args:
    slot (number): One-based active skill slot.

Returns:
    None.
]]
local function create_slot(slot: number)
    local frame = Instance.new("Frame")
    frame.Name = "Slot" .. tostring(slot)
    frame.Size = UDim2.fromOffset(72, 70)
    frame.BackgroundColor3 = UiTheme.PALETTE.BackdropSoft
    frame.BackgroundTransparency = 0.02
    frame.BorderSizePixel = 0
    UiTheme.add_corner(frame, 2)
    local frame_stroke = UiTheme.add_stroke(
        frame,
        UiTheme.PALETTE.Border,
        0.08
    )
    frame_stroke.Thickness = 1
    frame.Parent = slots

    local icon = UiOrnament.icon(
        frame,
        "AbilityIcon",
        "✦",
        SLOT_TINTS[slot] or Color3.fromRGB(41, 69, 105),
        56
    )
    icon.Position = UDim2.fromOffset(8, 4)
    slot_sigils[slot] = icon:WaitForChild("IconWell")
        :WaitForChild("Sigil") :: TextLabel

    local key = UiComponents.key_hint(
        frame,
        tostring(slot)
    )
    key.Position = UDim2.fromOffset(3, 3)
    key.ZIndex = 3

    local name = UiComponents.label(
        frame,
        "SkillName",
        "Empty",
        "Body"
    )
    name.AnchorPoint = Vector2.new(0.5, 1)
    name.Position = UDim2.new(0.5, 0, 1, -2)
    name.Size = UDim2.new(1, -8, 0, 14)
    name.TextXAlignment = Enum.TextXAlignment.Center
    name.TextWrapped = false
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.TextSize = 9
    name.TextColor3 = UiTheme.PALETTE.TextMuted

    local overlay = Instance.new("Frame")
    overlay.Name = "CooldownOverlay"
    overlay.AnchorPoint = Vector2.new(0, 1)
    overlay.Position = UDim2.fromScale(0, 1)
    overlay.Size = UDim2.fromScale(1, 0)
    overlay.BackgroundColor3 = UiTheme.PALETTE.Backdrop
    overlay.BackgroundTransparency = 0.18
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 4
    UiTheme.add_corner(overlay, 2)
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
    cooldown.TextStrokeTransparency = 0.35
    cooldown.ZIndex = 5

    slot_frames[slot] = frame
    slot_names[slot] = name
    slot_overlays[slot] = overlay
    slot_cooldowns[slot] = cooldown
end

for slot = 1, HotbarConfig.ACTIVE_SLOT_COUNT do
    create_slot(slot)
end

local hints = UiComponents.label(
    root,
    "CombatHints",
    "LMB  ATTACK     RMB  BLOCK     SHIFT  DODGE"
        .. "     CTRL  VIEW LOCK",
    "Caption"
)
hints.AnchorPoint = Vector2.new(0.5, 1)
hints.Position = UDim2.new(0.5, 0, 1, 0)
hints.Size = UDim2.new(1, 0, 0, 14)
hints.TextXAlignment = Enum.TextXAlignment.Center
hints.TextColor3 = UiTheme.PALETTE.TextFaint
hints.TextSize = 10

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

        overlay.Size = UDim2.fromScale(1, ratio)
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
