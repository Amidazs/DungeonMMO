--!strict
-- First-time Base tutorial layered over existing trusted quest state.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")

local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local TutorialDefinitions = require(
    shared:WaitForChild("TutorialDefinitions")
)
local UiTheme = require(shared:WaitForChild("UiTheme"))
local UiOrnament = require(
    shared:WaitForChild("UiOrnament")
)
local TutorialPathGuide = require(
    script.Parent:WaitForChild("TutorialPathGuide")
)

local quest_action_request = remotes:WaitForChild(
    "QuestActionRequest"
) :: RemoteEvent
local quest_snapshot = remotes:WaitForChild(
    "QuestSnapshot"
) :: RemoteEvent
local quest_dialogue_open = remotes:WaitForChild(
    "QuestDialogueOpen"
) :: RemoteEvent

local GUI_NAME = "NewPlayerTutorial"
local WAYPOINT_NAME = "DungeonMMOTutorialWaypoint"
local FIRST_QUEST_ID = TutorialDefinitions.FIRST_ADVENTURE_ID
local STEPS = TutorialDefinitions.BASE_STEPS
local SNAPSHOT_RETRY_SECONDS = 1.5
local SNAPSHOT_RETRY_COUNT = 8

local old = player_gui:FindFirstChild(GUI_NAME)
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.DisplayOrder = 205
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Enabled = false
gui.Parent = player_gui

local panel = Instance.new("Frame")
panel.Name = "TutorialPanel"
panel.AnchorPoint = Vector2.new(0.5, 0)
panel.Position = UDim2.new(0.5, 0, 0, 18)
panel.Size = UDim2.fromOffset(470, 220)
UiTheme.style_panel(panel, true)
panel.Parent = gui
UiOrnament.frame(panel, true)
UiTheme.bind_responsive_scale(panel, 1366, 0.72, 1)

local header_band = Instance.new("Frame")
header_band.Name = "HeaderBand"
header_band.Position = UDim2.fromOffset(7, 7)
header_band.Size = UDim2.new(1, -14, 0, 48)
header_band.BackgroundColor3 = UiTheme.PALETTE.SurfaceWarm
header_band.BackgroundTransparency = 0.08
header_band.BorderSizePixel = 0
UiTheme.add_gradient(
    header_band,
    UiTheme.PALETTE.SurfaceWarm,
    UiTheme.PALETTE.BackdropSoft
)
header_band.Parent = panel

local eyebrow = Instance.new("TextLabel")
eyebrow.Name = "Eyebrow"
eyebrow.Position = UDim2.fromOffset(22, 11)
eyebrow.Size = UDim2.new(1, -44, 0, 16)
eyebrow.Text = "NEW PLAYER GUIDE"
UiTheme.style_label(eyebrow, "Caption")
eyebrow.TextColor3 = UiTheme.PALETTE.Accent
eyebrow.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.fromOffset(22, 25)
title.Size = UDim2.new(1, -44, 0, 26)
UiTheme.style_label(title, "Heading")
title.Parent = panel

local body = Instance.new("TextLabel")
body.Name = "Body"
body.Position = UDim2.fromOffset(22, 66)
body.Size = UDim2.new(1, -44, 0, 82)
UiTheme.style_label(body, "Body")
body.TextWrapped = true
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextTruncate = Enum.TextTruncate.None
body.Parent = panel

local progress = Instance.new("TextLabel")
progress.Name = "Progress"
progress.Position = UDim2.fromOffset(22, 154)
progress.Size = UDim2.new(0.45, 0, 0, 18)
UiTheme.style_label(progress, "Caption")
progress.Parent = panel

local skip = Instance.new("TextButton")
skip.Name = "Skip"
skip.AnchorPoint = Vector2.new(0, 1)
skip.Position = UDim2.new(0, 22, 1, -14)
skip.Size = UDim2.fromOffset(122, 34)
skip.Text = "Skip for now"
UiTheme.style_button(skip, "Ghost")
skip.Parent = panel

local next_button = Instance.new("TextButton")
next_button.Name = "Next"
next_button.AnchorPoint = Vector2.new(1, 1)
next_button.Position = UDim2.new(1, -22, 1, -14)
next_button.Size = UDim2.fromOffset(156, 34)
UiTheme.style_button(next_button, "Primary")
next_button.Parent = panel

