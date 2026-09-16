local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Remotes")
local entryRequest = remotes:WaitForChild("DungeonEntryRequest")
local entryResult = remotes:WaitForChild("DungeonEntryResult")
local partyRequest = remotes:WaitForChild("PartyActionRequest")
local partySnapshot = remotes:WaitForChild("PartySnapshot")
local partyResult = remotes:WaitForChild("PartyActionResult")

local gui = Instance.new("ScreenGui")
gui.Name = "BaseUi"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "DungeonPartyPanel"
frame.AnchorPoint = Vector2.new(0.5, 1)
frame.Position = UDim2.fromScale(0.5, 0.97)
frame.Size = UDim2.fromOffset(760, 520)
frame.BackgroundTransparency = 0.08
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 36)
title.Position = UDim2.fromOffset(12, 8)
title.Text = "Dungeon Expeditions | Party 1-4"
title.TextScaled = true
title.BackgroundTransparency = 1
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 28)
status.Position = UDim2.fromOffset(12, 44)
status.Text = "Loading party state..."
status.TextWrapped = true
status.BackgroundTransparency = 1
status.Parent = frame

local function makeButton(parent, text, x, y, w, h)
    local button = Instance.new("TextButton")
    button.Text = text
    button.Position = UDim2.fromOffset(x, y)
    button.Size = UDim2.fromOffset(w, h)
    button.Parent = parent
    return button
end

local templeButton = makeButton(frame, "Temple", 12, 82, 170, 38)
local mineButton = makeButton(frame, "Abandoned Mine", 192, 82, 170, 38)
local createButton = makeButton(frame, "Create Party", 372, 82, 120, 38)
local readyButton = makeButton(frame, "Ready", 502, 82, 110, 38)
local leaveButton = makeButton(frame, "Leave Party", 622, 82, 126, 38)

local startButton = makeButton(frame, "Enter Selected Dungeon", 12, 130, 350, 42)
local refreshButton = makeButton(frame, "Refresh", 372, 130, 120, 42)

local inviteBanner = Instance.new("TextLabel")
inviteBanner.Position = UDim2.fromOffset(502, 130)
inviteBanner.Size = UDim2.fromOffset(246, 42)
inviteBanner.Text = "No incoming invite"
inviteBanner.TextWrapped = true
inviteBanner.Parent = frame

local acceptButton = makeButton(frame, "Accept", 502, 178, 118, 34)
local declineButton = makeButton(frame, "Decline", 630, 178, 118, 34)

local partyHeader = Instance.new("TextLabel")
partyHeader.Position = UDim2.fromOffset(12, 224)
partyHeader.Size = UDim2.fromOffset(350, 28)
partyHeader.Text = "Party"
partyHeader.Parent = frame

local inviteHeader = Instance.new("TextLabel")
inviteHeader.Position = UDim2.fromOffset(382, 224)
inviteHeader.Size = UDim2.fromOffset(366, 28)
inviteHeader.Text = "Players available to invite"
inviteHeader.Parent = frame

local partyList = Instance.new("ScrollingFrame")
partyList.Position = UDim2.fromOffset(12, 256)
partyList.Size = UDim2.fromOffset(350, 248)
partyList.CanvasSize = UDim2.new()
partyList.AutomaticCanvasSize = Enum.AutomaticSize.Y
partyList.ScrollBarThickness = 6
partyList.Parent = frame
local partyLayout = Instance.new("UIListLayout")
partyLayout.Padding = UDim.new(0, 4)
partyLayout.Parent = partyList

local inviteList = Instance.new("ScrollingFrame")
inviteList.Position = UDim2.fromOffset(382, 256)
inviteList.Size = UDim2.fromOffset(366, 248)
inviteList.CanvasSize = UDim2.new()
inviteList.AutomaticCanvasSize = Enum.AutomaticSize.Y
inviteList.ScrollBarThickness = 6
inviteList.Parent = frame
local inviteLayout = Instance.new("UIListLayout")
inviteLayout.Padding = UDim.new(0, 4)
inviteLayout.Parent = inviteList

local snapshot = nil
local localSoloDungeon = "TestDungeon"

local function fire(action, extra)
    local payload = extra or {}
    payload.Action = action
    partyRequest:FireServer(payload)
end

local function clearGenerated(container)
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

local function currentParty()
    return snapshot and snapshot.Party or nil
end

local function currentMember(party)
    if not party then return nil end
    for _, member in ipairs(party.Members or {}) do
        if member.UserId == player.UserId then return member end
    end
    return nil
end

local function selectedDungeon()
    local party = currentParty()
    return party and party.SelectedDungeonId or localSoloDungeon
end

