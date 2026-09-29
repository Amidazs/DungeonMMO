--!strict
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local UiArt = require(
    shared:WaitForChild("UiArt")
)
local UiComponents = require(
    shared:WaitForChild("UiComponents")
)
local UiTheme = require(
    shared:WaitForChild("UiTheme")
)

local WindowController = require(
    script.Parent.Parent
        :WaitForChild("Core")
        :WaitForChild("HudWindowController")
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
    "Guild overview, members, ranks and settings.",
    UDim2.fromOffset(680, 850)
)
local panel = modal.Root
panel.Visible = false
panel.ZIndex = 11
UiArt.clear_frame_chrome(panel)
UiArt.reference_background(
    panel,
    "Guild",
    11
)

modal.Header.ZIndex = 14
modal.Title.Visible = false
modal.Subtitle.Visible = false
modal.Close.ZIndex = 18
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
    "Guild",
    58,
    250
)
modal.Body.Size = UiArt.rect(
    "Guild",
    58,
    250,
    1008,
    1060
)
modal.Body.ZIndex = 14

UiTheme.bind_responsive_scale(
    panel,
    1366,
    0.62,
    1
)

local tab_row = Instance.new("Frame")
tab_row.Name = "GuildTabs"
tab_row.Position = UiArt.position(
    "Guild",
    60,
    188
)
tab_row.Size = UiArt.rect(
    "Guild",
    60,
    188,
    1000,
    56
)
tab_row.BackgroundTransparency = 1
tab_row.ZIndex = 15
tab_row.Parent = panel

local tab_layout = Instance.new("UIListLayout")
tab_layout.FillDirection = Enum.FillDirection.Horizontal
tab_layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tab_layout.Padding = UDim.new(0, 5)
tab_layout.SortOrder = Enum.SortOrder.LayoutOrder
tab_layout.Parent = tab_row

local TAB_NAMES = {
    "Overview",
    "Members",
    "Ranks",
    "Logs",
    "Settings",
}

--[[
Applies the shared dark-metal treatment to a guild text box.

Args:
    box (TextBox): Input field to style.

Returns:
    None.
]]
local function style_input(box: TextBox)
    box.BackgroundColor3 = UiTheme.PALETTE.BackdropSoft
    box.BackgroundTransparency = 0.04
    box.BorderSizePixel = 0
    box.Font = UiTheme.FONT.Body
    box.TextColor3 = UiTheme.PALETTE.Text
    box.PlaceholderColor3 = UiTheme.PALETTE.TextFaint
    box.TextSize = 14
    box.TextXAlignment = Enum.TextXAlignment.Left
    UiTheme.add_corner(box, 2)
    UiTheme.add_stroke(
        box,
        UiTheme.PALETTE.BorderSoft,
        0.22
    )
end

local pages: {[string]: Frame} = {}
local tab_buttons: {[string]: TextButton} = {}
local active_page = "Overview"
local latest_snapshot: any = nil

--[[
Creates one guild page container.

Args:
    name (string): Stable page name.

Returns:
    Frame: Hidden page frame filling the modal body.
]]
local function create_page(name: string): Frame
    local page = Instance.new("Frame")
    page.Name = name .. "Page"
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ZIndex = 14
    page.Parent = modal.Body
    pages[name] = page
    return page
end

for index, name in ipairs(TAB_NAMES) do
    local button = UiComponents.button(
        tab_row,
        name .. "Tab",
        name,
        "Ghost"
    )
    button.LayoutOrder = index
    button.Size = UDim2.new(0.2, -4, 1, 0)
    button.TextSize = 14
    button.ZIndex = 16
    UiArt.paint_tab(button, name == "Overview")
    tab_buttons[name] = button
end

local overview_page = create_page("Overview")
local members_page = create_page("Members")
local ranks_page = create_page("Ranks")
local logs_page = create_page("Logs")
local settings_page = create_page("Settings")

local guild_title = UiComponents.label(
    overview_page,
    "GuildTitle",
    "No Guild",
    "Title"
)
guild_title.Position = UDim2.fromOffset(18, 18)
guild_title.Size = UDim2.new(1, -36, 0, 38)
guild_title.TextSize = 28
guild_title.ZIndex = 15

