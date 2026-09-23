-- Command-bar setup for the six unpublished humanoid animation previews.
-- Clones the original tested guardian; the source rig remains untouched.

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local SOURCE_NAME = "DMMO_Astra_Guardian_Test"
local TARGET_NAME = "DMMO_Humanoid_Starter_Test"
local REQUIRED_PARTS = {
    "HumanoidRootPart", "LeftHand", "RightHand",
    "LeftFoot", "RightFoot",
}

-- Args: character (Model) - marked, independently cloned R15 test model.
-- Returns: nil - verifies the complete minimum preview body.
local function verify_rig(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    assert(humanoid and humanoid.RigType == Enum.HumanoidRigType.R15,
        "The cloned test body must be R15")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    assert(animator, "An existing Humanoid.Animator is required")
    for _, name in REQUIRED_PARTS do
        assert(character:FindFirstChild(name), "Missing body part: " .. name)
    end
end

-- Args: character (Model) - cloned guardian.
-- Returns: nil - removes original combat scripts and attached hammer.
local function remove_source_attacks(character)
    for _, item in character:GetDescendants() do
        if item:IsA("BaseScript") or item:IsA("KeyframeSequence")
            or item:IsA("Animation") then
            item:Destroy()
        end
    end
    local hammer = character:FindFirstChild("Guardian_Hammer")
    if hammer then
        hammer:Destroy()
    end
    local grip = character:FindFirstChild("GuardianHammerGrip", true)
    if grip then
        grip:Destroy()
    end
end

-- Args: character (Model) - R15 test target.
-- Returns: Model - separate anchored and original-preserving performer.
local function clone_performer(character)
    assert(character.Archivable,
        "The source mannequin must already allow independent cloning")
    local model = character:Clone()
    assert(model, "Cannot clone the original R15 test mannequin")
    model.Name = TARGET_NAME
    remove_source_attacks(model)
    model:SetAttribute("DMMO_TestOnly", true)
    model:SetAttribute("DMMO_AnimationLibrary", "Humanoid starter v1")
    model.Parent = workspace
    model:PivotTo(character:GetPivot() * CFrame.new(9, 0, 0))
    model.HumanoidRootPart.Anchored = true
    model.Humanoid.AutoRotate = false
    verify_rig(model)
    return model
end

-- Args: None.
-- Returns: Model - a new default R15 mannequin in an unpublished place.
local function create_default_performer()
    local description = Instance.new("HumanoidDescription")
    local model = game:GetService("Players"):CreateHumanoidModelFromDescription(
        description, Enum.HumanoidRigType.R15
    )
    description:Destroy()
    assert(model, "Roblox could not create its built-in R15 mannequin")
    remove_source_attacks(model)
    model.Name = TARGET_NAME
    model:SetAttribute("DMMO_TestOnly", true)
    model:SetAttribute("DMMO_AnimationLibrary", "Humanoid starter v1")
    model:SetAttribute("DMMO_MannequinSource", "Built-in Roblox R15")
    model.Parent = workspace
    model:PivotTo(CFrame.new(0, 5, 0))
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    assert(humanoid, "Default R15 model has no Humanoid")
    if not humanoid:FindFirstChildOfClass("Animator") then
        Instance.new("Animator").Parent = humanoid
    end
    local footHeight = math.min(
        model.LeftFoot.Position.Y - model.LeftFoot.Size.Y / 2,
        model.RightFoot.Position.Y - model.RightFoot.Size.Y / 2
    )
    model:PivotTo(
        CFrame.new(0, 0.05 - footHeight, 0) * model:GetPivot()
    )
    model.HumanoidRootPart.Anchored = true
    humanoid.AutoRotate = false
    verify_rig(model)
    return model
end

-- Args: parent (Instance), name (string), size (Vector3), color (Color3).
-- Returns: Part - noncolliding visual-only weapon geometry.
local function make_part(parent, name, size, color)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Material = Enum.Material.Metal
    part.Color = color
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.Massless = true
    part.Anchored = false
    part.Parent = parent
    return part
end

-- Args: hand (BasePart), part (BasePart), grip (CFrame).
-- Returns: Motor6D - invisible test-only connection to the real hand.
local function attach_part(hand, part, grip)
    local motor = Instance.new("Motor6D")
    motor.Name = "DMMO_PropGrip_" .. part.Name
    motor.Part0 = hand
    motor.Part1 = part
    motor.C0 = grip
    motor.C1 = CFrame.identity
    motor.Parent = hand
    part.CFrame = hand.CFrame * grip
    return motor
end

-- Args: character (Model), handName (string), sideName (string).
-- Returns: Part - visible steel practice sword fixed to the hand.
local function make_sword(character, handName, sideName)
    local hand = character[handName]
    local steel = Color3.fromRGB(194, 201, 208)
    local grip = CFrame.new(0, -1.15, -0.2)
        * CFrame.Angles(0, 0, math.rad(8))
    local blade = make_part(
        character, "DMMO_TestSword_" .. sideName,
        Vector3.new(0.18, 2.5, 0.3), steel
    )
    attach_part(hand, blade, grip)
    return blade
end

-- Args: character (Model), handName (string), sideName (string).
-- Returns: Part - short dagger carried independently by the hand.
local function make_dagger(character, handName, sideName)
    local steel = Color3.fromRGB(173, 181, 191)
    local blade = make_part(
        character, "DMMO_TestDagger_" .. sideName,
        Vector3.new(0.15, 1.2, 0.24), steel
    )
    attach_part(
        character[handName], blade, CFrame.new(0, -0.57, -0.16)
    )
    return blade
end

-- Args: character (Model), upper (Part), lower (Part) - attached bow limbs.
-- Returns: nil - adds two visual bowstring spans linked to the draw hand.
local function make_bowstring(character, upper, lower)
    local upperTip = Instance.new("Attachment")
    upperTip.Name = "DMMO_TestBowUpperTip"
    upperTip.Position = Vector3.new(0, 0.78, 0)
    upperTip.Parent = upper
    local lowerTip = Instance.new("Attachment")
    lowerTip.Name = "DMMO_TestBowLowerTip"
    lowerTip.Position = Vector3.new(0, -0.78, 0)
    lowerTip.Parent = lower
    local nock = Instance.new("Attachment")
    nock.Name = "DMMO_TestBowNock"
    nock.Position = Vector3.new(0, -0.07, -0.18)
    nock.Parent = character.RightHand
    for _, pair in {
        {"DMMO_TestBowStringUpper", upperTip},
        {"DMMO_TestBowStringLower", lowerTip},
    } do
        local strand = Instance.new("Beam")
        strand.Name = pair[1]
        strand.Attachment0 = pair[2]
        strand.Attachment1 = nock
        strand.Width0 = 0.025
        strand.Width1 = 0.025
        strand.FaceCamera = true
        strand.Enabled = false
        strand.Color = ColorSequence.new(Color3.fromRGB(216, 205, 181))
        strand.Parent = character
    end
end

-- Args: character (Model) - separate test mannequin.
-- Returns: {Part} - left-hand bow limbs and visible right-hand arrow.
local function make_bow(character)
    local left = character.LeftHand
    local wood = Color3.fromRGB(126, 89, 50)
    local grip = make_part(
        character, "DMMO_TestBowGrip",
        Vector3.new(0.22, 0.7, 0.22), wood
    )
    attach_part(left, grip, CFrame.new(0, -0.1, -0.25))
    local upper = make_part(
        character, "DMMO_TestBowUpper",
        Vector3.new(0.16, 1.65, 0.16), wood
    )
    attach_part(left, upper, CFrame.new(0, 0.83, -0.38)
        * CFrame.Angles(math.rad(11), 0, 0))
    local lower = make_part(
        character, "DMMO_TestBowLower",
        Vector3.new(0.16, 1.65, 0.16), wood
    )
    attach_part(left, lower, CFrame.new(0, -0.83, -0.38)
        * CFrame.Angles(math.rad(-11), 0, 0))
    make_bowstring(character, upper, lower)
    local arrow = make_part(
        character, "DMMO_TestArrow",
        Vector3.new(0.08, 0.08, 2.1), Color3.fromRGB(205, 188, 152)
    )
    attach_part(character.RightHand, arrow,
        CFrame.new(0, -0.07, -1.0))
    return {grip, upper, lower, arrow}
end

-- Args: character (Model) - separate test performer.
-- Returns: nil - builds full optional visual practice-weapon kit.
local function equip_visuals(character)
    make_sword(character, "RightHand", "Right")
    make_dagger(character, "LeftHand", "Left")
    make_dagger(character, "RightHand", "Right")
    make_bow(character)
    for _, part in character:GetChildren() do
        if part:IsA("BasePart") and part.Name:match("^DMMO_Test") then
            part.Transparency = 1
        end
    end
end

-- Args: None.
-- Returns: string - JSON record identifying isolated generated rig.
local function main()
    assert(RunService:IsStudio() and game.PlaceId == 0,
        "Only run in a separate unpublished Roblox Studio test place")
    local source = workspace:FindFirstChild(SOURCE_NAME)
    assert(not workspace:FindFirstChild(TARGET_NAME),
        "The starter mannequin already exists; preserve its animations")
    local performer
    if source then
        assert(source:GetAttribute("DMMO_TestOnly"),
            "Refusing to clone an unmarked original guardian")
        verify_rig(source)
        performer = clone_performer(source)
    else
        performer = create_default_performer()
    end
    equip_visuals(performer)
    return HttpService:JSONEncode({
        testRig = performer:GetFullName(),
        sourceWasAvailable = source ~= nil,
        originalUnmodified = source == nil or source.Parent == workspace,
        rigType = tostring(performer.Humanoid.RigType),
        sourceName = source and SOURCE_NAME or "Built-in Roblox R15",
        testOnly = performer:GetAttribute("DMMO_TestOnly"),
    })
end

return main()
