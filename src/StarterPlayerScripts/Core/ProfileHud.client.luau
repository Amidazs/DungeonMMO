--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local core = ReplicatedStorage:WaitForChild("Core")
local shared = core:WaitForChild("Shared")
local remotes = core:WaitForChild("Remotes")

local ProgressionClientState = require(
    script.Parent:WaitForChild("ProgressionClientState")
)
local UiArt = require(
    shared:WaitForChild("UiArt")
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

local HUD_WIDTH = 432
local HUD_HEIGHT = 129

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
card.Position = UDim2.fromOffset(16, 16)
card.Size = UDim2.fromOffset(HUD_WIDTH, HUD_HEIGHT)
card.BackgroundTransparency = 1
card.BorderSizePixel = 0
card.Parent = gui

UiArt.profile_background(card, 1)
UiTheme.bind_responsive_scale(card, 1366, 0.62, 1)

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

    card.Position = if camera.ViewportSize.X < 1180
        then UDim2.fromOffset(12, 52)
        else UDim2.fromOffset(16, 16)
end

local viewport_connection: RBXScriptConnection? = nil

--[[
Binds the status card to the active camera viewport.

Args:
    None.

Returns:
    None.
]]
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

local portrait_inner = Instance.new("Frame")
portrait_inner.Name = "PortraitInner"
portrait_inner.Position = UDim2.fromOffset(27, 9)
portrait_inner.Size = UDim2.fromOffset(72, 72)
portrait_inner.BackgroundColor3 = UiTheme.PALETTE.Backdrop
portrait_inner.BorderSizePixel = 0
portrait_inner.ClipsDescendants = true
portrait_inner.ZIndex = 2
UiTheme.add_corner(portrait_inner, 36)
portrait_inner.Parent = card

local portrait = Instance.new("ImageLabel")
portrait.Name = "PlayerPortrait"
portrait.Size = UDim2.fromScale(1, 1)
portrait.BackgroundTransparency = 1
portrait.ScaleType = Enum.ScaleType.Crop
portrait.ZIndex = 3
UiTheme.add_corner(portrait, 36)
portrait.Parent = portrait_inner

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

local player_name = UiComponents.label(
    card,
    "PlayerName",
    player.DisplayName,
    "Title"
)
player_name.Position = UDim2.fromOffset(119, 5)
player_name.Size = UDim2.fromOffset(203, 25)
player_name.TextColor3 = Color3.fromRGB(249, 239, 214)
player_name.TextSize = 22
player_name.TextStrokeColor3 = Color3.fromRGB(8, 5, 3)
player_name.TextStrokeTransparency = 0.28
player_name.ZIndex = 4

local level_value = UiComponents.label(
    card,
    "LevelValue",
    "1",
    "Title"
)
level_value.Position = UDim2.fromOffset(8, 84)
level_value.Size = UDim2.fromOffset(46, 36)
level_value.TextXAlignment = Enum.TextXAlignment.Center
level_value.TextColor3 = Color3.fromRGB(248, 239, 218)
level_value.TextSize = 23
level_value.TextStrokeColor3 = Color3.fromRGB(6, 4, 3)
level_value.TextStrokeTransparency = 0.18
level_value.ZIndex = 4

local class_label = UiComponents.label(
    card,
    "ClassLabel",
    last_class,
    "Caption"
)
class_label.Visible = false

local health_track = Instance.new("Frame")
health_track.Name = "HealthTrack"
health_track.Position = UDim2.fromOffset(124, 38)
health_track.Size = UDim2.fromOffset(285, 16)
health_track.BackgroundColor3 = Color3.fromRGB(39, 7, 10)
health_track.BackgroundTransparency = 0.04
health_track.BorderSizePixel = 0
health_track.ClipsDescendants = true
health_track.ZIndex = 2
UiTheme.add_corner(health_track, 5)
health_track.Parent = card

local health_fill = Instance.new("Frame")
health_fill.Name = "HealthFill"
health_fill.Size = UDim2.fromScale(1, 1)
health_fill.BackgroundColor3 = Color3.fromRGB(226, 25, 42)
health_fill.BorderSizePixel = 0
health_fill.ZIndex = 3
UiTheme.add_corner(health_fill, 5)
UiTheme.add_gradient(
    health_fill,
    Color3.fromRGB(255, 47, 65),
    Color3.fromRGB(153, 7, 21)
)
health_fill.Parent = health_track

local health_value = UiComponents.label(
    card,
    "HealthValue",
    "-- / --",
    "Heading"
)
health_value.Position = UDim2.fromOffset(124, 34)
health_value.Size = UDim2.fromOffset(285, 24)
health_value.TextXAlignment = Enum.TextXAlignment.Center
health_value.TextColor3 = Color3.fromRGB(255, 246, 229)
health_value.TextSize = 16
health_value.TextStrokeColor3 = Color3.new(0, 0, 0)
health_value.TextStrokeTransparency = 0.12
health_value.ZIndex = 5

local mana_track = Instance.new("Frame")
mana_track.Name = "ManaTrack"
mana_track.Position = UDim2.fromOffset(124, 64)
mana_track.Size = UDim2.fromOffset(285, 16)
mana_track.BackgroundColor3 = Color3.fromRGB(7, 18, 45)
mana_track.BackgroundTransparency = 0.04
mana_track.BorderSizePixel = 0
mana_track.ClipsDescendants = true
mana_track.ZIndex = 2
UiTheme.add_corner(mana_track, 5)
mana_track.Parent = card

local mana_fill = Instance.new("Frame")
mana_fill.Name = "ManaFill"
mana_fill.Size = UDim2.fromScale(1, 1)
mana_fill.BackgroundColor3 = Color3.fromRGB(25, 111, 226)
mana_fill.BorderSizePixel = 0
mana_fill.ZIndex = 3
UiTheme.add_corner(mana_fill, 5)
UiTheme.add_gradient(
    mana_fill,
    Color3.fromRGB(33, 150, 255),
    Color3.fromRGB(12, 64, 177)
)
mana_fill.Parent = mana_track

local mana_value = UiComponents.label(
    card,
    "ManaValue",
    "-- / --",
    "Heading"
)
mana_value.Position = UDim2.fromOffset(124, 60)
mana_value.Size = UDim2.fromOffset(285, 24)
mana_value.TextXAlignment = Enum.TextXAlignment.Center
mana_value.TextColor3 = Color3.fromRGB(255, 246, 229)
mana_value.TextSize = 16
mana_value.TextStrokeColor3 = Color3.new(0, 0, 0)
mana_value.TextStrokeTransparency = 0.12
mana_value.ZIndex = 5

local resource_stack = Instance.new("Frame")
resource_stack.Name = "ResourceStack"
resource_stack.Position = UDim2.fromOffset(124, 64)
resource_stack.Size = UDim2.fromOffset(285, 16)
resource_stack.BackgroundTransparency = 1
resource_stack.Visible = false
resource_stack.Parent = card

local progression_cache = Instance.new("Folder")
progression_cache.Name = "ProgressionDisplayState"
progression_cache.Parent = card

local level_cache = Instance.new("IntValue")
level_cache.Name = "Level"
level_cache.Parent = progression_cache

local xp_cache = Instance.new("IntValue")
xp_cache.Name = "XP"
xp_cache.Parent = progression_cache

local required_xp_cache = Instance.new("IntValue")
required_xp_cache.Name = "RequiredXP"
required_xp_cache.Parent = progression_cache

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
        health_value.Text = "-- / --"
        UiTheme.set_bar_ratio(health_fill, 0, true)
        return
    end

    local maximum = math.max(1, humanoid.MaxHealth)
    local current = math.max(0, humanoid.Health)
    health_value.Text = string.format(
        "%.0f / %.0f",
        current,
        maximum
    )
    UiTheme.set_bar_ratio(
        health_fill,
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
Updates the cached level and XP used by the bottom action bar.

Args:
    None.

Returns:
    None.
]]
local function update_progression_cache()
    local required = require(
        shared:WaitForChild("ProgressionConfig")
    ).get_required_xp(last_level)

    level_cache.Value = last_level
    xp_cache.Value = last_xp
    required_xp_cache.Value = required or 0
