--!strict
local TweenService = game:GetService("TweenService")

local UiTheme = {}

local PALETTE = table.freeze({
    Backdrop = Color3.fromRGB(10, 12, 16),
    Surface = Color3.fromRGB(21, 24, 30),
    SurfaceRaised = Color3.fromRGB(29, 33, 41),
    SurfaceHover = Color3.fromRGB(39, 44, 54),
    SurfacePressed = Color3.fromRGB(47, 52, 62),
    Border = Color3.fromRGB(93, 82, 62),
    BorderSoft = Color3.fromRGB(66, 68, 72),
    Text = Color3.fromRGB(239, 234, 218),
    TextMuted = Color3.fromRGB(167, 170, 178),
    TextFaint = Color3.fromRGB(112, 116, 124),
    Accent = Color3.fromRGB(207, 163, 77),
    AccentBright = Color3.fromRGB(232, 192, 101),
    AccentDark = Color3.fromRGB(108, 80, 40),
    Health = Color3.fromRGB(178, 65, 65),
    HealthDark = Color3.fromRGB(82, 38, 38),
    Stamina = Color3.fromRGB(72, 157, 103),
    StaminaDark = Color3.fromRGB(35, 72, 50),
    Mana = Color3.fromRGB(80, 112, 203),
    ManaDark = Color3.fromRGB(37, 52, 97),
    Ward = Color3.fromRGB(91, 169, 215),
    WardDark = Color3.fromRGB(40, 73, 94),
    Experience = Color3.fromRGB(185, 133, 59),
    Success = Color3.fromRGB(83, 168, 111),
    Warning = Color3.fromRGB(210, 153, 66),
    Danger = Color3.fromRGB(178, 65, 65),
    Disabled = Color3.fromRGB(67, 69, 75),
})

local FONT = table.freeze({
    Heading = Enum.Font.Garamond,
    Body = Enum.Font.Gotham,
    Strong = Enum.Font.GothamSemibold,
    Mono = Enum.Font.RobotoMono,
})

local TWEEN_INFO = TweenInfo.new(
    0.16,
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
Adds or updates a standard corner on one GuiObject.

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

    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = object
    return corner
end

--[[
Adds or updates a standard outline on one GuiObject.

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
    stroke.Transparency = transparency or 0.35
    stroke.Thickness = 1
    stroke.Parent = object
    return stroke
end

--[[
Adds a restrained top-to-bottom gradient to a GuiObject.

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
Styles a frame as a standard raised dark-fantasy panel.

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
    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = if raised
        then PALETTE.SurfaceRaised
        else PALETTE.Surface
    frame.BackgroundTransparency = 0.04
    UiTheme.add_corner(frame, 10)
    UiTheme.add_stroke(frame, PALETTE.Border, 0.36)
    UiTheme.add_gradient(
        frame,
        frame.BackgroundColor3:Lerp(Color3.new(1, 1, 1), 0.035),
        frame.BackgroundColor3:Lerp(Color3.new(0, 0, 0), 0.08)
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
        label.TextSize = 24
    elseif style == "Heading" then
        label.Font = FONT.Strong
        label.TextColor3 = PALETTE.Text
        label.TextSize = 17
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
        label.TextSize = 12
    else
        label.Font = FONT.Body
        label.TextColor3 = PALETTE.Text
        label.TextSize = 14
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
        return PALETTE.AccentDark
    elseif variant == "Danger" then
        return PALETTE.Danger
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
        return PALETTE.Accent
    elseif variant == "Danger" then
        return PALETTE.Danger:Lerp(PALETTE.Text, 0.18)
    end

    return PALETTE.BorderSoft
end

--[[
Styles a TextButton with consistent colours, typography and hover feedback.

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

    button.BackgroundColor3 = base
    button.BackgroundTransparency = if style == "Ghost" then 0.35 else 0.08
    button.BorderSizePixel = 0
    button.Font = FONT.Strong
    button.TextColor3 = if style == "Primary"
        then PALETTE.Text
        else PALETTE.Text
    button.TextSize = 14
    button.TextScaled = false
    button.AutoButtonColor = false

    UiTheme.add_corner(button, 7)
    UiTheme.add_stroke(button, button_border(style), 0.32)

    button.MouseEnter:Connect(function()
        if not button.Active then
            return
        end

        TweenService:Create(
            button,
            TWEEN_INFO,
            {
                BackgroundColor3 = base:Lerp(
                    PALETTE.SurfaceHover,
                    0.32
                ),
                BackgroundTransparency = 0,
            }
        ):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(
            button,
            TWEEN_INFO,
            {
                BackgroundColor3 = base,
                BackgroundTransparency = if style == "Ghost"
                    then 0.35
                    else 0.08,
            }
        ):Play()
    end)
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
    button.TextTransparency = if enabled then 0 else 0.45
    button.BackgroundTransparency = if enabled then 0.08 else 0.48
end

--[[
Styles a ScrollingFrame for the shared visual language.

Args:
    scrolling_frame (ScrollingFrame): Scrolling region to style.

Returns:
    None.
]]
function UiTheme.style_scroll(
    scrolling_frame: ScrollingFrame
)
    scrolling_frame.BackgroundColor3 = PALETTE.Backdrop
    scrolling_frame.BackgroundTransparency = 0.58
    scrolling_frame.BorderSizePixel = 0
    scrolling_frame.ScrollBarThickness = 5
    scrolling_frame.ScrollBarImageColor3 = PALETTE.AccentDark
    UiTheme.add_corner(scrolling_frame, 7)
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

    --[[
    Refreshes responsive scale from the current camera viewport.

    Args:
        None.

    Returns:
        None.
    ]]
    local function update()
        local camera = workspace.CurrentCamera
        if not camera then
            return
        end

        scale.Scale = math.clamp(
            camera.ViewportSize.X / reference_width,
            minimum,
            maximum
        )
    end

    --[[
    Rebinds viewport tracking when CurrentCamera changes.

    Args:
        None.

    Returns:
        None.
    ]]
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
