--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local DungeonDefinitions = require(
    shared:WaitForChild("DungeonDefinitions")
)
local DungeonDifficultyDefinitions = require(
    shared:WaitForChild("DungeonDifficultyDefinitions")
)
local UiComponents = require(
    shared:WaitForChild("UiComponents")
)
local UiTheme = require(
    shared:WaitForChild("UiTheme")
)

local entry_request = remotes:WaitForChild(
    "DungeonEntryRequest"
) :: RemoteEvent
local entry_result = remotes:WaitForChild(
    "DungeonEntryResult"
) :: RemoteEvent
local party_request = remotes:WaitForChild(
    "PartyActionRequest"
) :: RemoteEvent
local party_snapshot = remotes:WaitForChild(
    "PartySnapshot"
) :: RemoteEvent
local party_result = remotes:WaitForChild(
    "PartyActionResult"
) :: RemoteEvent

local MAX_ENTRANCE_DISTANCE = 15

local player_gui = player:WaitForChild("PlayerGui")
local old = player_gui:FindFirstChild("BaseUi")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "BaseUi"
gui.ResetOnSpawn = false
gui.DisplayOrder = 160
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
    "DungeonEntryPanel",
    "Dungeon Entrance",
    "Prepare your party before entering.",
    UDim2.fromOffset(920, 650)
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
    1440,
    0.68,
    1
)

local status = UiComponents.label(
    modal.Body,
    "Status",
    "",
    "Muted"
)
status.Size = UDim2.new(1, 0, 0, 26)
status.TextWrapped = true
status.ZIndex = 12

local dungeon_card = Instance.new("Frame")
dungeon_card.Name = "DungeonContext"
dungeon_card.Position = UDim2.fromOffset(0, 38)
dungeon_card.Size = UDim2.new(1, 0, 0, 74)
dungeon_card.BackgroundColor3 = UiTheme.PALETTE.SurfaceRaised
dungeon_card.BackgroundTransparency = 0.05
dungeon_card.BorderSizePixel = 0
dungeon_card.ZIndex = 12
UiTheme.add_corner(dungeon_card, 8)
UiTheme.add_stroke(
    dungeon_card,
    UiTheme.PALETTE.BorderSoft,
    0.42
)
dungeon_card.Parent = modal.Body

local dungeon_name = UiComponents.label(
    dungeon_card,
    "DungeonName",
    "Dungeon",
    "Heading"
)
dungeon_name.Position = UDim2.fromOffset(16, 10)
dungeon_name.Size = UDim2.new(0.58, -16, 0, 26)
dungeon_name.TextSize = 19
dungeon_name.ZIndex = 13

local dungeon_detail = UiComponents.label(
    dungeon_card,
    "DungeonDetail",
    "",
    "Muted"
)
dungeon_detail.Position = UDim2.fromOffset(16, 39)
dungeon_detail.Size = UDim2.new(0.58, -16, 0, 22)
dungeon_detail.ZIndex = 13

local entrance_hint = UiComponents.label(
    dungeon_card,
    "EntranceHint",
    "Entrance-bound instance",
    "Caption"
)
entrance_hint.AnchorPoint = Vector2.new(1, 0.5)
entrance_hint.Position = UDim2.new(1, -16, 0.5, 0)
entrance_hint.Size = UDim2.new(0.36, 0, 0, 24)
entrance_hint.TextXAlignment = Enum.TextXAlignment.Right
entrance_hint.TextColor3 = UiTheme.PALETTE.Accent
entrance_hint.ZIndex = 13

local difficulty_heading = UiComponents.section_heading(
    modal.Body,
    "DIFFICULTY"
)
difficulty_heading.Position = UDim2.fromOffset(0, 124)
difficulty_heading.Size = UDim2.new(1, 0, 0, 18)
difficulty_heading.ZIndex = 12

local difficulty_strip = Instance.new("Frame")
difficulty_strip.Name = "DifficultyStrip"
difficulty_strip.Position = UDim2.fromOffset(0, 148)
difficulty_strip.Size = UDim2.new(1, 0, 0, 72)
difficulty_strip.BackgroundTransparency = 1
difficulty_strip.ZIndex = 12
difficulty_strip.Parent = modal.Body

