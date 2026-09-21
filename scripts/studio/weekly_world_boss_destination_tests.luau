--!strict
-- Isolated world-boss place inspection. No runtime opt-in or published
-- teleport is necessary to verify dedicated composition and factory.
assert(game.PlaceId == 0 and game.GameId == 0,
    "World boss composition test requires unpublished Studio")

local SSS = game:GetService("ServerScriptService")
local Tags = game:GetService("CollectionService")

local checks = 0

-- Args:
--   value: boolean; required dedicated-world-boss composition property.
--   message: string; useful explanation of a failure.
-- Returns:
--   nil: records a passing check or raises.
local function check(value: boolean, message: string)
    checks += 1
    assert(value, "[World Boss Destination] " .. message)
end

check(SSS:FindFirstChild("WorldBoss") ~= nil
    and SSS.WorldBoss:FindFirstChild("WorldBossRuntime") ~= nil,
    "dedicated destination must have its own separate server runtime")
check(SSS:FindFirstChild("Base") == nil
    and SSS.Dungeon:FindFirstChild("DungeonRuntime") == nil,
    "normal Base/Dungeon runtime must not run in the boss place")
check(SSS:GetAttribute("DungeonMMOWorldBossPlaceEnabled") ~= true,
    "new world-boss place must ship disabled by default")

local factory = require(
    SSS.Dungeon:WaitForChild("DungeonWeeklyWorldBossFactory"))
local holder = Instance.new("Folder")
holder.Name = "WorldBossDestinationTest_TEMP"
holder.Parent = workspace

local boss = factory.create({
    Parent = holder,
    InstanceId = "DedicatedBossDestination_TEMP",
    SpawnCFrame = CFrame.new(0, 12, 0),
})
local humanoid = assert(boss:FindFirstChildOfClass("Humanoid"))
check(humanoid.Health > 0
    and boss:GetAttribute("WorldBossId") == "AncientGuardian"
    and Tags:HasTag(boss, "DungeonMMOWeeklyWorldBoss"),
    "isolated dedicated place can construct its authoritative boss")
check(boss:GetAttribute("DungeonRewardGoldMin") == 0
    and boss:GetAttribute("DungeonRewardGoldMax") == 0,
    "ordinary combat rewards cannot bypass weekly lockout")
holder:Destroy()

local Arena = require(
    SSS.WorldBoss:WaitForChild("WorldBossArenaLayout")
)
local spawn = Arena.create(workspace, "WorldBossArenaTest_TEMP")
local layout = assert(spawn.Parent)
check(spawn.Name == "WorldBossArenaSpawn"
    and spawn:IsA("BasePart") and spawn.Anchored
    and spawn.CanCollide == false,
    "opt-in prototype arena provides one safe physical entry anchor")
local walls = {"NorthWall", "SouthWall", "EastWall", "WestWall"}
for _, name in ipairs(walls) do
    local wall = assert(layout:FindFirstChild(name))
    check(wall:IsA("BasePart") and wall.CanCollide
        and wall.Anchored and wall.Size.Y >= 20,
        "prototype arena must include a full-height solid " .. name)
end
check(layout:FindFirstChild("Floor") ~= nil,
    "prototype arena needs an anchored floor beneath entry and boss")
local duplicate = pcall(function()
    Arena.create(workspace, "WorldBossArenaTest_TEMP")
end)
check(not duplicate, "creating the same prototype twice must fail")
layout:Destroy()

print(string.format(
    "[World Boss Destination] PASS: %d assertions.", checks))
