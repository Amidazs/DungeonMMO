--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local UiComponents = require(
    shared:WaitForChild("UiComponents")
)
local UiTheme = require(
    shared:WaitForChild("UiTheme")
)

local profile_gui = player:WaitForChild(
    "PlayerGui"
):WaitForChild("ProfileHud")
local status_card = profile_gui:WaitForChild(
    "StatusCard"
)
local resource_stack = status_card:WaitForChild(
    "ResourceStack"
)

local old = resource_stack:FindFirstChild(
    "StaminaBar"
)
if old then
    old:Destroy()
end

local stamina_bar = UiComponents.progress_bar(
    resource_stack,
    "StaminaBar",
    "STAMINA",
    UiTheme.PALETTE.Stamina,
    UiTheme.PALETTE.StaminaDark,
    20
)
stamina_bar.Root.LayoutOrder = 1
stamina_bar.Root.Size = UDim2.new(1, 0, 0, 20)
stamina_bar.Track.Position = UDim2.fromOffset(0, 13)
stamina_bar.Track.Size = UDim2.new(1, 0, 0, 6)
stamina_bar.Label.TextSize = 10
stamina_bar.Value.TextSize = 10

local parry = UiComponents.label(
    profile_gui,
    "ParryCue",
    "PERFECT PARRY",
    "Heading"
)
parry.AnchorPoint = Vector2.new(0.5, 1)
parry.Position = UDim2.new(0.5, 0, 1, -150)
parry.Size = UDim2.fromOffset(260, 34)
parry.TextXAlignment = Enum.TextXAlignment.Center
parry.TextColor3 = UiTheme.PALETTE.AccentBright
parry.TextStrokeColor3 = UiTheme.PALETTE.Backdrop
parry.TextStrokeTransparency = 0.25
parry.TextSize = 22
parry.Visible = false

--[[
Updates Stamina from replicated player attributes.

Args:
    None.

Returns:
    None.
]]
local function update_stamina()
    local current = tonumber(
        player:GetAttribute("CombatStamina")
    ) or 0
    local maximum = tonumber(
        player:GetAttribute("CombatMaxStamina")
    ) or 100
    local ratio = if maximum > 0
        then current / maximum
        else 0

    stamina_bar.Value.Text = string.format(
        "%.0f / %.0f",
        current,
        maximum
    )
    UiTheme.set_bar_ratio(
        stamina_bar.Fill,
        ratio
    )
end

--[[
Shows a brief server-confirmed parry cue.

Args:
    None.

Returns:
    None.
]]
local function show_parry()
    local pulse = player:GetAttribute(
        "CombatParryPulse"
    )

    parry.Visible = true
    parry.TextTransparency = 0

    task.delay(0.4, function()
        if player:GetAttribute(
            "CombatParryPulse"
        ) == pulse then
            parry.Visible = false
        end
    end)
end

update_stamina()

player:GetAttributeChangedSignal(
    "CombatStamina"
):Connect(update_stamina)
player:GetAttributeChangedSignal(
    "CombatMaxStamina"
):Connect(update_stamina)
player:GetAttributeChangedSignal(
    "CombatParryPulse"
):Connect(show_parry)