local difficulty_layout = Instance.new("UIListLayout")
difficulty_layout.FillDirection = Enum.FillDirection.Horizontal
difficulty_layout.Padding = UDim.new(0, 8)
difficulty_layout.SortOrder = Enum.SortOrder.LayoutOrder
difficulty_layout.Parent = difficulty_strip

local action_bar = Instance.new("Frame")
action_bar.Name = "ActionBar"
action_bar.Position = UDim2.fromOffset(0, 232)
action_bar.Size = UDim2.new(1, 0, 0, 44)
action_bar.BackgroundTransparency = 1
action_bar.ZIndex = 12
action_bar.Parent = modal.Body

local create_button = UiComponents.button(
    action_bar,
    "CreateParty",
    "Create Party",
    "Secondary"
)
create_button.Size = UDim2.fromOffset(132, 40)
create_button.ZIndex = 13

local ready_button = UiComponents.button(
    action_bar,
    "Ready",
    "Ready",
    "Secondary"
)
ready_button.Position = UDim2.fromOffset(140, 0)
ready_button.Size = UDim2.fromOffset(112, 40)
ready_button.ZIndex = 13

local leave_button = UiComponents.button(
    action_bar,
    "LeaveParty",
    "Leave Party",
    "Danger"
)
leave_button.Position = UDim2.fromOffset(260, 0)
leave_button.Size = UDim2.fromOffset(122, 40)
leave_button.ZIndex = 13

local refresh_button = UiComponents.button(
    action_bar,
    "Refresh",
    "Refresh",
    "Ghost"
)
refresh_button.Position = UDim2.fromOffset(390, 0)
refresh_button.Size = UDim2.fromOffset(104, 40)
refresh_button.ZIndex = 13

local start_button = UiComponents.button(
    action_bar,
    "Start",
    "Enter Dungeon",
    "Primary"
)
start_button.AnchorPoint = Vector2.new(1, 0)
start_button.Position = UDim2.fromScale(1, 0)
start_button.Size = UDim2.fromOffset(210, 40)
start_button.ZIndex = 13

local columns = Instance.new("Frame")
columns.Name = "PartyColumns"
columns.Position = UDim2.fromOffset(0, 292)
columns.Size = UDim2.new(1, 0, 1, -292)
columns.BackgroundTransparency = 1
columns.ZIndex = 12
columns.Parent = modal.Body

local party_column = Instance.new("Frame")
party_column.Name = "PartyColumn"
party_column.Size = UDim2.new(0.48, -6, 1, 0)
party_column.BackgroundTransparency = 1
party_column.ZIndex = 12
party_column.Parent = columns

local invite_column = Instance.new("Frame")
invite_column.Name = "InviteColumn"
invite_column.AnchorPoint = Vector2.new(1, 0)
invite_column.Position = UDim2.fromScale(1, 0)
invite_column.Size = UDim2.new(0.52, -6, 1, 0)
invite_column.BackgroundTransparency = 1
invite_column.ZIndex = 12
invite_column.Parent = columns

local party_header = UiComponents.section_heading(
    party_column,
    "PARTY"
)
party_header.Size = UDim2.new(1, 0, 0, 20)
party_header.ZIndex = 13

local party_list = Instance.new("ScrollingFrame")
party_list.Name = "PartyList"
party_list.Position = UDim2.fromOffset(0, 28)
party_list.Size = UDim2.new(1, 0, 1, -28)
party_list.AutomaticCanvasSize = Enum.AutomaticSize.Y
party_list.CanvasSize = UDim2.new()
party_list.ZIndex = 13
UiTheme.style_scroll(party_list)
party_list.Parent = party_column

local party_layout = Instance.new("UIListLayout")
party_layout.Padding = UDim.new(0, 7)
party_layout.Parent = party_list

local invite_header = UiComponents.section_heading(
    invite_column,
    "PLAYERS & INVITES"
)
invite_header.Size = UDim2.new(1, 0, 0, 20)
invite_header.ZIndex = 13

