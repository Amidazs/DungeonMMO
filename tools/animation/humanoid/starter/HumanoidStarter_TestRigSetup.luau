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
    assert(source and source:GetAttribute("DMMO_TestOnly"),
        "The existing test-only R15 guardian must be open first")
    assert(not workspace:FindFirstChild(TARGET_NAME),
        "The starter mannequin already exists; preserve its animations")
    verify_rig(source)
    local clone = clone_performer(source)
    equip_visuals(clone)
    return HttpService:JSONEncode({
        testRig = clone:GetFullName(),
        originalUnmodified = source.Parent == workspace,
        rigType = tostring(clone.Humanoid.RigType),
        sourceName = SOURCE_NAME,
        testOnly = clone:GetAttribute("DMMO_TestOnly"),
    })
end

return main()
