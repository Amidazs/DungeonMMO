--!strict
-- Shared native Roblox ornamentation for the fantasy interface.
local UiOrnament = {}

local GOLD = Color3.fromRGB(158, 116, 49)
local GOLD_BRIGHT = Color3.fromRGB(232, 187, 88)
local GOLD_PALE = Color3.fromRGB(247, 219, 151)
local BRONZE = Color3.fromRGB(89, 60, 27)
local SHADOW = Color3.fromRGB(4, 6, 8)
local METAL = Color3.fromRGB(28, 29, 30)

--[[
Creates one thin decorative edge strip.

Args:
    parent (Instance): Parent frame.
    name (string): Stable object name.
    position (UDim2): Strip position.
    size (UDim2): Strip dimensions.
    color (Color3): Strip colour.
    z_index (number): Rendering order.

Returns:
    Frame: Created edge strip.
]]
local function make_edge(
    parent: Instance,
    name: string,
    position: UDim2,
    size: UDim2,
    color: Color3,
    z_index: number
): Frame
    local edge = Instance.new("Frame")
    edge.Name = name
    edge.Position = position
    edge.Size = size
    edge.BackgroundColor3 = color
    edge.BackgroundTransparency = 0.08
    edge.BorderSizePixel = 0
    edge.ZIndex = z_index
    edge.Parent = parent
    return edge
end

--[[
Creates one angular corner bracket.

Args:
    parent (Instance): Parent ornament layer.
    name (string): Stable corner name.
    x (number): Horizontal corner side, zero or one.
    y (number): Vertical corner side, zero or one.
    z_index (number): Rendering order.

Returns:
    Frame: Root frame for the corner bracket.
]]
local function make_corner(
    parent: Instance,
    name: string,
    x: number,
    y: number,
    z_index: number
): Frame
    local corner = Instance.new("Frame")
    corner.Name = name
    corner.AnchorPoint = Vector2.new(x, y)
    corner.Position = UDim2.fromScale(x, y)
    corner.Size = UDim2.fromOffset(19, 19)
    corner.BackgroundTransparency = 1
    corner.BorderSizePixel = 0
    corner.ZIndex = z_index
    corner.Parent = parent

    local horizontal = make_edge(
        corner,
        "Horizontal",
        UDim2.fromOffset(if x == 0 then 0 else 1, 0),
        UDim2.fromOffset(18, 3),
        GOLD_BRIGHT,
        z_index
    )
    horizontal.AnchorPoint = Vector2.new(x, y)
    horizontal.Position = UDim2.fromScale(x, y)

    local vertical = make_edge(
        corner,
        "Vertical",
        UDim2.fromOffset(0, if y == 0 then 0 else 1),
        UDim2.fromOffset(3, 18),
        GOLD_BRIGHT,
        z_index
    )
    vertical.AnchorPoint = Vector2.new(x, y)
    vertical.Position = UDim2.fromScale(x, y)

    local jewel = Instance.new("Frame")
    jewel.Name = "CornerJewel"
    jewel.AnchorPoint = Vector2.new(0.5, 0.5)
    jewel.Position = UDim2.fromScale(0.5, 0.5)
    jewel.Size = UDim2.fromOffset(7, 7)
    jewel.BackgroundColor3 = GOLD
    jewel.BorderSizePixel = 0
    jewel.Rotation = 45
    jewel.ZIndex = z_index + 1
    jewel.Parent = corner

    local shine = Instance.new("Frame")
    shine.Name = "JewelShine"
    shine.AnchorPoint = Vector2.new(0.5, 0.5)
    shine.Position = UDim2.fromScale(0.5, 0.5)
    shine.Size = UDim2.fromOffset(3, 3)
    shine.BackgroundColor3 = GOLD_PALE
    shine.BorderSizePixel = 0
    shine.ZIndex = z_index + 2
    shine.Parent = jewel

    return corner
end

