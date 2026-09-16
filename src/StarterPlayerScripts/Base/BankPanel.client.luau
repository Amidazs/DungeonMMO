--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local BankConfig = require(shared:WaitForChild("BankConfig"))
local EnvironmentAnchorClient = require(
    shared:WaitForChild("EnvironmentAnchorClient")
)

local snapshot_request =
    remotes:WaitForChild("BankSnapshotRequest") :: RemoteEvent
local snapshot_remote =
    remotes:WaitForChild("BankSnapshot") :: RemoteEvent
local deposit_request =
    remotes:WaitForChild("BankDepositRequest") :: RemoteEvent
local withdraw_request =
    remotes:WaitForChild("BankWithdrawRequest") :: RemoteEvent
local action_result =
    remotes:WaitForChild("BankActionResult") :: RemoteEvent
local dungeon_entry_result =
    remotes:FindFirstChild("DungeonEntryResult")

local gui = Instance.new("ScreenGui")
gui.Name = "BankPanel"
gui.ResetOnSpawn = false
gui.DisplayOrder = 190
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(820, 520)
panel.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
panel.Visible = false
panel.Parent = gui

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(18, 10)
title.Size = UDim2.fromOffset(420, 36)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(245, 245, 245)
title.TextScaled = true
title.Text = "Account Bank"
title.Parent = panel

local capacity = Instance.new("TextLabel")
capacity.Position = UDim2.fromOffset(560, 12)
capacity.Size = UDim2.fromOffset(180, 32)
capacity.BackgroundTransparency = 1
capacity.TextColor3 = Color3.fromRGB(220, 220, 220)
capacity.TextScaled = true
capacity.Text = "0 / 40"
capacity.Parent = panel

local close = Instance.new("TextButton")
close.Position = UDim2.fromOffset(764, 10)
close.Size = UDim2.fromOffset(38, 34)
close.Text = "X"
close.Parent = panel

local inventory_title = Instance.new("TextLabel")
inventory_title.Position = UDim2.fromOffset(18, 58)
inventory_title.Size = UDim2.fromOffset(350, 28)
inventory_title.BackgroundTransparency = 1
inventory_title.TextColor3 = Color3.fromRGB(235, 235, 235)
inventory_title.Text = "Inventory"
inventory_title.TextScaled = true
inventory_title.Parent = panel

local bank_title = Instance.new("TextLabel")
bank_title.Position = UDim2.fromOffset(452, 58)
bank_title.Size = UDim2.fromOffset(350, 28)
bank_title.BackgroundTransparency = 1
bank_title.TextColor3 = Color3.fromRGB(235, 235, 235)
bank_title.Text = "Bank"
bank_title.TextScaled = true
bank_title.Parent = panel

local function make_list(x: number): ScrollingFrame
    local frame = Instance.new("ScrollingFrame")
    frame.Position = UDim2.fromOffset(x, 92)
    frame.Size = UDim2.fromOffset(350, 286)
    frame.BackgroundColor3 = Color3.fromRGB(34, 36, 43)
    frame.BorderSizePixel = 0
    frame.CanvasSize = UDim2.fromOffset(0, 0)
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.ScrollBarThickness = 8
    frame.Parent = panel

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = frame

    return frame
end

local inventory_list = make_list(18)
local bank_list = make_list(452)

local selected = Instance.new("TextLabel")
selected.Position = UDim2.fromOffset(18, 392)
selected.Size = UDim2.fromOffset(784, 34)
selected.BackgroundTransparency = 1
selected.TextXAlignment = Enum.TextXAlignment.Left
selected.TextColor3 = Color3.fromRGB(230, 230, 230)
selected.TextScaled = true
selected.Text = "Select an item."
selected.Parent = panel

local quantity_label = Instance.new("TextLabel")
quantity_label.Position = UDim2.fromOffset(18, 438)
quantity_label.Size = UDim2.fromOffset(90, 34)
quantity_label.BackgroundTransparency = 1
quantity_label.Text = "Quantity"
quantity_label.TextColor3 = Color3.fromRGB(230, 230, 230)
quantity_label.TextScaled = true
quantity_label.Parent = panel

local quantity_box = Instance.new("TextBox")
quantity_box.Position = UDim2.fromOffset(116, 438)
quantity_box.Size = UDim2.fromOffset(90, 34)
quantity_box.Text = "1"
quantity_box.ClearTextOnFocus = false
quantity_box.Parent = panel

local transfer = Instance.new("TextButton")
transfer.Position = UDim2.fromOffset(222, 438)
transfer.Size = UDim2.fromOffset(180, 34)
transfer.Text = "Deposit"
transfer.Parent = panel

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(418, 430)
status.Size = UDim2.fromOffset(384, 58)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.TextColor3 = Color3.fromRGB(220, 220, 220)
status.TextScaled = true
status.Text = ""
status.Parent = panel

local current_snapshot: any = nil
local selected_side: string? = nil
local selected_row: any = nil
local pending = false
local bank_anchor: BasePart? = nil

local function clear_rows(frame: ScrollingFrame)
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
end

