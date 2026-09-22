-- Isolated humanoid lasso motion authoring and preview.
-- Requires the separately created DMMO_Lasso_Character_Test R15 mannequin.
local M = {}
local rig = script.Parent
local RunService = game:GetService("RunService")
assert(RunService:IsStudio() and game.PlaceId == 0
    and rig.Name == "DMMO_Lasso_Character_Test"
    and rig:GetAttribute("DMMO_TestOnly"),
    "The lasso generator is test-only; use unpublished Place1")
local animator = rig.Humanoid:FindFirstChildWhichIsA("Animator")
assert(animator, "Humanoid Animator missing")
local motors, parts, base = {}, {}, {}
for _, object in rig:GetDescendants() do
    if object:IsA("Motor6D") then motors[object.Name] = object end
    if object:IsA("BasePart") then
        parts[object.Name] = object
        base[object.Name] = object.CFrame
    end
end
assert(motors.Root and motors.RightShoulder and motors.RightElbow
    and motors.LassoGripMotor and parts.LassoGrip,
    "Test skeleton or its rope grip is incomplete")
for _ = 1, 6 do
    for _, joint in motors do
        base[joint.Part1.Name] = base[joint.Part0.Name]
            * joint.C0 * joint.C1:Inverse()
    end
end
local root = base.HumanoidRootPart
local DURATION = 1.5
local TRANSITION = .6
local function angle(degrees)
    return math.rad(degrees)
end
local function rot(pitch, yaw, roll)
    return CFrame.Angles(angle(pitch or 0), angle(yaw or 0),
        angle(roll or 0))
end
local function smooth(value)
    value = math.clamp(value, 0, 1)
    return value * value * (3 - 2 * value)
end
local function fk(name, from, transform)
    local joint = motors[name]
    return from * joint.C0 * (transform or CFrame.identity) * joint.C1:Inverse()
end
function M.Pose(time, action)
    local raised, phase
    if action == "Raise" then
        raised = smooth(time / TRANSITION)
        phase = 0
    elseif action == "Lower" then
        raised = 1 - smooth(time / TRANSITION)
        phase = 0
    else
        raised = 1
        phase = (time / DURATION) * math.pi * 2
    end
    local sin, cos = math.sin(phase), math.cos(phase)
    local tr = {}
    for name in motors do tr[name] = CFrame.identity end
    tr.Root = CFrame.identity -- Preserve both planted feet.
    tr.Waist = rot(0, raised * (3 * sin), raised * (2 * cos))
    tr.Neck = rot(raised * (2 * cos), raised * (-2 * sin), 0)
    tr.RightShoulder = rot(raised * (125 + 8 * cos),
        raised * (-60 + 8 * sin), raised * (-60 + 7 * sin))
    tr.RightElbow = rot(raised * (30 + 7 * sin), 0, 0)
    tr.RightWrist = rot(raised * (10 + 12 * cos),
        raised * (8 * sin), raised * (-16 + 12 * cos))
    tr.LeftShoulder = rot(raised * (-8 + 4 * sin),
        raised * (6 * cos), raised * (10 * sin))
    tr.LeftElbow = rot(raised * (5 + 2 * sin), 0, 0)
    local frames = {HumanoidRootPart = root}
    frames.LowerTorso = fk("Root", root, tr.Root)
    frames.UpperTorso = fk("Waist", frames.LowerTorso, tr.Waist)
    frames.Head = fk("Neck", frames.UpperTorso, tr.Neck)
    for _, side in {"Left", "Right"} do
        local arm = side .. "UpperArm"
        local fore = side .. "LowerArm"
        local hand = side .. "Hand"
        frames[arm] = fk(side .. "Shoulder",
            frames.UpperTorso, tr[side .. "Shoulder"])
        frames[fore] = fk(side .. "Elbow",
            frames[arm], tr[side .. "Elbow"])
        frames[hand] = fk(side .. "Wrist",
            frames[fore], tr[side .. "Wrist"])
        frames[side .. "UpperLeg"] = fk(side .. "Hip",
            frames.LowerTorso, tr[side .. "Hip"])
        frames[side .. "LowerLeg"] = fk(side .. "Knee",
            frames[side .. "UpperLeg"], tr[side .. "Knee"])
        frames[side .. "Foot"] = fk(side .. "Ankle",
            frames[side .. "LowerLeg"], tr[side .. "Ankle"])
    end
    frames.LassoGrip = fk("LassoGripMotor", frames.RightHand)
    return tr, frames, {phase = phase, raised = raised}
