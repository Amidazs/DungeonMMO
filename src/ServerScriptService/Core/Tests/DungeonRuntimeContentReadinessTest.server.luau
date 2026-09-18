--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local module = Shared:FindFirstChild("DungeonRuntimeContentReadiness")
if not module then
    error(
        "[Dungeon Runtime Content Readiness Tests] RED: "
            .. "DungeonRuntimeContentReadiness is missing."
    )
end

local Definitions = require(
    Shared:WaitForChild("DungeonDifficultyDefinitions")
)
local Readiness = require(module)

local assertion_count = 0

-- Verifies one readiness-contract expectation.
local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Runtime Content Readiness Tests] " .. message,
            2
        )
    end
end

-- Returns whether one diagnostic issue code is present.
local function has_issue(analysis: any, code: string): boolean
    for _, issue in ipairs(analysis.Issues or {}) do
        if issue.Code == code then
            return true
        end
    end
    return false
end

local unknown_dungeon = Readiness.analyze(
    "UnknownDungeon",
    "Depth1"
)
check(
    unknown_dungeon.ok == false
        and unknown_dungeon.reason == "UnknownDungeon",
    "Unknown dungeons must fail explicitly."
)

local unknown_depth = Readiness.analyze(
    "TestDungeon",
    "UnknownDepth"
)
check(
    unknown_depth.ok == false
        and unknown_depth.reason == "UnknownDifficulty",
    "Unknown difficulties must fail explicitly."
)

for _, dungeon_id in ipairs({
    "TestDungeon",
    "AbandonedMine",
}) do
    local depth1 = Readiness.analyze(dungeon_id, "Depth1")
    check(depth1.ok == true, dungeon_id .. " Depth1 analysis must succeed.")
    check(depth1.Ready == true, dungeon_id .. " Depth1 must be ready.")
    check(
        depth1.ContentComplete == true,
        dungeon_id .. " Depth1 content must be complete."
    )
    check(
        depth1.ReleaseEnabled == true,
        dungeon_id .. " Depth1 release must remain enabled."
    )
    check(
        #(depth1.Issues or {}) == 0,
        dungeon_id .. " Depth1 must have no readiness issues."
    )

    local definition = Definitions.get(dungeon_id, "Depth1")
    check(
        definition.RuntimeReady == nil,
        dungeon_id .. " must not expose the old RuntimeReady switch."
    )
    check(
        definition.RuntimeReleaseEnabled == true,
        dungeon_id .. " Depth1 release switch must be explicit."
    )
end

for _, dungeon_id in ipairs({
    "TestDungeon",
    "AbandonedMine",
}) do
    for depth = 2, 4 do
        local difficulty_id = "Depth" .. tostring(depth)
        local analysis = Readiness.analyze(
            dungeon_id,
            difficulty_id
        )

        check(
            analysis.ok == true,
            dungeon_id .. " " .. difficulty_id
                .. " analysis must succeed."
        )
        check(
            analysis.Ready == false,
            dungeon_id .. " " .. difficulty_id
                .. " must remain fail closed."
        )
        check(
            analysis.ContentComplete == false,
            dungeon_id .. " " .. difficulty_id
                .. " content must remain incomplete."
        )
        check(
            analysis.ReleaseEnabled == false,
            dungeon_id .. " " .. difficulty_id
                .. " release must remain disabled."
        )
        check(
            has_issue(analysis, "DungeonLayoutNotRegistered"),
            dungeon_id .. " " .. difficulty_id
                .. " must report its missing physical layout."
        )
        if depth <= 4 then
            check(
                not has_issue(
                    analysis,
                    "EncounterContentNotRegistered"
                ),
                dungeon_id .. " " .. difficulty_id
                    .. " encounter content must be fully registered."
            )
            check(
                #(analysis.Issues or {}) == 1,
                dungeon_id .. " " .. difficulty_id
                    .. " must fail only on its missing"
                    .. " physical layout."
            )
        end

        local definition = Definitions.get(
            dungeon_id,
            difficulty_id
        )
        check(
            definition.RuntimeReady == nil,
            dungeon_id .. " " .. difficulty_id
                .. " must not expose RuntimeReady."
        )
        check(
            definition.RuntimeReleaseEnabled == false,
            dungeon_id .. " " .. difficulty_id
                .. " release switch must remain disabled."
        )
    end
end

print(string.format(
    "[Dungeon Runtime Content Readiness Tests] PASS: %d assertions.",
    assertion_count
))
