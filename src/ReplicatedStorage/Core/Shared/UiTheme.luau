--!strict
local TweenService = game:GetService("TweenService")

local UiTheme = {}

local PALETTE = table.freeze({
    Backdrop = Color3.fromRGB(6, 5, 4),
    BackdropSoft = Color3.fromRGB(12, 10, 8),
    Surface = Color3.fromRGB(18, 16, 13),
    SurfaceRaised = Color3.fromRGB(28, 25, 20),
    SurfaceHover = Color3.fromRGB(42, 35, 25),
    SurfacePressed = Color3.fromRGB(55, 44, 29),
    SurfaceWarm = Color3.fromRGB(38, 30, 19),
    Border = Color3.fromRGB(132, 96, 41),
    BorderSoft = Color3.fromRGB(88, 68, 39),
    BorderDark = Color3.fromRGB(45, 32, 18),
    Metal = Color3.fromRGB(113, 82, 36),
    MetalBright = Color3.fromRGB(207, 159, 69),
    Text = Color3.fromRGB(244, 232, 205),
    TextMuted = Color3.fromRGB(193, 181, 157),
    TextFaint = Color3.fromRGB(126, 119, 105),
    Accent = Color3.fromRGB(207, 158, 67),
    AccentBright = Color3.fromRGB(242, 197, 97),
    AccentDark = Color3.fromRGB(92, 61, 23),
    Health = Color3.fromRGB(184, 40, 43),
    HealthDark = Color3.fromRGB(67, 19, 21),
    Stamina = Color3.fromRGB(76, 142, 74),
    StaminaDark = Color3.fromRGB(27, 61, 33),
    Mana = Color3.fromRGB(43, 104, 190),
    ManaDark = Color3.fromRGB(19, 42, 79),
    Ward = Color3.fromRGB(55, 147, 199),
    WardDark = Color3.fromRGB(23, 61, 82),
    Experience = Color3.fromRGB(149, 71, 178),
    ExperienceDark = Color3.fromRGB(56, 28, 68),
    Success = Color3.fromRGB(80, 159, 102),
    Warning = Color3.fromRGB(220, 159, 56),
    Danger = Color3.fromRGB(184, 58, 50),
    Disabled = Color3.fromRGB(60, 59, 56),
})

local FONT = table.freeze({
    Heading = Enum.Font.Garamond,
    Body = Enum.Font.Garamond,
    Strong = Enum.Font.Garamond,
    Mono = Enum.Font.RobotoMono,
})

local TWEEN_INFO = TweenInfo.new(
    0.14,
    Enum.EasingStyle.Quad,
    Enum.EasingDirection.Out
)

UiTheme.PALETTE = PALETTE
UiTheme.FONT = FONT

export type ButtonVariant =
    "Primary"
    | "Secondary"
    | "Danger"
    | "Ghost"

export type LabelStyle =
    "Title"
    | "Heading"
    | "Body"
    | "Muted"
    | "Caption"
    | "Key"

--[[
Adds or updates a compact fantasy-interface corner.

Args:
    object (GuiObject): UI object that needs rounded corners.
    radius (number?): Corner radius in pixels.

Returns:
    UICorner: The configured corner instance.
]]
function UiTheme.add_corner(
    object: GuiObject,
    radius: number?
): UICorner
    local corner = object:FindFirstChildOfClass("UICorner")
        or Instance.new("UICorner")

    corner.CornerRadius = UDim.new(0, radius or 3)
    corner.Parent = object
    return corner
end

--[[
Adds or updates a standard metallic outline on one GuiObject.

Args:
    object (GuiObject): UI object that needs an outline.
    color (Color3?): Optional outline colour.
    transparency (number?): Optional outline transparency.

Returns:
    UIStroke: The configured stroke instance.
]]
function UiTheme.add_stroke(
    object: GuiObject,
    color: Color3?,
    transparency: number?
): UIStroke
    local stroke = object:FindFirstChildOfClass("UIStroke")
        or Instance.new("UIStroke")

    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = color or PALETTE.Border
    stroke.Transparency = transparency or 0.24
    stroke.Thickness = 1
    stroke.Parent = object
    return stroke
end

--[[
Adds a top-to-bottom metallic gradient to a GuiObject.

Args:
    object (GuiObject): UI object that receives the gradient.
    top (Color3): Colour at the top.
    bottom (Color3): Colour at the bottom.

Returns:
    UIGradient: The configured gradient instance.
]]
function UiTheme.add_gradient(
    object: GuiObject,
    top: Color3,
    bottom: Color3
): UIGradient
    local gradient = object:FindFirstChildOfClass("UIGradient")
        or Instance.new("UIGradient")

    gradient.Color = ColorSequence.new(top, bottom)
    gradient.Rotation = 90
    gradient.Parent = object
    return gradient
end