local current_step = 1
local started = false
local dismissed = false
local latest_state: any = nil
local waypoint_target: BasePart? = nil
local waypoint_highlight: Highlight? = nil
local waypoint_billboard: BillboardGui? = nil
local ground_guide = TutorialPathGuide.new(
    player,
    "DungeonMMONewPlayerTutorialGuide"
)

--[[
Returns whether mandatory identity selection is currently blocking the screen.

Args:
    None.

Returns:
    boolean: True while the mandatory race/class overlay is visible.
]]
local function identity_selection_visible(): boolean
    local identity_gui = player_gui:FindFirstChild("IdentitySelectionUi")
    if not identity_gui then
        return false
    end

    local overlay = identity_gui:FindFirstChild("MandatoryOverlay")
    return overlay ~= nil
        and overlay:IsA("GuiObject")
        and overlay.Visible
end

--[[
Finds one generated environment anchor by stable AnchorId attribute.

Args:
    anchor_id (string): Stable environment anchor identifier.

Returns:
    BasePart?: Matching physical anchor when replicated.
]]
local function find_environment_anchor(
    anchor_id: string
): BasePart?
    for _, descendant in ipairs(Workspace:GetDescendants()) do
        if descendant:IsA("BasePart")
            and descendant:GetAttribute("AnchorId") == anchor_id
        then
            return descendant
        end
    end

    return nil
end

--[[
Finds one generated physical quest giver.

Args:
    giver_id (string): Stable quest-giver identifier.

Returns:
    BasePart?: Matching placeholder or final giver root when present.
]]
local function find_quest_giver(
    giver_id: string
): BasePart?
    local folder = Workspace:FindFirstChild(
        "DungeonMMOQuestGivers"
    )
    local giver = folder and folder:FindFirstChild(giver_id)

    if giver and giver:IsA("Model") then
        local root = giver:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            return root
        end
    end

    return if giver and giver:IsA("BasePart")
        then giver
        else nil
end

--[[
Destroys the current local tutorial waypoint presentation.

Args:
    None.

Returns:
    nil: Clears the current local-only highlight and label.
]]
local function clear_waypoint()
    if waypoint_highlight then
        waypoint_highlight:Destroy()
        waypoint_highlight = nil
    end

    if waypoint_billboard then
        waypoint_billboard:Destroy()
        waypoint_billboard = nil
    end

    waypoint_target = nil
    ground_guide:clear()
end

