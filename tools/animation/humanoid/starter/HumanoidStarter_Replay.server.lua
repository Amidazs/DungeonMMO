-- Run only as a disabled-until-authorized Script in an unpublished R15 test rig.
-- Replays the six prebuilt editable clips, never applying damage.

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local RIG_NAME = "DMMO_Humanoid_Starter_Test"
local MODULE_NAME = "DMMO_Humanoid_Starter_Generator"
local DURATION = {
    Idle = 2.0,
    Walk = 1.0,
    Run = 0.7,
    Sword = 1.2,
    Daggers = 1.2,
    Bow = 1.5,
}
local MARKER_COUNTS = {
    Idle = 0,
    Walk = 0,
    Run = 0,
    Sword = 1,
    Daggers = 2,
    Bow = 1,
}
local LOOPS = {Idle = 2, Walk = 2, Run = 2}

-- Args: character (Model) - isolated, anchored test mannequin.
-- Returns: nil - keeps weapon grips and source gameplay separate.
local function check_preview_character(character)
    assert(RunService:IsStudio() and game.PlaceId == 0,
        "Humanoid replay is restricted to an unpublished Studio place")
    assert(character.Name == RIG_NAME
        and character:GetAttribute("DMMO_TestOnly"),
        "Replay must run beneath the independent R15 mannequin")
    assert(character.HumanoidRootPart.Anchored,
        "Do not unanchor the test rig for in-place animation replay")
    assert(character:FindFirstChild(MODULE_NAME),
        "Build the six sequences with the source-controlled generator")
end

-- Args: rig (Model), builder (table), action (string).
-- Returns: table - actual marker counts and timing from this test pass.
local function replay_action(rig, builder, action)
    local repetitions = LOOPS[action] or 1
    local track = builder.Play(action)
    task.wait(DURATION[action] * repetitions + 0.15)
    local recorded = table.clone(builder.markerCounts)
    builder.Stop()
    local expected = MARKER_COUNTS[action]
    local actual = action == "Bow"
        and recorded.ArrowRelease or recorded.Impact
    assert(actual == expected,
        string.format("%s marker mismatch: %d versus %d",
            action, actual, expected))
    local result = {
        action = action,
        repeated = repetitions,
        impactMarkers = recorded.Impact,
        arrowReleaseMarkers = recorded.ArrowRelease,
        duration = DURATION[action],
        clipName = "DMMO_Humanoid_" .. action .. "_v1",
    }
    rig:SetAttribute("DMMO_LastTestedAction", action)
    return result
end

-- Args: None.
-- Returns: nil - performs actual Studio playback without publishing.
local function main()
    local rig = script.Parent
    check_preview_character(rig)
    local builder = require(rig[MODULE_NAME])
    local summary = {}
    for _, action in builder.Names() do
        local result = replay_action(rig, builder, action)
        table.insert(summary, result)
        print("DMMO_HUMANOID_REPLAY",
            HttpService:JSONEncode(result))
    end
    assert(workspace:FindFirstChild(RIG_NAME) == rig,
        "The independent test performer disappeared during replay")
    rig:SetAttribute("DMMO_HumanoidStarterQA", "PLAYBACK_MARKERS_CHECKED")
    print("DMMO_HUMANOID_REPLAY_COMPLETE",
        HttpService:JSONEncode(summary))
end

main()