local guild_summary = UiComponents.label(
    overview_page,
    "GuildSummary",
    "",
    "Body"
)
guild_summary.Position = UDim2.fromOffset(18, 62)
guild_summary.Size = UDim2.new(1, -36, 0, 54)
guild_summary.TextWrapped = true
guild_summary.ZIndex = 15

local motd_heading = UiComponents.section_heading(
    overview_page,
    "GUILD MESSAGE"
)
motd_heading.Position = UDim2.fromOffset(18, 132)
motd_heading.Size = UDim2.new(1, -36, 0, 18)
motd_heading.ZIndex = 15

local motd = UiComponents.label(
    overview_page,
    "GuildMessage",
    "No guild message set.",
    "Body"
)
motd.Position = UDim2.fromOffset(18, 158)
motd.Size = UDim2.new(1, -36, 0, 86)
motd.TextWrapped = true
motd.TextYAlignment = Enum.TextYAlignment.Top
motd.ZIndex = 15

local overview_actions = Instance.new("Frame")
overview_actions.Name = "OverviewActions"
overview_actions.Position = UDim2.fromOffset(18, 264)
overview_actions.Size = UDim2.new(1, -36, 0, 94)
overview_actions.BackgroundTransparency = 1
overview_actions.ZIndex = 15
overview_actions.Parent = overview_page

local overview_grid = Instance.new("UIGridLayout")
overview_grid.CellSize = UDim2.new(0.5, -5, 0, 42)
overview_grid.CellPadding = UDim2.fromOffset(10, 8)
overview_grid.FillDirectionMaxCells = 2
overview_grid.Parent = overview_actions

local hall_button = UiComponents.button(
    overview_actions,
    "EnterHall",
    "Enter Guild Hall",
    "Primary"
)
local upgrade_button = UiComponents.button(
    overview_actions,
    "UpgradeGuild",
    "Upgrade Guild",
    "Secondary"
)
local leave_button = UiComponents.button(
    overview_actions,
    "LeaveGuild",
    "Leave Guild",
    "Danger"
)
local refresh_button = UiComponents.button(
    overview_actions,
    "Refresh",
    "Refresh",
    "Ghost"
)

local join_panel = Instance.new("Frame")
join_panel.Name = "JoinPanel"
join_panel.Position = UDim2.fromOffset(18, 382)
join_panel.Size = UDim2.new(1, -36, 0, 154)
join_panel.BackgroundTransparency = 1
join_panel.ZIndex = 15
join_panel.Parent = overview_page

local create_name = Instance.new("TextBox")
create_name.Name = "GuildName"
create_name.Size = UDim2.new(1, 0, 0, 40)
create_name.PlaceholderText = "Guild name"
create_name.ClearTextOnFocus = false
create_name.Text = ""
create_name.ZIndex = 16
style_input(create_name)
create_name.Parent = join_panel

local invite_guild_id = Instance.new("TextBox")
invite_guild_id.Name = "GuildId"
invite_guild_id.Position = UDim2.fromOffset(0, 50)
invite_guild_id.Size = UDim2.new(1, 0, 0, 40)
invite_guild_id.PlaceholderText = "Guild ID from invitation"
invite_guild_id.ClearTextOnFocus = false
invite_guild_id.Text = ""
invite_guild_id.ZIndex = 16
style_input(invite_guild_id)
invite_guild_id.Parent = join_panel

local create_guild_button = UiComponents.button(
    join_panel,
    "CreateGuild",
    "Create Guild",
    "Primary"
)
create_guild_button.Position = UDim2.fromOffset(0, 100)
create_guild_button.Size = UDim2.new(0.5, -5, 0, 42)
create_guild_button.ZIndex = 16

local accept_invite_button = UiComponents.button(
    join_panel,
    "AcceptInvite",
    "Accept Invitation",
    "Secondary"
)
accept_invite_button.Position = UDim2.new(0.5, 5, 0, 100)
accept_invite_button.Size = UDim2.new(0.5, -5, 0, 42)
accept_invite_button.ZIndex = 16

local member_heading = UiComponents.section_heading(
    members_page,
    "MEMBERS"
)
member_heading.Position = UDim2.fromOffset(18, 18)
member_heading.Size = UDim2.new(1, -36, 0, 18)
member_heading.ZIndex = 15

