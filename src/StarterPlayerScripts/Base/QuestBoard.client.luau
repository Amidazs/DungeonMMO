--!strict
-- Contextual Base Adventure Board backed by server-owned quest state.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local EnvironmentAnchorClient = require(
    shared:WaitForChild("EnvironmentAnchorClient")
)
local ItemDefinitions = require(
    shared:WaitForChild("ItemDefinitions")
)
local UiComponents = require(
    shared:WaitForChild("UiComponents")
)
local UiTheme = require(
    shared:WaitForChild("UiTheme")
)
local WindowController = require(
    script.Parent.Parent:WaitForChild("Core")
        :WaitForChild("HudWindowController")
)

local action_request = remotes:WaitForChild(
    "QuestActionRequest"
) :: RemoteEvent
local action_result = remotes:WaitForChild(
    "QuestActionResult"
) :: RemoteEvent
local snapshot_remote = remotes:WaitForChild(
    "QuestSnapshot"
) :: RemoteEvent

local WINDOW_NAME = "QuestBoard"
local ACCESS_DISTANCE = 15

local player_gui = player:WaitForChild("PlayerGui")
local old = player_gui:FindFirstChild("QuestBoard")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "QuestBoard"
gui.ResetOnSpawn = false
gui.DisplayOrder = 186
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player_gui

local modal = UiComponents.modal(
    gui,
    "AdventureBoard",
    "Adventure Board",
    "Take one-time contracts and claim server-authorized rewards.",
    UDim2.fromOffset(760, 560)
)
local panel = modal.Root
panel.Visible = false
UiTheme.bind_responsive_scale(
    panel,
    1366,
    0.70,
    1
)

local list = Instance.new("ScrollingFrame")
list.Name = "QuestList"
list.Size = UDim2.new(1, 0, 1, -58)
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
UiTheme.style_scroll(list)
list.Parent = modal.Body

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 6)
padding.PaddingBottom = UDim.new(0, 6)
padding.PaddingLeft = UDim.new(0, 6)
padding.PaddingRight = UDim.new(0, 6)
padding.Parent = list

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local status = UiComponents.label(
    modal.Body,
    "Status",
    "Interact with the Adventure Board to view quests.",
    "Muted"
)
status.AnchorPoint = Vector2.new(0, 1)
status.Position = UDim2.new(0, 0, 1, 0)
status.Size = UDim2.new(1, 0, 0, 44)
status.TextWrapped = true

local latest: any = nil
local board_anchor: BasePart? = nil
local distance_elapsed = 0
local pending_quest_id: string? = nil

--[[
Returns a readable item name from the shared item catalogue.

Args:
    item_id (string): Stable inventory item identifier.

Returns:
    string: Display name when known, otherwise the identifier.
]]
local function item_name(item_id: string): string
    local definition = ItemDefinitions.get(item_id)

    return if definition
        then tostring(definition.Name)
        else item_id
end

--[[
Normalizes one public quest reward into readable item fragments.

Args:
    reward (any): Public server-defined quest reward.

Returns:
    {string}: Ordered item-and-quantity labels.
]]
local function reward_items(reward: any): {string}
    local result = {}

    if type(reward) ~= "table" then
        return result
    end

    if type(reward.Items) == "table" then
        for _, item in ipairs(reward.Items) do
            if type(item) == "table"
                and type(item.ItemId) == "string"
            then
                table.insert(
                    result,
                    string.format(
                        "%dx %s",
                        math.max(
                            1,
                            math.floor(
                                tonumber(item.Quantity) or 1
                            )
                        ),
                        item_name(item.ItemId)
                    )
                )
            end
        end
        return result
    end

    if type(reward.ItemId) == "string" then
        table.insert(
            result,
            string.format(
                "%dx %s",
                math.max(
                    1,
                    math.floor(
                        tonumber(reward.Quantity) or 1
                    )
                ),
                item_name(reward.ItemId)
            )
        )
    end

    return result
end

