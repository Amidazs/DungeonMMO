--!strict
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local temple_module = Dungeon:FindFirstChild(
    "TempleDepth3BossFactory"
)
if not temple_module then
    error(
        "[Dungeon Depth3 Boss Factory Tests] RED: "
            .. "TempleDepth3BossFactory is missing."
    )
end

local mine_module = Dungeon:FindFirstChild(
    "AbandonedMineDepth3BossFactory"
)
if not mine_module then
    error(
        "[Dungeon Depth3 Boss Factory Tests] RED: "
            .. "AbandonedMineDepth3BossFactory is missing."
    )
end

local TempleDepth3BossFactory = require(temple_module)
local AbandonedMineDepth3BossFactory = require(mine_module)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Depth3 Boss Factory Tests] "
                .. message,
            2
        )
    end
end

local parent = Instance.new("Folder")
parent.Name = "Depth3BossFactoryTest"

local function create_options(): any
    return {
        Parent = parent,
        SpawnCFrame = CFrame.new(0, 5, 0),
        EncounterId = "Depth3BossFactoryTest",
        RewardXP = 60,
        RewardGoldMin = 12,
        RewardGoldMax = 24,
        BestiaryCreatureId = "marauder_captain",
        HealthMultiplier = 1.55,
        DamageMultiplier = 1.20,
        BossRole = "Boss",
    }
end

local temple = TempleDepth3BossFactory.create(
    create_options()
)
check(
    temple:GetAttribute("BossId") == "TempleDepth3Boss",
    "Temple Depth3 BossId mismatch."
)
check(
    temple.Name == "TempleDepth3Boss",
    "Temple Depth3 model name mismatch."
)
local temple_humanoid = temple:FindFirstChildOfClass("Humanoid")
check(
    temple_humanoid ~= nil
        and temple_humanoid.DisplayName == "Relic Guardian",
    "Temple Depth3 display identity mismatch."
)
check(
    CollectionService:HasTag(
        temple,
        "DungeonMarauderCaptain"
    ),
    "Temple Depth3 boss must retain Captain controller tag."
)

local mine = AbandonedMineDepth3BossFactory.create(
    create_options()
)
check(
    mine:GetAttribute("BossId")
        == "AbandonedMineDepth3Boss",
    "Mine Depth3 BossId mismatch."
)
check(
    mine.Name == "AbandonedMineDepth3Boss",
    "Mine Depth3 model name mismatch."
)
local mine_humanoid = mine:FindFirstChildOfClass("Humanoid")
check(
    mine_humanoid ~= nil
        and mine_humanoid.DisplayName == "Hollow Taskmaster",
    "Mine Depth3 display identity mismatch."
)
check(
    CollectionService:HasTag(
        mine,
        "DungeonMarauderCaptain"
    ),
    "Mine Depth3 boss must retain Captain controller tag."
)

parent:Destroy()

print(string.format(
    "[Dungeon Depth3 Boss Factory Tests] PASS: %d assertions.",
    assertion_count
))