local member_list = Instance.new("ScrollingFrame")
member_list.Name = "MemberList"
member_list.Position = UDim2.fromOffset(18, 46)
member_list.Size = UDim2.new(1, -36, 1, -256)
member_list.CanvasSize = UDim2.fromOffset(0, 0)
member_list.AutomaticCanvasSize = Enum.AutomaticSize.Y
member_list.ZIndex = 15
UiTheme.style_scroll(member_list)
member_list.Parent = members_page

local member_layout = Instance.new("UIListLayout")
member_layout.Padding = UDim.new(0, 6)
member_layout.SortOrder = Enum.SortOrder.LayoutOrder
member_layout.Parent = member_list

local target_user = Instance.new("TextBox")
target_user.Name = "TargetUser"
target_user.AnchorPoint = Vector2.new(0, 1)
target_user.Position = UDim2.new(0, 18, 1, -148)
target_user.Size = UDim2.new(1, -36, 0, 40)
target_user.PlaceholderText = "Target UserId"
target_user.ClearTextOnFocus = false
target_user.Text = ""
target_user.ZIndex = 15
style_input(target_user)
target_user.Parent = members_page

local member_actions = Instance.new("Frame")
member_actions.Name = "MemberActions"
member_actions.AnchorPoint = Vector2.new(0, 1)
member_actions.Position = UDim2.new(0, 18, 1, -18)
member_actions.Size = UDim2.new(1, -36, 0, 120)
member_actions.BackgroundTransparency = 1
member_actions.ZIndex = 15
member_actions.Parent = members_page

local member_grid = Instance.new("UIGridLayout")
member_grid.CellSize = UDim2.new(0.5, -5, 0, 36)
member_grid.CellPadding = UDim2.fromOffset(10, 6)
member_grid.FillDirectionMaxCells = 2
member_grid.Parent = member_actions

local invite_button = UiComponents.button(
    member_actions,
    "Invite",
    "Invite",
    "Primary"
)
local officer_button = UiComponents.button(
    member_actions,
    "PromoteOfficer",
    "Promote to Officer",
    "Secondary"
)
local member_button = UiComponents.button(
    member_actions,
    "SetMember",
    "Set Member",
    "Secondary"
)
local kick_button = UiComponents.button(
    member_actions,
    "Kick",
    "Remove Member",
    "Danger"
)
local transfer_button = UiComponents.button(
    member_actions,
    "TransferLeader",
    "Transfer Leadership",
    "Danger"
)

local ranks_text = UiComponents.label(
    ranks_page,
    "RanksText",
    "",
    "Body"
)
ranks_text.Position = UDim2.fromOffset(22, 24)
ranks_text.Size = UDim2.new(1, -44, 1, -48)
ranks_text.TextWrapped = true
ranks_text.TextYAlignment = Enum.TextYAlignment.Top
ranks_text.ZIndex = 15

local logs_text = UiComponents.label(
    logs_page,
    "LogsText",
    "Guild activity logs are not yet exposed to the client. "
        .. "This page is reserved for the audit-backed guild log.",
    "Body"
)
logs_text.Position = UDim2.fromOffset(22, 24)
logs_text.Size = UDim2.new(1, -44, 1, -48)
logs_text.TextWrapped = true
logs_text.TextYAlignment = Enum.TextYAlignment.Top
logs_text.ZIndex = 15

local settings_heading = UiComponents.section_heading(
    settings_page,
    "GUILD SETTINGS"
)
settings_heading.Position = UDim2.fromOffset(18, 18)
settings_heading.Size = UDim2.new(1, -36, 0, 18)
settings_heading.ZIndex = 15

local message_box = Instance.new("TextBox")
message_box.Name = "MessageOfTheDay"
message_box.Position = UDim2.fromOffset(18, 50)
message_box.Size = UDim2.new(1, -36, 0, 92)
message_box.ClearTextOnFocus = false
message_box.MultiLine = true
message_box.TextWrapped = true
message_box.TextYAlignment = Enum.TextYAlignment.Top
message_box.PlaceholderText = "Guild message of the day"
message_box.Text = ""
message_box.ZIndex = 15
style_input(message_box)
message_box.Parent = settings_page

local save_message_button = UiComponents.button(
    settings_page,
    "SaveMessage",
    "Save Guild Message",
    "Primary"
)
save_message_button.Position = UDim2.fromOffset(18, 152)
save_message_button.Size = UDim2.new(1, -36, 0, 40)
save_message_button.ZIndex = 15