--[[
Adds a local-only highlight and tutorial label to a world object.

Args:
    target (BasePart?): Physical world target to highlight.
    label_text (string): Short waypoint label.

Returns:
    nil: Replaces any previous tutorial waypoint.
]]
local function set_waypoint(
    target: BasePart?,
    label_text: string
)
    clear_waypoint()

    if not target then
        return
    end

    waypoint_target = target
    ground_guide:set_target(target)

    local highlight = Instance.new("Highlight")
    highlight.Name = WAYPOINT_NAME
    highlight.Adornee = target
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.78
    highlight.OutlineTransparency = 0
    highlight.Parent = target
    waypoint_highlight = highlight

    local billboard = Instance.new("BillboardGui")
    billboard.Name = WAYPOINT_NAME
    billboard.Size = UDim2.fromOffset(220, 42)
    billboard.StudsOffset = Vector3.new(0, 6.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = target

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = UiTheme.PALETTE.Surface
    label.BackgroundTransparency = 0.12
    label.Text = "◆ " .. label_text
    label.TextColor3 = UiTheme.PALETTE.AccentBright
    label.Font = UiTheme.FONT.Strong
    label.TextSize = 14
    UiTheme.add_corner(label, 2)
    UiTheme.add_stroke(
        label,
        UiTheme.PALETTE.Accent,
        0.25
    )
    label.Parent = billboard
    waypoint_billboard = billboard
end

--[[
Returns whether the first Adventure has started or completed.

Args:
    state (any): Server-owned quest snapshot state.

Returns:
    boolean: True once Worldroot Relic is active or complete.
]]
local function first_quest_started(state: any): boolean
    if type(state) ~= "table" then
        return false
    end

    local active = type(state.Active) == "table"
        and state.Active
        or {}
    local completed = type(state.Completed) == "table"
        and state.Completed
        or {}

    return type(active[FIRST_QUEST_ID]) == "table"
        or completed[FIRST_QUEST_ID] == true
end

--[[
Updates the waypoint for the currently displayed tutorial step.

Args:
    step_id (string): Stable tutorial step identifier.

Returns:
    nil: Applies or clears a local world waypoint.
]]
local function update_waypoint(step_id: string)
    if step_id == "WorldrootKeeper" then
        set_waypoint(
            find_quest_giver("WorldrootKeeper"),
            "Worldroot Keeper"
        )
        return
    end

    if step_id == "PartyAndPortal" then
        set_waypoint(
            find_environment_anchor("Base.TemplePortal"),
            "Temple Entrance"
        )
        return
    end

    clear_waypoint()
end

--[[
Renders the current tutorial copy and waypoint.

Args:
    None.

Returns:
    nil: Updates the tutorial panel from the shared step catalogue.
]]
local function render_step()
    local step = STEPS[current_step]
    if not step then
        return
    end

    title.Text = step.Title
    body.Text = step.Text
    progress.Text = string.format(
        "Step %d of %d",
        current_step,
        #STEPS
    )
    next_button.Text = step.ButtonText

    local waiting_for_quest =
        step.Id == "AcceptAdventure"
    UiTheme.set_button_enabled(
        next_button,
        not waiting_for_quest
    )

    update_waypoint(step.Id)
end

--[[
Hides the tutorial for the remainder of the current Base session.

Args:
    None.

Returns:
    nil: Clears tutorial UI and waypoint presentation.
]]
local function dismiss()
    dismissed = true
    gui.Enabled = false
    clear_waypoint()
end

--[[
Shows the tutorial after mandatory character creation is out of the way.

Args:
    None.

Returns:
    nil: Defers until the identity overlay is not visible.
]]
local function begin_when_ready()
    if started or dismissed then
        return
    end

    task.spawn(function()
        while identity_selection_visible() do
            task.wait(0.25)
        end

        if dismissed or first_quest_started(latest_state) then
            return
        end

        started = true
        current_step = 1
        gui.Enabled = true
        render_step()
    end)
end

--[[
Advances to the next manually controlled tutorial step.

Args:
    None.

Returns:
    nil: Finishes the tutorial after the final step.
]]
local function advance()
    if dismissed or not started then
        return
    end

    if current_step >= #STEPS then
        dismiss()
        return
    end

    current_step += 1
    render_step()
end

--[[
Handles an authoritative quest snapshot for tutorial gating.

Args:
    payload (any): QuestSnapshot remote payload.

Returns:
    nil: Starts or advances tutorial presentation as appropriate.
]]
local function handle_quest_snapshot(payload: any)
    if type(payload) ~= "table"
        or type(payload.State) ~= "table"
        or payload.State.ok ~= true
    then
        return
    end

    latest_state = payload.State

    if not started then
        if not first_quest_started(latest_state) then
            begin_when_ready()
        end
        return
    end

    if current_step == 3
        and first_quest_started(latest_state)
    then
        current_step = 4
        render_step()
    end
end

--[[
Handles a server-selected physical quest-giver conversation.

Args:
    payload (any): QuestDialogueOpen presentation payload.

Returns:
    nil: Advances the tutorial when the first quest giver is reached.
]]
local function handle_dialogue_open(payload: any)
    if not started
        or current_step ~= 2
        or type(payload) ~= "table"
    then
        return
    end

    if payload.ok == true
        and payload.GiverId == "WorldrootKeeper"
        and payload.QuestId == FIRST_QUEST_ID
    then
        current_step = 3
        render_step()
    end
end

skip.Activated:Connect(dismiss)
next_button.Activated:Connect(advance)
quest_snapshot.OnClientEvent:Connect(handle_quest_snapshot)
quest_dialogue_open.OnClientEvent:Connect(handle_dialogue_open)

task.spawn(function()
    for _ = 1, SNAPSHOT_RETRY_COUNT do
        if latest_state or dismissed then
            break
        end

        quest_action_request:FireServer("Snapshot")
        task.wait(SNAPSHOT_RETRY_SECONDS)
    end
end)