--[[
Styles an inset frame used inside ornate windows and HUD cards.

Args:
    frame (Frame): Inset frame to style.
    warm (boolean?): Whether to bias the surface toward bronze.

Returns:
    None.
]]
function UiTheme.style_inset(
    frame: Frame,
    warm: boolean?
)
    local base = if warm
        then PALETTE.SurfaceWarm
        else PALETTE.BackdropSoft

    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = base
    frame.BackgroundTransparency = 0.08
    UiTheme.add_corner(frame, 2)
    UiTheme.add_stroke(frame, PALETTE.BorderDark, 0.15)
    UiTheme.add_gradient(
        frame,
        base:Lerp(Color3.new(1, 1, 1), 0.025),
        base:Lerp(Color3.new(0, 0, 0), 0.24)
    )
end

--[[
Styles a frame as a dark high-fantasy metal panel.

Args:
    frame (Frame): Frame to style.
    raised (boolean?): Whether to use the raised surface colour.

Returns:
    None.
]]
function UiTheme.style_panel(
    frame: Frame,
    raised: boolean?
)
    local base = if raised
        then PALETTE.SurfaceRaised
        else PALETTE.Surface

    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = base
    frame.BackgroundTransparency = 0.015
    UiTheme.add_corner(frame, 1)

    local stroke = UiTheme.add_stroke(
        frame,
        PALETTE.Border,
        if raised then 0.08 else 0.18
    )
    stroke.Thickness = if raised then 2 else 1

    UiTheme.add_gradient(
        frame,
        base:Lerp(PALETTE.SurfaceWarm, 0.34),
        base:Lerp(Color3.new(0, 0, 0), 0.36)
    )
end

--[[
Styles a text label using one standard typography role.

Args:
    label (TextLabel): Label to style.
    style (LabelStyle): Typography role.

Returns:
    None.
]]
function UiTheme.style_label(
    label: TextLabel,
    style: LabelStyle
)
    label.BackgroundTransparency = 1
    label.TextWrapped = false
    label.TextTruncate = Enum.TextTruncate.AtEnd

    if style == "Title" then
        label.Font = FONT.Heading
        label.TextColor3 = PALETTE.Text
        label.TextSize = 25
        label.TextStrokeColor3 = PALETTE.Backdrop
        label.TextStrokeTransparency = 0.58
    elseif style == "Heading" then
        label.Font = FONT.Heading
        label.TextColor3 = PALETTE.Text
        label.TextSize = 17
        label.TextStrokeColor3 = PALETTE.Backdrop
        label.TextStrokeTransparency = 0.72
    elseif style == "Muted" then
        label.Font = FONT.Body
        label.TextColor3 = PALETTE.TextMuted
        label.TextSize = 14
    elseif style == "Caption" then
        label.Font = FONT.Strong
        label.TextColor3 = PALETTE.TextMuted
        label.TextSize = 11
    elseif style == "Key" then
        label.Font = FONT.Mono
        label.TextColor3 = PALETTE.AccentBright
        label.TextSize = 11
    else
        label.Font = FONT.Body
        label.TextColor3 = PALETTE.Text
        label.TextSize = 13
    end
end

--[[
Returns the background colour for a button variant.

Args:
    variant (ButtonVariant): Button visual role.

Returns:
    Color3: Base button colour.
]]
local function button_color(
    variant: ButtonVariant
): Color3
    if variant == "Primary" then
        return Color3.fromRGB(31, 54, 96)
    elseif variant == "Danger" then
        return Color3.fromRGB(87, 31, 29)
    elseif variant == "Ghost" then
        return PALETTE.Surface
    end

    return PALETTE.SurfaceRaised
end

--[[
Returns the border colour for a button variant.

Args:
    variant (ButtonVariant): Button visual role.

Returns:
    Color3: Button outline colour.
]]
local function button_border(
    variant: ButtonVariant
): Color3
    if variant == "Primary" then
        return PALETTE.AccentBright
    elseif variant == "Danger" then
        return PALETTE.Danger:Lerp(PALETTE.Accent, 0.24)
    elseif variant == "Ghost" then
        return PALETTE.BorderSoft
    end

    return PALETTE.Border
end

--[[
Applies the stored hover state for one themed button.

Args:
    button (TextButton): Button whose stored base colour is used.
    hovered (boolean): Whether the pointer is over the button.

Returns:
    None.
]]
local function apply_button_hover(
    button: TextButton,
    hovered: boolean
)
    local base = button:GetAttribute("DMMOUiBaseColor")
    local base_transparency = button:GetAttribute(
        "DMMOUiBaseTransparency"
    )

    if typeof(base) ~= "Color3"
        or type(base_transparency) ~= "number"
    then
        return
    end

    local target_color = if hovered and button.Active
        then base:Lerp(PALETTE.AccentDark, 0.34)
        else base
    local target_transparency = if hovered and button.Active
        then 0
        else base_transparency

    TweenService:Create(
        button,
        TWEEN_INFO,
        {
            BackgroundColor3 = target_color,
            BackgroundTransparency = target_transparency,
        }
    ):Play()
end

--[[
Binds idempotent hover feedback to a themed button.

Args:
    button (TextButton): Button receiving pointer feedback.

Returns:
    None.
]]
local function ensure_button_hover(
    button: TextButton
)
    if button:GetAttribute("DMMOUiHoverBound") == true then
        return
    end

    button:SetAttribute("DMMOUiHoverBound", true)

    button.MouseEnter:Connect(function()
        apply_button_hover(button, true)
    end)
    button.MouseLeave:Connect(function()
        apply_button_hover(button, false)
    end)