local function render()
    local party = currentParty()
    local invite = snapshot and snapshot.Invite or nil
    local selected = selectedDungeon()

    templeButton.Text = (selected == "TestDungeon" and "[Temple]" or "Temple")
    mineButton.Text = (selected == "AbandonedMine" and "[Abandoned Mine]" or "Abandoned Mine")

    createButton.Visible = party == nil
    leaveButton.Visible = party ~= nil
    readyButton.Visible = party ~= nil and #(party.Members or {}) > 1

    local me = currentMember(party)
    if me then
        readyButton.Text = me.Ready and "Unready" or "Ready"
    end

    acceptButton.Visible = invite ~= nil
    declineButton.Visible = invite ~= nil
    inviteBanner.Text = invite and ("Invite from " .. tostring(invite.InviterName)) or "No incoming invite"

    if party then
        local leader = party.LeaderUserId == player.UserId
        partyHeader.Text = string.format("Party %d/4 | %s", #(party.Members or {}), leader and "You are leader" or "Member")
        startButton.Text = (#party.Members > 1) and "Start Party Dungeon" or "Enter Selected Dungeon"
    else
        partyHeader.Text = "No party | Solo entry available"
        startButton.Text = "Enter Selected Dungeon Solo"
    end

    clearGenerated(partyList)
    if party then
        for _, member in ipairs(party.Members or {}) do
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -8, 0, 42)
            row.Parent = partyList

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -100, 1, 0)
            label.BackgroundTransparency = 1
            label.TextXAlignment = Enum.TextXAlignment.Left
            local leaderMark = member.UserId == party.LeaderUserId and " [Leader]" or ""
            local readyMark = (#party.Members > 1) and (member.Ready and " [Ready]" or " [Not Ready]") or ""
            label.Text = member.DisplayName .. leaderMark .. readyMark
            label.Parent = row

            if party.LeaderUserId == player.UserId and member.UserId ~= player.UserId then
                local kick = makeButton(row, "Kick", row.AbsoluteSize.X - 90, 4, 82, 34)
                kick.AnchorPoint = Vector2.new(1, 0)
                kick.Position = UDim2.new(1, -4, 0, 4)
                kick.Activated:Connect(function()
                    fire("Kick", {TargetUserId = member.UserId})
                end)
            end
        end
    else
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -8, 0, 42)
        label.Text = "Create a party to invite players, or enter solo."
        label.TextWrapped = true
        label.Parent = partyList
    end

    clearGenerated(inviteList)
    local canInvite = party and party.LeaderUserId == player.UserId and #party.Members < 4
    for _, candidate in ipairs((snapshot and snapshot.AvailablePlayers) or {}) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, 42)
        row.Parent = inviteList

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -100, 1, 0)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = candidate.DisplayName .. " (@" .. candidate.Name .. ")"
        label.Parent = row

        local inviteButton = makeButton(row, canInvite and "Invite" or "--", 0, 4, 82, 34)
        inviteButton.AnchorPoint = Vector2.new(1, 0)
        inviteButton.Position = UDim2.new(1, -4, 0, 4)
        inviteButton.Active = canInvite == true
        inviteButton.AutoButtonColor = canInvite == true
        if canInvite then
            inviteButton.Activated:Connect(function()
                fire("Invite", {TargetUserId = candidate.UserId})
            end)
        end
    end
end

templeButton.Activated:Connect(function()
    local party = currentParty()
    if party then
        if party.LeaderUserId == player.UserId then fire("SelectDungeon", {DungeonId = "TestDungeon"}) end
    else
        localSoloDungeon = "TestDungeon"
        render()
    end
end)

mineButton.Activated:Connect(function()
    local party = currentParty()
    if party then
        if party.LeaderUserId == player.UserId then fire("SelectDungeon", {DungeonId = "AbandonedMine"}) end
    else
        localSoloDungeon = "AbandonedMine"
        render()
    end
end)

createButton.Activated:Connect(function() fire("Create") end)
leaveButton.Activated:Connect(function() fire("Leave") end)
refreshButton.Activated:Connect(function() fire("RequestSnapshot") end)
acceptButton.Activated:Connect(function() fire("AcceptInvite") end)
declineButton.Activated:Connect(function() fire("DeclineInvite") end)

readyButton.Activated:Connect(function()
    local me = currentMember(currentParty())
    fire("SetReady", {Ready = not (me and me.Ready == true)})
end)

startButton.Activated:Connect(function()
    local party = currentParty()
    if party and #party.Members > 1 then
        if party.LeaderUserId ~= player.UserId then
            status.Text = "Only the party leader can start the dungeon."
            return
        end
        fire("StartEntry")
    else
        entryRequest:FireServer(selectedDungeon())
    end
end)

partySnapshot.OnClientEvent:Connect(function(nextSnapshot)
    snapshot = nextSnapshot
    render()
end)

partyResult.OnClientEvent:Connect(function(result)
    if result.ok then
        status.Text = tostring(result.Action) .. " succeeded"
    else
        local member = result.MemberName and (" | " .. tostring(result.MemberName)) or ""
        status.Text = tostring(result.Action) .. " blocked: " .. tostring(result.reason) .. member
    end
end)

entryResult.OnClientEvent:Connect(function(result)
    if result.ok and result.reason == "StudioPartyEntryProof" then
        status.Text = "Studio party entry proof passed for " .. tostring(result.DungeonId)
    elseif result.ok then
        status.Text = "Dungeon entry started..."
    else
        status.Text = "Entry blocked: " .. tostring(result.reason)
    end
end)

fire("RequestSnapshot")
