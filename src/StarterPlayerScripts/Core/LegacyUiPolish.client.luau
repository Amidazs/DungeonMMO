--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local player_gui = player:WaitForChild("PlayerGui")
local shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local UiTheme = require(
    shared:WaitForChild("UiTheme")
)

-- Character creation owns its mandatory full-screen overlay and the
-- selected race/class card appearance. Auto-styling its buttons on hover
-- obscures the selection highlight; leave IdentitySelectionUi untouched.
local TARGET_GUIS = table.freeze({
    BankPanel = true,
    EquipmentPanelUi = true,
    GuildPanel = true,
    MarketPanel = true,
    ProfessionUi = true,
    ProgressionTrainerUi = true,
    RaceChangeProofPanel = true,
    TravelPanel = true,
})

--[[
Returns the appropriate shared button role for a legacy button.

Args:
    button (TextButton): Legacy button being styled.

Returns:
    UiTheme.ButtonVariant: Shared visual role.
]]
local function button_variant(
    button: TextButton
): UiTheme.ButtonVariant
    local name = string.lower(button.Name)
    local text = string.lower(button.Text)

    if string.find(name, "close", 1, true)
        or text == "x"
        or text == "×" then
        return "Ghost"
    end

    if string.find(name, "leave", 1, true)
        or string.find(name, "decline", 1, true)
        or string.find(name, "kick", 1, true)
        or string.find(name, "delete", 1, true)
        or string.find(text, "leave", 1, true) then
        return "Danger"
    end

    if string.find(name, "confirm", 1, true)
        or string.find(name, "equip", 1, true)
        or string.find(name, "travel", 1, true)
        or string.find(name, "buy", 1, true)
        or string.find(name, "create", 1, true) then
        return "Primary"
    end

    return "Secondary"
end

--[[
Styles one legacy descendant without changing layout or behaviour.

Args:
    object (Instance): Descendant to inspect.

Returns:
    None.
]]
local function style_descendant(object: Instance)
    if object:IsA("TextButton") then
        UiTheme.style_button(
            object,
            button_variant(object)
        )
    elseif object:IsA("TextLabel") then
        local name = string.lower(object.Name)

        if string.find(name, "title", 1, true) then
            UiTheme.style_label(object, "Title")
        elseif string.find(name, "heading", 1, true)
            or string.find(name, "header", 1, true) then
            UiTheme.style_label(object, "Heading")
        elseif string.find(name, "status", 1, true)
            or string.find(name, "summary", 1, true) then
            UiTheme.style_label(object, "Muted")
        else
            object.Font = UiTheme.FONT.Body
            object.TextColor3 = UiTheme.PALETTE.Text
        end
    elseif object:IsA("ScrollingFrame") then
        UiTheme.style_scroll(object)
    elseif object:IsA("TextBox") then
        object.BackgroundColor3 = UiTheme.PALETTE.SurfaceRaised
        object.BackgroundTransparency = 0.08
        object.TextColor3 = UiTheme.PALETTE.Text
        object.PlaceholderColor3 = UiTheme.PALETTE.TextFaint
        object.Font = UiTheme.FONT.Body
        object.BorderSizePixel = 0
        UiTheme.add_corner(object, 7)
        UiTheme.add_stroke(
            object,
            UiTheme.PALETTE.BorderSoft,
            0.42
        )
    end
end

--[[
Applies shared panel treatment to direct ScreenGui frames.

Args:
    gui (ScreenGui): Legacy screen being polished.

Returns:
    None.
]]
local function style_root_frames(gui: ScreenGui)
    for _, child in ipairs(gui:GetChildren()) do
        if child:IsA("Frame") then
            UiTheme.style_panel(child, false)
        end
    end
end

--[[
Binds shared polish to one known legacy ScreenGui.

Args:
    gui (ScreenGui): Legacy screen to bind.

Returns:
    None.
]]
local function bind_gui(gui: ScreenGui)
    if not TARGET_GUIS[gui.Name] then
        return
    end

    style_root_frames(gui)

    for _, descendant in ipairs(gui:GetDescendants()) do
        style_descendant(descendant)
    end

    gui.DescendantAdded:Connect(style_descendant)
end

--[[
Checks a PlayerGui child and binds it when supported.

Args:
    child (Instance): PlayerGui child.

Returns:
    None.
]]
local function try_bind(child: Instance)
    if child:IsA("ScreenGui") then
        bind_gui(child)
    end
end

for _, child in ipairs(player_gui:GetChildren()) do
    try_bind(child)
end

player_gui.ChildAdded:Connect(try_bind)