--[[
Builds one compact reward summary for a quest card.

Args:
    reward (any): Public server-defined quest reward.

Returns:
    string: Gold and item reward description.
]]
local function reward_text(reward: any): string
    if type(reward) ~= "table" then
        return "Reward: none"
    end

    local pieces = {}
    local gold = math.max(
        0,
        math.floor(tonumber(reward.Gold) or 0)
    )

    if gold > 0 then
        table.insert(pieces, tostring(gold) .. " Gold")
    end

    for _, item in ipairs(reward_items(reward)) do
        table.insert(pieces, item)
    end

    return "Reward: " .. table.concat(pieces, "  •  ")
end

--[[
Returns a readable label for one current Adventure objective.

Args:
    objective (any): Public server-defined objective.

Returns:
    string: Short objective label for the quest card.
]]
local function objective_label(objective: any): string
    if type(objective) ~= "table" then
        return "Objective"
    end

    if objective.Type == "DungeonClear" then
        if objective.TargetId == "TestDungeon" then
            return "Clear the Temple"
        elseif objective.TargetId == "AbandonedMine" then
            return "Clear the Abandoned Mine"
        end
    elseif objective.Type == "CheckpointReached" then
        if objective.TargetId
            == "TestDungeon:EncounterStart:CombatRoom2"
        then
            return "Reach the Temple's inner approach"
        elseif objective.TargetId
            == "AbandonedMine:EncounterStart:CombatRoom2"
        then
            return "Reach the Mine's lower works"
        end
    elseif objective.Type == "EnemyDefeat" then
        if objective.TargetId == "forest_wolf" then
            return "Defeat Forest Wolves"
        elseif objective.TargetId == "marauder_captain" then
            return "Defeat the Marauder Captain"
        elseif objective.TargetId == "corrupted_foreman" then
            return "Defeat the Corrupted Foreman"
        end
    elseif objective.Type == "WorldInteraction" then
        if objective.TargetId == "TestDungeon:HiddenPanel:Room2" then
            return "Activate the faded Temple panel"
        end
    elseif objective.Type == "ItemCollected" then
        if objective.TargetId == "hidden_ward_fragment" then
            return "Collect the Hidden Ward Fragment"
        end
    end

    return tostring(
        objective.Id or objective.Type or "Objective"
    )
end

--[[
Builds the current objective progress text for one quest.

Args:
    definition (any): Public quest definition.
    state (any): Persisted active quest state, if any.

Returns:
    string: Objective progress joined into one readable line.
]]
local function objective_text(
    definition: any,
    state: any
): string
    local pieces = {}
    local progress = type(state) == "table"
        and state.Objectives
        or {}

    for _, objective in ipairs(definition.Objectives or {}) do
        local required = math.max(
            1,
            math.floor(tonumber(objective.Required) or 1)
        )
        local current = math.max(
            0,
            math.floor(
                tonumber(
                    type(progress) == "table"
                        and progress[objective.Id]
                        or 0
                ) or 0
            )
        )

        table.insert(
            pieces,
            string.format(
                "%s %d/%d",
                objective_label(objective),
                current,
                required
            )
        )
    end

    return table.concat(pieces, "  •  ")
end

--[[
Removes previously rendered quest cards.

Args:
    None.

Returns:
    None.
]]
local function clear_rows()
    for _, child in ipairs(list:GetChildren()) do
        if child ~= padding
            and child ~= layout
            and child:IsA("GuiObject")
        then
            child:Destroy()
        end
    end
end

--[[
Returns the current action state for one Adventure definition.

Args:
    definition (any): Public quest definition.

Returns:
    (string, boolean): Button text and whether it may be pressed.
]]
local function action_state(
    definition: any
): (string, boolean)
    local state = latest and latest.State
    local completed = state
        and type(state.Completed) == "table"
        and state.Completed[definition.Id] == true

    if completed then
        return "Completed", false
    end

    local active = state
        and type(state.Active) == "table"
        and state.Active[definition.Id]

    if type(active) == "table" then
        if active.Ready == true then
            return "Claim Reward", true
        end
        return "In Progress", false
    end

    local prerequisite = definition.PrerequisiteQuestId
    if type(prerequisite) == "string"
        and (
            not state
            or type(state.Completed) ~= "table"
            or state.Completed[prerequisite] ~= true
        )
    then
        return "Locked", false
    end

    return "Start Quest", true
