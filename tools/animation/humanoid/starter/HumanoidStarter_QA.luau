-- Run once in the unpublished test place after installing the ModuleScript.
-- Produces six distinct editable R15 clips and checks their keyframe data.

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local RIG_NAME = "DMMO_Humanoid_Starter_Test"
local GENERATOR_NAME = "DMMO_Humanoid_Starter_Generator"
local FPS = 60
local EXPECTED = {
    Idle = {duration = 2.0, looped = true, markers = 0},
    Walk = {duration = 1.0, looped = true, markers = 0},
    Run = {duration = 0.7, looped = true, markers = 0},
    Sword = {duration = 1.2, looped = false, markers = 1},
    Daggers = {duration = 1.2, looped = false, markers = 2},
    Bow = {duration = 1.5, looped = false, markers = 1},
}

-- Args: sequence (KeyframeSequence) - just-built editable R15 clip.
-- Returns: number - total semantic markers across its complete timeline.
local function count_markers(sequence)
    local total = 0
    for _, frame in sequence:GetKeyframes() do
        total += #frame:GetMarkers()
    end
    return total
end

-- Args: sequence (KeyframeSequence), duration (number).
-- Returns: nil - verifies the baked 60 Hz timeline and its endpoint.
local function assert_timeline(sequence, duration)
    local frames = sequence:GetKeyframes()
    local count = math.round(duration * FPS)
    assert(#frames == count + 1, "Wrong key count: " .. sequence.Name)
    local timeSet = {}
    local lastTime = -1
    for _, frame in frames do
        local tick = math.round(frame.Time * FPS)
        assert(tick >= 0 and tick <= count,
            "A keyframe exceeds the clip timeline")
        assert(not timeSet[tick], "Duplicate animation sample at " .. tick)
        timeSet[tick] = true
        if frame.Time > lastTime then
            lastTime = frame.Time
        end
    end
    assert(math.abs(lastTime - duration) < 1e-5,
        "Incorrect animation duration: " .. sequence.Name)
    for tick = 0, count do
        assert(timeSet[tick], "Missing sample " .. tick)
    end
end

-- Args: sequence (KeyframeSequence), expected (table).
-- Returns: table - per-clip names, times and marker counts for review.
local function inspect_clip(sequence, expected)
    assert(sequence:IsA("KeyframeSequence"), "Clip is not editable")
    assert(sequence.Loop == expected.looped,
        "Loop mismatch: " .. sequence.Name)
    assert_timeline(sequence, expected.duration)
    local markers = count_markers(sequence)
    assert(markers == expected.markers,
        "Attack marker mismatch: " .. sequence.Name)
    return {
        name = sequence.Name,
        duration = expected.duration,
        looping = sequence.Loop,
        frames = #sequence:GetKeyframes(),
        markers = markers,
    }
end

-- Args: None.
-- Returns: string - JSON report for the six development-only clips.
local function main()
    assert(RunService:IsStudio() and game.PlaceId == 0,
        "Humanoid sequence QA requires unpublished Roblox Studio")
    local character = workspace:FindFirstChild(RIG_NAME)
    assert(character and character:GetAttribute("DMMO_TestOnly"),
        "Run the isolated humanoid test-rig setup first")
    local module = character:FindFirstChild(GENERATOR_NAME)
    assert(module and module:IsA("ModuleScript"),
        "Install the GitHub generator as a test rig ModuleScript")
    local original = workspace:FindFirstChild(
        "DMMO_Astra_Guardian_Test"
    )
    if original then
        assert(original ~= character,
            "Never build the new clips on the source guardian")
    end
    local builder = require(module)
    local built = builder.BuildAll()
    local output = {}
    for _, name in builder.Names() do
        assert(built[name].Parent == character,
            "The animation was stored outside its isolated test rig")
        output[name] = inspect_clip(built[name], EXPECTED[name])
    end
    return HttpService:JSONEncode({
        status = "EDITABLE SEQUENCES BUILT; Studio visual QA pending",
        testRig = character:GetFullName(),
        originalRigUnmodified = original == nil
            or original.Parent == workspace,
        clips = output,
    })
end

return main()
