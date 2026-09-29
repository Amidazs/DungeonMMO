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
local UiArt = require(
    shared:WaitForChild("UiArt")
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
card.Size = UDim2.fromOffset(382, 120)
card.BackgroundTransparency = 1
card.BorderSizePixel = 0
card.Parent = gui
local profile_art = UiArt.popup_background(
    card,
    1
)
profile_art.Name = "ProfileArt"
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
        then UDim2.fromOffset(12, 54)
        else UDim2.fromOffset(18, 18)
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

local portrait_frame = Instance.new("Frame")
portrait_frame.Name = "PortraitFrame"
portrait_frame.Position = UDim2.fromOffset(0, 0)
portrait_frame.Size = UDim2.fromOffset(110, 120)
portrait_frame.BackgroundTransparency = 1
portrait_frame.BorderSizePixel = 0
portrait_frame.ZIndex = 2
portrait_frame.Parent = card

local portrait_inner = Instance.new("Frame")
portrait_inner.Name = "PortraitInner"
portrait_inner.Position = UDim2.fromOffset(17, 8)
portrait_inner.Size = UDim2.fromOffset(76, 76)
portrait_inner.BackgroundColor3 = UiTheme.PALETTE.Backdrop
portrait_inner.BorderSizePixel = 0
portrait_inner.ZIndex = 2
UiTheme.add_corner(portrait_inner, 38)
portrait_inner.ClipsDescendants = true
portrait_inner.Parent = portrait_frame

local portrait = Instance.new("ImageLabel")
portrait.Name = "PlayerPortrait"
portrait.Position = UDim2.fromOffset(2, 2)
portrait.Size = UDim2.new(1, -4, 1, -4)
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

local level_value = UiComponents.label(
    portrait_frame,
    "LevelValue",
    "1",
    "Heading"
)
level_value.AnchorPoint = Vector2.new(0.5, 0.5)
level_value.Position = UDim2.fromOffset(29, 95)
level_value.Size = UDim2.fromOffset(29, 29)
level_value.BackgroundTransparency = 1
level_value.TextXAlignment = Enum.TextXAlignment.Center
level_value.TextSize = 16
level_value.ZIndex = 4
level_value.TextStrokeColor3 = UiTheme.PALETTE.Backdrop
level_value.TextStrokeTransparency = 0.1

local name_plate = Instance.new("Frame")
name_plate.Name = "NamePlate"
name_plate.Position = UDim2.fromOffset(112, 7)
name_plate.Size = UDim2.new(1, -124, 0, 28)
name_plate.BackgroundTransparency = 1
name_plate.BorderSizePixel = 0
name_plate.ZIndex = 2
name_plate.Parent = card

local player_name = UiComponents.label(
    name_plate,
    "PlayerName",
    player.DisplayName,
    "Heading"
)
player_name.Position = UDim2.fromOffset(4, 0)
player_name.Size = UDim2.new(1, -8, 0, 18)
player_name.TextSize = 17
player_name.ZIndex = 3

local class_label = UiComponents.label(
    name_plate,
    "ClassLabel",
    last_class,
    "Caption"
)
class_label.Position = UDim2.fromOffset(4, 17)
class_label.Size = UDim2.new(1, -8, 0, 11)
class_label.TextColor3 = UiTheme.PALETTE.AccentBright
class_label.TextSize = 9
class_label.ZIndex = 3

local health = UiComponents.progress_bar(
    card,
    "HealthBar",
    "HP",
    UiTheme.PALETTE.Health,
    UiTheme.PALETTE.HealthDark,
    27
)
health.Root.Position = UDim2.fromOffset(112, 36)
health.Root.Size = UDim2.new(1, -126, 0, 24)
health.Root.ZIndex = 3
health.Track.Position = UDim2.fromOffset(0, 11)
health.Track.Size = UDim2.new(1, 0, 0, 10)
health.Track.ZIndex = 3
health.Fill.ZIndex = 4
health.Label.ZIndex = 4
health.Value.ZIndex = 4
health.Label.Text = "HP"
health.Label.TextSize = 9
health.Value.TextSize = 9

local resource_stack = Instance.new("Frame")
resource_stack.Name = "ResourceStack"
resource_stack.Position = UDim2.fromOffset(112, 62)
resource_stack.Size = UDim2.new(1, -126, 0, 48)
resource_stack.BackgroundTransparency = 1
resource_stack.Visible = true
resource_stack.ZIndex = 3
resource_stack.Parent = card

local resource_layout = Instance.new("UIListLayout")
resource_layout.Padding = UDim.new(0, 0)
resource_layout.SortOrder = Enum.SortOrder.LayoutOrder
resource_layout.Parent = resource_stack

local currency_label = UiComponents.label(
    card,
    "CurrencyLabel",
    "0G  •  0AP  •  0SP",
    "Caption"
)
currency_label.Visible = false
currency_label.Position = UDim2.fromOffset(0, 0)
currency_label.Size = UDim2.fromOffset(1, 1)
currency_label.TextWrapped = true
currency_label.TextYAlignment = Enum.TextYAlignment.Top
currency_label.TextXAlignment = Enum.TextXAlignment.Center
currency_label.TextColor3 = UiTheme.PALETTE.TextMuted
currency_label.TextSize = 9

local xp = UiComponents.progress_bar(
    card,
    "ExperienceBar",
    "XP",
    UiTheme.PALETTE.Experience,
    UiTheme.PALETTE.AccentDark,
    18
)
xp.Root.Visible = false
xp.Root.Position = UDim2.fromOffset(0, 0)
xp.Root.Size = UDim2.fromOffset(1, 1)
xp.Track.Position = UDim2.fromOffset(0, 8)
xp.Track.Size = UDim2.new(1, 0, 0, 6)
xp.Label.Text = "XP"
xp.Label.TextSize = 8
xp.Label.Size = UDim2.new(0.25, 0, 0, 8)
xp.Value.TextSize = 8
xp.Value.Size = UDim2.new(0.75, 0, 0, 8)

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
