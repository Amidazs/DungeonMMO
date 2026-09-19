--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local ProgressionClientState = require(
    script.Parent.Parent
        :WaitForChild("Core")
        :WaitForChild("ProgressionClientState")
)
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

local old = resource_stack:FindFirstChild("ManaBar")
if old then
    old:Destroy()
end

local mana_bar = UiComponents.progress_bar(
    resource_stack,
    "ManaBar",
    "MANA",
    UiTheme.PALETTE.Mana,
    UiTheme.PALETTE.ManaDark,
    20
)
mana_bar.Root.LayoutOrder = 2
mana_bar.Root.Size = UDim2.new(1, 0, 0, 20)
mana_bar.Track.Position = UDim2.fromOffset(0, 13)
mana_bar.Track.Size = UDim2.new(1, 0, 0, 6)
mana_bar.Label.TextSize = 10
mana_bar.Value.TextSize = 10
mana_bar.Root.Visible = false

local mage = false

--[[
Updates Mana from replicated player attributes.

Args:
    None.

Returns:
    None.
]]
local function update_value()
    local current = tonumber(
        player:GetAttribute("CombatMana")
    ) or 0
    local maximum = tonumber(
        player:GetAttribute("CombatMaxMana")
    ) or 100
    local regen = tonumber(
        player:GetAttribute(
            "CombatManaRegenPerSecond"
        )
    ) or 0
    local ratio = if maximum > 0
        then current / maximum
        else 0

    mana_bar.Value.Text = string.format(
        "%.0f / %.0f   +%.1f/s",
        current,
        maximum,
        regen
    )
    UiTheme.set_bar_ratio(mana_bar.Fill, ratio)
end

--[[
Updates Mana visibility from the current identity snapshot.

Args:
    snapshot (any): Current progression snapshot.

Returns:
    None.
]]
local function apply_identity_snapshot(snapshot: any)
    local identity = if type(snapshot) == "table"
        then snapshot.Identity
        else nil

    mage = type(identity) == "table"
        and identity.BaseClassId == "Mage"
    mana_bar.Root.Visible = mage
    update_value()
end

ProgressionClientState.subscribe(
    apply_identity_snapshot
)
apply_identity_snapshot(
    ProgressionClientState.get_snapshot()
)

for _, attribute_name in ipairs({
    "CombatMana",
    "CombatMaxMana",
    "CombatManaRegenPerSecond",
}) do
    player:GetAttributeChangedSignal(
        attribute_name
    ):Connect(update_value)
end
