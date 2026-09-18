--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Services")

local Director = require(
    Services:WaitForChild("DungeonInstanceDirector")
)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Difficulty Instance Director Tests] "
                .. message,
            2
        )
    end
end

local state = Director.resolve(
    "TestDungeon",
    "depth4-session",
    4000,
    {},
    "Depth4"
)
check(
    state.DifficultyId == "Depth4",
    "Instance state must carry difficulty ID."
)
check(
    state.DifficultyOrder == 4,
    "Instance state must carry difficulty order."
)
check(
    type(state.EncounterSequence) == "table"
        and #state.EncounterSequence == 6,
    "Depth4 immutable plan must carry six encounters."
)
check(
    state.EncounterSequence[2].Kind == "MiniBoss"
        and state.EncounterSequence[4].Kind == "MiniBoss"
        and state.EncounterSequence[5].Kind == "MiniBoss",
    "Final-depth plan must preserve prior-boss miniboss roles."
)
check(
    state.EncounterSequence[6].Kind == "FinalBoss",
    "Final-depth plan must end in a true final boss."
)

state.EncounterSequence[1].Id = "Mutated"
local second = Director.resolve(
    "TestDungeon",
    "depth4-session",
    4000,
    {},
    "Depth4"
)
check(
    second.EncounterSequence[1].Id ~= "Mutated",
    "Resolved encounter plans must be detached copies."
)

local legacy = Director.resolve(
    "TestDungeon",
    "legacy-session",
    4000,
    {}
)
check(
    legacy.DifficultyId == "Depth1"
        and legacy.DifficultyOrder == 1,
    "Legacy director calls must default to Depth1."
)

print(string.format(
    "[Dungeon Difficulty Instance Director Tests] PASS: %d assertions.",
    assertion_count
))
