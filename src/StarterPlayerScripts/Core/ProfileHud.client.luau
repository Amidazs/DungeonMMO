--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")

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
local UiArtAssets = require(
    shared:WaitForChild("UiArtAssets")
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

local party_snapshot = remotes:FindFirstChild(
    "PartySnapshot"
)
local party_action_request = remotes:FindFirstChild(
    "PartyActionRequest"
)

local HUD_WIDTH = 432
local HUD_HEIGHT = 144
local NAME_X = 120
local NAME_Y = 30
local NAME_MIN_WIDTH = 93
local NAME_MAX_WIDTH = 240
local NAME_HORIZONTAL_PADDING = 14
local BUFF_COLUMNS = 7
local BUFF_SLOT_WIDTH = 29
local BUFF_SLOT_HEIGHT = 29
local BUFF_SLOT_GAP = 3

local BUFF_DEFINITIONS = table.freeze({
    {
        Id = "PhysicalPower",
        Attribute = "C4PhysicalPowerBonus",
        Icon = UiArtAssets.PROFILE_BUFF_AURA,
    },
    {
        Id = "PhysicalGuard",
        Attribute = "C4PhysicalGuardBonus",
        Icon = UiArtAssets.PROFILE_BUFF_GUARD,
    },
    {
        Id = "Fortress",
        Attribute = "C4FortressDualDefenseBonus",
        Icon = UiArtAssets.PROFILE_BUFF_GUARD,
    },
    {
        Id = "BowGuard",
        Attribute = "C4BowGuardBonus",
        Icon = UiArtAssets.PROFILE_BUFF_GUARD,
    },
    {
        Id = "Evasion",
        Attribute = "C4EvasionBonus",
        Icon = UiArtAssets.PROFILE_BUFF_NATURE,
    },
    {
        Id = "MagicPower",
        Attribute = "C4MagicPowerBonus",
        Icon = UiArtAssets.PROFILE_BUFF_ARCANE,
    },
    {
        Id = "Movement",
        Attribute = "C4MovementBonus",
        Icon = UiArtAssets.PROFILE_BUFF_NATURE,
    },
})

local last_level = 1
local last_xp = 0
local last_gold = 0
local last_ap = 0
local last_sp = 0
local last_class = "Adventurer"
local last_max_mana = 0
local latest_party_leader_user_id: number? = nil
local character_connections: {RBXScriptConnection} = {}
local update_mana: () -> ()
local refresh_buffs: () -> ()

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
card.ClipsDescendants = false
card.Parent = gui

UiArt.profile_background(card, 1)
UiTheme.bind_responsive_scale(card, 1366, 0.56, 0.78)

--[[
Formats an integer with thousands separators for HUD resource values.

Args:
    value (number): Resource value to display.

Returns:
    string: Rounded integer using comma separators.
]]
local function format_number(value: number): string
    local text = tostring(math.floor(value + 0.5))
    local formatted = text

    while true do
        local next_text, count = string.gsub(
            formatted,
            "^(-?%d+)(%d%d%d)",
            "%1,%2"
        )
        formatted = next_text

        if count == 0 then
            break
        end
    end

    return formatted
end

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
portrait_inner.Position = UDim2.fromOffset(36, 33)
portrait_inner.Size = UDim2.fromOffset(75, 75)
portrait_inner.BackgroundColor3 = UiTheme.PALETTE.Backdrop
portrait_inner.BorderSizePixel = 0
portrait_inner.ClipsDescendants = true
portrait_inner.ZIndex = 4
UiTheme.add_corner(portrait_inner, 38)
portrait_inner.Parent = card

local portrait_outline = Instance.new("UIStroke")
portrait_outline.Name = "PortraitGoldOutline"
portrait_outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
portrait_outline.Color = Color3.fromRGB(223, 171, 58)
portrait_outline.Thickness = 1.1
portrait_outline.Transparency = 0.08
portrait_outline.Parent = portrait_inner

local portrait = Instance.new("ImageLabel")
portrait.Name = "PlayerPortrait"
portrait.Size = UDim2.fromScale(1, 1)
portrait.BackgroundTransparency = 1
portrait.ScaleType = Enum.ScaleType.Crop
portrait.ZIndex = 5
UiTheme.add_corner(portrait, 38)
portrait.Parent = portrait_inner

task.spawn(function()
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(
            player.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size352x352
        )
    end)

    if ok then
        portrait.Image = image
    end
end)

