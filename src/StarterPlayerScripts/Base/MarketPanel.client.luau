--!strict
local HttpService = game:GetService("HttpService")
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
local UiComponents = require(
    shared:WaitForChild("UiComponents")
)
local UiTheme = require(
    shared:WaitForChild("UiTheme")
)

local snapshot_request = remotes:WaitForChild(
    "MarketSnapshotRequest"
) :: RemoteEvent
local snapshot_remote = remotes:WaitForChild(
    "MarketSnapshot"
) :: RemoteEvent
local create_request = remotes:WaitForChild(
    "MarketCreateRequest"
) :: RemoteEvent
local buy_request = remotes:WaitForChild(
    "MarketBuyRequest"
) :: RemoteEvent
local cancel_request = remotes:WaitForChild(
    "MarketCancelRequest"
) :: RemoteEvent
local action_result = remotes:WaitForChild(
    "MarketActionResult"
) :: RemoteEvent

local ACCESS_DISTANCE = 15

local player_gui = player:WaitForChild("PlayerGui")
local old = player_gui:FindFirstChild("MarketPanel")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "MarketPanel"
gui.ResetOnSpawn = false
gui.DisplayOrder = 182
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player_gui

local modal = UiComponents.modal(
    gui,
    "AuctionHousePanel",
    "Auction House",
    "Browse player listings or offer an item for sale.",
    UDim2.fromOffset(820, 570)
)
local panel = modal.Root
panel.Visible = false
UiTheme.bind_responsive_scale(
    panel,
    1366,
    0.72,
    1
)

local sell_heading = UiComponents.section_heading(
    modal.Body,
    "SELL ITEM"
)
sell_heading.Size = UDim2.new(1, 0, 0, 18)

local sell_bar = Instance.new("Frame")
sell_bar.Name = "SellBar"
sell_bar.Position = UDim2.fromOffset(0, 24)
sell_bar.Size = UDim2.new(1, 0, 0, 48)
sell_bar.BackgroundTransparency = 1
sell_bar.Parent = modal.Body

--[[
Creates one themed auction input box.

Args:
    parent (Instance): Parent container.
    name (string): Instance name.
    placeholder (string): Placeholder text.
    position (UDim2): Input position.
    size (UDim2): Input size.

Returns:
    TextBox: Configured input box.
]]
local function create_input(
    parent: Instance,
    name: string,
    placeholder: string,
    position: UDim2,
    size: UDim2
): TextBox
    local box = Instance.new("TextBox")
    box.Name = name
    box.Position = position
    box.Size = size
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

local item_box = create_input(
    sell_bar,
    "ItemId",
    "Item ID",
    UDim2.fromOffset(0, 4),
    UDim2.new(0.47, -6, 0, 40)
)

local quantity_box = create_input(
    sell_bar,
    "Quantity",
    "Qty",
    UDim2.new(0.47, 2, 0, 4),
    UDim2.new(0.13, -4, 0, 40)
)

local price_box = create_input(
    sell_bar,
    "Price",
    "Gold",
    UDim2.new(0.60, 4, 0, 4),
    UDim2.new(0.18, -4, 0, 40)
)

local create_button = UiComponents.button(
    sell_bar,
    "ListItem",
    "List Item",
    "Primary"
)
create_button.AnchorPoint = Vector2.new(1, 0)
create_button.Position = UDim2.new(1, 0, 0, 4)
create_button.Size = UDim2.new(0.20, -4, 0, 40)

local browse_heading = UiComponents.section_heading(
    modal.Body,
    "ACTIVE LISTINGS"
)
browse_heading.Position = UDim2.fromOffset(0, 86)
browse_heading.Size = UDim2.new(0.6, 0, 0, 18)

local refresh_button = UiComponents.button(
    modal.Body,
    "Refresh",
    "Refresh",
    "Ghost"
)
refresh_button.AnchorPoint = Vector2.new(1, 0)
refresh_button.Position = UDim2.new(1, 0, 0, 80)
refresh_button.Size = UDim2.fromOffset(104, 32)

local list = Instance.new("ScrollingFrame")
list.Name = "Listings"
list.Position = UDim2.fromOffset(0, 112)
list.Size = UDim2.new(1, 0, 1, -162)
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
UiTheme.style_scroll(list)
list.Parent = modal.Body

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.Parent = list

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.Parent = list

local status = UiComponents.label(
    modal.Body,
    "Status",
    "Interact with the Auction House to browse listings.",
    "Muted"
)
status.AnchorPoint = Vector2.new(0, 1)
status.Position = UDim2.new(0, 0, 1, 0)
status.Size = UDim2.new(1, 0, 0, 38)
status.TextWrapped = true

local market_anchor: BasePart? = nil
local distance_elapsed = 0

--[[
Creates a unique request ID for idempotent market operations.

Args:
    None.

Returns:
    string: GUID request ID.
]]
local function request_id(): string
    return HttpService:GenerateGUID(false)
end

