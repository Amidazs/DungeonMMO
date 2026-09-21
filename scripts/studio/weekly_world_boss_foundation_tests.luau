--!strict
-- Disposable local Studio-only weekly world-boss policy verification.
assert(game.PlaceId == 0 and game.GameId == 0,
    "World-boss tests require an unpublished local Studio place")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild("WeeklyWorldBossServiceTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_WeeklyWorldBossServiceTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[World Boss Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[World Boss Focus] RESULT passed=1 total=1 failed=0")
