--!strict
-- Unpublished Studio retry contract using a failing in-memory adapter.
assert(game.PlaceId == 0 and game.GameId == 0,
    "World boss reward retry test requires unpublished Studio")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild(
    "WorldBossRewardRetryTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_WorldBossRewardRetryTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[World Boss Reward Retry Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[World Boss Reward Retry Focus] RESULT passed=1 total=1 failed=0")
