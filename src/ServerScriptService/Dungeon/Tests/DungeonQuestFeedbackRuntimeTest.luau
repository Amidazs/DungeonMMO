--!strict
-- Focused presentation contract for visible Dungeon quest feedback.

local ServerScriptService = game:GetService("ServerScriptService")

local Runtime = require(
    ServerScriptService.Dungeon.DungeonQuestFeedbackRuntime
)

local checks = 0

--[[
Counts one quest-feedback assertion.

Args:
    condition (boolean): Expected presentation state.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[Dungeon Quest Feedback] " .. label
    )
end

--[[
Creates one anchored test part.

Args:
    parent (Instance): Temporary presentation parent.
    name (string): Stable part name.

Returns:
    BasePart: Test-only physical quest object.
]]
local function part(
    parent: Instance,
    name: string
): BasePart
    local value = Instance.new("Part")
    value.Name = name
    value.Anchored = true
    value.Parent = parent
    return value
end

--[[
Returns feedback text and billboard visibility from one quest object.

Args:
    anchor (BasePart): Physical object expected to own feedback.

Returns:
    string: Current feedback text.
    boolean: Billboard enabled state.
]]
local function feedback(
    anchor: BasePart
): (string, boolean)
    local billboard = assert(
        anchor:FindFirstChild("QuestFeedback")
    ) :: BillboardGui
    local label = assert(
        billboard:FindFirstChild("Text")
    ) :: TextLabel

    return label.Text, billboard.Enabled
end

--[[
Runs Temple and Mine feedback transitions against fake trusted state.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all checks succeed.
]]
local function main()
    local root = Instance.new("Folder")
    root.Name = "FeedbackTestRoot"

    local temple = Instance.new("Folder")
    temple.Name = "DungeonMMOSyntheticTemple"
    temple.Parent = root

    local panel = part(temple, "HiddenPanel")

    local puzzle = Instance.new("Folder")
    puzzle.Name = "ResonancePuzzle"
    puzzle.Parent = temple
    local moon = part(puzzle, "Moon")

    local ward = part(temple, "ResonanceDefenseWard")

    local session = {
        State = "Active",
        InstanceState = {
            EncounterRuntime = {
                EncounterStates = {
                    CombatRoom1 = "Cleared",
                    CombatRoom2 = "Pending",
                },
            },
            QuestInteractions = {},
            PuzzleStates = {},
            DefenseStates = {},
        },
    }

    local bound = Runtime.attach({
        dungeon_id = "TestDungeon",
        difficulty_id = "Depth1",
        workspace = root,
        get_session = function(): any
            return session
        end,
    })
    check(
        bound.ok == true
            and bound.feedback_count == 3,
        "Temple binds three feedback surfaces"
    )

    task.wait(0.3)

    local text, visible = feedback(panel)
    check(
        visible
            and text:find(
                "hidden passage",
                1,
                true
            ) ~= nil,
        "hidden panel explains the secret-room interaction"
    )

    text, visible = feedback(moon)
    check(
        visible
            and text:find(
                "Resonance Shard",
                1,
                true
            ) ~= nil,
        "puzzle feedback explains the prerequisite shard"
    )

    text, visible = feedback(ward)
    check(
        visible
            and text:find(
                "Ward ready",
                1,
                true
            ) ~= nil,
        "defense feedback explains ready state"
    )

    session.InstanceState.EncounterRuntime
        .EncounterStates.CombatRoom2 = "Cleared"
    session.InstanceState.PuzzleStates
        .TempleResonanceLock = {
            NextIndex = 2,
            Completed = false,
        }

    task.wait(0.3)
    text = select(1, feedback(moon))
    check(
        text:find("Next: Root", 1, true) ~= nil,
        "puzzle feedback shows the next ordered rune"
    )

    session.InstanceState.DefenseStates
        .TempleResonanceWard = {
            Started = true,
            Completed = false,
            UnheldSeconds = 1.5,
        }
    task.wait(0.3)
    text = select(1, feedback(ward))
    check(
        text:find(
            "RETURN TO THE WARD",
            1,
            true
        ) ~= nil,
        "defense feedback exposes grace danger"
    )

    session.State = "Complete"

    local mine_root = Instance.new("Folder")
    mine_root.Name = "FeedbackMineRoot"

    local mine = Instance.new("Folder")
    mine.Name = "DungeonMMOSyntheticMine"
    mine.Parent = mine_root
    local surveyor = part(mine, "LostSurveyor")

    local mine_session = {
        State = "Active",
        InstanceState = {
            EscortStates = {
                MineSurveyor = {
                    Started = true,
                    Completed = false,
                    Phase = "WaitingForRoom2",
                },
            },
        },
    }

    local mine_bound = Runtime.attach({
        dungeon_id = "AbandonedMine",
        difficulty_id = "Depth1",
        workspace = mine_root,
        get_session = function(): any
            return mine_session
        end,
    })
    check(
        mine_bound.ok == true
            and mine_bound.feedback_count == 1,
        "Mine binds one escort feedback surface"
    )

    task.wait(0.3)
    text, visible = feedback(surveyor)
    check(
        visible
            and text:find(
                "Secure Room 2",
                1,
                true
            ) ~= nil,
        "escort feedback explains its safe pause"
    )

    mine_session.State = "Complete"
    root:Destroy()
    mine_root:Destroy()

    print(
        ("[Dungeon Quest Feedback] PASS: %d assertions")
            :format(checks)
    )
end

main()
