--!strict
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local temple_module = Dungeon:FindFirstChild(
    "TempleDepth4BossFactory"
)
if not temple_module then
    error(
        "[Dungeon Depth4 Boss Factory Tests] RED: "
            .. "TempleDepth4BossFactory is missing."
    )
end

local mine_module = Dungeon:FindFirstChild(
    "AbandonedMineDepth4BossFactory"
)
if not mine_module then
    error(
        "[Dungeon Depth4 Boss Factory Tests] RED: "
            .. "AbandonedMineDepth4BossFactory is missing."
    )
end

local TempleDepth4BossFactory = require(temple_module)
local AbandonedMineDepth4BossFactory = require(mine_module)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Depth4 Boss Factory Tests] "
                .. message,
            2
        )
    end
end

local parent = Instance.new("Folder")
parent.Name = "Depth4BossFactoryTest"

local function create_options(): any
    return {
        Parent = parent,
        SpawnCFrame = CFrame.new(0, 5, 0),
        EncounterId = "Depth4FinalBossFactoryTest",
        RewardXP = 75,
        RewardGoldMin = 15,
        RewardGoldMax = 30,
        BestiaryCreatureId = "marauder_captain",
        HealthMultiplier = 2.0,
        DamageMultiplier = 1.35,
        BossRole = "FinalBoss",
    }
end

local temple = TempleDepth4BossFactory.create(
    create_options()
)
check(
    temple:GetAttribute("BossId") == "TempleDepth4Boss",
    "Temple Depth4 BossId mismatch."
)
check(
    temple.Name == "TempleDepth4Boss",
    "Temple Depth4 model name mismatch."
)
check(
    temple:GetAttribute("BossRole") == "FinalBoss",
    "Temple final-boss role must be preserved."
)
local temple_humanoid = temple:FindFirstChildOfClass("Humanoid")
check(
    temple_humanoid ~= nil
        and temple_humanoid.DisplayName == "Sanctum Ascendant",
    "Temple Depth4 display identity mismatch."
)
check(
    CollectionService:HasTag(
        temple,
        "DungeonMarauderCaptain"
    ),
    "Temple Depth4 boss must retain Captain controller tag."
)

local mine = AbandonedMineDepth4BossFactory.create(
    create_options()
)
check(
    mine:GetAttribute("BossId")
        == "AbandonedMineDepth4Boss",
    "Mine Depth4 BossId mismatch."
)
check(
    mine.Name == "AbandonedMineDepth4Boss",
    "Mine Depth4 model name mismatch."
)
check(
    mine:GetAttribute("BossRole") == "FinalBoss",
    "Mine final-boss role must be preserved."
)
local mine_humanoid = mine:FindFirstChildOfClass("Humanoid")
check(
    mine_humanoid ~= nil
        and mine_humanoid.DisplayName == "Buried Tyrant",
    "Mine Depth4 display identity mismatch."
)
check(
    CollectionService:HasTag(
        mine,
        "DungeonMarauderCaptain"
    ),
    "Mine Depth4 boss must retain Captain controller tag."
)

parent:Destroy()

print(string.format(
    "[Dungeon Depth4 Boss Factory Tests] PASS: %d assertions.",
    assertion_count
))
