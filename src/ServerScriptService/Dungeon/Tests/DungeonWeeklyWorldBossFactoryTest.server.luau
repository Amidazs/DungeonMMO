--!strict
-- Verify the prototype uses an existing combat boss, but has its own
-- server-issued instance identity and no ordinary encounter reward.
local CollectionService = game:GetService("CollectionService")
local SSS = game:GetService("ServerScriptService")

local Factory = require(
    SSS.Dungeon:WaitForChild("DungeonWeeklyWorldBossFactory")
)

local assertions = 0

-- Args:
--   condition: boolean; expected guardian-factory property.
--   message: string; actionable failed requirement.
-- Returns:
--   nil: records the assertion or raises an error.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[Weekly Boss Factory] " .. message)
end

local holder = Instance.new("Folder")
holder.Name = "WeeklyBossFactoryTest_TEMP"
holder.Parent = workspace

local invalid, reason = pcall(function()
    Factory.create({
        Parent = holder,
        SpawnCFrame = CFrame.new(0, 20, 0),
    })
end)
check(not invalid and tostring(reason):find("authorized server"),
    "factory must reject an absent server-issued instance ID")

local boss = Factory.create({
    Parent = holder,
    SpawnCFrame = CFrame.new(0, 20, 0),
    InstanceId = "WeeklyBossTestInstanceA",
})
local humanoid = assert(boss:FindFirstChildOfClass("Humanoid"))
check(humanoid.Health > 0 and humanoid.MaxHealth > 0,
    "the reused combat controller must spawn a living boss")
check(boss:GetAttribute("WorldBossId") == "AncientGuardian",
    "server factory must assign the registered weekly identity")
check(boss:GetAttribute("WorldBossInstanceId")
    == "WeeklyBossTestInstanceA",
    "boss identity must be bound to its specific instance")
check(CollectionService:HasTag(
    boss, "DungeonMMOWeeklyWorldBoss"),
    "only the server factory may enroll the actual guardian model")
check(boss:GetAttribute("DungeonBossRole") == "WorldBoss",
    "existing combat controller must retain its distinct boss role")
check(boss:GetAttribute("DungeonRewardGoldMin") == 0
    and boss:GetAttribute("DungeonRewardGoldMax") == 0
    and boss:GetAttribute("DungeonRewardXP") == 0,
    "ordinary combat rewards must not bypass the weekly reward gate")
check(boss:GetAttribute("BestiaryCreatureId") == nil,
    "prototype must not award unrelated existing boss bestiary entries")

holder:Destroy()
print(string.format(
    "[Weekly Boss Factory] PASS: %d assertions.", assertions))
