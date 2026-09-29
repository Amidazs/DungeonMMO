--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")
local combat_shared = ReplicatedStorage
    :WaitForChild("Combat")
    :WaitForChild("Shared")

local ProgressionClientState = require(
    script.Parent:WaitForChild("ProgressionClientState")
)
local SkillDefinitions = require(
    combat_shared:WaitForChild("SkillDefinitions")
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

local progression_snapshot = remotes:WaitForChild(
    "ProgressionSnapshot"
) :: RemoteEvent
local loadout_request = remotes:WaitForChild(
    "LoadoutRequest"
) :: RemoteEvent
local action_result = remotes:WaitForChild(
    "ProgressionActionResult"
) :: RemoteEvent

local WindowController = require(
    script.Parent:WaitForChild("HudWindowController")
)

local player_gui = player:WaitForChild("PlayerGui")
local old = player_gui:FindFirstChild("CharacterSkillsMenu")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "CharacterSkillsMenu"
gui.ResetOnSpawn = false
gui.DisplayOrder = 171
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
    "SkillsPanel",
    "Skills & Loadout",
    "Select a learned skill, then choose the hotbar slot.",
    UDim2.fromOffset(680, 850)
)
local panel = modal.Root
panel.Visible = false
panel.ZIndex = 11
UiArt.clear_frame_chrome(panel)
UiArt.reference_background(
    panel,
    "Skills",
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
    "Skills",
    52,
    260
)
modal.Body.Size = UiArt.rect(
    "Skills",
    52,
    260,
    1015,
    1045
)
modal.Body.ZIndex = 14

UiTheme.bind_responsive_scale(
    panel,
    1366,
    0.62,
    1
)

local reference_tabs = Instance.new("Frame")
reference_tabs.Name = "ReferenceTabs"
reference_tabs.Position = UiArt.position(
    "Skills",
    72,
    190
)
reference_tabs.Size = UiArt.rect(
    "Skills",
    72,
    190,
    710,
    58
)
reference_tabs.BackgroundTransparency = 1
reference_tabs.ZIndex = 15
reference_tabs.Parent = panel

local reference_tab_layout = Instance.new("UIListLayout")
reference_tab_layout.FillDirection = Enum.FillDirection.Horizontal
reference_tab_layout.Padding = UDim.new(0, 8)
reference_tab_layout.Parent = reference_tabs

local active_skills_tab = UiComponents.button(
    reference_tabs,
    "ActiveSkillsTab",
    "Active",
    "Ghost"
)
active_skills_tab.Size = UDim2.new(0.333, -6, 1, 0)
active_skills_tab.ZIndex = 16
UiArt.paint_tab(active_skills_tab, true)

local passive_skills_tab = UiComponents.button(
    reference_tabs,
    "PassiveSkillsTab",
    "Passive",
    "Ghost"
)
passive_skills_tab.Size = UDim2.new(0.333, -6, 1, 0)
passive_skills_tab.ZIndex = 16
passive_skills_tab.Active = false
UiArt.paint_tab(passive_skills_tab, false)

local class_skills_tab = UiComponents.button(
    reference_tabs,
    "ClassSkillsTab",
    "Class",
    "Ghost"
)
class_skills_tab.Size = UDim2.new(0.333, -6, 1, 0)
class_skills_tab.ZIndex = 16
class_skills_tab.Active = false
UiArt.paint_tab(class_skills_tab, false)

local skill_heading = UiComponents.section_heading(
    modal.Body,
    "LEARNED SKILLS"
)
skill_heading.Position = UDim2.fromOffset(0, 0)
skill_heading.Size = UDim2.new(0.50, -6, 0, 20)
skill_heading.ZIndex = 12

local loadout_heading = UiComponents.section_heading(
    modal.Body,
    "ACTIVE LOADOUT"
)
loadout_heading.Position = UDim2.new(0.50, 6, 0, 0)
loadout_heading.Size = UDim2.new(0.50, -6, 0, 20)
loadout_heading.ZIndex = 12

