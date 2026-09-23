-- Six editable R15 clips. Studio-only authoring, never a live combat script.
-- Install under an unpublished, test-only R15 rig with an Animator.

local RunService = game:GetService("RunService")
local Provider = game:GetService("KeyframeSequenceProvider")

local FPS = 60
local NAME_PREFIX = "DMMO_Humanoid_"
local RIG_NAME = "DMMO_Humanoid_Starter_Test"
local REQUIRED_JOINTS = {
    "Root", "Waist", "Neck",
    "LeftShoulder", "LeftElbow", "LeftWrist",
    "RightShoulder", "RightElbow", "RightWrist",
    "LeftHip", "LeftKnee", "LeftAnkle",
    "RightHip", "RightKnee", "RightAnkle",
}
local SPECS = {
    Idle = {duration = 2.0, looped = true,
        priority = Enum.AnimationPriority.Idle},
    Walk = {duration = 1.0, looped = true,
        priority = Enum.AnimationPriority.Movement},
    Run = {duration = 0.7, looped = true,
        priority = Enum.AnimationPriority.Movement},
    Sword = {duration = 1.2, looped = false,
        priority = Enum.AnimationPriority.Action,
        markers = {{frame = 36, name = "Impact", value = "Sword"}}},
    Daggers = {duration = 1.2, looped = false,
        priority = Enum.AnimationPriority.Action,
        markers = {
            {frame = 27, name = "Impact", value = "LeftDagger"},
            {frame = 51, name = "Impact", value = "RightDagger"},
        }},
    Bow = {duration = 1.5, looped = false,
        priority = Enum.AnimationPriority.Action,
        markers = {
            {frame = 63, name = "ArrowRelease", value = "Bow"},
        }},
}
local ORDER = {"Idle", "Walk", "Run", "Sword", "Daggers", "Bow"}
local ATTACK_POSES = {
    Sword = {
        {time = 0.00, joints = {}},
        {time = 0.20, joints = {
            Root = {0, -0.03, 0, 2, -7, 0},
            Waist = {0, 0, 0, -8, -14, -4},
            RightShoulder = {0, 0, 0, -55, -25, 18},
            RightElbow = {0, 0, 0, -58, 0, 0},
            LeftShoulder = {0, 0, 0, 14, 0, -12},
            LeftHip = {0, 0, 0, 5, 0, 0},
        }},
        {time = 0.48, joints = {
            Root = {0, -0.12, 0, 4, -14, 0},
            Waist = {0, 0, 0, -13, -24, -8},
            RightShoulder = {0, 0, 0, -112, -30, 30},
            RightElbow = {0, 0, 0, -78, 0, 0},
            RightWrist = {0, 0, 0, 10, 0, -9},
            LeftShoulder = {0, 0, 0, 28, -5, -20},
            LeftHip = {0, 0, 0, 12, 0, 0},
            RightHip = {0, 0, 0, -12, 0, 0},
        }},
        {time = 0.60, joints = {
            Root = {0, -0.22, 0, 8, 8, 0},
            Waist = {0, 0, 0, 12, 22, 7},
            RightShoulder = {0, 0, 0, 52, 16, -28},
            RightElbow = {0, 0, 0, -16, 0, 0},
            RightWrist = {0, 0, 0, -20, 0, 0},
            LeftShoulder = {0, 0, 0, -10, -4, 14},
            LeftHip = {0, 0, 0, -12, 0, 0},
            RightHip = {0, 0, 0, 15, 0, 0},
        }},
        {time = 0.75, joints = {
            Root = {0, -0.16, 0, 9, 12, 0},
            Waist = {0, 0, 0, 13, 26, 6},
            RightShoulder = {0, 0, 0, 78, 20, -34},
            RightElbow = {0, 0, 0, -13, 0, 0},
            LeftShoulder = {0, 0, 0, -14, 0, 14},
        }},
        {time = 0.98, joints = {
            Root = {0, -0.05, 0, 2, 1, 0},
            Waist = {0, 0, 0, 2, 4, 0},
            RightShoulder = {0, 0, 0, 16, 0, -8},
            RightElbow = {0, 0, 0, -30, 0, 0},
        }},
        {time = 1.20, joints = {}},
    },
    Daggers = {
        {time = 0.00, joints = {}},
        {time = 0.18, joints = {
            Root = {0, -0.09, 0, 6, 0, 0},
            Waist = {0, 0, 0, 7, 0, 0},
            LeftShoulder = {0, 0, 0, -65, 14, -28},
            LeftElbow = {0, 0, 0, -72, 0, 0},
            RightShoulder = {0, 0, 0, -18, -12, 19},
            RightElbow = {0, 0, 0, -62, 0, 0},
            LeftHip = {0, 0, 0, -8, 0, 0},
            RightHip = {0, 0, 0, 10, 0, 0},
        }},
        {time = 0.45, joints = {
            Root = {0, -0.15, 0, 13, -18, -3},
            Waist = {0, 0, 0, 10, -21, -8},
            LeftShoulder = {0, 0, 0, 60, -18, 19},
            LeftElbow = {0, 0, 0, -22, 0, 0},
            LeftWrist = {0, 0, 0, -19, 0, 0},
            RightShoulder = {0, 0, 0, -83, -14, 18},
            RightElbow = {0, 0, 0, -67, 0, 0},
        }},
        {time = 0.62, joints = {
            Root = {0, -0.13, 0, 12, 1, 0},
            Waist = {0, 0, 0, 9, 8, 3},
            LeftShoulder = {0, 0, 0, 24, 0, 10},
            LeftElbow = {0, 0, 0, -48, 0, 0},
            RightShoulder = {0, 0, 0, -109, 12, 28},
            RightElbow = {0, 0, 0, -70, 0, 0},
        }},
        {time = 0.85, joints = {
            Root = {0, -0.16, 0, 12, 18, 4},
            Waist = {0, 0, 0, 12, 22, 8},
            LeftShoulder = {0, 0, 0, -35, 6, -10},
            LeftElbow = {0, 0, 0, -65, 0, 0},
            RightShoulder = {0, 0, 0, 58, -16, -18},
            RightElbow = {0, 0, 0, -24, 0, 0},
            RightWrist = {0, 0, 0, -18, 0, 0},
        }},
        {time = 1.05, joints = {
            Root = {0, -0.05, 0, 4, 0, 0},
            Waist = {0, 0, 0, 3, 0, 0},
            LeftShoulder = {0, 0, 0, -12, 0, -8},
            LeftElbow = {0, 0, 0, -26, 0, 0},
            RightShoulder = {0, 0, 0, 13, 0, 8},
            RightElbow = {0, 0, 0, -32, 0, 0},
        }},
        {time = 1.20, joints = {}},
    },
    Bow = {
        {time = 0.00, joints = {}},
        {time = 0.25, joints = {
            Root = {0, -0.04, 0, 0, -6, 0},
            Waist = {0, 0, 0, 0, -9, 0},
            LeftShoulder = {0, 0, 0, -74, -8, -9},
            LeftElbow = {0, 0, 0, -12, 0, 0},
            LeftWrist = {0, 0, 0, -7, 0, -10},
            RightShoulder = {0, 0, 0, -64, 13, 15},
            RightElbow = {0, 0, 0, -34, 0, 0},
        }},
        {time = 0.78, joints = {
            Root = {0, -0.05, 0, 0, -8, 0},
            Waist = {0, 0, 0, 1, -13, 0},
            LeftShoulder = {0, 0, 0, -87, -12, -12},
            LeftElbow = {0, 0, 0, -8, 0, 0},
            RightShoulder = {0, 0, 0, -79, 41, 21},
            RightElbow = {0, 0, 0, -105, 0, 0},
            RightWrist = {0, 0, 0, -16, -7, 7},
            Neck = {0, 0, 0, 0, 13, 0},
        }},
        {time = 1.05, joints = {
            Root = {0, -0.04, 0, 0, -8, 0},
            Waist = {0, 0, 0, 1, -13, 0},
            LeftShoulder = {0, 0, 0, -87, -12, -12},
            LeftElbow = {0, 0, 0, -8, 0, 0},
            RightShoulder = {0, 0, 0, -79, 39, 21},
            RightElbow = {0, 0, 0, -96, 0, 0},
            RightWrist = {0, 0, 0, -13, -7, 7},
            Neck = {0, 0, 0, 0, 13, 0},
        }},
        {time = 1.14, joints = {
            Root = {0, -0.03, 0, 1, -8, 0},
            Waist = {0, 0, 0, 1, -10, 0},
            LeftShoulder = {0, 0, 0, -86, -12, -12},
            LeftElbow = {0, 0, 0, -9, 0, 0},
            RightShoulder = {0, 0, 0, -72, 17, 18},
            RightElbow = {0, 0, 0, -51, 0, 0},
            Neck = {0, 0, 0, 0, 10, 0},
        }},
        {time = 1.33, joints = {
            Root = {0, -0.02, 0, 0, 0, 0},
            LeftShoulder = {0, 0, 0, -28, 0, -3},
            LeftElbow = {0, 0, 0, -13, 0, 0},
            RightShoulder = {0, 0, 0, -25, 0, 4},
            RightElbow = {0, 0, 0, -23, 0, 0},
        }},
        {time = 1.50, joints = {}},
    },
}

