--!strict
-- Truthful local navigation UI using the supplied reference art.
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local UiArt = require(
    shared:WaitForChild("UiArt")
)
local UiComponents = require(
    shared:WaitForChild("UiComponents")
)
local UiTheme = require(
    shared:WaitForChild("UiTheme")
)
local WindowController = require(
    script.Parent:WaitForChild("HudWindowController")
)

local player_gui = player:WaitForChild("PlayerGui")
local old = player_gui:FindFirstChild("NavigationMenu")
if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "NavigationMenu"
gui.ResetOnSpawn = false
gui.DisplayOrder = 173
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player_gui

local map_points = {}

--[[
Creates a readable label with consistent window Z-order.

Args:
    parent (GuiObject): Parent container.
    name (string): Stable instance name.
    text (string): Initial label text.
    x (number): X offset.
    y (number): Y offset.
    width (number): Label width.
    height (number): Label height.

Returns:
    TextLabel: Configured label.
]]
local function create_label(
    parent: GuiObject,
    name: string,
    text: string,
    x: number,
    y: number,
    width: number,
    height: number
): TextLabel
    local label = UiComponents.label(
        parent,
        name,
        text,
        "Body"
    )
    label.Position = UDim2.fromOffset(x, y)
    label.Size = UDim2.fromOffset(width, height)
    label.TextWrapped = true
    label.ZIndex = 16
    return label
end

--[[
Finds the BasePart that owns a proximity prompt.

Args:
    prompt (ProximityPrompt): Prompt to resolve.

Returns:
    BasePart?: Owning world part, if one exists.
]]
local function get_prompt_part(
    prompt: ProximityPrompt
): BasePart?
    local parent = prompt.Parent
    if parent and parent:IsA("BasePart") then
        return parent
    end

    if parent then
        return parent:FindFirstAncestorWhichIsA(
            "BasePart"
        )
    end

    return nil
end

--[[
Adds one nearby interaction point to the local map.

Args:
    prompt (Instance): Candidate proximity prompt.

Returns:
    None.
]]
local function add_prompt(prompt: Instance)
    if not prompt:IsA("ProximityPrompt") then
        return
    end

    local part = get_prompt_part(prompt)
    if not part then
        return
    end

    table.insert(
        map_points,
        {
            Part = part,
            Prompt = prompt,
        }
    )
end

--[[
Creates the reference-style world-map window.

Args:
    None.

Returns:
    any: Modal component table.
]]
local function create_map_window()
    local modal = UiComponents.modal(
        gui,
        "MapPanel",
        "Map",
        "",
        UDim2.fromOffset(720, 820)
    )
    modal.Root.Visible = false
    modal.Root.ZIndex = 11

    UiArt.clear_frame_chrome(modal.Root)
    UiArt.reference_background(
        modal.Root,
        "WorldMap",
        11
    )

    modal.Title.Visible = false
    modal.Subtitle.Visible = false
    modal.Body.Position = UDim2.fromScale(
        0.075,
        0.17
    )
    modal.Body.Size = UDim2.fromScale(
        0.85,
        0.72
    )
    modal.Body.ZIndex = 15

    UiArt.align_close(
        modal.Root,
        modal.Close,
        "WorldMap"
    )
    UiTheme.bind_responsive_scale(
        modal.Root,
        1366,
        0.5,
        1
    )

    WindowController.register(
        "Map",
        function(visible: boolean)
            modal.Root.Visible = visible
        end
    )
    modal.Close.Activated:Connect(function()
        WindowController.set_visible(
            "Map",
            false
        )
    end)

    return modal
end

local map = create_map_window()

local map_description = create_label(
    map.Body,
    "MapDescription",
    "Local landmarks around your current position.",
    0,
    0,
    560,
    34
)
map_description.TextColor3 = UiTheme.PALETTE.TextMuted

local map_area = Instance.new("Frame")
map_area.Name = "LocalLandmarks"
map_area.Position = UDim2.fromOffset(0, 48)
map_area.Size = UDim2.new(1, 0, 1, -105)
map_area.BackgroundColor3 = Color3.fromRGB(
    19,
    26,
    24
)
map_area.BackgroundTransparency = 0.08
map_area.BorderSizePixel = 0
map_area.ClipsDescendants = true
map_area.ZIndex = 16
map_area.Parent = map.Body
UiTheme.add_stroke(
    map_area,
    UiTheme.PALETTE.AccentBright,
    0.32
)

local player_marker = create_label(
    map_area,
    "PlayerMarker",
    "▲",
    0,
    0,
    24,
    24
)
player_marker.AnchorPoint = Vector2.new(0.5, 0.5)
player_marker.Position = UDim2.fromScale(0.5, 0.5)
player_marker.TextColor3 = Color3.fromRGB(
    83,
    204,
    248
)
player_marker.ZIndex = 20