local skill_list = Instance.new("ScrollingFrame")
skill_list.Name = "SkillList"
skill_list.Position = UDim2.fromOffset(0, 28)
skill_list.Size = UDim2.new(0.50, -6, 1, -76)
skill_list.CanvasSize = UDim2.fromOffset(0, 0)
skill_list.ZIndex = 12
UiTheme.style_scroll(skill_list)
skill_list.Parent = modal.Body

local skill_padding = Instance.new("UIPadding")
skill_padding.PaddingTop = UDim.new(0, 8)
skill_padding.PaddingBottom = UDim.new(0, 8)
skill_padding.PaddingLeft = UDim.new(0, 8)
skill_padding.PaddingRight = UDim.new(0, 8)
skill_padding.Parent = skill_list

local skill_layout = Instance.new("UIGridLayout")
skill_layout.CellSize = UDim2.fromOffset(82, 108)
skill_layout.CellPadding = UDim2.fromOffset(5, 6)
skill_layout.SortOrder = Enum.SortOrder.LayoutOrder
skill_layout.Parent = skill_list

local loadout = Instance.new("Frame")
loadout.Name = "Loadout"
loadout.Position = UDim2.new(0.50, 6, 0, 28)
loadout.Size = UDim2.new(0.50, -6, 1, -76)
loadout.BorderSizePixel = 0
loadout.ZIndex = 12
UiTheme.style_inset(loadout, true)
loadout.Parent = modal.Body

local loadout_padding = Instance.new("UIPadding")
loadout_padding.PaddingTop = UDim.new(0, 10)
loadout_padding.PaddingBottom = UDim.new(0, 10)
loadout_padding.PaddingLeft = UDim.new(0, 10)
loadout_padding.PaddingRight = UDim.new(0, 10)
loadout_padding.Parent = loadout

local loadout_layout = Instance.new("UIListLayout")
loadout_layout.Padding = UDim.new(0, 8)
loadout_layout.SortOrder = Enum.SortOrder.LayoutOrder
loadout_layout.Parent = loadout

local status = UiComponents.label(
    modal.Body,
    "Status",
    "Choose a learned skill to edit your loadout.",
    "Muted"
)
status.AnchorPoint = Vector2.new(0, 1)
status.Position = UDim2.new(0, 0, 1, 0)
status.Size = UDim2.new(1, 0, 0, 36)
status.TextWrapped = true
status.ZIndex = 12

local selected_skill: string? = nil
local latest: any = {}
local skill_buttons: {[string]: TextButton} = {}
local skill_name_labels: {[string]: TextLabel} = {}
local skill_rank_labels: {[string]: TextLabel} = {}
local slot_buttons: {[number]: TextButton} = {}
local slot_sigils: {[number]: TextLabel} = {}

--[[
Returns all skill IDs sorted by display name.

Args:
    None.

Returns:
    {string}: Stable sorted skill IDs.
]]
local function sorted_skill_ids(): {string}
    local ids = {}
    for skill_id in pairs(SkillDefinitions.all()) do
        table.insert(ids, skill_id)
    end

    table.sort(ids, function(left: string, right: string)
        local left_def = SkillDefinitions.get(left)
        local right_def = SkillDefinitions.get(right)
        local left_name = if left_def
            then left_def.DISPLAY_NAME
            else left
        local right_name = if right_def
            then right_def.DISPLAY_NAME
            else right
        return left_name < right_name
    end)

    return ids
end

--[[
Returns whether a snapshot marks one skill as learned.

Args:
    snapshot (any): Progression snapshot.
    skill_id (string): Skill identifier.

Returns:
    boolean: True when the skill is learned at rank one or higher.
]]
local function is_known(
    snapshot: any,
    skill_id: string
): boolean
    local skills = if type(snapshot.Skills) == "table"
        then snapshot.Skills
        else {}
    local state = skills[skill_id]

    return type(state) == "table"
        and state.Known == true
        and (tonumber(state.Rank) or 0) >= 1
end