local permission_heading = UiComponents.section_heading(
    settings_page,
    "WHO CAN SEE GUILD SETTINGS?"
)
permission_heading.Position = UDim2.fromOffset(18, 220)
permission_heading.Size = UDim2.new(1, -36, 0, 18)
permission_heading.ZIndex = 15

local officer_access = UiComponents.button(
    settings_page,
    "OfficerAccess",
    "Officer: Hidden",
    "Secondary"
)
officer_access.Position = UDim2.fromOffset(18, 254)
officer_access.Size = UDim2.new(1, -36, 0, 44)
officer_access.ZIndex = 15

local member_access = UiComponents.button(
    settings_page,
    "MemberAccess",
    "Member: Hidden",
    "Secondary"
)
member_access.Position = UDim2.fromOffset(18, 308)
member_access.Size = UDim2.new(1, -36, 0, 44)
member_access.ZIndex = 15

local settings_note = UiComponents.label(
    settings_page,
    "SettingsNote",
    "Guild Master always has access. "
        .. "Only the Guild Master can change these permissions.",
    "Muted"
)
settings_note.Position = UDim2.fromOffset(18, 368)
settings_note.Size = UDim2.new(1, -36, 0, 60)
settings_note.TextWrapped = true
settings_note.TextYAlignment = Enum.TextYAlignment.Top
settings_note.ZIndex = 15

UiArt.paint_button(hall_button, "Primary")
UiArt.paint_button(upgrade_button, "Secondary")
UiArt.paint_button(leave_button, "Danger")
UiArt.paint_button(refresh_button, "Ghost")
UiArt.paint_button(create_guild_button, "Primary")
UiArt.paint_button(accept_invite_button, "Secondary")
UiArt.paint_button(invite_button, "Primary")
UiArt.paint_button(officer_button, "Secondary")
UiArt.paint_button(member_button, "Secondary")
UiArt.paint_button(kick_button, "Danger")
UiArt.paint_button(transfer_button, "Danger")
UiArt.paint_button(save_message_button, "Primary")
UiArt.paint_button(officer_access, "Secondary")
UiArt.paint_button(member_access, "Secondary")

local status = UiComponents.label(
    modal.Body,
    "Status",
    "",
    "Muted"
)
status.AnchorPoint = Vector2.new(0, 1)
status.Position = UDim2.new(0, 18, 1, -2)
status.Size = UDim2.new(1, -36, 0, 28)
status.ZIndex = 20

--[[
Sends one server-authoritative guild action.

Args:
    action (string): Guild action identifier.
    payload (any?): Optional action payload.

Returns:
    None.
]]
local function request(
    action: string,
    payload: any?
)
    action_request:FireServer(
        action,
        payload or {},
        HttpService:GenerateGUID(false)
    )
end

--[[
Returns the latest guild membership table.

Args:
    None.

Returns:
    any?: Membership snapshot.
]]
local function membership(): any?
    return latest_snapshot
        and latest_snapshot.membership
        or nil
end

--[[
Returns the latest public guild table.

Args:
    None.

Returns:
    any?: Guild snapshot.
]]
local function guild(): any?
    return latest_snapshot
        and latest_snapshot.guild
        or nil
end

--[[
Returns whether the current player may see Guild Settings.

Args:
    None.

Returns:
    boolean: Permission-gated Settings visibility.
]]
local function can_view_settings(): boolean
    local permissions = latest_snapshot
        and latest_snapshot.permissions

    return type(permissions) == "table"
        and permissions.CanViewSettings == true
end

--[[
Returns whether the current player may edit Guild Settings.

Args:
    None.

Returns:
    boolean: True for the Guild Master.
]]
local function can_edit_settings(): boolean
    local permissions = latest_snapshot
        and latest_snapshot.permissions

    return type(permissions) == "table"
        and permissions.CanEditSettings == true
end

--[[
Applies page and tab visibility.

Args:
    requested_page (string): Desired page name.

Returns:
    None.
]]
local function show_page(requested_page: string)
    if requested_page == "Settings"
        and not can_view_settings()
    then
        requested_page = "Overview"
    end

    active_page = requested_page

    for name, page in pairs(pages) do
        page.Visible = name == active_page
    end

    for name, button in pairs(tab_buttons) do
        UiArt.paint_tab(
            button,
            name == active_page
        )
    end
end