local M = {}
local rig = script.Parent
local motors = {}
local activeTrack = nil
local activeConnection = nil

-- Args: None.
-- Returns: Humanoid, Animator - validated test rig and animation player.
local function validate_rig()
    assert(RunService:IsStudio() and game.PlaceId == 0,
        "Humanoid starter animations require an unpublished Studio place")
    assert(rig.Name == RIG_NAME and rig:GetAttribute("DMMO_TestOnly"),
        "Install the generator on its isolated, marked R15 test model")
    local humanoid = rig:FindFirstChildOfClass("Humanoid")
    assert(humanoid and humanoid.RigType == Enum.HumanoidRigType.R15,
        "The test performer must use an R15 Humanoid")
    local animator = humanoid:FindFirstChildOfClass("Animator")
    assert(animator, "The test performer needs a Humanoid.Animator")
    local root = rig:FindFirstChild("HumanoidRootPart")
    assert(root and root.Anchored, "Anchor the test root before authoring")
    return humanoid, animator
end

-- Args: None.
-- Returns: nil - fills the local verified body-joint map.
local function read_motors()
    local discovered = {}
    for _, item in rig:GetDescendants() do
        if item:IsA("Motor6D") then
            assert(not discovered[item.Name],
                "Duplicate motor name: " .. item.Name)
            discovered[item.Name] = item
        end
    end
    for _, name in REQUIRED_JOINTS do
        local joint = discovered[name]
        assert(joint and joint.Part0 and joint.Part1,
            "Missing or disconnected R15 joint: " .. name)
        motors[name] = joint
    end
