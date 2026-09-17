--!strict
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Remotes")
local snapshot_request = remotes:WaitForChild("MarketSnapshotRequest") :: RemoteEvent
local snapshot_remote = remotes:WaitForChild("MarketSnapshot") :: RemoteEvent
local create_request = remotes:WaitForChild("MarketCreateRequest") :: RemoteEvent
local buy_request = remotes:WaitForChild("MarketBuyRequest") :: RemoteEvent
local cancel_request = remotes:WaitForChild("MarketCancelRequest") :: RemoteEvent
local action_result = remotes:WaitForChild("MarketActionResult") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "MarketPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(430, 500)
frame.Position = UDim2.new(0, 15, 0.5, -250)
frame.BackgroundTransparency = 0.12
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -10, 0, 30)
title.Position = UDim2.fromOffset(5, 5)
title.Text = "Limited Market - Systems Alpha"
title.Parent = frame
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -10, 0, 42)
status.Position = UDim2.fromOffset(5, 38)
status.TextWrapped = true
status.Text = "Requesting market snapshot..."
status.Parent = frame

local function input(placeholder: string, x: number, width: number): TextBox
    local box = Instance.new("TextBox")
    box.Size = UDim2.fromOffset(width, 30)
    box.Position = UDim2.fromOffset(x, 85)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.ClearTextOnFocus = false
    box.Parent = frame
    return box
end

local item_box = input("item_id", 5, 180)
local quantity_box = input("qty", 190, 60)
local price_box = input("price", 255, 80)

local create_button = Instance.new("TextButton")
create_button.Size = UDim2.fromOffset(85, 30)
create_button.Position = UDim2.fromOffset(340, 85)
create_button.Text = "List"
create_button.Parent = frame
local refresh_button = Instance.new("TextButton")
refresh_button.Size = UDim2.fromOffset(85, 28)
refresh_button.Position = UDim2.fromOffset(340, 120)
refresh_button.Text = "Refresh"
refresh_button.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -10, 1, -155)
list.Position = UDim2.fromOffset(5, 150)
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.ScrollBarThickness = 8
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.Parent = list

local function request_id(): string
    return HttpService:GenerateGUID(false)
end

create_button.Activated:Connect(function()
    create_request:FireServer(
        item_box.Text,
        tonumber(quantity_box.Text),
        tonumber(price_box.Text),
        request_id()
    )
end)
refresh_button.Activated:Connect(function()
    snapshot_request:FireServer()
end)
local function clear_rows()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end
end

local function add_listing_row(entry: any)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -10, 0, 44)
    row.Parent = list

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -180, 1, 0)
    text.BackgroundTransparency = 1
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Text = string.format(
        "%s x%d | %d Gold | Seller %s",
        tostring(entry.Item and entry.Item.ItemId),
        tonumber(entry.Item and entry.Item.Quantity) or 0,
        tonumber(entry.Price) or 0,
        tostring(entry.SellerUserId)
    )
    text.Parent = row

    local action = Instance.new("TextButton")
    action.Size = UDim2.fromOffset(80, 32)
    action.Position = UDim2.new(1, -170, 0, 6)
    action.Text = if entry.SellerUserId == player.UserId then "Cancel" else "Buy"
    action.Parent = row
    action.Activated:Connect(function()
        if entry.SellerUserId == player.UserId then
            cancel_request:FireServer(entry.ListingId, request_id())
        else
            buy_request:FireServer(entry.ListingId, request_id())
        end
    end)
end

snapshot_remote.OnClientEvent:Connect(function(snapshot: any)
    clear_rows()
    if not snapshot or snapshot.ok ~= true then
        status.Text = "Market unavailable: " .. tostring(snapshot and snapshot.reason)
        return
    end
    local listings = if type(snapshot.Listings) == "table" then snapshot.Listings else {}
    for _, entry in ipairs(listings) do
        add_listing_row(entry)
    end
    status.Text = string.format(
        "%d active listing%s visible. Tax is server-owned at 5%%.",
        #listings,
        if #listings == 1 then "" else "s"
    )
end)

action_result.OnClientEvent:Connect(function(response: any)
    if response and response.ok == true then
        status.Text = tostring(response.action) .. " succeeded."
    elseif response and response.pending_recovery == true then
        status.Text = tostring(response.action) .. " committed; recovery is pending."
    else
        status.Text = tostring(response and response.action or "Market")
            .. " failed: " .. tostring(response and response.reason)
    end
end)

snapshot_request:FireServer()