local name_extension = Instance.new("Frame")
name_extension.Name = "NameExtension"
name_extension.Position = UDim2.fromOffset(
    NAME_X + NAME_MIN_WIDTH - 4,
    29
)
name_extension.Size = UDim2.fromOffset(0, 23)
name_extension.BackgroundColor3 = Color3.fromRGB(13, 12, 13)
name_extension.BackgroundTransparency = 0.04
name_extension.BorderSizePixel = 0
name_extension.Visible = false
name_extension.ZIndex = 2
UiTheme.add_corner(name_extension, 4)
name_extension.Parent = card

local name_extension_stroke = Instance.new("UIStroke")
name_extension_stroke.Name = "GoldBorder"
name_extension_stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
name_extension_stroke.Color = Color3.fromRGB(187, 126, 25)
name_extension_stroke.Thickness = 1.5
name_extension_stroke.Transparency = 0.05
name_extension_stroke.Parent = name_extension

local player_name = UiComponents.label(
    card,
    "PlayerName",
    player.DisplayName,
    "Title"
)
player_name.Position = UDim2.fromOffset(NAME_X, NAME_Y)
player_name.Size = UDim2.fromOffset(NAME_MIN_WIDTH, 21)
player_name.TextColor3 = Color3.fromRGB(249, 239, 214)
player_name.TextSize = 18
player_name.TextStrokeColor3 = Color3.fromRGB(8, 5, 3)
player_name.TextStrokeTransparency = 0.28
player_name.TextTruncate = Enum.TextTruncate.None
player_name.ZIndex = 5

local party_crown = Instance.new("ImageLabel")
party_crown.Name = "PartyLeaderCrown"
party_crown.Position = UDim2.fromOffset(223, 31)
party_crown.Size = UDim2.fromOffset(16, 12)
party_crown.BackgroundTransparency = 1
party_crown.Image = UiArtAssets.PROFILE_PARTY_CROWN
party_crown.ScaleType = Enum.ScaleType.Fit
party_crown.Visible = false
party_crown.ZIndex = 6
party_crown.Parent = card

--[[
Resizes the name presentation so long display names keep their natural size.

The supplied painted HUD remains the base shell. Only the dark name rail is
extended when the measured text needs more room, so the portrait and HP/MP
art are never stretched.

Args:
    None.

Returns:
    None.
]]
local function update_name_layout()
    local measured = TextService:GetTextSize(
        player_name.Text,
        player_name.TextSize,
        player_name.Font,
        Vector2.new(NAME_MAX_WIDTH, 21)
    )
    local requested_width = measured.X
        + NAME_HORIZONTAL_PADDING
    local name_width = math.clamp(
        requested_width,
        NAME_MIN_WIDTH,
        NAME_MAX_WIDTH
    )
    local extension_width = math.max(
        0,
        name_width - NAME_MIN_WIDTH
    )

    player_name.Size = UDim2.fromOffset(name_width, 21)
    name_extension.Size = UDim2.fromOffset(
        extension_width,
        23
    )
    name_extension.Visible = extension_width > 0

    party_crown.Position = UDim2.fromOffset(
        NAME_X + name_width + 10,
        31
    )
end

update_name_layout()

local level_value = UiComponents.label(
    card,
    "LevelValue",
    "1",
    "Title"
)
level_value.Position = UDim2.fromOffset(17, 84)
level_value.Size = UDim2.fromOffset(31, 31)
level_value.TextXAlignment = Enum.TextXAlignment.Center
level_value.TextYAlignment = Enum.TextYAlignment.Center
level_value.TextColor3 = Color3.fromRGB(248, 239, 218)
level_value.TextSize = 21
level_value.TextStrokeColor3 = Color3.fromRGB(6, 4, 3)
level_value.TextStrokeTransparency = 0.18
level_value.ZIndex = 6

local class_label = UiComponents.label(
    card,
    "ClassLabel",
    last_class,
    "Caption"
)
class_label.Visible = false

local health_track = Instance.new("Frame")
health_track.Name = "HealthTrack"
health_track.Position = UDim2.fromOffset(126, 59)
health_track.Size = UDim2.fromOffset(274, 15)
health_track.BackgroundColor3 = Color3.fromRGB(31, 8, 11)
health_track.BackgroundTransparency = 1
health_track.BorderSizePixel = 0
health_track.ClipsDescendants = true
health_track.ZIndex = 2
UiTheme.add_corner(health_track, 2)
health_track.Parent = card

local health_fill = Instance.new("Frame")
health_fill.Name = "HealthFill"
health_fill.Size = UDim2.fromScale(0, 1)
health_fill.BackgroundColor3 = Color3.fromRGB(150, 22, 30)
health_fill.BorderSizePixel = 0
health_fill.ZIndex = 3
UiTheme.add_corner(health_fill, 2)
UiTheme.add_gradient(
    health_fill,
    Color3.fromRGB(185, 39, 44),
    Color3.fromRGB(105, 10, 24)
)
health_fill.Parent = health_track