end

--[[
Styles a TextButton with metallic framing and restrained hover feedback.

Args:
    button (TextButton): Button to style.
    variant (ButtonVariant?): Visual role. Defaults to Secondary.

Returns:
    None.
]]
function UiTheme.style_button(
    button: TextButton,
    variant: ButtonVariant?
)
    local style = variant or "Secondary"
    local base = button_color(style)
    local transparency = if style == "Ghost" then 0.26 else 0.02

    button.BackgroundColor3 = base
    button.BackgroundTransparency = transparency
    button.BorderSizePixel = 0
    button.Font = FONT.Heading
    button.TextColor3 = PALETTE.Text
    button.TextSize = 16
    button.TextScaled = false
    button.AutoButtonColor = false

    button:SetAttribute("DMMOUiBaseColor", base)
    button:SetAttribute(
        "DMMOUiBaseTransparency",
        transparency
    )

    UiTheme.add_corner(button, 1)

    local stroke = UiTheme.add_stroke(
        button,
        button_border(style),
        if style == "Primary" then 0.08 else 0.22
    )
    stroke.Thickness = if style == "Primary" then 2 else 1

    UiTheme.add_gradient(
        button,
        base:Lerp(PALETTE.MetalBright, 0.08),
        base:Lerp(Color3.new(0, 0, 0), 0.30)
    )
    ensure_button_hover(button)
end

--[[
Updates the disabled presentation of a themed button.

Args:
    button (TextButton): Button to update.
    enabled (boolean): Whether the button should be interactive.

Returns:
    None.
]]
function UiTheme.set_button_enabled(
    button: TextButton,
    enabled: boolean
)
    button.Active = enabled
    button.Selectable = enabled
    button.AutoButtonColor = false
    button.TextTransparency = if enabled then 0 else 0.50
    button.BackgroundTransparency = if enabled
        then button:GetAttribute("DMMOUiBaseTransparency")
            or 0.02
        else 0.52
end

--[[
Styles a ScrollingFrame for the shared fantasy visual language.

Args:
    scrolling_frame (ScrollingFrame): Scrolling region to style.

Returns:
    None.
]]
function UiTheme.style_scroll(
    scrolling_frame: ScrollingFrame
)
    scrolling_frame.BackgroundColor3 = PALETTE.Backdrop
    scrolling_frame.BackgroundTransparency = 0.08
    scrolling_frame.BorderSizePixel = 0
    scrolling_frame.ScrollBarThickness = 5
    scrolling_frame.ScrollBarImageColor3 = PALETTE.AccentDark
    UiTheme.add_corner(scrolling_frame, 2)
    UiTheme.add_stroke(
        scrolling_frame,
        PALETTE.BorderDark,
        0.28
    )
end

--[[
Smoothly changes a progress-bar fill ratio.

Args:
    fill (Frame): Fill object to resize.
    ratio (number): Target ratio from zero to one.
    immediate (boolean?): Whether to skip tweening.

Returns:
    None.
]]
function UiTheme.set_bar_ratio(
    fill: Frame,
    ratio: number,
    immediate: boolean?
)
    local safe_ratio = math.clamp(ratio, 0, 1)
    local target = UDim2.fromScale(safe_ratio, 1)

    if immediate then
        fill.Size = target
        return
    end

    TweenService:Create(
        fill,
        TWEEN_INFO,
        {Size = target}
    ):Play()
end

--[[
Attaches responsive UIScale behaviour to a GuiObject.

Args:
    object (GuiObject): Root panel that should scale with viewport width.
    reference_width (number): Viewport width at scale 1.
    min_scale (number?): Minimum allowed scale.
    max_scale (number?): Maximum allowed scale.

Returns:
    () -> (): Cleanup callback that disconnects viewport tracking.
]]
function UiTheme.bind_responsive_scale(
    object: GuiObject,
    reference_width: number,
    min_scale: number?,
    max_scale: number?
): () -> ()
    local scale = object:FindFirstChildOfClass("UIScale")
        or Instance.new("UIScale")
    local camera_connection: RBXScriptConnection? = nil
    local minimum = min_scale or 0.72
    local maximum = max_scale or 1.0

    scale.Parent = object

    local function update()
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end

        scale.Scale = math.clamp(
            math.min(
                camera.ViewportSize.X / reference_width,
                camera.ViewportSize.Y / 720
            ),
            minimum,
            maximum
        )
    end

    local function bind_camera()
        if camera_connection then
            camera_connection:Disconnect()
        end

        local camera = workspace.CurrentCamera
        if camera then
            camera_connection = camera:GetPropertyChangedSignal(
                "ViewportSize"
            ):Connect(update)
        end
        update()
    end

    workspace:GetPropertyChangedSignal(
        "CurrentCamera"
    ):Connect(bind_camera)
    bind_camera()

    return function()
        if camera_connection then
            camera_connection:Disconnect()
        end
    end
end

return table.freeze(UiTheme)
