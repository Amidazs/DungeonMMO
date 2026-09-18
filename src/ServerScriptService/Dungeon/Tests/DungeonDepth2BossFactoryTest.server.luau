--!strict
local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local temple_module = Dungeon:FindFirstChild(
    "TempleDepth2BossFactory"
)
if not temple_module then
    error(
        "[Dungeon Depth2 Boss Factory Tests] RED: "
            .. "TempleDepth2BossFactory is missing."
    )
end

local mine_module = Dungeon:FindFirstChild(
    "AbandonedMineDepth2BossFactory"
)
if not mine_module then
    error(
        "[Dungeon Depth2 Boss Factory Tests] RED: "
            .. "AbandonedMineDepth2BossFactory is missing."
    )
end

local TempleDepth2BossFactory = require(temple_module)
local AbandonedMineDepth2BossFactory = require(mine_module)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Depth2 Boss Factory Tests] "
                .. message,
            2
        )
    end
end

local parent = Instance.new("Folder")
parent.Name = "Depth2BossFactoryTest"

local function create_options(): any
    return {
        Parent = parent,
        SpawnCFrame = CFrame.new(0, 5, 0),
        EncounterId = "Depth2BossFactoryTest",
        RewardXP = 50,
        RewardGoldMin = 10,
        RewardGoldMax = 20,
        BestiaryCreatureId = "marauder_captain",
        HealthMultiplier = 1.25,
        DamageMultiplier = 1.10,
        BossRole = "Boss",
    }
end

local temple = TempleDepth2BossFactory.create(
    create_options()
)
check(
    temple:GetAttribute("BossId") == "TempleDepth2Boss",
    "Temple Depth2 BossId mismatch."
)
check(
    temple.Name == "TempleDepth2Boss",
    "Temple Depth2 model name mismatch."
)
local temple_humanoid = temple:FindFirstChildOfClass("Humanoid")
check(
    temple_humanoid ~= nil
        and temple_humanoid.DisplayName == "Temple Warden",
    "Temple Depth2 display identity mismatch."
)
check(
    CollectionService:HasTag(
        temple,
        "DungeonMarauderCaptain"
    ),
    "Temple Depth2 boss must retain Captain controller tag."
)

local mine = AbandonedMineDepth2BossFactory.create(
    create_options()
)
check(
    mine:GetAttribute("BossId")
        == "AbandonedMineDepth2Boss",
    "Mine Depth2 BossId mismatch."
)
check(
    mine.Name == "AbandonedMineDepth2Boss",
    "Mine Depth2 model name mismatch."
)
local mine_humanoid = mine:FindFirstChildOfClass("Humanoid")
check(
    mine_humanoid ~= nil
        and mine_humanoid.DisplayName == "Deep Overseer",
    "Mine Depth2 display identity mismatch."
)
check(
    CollectionService:HasTag(
        mine,
        "DungeonMarauderCaptain"
    ),
    "Mine Depth2 boss must retain Captain controller tag."
)

parent:Destroy()

print(string.format(
    "[Dungeon Depth2 Boss Factory Tests] PASS: %d assertions.",
    assertion_count
))