local health_value = UiComponents.label(
    card,
    "HealthValue",
    "-- / --",
    "Heading"
)
health_value.Position = UDim2.fromOffset(126, 56)
health_value.Size = UDim2.fromOffset(274, 21)
health_value.TextXAlignment = Enum.TextXAlignment.Center
health_value.TextColor3 = Color3.fromRGB(255, 246, 229)
health_value.TextSize = 15
health_value.TextStrokeColor3 = Color3.new(0, 0, 0)
health_value.TextStrokeTransparency = 0.12
health_value.ZIndex = 5

local mana_track = Instance.new("Frame")
mana_track.Name = "ManaTrack"
mana_track.Position = UDim2.fromOffset(126, 79)
mana_track.Size = UDim2.fromOffset(274, 15)
mana_track.BackgroundColor3 = Color3.fromRGB(6, 14, 35)
mana_track.BackgroundTransparency = 1
mana_track.BorderSizePixel = 0
mana_track.ClipsDescendants = true
mana_track.ZIndex = 2
UiTheme.add_corner(mana_track, 2)
mana_track.Parent = card

local mana_fill = Instance.new("Frame")
mana_fill.Name = "ManaFill"
mana_fill.Size = UDim2.fromScale(0, 1)
mana_fill.BackgroundColor3 = Color3.fromRGB(35, 90, 175)
mana_fill.BorderSizePixel = 0
mana_fill.ZIndex = 3
UiTheme.add_corner(mana_fill, 2)
UiTheme.add_gradient(
    mana_fill,
    Color3.fromRGB(39, 120, 205),
    Color3.fromRGB(12, 45, 115)
)
mana_fill.Parent = mana_track

local mana_value = UiComponents.label(
    card,
    "ManaValue",
    "-- / --",
    "Heading"
)
mana_value.Position = UDim2.fromOffset(126, 76)
mana_value.Size = UDim2.fromOffset(274, 21)
mana_value.TextXAlignment = Enum.TextXAlignment.Center
mana_value.TextColor3 = Color3.fromRGB(255, 246, 229)
mana_value.TextSize = 15
mana_value.TextStrokeColor3 = Color3.new(0, 0, 0)
mana_value.TextStrokeTransparency = 0.12
mana_value.ZIndex = 5

local buff_container = Instance.new("Frame")
buff_container.Name = "BuffContainer"
buff_container.Position = UDim2.fromOffset(123, 101)
buff_container.Size = UDim2.fromOffset(245, 64)
buff_container.BackgroundTransparency = 1
buff_container.BorderSizePixel = 0
buff_container.ClipsDescendants = false
buff_container.ZIndex = 5
buff_container.Parent = card

local buff_layout = Instance.new("UIGridLayout")
buff_layout.Name = "BuffLayout"
buff_layout.CellSize = UDim2.fromOffset(
    BUFF_SLOT_WIDTH,
    BUFF_SLOT_HEIGHT
)
buff_layout.CellPadding = UDim2.fromOffset(
    BUFF_SLOT_GAP,
    BUFF_SLOT_GAP
)
buff_layout.FillDirectionMaxCells = BUFF_COLUMNS
buff_layout.SortOrder = Enum.SortOrder.LayoutOrder
buff_layout.Parent = buff_container

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
Refreshes the party-leader crown from Base party state or Dungeon metadata.

Args:
    None.

Returns:
    None.
]]
local function refresh_party_crown()
    local dungeon_leader = tonumber(
        player:GetAttribute("PartyLeaderUserId")
    )
    local leader_user_id =
        latest_party_leader_user_id
        or dungeon_leader

    party_crown.Visible =
        leader_user_id ~= nil
        and leader_user_id > 0
        and leader_user_id == player.UserId
end

--[[
Applies the latest Base party snapshot to the local crown.

Args:
    payload (any): PartySnapshot server payload.

Returns:
    None.
]]
local function apply_party_snapshot(payload: any)
    local party = if type(payload) == "table"
        then payload.Party
        else nil

    latest_party_leader_user_id =
        if type(party) == "table"
            then tonumber(party.LeaderUserId)
            else nil

    refresh_party_crown()
end

--[[
Removes runtime-created buff slots while preserving the grid layout.

Args:
    None.

Returns:
    None.
]]
local function clear_buff_slots()
    for _, child in ipairs(buff_container:GetChildren()) do
        if child ~= buff_layout
            and child:IsA("GuiObject")
        then
            child:Destroy()
        end
    end
end

