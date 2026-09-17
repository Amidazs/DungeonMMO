--!strict
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Remotes")
local snapshot_request = remotes:WaitForChild("GuildSnapshotRequest") :: RemoteEvent
local snapshot_remote = remotes:WaitForChild("GuildSnapshot") :: RemoteEvent
local action_request = remotes:WaitForChild("GuildActionRequest") :: RemoteEvent
local action_result = remotes:WaitForChild("GuildActionResult") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "GuildPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.fromOffset(360, 470)
frame.Position = UDim2.new(1, -375, 0.5, -235)
frame.BackgroundTransparency = 0.12
frame.Parent = gui

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = frame
local function label(text: string, height: number?): TextLabel
    local value = Instance.new("TextLabel")
    value.Size = UDim2.new(1, -10, 0, height or 28)
    value.BackgroundTransparency = 1
    value.TextWrapped = true
    value.TextXAlignment = Enum.TextXAlignment.Left
    value.Text = text
    value.Parent = frame
    return value
end

local function textbox(placeholder: string): TextBox
    local value = Instance.new("TextBox")
    value.Size = UDim2.new(1, -10, 0, 30)
    value.PlaceholderText = placeholder
    value.Text = ""
    value.ClearTextOnFocus = false
    value.Parent = frame
    return value
end

local function button(text: string): TextButton
    local value = Instance.new("TextButton")
    value.Size = UDim2.new(1, -10, 0, 30)
    value.Text = text
    value.Parent = frame
    return value
end

local title = label("Guild / Hall Systems Alpha", 32)
title.TextScaled = false
local status = label("Requesting guild snapshot...", 48)
local guild_name = textbox("Guild name (Create)")
local target_user = textbox("Target UserId (Invite / Role / Kick)")
local guild_id = textbox("GuildId (Accept invite)")

local create_button = button("Create Guild")
local invite_button = button("Invite User")
local accept_button = button("Accept Invite")
local officer_button = button("Set Officer")
local member_button = button("Set Member")
local kick_button = button("Kick User")
local upgrade_button = button("Upgrade Guild")
local hall_button = button("Enter Guild Hall Proof")
local exit_button = button("Exit Guild Hall")
local refresh_button = button("Refresh")

local function request(action: string, payload: any?)
    action_request:FireServer(
        action,
        payload or {},
        HttpService:GenerateGUID(false)
    )
end

create_button.Activated:Connect(function()
    request("Create", {Name = guild_name.Text})
end)
invite_button.Activated:Connect(function()
    request("Invite", {TargetUserId = tonumber(target_user.Text)})
end)
accept_button.Activated:Connect(function()
    request("Accept", {GuildId = guild_id.Text})
end)
officer_button.Activated:Connect(function()
    request("SetRole", {TargetUserId = tonumber(target_user.Text), Role = "Officer"})
end)
member_button.Activated:Connect(function()
    request("SetRole", {TargetUserId = tonumber(target_user.Text), Role = "Member"})
end)
kick_button.Activated:Connect(function()
    request("Kick", {TargetUserId = tonumber(target_user.Text)})
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

snapshot_remote.OnClientEvent:Connect(function(snapshot: any)
    if not snapshot or snapshot.ok ~= true then
        status.Text = "Guild snapshot unavailable: " .. tostring(snapshot and snapshot.reason)
        return
    end
    if not snapshot.membership or not snapshot.guild then
        status.Text = "Not in a guild. Create one or accept an invite."
        return
    end
    local member_count = 0
    for _ in pairs(snapshot.guild.Members or {}) do member_count += 1 end
    status.Text = string.format(
        "%s | Lv %d | XP %d | Guild Gold %d | %s | %d members",
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
        status.Text = tostring(response.action) .. " succeeded."
        if response.admission then
            status.Text ..= " Hall=" .. tostring(response.admission.HallKey)
        end
    else
        status.Text = tostring(response and response.action or "Guild")
            .. " failed: " .. tostring(response and response.reason)
    end
end)

snapshot_request:FireServer()