end

--[[
Renders progression identity values owned by the unit frame.

Args:
    None.

Returns:
    None.
]]
local function render_progression()
    level_value.Text = tostring(last_level)
    class_label.Text = last_class
    update_progression_cache()
end

--[[
Applies a progression snapshot to the status HUD.

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
    if type(identity) == "table" then
        if type(identity.ClassId) == "string"
            and identity.ClassId ~= "" then
            last_class = identity.ClassId
        elseif type(identity.BaseClassId) == "string"
            and identity.BaseClassId ~= "" then
            last_class = identity.BaseClassId
        end
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

-- Replicated combat resources are authoritative. Base may not expose combat MP.
local function update_mana()
    local maximum = tonumber(player:GetAttribute("CombatMaxMana")) or 0
    local current = tonumber(player:GetAttribute("CombatMana"))
    mana_value.Text = if maximum > 0 then string.format("%.0f / %.0f", math.clamp(current or maximum, 0, maximum), maximum) else "MP unavailable in Base"
    UiTheme.set_bar_ratio(mana_fill, if maximum > 0 then math.clamp(current or maximum, 0, maximum) / maximum else 0, true)
end
player:GetAttributeChangedSignal("CombatMana"):Connect(update_mana)
player:GetAttributeChangedSignal("CombatMaxMana"):Connect(update_mana)
update_mana()