local invite_banner = Instance.new("Frame")
invite_banner.Name = "InviteBanner"
invite_banner.Position = UDim2.fromOffset(0, 28)
invite_banner.Size = UDim2.new(1, 0, 0, 58)
invite_banner.BackgroundColor3 = UiTheme.PALETTE.AccentDark
invite_banner.BackgroundTransparency = 0.35
invite_banner.BorderSizePixel = 0
invite_banner.Visible = false
invite_banner.ZIndex = 13
UiTheme.add_corner(invite_banner, 7)
UiTheme.add_stroke(
    invite_banner,
    UiTheme.PALETTE.Accent,
    0.4
)
invite_banner.Parent = invite_column

local invite_text = UiComponents.label(
    invite_banner,
    "InviteText",
    "",
    "Body"
)
invite_text.Position = UDim2.fromOffset(12, 5)
invite_text.Size = UDim2.new(1, -176, 1, -10)
invite_text.TextWrapped = true
invite_text.ZIndex = 14

local accept_button = UiComponents.button(
    invite_banner,
    "Accept",
    "Accept",
    "Primary"
)
accept_button.AnchorPoint = Vector2.new(1, 0.5)
accept_button.Position = UDim2.new(1, -76, 0.5, 0)
accept_button.Size = UDim2.fromOffset(70, 36)
accept_button.ZIndex = 14

local decline_button = UiComponents.button(
    invite_banner,
    "Decline",
    "X",
    "Danger"
)
decline_button.AnchorPoint = Vector2.new(1, 0.5)
decline_button.Position = UDim2.new(1, -8, 0.5, 0)
decline_button.Size = UDim2.fromOffset(58, 36)
decline_button.ZIndex = 14

local invite_list = Instance.new("ScrollingFrame")
invite_list.Name = "InviteList"
invite_list.Position = UDim2.fromOffset(0, 94)
invite_list.Size = UDim2.new(1, 0, 1, -94)
invite_list.AutomaticCanvasSize = Enum.AutomaticSize.Y
invite_list.CanvasSize = UDim2.new()
invite_list.ZIndex = 13
UiTheme.style_scroll(invite_list)
invite_list.Parent = invite_column

local invite_layout = Instance.new("UIListLayout")
invite_layout.Padding = UDim.new(0, 7)
invite_layout.Parent = invite_list

local snapshot: any = nil
local entrance_dungeon_id: string? = nil
local entrance_anchor: BasePart? = nil
local solo_difficulty_id: string? = nil
local difficulty_buttons: {[string]: TextButton} = {}
local prompt_connections: {[ProximityPrompt]: RBXScriptConnection} = {}
local distance_elapsed = 0

--[[
Sends one party action using the existing party protocol.

Args:
    action (string): Party action name.
    extra (any?): Additional payload fields.

Returns:
    None.
]]
local function fire(action: string, extra: any?)
    local payload = extra or {}
    payload.Action = action
    party_request:FireServer(payload)
end

--[[
Returns the current party from the latest snapshot.

Args:
    None.

Returns:
    any?: Current party state.
]]
local function current_party(): any?
    return snapshot and snapshot.Party or nil
end

--[[
Returns the local player's party-member state.

Args:
    party (any?): Current party state.

Returns:
    any?: Local member state.
]]
local function current_member(party: any?): any?
    if not party then
        return nil
    end

    for _, member in ipairs(party.Members or {}) do
        if member.UserId == player.UserId then
            return member
        end
    end

    return nil
end

--[[
Returns the dungeon selected for the current entry context.

Args:
    None.

Returns:
    string?: Dungeon ID selected by party or entrance.
]]
local function selected_dungeon(): string?
    if entrance_dungeon_id then
        return entrance_dungeon_id
    end

    local party = current_party()
    if party and type(party.SelectedDungeonId) == "string" then
        return party.SelectedDungeonId
    end

    return nil
end

--[[
Returns the difficulty selected for the current entry context.

Args:
    None.

Returns:
    string?: Difficulty ID selected by party or solo player.
]]
local function selected_difficulty(): string?
    local party = current_party()

    if party
        and type(party.SelectedDifficultyId) == "string" then
        return party.SelectedDifficultyId
    end

    return solo_difficulty_id
end

