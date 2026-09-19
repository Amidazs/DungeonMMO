--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local ProgressionConfig = require(
    shared:WaitForChild("ProgressionConfig")
)
local ProgressionClientState = require(
    script.Parent:WaitForChild("ProgressionClientState")
)
local UiComponents = require(
    shared:WaitForChild("UiComponents")
)
local UiTheme = require(
    shared:WaitForChild("UiTheme")
)

local profile_snapshot = remotes:WaitForChild(
    "ProfileSnapshot"
) :: RemoteEvent
local progression_snapshot = remotes:WaitForChild(
    "ProgressionSnapshot"
) :: RemoteEvent

local last_level = 1
local last_xp = 0
local last_gold = 0
local last_ap = 0
local last_sp = 0
local last_class = "Adventurer"
local character_connections: {RBXScriptConnection} = {}

local player_gui = player:WaitForChild("PlayerGui")
local old = player_gui:FindFirstChild("ProfileHud")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "ProfileHud"
gui.ResetOnSpawn = false
gui.DisplayOrder = 120
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player_gui

local card = Instance.new("Frame")
card.Name = "StatusCard"
card.AnchorPoint = Vector2.new(0, 1)
card.Position = UDim2.new(0, 18, 1, -18)
card.Size = UDim2.fromOffset(330, 224)
UiTheme.style_panel(card, false)
card.Parent = gui
UiTheme.bind_responsive_scale(card, 1366, 0.78, 1)

local accent = Instance.new("Frame")
accent.Name = "Accent"
accent.Size = UDim2.new(0, 4, 1, -20)
accent.Position = UDim2.fromOffset(0, 10)
accent.BackgroundColor3 = UiTheme.PALETTE.Accent
accent.BorderSizePixel = 0
UiTheme.add_corner(accent, 2)
accent.Parent = card

local level_badge = Instance.new("Frame")
level_badge.Name = "LevelBadge"
level_badge.Position = UDim2.fromOffset(16, 14)
level_badge.Size = UDim2.fromOffset(48, 48)
level_badge.BackgroundColor3 = UiTheme.PALETTE.AccentDark
level_badge.BorderSizePixel = 0
UiTheme.add_corner(level_badge, 8)
UiTheme.add_stroke(
    level_badge,
    UiTheme.PALETTE.Accent,
    0.2
)
level_badge.Parent = card

local level_caption = UiComponents.label(
    level_badge,
    "LevelCaption",
    "LV",
    "Caption"
)
level_caption.Position = UDim2.fromOffset(0, 5)
level_caption.Size = UDim2.new(1, 0, 0, 12)
level_caption.TextXAlignment = Enum.TextXAlignment.Center
level_caption.TextColor3 = UiTheme.PALETTE.AccentBright

local level_value = UiComponents.label(
    level_badge,
    "LevelValue",
    "1",
    "Heading"
)
level_value.Position = UDim2.fromOffset(0, 17)
level_value.Size = UDim2.new(1, 0, 0, 26)
level_value.TextXAlignment = Enum.TextXAlignment.Center
level_value.TextSize = 20

local class_label = UiComponents.label(
    card,
    "ClassLabel",
    last_class,
    "Heading"
)
class_label.Position = UDim2.fromOffset(76, 13)
class_label.Size = UDim2.new(1, -92, 0, 24)

local currency_label = UiComponents.label(
    card,
    "CurrencyLabel",
    "0 GOLD   •   0 AP   •   0 SP",
    "Muted"
)
currency_label.Position = UDim2.fromOffset(76, 38)
currency_label.Size = UDim2.new(1, -92, 0, 20)

local health = UiComponents.progress_bar(
    card,
    "HealthBar",
    "HEALTH",
    UiTheme.PALETTE.Health,
    UiTheme.PALETTE.HealthDark,
    30
)
health.Root.Position = UDim2.fromOffset(16, 72)
health.Root.Size = UDim2.new(1, -32, 0, 30)

local xp = UiComponents.progress_bar(
    card,
    "ExperienceBar",
    "EXPERIENCE",
    UiTheme.PALETTE.Experience,
    UiTheme.PALETTE.AccentDark,
    30
)
xp.Root.Position = UDim2.fromOffset(16, 104)
xp.Root.Size = UDim2.new(1, -32, 0, 30)

