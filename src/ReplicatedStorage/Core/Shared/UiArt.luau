--!strict
-- Reference-derived UI artwork shared by DungeonMMO client interfaces.
local UiArt = {}

UiArt.ATLAS_IMAGE = "rbxassetid://107368787767290"
UiArt.ATLAS_SIZE = Vector2.new(1024, 512)

export type Region = {
    Offset: Vector2,
    Size: Vector2,
}

local REGIONS: {[string]: Region} = {
    Window = {
        Offset = Vector2.new(0, 0),
        Size = Vector2.new(290, 295),
    },
    Journal = {
        Offset = Vector2.new(296, 0),
        Size = Vector2.new(290, 295),
    },
    Tracker = {
        Offset = Vector2.new(592, 0),
        Size = Vector2.new(132, 187),
    },
    Profile = {
        Offset = Vector2.new(732, 0),
        Size = Vector2.new(191, 60),
    },
    ActionBar = {
        Offset = Vector2.new(0, 310),
        Size = Vector2.new(384, 67),
    },
    HotbarSlot = {
        Offset = Vector2.new(390, 310),
        Size = Vector2.new(31, 39),
    },
    CommandButton = {
        Offset = Vector2.new(428, 310),
        Size = Vector2.new(33, 44),
    },
    ActiveTab = {
        Offset = Vector2.new(468, 310),
        Size = Vector2.new(50, 16),
    },
    InactiveTab = {
        Offset = Vector2.new(524, 310),
        Size = Vector2.new(61, 16),
    },
    DungeonCard = {
        Offset = Vector2.new(592, 310),
        Size = Vector2.new(134, 54),
    },
}

UiArt.REGIONS = table.freeze(REGIONS)

--[[
Returns a named atlas region.

Args:
    region_name (string): Stable region name from REGIONS.

Returns:
    Region: Offset and size for the requested atlas region.
]]
function UiArt.get_region(region_name: string): Region
    local region = REGIONS[region_name]
    assert(region, "Unknown DungeonMMO UI art region: " .. region_name)
    return region
end

--[[
Creates one cropped atlas image.

Args:
    parent (Instance): Parent GUI container.
    name (string): Stable instance name.
    region_name (string): Named atlas region to display.
    z_index (number?): Optional rendering order.

Returns:
    ImageLabel: Configured atlas-backed image label.
]]
function UiArt.image(
    parent: Instance,
    name: string,
    region_name: string,
    z_index: number?
): ImageLabel
    local region = UiArt.get_region(region_name)
    local image = Instance.new("ImageLabel")
    image.Name = name
    image.BackgroundTransparency = 1
    image.BorderSizePixel = 0
    image.Image = UiArt.ATLAS_IMAGE
    image.ImageRectOffset = region.Offset
    image.ImageRectSize = region.Size
    image.ScaleType = Enum.ScaleType.Stretch
    image.Size = UDim2.fromScale(1, 1)
    image.ZIndex = z_index or 1
    image.Parent = parent
    return image
end

--[[
Adds a named atlas region as a full-size background for a GuiObject.

Args:
    parent (GuiObject): GUI object receiving the art shell.
    region_name (string): Named atlas region to display.
    z_index (number?): Optional rendering order.

Returns:
    ImageLabel: Created background image.
]]
function UiArt.background(
    parent: GuiObject,
    region_name: string,
    z_index: number?
): ImageLabel
    local image = UiArt.image(
        parent,
        "ReferenceArt",
        region_name,
        z_index
    )
    image.AnchorPoint = Vector2.zero
    image.Position = UDim2.fromScale(0, 0)
    image.Size = UDim2.fromScale(1, 1)
    return image
end

--[[
Makes a procedural frame transparent so atlas artwork can provide its shell.

Args:
    frame (Frame): Existing frame whose shape is supplied by artwork.

Returns:
    None.
]]
function UiArt.clear_frame_chrome(frame: Frame)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0

    local chrome = frame:FindFirstChild("DMMOFantasyChrome")
    if chrome then
        chrome.Visible = false
    end

    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("UIStroke") then
            child.Transparency = 1
        elseif child:IsA("UIGradient") then
            child.Enabled = false
        end
    end
end

return table.freeze(UiArt)