for _, name in ipairs(TAB_NAMES) do
    tab_buttons[name].Activated:Connect(function()
        show_page(name)
    end)
end

--[[
Clears generated member rows.

Args:
    None.

Returns:
    None.
]]
local function clear_member_rows()
    for _, child in ipairs(member_list:GetChildren()) do
        if child ~= member_layout
            and child:IsA("GuiObject")
        then
            child:Destroy()
        end
    end
end

--[[
Renders guild members into the Members page.

Args:
    guild_snapshot (any): Current public guild table.

Returns:
    None.
]]
local function render_members(guild_snapshot: any)
    clear_member_rows()

    if type(guild_snapshot) ~= "table"
        or type(guild_snapshot.Members) ~= "table"
    then
        return
    end

    local rows = {}
    for key, member in pairs(guild_snapshot.Members) do
        table.insert(rows, {
            Key = key,
            UserId = tonumber(member.UserId) or 0,
            Role = tostring(member.Role or "Member"),
        })
    end

    table.sort(rows, function(left: any, right: any): boolean
        if left.Role == right.Role then
            return left.UserId < right.UserId
        end
        return left.Role < right.Role
    end)

    for index, member in ipairs(rows) do
        local row = Instance.new("Frame")
        row.Name = "Member" .. tostring(member.UserId)
        row.LayoutOrder = index
        row.Size = UDim2.new(1, -8, 0, 42)
        row.ZIndex = 16
        UiTheme.style_inset(row, false)
        row.Parent = member_list

        local label = UiComponents.label(
            row,
            "MemberText",
            string.format(
                "User %d",
                member.UserId
            ),
            "Body"
        )
        label.Position = UDim2.fromOffset(10, 0)
        label.Size = UDim2.new(0.65, -10, 1, 0)
        label.ZIndex = 17

        local role = UiComponents.label(
            row,
            "Role",
            member.Role,
            "Heading"
        )
        role.AnchorPoint = Vector2.new(1, 0)
        role.Position = UDim2.new(1, -10, 0, 0)
        role.Size = UDim2.new(0.35, 0, 1, 0)
        role.TextXAlignment = Enum.TextXAlignment.Right
        role.TextColor3 = UiTheme.PALETTE.AccentBright
        role.ZIndex = 17
    end
end

--[[
Renders all guild pages from the latest server snapshot.

Args:
    snapshot (any): Guild snapshot payload.

Returns:
    None.
]]
local function render(snapshot: any)
    latest_snapshot = snapshot

    if type(snapshot) ~= "table"
        or snapshot.ok ~= true
    then
        status.Text = "Guild unavailable: "
            .. tostring(
                snapshot and snapshot.reason or "Unknown"
            )
        show_page("Overview")
        return
    end

    local current_membership = membership()
    local current_guild = guild()
    local in_guild = current_membership ~= nil
        and current_guild ~= nil

    join_panel.Visible = not in_guild
    overview_actions.Visible = in_guild
    tab_buttons.Members.Visible = in_guild
    tab_buttons.Ranks.Visible = in_guild
    tab_buttons.Logs.Visible = in_guild
    tab_buttons.Settings.Visible =
        in_guild and can_view_settings()

    if not in_guild then
        guild_title.Text = "No Guild"
        guild_summary.Text =
            "Create a guild or accept an invitation."
        motd.Text = "No guild message set."
        status.Text = "You are not currently in a guild."
        show_page("Overview")
        return
    end

    local member_count = 0
    for _ in pairs(current_guild.Members or {}) do
        member_count += 1
    end

    guild_title.Text = tostring(current_guild.Name)
    guild_summary.Text = string.format(
        "Level %d  •  %d XP  •  %d Guild Gold  •  "
            .. "%d members  •  %s",
        tonumber(current_guild.Level) or 1,
        tonumber(current_guild.XP) or 0,
        tonumber(current_guild.Gold) or 0,
        member_count,
        tostring(current_membership.Role)
    )

    local settings = current_guild.Settings
    motd.Text = if type(settings) == "table"
            and type(settings.MessageOfTheDay) == "string"
            and settings.MessageOfTheDay ~= ""
        then settings.MessageOfTheDay
        else "No guild message set."

    render_members(current_guild)

    ranks_text.Text = string.format(
        "Guild Master\n"
            .. "Full guild authority. Guild Settings always visible.\n\n"
            .. "Officer\n"
            .. "Can invite players. Settings visibility: %s.\n\n"
            .. "Member\n"
            .. "Standard guild member. Settings visibility: %s.",
        if type(settings) == "table"
                and settings.ViewSettingsByRole
                and settings.ViewSettingsByRole.Officer == true
            then "Visible"
            else "Hidden",
        if type(settings) == "table"
                and settings.ViewSettingsByRole
                and settings.ViewSettingsByRole.Member == true
            then "Visible"
            else "Hidden"
    )

    if can_view_settings()
        and type(settings) == "table"
    then
        message_box.Text = tostring(
            settings.MessageOfTheDay or ""
        )

        local officer_visible =
            settings.ViewSettingsByRole
            and settings.ViewSettingsByRole.Officer == true
        local member_visible =
            settings.ViewSettingsByRole
            and settings.ViewSettingsByRole.Member == true

        officer_access.Text =
            "Officer: "
            .. if officer_visible then "Visible" else "Hidden"
        member_access.Text =
            "Member: "
            .. if member_visible then "Visible" else "Hidden"

        UiTheme.set_button_enabled(
            officer_access,
            can_edit_settings()
        )
        UiTheme.set_button_enabled(
            member_access,
            can_edit_settings()
        )
        UiTheme.set_button_enabled(
            save_message_button,
            can_edit_settings()
        )
        message_box.TextEditable = can_edit_settings()
    end

    if active_page == "Settings"
        and not can_view_settings()
    then
        active_page = "Overview"
    end

    status.Text = "Guild data refreshed."
    show_page(active_page)