--[[
Returns the current rank for one skill.

Args:
    snapshot (any): Progression snapshot.
    skill_id (string): Skill identifier.

Returns:
    number: Current rank or zero when locked.
]]
local function skill_rank(
    snapshot: any,
    skill_id: string
): number
    local skills = if type(snapshot.Skills) == "table"
        then snapshot.Skills
        else {}
    local state = skills[skill_id]

    if type(state) ~= "table" then
        return 0
    end

    return tonumber(state.Rank) or 0
end

--[[
Creates one skill selection row.

Args:
    skill_id (string): Skill identifier.
    order (number): Stable layout order.

Returns:
    TextButton: Created row button.
]]
local function create_skill_button(
    skill_id: string,
    order: number
): TextButton
    local definition = SkillDefinitions.get(skill_id)
    local display_name = if definition
        then definition.DISPLAY_NAME
        else skill_id

    local button = UiComponents.button(
        skill_list,
        skill_id,
        "",
        "Secondary"
    )
    button.LayoutOrder = order
    button.Size = UDim2.fromOffset(82, 108)
    button.Text = ""
    button.ZIndex = 13
    UiArt.paint_button(button, "Secondary")
    button:SetAttribute(
        "SkillDisplayName",
        display_name
    )

    local icon = UiOrnament.icon(
        button,
        "SkillIcon",
        string.sub(display_name, 1, 1),
        Color3.fromRGB(42, 71, 113),
        58
    )
    icon.AnchorPoint = Vector2.new(0.5, 0)
    icon.Position = UDim2.new(0.5, 0, 0, 6)
    icon.ZIndex = 14

    local name_label = UiComponents.label(
        button,
        "SkillName",
        display_name,
        "Heading"
    )
    name_label.Position = UDim2.fromOffset(5, 72)
    name_label.Size = UDim2.new(1, -10, 0, 18)
    name_label.TextXAlignment = Enum.TextXAlignment.Center
    name_label.TextTruncate = Enum.TextTruncate.AtEnd
    name_label.TextSize = 11
    name_label.ZIndex = 14

    local rank_label = UiComponents.label(
        button,
        "Rank",
        "Locked",
        "Caption"
    )
    rank_label.Position = UDim2.fromOffset(5, 91)
    rank_label.Size = UDim2.new(1, -10, 0, 12)
    rank_label.TextXAlignment = Enum.TextXAlignment.Center
    rank_label.TextSize = 9
    rank_label.ZIndex = 14

    skill_name_labels[skill_id] = name_label
    skill_rank_labels[skill_id] = rank_label

    return button
end

--[[
Creates one loadout-slot button.

Args:
    slot (number): One-based active slot number.

Returns:
    TextButton: Created slot button.
]]
local function create_slot_button(slot: number): TextButton
    local button = UiComponents.button(
        loadout,
        "SkillSlot" .. tostring(slot),
        "Slot " .. tostring(slot),
        "Secondary"
    )
    button.LayoutOrder = slot
    button.Size = UDim2.new(1, 0, 0, 62)
    button.TextWrapped = true
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextColor3 = UiTheme.PALETTE.Text
    button.TextSize = 16
    button.TextStrokeTransparency = 0.68
    button.ZIndex = 13
    UiArt.paint_button(button, "Secondary")

    local icon = UiOrnament.icon(
        button,
        "LoadoutIcon",
        "·",
        Color3.fromRGB(55, 49, 42),
        40
    )
    icon.Position = UDim2.fromOffset(8, 11)
    icon.ZIndex = 14
    slot_sigils[slot] = icon
        :WaitForChild("IconWell")
        :WaitForChild("Sigil") :: TextLabel

    local key = UiComponents.key_hint(
        button,
        tostring(slot)
    )
    key.AnchorPoint = Vector2.new(1, 0.5)
    key.Position = UDim2.new(1, -8, 0.5, 0)
    key.ZIndex = 15

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 58)
    padding.PaddingRight = UDim.new(0, 42)
    padding.Parent = button

    return button
end

