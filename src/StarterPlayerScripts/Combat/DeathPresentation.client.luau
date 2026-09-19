--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local UiComponents = require(
    shared:WaitForChild("UiComponents")
)
local UiTheme = require(
    shared:WaitForChild("UiTheme")
)

local FADE_SECONDS = 0.35
local DEATH_BACKGROUND_TRANSPARENCY = 0.24

local screen_gui = Instance.new("ScreenGui")
screen_gui.Name = "DeathPresentation"
screen_gui.IgnoreGuiInset = true
screen_gui.ResetOnSpawn = false
screen_gui.DisplayOrder = 1000
screen_gui.Parent = player_gui

local backdrop = Instance.new("Frame")
backdrop.Name = "Backdrop"
backdrop.Size = UDim2.fromScale(1, 1)
backdrop.BackgroundColor3 = Color3.fromRGB(18, 5, 7)
backdrop.BackgroundTransparency = 1
backdrop.BorderSizePixel = 0
backdrop.Parent = screen_gui

local title = UiComponents.label(
    backdrop,
    "Title",
    "DEFEATED",
    "Title"
)
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.fromScale(0.5, 0.46)
title.Size = UDim2.fromOffset(520, 58)
title.TextXAlignment = Enum.TextXAlignment.Center
title.TextSize = 34
title.TextColor3 = UiTheme.PALETTE.Text
title.TextStrokeColor3 = Color3.fromRGB(40, 5, 8)
title.TextStrokeTransparency = 0.35
title.TextTransparency = 1

local subtitle = UiComponents.label(
    backdrop,
    "Subtitle",
    "Your expedition is not over yet.",
    "Muted"
)
subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
subtitle.Position = UDim2.fromScale(0.5, 0.53)
subtitle.Size = UDim2.fromOffset(520, 30)
subtitle.TextXAlignment = Enum.TextXAlignment.Center
subtitle.TextTransparency = 1

local death_serial = 0

--[[
Shows the death presentation.

Args:
    None.

Returns:
    None.
]]
local function show_death()
    death_serial += 1
    backdrop.BackgroundTransparency =
        DEATH_BACKGROUND_TRANSPARENCY
    title.TextTransparency = 0
    subtitle.TextTransparency = 0
end

--[[
Fades the death presentation after a fresh character spawns.

Args:
    expected_serial (number): Death sequence expected by the caller.

Returns:
    None.
]]
local function hide_death(expected_serial: number)
    if expected_serial ~= death_serial then
        return
    end

    TweenService:Create(
        backdrop,
        TweenInfo.new(FADE_SECONDS),
        {BackgroundTransparency = 1}
    ):Play()
    TweenService:Create(
        title,
        TweenInfo.new(FADE_SECONDS),
        {TextTransparency = 1}
    ):Play()
    TweenService:Create(
        subtitle,
        TweenInfo.new(FADE_SECONDS),
        {TextTransparency = 1}
    ):Play()
end

--[[
Hooks death presentation for one local character.

Args:
    character (Model): Newly spawned local character.

Returns:
    None.
]]
local function track_character(character: Model)
    local humanoid = character:WaitForChild(
        "Humanoid"
    ) :: Humanoid
    local spawn_serial = death_serial

    if spawn_serial > 0 then
        hide_death(spawn_serial)
    end

    humanoid.Died:Connect(show_death)
end

player.CharacterAdded:Connect(track_character)

if player.Character then
    track_character(player.Character)
end