--[[
Refreshes visual selection state on all released difficulty buttons.

Args:
    dungeon_id (string): Active dungeon ID.
    selected_id (string?): Selected difficulty ID.

Returns:
    None.
]]
local function style_difficulty_buttons(
    dungeon_id: string,
    selected_id: string?
)
    for difficulty_id, button in pairs(
        difficulty_buttons
    ) do
        local difficulty =
            DungeonDifficultyDefinitions.get(
                dungeon_id,
                difficulty_id
            )
        local released = difficulty
            and difficulty.RuntimeReleaseEnabled == true

        if released then
            local selected = difficulty_id == selected_id
            button.BackgroundColor3 = if selected
                then UiTheme.PALETTE.AccentDark
                else UiTheme.PALETTE.SurfaceRaised

            UiTheme.add_stroke(
                button,
                if selected
                    then UiTheme.PALETTE.Accent
                    else UiTheme.PALETTE.BorderSoft,
                if selected then 0.15 else 0.5
            )
        end
    end
end

--[[
Removes generated rows while preserving their layout object.

Args:
    container (Instance): Scrolling region to clear.
    layout_object (UIListLayout): Layout object to preserve.

Returns:
    None.
]]
local function clear_generated(
    container: Instance,
    layout_object: UIListLayout
)
    for _, child in ipairs(container:GetChildren()) do
        if child ~= layout_object
            and child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

--[[
Returns a compact summary for one dungeon difficulty.

Args:
    definition (any): Difficulty definition.

Returns:
    string: Room count and scaling summary.
]]
local function difficulty_summary(definition: any): string
    local rooms = #(definition.EncounterSequence or {})

    return string.format(
        "%d rooms  |  %.2fx HP  |  %.2fx DMG",
        rooms,
        tonumber(definition.EnemyHealthMultiplier) or 1,
        tonumber(definition.EnemyDamageMultiplier) or 1
    )
end

--[[
Rebuilds difficulty buttons for the active entrance dungeon.

Args:
    dungeon_id (string): Active dungeon ID.

Returns:
    None.
]]
local function build_difficulty_buttons(dungeon_id: string)
    for _, child in ipairs(difficulty_strip:GetChildren()) do
        if child ~= difficulty_layout
            and child:IsA("GuiObject") then
            child:Destroy()
        end
    end

    table.clear(difficulty_buttons)

    for _, definition in ipairs(
        DungeonDifficultyDefinitions.ordered(dungeon_id)
    ) do
        local button = UiComponents.button(
            difficulty_strip,
            definition.Id,
            definition.DisplayName
                .. "\n"
                .. difficulty_summary(definition),
            "Secondary"
        )

        button.LayoutOrder = definition.Order
        button.Size = UDim2.new(0.25, -6, 1, 0)
        button.TextWrapped = true
        button.TextSize = 12
        button.ZIndex = 13
        difficulty_buttons[definition.Id] = button

        local released =
            definition.RuntimeReleaseEnabled == true
        UiTheme.set_button_enabled(button, released)

        if not released then
            button.Text = definition.DisplayName
                .. "\nLocked"
        end

        button.Activated:Connect(function()
            if not released then
                return
            end

            local party = current_party()
            if party then
                if party.LeaderUserId ~= player.UserId then
                    status.Text =
                        "Only the party leader can change difficulty."
                    return
                end

                fire(
                    "SelectDifficulty",
                    {DifficultyId = definition.Id}
                )
                return
            end

            solo_difficulty_id = definition.Id
            style_difficulty_buttons(
                dungeon_id,
                solo_difficulty_id
            )
        end)
    end
end

