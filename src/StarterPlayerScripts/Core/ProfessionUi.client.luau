--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local ItemDefinitions = require(shared:WaitForChild("ItemDefinitions"))
local ProfessionDefinitions = require(shared:WaitForChild("ProfessionDefinitions"))
local ProfessionRecipes = require(shared:WaitForChild("ProfessionRecipes"))

local profession_snapshot = remotes:WaitForChild("ProfessionSnapshot") :: RemoteEvent
local station_open = remotes:WaitForChild("ProfessionStationOpen") :: RemoteEvent
local craft_request = remotes:WaitForChild("ProfessionCraftRequest") :: RemoteEvent
local action_result = remotes:WaitForChild("ProfessionActionResult") :: RemoteEvent

local gui = Instance.new("ScreenGui")
gui.Name = "ProfessionUi"
gui.ResetOnSpawn = false
gui.DisplayOrder = 190
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(760, 560)
panel.BackgroundColor3 = Color3.fromRGB(24, 27, 31)
panel.BackgroundTransparency = 0.04
panel.BorderSizePixel = 0
panel.Visible = false
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(20, 14)
title.Size = UDim2.fromOffset(600, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(244, 238, 220)
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextScaled = true
title.Text = "Professions"
title.Parent = panel

local close = Instance.new("TextButton")
close.Position = UDim2.fromOffset(690, 14)
close.Size = UDim2.fromOffset(48, 40)
close.Text = "X"
close.Parent = panel

local progress = Instance.new("TextLabel")
progress.Position = UDim2.fromOffset(20, 62)
progress.Size = UDim2.fromOffset(718, 46)
progress.BackgroundTransparency = 0.25
progress.TextColor3 = Color3.fromRGB(228, 228, 220)
progress.TextXAlignment = Enum.TextXAlignment.Left
progress.Text = ""
progress.Parent = panel

local recipe_container = Instance.new("ScrollingFrame")
recipe_container.Position = UDim2.fromOffset(20, 122)
recipe_container.Size = UDim2.fromOffset(718, 360)
recipe_container.BackgroundTransparency = 0.15
recipe_container.BorderSizePixel = 0
recipe_container.ScrollBarThickness = 8
recipe_container.CanvasSize = UDim2.fromOffset(0, 0)
recipe_container.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = recipe_container

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(20, 494)
status.Size = UDim2.fromOffset(718, 44)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(220, 220, 220)
status.TextXAlignment = Enum.TextXAlignment.Left
status.TextWrapped = true
status.Text = "Gather materials, then use a profession station."
status.Parent = panel

local toast = Instance.new("TextLabel")
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.fromScale(0.5, 0.08)
toast.Size = UDim2.fromOffset(520, 54)
toast.BackgroundColor3 = Color3.fromRGB(25, 29, 31)
toast.BackgroundTransparency = 1
toast.TextColor3 = Color3.fromRGB(244, 240, 220)
toast.TextTransparency = 1
toast.TextScaled = true
toast.Visible = false
toast.Parent = gui
local toast_corner = Instance.new("UICorner")
toast_corner.CornerRadius = UDim.new(0, 8)
toast_corner.Parent = toast

local latest: any = nil
local station_id: string? = nil
local toast_serial = 0

local function item_name(item_id: string): string
    local definition = ItemDefinitions.get(item_id)
    return if definition then tostring(definition.Name) else item_id
end

local function profession_name(profession_id: any): string
    if type(profession_id) ~= "string" then
        return "Profession"
    end
    local definition = ProfessionDefinitions.get(profession_id)
    return if definition then tostring(definition.Name) else profession_id
end

local function show_toast(text: string)
    toast_serial += 1
    local serial = toast_serial
    toast.Text = text
    toast.Visible = true
    toast.BackgroundTransparency = 0.12
    toast.TextTransparency = 0

    task.delay(2.4, function()
        if serial ~= toast_serial then
            return
        end
        local tween = TweenService:Create(
            toast,
            TweenInfo.new(0.3),
            {
                BackgroundTransparency = 1,
                TextTransparency = 1,
            }
        )
        tween:Play()
        tween.Completed:Wait()
        if serial == toast_serial then
            toast.Visible = false
        end
    end)
end

local function clear_rows()
    for _, child in ipairs(recipe_container:GetChildren()) do
        if child ~= layout then
            child:Destroy()
        end
    end
end

local function count_item(item_id: string): number
    if not latest or type(latest.Inventory) ~= "table" then
        return 0
    end
    return math.max(0, math.floor(tonumber(latest.Inventory[item_id]) or 0))
end

--[[
Shows a one-time choice for each of the two profession categories.

Args:
    slots (any): Server-returned gathering and crafting selections.

Returns:
    nil: Renders only still-available choices; server authorizes clicks.
]]
local function render_choices(slots: any)
    title.Text = "Choose Your Professions"
    progress.Text = "  One gathering + one crafting profession per character."
    status.Text = "Your choices are permanent for now. Trade for other goods."
    clear_rows()

    for _, kind in {"Gathering", "Creation"} do
        local selected = slots[kind]
        for _, profession_id in ipairs(ProfessionDefinitions.order()) do
            local definition = ProfessionDefinitions.get(profession_id)
            if definition and definition.Kind == kind then
                local row = Instance.new("TextButton")
                row.Size = UDim2.new(1, -12, 0, 52)
                row.BackgroundColor3 = Color3.fromRGB(37, 41, 45)
                row.TextColor3 = Color3.fromRGB(244, 238, 220)
                row.TextScaled = false
                row.TextSize = 20
                row.Text = string.format(
                    "%s: %s%s",
                    if kind == "Creation" then "Crafting"
                        else "Gathering",
                    definition.Name,
                    if selected ~= "" then
                        (if selected == profession_id
                            then " (selected)" else " (unavailable)")
                    else " (choose)"
                )
                row.Active = selected == ""
                row.AutoButtonColor = selected == ""
                row.Parent = recipe_container
                if selected == "" then
                    row.MouseButton1Click:Connect(function()
                        status.Text = "Choosing " .. definition.Name .. "..."
                        profession_snapshot:FireServer({
                            Action = "ChooseProfession",
                            ProfessionId = profession_id,
                        })
                    end)
                end
            end
        end
    end
    task.defer(function()
        recipe_container.CanvasSize = UDim2.fromOffset(
            0, layout.AbsoluteContentSize.Y + 8
        )
    end)
end

--[[
Renders selected profession progress or the mandatory selection view.

Args:
    None.

Returns:
    nil: Updates only this existing, closable profession window.
]]
local function render()
    if not latest or latest.ok ~= true then
        return
    end
    local slots = latest.ProfessionSlots or {}
    if slots.Gathering == "" or slots.Creation == "" then
        render_choices(slots)
        return
    end
    if not station_id then
        return
    end

    local profession = ProfessionDefinitions.get(station_id)
    local state = latest.Professions and latest.Professions[station_id]
    local level = state and tonumber(state.Level) or 1
    local progress_xp = state and tonumber(state.Progress) or 0
    local needed = state and tonumber(state.XPToNext) or nil

    title.Text = (profession and profession.Name or station_id) .. " Station"
    local profession_label = profession and profession.Name or station_id
    progress.Text = if needed
        then string.format(
            "  %s Level %d   •   %d / %d Profession XP",
            profession_label,
            level,
            progress_xp,
            needed
        )
        else string.format(
            "  %s Level %d   •   Foundation profession maximum reached",
            profession_label,
            level
        )

    clear_rows()
    local recipes = ProfessionRecipes.for_station(station_id)
    if slots.Creation ~= station_id then
        status.Text = "You chose " .. profession_name(slots.Creation)
            .. ". Trade with a " .. profession_name(station_id)
            .. " crafter for these goods."
    else
        status.Text = "Server-authoritative crafting"
    end

    for _, recipe in ipairs(recipes) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -12, 0, 104)
        row.BackgroundTransparency = 0.08
        row.BackgroundColor3 = Color3.fromRGB(37, 41, 45)
        row.BorderSizePixel = 0
        row.Parent = recipe_container

        local row_corner = Instance.new("UICorner")
        row_corner.CornerRadius = UDim.new(0, 6)
        row_corner.Parent = row

        local name_label = Instance.new("TextLabel")
        name_label.Position = UDim2.fromOffset(12, 8)
        name_label.Size = UDim2.new(1, -170, 0, 26)
        name_label.BackgroundTransparency = 1
        name_label.TextColor3 = Color3.fromRGB(245, 240, 226)
        name_label.TextXAlignment = Enum.TextXAlignment.Left
        name_label.Text = recipe.Name
        name_label.Parent = row

        local requirement = Instance.new("TextLabel")
        requirement.Position = UDim2.fromOffset(12, 36)
        requirement.Size = UDim2.new(1, -170, 0, 54)
        requirement.BackgroundTransparency = 1
        requirement.TextColor3 = Color3.fromRGB(211, 214, 206)
        requirement.TextXAlignment = Enum.TextXAlignment.Left
        requirement.TextYAlignment = Enum.TextYAlignment.Top
        requirement.TextWrapped = true

        local pieces = {}
        local has_materials = true
        for _, input in ipairs(recipe.Inputs) do
            local owned = count_item(input.ItemId)
            if owned < input.Quantity then
                has_materials = false
            end
            table.insert(
                pieces,
                string.format("%s %d/%d", item_name(input.ItemId), owned, input.Quantity)
            )
        end
        requirement.Text = table.concat(pieces, "   •   ")
            .. "\nCreates: " .. item_name(recipe.Output.ItemId)
            .. "   •   +" .. tostring(recipe.XP)
            .. " " .. profession_name(recipe.ProfessionId) .. " XP"
        requirement.Parent = row

        local button = Instance.new("TextButton")
        button.Position = UDim2.new(1, -146, 0, 26)
        button.Size = UDim2.fromOffset(132, 52)
        button.Parent = row

        local unlocked = level >= recipe.RequiredLevel
            and slots.Creation == recipe.ProfessionId
        if slots.Creation ~= recipe.ProfessionId then
            button.Text = "Not Your Craft"
            button.Active = false
            button.AutoButtonColor = false
        elseif not unlocked then
            button.Text = "Level " .. tostring(recipe.RequiredLevel)
            button.Active = false
            button.AutoButtonColor = false
        elseif not has_materials then
            button.Text = "Need Materials"
            button.Active = false
            button.AutoButtonColor = false
        else
            button.Text = "Craft"
            button.Active = true
            button.MouseButton1Click:Connect(function()
                status.Text = "Crafting " .. recipe.Name .. "..."
                craft_request:FireServer(recipe.Id)
            end)
        end
    end

    task.defer(function()
        recipe_container.CanvasSize = UDim2.fromOffset(
            0,
            layout.AbsoluteContentSize.Y + 8
        )
    end)
