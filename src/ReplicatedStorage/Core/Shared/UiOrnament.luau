--!strict
-- Shared native Roblox ornamentation for the fantasy interface.
local UiOrnament = {}

local GOLD = Color3.fromRGB(191, 151, 82)
local HIGHLIGHT = Color3.fromRGB(244, 207, 132)
local SHADOW = Color3.fromRGB(27, 30, 37)

--[[
Adds an inset border and subtle corner ornaments to an existing frame.

Args:
    frame (Frame): Panel to decorate without changing its content.
    prominent (boolean?): Use stronger metallic accents.

Returns:
    None.
]]
function UiOrnament.frame(frame: Frame, prominent: boolean?)
    local inset = Instance.new("Frame")
    inset.Name = "MetalInset"
    inset.Position = UDim2.fromOffset(5, 5)
    inset.Size = UDim2.new(1, -10, 1, -10)
    inset.BackgroundTransparency = 1
    inset.BorderSizePixel = 0
    inset.ZIndex = frame.ZIndex
    inset.Parent = frame

    local edge = Instance.new("UIStroke")
    edge.Color = if prominent then GOLD else GOLD:Lerp(SHADOW, 0.35)
    edge.Transparency = if prominent then 0.2 else 0.5
    edge.Thickness = 1
    edge.Parent = inset

    for _, x in ipairs({0, 1}) do
        for _, y in ipairs({0, 1}) do
            local ornament = Instance.new("Frame")
            ornament.Name = "MetalCorner"
            ornament.AnchorPoint = Vector2.new(x, y)
            ornament.Position = UDim2.fromScale(x, y)
            ornament.Size = UDim2.fromOffset(13, 13)
            ornament.BackgroundColor3 = GOLD
            ornament.BorderSizePixel = 0
            ornament.Rotation = 45
            ornament.ZIndex = frame.ZIndex + 1
            ornament.Parent = inset

            local jewel = Instance.new("Frame")
            jewel.Name = "CornerJewel"
            jewel.AnchorPoint = Vector2.new(0.5, 0.5)
            jewel.Position = UDim2.fromScale(0.5, 0.5)
            jewel.Size = UDim2.fromOffset(5, 5)
            jewel.BackgroundColor3 = HIGHLIGHT
            jewel.BorderSizePixel = 0
            jewel.ZIndex = ornament.ZIndex + 1
            jewel.Parent = ornament
        end
    end
end

--[[
Creates a symbolic skill or item icon using native UI shapes.

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
    outer.BackgroundColor3 = SHADOW
    outer.BorderSizePixel = 0
    outer.Parent = parent

    local rim = Instance.new("UIStroke")
    rim.Color = GOLD
    rim.Thickness = 2
    rim.Transparency = 0.08
    rim.Parent = outer

    local well = Instance.new("Frame")
    well.Name = "IconWell"
    well.Position = UDim2.fromOffset(4, 4)
    well.Size = UDim2.new(1, -8, 1, -8)
    well.BackgroundColor3 = tint
    well.BorderSizePixel = 0
    well.Parent = outer

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(
        tint:Lerp(Color3.new(1, 1, 1), 0.18),
        tint:Lerp(Color3.new(0, 0, 0), 0.56)
    )
    gradient.Rotation = 110
    gradient.Parent = well

    local sigil = Instance.new("TextLabel")
    sigil.Name = "Sigil"
    sigil.BackgroundTransparency = 1
    sigil.Size = UDim2.fromScale(1, 1)
    sigil.Font = Enum.Font.Garamond
    sigil.Text = caption
    sigil.TextColor3 = Color3.fromRGB(247, 225, 173)
    sigil.TextStrokeColor3 = Color3.fromRGB(13, 13, 20)
    sigil.TextStrokeTransparency = 0.28
    sigil.TextSize = math.floor(size * 0.55)
    sigil.ZIndex = 2
    sigil.Parent = well
    return outer
end

return table.freeze(UiOrnament)