--[[
Creates one visible active-buff slot.

Args:
    definition (any): HUD buff definition.
    order (number): Stable display order.

Returns:
    None.
]]
local function create_buff_slot(
    definition: any,
    order: number
)
    local slot = Instance.new("Frame")
    slot.Name = tostring(definition.Id) .. "Buff"
    slot.LayoutOrder = order
    slot.BackgroundTransparency = 1
    slot.BorderSizePixel = 0
    slot.ZIndex = 6
    slot.Parent = buff_container

    local frame_art = Instance.new("ImageLabel")
    frame_art.Name = "FrameArt"
    frame_art.Size = UDim2.fromScale(1, 1)
    frame_art.BackgroundTransparency = 1
    frame_art.Image = UiArtAssets.PROFILE_BUFF_SLOT
    frame_art.ScaleType = Enum.ScaleType.Stretch
    frame_art.ZIndex = 6
    frame_art.Parent = slot

    local icon = Instance.new("ImageLabel")
    icon.Name = "BuffIcon"
    icon.Position = UDim2.fromOffset(4, 4)
    icon.Size = UDim2.new(1, -8, 1, -8)
    icon.BackgroundTransparency = 1
    icon.Image = tostring(definition.Icon)
    icon.ScaleType = Enum.ScaleType.Crop
    icon.ZIndex = 7
    icon.Parent = slot

    slot:SetAttribute(
        "BuffId",
        tostring(definition.Id)
    )
end

--[[
Rebuilds active buff icons from replicated server-authored status values.

A buff has no slot when inactive. The grid supports seven icons on the
reference row and automatically continues onto further rows when future
systems expose more simultaneous buffs.

Args:
    None.

Returns:
    None.
]]
refresh_buffs = function()
    clear_buff_slots()

    local character = player.Character
    if not character then
        return
    end

    local order = 0
    for _, definition in ipairs(BUFF_DEFINITIONS) do
        local magnitude = tonumber(
            character:GetAttribute(
                tostring(definition.Attribute)
            )
        ) or 0

        if magnitude > 0 then
            order += 1
            create_buff_slot(
                definition,
                order
            )
        end
    end
end

--[[
Disconnects character-specific Health and buff listeners.

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
        "%s / %s",
        format_number(current),
        format_number(maximum)
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

    for _, definition in ipairs(BUFF_DEFINITIONS) do
        table.insert(
            character_connections,
            character:GetAttributeChangedSignal(
                tostring(definition.Attribute)
            ):Connect(refresh_buffs)
        )
    end

    update_health(humanoid)
    refresh_buffs()
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
    last_max_mana = math.max(
        0,
        tonumber(payload.MaxMana) or last_max_mana
    )

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
    update_mana()
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

if party_snapshot and party_snapshot:IsA("RemoteEvent") then
    party_snapshot.OnClientEvent:Connect(
        apply_party_snapshot
    )
end

player:GetAttributeChangedSignal(
    "PartyLeaderUserId"
):Connect(refresh_party_crown)

player.CharacterAdded:Connect(bind_character)
player.CharacterRemoving:Connect(function()
    disconnect_character()
    update_health(nil)
    refresh_buffs()
end)

if player.Character then
    bind_character(player.Character)
else
    update_health(nil)
    refresh_buffs()
end

render_progression()
refresh_party_crown()

task.defer(function()
    profile_snapshot:FireServer("Request")
    progression_snapshot:FireServer("Request")

    if party_action_request
        and party_action_request:IsA("RemoteEvent")
    then
        party_action_request:FireServer({
            Action = "RequestSnapshot",
        })
    end
end)

--[[
Updates MP from live combat attributes or the server progression snapshot.

The combat service owns current MP inside dungeons. Base does not run that
service, so the progression snapshot supplies the authoritative maximum and
Base presents it as full while the player is out of combat.

Args:
    None.

Returns:
    None.
]]
update_mana = function()
    local combat_maximum = tonumber(
        player:GetAttribute("CombatMaxMana")
    ) or 0
    local combat_current = tonumber(
        player:GetAttribute("CombatMana")
    )

    local maximum = if combat_maximum > 0
        then combat_maximum
        else last_max_mana

    if maximum <= 0 then
        mana_value.Text = "-- / --"
        UiTheme.set_bar_ratio(
            mana_fill,
            0,
            true
        )
        return
    end

    local current = if combat_maximum > 0
        then math.clamp(
            combat_current or maximum,
            0,
            maximum
        )
        else maximum

    mana_value.Text = string.format(
        "%s / %s",
        format_number(current),
        format_number(maximum)
    )
    UiTheme.set_bar_ratio(
        mana_fill,
        current / maximum
    )
end

player:GetAttributeChangedSignal(
    "CombatMana"
):Connect(update_mana)
player:GetAttributeChangedSignal(
    "CombatMaxMana"
):Connect(update_mana)
update_mana()
