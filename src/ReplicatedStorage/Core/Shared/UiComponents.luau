--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local UiTheme = require(shared:WaitForChild("UiTheme"))

local UiComponents = {}

export type ProgressBar = {
    Root: Frame,
    Track: Frame,
    Fill: Frame,
    Label: TextLabel,
    Value: TextLabel,
}

export type ModalShell = {
    Root: Frame,
    Header: Frame,
    Title: TextLabel,
    Subtitle: TextLabel,
    Close: TextButton,
    Body: Frame,
}

--[[
Creates a themed text label.

Args:
    parent (Instance): Parent instance.
    name (string): Instance name.
    text (string): Initial label text.
    style (UiTheme.LabelStyle): Typography role.

Returns:
    TextLabel: Configured label.
]]
function UiComponents.label(
    parent: Instance,
    name: string,
    text: string,
    style: UiTheme.LabelStyle
): TextLabel
    local label = Instance.new("TextLabel")
    label.Name = name
    label.Text = text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    UiTheme.style_label(label, style)
    label.Parent = parent
    return label
end

--[[
Creates a themed text button.

Args:
    parent (Instance): Parent instance.
    name (string): Instance name.
    text (string): Button text.
    variant (UiTheme.ButtonVariant?): Optional visual role.

Returns:
    TextButton: Configured button.
]]
function UiComponents.button(
    parent: Instance,
    name: string,
    text: string,
    variant: UiTheme.ButtonVariant?
): TextButton
    local button = Instance.new("TextButton")
    button.Name = name
    button.Text = text
    button.Selectable = true
    UiTheme.style_button(button, variant)
    button.Parent = parent
    return button
end

--[[
Creates a compact caption/value progress bar.

Args:
    parent (Instance): Parent instance.
    name (string): Root name.
    caption (string): Left-side bar caption.
    fill_color (Color3): Fill colour.
    track_color (Color3): Track colour.
    height (number?): Root height in pixels.

Returns:
    ProgressBar: References to the created bar controls.
]]
function UiComponents.progress_bar(
    parent: Instance,
    name: string,
    caption: string,
    fill_color: Color3,
    track_color: Color3,
    height: number?
): ProgressBar
    local root = Instance.new("Frame")
    root.Name = name
    root.Size = UDim2.new(1, 0, 0, height or 30)
    root.BackgroundTransparency = 1
    root.Parent = parent

    local bar_label = UiComponents.label(
        root,
        "Caption",
        caption,
        "Caption"
    )
    bar_label.Position = UDim2.fromOffset(0, 0)
    bar_label.Size = UDim2.new(0.45, 0, 0, 12)

    local value_label = UiComponents.label(
        root,
        "Value",
        "",
        "Caption"
    )
    value_label.AnchorPoint = Vector2.new(1, 0)
    value_label.Position = UDim2.fromScale(1, 0)
    value_label.Size = UDim2.new(0.55, 0, 0, 12)
    value_label.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Position = UDim2.fromOffset(0, 16)
    track.Size = UDim2.new(1, 0, 0, 9)
    track.BackgroundColor3 = track_color
    track.BorderSizePixel = 0
    UiTheme.add_corner(track, 4)
    track.Parent = root

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.fromScale(1, 1)
    fill.BackgroundColor3 = fill_color
    fill.BorderSizePixel = 0
    UiTheme.add_corner(fill, 4)
    UiTheme.add_gradient(
        fill,
        fill_color:Lerp(Color3.new(1, 1, 1), 0.12),
        fill_color:Lerp(Color3.new(0, 0, 0), 0.12)
    )
    fill.Parent = track

    return {
        Root = root,
        Track = track,
        Fill = fill,
        Label = bar_label,
        Value = value_label,
    }
end

