--!strict
local Base = script.Parent.Parent

local module = Base:FindFirstChild("DungeonEntrySelectionRules")
if not module then
    error(
        "[Dungeon Entry Selection Rules Tests] RED: "
            .. "DungeonEntrySelectionRules is missing."
    )
end

local Rules = require(module)
local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error("[Dungeon Entry Selection Rules Tests] " .. message, 2)
    end
end

local legacy = Rules.resolve("TestDungeon")
check(legacy.ok == true, "Legacy string request must remain valid.")
check(legacy.DungeonId == "TestDungeon", "Legacy dungeon ID mismatch.")
check(legacy.DifficultyId == "Depth1", "Legacy request must default to Depth1.")

local structured = Rules.resolve({
    DungeonId = "TestDungeon",
    DifficultyId = "Depth2",
    EnemyHealthMultiplier = 999,
    RewardMultiplier = 999,
})
check(structured.ok == true, "Structured request must resolve.")
check(structured.DifficultyId == "Depth2", "Structured difficulty mismatch.")
check(
    structured.EnemyHealthMultiplier == nil
        and structured.RewardMultiplier == nil,
    "Client tuning values must never enter the resolved authority payload."
)

check(
    Rules.resolve({
        DungeonId = "TestDungeon",
        DifficultyId = 2,
    }).reason == "UnknownDifficulty",
    "Non-string difficulty IDs must be rejected."
)
check(
    Rules.resolve("UnknownDungeon").reason == "UnknownDungeon",
    "Unknown dungeon IDs must be rejected."
)
check(
    Rules.resolve({
        DungeonId = "TestDungeon",
        DifficultyId = "Unknown",
    }).reason == "UnknownDifficulty",
    "Unknown difficulty IDs must be rejected."
)

print(string.format(
    "[Dungeon Entry Selection Rules Tests] PASS: %d assertions.",
    assertion_count
))