end

--[[
Sends one Start or Claim request for a known Adventure quest.

Args:
    definition (any): Public Adventure quest definition.

Returns:
    None.
]]
local function request_action(definition: any)
    if pending_quest_id then
        return
    end

    local state = latest and latest.State
    local active = state
        and type(state.Active) == "table"
        and state.Active[definition.Id]
    local action = if type(active) == "table"
            and active.Ready == true
        then "Claim"
        else "Start"

    pending_quest_id = definition.Id
    status.Text = action
        .. " request sent for "
        .. tostring(definition.DisplayName or definition.Id)
        .. "..."
    action_request:FireServer(action, definition.Id)
end

--[[
Creates the styled shell for one Adventure quest card.

Args:
    definition (any): Public quest definition.
    order (number): Stable catalogue order.

Returns:
    Frame: Card container ready for labels and controls.
]]
local function create_quest_card(
    definition: any,
    order: number
): Frame
    local row = Instance.new("Frame")
    row.Name = tostring(definition.Id)
    row.LayoutOrder = order
    row.Size = UDim2.new(1, 0, 0, 142)
    row.BackgroundColor3 = UiTheme.PALETTE.SurfaceRaised
    row.BackgroundTransparency = 0.08
    row.BorderSizePixel = 0
    UiTheme.add_corner(row, 8)
    UiTheme.add_stroke(
        row,
        UiTheme.PALETTE.BorderSoft,
        0.52
    )
    row.Parent = list
    return row
end

--[[
Adds quest title and minimum-level labels to a card.

Args:
    row (Frame): Quest card container.
    definition (any): Public quest definition.

Returns:
    None.
]]
local function add_quest_header(
    row: Frame,
    definition: any
)
    local name = UiComponents.label(
        row,
        "QuestName",
        tostring(definition.DisplayName or definition.Id),
        "Heading"
    )
    name.Position = UDim2.fromOffset(14, 10)
    name.Size = UDim2.new(1, -174, 0, 24)

    local level = UiComponents.label(
        row,
        "Level",
        "Level "
            .. tostring(
                math.floor(
                    tonumber(definition.MinimumLevel) or 1
                )
            )
            .. "+",
        "Muted"
    )
    level.AnchorPoint = Vector2.new(1, 0)
    level.Position = UDim2.new(1, -14, 0, 10)
    level.Size = UDim2.fromOffset(120, 22)
    level.TextXAlignment = Enum.TextXAlignment.Right
end

--[[
Adds objective and reward text to a quest card.

Args:
    row (Frame): Quest card container.
    definition (any): Public quest definition.
    active (any): Persisted active quest state, if any.

Returns:
    None.
]]
local function add_quest_details(
    row: Frame,
    definition: any,
    active: any
)
    local objective = UiComponents.label(
        row,
        "Objective",
        objective_text(definition, active),
        "Body"
    )
    objective.Position = UDim2.fromOffset(14, 42)
    objective.Size = UDim2.new(1, -170, 0, 38)
    objective.TextWrapped = true
    objective.TextYAlignment = Enum.TextYAlignment.Top

    local reward = UiComponents.label(
        row,
        "Reward",
        reward_text(definition.Reward),
        "Muted"
    )
    reward.Position = UDim2.fromOffset(14, 88)
    reward.Size = UDim2.new(1, -170, 0, 40)
    reward.TextWrapped = true
    reward.TextYAlignment = Enum.TextYAlignment.Top
end

--[[
Adds the current server-state action control to a quest card.

Args:
    row (Frame): Quest card container.
    definition (any): Public quest definition.

Returns:
    None.
]]
local function add_quest_action(
    row: Frame,
    definition: any
)
    local button_text, enabled = action_state(definition)
    local action = UiComponents.button(
        row,
        "Action",
        button_text,
        if enabled then "Primary" else "Ghost"
    )
    action.AnchorPoint = Vector2.new(1, 0.5)
    action.Position = UDim2.new(1, -14, 0.5, 0)
    action.Size = UDim2.fromOffset(138, 46)
    action.Active = enabled
    action.AutoButtonColor = enabled

    if enabled then
        action.Activated:Connect(function()
            request_action(definition)
        end)
    end
