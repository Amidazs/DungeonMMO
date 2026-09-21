--!strict
-- Dedicated, unpublished Studio tests for the disabled-by-default
-- Dungeon guardian prototype and the shared weekly reward policy.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Weekly boss tests require an unpublished local place")

local SSS = game:GetService("ServerScriptService")

local function run_test(source: Script, name: string)
    local runner = Instance.new("ModuleScript")
    runner.Name = "TEMP_WeeklyBoss_" .. name
    runner.Source = source.Source .. "\nreturn true\n"
    runner.Parent = SSS
    local ok, reason = pcall(require, runner)
    runner:Destroy()
    if not ok then
        warn("[World Boss Dungeon Focus] FAIL " .. name .. ": "
            .. tostring(reason))
        error(reason)
    end
    print("[World Boss Dungeon Focus] PASS " .. name)
end

run_test(
    SSS.Core.Tests:WaitForChild("WeeklyWorldBossServiceTest"),
    "WeeklyWorldBossServiceTest"
)
run_test(
    SSS.Dungeon.Tests:WaitForChild("DungeonWeeklyWorldBossFactoryTest"),
    "DungeonWeeklyWorldBossFactoryTest"
)
print("[World Boss Dungeon Focus] RESULT passed=2 total=2 failed=0")