--[[
Creates one party-member row.

Args:
    party (any): Current party state.
    member (any): Party-member snapshot.

Returns:
    None.
]]
local function add_party_row(party: any, member: any)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 54)
    row.BackgroundColor3 = UiTheme.PALETTE.SurfaceRaised
    row.BackgroundTransparency = 0.12
    row.BorderSizePixel = 0
    row.ZIndex = 14
    UiTheme.add_corner(row, 7)
    row.Parent = party_list

    local is_leader = member.UserId == party.LeaderUserId
    local ready = member.Ready == true

    local name = UiComponents.label(
        row,
        "Name",
        tostring(member.DisplayName),
        "Heading"
    )
    name.Position = UDim2.fromOffset(12, 6)
    name.Size = UDim2.new(1, -104, 0, 22)
    name.ZIndex = 15

    local state = UiComponents.label(
        row,
        "State",
        if is_leader
            then "Party Leader"
            elseif ready
                then "Ready"
                else "Not ready",
        "Muted"
    )
    state.Position = UDim2.fromOffset(12, 29)
    state.Size = UDim2.new(1, -104, 0, 18)
    state.TextColor3 = if ready
        then UiTheme.PALETTE.Success
        else UiTheme.PALETTE.TextMuted
    state.ZIndex = 15

    if party.LeaderUserId == player.UserId
        and member.UserId ~= player.UserId then
        local kick = UiComponents.button(
            row,
            "Kick",
            "Kick",
            "Danger"
        )
        kick.AnchorPoint = Vector2.new(1, 0.5)
        kick.Position = UDim2.new(1, -8, 0.5, 0)
        kick.Size = UDim2.fromOffset(72, 34)
        kick.ZIndex = 15

        kick.Activated:Connect(function()
            fire(
                "Kick",
                {TargetUserId = member.UserId}
            )
        end)
    end
end

--[[
Creates one available-player row.

Args:
    candidate (any): Available-player snapshot.
    can_invite (boolean): Whether the local player may invite.

Returns:
    None.
]]
local function add_invite_row(
    candidate: any,
    can_invite: boolean
)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -8, 0, 50)
    row.BackgroundColor3 = UiTheme.PALETTE.SurfaceRaised
    row.BackgroundTransparency = 0.12
    row.BorderSizePixel = 0
    row.ZIndex = 14
    UiTheme.add_corner(row, 7)
    row.Parent = invite_list

    local name = UiComponents.label(
        row,
        "Name",
        tostring(candidate.DisplayName),
        "Body"
    )
    name.Position = UDim2.fromOffset(12, 5)
    name.Size = UDim2.new(1, -102, 0, 21)
    name.ZIndex = 15

    local username = UiComponents.label(
        row,
        "Username",
        "@" .. tostring(candidate.Name),
        "Caption"
    )
    username.Position = UDim2.fromOffset(12, 27)
    username.Size = UDim2.new(1, -102, 0, 16)
    username.ZIndex = 15

    local invite = UiComponents.button(
        row,
        "Invite",
        if can_invite then "Invite" else "Full",
        "Secondary"
    )
    invite.AnchorPoint = Vector2.new(1, 0.5)
    invite.Position = UDim2.new(1, -8, 0.5, 0)
    invite.Size = UDim2.fromOffset(76, 34)
    invite.ZIndex = 15
    UiTheme.set_button_enabled(invite, can_invite)

    if can_invite then
        invite.Activated:Connect(function()
            fire(
                "Invite",
                {TargetUserId = candidate.UserId}
            )
        end)
    end
end