--[[
Removes generated auction listing rows.

Args:
    None.

Returns:
    None.
]]
local function clear_rows()
    for _, child in ipairs(list:GetChildren()) do
        if child ~= layout
            and child ~= padding
            and child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

--[[
Creates one readable auction listing row.

Args:
    entry (any): Sanitized market listing snapshot entry.

Returns:
    None.
]]
local function add_listing_row(entry: any)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 62)
    row.BackgroundColor3 = UiTheme.PALETTE.SurfaceRaised
    row.BackgroundTransparency = 0.08
    row.BorderSizePixel = 0
    UiTheme.add_corner(row, 7)
    UiTheme.add_stroke(
        row,
        UiTheme.PALETTE.BorderSoft,
        0.58
    )
    row.Parent = list

    local item_id = tostring(
        entry.Item and entry.Item.ItemId or "Unknown Item"
    )
    local quantity = tonumber(
        entry.Item and entry.Item.Quantity
    ) or 0

    local name = UiComponents.label(
        row,
        "Item",
        string.format("%s  x%d", item_id, quantity),
        "Heading"
    )
    name.Position = UDim2.fromOffset(14, 8)
    name.Size = UDim2.new(0.48, 0, 0, 22)

    local seller = UiComponents.label(
        row,
        "Seller",
        "Seller " .. tostring(entry.SellerUserId),
        "Muted"
    )
    seller.Position = UDim2.fromOffset(14, 33)
    seller.Size = UDim2.new(0.42, 0, 0, 18)

    local price = UiComponents.label(
        row,
        "Price",
        tostring(tonumber(entry.Price) or 0) .. " Gold",
        "Heading"
    )
    price.AnchorPoint = Vector2.new(1, 0.5)
    price.Position = UDim2.new(1, -108, 0.5, 0)
    price.Size = UDim2.fromOffset(150, 28)
    price.TextXAlignment = Enum.TextXAlignment.Right
    price.TextColor3 = UiTheme.PALETTE.AccentBright

    local own_listing = entry.SellerUserId == player.UserId
    local action = UiComponents.button(
        row,
        "Action",
        if own_listing then "Cancel" else "Buy",
        if own_listing then "Danger" else "Primary"
    )
    action.AnchorPoint = Vector2.new(1, 0.5)
    action.Position = UDim2.new(1, -10, 0.5, 0)
    action.Size = UDim2.fromOffset(86, 38)

    action.Activated:Connect(function()
        if own_listing then
            cancel_request:FireServer(
                entry.ListingId,
                request_id()
            )
        else
            buy_request:FireServer(
                entry.ListingId,
                request_id()
            )
        end
    end)
end

--[[
Shows or hides the contextual Auction House window.

Args:
    visible (boolean): Desired panel visibility.

Returns:
    None.
]]
local function set_visible(visible: boolean)
    panel.Visible = visible

    if visible then
        status.Text = "Loading auction listings..."
        snapshot_request:FireServer()
    end
end

--[[
Connects the Auction House world prompt to the window.

Args:
    None.

Returns:
    None.
]]
local function connect_market_prompt()
    market_anchor = EnvironmentAnchorClient.wait_for(
        "Base",
        "Base.Travel.Market",
        15
    )

    if not market_anchor then
        return
    end

    local prompt = market_anchor:FindFirstChild(
        "AuctionHousePrompt"
    )
    if prompt and prompt:IsA("ProximityPrompt") then
        prompt.Triggered:Connect(function()
            set_visible(true)
        end)
    end
end

--[[
Closes the Auction House window when the player leaves its area.

Args:
    delta (number): Heartbeat delta time.

Returns:
    None.
]]
local function update_distance(delta: number)
    if not panel.Visible or not market_anchor then
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

    if (
        root.Position - market_anchor.Position
    ).Magnitude > ACCESS_DISTANCE then
        set_visible(false)
    end
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

modal.Close.Activated:Connect(function()
    set_visible(false)
end)

snapshot_remote.OnClientEvent:Connect(function(snapshot: any)
    clear_rows()

    if not snapshot or snapshot.ok ~= true then
        status.Text = "Auction House unavailable: "
            .. tostring(snapshot and snapshot.reason)
        return
    end

    local listings = if type(snapshot.Listings) == "table"
        then snapshot.Listings
        else {}

    for _, entry in ipairs(listings) do
        add_listing_row(entry)
    end

    status.Text = string.format(
        "%d active listing%s  |  5%% market tax",
        #listings,
        if #listings == 1 then "" else "s"
    )
end)

action_result.OnClientEvent:Connect(function(response: any)
    if response and response.ok == true then
        status.Text = tostring(response.action)
            .. " succeeded."
        snapshot_request:FireServer()
    elseif response
        and response.pending_recovery == true then
        status.Text = tostring(response.action)
            .. " committed; recovery is pending."
    else
        status.Text = tostring(
            response and response.action or "Market"
        )
            .. " failed: "
            .. tostring(response and response.reason)
    end
end)

task.spawn(connect_market_prompt)
RunService.Heartbeat:Connect(update_distance)