--[[
Creates a standard modal with header, close button and body region.

Args:
    parent (Instance): Parent ScreenGui or container.
    name (string): Root frame name.
    title_text (string): Main modal title.
    subtitle_text (string): Supporting title text.
    size (UDim2): Modal size.

Returns:
    ModalShell: References to modal regions and controls.
]]
function UiComponents.modal(
    parent: Instance,
    name: string,
    title_text: string,
    subtitle_text: string,
    size: UDim2
): ModalShell
    local root = Instance.new("Frame")
    root.Name = name
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.fromScale(0.5, 0.5)
    root.Size = size
    UiTheme.style_panel(root, false)
    root.Parent = parent

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Position = UDim2.fromOffset(18, 14)
    header.Size = UDim2.new(1, -36, 0, 54)
    header.BackgroundTransparency = 1
    header.Parent = root

    local title = UiComponents.label(
        header,
        "Title",
        title_text,
        "Title"
    )
    title.Size = UDim2.new(1, -56, 0, 28)

    local subtitle = UiComponents.label(
        header,
        "Subtitle",
        subtitle_text,
        "Muted"
    )
    subtitle.Position = UDim2.fromOffset(0, 29)
    subtitle.Size = UDim2.new(1, -56, 0, 20)

    local close = UiComponents.button(
        header,
        "Close",
        "×",
        "Ghost"
    )
    close.AnchorPoint = Vector2.new(1, 0)
    close.Position = UDim2.fromScale(1, 0)
    close.Size = UDim2.fromOffset(38, 38)
    close.TextSize = 22

    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Position = UDim2.fromOffset(18, 78)
    divider.Size = UDim2.new(1, -36, 0, 1)
    divider.BackgroundColor3 = UiTheme.PALETTE.Border
    divider.BackgroundTransparency = 0.55
    divider.BorderSizePixel = 0
    divider.Parent = root

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Position = UDim2.fromOffset(18, 92)
    body.Size = UDim2.new(1, -36, 1, -110)
    body.BackgroundTransparency = 1
    body.Parent = root

    return {
        Root = root,
        Header = header,
        Title = title,
        Subtitle = subtitle,
        Close = close,
        Body = body,
    }
end

--[[
Creates a small key-hint pill.

Args:
    parent (Instance): Parent instance.
    text (string): Key text to display.

Returns:
    TextLabel: Key-hint label.
]]
function UiComponents.key_hint(
    parent: Instance,
    text: string
): TextLabel
    local label = UiComponents.label(
        parent,
        "KeyHint",
        text,
        "Key"
    )
    label.BackgroundColor3 = UiTheme.PALETTE.Backdrop
    label.BackgroundTransparency = 0.18
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Size = UDim2.fromOffset(25, 21)
    UiTheme.add_corner(label, 5)
    UiTheme.add_stroke(
        label,
        UiTheme.PALETTE.BorderSoft,
        0.4
    )
    return label
end

--[[
Creates a subtle section divider with a heading.

Args:
    parent (Instance): Parent instance.
    text (string): Heading text.

Returns:
    TextLabel: Created heading label.
]]
function UiComponents.section_heading(
    parent: Instance,
    text: string
): TextLabel
    local label = UiComponents.label(
        parent,
        "SectionHeading",
        text,
        "Caption"
    )
    label.TextColor3 = UiTheme.PALETTE.Accent
    label.TextXAlignment = Enum.TextXAlignment.Left
    return label
end

--[[
Applies safe shared polish to legacy UI descendants.

Args:
    root (Instance): UI subtree to polish.

Returns:
    None.
]]
function UiComponents.polish_legacy_tree(
    root: Instance
)
    for _, descendant in ipairs(root:GetDescendants()) do
        if descendant:IsA("TextButton") then
            UiTheme.style_button(descendant, "Secondary")
        elseif descendant:IsA("TextLabel") then
            descendant.Font = UiTheme.FONT.Body
            if descendant.TextColor3
                == Color3.new(1, 1, 1) then
                descendant.TextColor3 = UiTheme.PALETTE.Text
            end
        elseif descendant:IsA("ScrollingFrame") then
            UiTheme.style_scroll(descendant)
        end
    end
end

return table.freeze(UiComponents)
