--!strict
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local UiComponents = require(
    shared:WaitForChild("UiComponents")
)
local UiTheme = require(
    shared:WaitForChild("UiTheme")
)

local snapshot_request = remotes:WaitForChild(
    "GuildSnapshotRequest"
) :: RemoteEvent
local snapshot_remote = remotes:WaitForChild(
    "GuildSnapshot"
) :: RemoteEvent
local action_request = remotes:WaitForChild(
    "GuildActionRequest"
) :: RemoteEvent
local action_result = remotes:WaitForChild(
    "GuildActionResult"
) :: RemoteEvent

local WindowController = require(
    script.Parent.Parent:WaitForChild("Core")
        :WaitForChild("HudWindowController")
)

local player_gui = player:WaitForChild("PlayerGui")
local old = player_gui:FindFirstChild("GuildPanel")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "GuildPanel"
gui.ResetOnSpawn = false
gui.DisplayOrder = 180
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player_gui

local modal = UiComponents.modal(
    gui,
    "GuildWindow",
    "Guild",
    "Manage your guild, members and hall.",
    UDim2.fromOffset(720, 600)
)
local panel = modal.Root
panel.Visible = false
UiTheme.bind_responsive_scale(
    panel,
    1366,
    0.35,
    1
)

local status_card = Instance.new("Frame")
status_card.Name = "GuildStatus"
status_card.Size = UDim2.new(1, 0, 0, 84)
status_card.BackgroundColor3 = UiTheme.PALETTE.SurfaceRaised
status_card.BackgroundTransparency = 0.08
status_card.BorderSizePixel = 0
UiTheme.add_corner(status_card, 8)
UiTheme.add_stroke(
    status_card,
    UiTheme.PALETTE.BorderSoft,
    0.5
)
status_card.Parent = modal.Body

local status = UiComponents.label(
    status_card,
    "Status",
    "Press J to open Guild.",
    "Body"
)
status.Position = UDim2.fromOffset(14, 10)
status.Size = UDim2.new(1, -28, 1, -20)
status.TextWrapped = true
status.TextYAlignment = Enum.TextYAlignment.Top

local guild_heading = UiComponents.section_heading(
    modal.Body,
    "GUILD ACTIONS"
)
guild_heading.Position = UDim2.fromOffset(0, 98)
guild_heading.Size = UDim2.new(1, 0, 0, 18)

local form = Instance.new("Frame")
form.Name = "GuildActions"
form.Position = UDim2.fromOffset(0, 124)
form.Size = UDim2.new(1, 0, 1, -124)
form.BackgroundTransparency = 1
form.Parent = modal.Body

--[[
Creates one themed guild input field.

Args:
    parent (Instance): Parent container.
    name (string): Instance name.
    placeholder (string): Placeholder text.
    y (number): Vertical position in pixels.

Returns:
    TextBox: Configured input box.
]]
local function create_input(
    parent: Instance,
    name: string,
    placeholder: string,
    y: number
): TextBox
    local box = Instance.new("TextBox")
    box.Name = name
    box.Position = UDim2.fromOffset(0, y)
    box.Size = UDim2.new(1, 0, 0, 40)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.ClearTextOnFocus = false
    box.BackgroundColor3 = UiTheme.PALETTE.SurfaceRaised
    box.BackgroundTransparency = 0.06
    box.TextColor3 = UiTheme.PALETTE.Text
    box.PlaceholderColor3 = UiTheme.PALETTE.TextFaint
    box.Font = UiTheme.FONT.Body
    box.TextSize = 14
    box.BorderSizePixel = 0
    UiTheme.add_corner(box, 7)
    UiTheme.add_stroke(
        box,
        UiTheme.PALETTE.BorderSoft,
        0.42
    )
    box.Parent = parent
    return box
end

local guild_name = create_input(
    form,
    "GuildName",
    "Guild name",
    0
)

local target_user = create_input(
    form,
    "TargetUser",
    "Target UserId",
    50
)

local guild_id = create_input(
    form,
    "GuildId",
    "Guild ID for invitation",
    100
)

local action_grid = Instance.new("Frame")
action_grid.Name = "ActionGrid"
action_grid.Position = UDim2.fromOffset(0, 158)
action_grid.Size = UDim2.new(1, 0, 0, 184)
action_grid.BackgroundTransparency = 1
action_grid.Parent = form

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0.5, -5, 0, 40)
grid.CellPadding = UDim2.fromOffset(10, 8)
grid.FillDirectionMaxCells = 2
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.Parent = action_grid

--[[
Creates one guild action button in the two-column action grid.

Args:
    name (string): Button instance name.
    text (string): Visible button label.
    order (number): Layout order.
    variant (UiTheme.ButtonVariant?): Shared button style.

Returns:
    TextButton: Configured action button.
]]
local function create_action_button(
    name: string,
    text: string,
    order: number,
    variant: UiTheme.ButtonVariant?
): TextButton
    local button = UiComponents.button(
        action_grid,
        name,
        text,
        variant
    )
    button.LayoutOrder = order
    return button
end

