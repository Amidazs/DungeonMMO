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
local UiOrnament = require(
    shared:WaitForChild("UiOrnament")
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
card.AnchorPoint = Vector2.new(0, 0)
card.Position = UDim2.fromOffset(18, 18)
card.Size = UDim2.fromOffset(410, 190)
UiTheme.style_panel(card, false)
card.Parent = gui
UiOrnament.frame(card, true)
UiTheme.bind_responsive_scale(card, 1366, 0.56, 1)

--[[
Keeps the unit frame below Roblox chrome on narrow Studio viewports.

Args:
    None.

Returns:
    None.
]]
local function update_status_position()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    card.AnchorPoint = Vector2.new(0, 0)
    card.Position = if camera.ViewportSize.X < 1180
        then UDim2.fromOffset(12, 54)
        else UDim2.fromOffset(18, 18)
end

local viewport_connection: RBXScriptConnection? = nil

-- Rebinds viewport updates when Roblox replaces the current camera.
local function bind_viewport()
    if viewport_connection then
        viewport_connection:Disconnect()
    end
    local camera = workspace.CurrentCamera
    if camera then
        viewport_connection = camera:GetPropertyChangedSignal(
            "ViewportSize"
        ):Connect(update_status_position)
    end
    update_status_position()
end

workspace:GetPropertyChangedSignal(
    "CurrentCamera"
):Connect(bind_viewport)
bind_viewport()

local accent = Instance.new("Frame")
accent.Name = "Accent"
accent.Size = UDim2.new(1, -36, 0, 2)
accent.Position = UDim2.fromOffset(18, 9)
accent.BackgroundColor3 = UiTheme.PALETTE.AccentBright
accent.BackgroundTransparency = 0.18
accent.BorderSizePixel = 0
accent.Parent = card

local level_badge = Instance.new("Frame")
level_badge.Name = "LevelBadge"
level_badge.Position = UDim2.fromOffset(18, 22)
level_badge.Size = UDim2.fromOffset(70, 70)
level_badge.BackgroundColor3 = UiTheme.PALETTE.SurfaceWarm
level_badge.BorderSizePixel = 0
UiTheme.add_corner(level_badge, 3)
local portrait_stroke = UiTheme.add_stroke(
    level_badge,
    UiTheme.PALETTE.AccentBright,
    0.05
)
portrait_stroke.Thickness = 2
level_badge.Parent = card

local portrait = Instance.new("ImageLabel")
portrait.Name = "PlayerPortrait"
portrait.Size = UDim2.fromScale(1, 1)
portrait.BackgroundTransparency = 1
portrait.ScaleType = Enum.ScaleType.Crop
portrait.ZIndex = 1
portrait.Parent = level_badge
UiTheme.add_corner(portrait, 2)

-- Display the real character headshot without assuming image ownership.
task.spawn(function()
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
    end)
    if ok then
        portrait.Image = image
    end
end)

local level_caption = UiComponents.label(
    level_badge,
    "LevelCaption",
    "LV",
    "Caption"
)
level_caption.Visible = false

local level_value = UiComponents.label(
    level_badge,
    "LevelValue",
    "1",
    "Heading"
)
level_value.AnchorPoint = Vector2.new(0.5, 0.5)
level_value.Position = UDim2.new(0, 3, 1, -3)
level_value.Size = UDim2.fromOffset(32, 32)
level_value.BackgroundTransparency = 0.04
level_value.BackgroundColor3 = UiTheme.PALETTE.Backdrop
level_value.ZIndex = 3
level_value.TextXAlignment = Enum.TextXAlignment.Center
level_value.TextSize = 18
UiTheme.add_corner(level_value, 16)
local level_stroke = UiTheme.add_stroke(
    level_value,
    UiTheme.PALETTE.AccentBright,
    0.04
)
level_stroke.Thickness = 2

local player_name = UiComponents.label(
    card,
    "PlayerName",
    player.DisplayName,
    "Title"
)
player_name.Position = UDim2.fromOffset(102, 17)
player_name.Size = UDim2.new(1, -120, 0, 27)
player_name.TextSize = 22

local class_label = UiComponents.label(
    card,
    "ClassLabel",
    last_class,
    "Muted"
)
class_label.Position = UDim2.fromOffset(103, 43)
class_label.Size = UDim2.new(1, -121, 0, 18)
class_label.TextColor3 = UiTheme.PALETTE.AccentBright

local currency_label = UiComponents.label(
    card,
    "CurrencyLabel",
    "0 GOLD   •   0 AP   •   0 SP",
    "Caption"
)
currency_label.Position = UDim2.fromOffset(18, 102)
currency_label.Size = UDim2.fromOffset(70, 48)
currency_label.TextWrapped = true
currency_label.TextYAlignment = Enum.TextYAlignment.Top
currency_label.TextColor3 = UiTheme.PALETTE.TextMuted

local health = UiComponents.progress_bar(
    card,
    "HealthBar",
    "HEALTH",
    UiTheme.PALETTE.Health,
    UiTheme.PALETTE.HealthDark,
    30
)
health.Root.Position = UDim2.fromOffset(102, 64)
health.Root.Size = UDim2.new(1, -120, 0, 30)
health.Label.Text = "HP"

local xp = UiComponents.progress_bar(
    card,
    "ExperienceBar",
    "EXPERIENCE",
    UiTheme.PALETTE.Experience,
    UiTheme.PALETTE.AccentDark,
    30
)
xp.Root.Position = UDim2.fromOffset(18, 158)
xp.Root.Size = UDim2.new(1, -36, 0, 27)
xp.Label.Text = "XP"

local resource_stack = Instance.new("Frame")
resource_stack.Name = "ResourceStack"
resource_stack.Position = UDim2.fromOffset(102, 98)
resource_stack.Size = UDim2.new(1, -120, 0, 58)
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