local resource_stack = Instance.new("Frame")
resource_stack.Name = "ResourceStack"
resource_stack.Position = UDim2.fromOffset(16, 140)
resource_stack.Size = UDim2.new(1, -32, 0, 70)
resource_stack.BackgroundTransparency = 1
resource_stack.Parent = card

local resource_layout = Instance.new("UIListLayout")
resource_layout.Padding = UDim.new(0, 2)
resource_layout.SortOrder = Enum.SortOrder.LayoutOrder
resource_layout.Parent = resource_stack

--[[
Disconnects character-specific Health listeners.

Args:
    None.

Returns:
    None.
]]
local function disconnect_character()
    for _, connection in ipairs(character_connections) do
        connection:Disconnect()
    end
    table.clear(character_connections)
end

--[[
Updates the Health bar from the current Humanoid.

Args:
    humanoid (Humanoid?): Current local Humanoid.

Returns:
    None.
]]
local function update_health(humanoid: Humanoid?)
    if not humanoid then
        health.Value.Text = "-- / --"
        UiTheme.set_bar_ratio(health.Fill, 0, true)
        return
    end

    local maximum = math.max(1, humanoid.MaxHealth)
    local current = math.max(0, humanoid.Health)
    health.Value.Text = string.format(
        "%.0f / %.0f",
        current,
        maximum
    )
    UiTheme.set_bar_ratio(
        health.Fill,
        current / maximum
    )
end

--[[
Binds the status HUD to a newly spawned character.

Args:
    character (Model): New local character.

Returns:
    None.
]]
local function bind_character(character: Model)
    disconnect_character()

    local humanoid = character:WaitForChild(
        "Humanoid"
    ) :: Humanoid

    table.insert(
        character_connections,
        humanoid.HealthChanged:Connect(function()
            update_health(humanoid)
        end)
    )
    table.insert(
        character_connections,
        humanoid:GetPropertyChangedSignal(
            "MaxHealth"
        ):Connect(function()
            update_health(humanoid)
        end)
    )

    update_health(humanoid)
end

--[[
Renders level, XP and progression counters.

Args:
    None.

Returns:
    None.
]]
local function render_progression()
    local required = ProgressionConfig.get_required_xp(
        last_level
    )

    level_value.Text = tostring(last_level)
    class_label.Text = last_class
    currency_label.Text = string.format(
        "%d GOLD   •   %d AP   •   %d SP",
        last_gold,
        last_ap,
        last_sp
    )

    if required then
        xp.Value.Text = string.format(
            "%d / %d",
            last_xp,
            required
        )
        UiTheme.set_bar_ratio(
            xp.Fill,
            if required > 0
                then last_xp / required
                else 0
        )
    else
        xp.Value.Text = "MAX"
        UiTheme.set_bar_ratio(xp.Fill, 1)
    end
end

--[[
Applies a progression snapshot to the compact status HUD.

Args:
    payload (any): Server progression snapshot.

Returns:
    None.
]]
local function apply_progression(payload: any)
    if type(payload) ~= "table" then
        return
    end

    ProgressionClientState.apply_snapshot(payload)
    last_level = tonumber(payload.Level) or last_level
    last_xp = tonumber(payload.XP) or last_xp
    last_gold = tonumber(payload.Gold) or last_gold
    last_ap = tonumber(payload.APAvailable) or 0
    last_sp = tonumber(payload.SPAvailable) or 0

    local identity = payload.Identity
    if type(identity) == "table"
        and type(identity.BaseClassId) == "string" then
        last_class = identity.BaseClassId
    end

    render_progression()
end

--[[
Applies the lightweight profile snapshot.

Args:
    payload (any): Server profile snapshot.

Returns:
    None.
]]
local function apply_profile(payload: any)
    if type(payload) ~= "table" then
        return
    end

    last_level = tonumber(payload.Level) or last_level
    last_xp = tonumber(payload.XP) or last_xp
    last_gold = tonumber(payload.Gold) or last_gold
    render_progression()
end

profile_snapshot.OnClientEvent:Connect(apply_profile)
progression_snapshot.OnClientEvent:Connect(apply_progression)

player.CharacterAdded:Connect(bind_character)
player.CharacterRemoving:Connect(function()
    disconnect_character()
    update_health(nil)
end)

if player.Character then
    bind_character(player.Character)
else
    update_health(nil)
end

render_progression()

task.defer(function()
    profile_snapshot:FireServer("Request")
    progression_snapshot:FireServer("Request")
end)
