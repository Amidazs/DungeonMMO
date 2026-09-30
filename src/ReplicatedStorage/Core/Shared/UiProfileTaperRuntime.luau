--!strict
local AssetService = game:GetService("AssetService")
local EncodingService = game:GetService("EncodingService")

local TaperData = require(
    script.Parent:WaitForChild("UiProfileTaperData")
)

local UiProfileTaperRuntime = {}

type TaperDefinition = {
    Width: number,
    Height: number,
    X: number,
    Y: number,
    Data: string,
}

export type TaperOverlay = {
    Clip: Frame,
    Image: ImageLabel,
    Definition: TaperDefinition,
}

export type TaperOverlays = {
    Health: TaperOverlay?,
    Mana: TaperOverlay?,
}

local LIVE_IMAGES: {EditableImage} = {}

--[[
Creates an EditableImage from one embedded RGBA taper payload.

Args:
    definition (TaperDefinition): Exact taper pixels and geometry.

Returns:
    EditableImage?: Runtime taper image, or nil when allocation fails.
]]
local function create_editable_image(
    definition: TaperDefinition
): EditableImage?
    local decoded = EncodingService:Base64Decode(
        buffer.fromstring(definition.Data)
    )
    local expected_size =
        definition.Width * definition.Height * 4

    assert(
        buffer.len(decoded) == expected_size,
        "Embedded profile taper payload has an unexpected size"
    )

    local editable = AssetService:CreateEditableImage({
        Size = Vector2.new(
            definition.Width,
            definition.Height
        ),
    })

    if not editable then
        warn(
            "[UiProfileTaperRuntime] EditableImage allocation failed."
        )
        return nil
    end

    editable:WritePixelsBuffer(
        Vector2.zero,
        Vector2.new(
            definition.Width,
            definition.Height
        ),
        decoded
    )
    table.insert(LIVE_IMAGES, editable)
    return editable
end

--[[
Creates one dynamically clipped exact taper at a resource-bar end.

Args:
    parent (GuiObject): Profile HUD root receiving the taper.
    name (string): Stable overlay instance name.
    definition (TaperDefinition): Taper pixel data and placement.
    z_index (number): Foreground rendering order.

Returns:
    TaperOverlay?: Overlay handle, or nil if image creation fails.
]]
local function create_overlay(
    parent: GuiObject,
    name: string,
    definition: TaperDefinition,
    z_index: number
): TaperOverlay?
    local editable = create_editable_image(definition)
    if not editable then
        return nil
    end

    local clip = Instance.new("Frame")
    clip.Name = name .. "Clip"
    clip.Position = UDim2.fromOffset(
        definition.X,
        definition.Y
    )
    clip.Size = UDim2.fromOffset(
        0,
        definition.Height
    )
    clip.BackgroundTransparency = 1
    clip.BorderSizePixel = 0
    clip.ClipsDescendants = true
    clip.Visible = false
    clip.ZIndex = z_index
    clip.Parent = parent

    local image = Instance.new("ImageLabel")
    image.Name = name
    image.Size = UDim2.fromOffset(
        definition.Width,
        definition.Height
    )
    image.BackgroundTransparency = 1
    image.BorderSizePixel = 0
    image.ImageContent = Content.fromObject(editable)
    image.ScaleType = Enum.ScaleType.Stretch
    image.ZIndex = z_index
    image.Parent = clip

    return {
        Clip = clip,
        Image = image,
        Definition = definition,
    }
end

--[[
Adds shell-derived exact taper artwork for both profile resource bars.

Args:
    parent (GuiObject): Profile HUD root receiving the overlays.
    z_index (number?): Optional taper rendering order.

Returns:
    TaperOverlays: Handles used to reveal each taper with bar progress.
]]
function UiProfileTaperRuntime.add_overlays(
    parent: GuiObject,
    z_index: number?
): TaperOverlays
    local order = z_index or 4

    return {
        Health = create_overlay(
            parent,
            "HealthRightTaper",
            TaperData.HEALTH,
            order
        ),
        Mana = create_overlay(
            parent,
            "ManaRightTaper",
            TaperData.MANA,
            order
        ),
    }
end

--[[
Updates one taper so only the part reached by the logical fill is visible.

Args:
    overlay (TaperOverlay?): Taper overlay to update.
    ratio (number): Current resource ratio from zero to one.
    bar_x (number): Left edge of the logical resource bar.
    bar_width (number): Full logical width including the taper.

Returns:
    None.
]]
function UiProfileTaperRuntime.set_ratio(
    overlay: TaperOverlay?,
    ratio: number,
    bar_x: number,
    bar_width: number
)
    if not overlay then
        return
    end

    local clamped = math.clamp(ratio, 0, 1)
    local fill_end = bar_x + (bar_width * clamped)
    local visible_width = math.clamp(
        math.floor(
            fill_end - overlay.Definition.X + 0.5
        ),
        0,
        overlay.Definition.Width
    )

    overlay.Clip.Size = UDim2.fromOffset(
        visible_width,
        overlay.Definition.Height
    )
    overlay.Clip.Visible = visible_width > 0
end

return table.freeze(UiProfileTaperRuntime)