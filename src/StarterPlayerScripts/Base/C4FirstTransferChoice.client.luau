--!strict
-- Original C4 class choice; selecting a path never awards an unbuilt quest.
-- Existing custom advanced profiles are left untouched until migration.
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remotes = RS:WaitForChild("Core"):WaitForChild("Remotes")
local requests = remotes:WaitForChild("ClassAdvancementRequest")
local snapshots = remotes:WaitForChild("ClassAdvancementSnapshot")
local results = remotes:WaitForChild("ClassAdvancementResult")
local progression = remotes:WaitForChild("ProgressionSnapshot")

local gui = Instance.new("ScreenGui")
gui.Name = "C4FirstTransferChoiceUi"
gui.DisplayOrder = 208
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local toggle = Instance.new("TextButton")
toggle.Name = "ClassPathButton"
toggle.Size = UDim2.fromOffset(128, 34)
toggle.Position = UDim2.new(1, -144, 0, 16)
toggle.BackgroundColor3 = Color3.fromRGB(38, 47, 58)
toggle.TextColor3 = Color3.fromRGB(244, 229, 195)
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 14
toggle.Text = "Class Path"
toggle.Visible = false
toggle.Parent = gui

local panel = Instance.new("Frame")
panel.Name = "ClassPathPanel"
panel.Size = UDim2.fromScale(0.72, 0.69)
panel.Position = UDim2.fromScale(0.14, 0.155)
panel.BackgroundColor3 = Color3.fromRGB(22, 29, 37)
panel.Visible = false
panel.Parent = gui

local constraint = Instance.new("UISizeConstraint")
constraint.MaxSize = Vector2.new(720, 575)
constraint.MinSize = Vector2.new(370, 380)
constraint.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(16, 12)
title.Size = UDim2.new(1, -72, 0, 42)
title.Text = "Choose your first class path"
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(242, 226, 189)
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.Parent = panel

local close = Instance.new("TextButton")
close.Name = "CloseButton"
close.Size = UDim2.fromOffset(40, 36)
close.Position = UDim2.new(1, -47, 0, 12)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.fromRGB(240, 240, 240)
close.BackgroundColor3 = Color3.fromRGB(70, 51, 53)
close.Parent = panel

local description = Instance.new("TextLabel")
description.Position = UDim2.new(0, 16, 0, 58)
description.Size = UDim2.new(1, -32, 0, 65)
description.BackgroundTransparency = 1
description.TextWrapped = true
description.TextXAlignment = Enum.TextXAlignment.Left
description.TextYAlignment = Enum.TextYAlignment.Top
description.TextColor3 = Color3.fromRGB(201, 208, 217)
description.Font = Enum.Font.Gotham
description.TextSize = 14
description.Text = "At level 18, select an original C4 advancement path."
description.Parent = panel

local options = Instance.new("ScrollingFrame")
options.Name = "SourceClassOptions"
options.Position = UDim2.new(0, 16, 0, 135)
options.Size = UDim2.new(1, -32, 1, -213)
options.BackgroundTransparency = 1
options.BorderSizePixel = 0
options.ScrollBarThickness = 5
options.AutomaticCanvasSize = Enum.AutomaticSize.Y
options.CanvasSize = UDim2.fromOffset(0, 0)
options.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 9)
layout.Parent = options

local status = Instance.new("TextLabel")
status.Name = "ClassPathStatus"
status.Position = UDim2.new(0, 16, 1, -70)
status.Size = UDim2.new(1, -32, 0, 52)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.TextYAlignment = Enum.TextYAlignment.Center
status.TextXAlignment = Enum.TextXAlignment.Left
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(244, 197, 132)
status.Parent = panel

local latest: any = nil
local pending = false
local dismissed = false
local last_level: number? = nil