--[[
Adds layered metal framing and angular ornaments to a panel.

Args:
    frame (Frame): Panel to decorate without changing its content.
    prominent (boolean?): Use stronger metallic accents.

Returns:
    None.
]]
function UiOrnament.frame(
    frame: Frame,
    prominent: boolean?
)
    local previous = frame:FindFirstChild("DMMOFantasyChrome")
    if previous then
        previous:Destroy()
    end

    local chrome = Instance.new("Frame")
    chrome.Name = "DMMOFantasyChrome"
    chrome.Size = UDim2.fromScale(1, 1)
    chrome.BackgroundTransparency = 1
    chrome.BorderSizePixel = 0
    chrome.ZIndex = frame.ZIndex
    chrome.Parent = frame

    local outer = Instance.new("UIStroke")
    outer.Name = "OuterMetal"
    outer.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    outer.Color = if prominent then GOLD_BRIGHT else GOLD
    outer.Transparency = if prominent then 0.02 else 0.18
    outer.Thickness = if prominent then 2 else 1
    outer.Parent = chrome

    local inset = Instance.new("Frame")
    inset.Name = "MetalInset"
    inset.Position = UDim2.fromOffset(5, 5)
    inset.Size = UDim2.new(1, -10, 1, -10)
    inset.BackgroundTransparency = 1
    inset.BorderSizePixel = 0
    inset.ZIndex = frame.ZIndex
    inset.Parent = chrome

    local inner = Instance.new("UIStroke")
    inner.Name = "InnerMetal"
    inner.Color = if prominent
        then GOLD
        else GOLD:Lerp(BRONZE, 0.44)
    inner.Transparency = if prominent then 0.15 else 0.38
    inner.Thickness = 1
    inner.Parent = inset

    local top_glint = make_edge(
        chrome,
        "TopGlint",
        UDim2.fromOffset(28, 2),
        UDim2.new(1, -56, 0, 1),
        if prominent then GOLD_PALE else GOLD,
        frame.ZIndex + 1
    )
    top_glint.BackgroundTransparency = if prominent then 0.30 else 0.58

    local bottom_shadow = make_edge(
        chrome,
        "BottomShadow",
        UDim2.new(0, 28, 1, -3),
        UDim2.new(1, -56, 0, 1),
        BRONZE,
        frame.ZIndex + 1
    )
    bottom_shadow.BackgroundTransparency = 0.34

    for _, x in ipairs({0, 1}) do
        for _, y in ipairs({0, 1}) do
            make_corner(
                chrome,
                "MetalCorner" .. tostring(x) .. tostring(y),
                x,
                y,
                frame.ZIndex + 2
            )
        end
    end
end

--[[
Adds a gold horizontal divider with a small centre diamond.

Args:
    parent (Instance): Parent container.
    position (UDim2): Divider position.
    size (UDim2): Divider size.
    z_index (number?): Optional rendering order.

Returns:
    Frame: Divider root.
]]
function UiOrnament.divider(
    parent: Instance,
    position: UDim2,
    size: UDim2,
    z_index: number?
): Frame
    local root = Instance.new("Frame")
    root.Name = "OrnateDivider"
    root.Position = position
    root.Size = size
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.ZIndex = z_index or 1
    root.Parent = parent

    local line = make_edge(
        root,
        "Line",
        UDim2.new(0, 0, 0.5, 0),
        UDim2.new(1, 0, 0, 1),
        GOLD,
        root.ZIndex
    )
    line.BackgroundTransparency = 0.42

    local diamond = Instance.new("Frame")
    diamond.Name = "Diamond"
    diamond.AnchorPoint = Vector2.new(0.5, 0.5)
    diamond.Position = UDim2.fromScale(0.5, 0.5)
    diamond.Size = UDim2.fromOffset(6, 6)
    diamond.BackgroundColor3 = GOLD_BRIGHT
    diamond.BorderSizePixel = 0
    diamond.Rotation = 45
    diamond.ZIndex = root.ZIndex + 1
    diamond.Parent = root

    return root
end

--[[
Creates a symbolic skill or item icon using layered metal framing.

Args:
    parent (Instance): Container for the icon.
    name (string): Stable icon name.
    caption (string): Short symbolic glyph.
    tint (Color3): Main icon colour.
    size (number): Square width and height.

Returns:
    Frame: The decorated icon frame.
]]
function UiOrnament.icon(
    parent: Instance,
    name: string,
    caption: string,
    tint: Color3,
    size: number
): Frame
    local outer = Instance.new("Frame")
    outer.Name = name
    outer.Size = UDim2.fromOffset(size, size)
    outer.BackgroundColor3 = METAL
    outer.BorderSizePixel = 0
    outer.Parent = parent

    local rim = Instance.new("UIStroke")
    rim.Color = GOLD_BRIGHT
    rim.Thickness = 2
    rim.Transparency = 0.05
    rim.Parent = outer

    local inner = Instance.new("Frame")
    inner.Name = "InnerRim"
    inner.Position = UDim2.fromOffset(3, 3)
    inner.Size = UDim2.new(1, -6, 1, -6)
    inner.BackgroundColor3 = BRONZE
    inner.BorderSizePixel = 0
    inner.Parent = outer

    local well = Instance.new("Frame")
    well.Name = "IconWell"
    well.Position = UDim2.fromOffset(5, 5)
    well.Size = UDim2.new(1, -10, 1, -10)
    well.BackgroundColor3 = tint
    well.BorderSizePixel = 0
    well.ZIndex = inner.ZIndex + 1
    well.Parent = outer

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(
        tint:Lerp(Color3.new(1, 1, 1), 0.22),
        tint:Lerp(Color3.new(0, 0, 0), 0.64)
    )
    gradient.Rotation = 120
    gradient.Parent = well

    local sigil = Instance.new("TextLabel")
    sigil.Name = "Sigil"
    sigil.BackgroundTransparency = 1
    sigil.Size = UDim2.fromScale(1, 1)
    sigil.Font = Enum.Font.Garamond
    sigil.Text = caption
    sigil.TextColor3 = GOLD_PALE
    sigil.TextStrokeColor3 = SHADOW
    sigil.TextStrokeTransparency = 0.18
    sigil.TextSize = math.floor(size * 0.56)
    sigil.ZIndex = 2
    sigil.Parent = well

    return outer
end

return table.freeze(UiOrnament)
