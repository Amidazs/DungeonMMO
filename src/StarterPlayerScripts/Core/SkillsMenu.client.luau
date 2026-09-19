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
    UDim2.fromOffset(820, 570)
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

local skill_heading = UiComponents.section_heading(
    modal.Body,
    "AVAILABLE SKILLS"
)
skill_heading.Position = UDim2.fromOffset(0, 0)
skill_heading.Size = UDim2.new(0.56, -10, 0, 20)
skill_heading.ZIndex = 12

local loadout_heading = UiComponents.section_heading(
    modal.Body,
    "ACTIVE LOADOUT"
)
loadout_heading.Position = UDim2.new(0.58, 8, 0, 0)
loadout_heading.Size = UDim2.new(0.42, -8, 0, 20)
loadout_heading.ZIndex = 12

local skill_list = Instance.new("ScrollingFrame")
skill_list.Name = "SkillList"
skill_list.Position = UDim2.fromOffset(0, 28)
skill_list.Size = UDim2.new(0.56, -10, 1, -76)
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

local skill_layout = Instance.new("UIListLayout")
skill_layout.Padding = UDim.new(0, 7)
skill_layout.SortOrder = Enum.SortOrder.LayoutOrder
skill_layout.Parent = skill_list

local loadout = Instance.new("Frame")
loadout.Name = "Loadout"
loadout.Position = UDim2.new(0.58, 8, 0, 28)
loadout.Size = UDim2.new(0.42, -8, 1, -76)
loadout.BackgroundColor3 = UiTheme.PALETTE.Backdrop
loadout.BackgroundTransparency = 0.55
loadout.BorderSizePixel = 0
loadout.ZIndex = 12
UiTheme.add_corner(loadout, 8)
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
local slot_buttons: {[number]: TextButton} = {}

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
        display_name,
        "Secondary"
    )
    button.LayoutOrder = order
    button.Size = UDim2.new(1, 0, 0, 52)
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.TextSize = 14
    button.ZIndex = 13

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 14)
    padding.PaddingRight = UDim.new(0, 14)
    padding.Parent = button

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
    button.Size = UDim2.new(1, 0, 0, 56)
    button.TextWrapped = true
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.ZIndex = 13

    local key = UiComponents.key_hint(
        button,
        tostring(slot)
    )
    key.AnchorPoint = Vector2.new(1, 0.5)
    key.Position = UDim2.new(1, -8, 0.5, 0)
    key.ZIndex = 14

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
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

    button.Activated:Connect(function()
        if not is_known(latest, skill_id) then
            status.Text = "This skill is locked. "
                .. "Learn it before assigning it."
            return
        end

        selected_skill = skill_id
        status.Text = "Selected "
            .. button.Text:gsub("   •.*$", "")
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
        local known = is_known(latest, skill_id)
        local rank = skill_rank(latest, skill_id)
        local selected = selected_skill == skill_id

        if not known and selected then
            selected_skill = nil
            selected = false
        end

        button.Text = string.format(
            "%s   •   %s",
            display_name,
            if known
                then "Rank " .. tostring(rank)
                else "Locked"
        )
        button.TextColor3 = if known
            then UiTheme.PALETTE.Text
            else UiTheme.PALETTE.TextFaint
        button.BackgroundColor3 = if selected
            then UiTheme.PALETTE.AccentDark
            else UiTheme.PALETTE.SurfaceRaised
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

        slot_buttons[slot].Text = string.format(
            "Slot %d   •   %s",
            slot,
            name
        )
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

    if input.KeyCode == Enum.KeyCode.K then
        set_visible(not panel.Visible)
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