--[[
Refreshes dungeon, difficulty, party and invite presentation.

Args:
    None.

Returns:
    None.
]]
local function render()
    local party = current_party()
    local invite = snapshot and snapshot.Invite or nil
    local dungeon_id = selected_dungeon()

    if not dungeon_id then
        return
    end

    local definition = DungeonDefinitions.get(dungeon_id)
    dungeon_name.Text = if definition
        then tostring(definition.DisplayName)
        else dungeon_id
    dungeon_detail.Text = if definition
        then string.format(
            "%d-%d players  |  Instanced dungeon",
            tonumber(definition.MinPlayers) or 1,
            tonumber(definition.MaxPlayers) or 4
        )
        else "Instanced dungeon"

    if next(difficulty_buttons) == nil
        or not difficulty_buttons[
            selected_difficulty() or ""
        ] then
        build_difficulty_buttons(dungeon_id)
    end

    local difficulty_id = selected_difficulty()
    style_difficulty_buttons(
        dungeon_id,
        difficulty_id
    )

    local difficulty =
        if difficulty_id
            then DungeonDifficultyDefinitions.get(
                dungeon_id,
                difficulty_id
            )
            else nil
    local difficulty_released = difficulty
        and difficulty.RuntimeReleaseEnabled == true

    create_button.Visible = party == nil
    leave_button.Visible = party ~= nil
    ready_button.Visible = party ~= nil
        and #(party.Members or {}) > 1

    local me = current_member(party)
    if me then
        ready_button.Text = if me.Ready
            then "Unready"
            else "Ready"
    end

    invite_banner.Visible = invite ~= nil
    if invite then
        invite_text.Text = "Invite from "
            .. tostring(invite.InviterName)
    end

    if party then
        local leader = party.LeaderUserId == player.UserId
        local entrance_matches =
            party.SelectedDungeonId == dungeon_id

        party_header.Text = string.format(
            "PARTY  -  %d / 4  -  %s",
            #(party.Members or {}),
            if leader
                then "YOU ARE LEADER"
                else "MEMBER"
        )
        start_button.Text = if #(party.Members or {}) > 1
            then "Start Party Dungeon"
            else "Enter Dungeon"

        UiTheme.set_button_enabled(
            start_button,
            leader
                and entrance_matches
                and difficulty_released == true
        )

        if not entrance_matches and not leader then
            status.Text =
                "This entrance does not match the party selection."
        end
    else
        party_header.Text = "PARTY  -  SOLO ENTRY AVAILABLE"
        start_button.Text = "Enter Dungeon Solo"
        UiTheme.set_button_enabled(
            start_button,
            difficulty_released == true
        )
    end

    clear_generated(party_list, party_layout)
    if party then
        for _, member in ipairs(party.Members or {}) do
            add_party_row(party, member)
        end
    else
        local empty = UiComponents.label(
            party_list,
            "Empty",
            "Create a party to invite players, "
                .. "or enter this dungeon solo.",
            "Muted"
        )
        empty.Size = UDim2.new(1, -8, 0, 70)
        empty.TextWrapped = true
        empty.TextXAlignment = Enum.TextXAlignment.Center
        empty.ZIndex = 14
    end

    clear_generated(invite_list, invite_layout)
    local can_invite = party
        and party.LeaderUserId == player.UserId
        and #party.Members < 4

    for _, candidate in ipairs(
        (snapshot and snapshot.AvailablePlayers) or {}
    ) do
        add_invite_row(
            candidate,
            can_invite == true
        )
    end
end

--[[
Shows or hides the entrance-bound dungeon panel.

Args:
    visible (boolean): Desired panel visibility.

Returns:
    None.
]]
local function set_visible(visible: boolean)
    panel.Visible = visible
    backdrop.Visible = visible

    if visible then
        fire("RequestSnapshot")
    else
        entrance_anchor = nil
        entrance_dungeon_id = nil
        solo_difficulty_id = nil
    end
end

--[[
Synchronises a leader-owned party to the active physical entrance.

Args:
    None.

Returns:
    None.
]]
local function sync_party_to_entrance()
    local party = current_party()
    if not party or not entrance_dungeon_id then
        return
    end

    if party.LeaderUserId == player.UserId
        and party.SelectedDungeonId
            ~= entrance_dungeon_id then
        fire(
            "SelectDungeon",
            {DungeonId = entrance_dungeon_id}
        )
    end
end

--[[
Opens the panel for one physical dungeon entrance.

Args:
    anchor (BasePart): World anchor containing the entrance prompt.
    dungeon_id (string): Dungeon represented by that entrance.

Returns:
    None.
]]
local function open_from_entrance(
    anchor: BasePart,
    dungeon_id: string
)
    local definition = DungeonDefinitions.get(dungeon_id)
    if not definition then
        return
    end

    entrance_anchor = anchor
    entrance_dungeon_id = dungeon_id
    solo_difficulty_id =
        DungeonDifficultyDefinitions.default_id(dungeon_id)

    table.clear(difficulty_buttons)
    build_difficulty_buttons(dungeon_id)

    sync_party_to_entrance()

    status.Text = "Choose a difficulty and prepare your party."
    set_visible(true)
    render()
end