end

--[[
Creates one complete Adventure quest card.

Args:
    definition (any): Public quest definition.
    order (number): Stable catalogue order.

Returns:
    None.
]]
local function add_quest_row(
    definition: any,
    order: number
)
    local state = latest and latest.State
    local active = state
        and type(state.Active) == "table"
        and state.Active[definition.Id]
    local row = create_quest_card(definition, order)

    add_quest_header(row, definition)
    add_quest_details(row, definition, active)
    add_quest_action(row, definition)
end

--[[
Renders the latest server quest catalogue and persisted state.

Args:
    None.

Returns:
    None.
]]
local function render()
    if type(latest) ~= "table"
        or type(latest.Definitions) ~= "table"
        or type(latest.State) ~= "table"
    then
        return
    end

    clear_rows()

    for index, definition in ipairs(latest.Definitions) do
        add_quest_row(definition, index)
    end
end

--[[
Requests the latest Adventure catalogue and quest state.

Args:
    None.

Returns:
    None.
]]
local function request_snapshot()
    status.Text = "Loading Adventure Board..."
    action_request:FireServer("Snapshot")
end

--[[
Applies managed Adventure Board visibility.

Args:
    visible (boolean): Whether the contextual window should be shown.

Returns:
    None.
]]
local function set_visible(visible: boolean)
    panel.Visible = visible

    if visible then
        request_snapshot()
    else
        pending_quest_id = nil
    end
end

--[[
Finds the Base board and connects its physical prompt.

Args:
    None.

Returns:
    None.
]]
local function connect_board_prompt()
    board_anchor = EnvironmentAnchorClient.wait_for(
        "Base",
        "Base.DungeonBoard",
        15
    )

    if not board_anchor then
        return
    end

    local prompt = board_anchor:FindFirstChild("QuestBoardPrompt")
    if prompt and prompt:IsA("ProximityPrompt") then
        prompt.Triggered:Connect(function()
            WindowController.set_visible(WINDOW_NAME, true)
        end)
    end
end

--[[
Closes the Adventure Board when the player leaves its world context.

Args:
    delta (number): Heartbeat delta time.

Returns:
    None.
]]
local function update_distance(delta: number)
    if not panel.Visible or not board_anchor then
        return
    end

    distance_elapsed += delta
    if distance_elapsed < 0.25 then
        return
    end
    distance_elapsed = 0

    local character = player.Character
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    if not root or not root:IsA("BasePart") then
        WindowController.set_visible(WINDOW_NAME, false)
        return
    end

    if (
        root.Position - board_anchor.Position
    ).Magnitude > ACCESS_DISTANCE then
        status.Text = "Moved away from Adventure Board."
        WindowController.set_visible(WINDOW_NAME, false)
    end
end

WindowController.register(WINDOW_NAME, set_visible)

modal.Close.Activated:Connect(function()
    WindowController.set_visible(WINDOW_NAME, false)
end)

snapshot_remote.OnClientEvent:Connect(function(payload: any)
    if type(payload) ~= "table"
        or type(payload.State) ~= "table"
        or payload.State.ok ~= true
    then
        status.Text = "Adventure Board unavailable."
        return
    end

    latest = payload
    pending_quest_id = nil
    render()
    status.Text = "Choose an Adventure or claim a completed reward."
end)

action_result.OnClientEvent:Connect(function(response: any)
    if type(response) ~= "table" then
        return
    end

    pending_quest_id = nil

    if response.ok == true then
        status.Text = "Adventure updated."
        return
    end

    local reason = tostring(response.reason or "QuestRejected")
    if reason == "QuestUnavailable" then
        reason = "This Adventure is not available to this character yet."
    elseif reason == "QuestNotReady" then
        reason = "Finish every objective before claiming the reward."
    elseif reason == "QuestRequestCooldown" then
        reason = "Please wait a moment before another board action."
    elseif reason == "QuestAlreadyCompleted" then
        reason = "This Adventure has already been completed."
    end

    status.Text = reason
end)

task.spawn(connect_board_prompt)
RunService.Heartbeat:Connect(update_distance)