end
function M.Show(time, action)
    local transforms, positions, state = M.Pose(time, action)
    for name, joint in motors do
        joint.Transform = transforms[name]
    end
    for name, cf in positions do
        if parts[name] then parts[name].CFrame = cf end
    end
    return state
end

function M.Reset()
    for _, name in {"Raise", "Swing", "Lower"} do
        local track = M.tracks and M.tracks[name]
        if track then track:Stop(0) end
    end
    if M.connection then M.connection:Disconnect(); M.connection = nil end
    if not RunService:IsRunning() then
        animator:StepAnimations(0)
    end
    for _, object in rig:GetDescendants() do
        if object:IsA("AnimationConstraint") then
            object.Transform = CFrame.identity
        end
    end
    for _, motor in motors do motor.Transform = CFrame.identity end
    for name, cf in base do
        if parts[name] then parts[name].CFrame = cf end
    end
end

local function keyframe(time, action, index)
    local transforms = M.Pose(time, action)
    local key = Instance.new("Keyframe")
    key.Name = string.format("%s_%03d", action, index)
    key.Time = time
    local poses = {}
    local basePose = Instance.new("Pose")
    basePose.Name = "HumanoidRootPart"
    basePose.Weight = 1
    poses.HumanoidRootPart = basePose
    basePose.Parent = key
    local remaining = {}
    for name, joint in motors do
        if name ~= "LassoGripMotor" then
            remaining[name] = joint
        end
    end
    for _ = 1, 6 do
        for name, joint in remaining do
            local parent = poses[joint.Part0.Name]
            if parent then
                local pose = Instance.new("Pose")
                pose.Name = joint.Part1.Name
                pose.Weight = 1
                pose.CFrame = transforms[name]
                pose.EasingStyle = Enum.PoseEasingStyle.Linear
                pose.Parent = parent
                poses[joint.Part1.Name] = pose
                remaining[name] = nil
            end
        end
    end
    assert(next(remaining) == nil, "Incomplete lasso pose hierarchy")
    return key
end

function M.Build()
    M.Reset()
    local specs = {
        {name = "DMMO_Lasso_Raise", action = "Raise",
            length = TRANSITION, frames = 36, looped = false},
        {name = "DMMO_Lasso_Swing_Loop", action = "Swing",
            length = DURATION, frames = 90, looped = true},
        {name = "DMMO_Lasso_Lower", action = "Lower",
            length = TRANSITION, frames = 36, looped = false},
    }
    local result = {}
    for _, spec in specs do
        local previous = rig:FindFirstChild(spec.name)
        if previous then previous:Destroy() end
        local sequence = Instance.new("KeyframeSequence")
        sequence.Name = spec.name
        sequence.Priority = Enum.AnimationPriority.Action
        sequence.Loop = spec.looped
        for index = 0, spec.frames do
            local time = spec.length * index / spec.frames
            local frame = keyframe(time, spec.action, index)
            frame.Parent = sequence
        end
        sequence:SetAttribute("DMMO_TestOnly", true)
        sequence:SetAttribute("Duration", spec.length)
        sequence:SetAttribute("Purpose",
            "R15 overhead lasso: raise, smooth circular motion, lower")
        sequence.Parent = rig
        result[spec.action] = sequence
    end
    return result
end
function M.StartPreview()
    M.Reset()
    local names = {Raise = "DMMO_Lasso_Raise",
        Swing = "DMMO_Lasso_Swing_Loop",
        Lower = "DMMO_Lasso_Lower"}
    local clips = {}
    M.tracks = {}
    for action, sequenceName in names do
        local sequence = rig:FindFirstChild(sequenceName)
        assert(sequence and sequence:IsA("KeyframeSequence"),
            "Build the lasso clips before preview: " .. sequenceName)
        local animation = Instance.new("Animation")
        animation.Name = "DMMO_Lasso_" .. action .. "_Preview"
        animation.AnimationId = game:GetService(
            "KeyframeSequenceProvider"):RegisterKeyframeSequence(sequence)
        clips[action] = animation
        M.tracks[action] = animator:LoadAnimation(animation)
        M.tracks[action].Priority = Enum.AnimationPriority.Action
    end
    local raise = M.tracks.Raise
    raise:Play(0.05, 1, 1)
    M.previewState = "Raise"
    return M.tracks
end
return M