--[[
Clears only server-supplied path buttons, preserving the UI layout.

Args:
    None.

Returns:
    nil: Removes stale choices from a previous race/class snapshot.
]]
local function clear_options()
    for _, child in ipairs(options:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
end

--[[
Renders a single exact source branch from the authoritative server.

Args:
    entry (any): Server-selected original race/family class option.
    state (any): Authoritative selected class and level permission.

Returns:
    nil: Adds a bound click handler for this original C4 branch only.
]]
local function add_option(entry: any, state: any)
    local button = Instance.new("TextButton")
    button.Name = entry.Id .. "Choice"
    button.Size = UDim2.new(1, -6, 0, 105)
    button.TextWrapped = true
    button.TextXAlignment = Enum.TextXAlignment.Left
    button.Font = Enum.Font.Gotham
    button.TextSize = 15
    button.TextColor3 = Color3.fromRGB(249, 237, 207)
    local selected = state.SelectedClassId == entry.Id
    button.BackgroundColor3 = if selected
        then Color3.fromRGB(55, 74, 69)
        else Color3.fromRGB(42, 51, 63)
    local skills_note = if entry.SkillInventoryStatus
        == "DungeonMMOAnaloguesMapped"
        then tostring(entry.MappedAnalogueRanks)
            .. " DungeonMMO rank analogues; exact C4 audit pending"
        elseif entry.SkillInventoryStatus
            == "OriginalC4Level20SourceMapped"
        then tostring(entry.ExactOriginalLevel20RankEntries)
            .. " original C4 level-20 ranks documented; not yet playable"
        else "Original C4 class skills not yet inventoried"
    button.Text = "  " .. entry.DisplayName
        .. (if selected then "  — SELECTED" else "")
        .. "\n  " .. entry.QuestName
        .. "\n  Skills: " .. skills_note
        .. "\n  Advancement quest: "
        .. (if entry.QuestWorldReady and entry.QuestImplemented
            then "Available" else "Not yet playable")
    button.Active = state.CanChoose == true and not pending
    button.AutoButtonColor = button.Active
    button.Parent = options
    button.Activated:Connect(function()
        if not state.CanChoose or pending then return end
        pending = true
        status.Text = "Saving your chosen C4 class path..."
        requests:FireServer("SelectFirstTransfer", entry.Id)
    end)
end

--[[
Updates the visible, closable choice window from a genuine server snapshot.

Args:
    snapshot (any): Existing server class advancement snapshot payload.

Returns:
    nil: Never predicts or writes a class identity on the client.
]]
local function render(snapshot: any)
    local state = snapshot and snapshot.OriginalFirstTransfer
    local quest = snapshot and snapshot.OriginalQuest
    latest = state
    toggle.Visible = type(state) == "table" and state.ok == true
    if not toggle.Visible then
        panel.Visible = false
        return
    end
    pending = false
    clear_options()
    for _, entry in ipairs(state.Options or {}) do
        add_option(entry, state)
    end
    if state.LegacyAdvancementNeedsMigration then
        status.Text = "Existing class progression is preserved; migration is pending."
    elseif state.SelectedClassId then
        if quest and quest.ok and quest.Started then
            status.Text = "Original quest stage "
                .. tostring(quest.Step)
                .. " started. The remaining dungeon stages and full "
                .. "advancement quest are still in development."
        elseif quest and quest.ok and quest.WorldReady then
            status.Text = "Visit your original C4 quest NPC near the "
                .. "hub arrival point. The full advancement quest is still "
                .. "in development; no advanced class is awarded yet."
        else
            status.Text = "Your chosen path is saved. Its original "
                .. "advancement quest is still in development."
        end
    elseif state.CanChoose then
        status.Text = "Select one path. Selection does not award a class or bypass its quest."
    else
        status.Text = "Original class choices open at level 18."
    end
    if state.CanChoose and not dismissed then
        panel.Visible = true
    end
end

close.Activated:Connect(function()
    dismissed = true
    panel.Visible = false
end)

toggle.Activated:Connect(function()
    if latest and latest.ok then
        panel.Visible = not panel.Visible
        if panel.Visible then dismissed = false end
    end
end)

snapshots.OnClientEvent:Connect(render)

results.OnClientEvent:Connect(function(response)
    if not pending then return end
    pending = false
    if response and response.ok then
        status.Text = "Class path saved; its original quest is not yet implemented."
    else
        status.Text = "Choice rejected: "
            .. tostring(response and response.reason or "Unknown")
    end
    requests:FireServer("Snapshot")
end)

progression.OnClientEvent:Connect(function(snapshot)
    local level = snapshot and snapshot.Level
    if type(level) == "number" and level ~= last_level then
        last_level = level
        requests:FireServer("Snapshot")
    end
end)

requests:FireServer("Snapshot")