for order, skill_id in ipairs(sorted_skill_ids()) do
    local button = create_skill_button(
        skill_id,
        order
    )
    skill_buttons[skill_id] = button
    -- Skill definitions are public assets, but the player's unlocked
    -- catalogue must come only from their authoritative profile snapshot.
    button.Visible = false

    button.Activated:Connect(function()
        if not is_known(latest, skill_id) then
            status.Text = "This skill is locked. "
                .. "Learn it before assigning it."
            return
        end

        selected_skill = skill_id
        status.Text = "Selected "
            .. tostring(
                button:GetAttribute("SkillDisplayName")
                    or skill_id
            )
            .. ". Choose a hotbar slot."
    end)
end

for slot = 1, 6 do
    local button = create_slot_button(slot)
    slot_buttons[slot] = button

    button.Activated:Connect(function()
        if not selected_skill then
            status.Text = "Select a learned skill first."
            return
        end

        status.Text = "Assigning skill to Slot "
            .. tostring(slot)
            .. "..."
        loadout_request:FireServer(
            selected_skill,
            slot
        )
    end)
end

--[[
Renders learned/locked skill rows and equipped slots.

Args:
    snapshot (any): Current progression snapshot.

Returns:
    None.
]]
local function render(snapshot: any)
    latest = snapshot or {}
    local loadout_state = if type(latest.Loadout) == "table"
        then latest.Loadout
        else {}

    for skill_id, button in pairs(skill_buttons) do
        local definition = SkillDefinitions.get(skill_id)
        local display_name = if definition
            then definition.DISPLAY_NAME
            else skill_id
        local available = type(latest.Skills) == "table"
            and type(latest.Skills[skill_id]) == "table"
        button.Visible = available
        local known = is_known(latest, skill_id)
        local rank = skill_rank(latest, skill_id)
        local selected = selected_skill == skill_id

        if not known and selected then
            selected_skill = nil
            selected = false
        end

        local name_label = skill_name_labels[skill_id]
        local rank_label = skill_rank_labels[skill_id]

        if name_label then
            name_label.Text = display_name
            name_label.TextColor3 = if known
                then UiTheme.PALETTE.Text
                else UiTheme.PALETTE.TextFaint
        end

        if rank_label then
            rank_label.Text = if known
                then "Lv. " .. tostring(rank)
                else "Locked"
            rank_label.TextColor3 = if known
                then UiTheme.PALETTE.Accent
                else UiTheme.PALETTE.TextFaint
        end

        UiArt.paint_button(
            button,
            if selected then "Accent" else "Secondary"
        )
        UiTheme.set_button_enabled(button, known)
    end

    for slot = 1, 6 do
        local skill_id = loadout_state[slot]
        local definition = if type(skill_id) == "string"
            then SkillDefinitions.get(skill_id)
            else nil
        local name = if definition
            then definition.DISPLAY_NAME
            else "Empty"

        slot_buttons[slot].Text = name
        slot_buttons[slot].TextColor3 =
            if definition
                then UiTheme.PALETTE.Text
                else UiTheme.PALETTE.TextMuted
        slot_sigils[slot].Text = if definition
            then string.sub(name, 1, 1)
            else "·"
    end

    task.defer(function()
        skill_list.CanvasSize = UDim2.fromOffset(
            0,
            skill_layout.AbsoluteContentSize.Y + 16
        )
    end)
end

--[[
Shows or hides the Skills modal.

Args:
    visible (boolean): Desired modal visibility.

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

WindowController.register("Skills", apply_visibility)

local function set_visible(visible: boolean)
    WindowController.set_visible("Skills", visible)
end

UiArt.align_close(panel, modal.Close, "Skills")

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

    if input.KeyCode == Enum.KeyCode.K then
        set_visible(true)
    end
end)

action_result.OnClientEvent:Connect(function(payload: any)
    if type(payload) ~= "table"
        or payload.action ~= "Loadout" then
        return
    end

    if payload.ok == true then
        selected_skill = nil
        status.Text = "Loadout updated."
        render(
            ProgressionClientState.get_snapshot()
        )
    else
        status.Text = "Loadout blocked: "
            .. tostring(payload.reason or "Unknown")
    end
end)

ProgressionClientState.subscribe(render)
render(ProgressionClientState.get_snapshot())

task.defer(function()
    progression_snapshot:FireServer("Request")
end)