local coordinates = create_label(
    map.Body,
    "Coordinates",
    "",
    0,
    0,
    560,
    34
)
coordinates.Position = UDim2.new(
    0,
    0,
    1,
    -38
)
coordinates.TextXAlignment =
    Enum.TextXAlignment.Center

for _, item in ipairs(workspace:GetDescendants()) do
    add_prompt(item)
end
workspace.DescendantAdded:Connect(add_prompt)

local location_hud = Instance.new("Frame")
location_hud.Name = "LocationHud"
location_hud.AnchorPoint = Vector2.new(1, 0)
location_hud.Position = UDim2.new(
    1,
    -18,
    0,
    12
)
location_hud.Size = UDim2.fromOffset(260, 182)
location_hud.BackgroundTransparency = 1
location_hud.Parent = gui
UiTheme.bind_responsive_scale(
    location_hud,
    1600,
    0.55,
    1
)
UiArt.popup_background(location_hud, 1)

local zone_label = create_label(
    location_hud,
    "Zone",
    "Current Area",
    18,
    12,
    224,
    26
)
zone_label.TextXAlignment =
    Enum.TextXAlignment.Center

local clock_label = create_label(
    location_hud,
    "WorldTime",
    "",
    18,
    42,
    224,
    22
)
clock_label.TextXAlignment =
    Enum.TextXAlignment.Center

local map_hint = create_label(
    location_hud,
    "MapHint",
    "Local landmarks\nOpen Map [M]",
    18,
    74,
    224,
    48
)
map_hint.TextXAlignment =
    Enum.TextXAlignment.Center

local mini_coordinates = create_label(
    location_hud,
    "Coordinates",
    "",
    18,
    133,
    224,
    24
)
mini_coordinates.TextXAlignment =
    Enum.TextXAlignment.Center

local open_map = Instance.new("TextButton")
open_map.Name = "OpenMap"
open_map.Size = UDim2.fromScale(1, 1)
open_map.BackgroundTransparency = 1
open_map.BorderSizePixel = 0
open_map.Text = ""
open_map.ZIndex = 21
open_map.Parent = location_hud
open_map.Activated:Connect(function()
    WindowController.set_visible("Map", true)
end)

UserInputService.InputBegan:Connect(function(
    input: InputObject,
    processed: boolean
)
    if processed
        or input.KeyCode ~= Enum.KeyCode.M then
        return
    end

    WindowController.set_visible("Map", true)
end)

--[[
Refreshes local map markers and location readouts.

Args:
    None.

Returns:
    None.
]]
local function update_location()
    local character = player.Character
    local root = if character
        then character:FindFirstChild(
            "HumanoidRootPart"
        )
        else nil
    local is_base = player.PlayerScripts
        :FindFirstChild("Base") ~= nil

    zone_label.Text = if is_base
        then "Starting Base"
        else "Dungeon"

    local hour = math.floor(Lighting.ClockTime)
    local minute = math.floor(
        (Lighting.ClockTime % 1) * 60
    )
    clock_label.Text = string.format(
        "World time  %02d:%02d",
        hour,
        minute
    )

    if not root or not root:IsA("BasePart") then
        return
    end

    local position = root.Position
    local coordinate_text = string.format(
        "X: %.0f   Y: %.0f   Z: %.0f",
        position.X,
        position.Y,
        position.Z
    )
    coordinates.Text = coordinate_text
    mini_coordinates.Text = coordinate_text

    for _, point in ipairs(map_points) do
        local part = point.Part
        local prompt = point.Prompt

        if not part.Parent or not prompt.Parent then
            continue
        end

        local marker = prompt:GetAttribute(
            "DMMOMapMarker"
        )
        if not marker then
            local text = if prompt.ObjectText ~= ""
                then prompt.ObjectText
                else prompt.ActionText
            local label = create_label(
                map_area,
                "Landmark",
                text,
                0,
                0,
                100,
                28
            )
            label.TextSize = 12
            label.AnchorPoint = Vector2.new(
                0.5,
                0.5
            )
            label.TextColor3 =
                UiTheme.PALETTE.AccentBright
            marker = label
            prompt:SetAttribute(
                "DMMOMapMarker",
                true
            )
            point.Marker = label
        end

        local marker_label = point.Marker
        if not marker_label then
            continue
        end

        local delta = part.Position - position
        local x = 0.5 + delta.X / 500
        local z = 0.5 + delta.Z / 500
        marker_label.Visible =
            x > 0.08
            and x < 0.92
            and z > 0.06
            and z < 0.94
        marker_label.Position = UDim2.fromScale(
            x,
            z
        )
    end
end

task.spawn(function()
    while gui.Parent do
        update_location()
        task.wait(0.25)
    end
end)
