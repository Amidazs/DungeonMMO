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
local resource_stack = profile_gui
    :WaitForChild("StatusCard")
    :WaitForChild("ResourceStack")

local old = resource_stack:FindFirstChild("WardBar")
if old then
    old:Destroy()
end

local ward_bar = UiComponents.progress_bar(
    resource_stack,
    "WardBar",
    "WARD",
    UiTheme.PALETTE.Ward,
    UiTheme.PALETTE.WardDark,
    20
)
ward_bar.Root.LayoutOrder = 3
ward_bar.Root.Size = UDim2.new(1, 0, 0, 20)
ward_bar.Track.Position = UDim2.fromOffset(0, 13)
ward_bar.Track.Size = UDim2.new(1, 0, 0, 6)
ward_bar.Label.TextSize = 10
ward_bar.Value.TextSize = 10
ward_bar.Root.Visible = false

local character_connections: {RBXScriptConnection} = {}

--[[
Disconnects Ward listeners from the previous character.

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
Updates Ward amount and visibility.

Args:
    None.

Returns:
    None.
]]
local function update_value()
    local character = player.Character
    if not character then
        ward_bar.Root.Visible = false
        return
    end

    local active = character:GetAttribute(
        "ArcaneWardActive"
    ) == true
    local current = tonumber(
        character:GetAttribute(
            "ArcaneWardCurrent"
        )
    ) or 0
    local maximum = tonumber(
        character:GetAttribute(
            "ArcaneWardMax"
        )
    ) or 0
    local visible = active
        and current > 0
        and maximum > 0

    ward_bar.Root.Visible = visible
    if not visible then
        return
    end

    ward_bar.Value.Text = string.format(
        "%.0f / %.0f",
        current,
        maximum
    )
    UiTheme.set_bar_ratio(
        ward_bar.Fill,
        current / maximum
    )
end

--[[
Binds Ward attributes on a new character.

Args:
    character (Model): New local character.

Returns:
    None.
]]
local function bind_character(character: Model)
    disconnect_character()

    for _, attribute_name in ipairs({
        "ArcaneWardActive",
        "ArcaneWardCurrent",
        "ArcaneWardMax",
    }) do
        table.insert(
            character_connections,
            character:GetAttributeChangedSignal(
                attribute_name
            ):Connect(update_value)
        )
    end

    update_value()
end

player.CharacterAdded:Connect(bind_character)
player.CharacterRemoving:Connect(function()
    disconnect_character()
    ward_bar.Root.Visible = false
end)

if player.Character then
    bind_character(player.Character)
else
    update_value()
end
