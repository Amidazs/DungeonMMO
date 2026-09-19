--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local combat_shared = ReplicatedStorage
    :WaitForChild("Combat")
    :WaitForChild("Shared")
local core_shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local draw_rules = require(
    combat_shared:WaitForChild("RangerDrawRules")
)
local UiComponents = require(
    core_shared:WaitForChild("UiComponents")
)
local UiTheme = require(
    core_shared:WaitForChild("UiTheme")
)

local gui = Instance.new("ScreenGui")
gui.Name = "RangerDrawGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 126
gui.Parent = player:WaitForChild("PlayerGui")

local card = Instance.new("Frame")
card.Name = "DrawCard"
card.AnchorPoint = Vector2.new(0.5, 1)
card.Position = UDim2.new(0.5, 0, 1, -126)
card.Size = UDim2.fromOffset(260, 50)
card.Visible = false
UiTheme.style_panel(card, false)
card.Parent = gui

local caption = UiComponents.label(
    card,
    "Caption",
    "BOW DRAW",
    "Caption"
)
caption.Position = UDim2.fromOffset(12, 6)
caption.Size = UDim2.new(0.45, 0, 0, 14)
caption.TextColor3 = UiTheme.PALETTE.Accent

local tier_label = UiComponents.label(
    card,
    "Tier",
    "",
    "Heading"
)
tier_label.AnchorPoint = Vector2.new(1, 0)
tier_label.Position = UDim2.new(1, -12, 0, 5)
tier_label.Size = UDim2.new(0.5, 0, 0, 18)
tier_label.TextXAlignment = Enum.TextXAlignment.Right

local track = Instance.new("Frame")
track.Position = UDim2.fromOffset(12, 30)
track.Size = UDim2.new(1, -24, 0, 8)
track.BackgroundColor3 = UiTheme.PALETTE.AccentDark
track.BorderSizePixel = 0
UiTheme.add_corner(track, 4)
track.Parent = card

local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(0, 1)
fill.BackgroundColor3 = UiTheme.PALETTE.Accent
fill.BorderSizePixel = 0
UiTheme.add_corner(fill, 4)
fill.Parent = track

--[[
Returns the authoritative current bow-draw duration.

Args:
    None.

Returns:
    number?: Draw duration while a draw is active.
]]
local function current_draw_elapsed(): number?
    local character = player.Character

    if not character
        or character:GetAttribute(
            "RangerDrawing"
        ) ~= true then
        return nil
    end

    local started_at = character:GetAttribute(
        "RangerDrawStartedAt"
    )
    if type(started_at) ~= "number"
        or started_at <= 0 then
        return nil
    end

    return math.max(
        0,
        Workspace:GetServerTimeNow() - started_at
    )
end

--[[
Refreshes the draw-state indicator.

Args:
    None.

Returns:
    None.
]]
local function refresh()
    local elapsed = current_draw_elapsed()

    if elapsed == nil then
        card.Visible = false
        return
    end

    local tier = draw_rules.classify(elapsed)
    local ratio = math.clamp(
        elapsed / draw_rules.FULL_DRAW_SECONDS,
        0,
        1
    )

    card.Visible = true
    tier_label.Text = string.upper(
        tostring(tier.Tier)
    )
    UiTheme.set_bar_ratio(fill, ratio)
end

RunService.RenderStepped:Connect(refresh)
refresh()
