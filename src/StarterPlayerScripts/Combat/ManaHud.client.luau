--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local UiTheme = require(
    shared:WaitForChild("UiTheme")
)

local profile_gui = player:WaitForChild(
    "PlayerGui"
):WaitForChild("ProfileHud")
local status_card = profile_gui:WaitForChild(
    "StatusCard"
)
local mana_fill = status_card:WaitForChild(
    "ManaFill"
) :: Frame
local mana_value = status_card:WaitForChild(
    "ManaValue"
) :: TextLabel

--[[
Updates the reference-style MP bar from replicated combat resources.

All DungeonMMO classes retain an MP display because the source progression
model has MP for fighter and mage lineages alike.

Args:
    None.

Returns:
    None.
]]
local function update_value()
    local maximum = tonumber(
        player:GetAttribute("CombatMaxMana")
    ) or 0
    local current = tonumber(
        player:GetAttribute("CombatMana")
    )

    if maximum <= 0 then
        mana_value.Text = "-- / --"
        UiTheme.set_bar_ratio(
            mana_fill,
            0,
            true
        )
        return
    end

    current = math.clamp(
        current or maximum,
        0,
        maximum
    )

    mana_value.Text = string.format(
        "%.0f / %.0f",
        current,
        maximum
    )
    UiTheme.set_bar_ratio(
        mana_fill,
        current / maximum
    )
end

for _, attribute_name in ipairs({
    "CombatMana",
    "CombatMaxMana",
}) do
    player:GetAttributeChangedSignal(
        attribute_name
    ):Connect(update_value)
end

update_value()