local function row_text(row: any, inventory_side: boolean): string
    local suffix = ""
    if inventory_side and row.Bankable == false then
        suffix = " • NOT BANKABLE"
    elseif inventory_side
        and (tonumber(row.EquippedQuantity) or 0) > 0
    then
        suffix = string.format(
            " • %d equipped",
            tonumber(row.EquippedQuantity) or 0
        )
    end

    return string.format(
        "%s  x%d  [%s]%s",
        tostring(row.Name or row.ItemId),
        tonumber(row.Quantity) or 0,
        tostring(row.Rarity or "Basic"),
        suffix
    )
end

local function select_row(side: string, row: any)
    selected_side = side
    selected_row = row
    quantity_box.Text = "1"

    selected.Text = string.format(
        "%s • %s • owned %d",
        tostring(row.Name or row.ItemId),
        tostring(row.Category or row.Kind or "Item"),
        tonumber(row.Quantity) or 0
    )

    transfer.Text = if side == "Inventory"
        then "Deposit"
        else "Withdraw"
end

local function add_row(
    frame: ScrollingFrame,
    side: string,
    row: any
)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -8, 0, 36)
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Text = "  " .. row_text(row, side == "Inventory")
    button.Parent = frame
    button.Activated:Connect(function()
        select_row(side, row)
    end)
end

local function render(snapshot: any)
    current_snapshot = snapshot
    clear_rows(inventory_list)
    clear_rows(bank_list)

    capacity.Text = string.format(
        "%d / %d",
        tonumber(snapshot.UsedSlots) or 0,
        tonumber(snapshot.Capacity) or BankConfig.CAPACITY
    )

    for _, row in ipairs(snapshot.Inventory or {}) do
        add_row(inventory_list, "Inventory", row)
    end

    for _, row in ipairs(snapshot.Items or {}) do
        add_row(bank_list, "Bank", row)
    end
end

local function requested_quantity(): number?
    local value = tonumber(quantity_box.Text)
    if not value or not selected_row or not selected_side then
        return nil
    end

    value = math.floor(value)
    if value < 1 then
        return nil
    end

    local available = if selected_side == "Inventory"
        then tonumber(selected_row.AvailableQuantity) or 0
        else tonumber(selected_row.Quantity) or 0

    available = math.floor(available)
    if available < 1 then
        return nil
    end

    return math.min(value, available)
end

local function set_pending(value: boolean)
    pending = value
    transfer.Active = not value
    transfer.AutoButtonColor = not value
end

transfer.Activated:Connect(function()
    if pending or not selected_row or not selected_side then
        return
    end

    local amount = requested_quantity()
    if not amount then
        status.Text = "Enter a positive whole-number quantity."
        return
    end

    set_pending(true)
    status.Text = "Requesting authoritative transfer..."

    if selected_side == "Inventory" then
        deposit_request:FireServer(selected_row.ItemId, amount)
    else
        withdraw_request:FireServer(selected_row.ItemId, amount)
    end
end)

close.Activated:Connect(function()
    if not pending then
        panel.Visible = false
    end
end)

snapshot_remote.OnClientEvent:Connect(function(snapshot: any)
    if type(snapshot) ~= "table" or snapshot.ok ~= true then
        return
    end

    set_pending(false)
    status.Text = ""
    render(snapshot)
    panel.Visible = true
end)

action_result.OnClientEvent:Connect(function(result: any)
    if type(result) ~= "table" then
        return
    end

    set_pending(false)

    if result.ok == true then
        status.Text = "Transfer complete."
        selected_side = nil
        selected_row = nil
        selected.Text = "Select an item."
    else
        status.Text = "Bank action blocked: "
            .. tostring(result.reason or "Rejected")
    end
end)

if dungeon_entry_result and dungeon_entry_result:IsA("RemoteEvent") then
    dungeon_entry_result.OnClientEvent:Connect(function(payload: any)
        if type(payload) == "table" and payload.ok == true then
            panel.Visible = false
            selected_side = nil
            selected_row = nil
        end
    end)
end

task.spawn(function()
    bank_anchor = EnvironmentAnchorClient.wait_for(
        "Base",
        "Base.Service.Bank",
        15
    )

    if not bank_anchor then
        return
    end

    local prompt = bank_anchor:FindFirstChild("BankPrompt")
    if prompt and prompt:IsA("ProximityPrompt") then
        prompt.Triggered:Connect(function()
            if pending then
                return
            end
            status.Text = "Loading Bank..."
            snapshot_request:FireServer()
        end)
    end
end)

local elapsed = 0
RunService.Heartbeat:Connect(function(delta: number)
    if not panel.Visible or not bank_anchor then
        return
    end

    elapsed += delta
    if elapsed < 0.25 then
        return
    end
    elapsed = 0

    local character = player.Character
    local root = character
        and character:FindFirstChild("HumanoidRootPart")

    if not root or not root:IsA("BasePart") then
        panel.Visible = false
        return
    end

    if not (
        (root.Position - bank_anchor.Position).Magnitude
        <= BankConfig.ACCESS_DISTANCE
    ) then
        panel.Visible = false
        status.Text = "Moved away from Bank."
        selected_side = nil
        selected_row = nil
    end
end)
