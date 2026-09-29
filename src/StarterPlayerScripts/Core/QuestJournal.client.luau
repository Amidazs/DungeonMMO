--!strict
-- Shared Adventure quest tracker and journal for Base and Dungeon places.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local QuestPresentation = require(
    shared:WaitForChild("QuestPresentation")
)
local DungeonDefinitions = require(
    shared:WaitForChild("DungeonDefinitions")
)
local QuestNarrativeDefinitions = require(
    shared:WaitForChild("QuestNarrativeDefinitions")
)
local UiComponents = require(
    shared:WaitForChild("UiComponents")
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

local quest_action_request = remotes:WaitForChild(
    "QuestActionRequest"
) :: RemoteEvent
local quest_action_result = remotes:WaitForChild(
    "QuestActionResult"
) :: RemoteEvent
local quest_snapshot = remotes:WaitForChild(
    "QuestSnapshot"
) :: RemoteEvent

local WINDOW_NAME = "Quests"
local GUI_NAME = "QuestJournal"
local SNAPSHOT_REFRESH_SECONDS = 1
local MAX_TRACKER_HEIGHT = 440
local TRACKER_WIDTH = 330
local JOURNAL_ROW_HEIGHT = 76

local player_scripts = player:WaitForChild("PlayerScripts")
local ground_guide: any = nil

--[[
Creates the Base-only floor guide once the Base client folder is replicated.

Core scripts can start before the sibling Base folder is copied into
PlayerScripts, so this is intentionally lazy instead of checking only once
during module startup.

Args:
    None.

Returns:
    any?: Quest tracking guide in Base, or nil in Dungeon.
]]
local function ensure_ground_guide(): any?
    if ground_guide then
        return ground_guide
    end

    local base_folder = player_scripts:FindFirstChild("Base")
    if not base_folder then
        return nil
    end

    local guide_module = base_folder:FindFirstChild(
        "TutorialPathGuide"
    )
    if not guide_module or not guide_module:IsA("ModuleScript") then
        return nil
    end

    local TutorialPathGuide = require(guide_module)
    ground_guide = TutorialPathGuide.new(
        player,
        "DungeonMMOQuestTrackingGuide"
    )
    return ground_guide
end

local previous = player_gui:FindFirstChild(GUI_NAME)
if previous then
    previous:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = GUI_NAME
gui.ResetOnSpawn = false
gui.DisplayOrder = 175
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player_gui

local tracker = Instance.new("Frame")
tracker.Name = "ActiveQuestTracker"
tracker.AnchorPoint = Vector2.new(1, 0)
tracker.Position = UDim2.new(1, -18, 0, 226)
tracker.Size = UDim2.fromOffset(
    TRACKER_WIDTH,
    MAX_TRACKER_HEIGHT
)
tracker.Visible = false
tracker.BackgroundTransparency = 1
tracker.BorderSizePixel = 0
tracker.Parent = gui

local tracker_art = UiArt.reference_background(
    tracker,
    "Tracker",
    1
)
tracker_art.Name = "TrackerArt"

local tracker_header = Instance.new("Frame")
tracker_header.Name = "HeaderBand"
tracker_header.Position = UDim2.fromOffset(7, 7)
tracker_header.Size = UDim2.new(1, -14, 0, 31)
tracker_header.BackgroundTransparency = 1
tracker_header.BorderSizePixel = 0
tracker_header.ZIndex = 2
tracker_header.Parent = tracker
UiTheme.bind_responsive_scale(
    tracker,
    1366,
    0.66,
    1
)

local tracker_title = UiComponents.label(
    tracker,
    "Title",
    "Quest Tracker",
    "Heading"
)
tracker_title.Position = UDim2.fromOffset(17, 10)
tracker_title.Size = UDim2.new(1, -34, 0, 24)
tracker_title.TextColor3 = UiTheme.PALETTE.Text
tracker_title.Visible = false
tracker_title.TextSize = 17
tracker_title.ZIndex = 2

local tracker_hint = UiComponents.label(
    tracker,
    "Hint",
    "L  JOURNAL",
    "Caption"
)
tracker_hint.AnchorPoint = Vector2.new(1, 0)
tracker_hint.Position = UDim2.new(1, -15, 0, 13)
tracker_hint.Size = UDim2.fromOffset(88, 14)
tracker_hint.TextXAlignment = Enum.TextXAlignment.Right
tracker_hint.TextSize = 9
tracker_hint.Visible = false
tracker_hint.ZIndex = 3

local tracker_list = Instance.new("ScrollingFrame")
tracker_list.Name = "QuestRows"
tracker_list.Position = UDim2.fromOffset(30, 82)
tracker_list.Size = UDim2.new(1, -60, 1, -108)
tracker_list.CanvasSize = UDim2.new()
tracker_list.AutomaticCanvasSize = Enum.AutomaticSize.Y
tracker_list.BackgroundTransparency = 1
tracker_list.BorderSizePixel = 0
tracker_list.ScrollBarThickness = 3
tracker_list.ZIndex = 2
tracker_list.Parent = tracker

local tracker_layout = Instance.new("UIListLayout")
tracker_layout.Padding = UDim.new(0, 6)
tracker_layout.SortOrder = Enum.SortOrder.LayoutOrder
tracker_layout.Parent = tracker_list

local modal = UiComponents.modal(
    gui,
    "QuestJournalWindow",
    "Quest Journal",
    "Accepted quests, objectives and rewards.",
    UDim2.fromOffset(680, 850)
)
local journal_panel = modal.Root
journal_panel.AnchorPoint = Vector2.new(0, 0)
journal_panel.Position = UDim2.fromOffset(22, 86)
journal_panel.Visible = false
journal_panel.ZIndex = 1
UiArt.clear_frame_chrome(journal_panel)
UiArt.reference_background(
    journal_panel,
    "Journal",
    1
)

modal.Body.Position = UiArt.position(
    "Journal",
    62,
    300
)
modal.Body.Size = UiArt.rect(
    "Journal",
    62,
    300,
    994,
    1017
)
modal.Body.ZIndex = 3
modal.Header.ZIndex = 3
modal.Title.Visible = false
modal.Subtitle.Visible = false

local modal_header_band = journal_panel:FindFirstChild("HeaderBand")
if modal_header_band and modal_header_band:IsA("GuiObject") then
    modal_header_band.Visible = false
end

local modal_divider = journal_panel:FindFirstChild("OrnateDivider")
if modal_divider and modal_divider:IsA("GuiObject") then
    modal_divider.Visible = false
end

modal.Close.BackgroundTransparency = 1
modal.Close.TextTransparency = 1
modal.Close.ZIndex = 4
UiTheme.bind_responsive_scale(
    journal_panel,
    1366,
    0.72,
    1
)

local tab_bar = Instance.new("Frame")
tab_bar.Name = "JournalTabs"
tab_bar.Position = UiArt.position(
    "Journal",
    70,
    214
)
tab_bar.Size = UiArt.rect(
    "Journal",
    70,
    214,
    710,
    58
)
tab_bar.BackgroundTransparency = 1
tab_bar.Visible = true
tab_bar.ZIndex = 3
tab_bar.Parent = journal_panel

local tab_layout = Instance.new("UIListLayout")
tab_layout.FillDirection = Enum.FillDirection.Horizontal
tab_layout.Padding = UDim.new(0, 5)
tab_layout.Parent = tab_bar

local active_tab = UiComponents.button(
    tab_bar,
    "ActiveTab",
    "Active",
    "Primary"
)
active_tab.Size = UDim2.new(0.333, -4, 1, 0)
active_tab.ZIndex = 4
active_tab.Active = false
UiArt.paint_tab(active_tab, true)

local completed_tab = UiComponents.button(
    tab_bar,
    "CompletedTab",
    "Completed",
    "Ghost"
)
completed_tab.Size = UDim2.new(0.333, -4, 1, 0)
completed_tab.ZIndex = 4
completed_tab.Active = false
UiArt.paint_tab(completed_tab, false)

local failed_tab = UiComponents.button(
    tab_bar,
    "FailedTab",
    "Failed",
    "Ghost"
)
failed_tab.Size = UDim2.new(0.333, -4, 1, 0)
failed_tab.ZIndex = 4
failed_tab.Active = false
UiArt.paint_tab(failed_tab, false)

local journal_status = UiComponents.label(
    modal.Body,
    "Status",
    "Loading accepted quests...",
    "Muted"
)
journal_status.Position = UDim2.fromOffset(6, 39)
journal_status.Size = UDim2.new(1, -12, 0, 23)
journal_status.TextWrapped = true
journal_status.TextSize = 10
journal_status.Visible = false
journal_status.ZIndex = 3

local journal_content = Instance.new("Frame")
journal_content.Name = "JournalContent"
journal_content.Position = UDim2.fromScale(0, 0)
journal_content.Size = UDim2.fromScale(1, 1)
journal_content.BackgroundTransparency = 1
journal_content.ZIndex = 2
journal_content.Parent = modal.Body

local journal_list = Instance.new("ScrollingFrame")
journal_list.Name = "QuestList"
journal_list.Size = UDim2.new(0.44, -6, 1, 0)
journal_list.CanvasSize = UDim2.new()
journal_list.AutomaticCanvasSize = Enum.AutomaticSize.Y
UiTheme.style_scroll(journal_list)
journal_list.BackgroundTransparency = 1
journal_list.ZIndex = 3
local journal_list_stroke =
    journal_list:FindFirstChildOfClass("UIStroke")
if journal_list_stroke then
    journal_list_stroke.Transparency = 1
end
journal_list.Parent = journal_content

local journal_padding = Instance.new("UIPadding")
journal_padding.PaddingTop = UDim.new(0, 7)
journal_padding.PaddingBottom = UDim.new(0, 7)
journal_padding.PaddingLeft = UDim.new(0, 7)
journal_padding.PaddingRight = UDim.new(0, 7)
journal_padding.Parent = journal_list

local journal_layout = Instance.new("UIListLayout")
journal_layout.Padding = UDim.new(0, 7)
journal_layout.SortOrder = Enum.SortOrder.LayoutOrder
journal_layout.Parent = journal_list

local detail_panel = Instance.new("Frame")
detail_panel.Name = "QuestDetail"
detail_panel.Position = UDim2.new(0.44, 6, 0, 0)
detail_panel.Size = UDim2.new(0.56, -6, 1, 0)
detail_panel.BorderSizePixel = 0
UiTheme.style_inset(detail_panel, false)
detail_panel.BackgroundTransparency = 1
detail_panel.ZIndex = 3
local detail_stroke =
    detail_panel:FindFirstChildOfClass("UIStroke")
if detail_stroke then
    detail_stroke.Transparency = 1
end
detail_panel.Parent = journal_content

local detail_title = UiComponents.label(
    detail_panel,
    "QuestName",
    "Select a quest",
    "Title"
)
detail_title.Position = UDim2.fromOffset(18, 14)
detail_title.Size = UDim2.new(1, -36, 0, 32)
detail_title.TextSize = 24

local detail_meta = UiComponents.label(
    detail_panel,
    "QuestMeta",
    "",
    "Muted"
)
detail_meta.Position = UDim2.fromOffset(18, 47)
detail_meta.Size = UDim2.new(1, -36, 0, 20)

local location_card = Instance.new("Frame")
location_card.Name = "LocationCard"
location_card.Position = UDim2.fromOffset(18, 74)
location_card.Size = UDim2.new(1, -36, 0, 66)
UiTheme.style_inset(location_card, true)
location_card.BackgroundTransparency = 1
local location_stroke =
    location_card:FindFirstChildOfClass("UIStroke")
if location_stroke then
    location_stroke.Transparency = 1
end
location_card.Parent = detail_panel

local location_kicker = UiComponents.label(
    location_card,
    "LocationKicker",
    "QUEST LOCATION",
    "Caption"
)
location_kicker.Position = UDim2.fromOffset(12, 7)
location_kicker.Size = UDim2.new(1, -24, 0, 16)
location_kicker.TextColor3 = UiTheme.PALETTE.Accent

local location_name = UiComponents.label(
    location_card,
    "LocationName",
    "Adventure",
    "Heading"
)
location_name.Position = UDim2.fromOffset(12, 23)
location_name.Size = UDim2.new(1, -24, 0, 22)

local location_depth = UiComponents.label(
    location_card,
    "LocationDepth",
    "",
    "Muted"
)
location_depth.Position = UDim2.fromOffset(12, 44)
location_depth.Size = UDim2.new(1, -24, 0, 16)
location_depth.TextSize = 11

local detail_story = UiComponents.label(
    detail_panel,
    "QuestStory",
    "",
    "Body"
)
detail_story.Position = UDim2.fromOffset(18, 151)
detail_story.Size = UDim2.new(1, -36, 0, 72)
detail_story.TextWrapped = true
detail_story.TextYAlignment = Enum.TextYAlignment.Top
detail_story.TextTruncate = Enum.TextTruncate.None

local objectives_heading = UiComponents.section_heading(
    detail_panel,
    "OBJECTIVES"
)
objectives_heading.Position = UDim2.fromOffset(18, 229)
objectives_heading.Size = UDim2.new(1, -36, 0, 18)

local detail_objectives = Instance.new("Frame")
detail_objectives.Name = "Objectives"
detail_objectives.Position = UDim2.fromOffset(18, 251)
detail_objectives.Size = UDim2.new(1, -36, 0, 98)
detail_objectives.BackgroundTransparency = 1
detail_objectives.Parent = detail_panel

local objective_layout = Instance.new("UIListLayout")
objective_layout.Padding = UDim.new(0, 5)
objective_layout.SortOrder = Enum.SortOrder.LayoutOrder
objective_layout.Parent = detail_objectives

local rewards_heading = UiComponents.section_heading(
    detail_panel,
    "REWARDS"
)
rewards_heading.Position = UDim2.fromOffset(18, 354)
rewards_heading.Size = UDim2.new(1, -36, 0, 18)

local detail_reward = UiComponents.label(
    detail_panel,
    "Reward",
    "",
    "Body"
)
detail_reward.Position = UDim2.fromOffset(18, 376)
detail_reward.Size = UDim2.new(1, -36, 0, 34)
detail_reward.TextWrapped = true
detail_reward.TextYAlignment = Enum.TextYAlignment.Top

local detail_ready = UiComponents.label(
    detail_panel,
    "Ready",
    "",
    "Caption"
)
detail_ready.Position = UDim2.fromOffset(18, 414)
detail_ready.Size = UDim2.new(1, -36, 0, 18)
detail_ready.TextColor3 = UiTheme.PALETTE.AccentBright

local detail_track = UiComponents.button(
    detail_panel,
    "Track",
    "Track Quest",
    "Primary"
)
detail_track.AnchorPoint = Vector2.new(0, 1)
detail_track.Position = UDim2.new(0, 18, 1, -14)
detail_track.Size = UDim2.new(1, -36, 0, 38)

local latest: any = nil
local auto_track_requested = false
local selected_journal_quest_id: string? = nil

--[[
Removes generated GUI rows while preserving layout helpers.

Args:
    container (Instance): Tracker or journal row container.
    preserved ({Instance}): Child instances that must remain.

Returns:
    nil: Destroys only generated GuiObjects.
]]
local function clear_generated_rows(
    container: Instance,
    preserved: {Instance}
)
    local keep: {[Instance]: boolean} = {}

    for _, child in ipairs(preserved) do
        keep[child] = true
    end

    for _, child in ipairs(container:GetChildren()) do
        if not keep[child] and child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

--[[
Returns active Adventure definitions in server catalogue order.

Args:
    None.

Returns:
    {any}: Definitions that currently have active quest state.
]]
local function active_definitions(): {any}
    local result = {}

    if type(latest) ~= "table"
        or type(latest.Definitions) ~= "table"
        or type(latest.State) ~= "table"
        or type(latest.State.Active) ~= "table"
    then
        return result
    end

    for _, definition in ipairs(latest.Definitions) do
        if type(latest.State.Active[definition.Id]) == "table" then
            table.insert(result, definition)
        end
    end

    return result
end

--[[
Returns the current active state for one quest.

Args:
    quest_id (string): Stable Adventure quest identifier.

Returns:
    any?: Active quest state when present.
]]
local function active_state(quest_id: string): any?
    if type(latest) ~= "table"
        or type(latest.State) ~= "table"
        or type(latest.State.Active) ~= "table"
    then
        return nil
    end

    return latest.State.Active[quest_id]
end

--[[
Returns whether one quest is the persistent tracked quest.

Args:
    quest_id (string): Stable Adventure quest identifier.

Returns:
    boolean: True only for the single tracked quest.
]]
local function is_tracked(quest_id: string): boolean
    return type(latest) == "table"
        and type(latest.State) == "table"
        and latest.State.TrackedQuestId == quest_id
end

--[[
Requests a server-owned quest snapshot.

Args:
    None.

Returns:
    nil: Sends the read-only Snapshot action.
]]
local function request_snapshot()
    quest_action_request:FireServer("Snapshot")
end

--[[
Requests that one active quest become the tracked quest.

Args:
    quest_id (string): Active Adventure quest identifier.

Returns:
    nil: Sends only the selected quest id to the server.
]]
local function request_track(quest_id: string)
    quest_action_request:FireServer("Track", quest_id)
end

--[[
Finds one Base environment anchor by stable AnchorId.

Args:
    anchor_id (string): Stable environment anchor id.

Returns:
    BasePart?: Matching replicated anchor.
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
Finds one physical Base quest giver root.

Args:
    giver_id (string): Stable quest-giver id.

Returns:
    BasePart?: Physical giver root when present.
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
Returns whether the first-time tutorial currently owns Base guidance.

Args:
    None.

Returns:
    boolean: True while the tutorial overlay is enabled.
]]
local function tutorial_owns_guidance(): boolean
    local tutorial = player_gui:FindFirstChild("NewPlayerTutorial")

    return tutorial ~= nil
        and tutorial:IsA("ScreenGui")
        and tutorial.Enabled
end

--[[
Updates the Base-only floor flow for the persistent tracked quest.

Args:
    None.

Returns:
    nil: Clears guidance in Dungeon or when no valid tracked target exists.
]]
local function update_base_guidance()
    local guide = ensure_ground_guide()
    if not guide then
        return
    end

    if tutorial_owns_guidance() then
        guide:clear()
        return
    end

    local tracked_id = type(latest) == "table"
        and type(latest.State) == "table"
        and latest.State.TrackedQuestId
        or nil
    local state = type(tracked_id) == "string"
        and active_state(tracked_id)
        or nil
    local definition = nil

    for _, candidate in ipairs(active_definitions()) do
        if candidate.Id == tracked_id then
            definition = candidate
            break
        end
    end

    if not definition or not state then
        guide:clear()
        return
    end

    local navigation =
        QuestPresentation.base_navigation_target(
            definition,
            state
        )

    if not navigation then
        guide:clear()
        return
    end

    local target = if navigation.Kind == "Giver"
        then find_quest_giver(navigation.Id)
        else find_environment_anchor(navigation.Id)

    if target then
        guide:set_target(target)
    else
        guide:clear()
    end
end

--[[
Returns the compact tracker line for one active quest.

Args:
    definition (any): Adventure quest definition.
    state (any): Active quest state.

Returns:
    string: Current goal or hand-in text.
]]
local function tracker_goal_text(
    definition: any,
    state: any
): string
    if type(state) == "table" and state.Ready == true then
        local giver = QuestPresentation.giver_for_quest(
            definition.Id
        )

        return if giver
            then "Return to " .. tostring(giver.Speaker)
            else "Ready to turn in"
    end

    local row = QuestPresentation.first_incomplete(
        definition,
        state
    )

    return if row
        then row.Text
        else "Objectives complete"
end

--[[
Returns the dungeon and depth context for the current quest objective.

Args:
    definition (any): Active Adventure quest definition.
    state (any): Current active quest state.

Returns:
    (string, string): Location name and eligible depth text.
]]
local function quest_location_text(
    definition: any,
    state: any
): (string, string)
    local row = QuestPresentation.first_incomplete(
        definition,
        state
    )

    if not row then
        return "Adventure", "Objectives complete"
    end

    local requirement =
        QuestPresentation.objective_dungeon_requirement(
            row.Definition
        )

    if not requirement then
        return "Sunridge Village", "Base objective"
    end

    local dungeon = DungeonDefinitions.get(
        tostring(requirement.DungeonId or "")
    )
    local dungeon_name = if dungeon
        then tostring(dungeon.DisplayName)
        else tostring(requirement.DungeonId or "Dungeon")

    return dungeon_name,
        QuestPresentation.difficulty_text(requirement)
end


--[[
Returns the compact tracker height needed by one active quest.

Args:
    definition (any): Active Adventure definition.
    state (any): Active quest state.

Returns:
    number: Pixel height for the tracker row.
]]
local function tracker_row_height(
    definition: any,
    state: any
): number
    if type(state) == "table" and state.Ready == true then
        return 92
    end

    local objectives = QuestPresentation.objective_rows(
        definition,
        state
    )

    return 70 + math.max(1, #objectives) * 21
end

--[[
Creates one compact right-side active quest row.

Args:
    definition (any): Active Adventure definition.
    order (number): Stable tracker order.

Returns:
    number: Rendered row height in pixels.
]]
local function add_tracker_row(
    definition: any,
    order: number
): number
    local state = active_state(definition.Id)
    if not state then
        return 0
    end

    local tracked = is_tracked(definition.Id)
    local row_height = tracker_row_height(
        definition,
        state
    )
    local row = Instance.new("TextButton")
    row.Name = definition.Id
    row.LayoutOrder = order
    row.Size = UDim2.new(1, 0, 0, row_height)
    row.BackgroundColor3 = if tracked
        then UiTheme.PALETTE.SurfaceWarm
        else UiTheme.PALETTE.SurfaceRaised
    row.BackgroundTransparency = if tracked then 0.36 else 0.62
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    UiTheme.add_corner(row, 2)
    UiTheme.add_stroke(
        row,
        if tracked
            then UiTheme.PALETTE.Accent
            else UiTheme.PALETTE.BorderSoft,
        if tracked then 0.18 else 0.58
    )
    row.Parent = tracker_list

    local name = UiComponents.label(
        row,
        "QuestName",
        (if tracked then "◆ " else "")
            .. tostring(definition.DisplayName or definition.Id),
        "Body"
    )
    name.Position = UDim2.fromOffset(12, 6)
    name.Size = UDim2.new(1, -24, 0, 20)
    name.TextColor3 = if tracked
        then UiTheme.PALETTE.AccentBright
        else UiTheme.PALETTE.Text

    local location_text, depth_text = quest_location_text(
        definition,
        state
    )
    local location = UiComponents.label(
        row,
        "Location",
        location_text .. "  •  " .. depth_text,
        "Caption"
    )
    location.Position = UDim2.fromOffset(12, 26)
    location.Size = UDim2.new(1, -24, 0, 16)
    location.TextColor3 = UiTheme.PALETTE.TextMuted
    location.TextTruncate = Enum.TextTruncate.AtEnd

    if type(state) == "table" and state.Ready == true then
        local goal = UiComponents.label(
            row,
            "Goal",
            tracker_goal_text(definition, state),
            "Muted"
        )
        goal.Position = UDim2.fromOffset(12, 47)
        goal.Size = UDim2.new(1, -24, 0, 18)
        goal.TextWrapped = false
        goal.TextTruncate = Enum.TextTruncate.AtEnd
        goal.TextColor3 = UiTheme.PALETTE.Accent
    else
        local objectives = QuestPresentation.objective_rows(
            definition,
            state
        )

        for index, objective in ipairs(objectives) do
            local goal = UiComponents.label(
                row,
                "Goal" .. tostring(index),
                (if objective.Complete then "✓  " else "□  ")
                    .. objective.Text,
                if objective.Complete then "Muted" else "Body"
            )
            goal.Position = UDim2.fromOffset(
                12,
                46 + (index - 1) * 21
            )
            goal.Size = UDim2.new(1, -24, 0, 19)
            goal.TextWrapped = false
            goal.TextTruncate = Enum.TextTruncate.AtEnd
        end
    end

    local reward = UiComponents.label(
        row,
        "Reward",
        "Rewards  •  "
            .. QuestPresentation.reward_text(definition.Reward),
        "Caption"
    )
    reward.AnchorPoint = Vector2.new(0, 1)
    reward.Position = UDim2.new(0, 12, 1, -6)
    reward.Size = UDim2.new(1, -24, 0, 16)
    reward.TextColor3 = UiTheme.PALETTE.Accent
    reward.TextTruncate = Enum.TextTruncate.AtEnd

    row.Activated:Connect(function()
        if not tracked then
            request_track(definition.Id)
        end
    end)

    return row_height
end

--[[
Renders the permanent right-side list of accepted quests.

Args:
    None.

Returns:
    nil: Hides the tracker when no Adventure quests are active.
]]
local function render_tracker()
    clear_generated_rows(
        tracker_list,
        {tracker_layout}
    )

    local definitions = active_definitions()
    tracker.Visible = #definitions > 0

    if #definitions == 0 then
        return
    end

    table.sort(definitions, function(a: any, b: any)
        if is_tracked(a.Id) ~= is_tracked(b.Id) then
            return is_tracked(a.Id)
        end
        return tostring(a.DisplayName) < tostring(b.DisplayName)
    end)

    local content_height = 0

    for index, definition in ipairs(definitions) do
        content_height += add_tracker_row(
            definition,
            index
        )
    end

    content_height += math.max(
        0,
        #definitions - 1
    ) * 6

    tracker.Size = UDim2.fromOffset(
        TRACKER_WIDTH,
        MAX_TRACKER_HEIGHT
    )
end

--[[
Returns one readable narrative paragraph for the selected quest.

Args:
    definition (any): Active Adventure quest definition.
    state (any): Current active quest state.

Returns:
    string: Progress or ready narrative text when available.
]]
local function journal_story_text(
    definition: any,
    state: any
): string
    local narrative = QuestNarrativeDefinitions.get(
        definition.Id
    )
    if type(narrative) ~= "table" then
        return "Continue this adventure and complete its current objectives."
    end

    local lines = if type(state) == "table"
        and state.Ready == true
        then narrative.Ready
        else narrative.Progress

    if type(lines) ~= "table" then
        lines = narrative.Start
    end

    return if type(lines) == "table"
        then table.concat(lines, " ")
        else "Continue this adventure and complete its current objectives."
end

--[[
Clears generated objective labels from the detail pane.

Args:
    None.

Returns:
    None.
]]
local function clear_detail_objectives()
    for _, child in ipairs(detail_objectives:GetChildren()) do
        if child ~= objective_layout
            and child:IsA("GuiObject")
        then
            child:Destroy()
        end
    end
end

--[[
Renders the selected quest into the right-side detail pane.

Args:
    definition (any): Selected active Adventure definition.

Returns:
    None.
]]
local function render_journal_detail(
    definition: any
)
    local state = active_state(definition.Id)
    if not state then
        return
    end

    local narrative = QuestNarrativeDefinitions.get(
        definition.Id
    )
    local speaker = type(narrative) == "table"
        and narrative.Speaker
        or "Adventure"
    local tracked = is_tracked(definition.Id)
    local location_text, depth_text = quest_location_text(
        definition,
        state
    )

    detail_title.Text = tostring(
        definition.DisplayName or definition.Id
    )
    detail_meta.Text = string.format(
        "%s   •   Recommended level %d+",
        tostring(speaker),
        tonumber(definition.MinimumLevel) or 1
    )
    location_name.Text = location_text
    location_depth.Text = depth_text

    detail_story.Text = journal_story_text(
        definition,
        state
    )

    clear_detail_objectives()
    for index, objective in ipairs(
        QuestPresentation.objective_rows(
            definition,
            state
        )
    ) do
        local label = UiComponents.label(
            detail_objectives,
            "Objective" .. tostring(index),
            (if objective.Complete then "✓  " else "□  ")
                .. objective.Text,
            if objective.Complete then "Muted" else "Body"
        )
        label.LayoutOrder = index
        label.Size = UDim2.new(1, 0, 0, 25)
        label.TextWrapped = true
        label.TextColor3 = if objective.Complete
            then UiTheme.PALETTE.Success
            else UiTheme.PALETTE.Text
    end

    detail_reward.Text =
        QuestPresentation.reward_text(definition.Reward)

    if type(state) == "table" and state.Ready == true then
        local giver = QuestPresentation.giver_for_quest(
            definition.Id
        )
        detail_ready.Text = if giver
            then "READY • Return to " .. tostring(giver.Speaker)
            else "READY TO TURN IN"
    else
        detail_ready.Text = ""
    end

    detail_track.Text = if tracked
        then "Tracking Quest"
        else "Track Quest"
    UiTheme.style_button(
        detail_track,
        if tracked then "Ghost" else "Primary"
    )
    UiTheme.set_button_enabled(
        detail_track,
        not tracked
    )
end

local render_journal: () -> ()

--[[
Creates one selectable quest entry in the left-side journal list.

Args:
    definition (any): Active Adventure definition.
    order (number): Stable list order.

Returns:
    None.
]]
local function add_journal_row(
    definition: any,
    order: number
)
    local state = active_state(definition.Id)
    if not state then
        return
    end

    local selected =
        selected_journal_quest_id == definition.Id
    local tracked = is_tracked(definition.Id)
    local row = UiComponents.button(
        journal_list,
        definition.Id,
        "",
        if selected then "Primary" else "Ghost"
    )
    row.LayoutOrder = order
    row.Size = UDim2.new(1, 0, 0, JOURNAL_ROW_HEIGHT)
    row.Text = ""

    local marker = Instance.new("Frame")
    marker.Name = "QuestMarker"
    marker.AnchorPoint = Vector2.new(0.5, 0.5)
    marker.Position = UDim2.fromOffset(22, 31)
    marker.Size = UDim2.fromOffset(16, 16)
    marker.BackgroundColor3 = if tracked
        then UiTheme.PALETTE.Accent
        else UiTheme.PALETTE.AccentDark
    marker.BorderSizePixel = 0
    marker.Rotation = 45
    marker.Parent = row
    UiTheme.add_stroke(
        marker,
        UiTheme.PALETTE.AccentBright,
        if tracked then 0.05 else 0.28
    )

    local title = UiComponents.label(
        row,
        "QuestName",
        tostring(definition.DisplayName or definition.Id),
        "Heading"
    )
    title.Position = UDim2.fromOffset(42, 8)
    title.Size = UDim2.new(1, -52, 0, 24)
    title.TextSize = 15
    title.TextColor3 = if tracked
        then UiTheme.PALETTE.AccentBright
        else UiTheme.PALETTE.Text

    local location_text, depth_text = quest_location_text(
        definition,
        state
    )
    local subtitle = UiComponents.label(
        row,
        "QuestMeta",
        string.format(
            "Lv. %d  •  %s  •  %s",
            tonumber(definition.MinimumLevel) or 1,
            location_text,
            depth_text
        ),
        "Muted"
    )
    subtitle.Position = UDim2.fromOffset(42, 35)
    subtitle.Size = UDim2.new(1, -52, 0, 22)
    subtitle.TextSize = 10
    subtitle.TextTruncate = Enum.TextTruncate.AtEnd

    row.Activated:Connect(function()
        selected_journal_quest_id = definition.Id
        render_journal()
    end)
end

--[[
Renders the master/detail Quest Journal.

Args:
    None.

Returns:
    None.
]]
render_journal = function()
    clear_generated_rows(
        journal_list,
        {journal_padding, journal_layout}
    )

    local definitions = active_definitions()

    if #definitions == 0 then
        selected_journal_quest_id = nil
        journal_status.Text =
            "You do not currently have any accepted Adventure quests."
        detail_title.Text = "No active quests"
        detail_meta.Text = ""
        location_name.Text = "Adventure"
        location_depth.Text = ""
        detail_story.Text =
            "Accepted Adventure quests will appear here."
        detail_reward.Text = ""
        detail_ready.Text = ""
        clear_detail_objectives()
        detail_track.Text = "Track Quest"
        UiTheme.set_button_enabled(detail_track, false)
        return
    end

    local selection_valid = false
    for _, definition in ipairs(definitions) do
        if definition.Id == selected_journal_quest_id then
            selection_valid = true
            break
        end
    end

    if not selection_valid then
        local tracked_id = type(latest) == "table"
            and type(latest.State) == "table"
            and latest.State.TrackedQuestId
            or nil
        selected_journal_quest_id =
            if type(tracked_id) == "string"
                then tracked_id
                else definitions[1].Id
    end

    journal_status.Text = string.format(
        "%d active quest%s",
        #definitions,
        if #definitions == 1 then "" else "s"
    )

    local selected_definition = nil
    for index, definition in ipairs(definitions) do
        add_journal_row(definition, index)
        if definition.Id == selected_journal_quest_id then
            selected_definition = definition
        end
    end

    if selected_definition then
        render_journal_detail(selected_definition)
    end
end

detail_track.Activated:Connect(function()
    if type(selected_journal_quest_id) ~= "string"
        or is_tracked(selected_journal_quest_id)
    then
        return
    end

    request_track(selected_journal_quest_id)
end)

--[[
Ensures legacy active quests obtain one tracked selection.

Args:
    None.

Returns:
    nil: Sends at most one automatic Track request per missing selection.
]]
local function ensure_tracked_selection()
    if type(latest) ~= "table"
        or type(latest.State) ~= "table"
        or latest.State.TrackedQuestId ~= nil
        or auto_track_requested
    then
        return
    end

    local definitions = active_definitions()
    if #definitions == 0 then
        return
    end

    auto_track_requested = true
    request_track(definitions[1].Id)
end

--[[
Applies one authoritative quest snapshot to all quest presentation.

Args:
    payload (any): QuestSnapshot remote payload.

Returns:
    nil: Stores and renders valid server-owned state.
]]
local function apply_snapshot(payload: any)
    if type(payload) ~= "table"
        or type(payload.Definitions) ~= "table"
        or type(payload.State) ~= "table"
        or payload.State.ok ~= true
    then
        return
    end

    latest = payload

    if payload.State.TrackedQuestId ~= nil then
        auto_track_requested = false
    end

    ensure_tracked_selection()
    render_tracker()
    render_journal()
    update_base_guidance()
end

--[[
Applies Quest Journal managed visibility.

Args:
    visible (boolean): Whether the journal should be open.

Returns:
    nil: Shows or hides the journal modal.
]]
local function set_journal_visible(visible: boolean)
    journal_panel.Visible = visible

    if visible then
        request_snapshot()
    end
end

quest_snapshot.OnClientEvent:Connect(apply_snapshot)

quest_action_result.OnClientEvent:Connect(function(result: any)
    if type(result) == "table" and result.ok == true then
        request_snapshot()
    end
end)

WindowController.register(
    WINDOW_NAME,
    set_journal_visible
)

UiArt.align_close(journal_panel, modal.Close, "Journal")

modal.Close.Activated:Connect(function()
    WindowController.set_visible(WINDOW_NAME, false)
end)

UserInputService.InputBegan:Connect(
    function(input: InputObject, processed: boolean)
        if processed then
            return
        end

        if input.KeyCode == Enum.KeyCode.L then
            WindowController.set_visible(WINDOW_NAME, true)
        end
    end
)

task.spawn(function()
    while gui.Parent do
        request_snapshot()
        task.wait(SNAPSHOT_REFRESH_SECONDS)
    end
end)