end

-- Args: degrees (number) - joint rotation angle.
-- Returns: number - radians for Roblox CFrame calculations.
local function radians(degrees)
    return math.rad(degrees)
end

-- Args: x, y, z (number) - degree angles.
-- Returns: CFrame - local XYZ joint rotation.
local function rotation(x, y, z)
    return CFrame.Angles(radians(x), radians(y), radians(z))
end

-- Args: angle (number) - unit fraction to interpolate.
-- Returns: number - eased progress from zero to one.
local function smoothstep(angle)
    local t = math.clamp(angle, 0, 1)
    return t * t * (3 - 2 * t)
end

-- Args: data ({number}?) - x,y,z position followed by XYZ degree angles.
-- Returns: CFrame - one editable motor transform.
local function transform(data)
    if not data then
        return CFrame.identity
    end
    assert(#data == 6, "A joint control requires six numbers")
    return CFrame.new(data[1], data[2], data[3])
        * rotation(data[4], data[5], data[6])
end

-- Args: name (string), t (number) - selected action and time.
-- Returns: {[string]: CFrame} - all R15 joint motions at this sample.
local function attack_transforms(name, t)
    local poses = ATTACK_POSES[name]
    local before, after = poses[1], poses[#poses]
    for index = 1, #poses - 1 do
        if t >= poses[index].time and t <= poses[index + 1].time then
            before, after = poses[index], poses[index + 1]
            break
        end
    end
    local alpha = smoothstep(
        (t - before.time) / math.max(after.time - before.time, 1e-5)
    )
    local result = {}
    for _, joint in REQUIRED_JOINTS do
        local original = transform(before.joints[joint])
        local target = transform(after.joints[joint])
        result[joint] = original:Lerp(target, alpha)
    end
    return result
end

-- Args: t (number) - seconds within the looping idle.
-- Returns: {[string]: CFrame} - gentle breathing without foot movement.
local function idle_transforms(t)
    local phase = t * math.pi
    local inhale = math.sin(phase)
    return {
        Root = CFrame.new(0, 0.013 * inhale, 0),
        Waist = rotation(1.2 * inhale, 0, 0),
        Neck = rotation(-0.5 * inhale, 0, 0),
        LeftShoulder = rotation(0.8 * inhale, 0, 0),
        RightShoulder = rotation(0.8 * inhale, 0, 0),
    }
end

-- Args: phase (number), speed (number), running (boolean).
-- Returns: {[string]: CFrame} - one side's hip/knee/ankle and arm angles.
local function limb_angles(phase, speed, running)
    local swing = math.sin(phase)
    local airborne = math.max(0, swing)
    local hip = speed * swing
    local knee = (running and 47 or 22) * airborne
    return {
        hip = hip,
        knee = knee,
        ankle = -0.38 * hip - 0.32 * knee,
        shoulder = -hip * (running and 0.77 or 0.55),
        elbow = (running and -48 or -10) - 6 * airborne,
    }
end

-- Args: name (string), t (number) - Walk/Run and phase time.
-- Returns: {[string]: CFrame} - mirrored full-body in-place locomotion.
local function locomotion_transforms(name, t)
    local running = name == "Run"
    local duration = SPECS[name].duration
    local phase = 2 * math.pi * t / duration
    local reach = running and 36 or 24
    local left = limb_angles(phase, reach, running)
    local right = limb_angles(phase + math.pi, reach, running)
    local body_bob = running and 0.080 or 0.037
    local lean = running and 7 or 1.8
    return {
        Root = CFrame.new(0, body_bob * (1 - math.cos(2 * phase)) / 2, 0)
            * rotation(lean, 0, 1.4 * math.sin(phase)),
        Waist = rotation(-lean * 0.22, 0,
            (running and 3.0 or 2.1) * math.sin(phase)),
        Neck = rotation(-lean * 0.2, 0, 0),
        LeftHip = rotation(left.hip, 0, 0),
        LeftKnee = rotation(left.knee, 0, 0),
        LeftAnkle = rotation(left.ankle, 0, 0),
        RightHip = rotation(right.hip, 0, 0),
        RightKnee = rotation(right.knee, 0, 0),
        RightAnkle = rotation(right.ankle, 0, 0),
        LeftShoulder = rotation(left.shoulder, 0, 0),
        LeftElbow = rotation(left.elbow, 0, 0),
        RightShoulder = rotation(right.shoulder, 0, 0),
        RightElbow = rotation(right.elbow, 0, 0),
    }
end

-- Args: name (string), t (number) - clip and seconds to sample.
-- Returns: {[string]: CFrame} - complete joint pose for that instant.
function M.Pose(name, t)
    local spec = SPECS[name]
    assert(spec, "Unknown humanoid animation: " .. tostring(name))
    local time = math.clamp(t, 0, spec.duration)
    local requested
    if name == "Idle" then
        requested = idle_transforms(time)
    elseif name == "Walk" or name == "Run" then
        requested = locomotion_transforms(name, time)
    else
        requested = attack_transforms(name, time)
    end
    local complete = {}
    for _, joint in REQUIRED_JOINTS do
        complete[joint] = requested[joint] or CFrame.identity
    end
    return complete
end

-- Args: jointMap ({[string]: CFrame}), frameIndex (number).
-- Returns: Keyframe - full editable R15 pose hierarchy at this frame.
local function build_keyframe(jointMap, frameIndex)
    local key = Instance.new("Keyframe")
    key.Time = frameIndex / FPS
    key.Name = string.format("Frame_%03d", frameIndex)
    local root = Instance.new("Pose")
    root.Name = "HumanoidRootPart"
    root.Weight = 1
    root.Parent = key
    local poses = {HumanoidRootPart = root}
    local remaining = {}
    for _, name in REQUIRED_JOINTS do
        remaining[name] = motors[name]
    end
    for _ = 1, 5 do
        for name, joint in remaining do
            local parent = poses[joint.Part0.Name]
            if parent then
                local pose = Instance.new("Pose")
                pose.Name = joint.Part1.Name
                pose.Weight = 1
                pose.CFrame = jointMap[name]
                pose.EasingStyle = Enum.PoseEasingStyle.Linear
                pose.Parent = parent
                poses[joint.Part1.Name] = pose
                remaining[name] = nil
            end
        end
    end
    assert(next(remaining) == nil, "R15 joint pose tree is incomplete")
    return key
end

-- Args: name (string) - one of the six supported motion names.
-- Returns: KeyframeSequence - new editable sequence on the test rig.
function M.Build(name)
    validate_rig()
    local spec = SPECS[name]
    assert(spec, "Unknown humanoid animation: " .. tostring(name))
    local filename = NAME_PREFIX .. name .. "_v1"
    assert(not rig:FindFirstChild(filename),
        "Sequence already exists; preserve the original: " .. filename)
    local sequence = Instance.new("KeyframeSequence")
    sequence.Name = filename
    sequence.Loop = spec.looped
    sequence.Priority = spec.priority
    local count = math.round(spec.duration * FPS)
    for frame = 0, count do
        local key = build_keyframe(M.Pose(name, frame / FPS), frame)
        key.Parent = sequence
        for _, markerSpec in spec.markers or {} do
            if markerSpec.frame == frame then
                local marker = Instance.new("KeyframeMarker")
                marker.Name = markerSpec.name
                marker.Value = markerSpec.value
                marker.Parent = key
            end
        end
    end
    sequence:SetAttribute("Duration", spec.duration)
    sequence:SetAttribute("DMMO_TestOnly", true)
    sequence:SetAttribute("MotionName", name)
    sequence:SetAttribute("SampleRateHz", FPS)
    sequence.Parent = rig
    return sequence
end

-- Args: None.
-- Returns: {[string]: KeyframeSequence} - six independent editable clips.
function M.BuildAll()
    local sequences = {}
    for _, name in ORDER do
        sequences[name] = M.Build(name)
    end
    return sequences
end

-- Args: name (string) - clip whose visible test weapon should be shown.
-- Returns: nil - chooses only the matching test props, never gameplay weapons.
function M.Equip(name)
    assert(SPECS[name], "Unknown preview weapon action: " .. tostring(name))
    local selected = {
        Sword = {"DMMO_TestSword_Right"},
        Daggers = {"DMMO_TestDagger_Left", "DMMO_TestDagger_Right"},
        Bow = {
            "DMMO_TestBowGrip", "DMMO_TestBowUpper",
            "DMMO_TestBowLower", "DMMO_TestArrow",
        },
    }
    local visible = {}
    for _, propName in selected[name] or {} do
        visible[propName] = true
    end
    for _, part in rig:GetDescendants() do
        if part:IsA("BasePart") and part.Name:match("^DMMO_Test") then
            part.Transparency = visible[part.Name] and 0 or 1
        end
    end
end

-- Args: None.
-- Returns: nil - stops this generator's track and clears transient transforms.
function M.Stop()
    if activeTrack then
        activeTrack:Stop(0)
        activeTrack = nil
    end
    if activeConnection then
        activeConnection:Disconnect()
        activeConnection = nil
    end
    local _, animator = validate_rig()
    if not RunService:IsRunning() then
        animator:StepAnimations(0)
    end
    for _, joint in REQUIRED_JOINTS do
        motors[joint].Transform = CFrame.identity
    end
    for _, item in rig:GetDescendants() do
        if item:IsA("AnimationConstraint") then
            item.Transform = CFrame.identity
        end
    end
end

-- Args: name (string), speed (number?) - built clip and playback speed.
-- Returns: AnimationTrack - actual R15 Studio Animator preview track.
function M.Play(name, speed)
    M.Stop()
    local _, animator = validate_rig()
    local sequence = rig:FindFirstChild(NAME_PREFIX .. name .. "_v1")
    assert(sequence and sequence:IsA("KeyframeSequence"),
        "Build the motion before preview: " .. tostring(name))
    M.Equip(name)
    local animation = Instance.new("Animation")
    animation.Name = sequence.Name .. "_Preview"
    animation.AnimationId = Provider:RegisterKeyframeSequence(sequence)
    local track = animator:LoadAnimation(animation)
    track.Looped = SPECS[name].looped
    track.Priority = SPECS[name].priority
    activeTrack = track
    M.markerCounts = {Impact = 0, ArrowRelease = 0}
    track:GetMarkerReachedSignal("Impact"):Connect(function(value)
        M.markerCounts.Impact += 1
        rig:SetAttribute("DMMO_LastImpact", value)
    end)
    track:GetMarkerReachedSignal("ArrowRelease"):Connect(function(value)
        M.markerCounts.ArrowRelease += 1
        rig:SetAttribute("DMMO_LastArrowRelease", value)
        local arrow = rig:FindFirstChild("DMMO_TestArrow")
        if arrow then
            arrow.Transparency = 1
        end
    end)
    track:Play(0.08, 1, speed or 1)
    if not RunService:IsRunning() then
        activeConnection = RunService.Heartbeat:Connect(function(dt)
            animator:StepAnimations(dt)
        end)
    end
    return track
end

-- Args: None.
-- Returns: {string} - deterministic build order for the six actions.
function M.Names()
    return table.clone(ORDER)
end

validate_rig()
read_motors()
return M