end

station_open.OnClientEvent:Connect(function(payload: any)
    if type(payload) ~= "table" or payload.ok ~= true then
        show_toast("Profession station is not ready.")
        return
    end
    station_id = tostring(payload.StationId or "")
    latest = payload
    panel.Visible = true
    status.Text = "Server-authoritative crafting"
    render()
end)

profession_snapshot.OnClientEvent:Connect(function(payload: any)
    if type(payload) == "table" and payload.ok == true then
        latest = payload
        local slots = latest.ProfessionSlots or {}
        local needs_choice = slots.Gathering == ""
            or slots.Creation == ""
        if needs_choice then
            panel.Visible = true
        elseif not station_id then
            panel.Visible = false
        end
        if panel.Visible then
            render()
        end
    end
end)

action_result.OnClientEvent:Connect(function(payload: any)
    if type(payload) ~= "table" then
        return
    end

    if payload.action == "ChooseProfession" then
        if payload.ok == true then
            show_toast(
                profession_name(payload.profession_id)
                    .. " selected. Other professions require trading."
            )
        else
            show_toast(tostring(payload.reason or "ChoiceRejected"))
        end
        return
    end

    if payload.ok == true then
        local verb = if payload.action == "Craft" then "Crafted" else "Gathered"
        local item = if type(payload.item_id) == "string" then item_name(payload.item_id) else "profession item"
        local quantity = math.max(1, math.floor(tonumber(payload.quantity) or 1))
        local level_text = ""
        if tonumber(payload.level_after) and tonumber(payload.level_before)
            and payload.level_after > payload.level_before
        then
            level_text = "   •   Level " .. tostring(payload.level_after) .. "!"
        end
        local profession_label = profession_name(payload.profession_id)
        local text = string.format(
            "%s %dx %s   •   +%d %s XP%s",
            verb,
            quantity,
            item,
            math.max(0, math.floor(tonumber(payload.xp) or 0)),
            profession_label,
            level_text
        )
        status.Text = text
        show_toast(text)
    else
        local reason = tostring(payload.reason or "ActionRejected")
        if reason == "ResourceAlreadyGathered" or reason == "ResourceAlreadyClaimed" then
            reason = "You already gathered this resource during this run"
        elseif reason == "DungeonSessionNotReady" then
            reason = "Dungeon gathering session is not ready yet"
        elseif reason == "MissingMaterials" then
            reason = "Not enough materials"
        elseif reason == "ProfessionLevelTooLow" then
            reason = "Profession level is too low"
        elseif reason == "ProfessionNotSelected" then
            reason = "This is not your selected profession. Trade for its goods."
        elseif reason == "NotAtRequiredStation" then
            reason = "Move closer to the required station"
        elseif reason == "IngredientEquipped" then
            reason = "Unequip the item before using it as a crafting ingredient"
        end
        status.Text = reason
        show_toast(reason)
    end
end)

close.MouseButton1Click:Connect(function()
    panel.Visible = false
    station_id = nil
end)

profession_snapshot:FireServer("Request")
