--!strict
-- Painted reference UI artwork shared by DungeonMMO client interfaces.
--
-- Older atlas regions remain available for the four horizontal HUD elements
-- until their new high-resolution source images are uploaded. Main windows
-- use the full-resolution images registered in UiArtAssets.
local UiArtAssets = require(
    script.Parent:WaitForChild("UiArtAssets")
)

local UiArt = {}

UiArt.ATLAS_IMAGE = "rbxassetid://107368787767290"
UiArt.WINDOW_IMAGE = "rbxassetid://127588383054650"
UiArt.POPUP_IMAGE = "rbxassetid://125369844739576"
UiArt.ATLAS_SIZE = Vector2.new(1024, 512)

local SHELL_SLICE_CENTER = Rect.new(
    18,
    44,
    272,
    280
)

export type Region = {
    Offset: Vector2,
    Size: Vector2,
}

export type DirectArt = {
    Image: string,
    SourceSize: Vector2,
}

export type PaintedButtonStyle =
    "Primary"
    | "Secondary"
    | "Danger"
    | "Accent"
    | "Ghost"

local REGIONS: {[string]: Region} = {
    Window = {
        Offset = Vector2.new(0, 0),
        Size = Vector2.new(290, 295),
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
}

local DIRECT_ART: {[string]: DirectArt} = {
    Journal = {
        Image = UiArtAssets.QUEST_JOURNAL,
        SourceSize = Vector2.new(1122, 1402),
    },
    Tracker = {
        Image = UiArtAssets.QUEST_TRACKER,
        SourceSize = Vector2.new(1086, 1448),
    },
    Inventory = {
        Image = UiArtAssets.INVENTORY,
        SourceSize = Vector2.new(1122, 1402),
    },
    Skills = {
        Image = UiArtAssets.SKILLS,
        SourceSize = Vector2.new(1122, 1402),
    },
    Stats = {
        Image = UiArtAssets.STATS,
        SourceSize = Vector2.new(1122, 1402),
    },
    Guild = {
        Image = UiArtAssets.GUILD,
        SourceSize = Vector2.new(1122, 1402),
    },
    Party = {
        Image = UiArtAssets.PARTY,
        SourceSize = Vector2.new(1086, 1448),
    },
    Settings = {
        Image = UiArtAssets.SETTINGS,
        SourceSize = Vector2.new(1122, 1402),
    },
    WorldMap = {
        Image = UiArtAssets.WORLD_MAP,
        SourceSize = Vector2.new(1122, 1402),
    },
    Minimap = {
        Image = UiArtAssets.MINIMAP,
        SourceSize = Vector2.new(1254, 1254),
    },
    DungeonCard = {
        Image = UiArtAssets.DUNGEON_CARD,
        SourceSize = Vector2.new(1448, 1086),
    },
    Chat = {
        Image = UiArtAssets.CHAT,
        SourceSize = Vector2.new(1448, 1086),
    },
}

local EMPTY_DIRECT_ART: {[string]: DirectArt} = {
    Journal = {
        Image = UiArtAssets.QUEST_JOURNAL_EMPTY,
        SourceSize = Vector2.new(1122, 1402),
    },
    Tracker = {
        Image = UiArtAssets.QUEST_TRACKER_EMPTY,
        SourceSize = Vector2.new(1086, 1448),
    },
    Inventory = {
        Image = UiArtAssets.INVENTORY_EMPTY,
        SourceSize = Vector2.new(1122, 1402),
    },
    Skills = {
        Image = UiArtAssets.SKILLS_EMPTY,
        SourceSize = Vector2.new(1122, 1402),
    },
    Stats = {
        Image = UiArtAssets.STATS_EMPTY,
        SourceSize = Vector2.new(1122, 1402),
    },
    Guild = {
        Image = UiArtAssets.GUILD_EMPTY,
        SourceSize = Vector2.new(1122, 1402),
    },
    Party = {
        Image = UiArtAssets.PARTY_EMPTY,
        SourceSize = Vector2.new(1086, 1448),
    },
    Settings = {
        Image = UiArtAssets.SETTINGS_EMPTY,
        SourceSize = Vector2.new(1122, 1402),
    },
}

local PAINTED_BUTTON_IMAGES: {
    [PaintedButtonStyle]: string
} = {
    Primary = UiArtAssets.BUTTON_BLUE,
    Secondary = UiArtAssets.BUTTON_DARK,
    Danger = UiArtAssets.BUTTON_RED,
    Accent = UiArtAssets.BUTTON_GOLD,
    Ghost = UiArtAssets.BUTTON_DARK,
}

UiArt.REGIONS = table.freeze(REGIONS)
UiArt.DIRECT_ART = table.freeze(DIRECT_ART)
UiArt.EMPTY_DIRECT_ART = table.freeze(EMPTY_DIRECT_ART)

--[[
Returns a named legacy atlas region.

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
Returns one full-resolution painted art definition.

Args:
    art_name (string): Stable art name from DIRECT_ART.

Returns:
    DirectArt: Image id and original pixel dimensions.
]]
function UiArt.get_direct_art(art_name: string): DirectArt
    local art = DIRECT_ART[art_name]
    assert(art, "Unknown DungeonMMO direct UI art: " .. art_name)
    return art
end

--[[
Creates a full-resolution empty reference-derived background.

Args:
    parent (GuiObject): GUI object receiving the artwork.
    art_name (string): Stable empty-art name.
    z_index (number?): Optional rendering order.

Returns:
    ImageLabel: Empty painted reference background.
]]
function UiArt.reference_background(
    parent: GuiObject,
    art_name: string,
    z_index: number?
): ImageLabel
    local art = EMPTY_DIRECT_ART[art_name]
    assert(
        art,
        "No empty DungeonMMO reference art for: "
            .. art_name
    )

    local existing = parent:FindFirstChild("ReferenceArt")
    if existing then
        existing:Destroy()
    end

    local image = Instance.new("ImageLabel")
    image.Name = "ReferenceArt"
    image.BackgroundTransparency = 1
    image.BorderSizePixel = 0
    image.Image = art.Image
    image.ScaleType = Enum.ScaleType.Stretch
    image.Size = UDim2.fromScale(1, 1)
    image.ZIndex = z_index or 1
    image.Parent = parent
    return image
end

--[[
Applies a reference-derived painted button surface.

Args:
    button (TextButton): Existing interactive button.
    style (PaintedButtonStyle): Painted colour treatment.

Returns:
    ImageLabel: Painted background image.
]]
function UiArt.paint_button(
    button: TextButton,
    style: PaintedButtonStyle
): ImageLabel
    local existing = button:FindFirstChild(
        "PaintedButtonArt"
    )

    if existing then
        existing:Destroy()
    end

    button:SetAttribute("DMMOPaintedButton", true)
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.TextColor3 = Color3.fromRGB(248, 234, 202)
    button.TextStrokeColor3 = Color3.fromRGB(10, 7, 4)
    button.TextStrokeTransparency = 0.32

    for _, child in ipairs(button:GetChildren()) do
        if child:IsA("UIStroke") then
            child.Transparency = 1
        elseif child:IsA("UIGradient") then
            child.Enabled = false
        elseif child:IsA("UICorner") then
            child.CornerRadius = UDim.new(0, 0)
        end
    end

    local art = Instance.new("ImageLabel")
    art.Name = "PaintedButtonArt"
    art.BackgroundTransparency = 1
    art.BorderSizePixel = 0
    art.Image = PAINTED_BUTTON_IMAGES[style]
    art.ScaleType = Enum.ScaleType.Stretch
    art.Size = UDim2.fromScale(1, 1)
    art.ZIndex = math.max(1, button.ZIndex - 1)
    art.Parent = button
    return art
end

--[[
Applies active or inactive reference tab artwork.

Args:
    button (TextButton): Existing tab button.
    active (boolean): Whether the tab is selected.

Returns:
    ImageLabel: Painted tab background.
]]
function UiArt.paint_tab(
    button: TextButton,
    active: boolean
): ImageLabel
    local art = UiArt.paint_button(
        button,
        "Secondary"
    )
    art.Image = if active
        then UiArtAssets.TAB_ACTIVE
        else UiArtAssets.TAB_INACTIVE

    button.TextColor3 = if active
        then Color3.fromRGB(255, 224, 157)
        else Color3.fromRGB(238, 229, 211)
    return art
end

--[[
Creates one cropped legacy atlas image.

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
Adds either full-resolution painted art or a legacy atlas region.

Args:
    parent (GuiObject): GUI object receiving the artwork.
    art_name (string): Direct-art or legacy-region name.
    z_index (number?): Optional rendering order.

Returns:
    ImageLabel: Created image label.
]]
function UiArt.background(
    parent: GuiObject,
    art_name: string,
    z_index: number?
): ImageLabel
    assert(
        DIRECT_ART[art_name] == nil,
        "Filled reference art is not a runtime background: "
            .. art_name
            .. ". Use window_background or popup_background."
    )

    local image = UiArt.image(
        parent,
        "ReferenceArt",
        art_name,
        z_index
    )
    image.AnchorPoint = Vector2.zero
    image.Position = UDim2.fromScale(0, 0)
    image.Size = UDim2.fromScale(1, 1)
    return image
end

--[[
Converts a rectangle from source-image pixels to scale-based UI coordinates.

Args:
    art_name (string): Direct artwork whose source size defines coordinates.
    x (number): Source x coordinate.
    y (number): Source y coordinate.
    width (number): Source rectangle width.
    height (number): Source rectangle height.

Returns:
    UDim2: Scale-based rectangle matching the source artwork.
]]
function UiArt.rect(
    art_name: string,
    x: number,
    y: number,
    width: number,
    height: number
): UDim2
    local source = UiArt.get_direct_art(art_name).SourceSize

    return UDim2.fromScale(
        width / source.X,
        height / source.Y
    )
end

--[[
Returns the source-relative position for a painted UI coordinate.

Args:
    art_name (string): Direct artwork whose source size defines coordinates.
    x (number): Source x coordinate.
    y (number): Source y coordinate.

Returns:
    UDim2: Scale-based position matching the source artwork.
]]
function UiArt.position(
    art_name: string,
    x: number,
    y: number
): UDim2
    local source = UiArt.get_direct_art(art_name).SourceSize

    return UDim2.fromScale(
        x / source.X,
        y / source.Y
    )
end

--[[
Covers baked example content while retaining the surrounding painted frame.

Args:
    parent (GuiObject): Artwork container.
    art_name (string): Direct artwork defining source coordinates.
    name (string): Stable mask instance name.
    x (number): Source x coordinate.
    y (number): Source y coordinate.
    width (number): Source mask width.
    height (number): Source mask height.
    z_index (number?): Optional rendering order.

Returns:
    Frame: Opaque dark content mask.
]]
function UiArt.content_mask(
    parent: GuiObject,
    art_name: string,
    name: string,
    x: number,
    y: number,
    width: number,
    height: number,
    z_index: number?
): ImageLabel
    local mask = Instance.new("ImageLabel")
    mask.Name = name
    mask.Position = UiArt.position(art_name, x, y)
    mask.Size = UiArt.rect(
        art_name,
        x,
        y,
        width,
        height
    )
    mask.BackgroundTransparency = 1
    mask.BorderSizePixel = 0
    mask.Image = UiArtAssets.QUEST_JOURNAL
    mask.ImageRectOffset = Vector2.new(360, 950)
    mask.ImageRectSize = Vector2.new(140, 140)
    mask.ScaleType = Enum.ScaleType.Stretch
    mask.ImageColor3 = Color3.fromRGB(235, 235, 235)
    mask.ZIndex = z_index or 2
    mask.Parent = parent
    return mask
end

--[[
Creates a clean reference-derived sliced shell.

Args:
    parent (GuiObject): GUI object receiving the shell.
    name (string): Stable image instance name.
    image_asset (string): Roblox image asset identifier.
    z_index (number?): Optional rendering order.

Returns:
    ImageLabel: Sliced image shell.
]]
local function sliced_shell(
    parent: GuiObject,
    name: string,
    image_asset: string,
    z_index: number?
): ImageLabel
    local image = Instance.new("ImageLabel")
    image.Name = name
    image.BackgroundTransparency = 1
    image.BorderSizePixel = 0
    image.Image = image_asset
    image.ScaleType = Enum.ScaleType.Slice
    image.SliceCenter = SHELL_SLICE_CENTER
    image.SliceScale = 1
    image.Size = UDim2.fromScale(1, 1)
    image.ZIndex = z_index or 1
    image.Parent = parent
    return image
end

--[[
Adds the cleaned fallback window art to a modal.

Args:
    parent (GuiObject): Modal root.
    z_index (number?): Optional rendering order.

Returns:
    ImageLabel: Window shell.
]]
function UiArt.window_background(
    parent: GuiObject,
    z_index: number?
): ImageLabel
    return sliced_shell(
        parent,
        "ReferenceArt",
        UiArt.WINDOW_IMAGE,
        z_index
    )
end

--[[
Adds the close-button-free fallback popup art to a modal.

Args:
    parent (GuiObject): Popup root.
    z_index (number?): Optional rendering order.

Returns:
    ImageLabel: Popup shell.
]]
function UiArt.popup_background(
    parent: GuiObject,
    z_index: number?
): ImageLabel
    return sliced_shell(
        parent,
        "ReferencePopupArt",
        UiArt.POPUP_IMAGE,
        z_index
    )
end

--[[
Makes a procedural frame transparent so painted artwork supplies its shell.

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
