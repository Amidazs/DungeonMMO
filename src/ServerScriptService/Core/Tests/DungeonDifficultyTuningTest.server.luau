--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Services")
local module = Services:FindFirstChild("DungeonDifficultyTuning")
if not module then
    error(
        "[Dungeon Difficulty Tuning Tests] RED: "
            .. "DungeonDifficultyTuning is missing."
    )
end

local Tuning = require(module)
local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error("[Dungeon Difficulty Tuning Tests] " .. message, 2)
    end
end

local depth1 = assert(Tuning.resolve("TestDungeon", "Depth1", nil))
check(depth1.EnemyHealthMultiplier == 1, "Depth1 HP must be neutral.")
check(depth1.EnemyDamageMultiplier == 1, "Depth1 damage must be neutral.")

local fortified = assert(Tuning.resolve(
    "TestDungeon",
    "Depth4",
    "Fortified"
))
check(
    math.abs(fortified.EnemyHealthMultiplier - 2.28) < 0.0001,
    "Depth4 HP and Fortified HP must compose multiplicatively."
)
check(
    fortified.EnemyDamageMultiplier == 1.35,
    "Depth4 outgoing damage multiplier mismatch."
)

local monster = Tuning.scale_monster_reward(
    {XP = 10, GoldMin = 3, GoldMax = 6, BestiaryCreatureId = "marauder"},
    fortified
)
check(monster.XP == 15, "Depth4 monster XP must scale to 15.")
check(monster.GoldMin == 5, "Depth4 minimum Gold must round to 5.")
check(monster.GoldMax == 9, "Depth4 maximum Gold must scale to 9.")
check(
    monster.BestiaryCreatureId == "marauder",
    "Reward identity metadata must survive scaling."
)

local completion = Tuning.scale_completion_reward(
    {Gold = 50, LootTable = {{Weight = 1, ItemId = "x"}}},
    fortified
)
check(
    completion.Gold == 88,
    "Depth4 completion Gold must round 87.5 to 88."
)
check(
    completion.LootTable[1].ItemId == "x",
    "Completion loot identity must survive scaling."
)

print(string.format(
    "[Dungeon Difficulty Tuning Tests] PASS: %d assertions.",
    assertion_count
))
