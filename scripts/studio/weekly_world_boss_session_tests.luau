--!strict
-- Dedicated unpublished Edit-mode acceptance of weekly event durability.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Weekly boss session tests require an unpublished local Studio place")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild(
    "WeeklyWorldBossSessionBridgeTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_WeeklyWorldBossSessionBridgeTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[World Boss Session Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[World Boss Session Focus] RESULT passed=1 total=1 failed=0")