local create_button = create_action_button(
    "CreateGuild",
    "Create Guild",
    1,
    "Primary"
)
local invite_button = create_action_button(
    "InviteUser",
    "Invite User",
    2,
    "Secondary"
)
local accept_button = create_action_button(
    "AcceptInvite",
    "Accept Invitation",
    3,
    "Primary"
)
local officer_button = create_action_button(
    "SetOfficer",
    "Promote to Officer",
    4,
    "Secondary"
)
local member_button = create_action_button(
    "SetMember",
    "Set Member Role",
    5,
    "Secondary"
)
local kick_button = create_action_button(
    "KickUser",
    "Remove Member",
    6,
    "Danger"
)
local upgrade_button = create_action_button(
    "UpgradeGuild",
    "Upgrade Guild",
    7,
    "Primary"
)
local hall_button = create_action_button(
    "EnterHall",
    "Enter Guild Hall",
    8,
    "Secondary"
)

local footer = Instance.new("Frame")
footer.Name = "Footer"
footer.AnchorPoint = Vector2.new(0, 1)
footer.Position = UDim2.new(0, 0, 1, 0)
footer.Size = UDim2.new(1, 0, 0, 44)
footer.BackgroundTransparency = 1
footer.Parent = form

local exit_button = UiComponents.button(
    footer,
    "ExitHall",
    "Exit Guild Hall",
    "Secondary"
)
exit_button.Size = UDim2.fromOffset(160, 40)

local refresh_button = UiComponents.button(
    footer,
    "Refresh",
    "Refresh",
    "Ghost"
)
refresh_button.AnchorPoint = Vector2.new(1, 0)
refresh_button.Position = UDim2.fromScale(1, 0)
refresh_button.Size = UDim2.fromOffset(110, 40)

--[[
Sends one guild action with an idempotency request ID.

Args:
    action (string): Guild action name.
    payload (any?): Optional action payload.

Returns:
    None.
]]
local function request(action: string, payload: any?)
    action_request:FireServer(
        action,
        payload or {},
        HttpService:GenerateGUID(false)
    )
end

--[[
Shows or hides the global Guild window.

Args:
    visible (boolean): Desired window visibility.

Returns:
    None.
]]
local function apply_visibility(visible: boolean)
    panel.Visible = visible

    if visible then
        status.Text = "Loading guild..."
        snapshot_request:FireServer()
    end
end

WindowController.register("Guild", apply_visibility)

local function set_visible(visible: boolean)
    WindowController.set_visible("Guild", visible)
end

create_button.Activated:Connect(function()
    request("Create", {Name = guild_name.Text})
end)

invite_button.Activated:Connect(function()
    request(
        "Invite",
        {TargetUserId = tonumber(target_user.Text)}
    )
end)

accept_button.Activated:Connect(function()
    request("Accept", {GuildId = guild_id.Text})
end)

officer_button.Activated:Connect(function()
    request(
        "SetRole",
        {
            TargetUserId = tonumber(target_user.Text),
            Role = "Officer",
        }
    )
end)

member_button.Activated:Connect(function()
    request(
        "SetRole",
        {
            TargetUserId = tonumber(target_user.Text),
            Role = "Member",
        }
    )
end)

kick_button.Activated:Connect(function()
    request(
        "Kick",
        {TargetUserId = tonumber(target_user.Text)}
    )
end)

upgrade_button.Activated:Connect(function()
    request("Upgrade")
end)

hall_button.Activated:Connect(function()
    request("HallEntry")
end)

exit_button.Activated:Connect(function()
    request("HallExit")
end)

refresh_button.Activated:Connect(function()
    snapshot_request:FireServer()
end)

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

    if input.KeyCode == Enum.KeyCode.J then
        set_visible(not panel.Visible)
    end
end)

snapshot_remote.OnClientEvent:Connect(function(snapshot: any)
    if not snapshot or snapshot.ok ~= true then
        status.Text = "Guild unavailable: "
            .. tostring(snapshot and snapshot.reason)
        return
    end

    if not snapshot.membership or not snapshot.guild then
        status.Text =
            "You are not in a guild. Create one or accept an invitation."
        return
    end

    local member_count = 0
    for _ in pairs(snapshot.guild.Members or {}) do
        member_count += 1
    end

    status.Text = string.format(
        "%s\nLevel %d  |  %d XP  |  %d Guild Gold"
            .. "  |  %s  |  %d members",
        tostring(snapshot.guild.Name),
        tonumber(snapshot.guild.Level) or 1,
        tonumber(snapshot.guild.XP) or 0,
        tonumber(snapshot.guild.Gold) or 0,
        tostring(snapshot.membership.Role),
        member_count
    )
end)

action_result.OnClientEvent:Connect(function(response: any)
    if response and response.ok == true then
        status.Text = tostring(response.action)
            .. " succeeded."

        if response.admission then
            status.Text ..= "\nHall: "
                .. tostring(response.admission.HallKey)
        end

        snapshot_request:FireServer()
        return
    end

    status.Text = tostring(
        response and response.action or "Guild"
    )
        .. " failed: "
        .. tostring(response and response.reason)
end)