--[[
Binds one world DungeonEntryPrompt to the contextual panel.

Args:
    prompt (ProximityPrompt): Dungeon entrance prompt to bind.

Returns:
    None.
]]
local function bind_entrance_prompt(prompt: ProximityPrompt)
    if prompt_connections[prompt] then
        return
    end

    local parent = prompt.Parent
    if not parent or not parent:IsA("BasePart") then
        return
    end

    prompt_connections[prompt] = prompt.Triggered:Connect(
        function()
            local dungeon_id = parent:GetAttribute("DungeonId")
            if type(dungeon_id) == "string" then
                open_from_entrance(parent, dungeon_id)
            end
        end
    )
end

--[[
Checks a workspace descendant for a dungeon entrance prompt.

Args:
    descendant (Instance): Workspace descendant to inspect.

Returns:
    None.
]]
local function try_bind_entrance(descendant: Instance)
    if descendant:IsA("ProximityPrompt")
        and descendant.Name == "DungeonEntryPrompt" then
        bind_entrance_prompt(descendant)
    end
end

--[[
Closes the dungeon panel when the player walks away.

Args:
    delta (number): Heartbeat delta time.

Returns:
    None.
]]
local function update_entrance_distance(delta: number)
    if not panel.Visible or not entrance_anchor then
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
        set_visible(false)
        return
    end

    local distance =
        (root.Position - entrance_anchor.Position).Magnitude

    if distance > MAX_ENTRANCE_DISTANCE then
        set_visible(false)
    end
end

create_button.Activated:Connect(function()
    fire("Create")
end)

leave_button.Activated:Connect(function()
    fire("Leave")
end)

refresh_button.Activated:Connect(function()
    fire("RequestSnapshot")
end)

accept_button.Activated:Connect(function()
    fire("AcceptInvite")
end)

decline_button.Activated:Connect(function()
    fire("DeclineInvite")
end)

ready_button.Activated:Connect(function()
    local me = current_member(current_party())

    fire(
        "SetReady",
        {Ready = not (me and me.Ready == true)}
    )
end)

start_button.Activated:Connect(function()
    local dungeon_id = selected_dungeon()
    local difficulty_id = selected_difficulty()
    if not dungeon_id or not difficulty_id then
        status.Text = "Dungeon entry context is unavailable."
        return
    end

    local party = current_party()
    if party and #party.Members > 1 then
        if party.LeaderUserId ~= player.UserId then
            status.Text =
                "Only the party leader can start the dungeon."
            return
        end

        fire("StartEntry")
        return
    end

    entry_request:FireServer({
        DungeonId = dungeon_id,
        DifficultyId = difficulty_id,
    })
end)

modal.Close.Activated:Connect(function()
    set_visible(false)
end)

backdrop.Activated:Connect(function()
    set_visible(false)
end)

party_snapshot.OnClientEvent:Connect(
    function(next_snapshot: any)
        snapshot = next_snapshot
        if panel.Visible then
            sync_party_to_entrance()
            render()
        end
    end
)

party_result.OnClientEvent:Connect(function(result: any)
    if result.ok then
        status.Text = tostring(result.Action)
            .. " succeeded."
    else
        local member = if result.MemberName
            then "  -  " .. tostring(result.MemberName)
            else ""

        status.Text = tostring(result.Action)
            .. " blocked: "
            .. tostring(result.reason)
            .. member
    end
end)

entry_result.OnClientEvent:Connect(function(result: any)
    if result.ok
        and result.reason == "StudioPartyEntryProof" then
        status.Text =
            "Studio party entry proof passed for "
            .. tostring(result.DungeonId)
    elseif result.ok then
        status.Text = "Entering dungeon..."
    elseif result.reason == "DifficultyLocked"
        and type(result.MemberUserId) == "number"
    then
        local member_name = result.MemberName
            or ("Player " .. tostring(result.MemberUserId))
        status.Text = tostring(member_name)
            .. " has not unlocked "
            .. tostring(result.DifficultyId or "this difficulty")
            .. ". Every party member must clear the previous difficulty."
    else
        status.Text = "Entry blocked: "
            .. tostring(result.reason)
    end
end)

for _, descendant in ipairs(Workspace:GetDescendants()) do
    try_bind_entrance(descendant)
end

Workspace.DescendantAdded:Connect(try_bind_entrance)
RunService.Heartbeat:Connect(update_entrance_distance)
fire("RequestSnapshot")