end

hall_button.Activated:Connect(function()
    request("HallEntry")
end)

upgrade_button.Activated:Connect(function()
    request("Upgrade")
end)

leave_button.Activated:Connect(function()
    request("Leave")
end)

refresh_button.Activated:Connect(function()
    snapshot_request:FireServer()
end)

create_guild_button.Activated:Connect(function()
    request(
        "Create",
        {Name = create_name.Text}
    )
end)

accept_invite_button.Activated:Connect(function()
    request(
        "Accept",
        {GuildId = invite_guild_id.Text}
    )
end)

invite_button.Activated:Connect(function()
    request(
        "Invite",
        {TargetUserId = tonumber(target_user.Text)}
    )
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

transfer_button.Activated:Connect(function()
    request(
        "TransferLeader",
        {TargetUserId = tonumber(target_user.Text)}
    )
end)

save_message_button.Activated:Connect(function()
    if can_edit_settings() then
        request(
            "SetMessage",
            {Message = message_box.Text}
        )
    end
end)

officer_access.Activated:Connect(function()
    if not can_edit_settings() then
        return
    end

    local settings = guild()
        and guild().Settings
    local current = type(settings) == "table"
        and settings.ViewSettingsByRole
        and settings.ViewSettingsByRole.Officer == true

    request(
        "SetSettingsAccess",
        {
            Role = "Officer",
            Allowed = not current,
        }
    )
end)

member_access.Activated:Connect(function()
    if not can_edit_settings() then
        return
    end

    local settings = guild()
        and guild().Settings
    local current = type(settings) == "table"
        and settings.ViewSettingsByRole
        and settings.ViewSettingsByRole.Member == true

    request(
        "SetSettingsAccess",
        {
            Role = "Member",
            Allowed = not current,
        }
    )
end)

--[[
Shows or hides the managed Guild window.

Args:
    visible (boolean): Desired visibility.

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

UiArt.align_close(panel, modal.Close, "Guild")

modal.Close.Activated:Connect(function()
    WindowController.set_visible(
        "Guild",
        false
    )
end)

UserInputService.InputBegan:Connect(function(
    input: InputObject,
    processed: boolean
)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.J then
        WindowController.toggle("Guild")
    end
end)

snapshot_remote.OnClientEvent:Connect(function(
    snapshot: any
)
    render(snapshot)
end)

action_result.OnClientEvent:Connect(function(
    response: any
)
    if response and response.ok == true then
        status.Text = tostring(response.action)
            .. " succeeded."
        snapshot_request:FireServer()
        return
    end

    status.Text = tostring(
        response and response.action or "Guild"
    )
        .. " failed: "
        .. tostring(
            response and response.reason or "Unknown"
        )
end)

show_page("Overview")
