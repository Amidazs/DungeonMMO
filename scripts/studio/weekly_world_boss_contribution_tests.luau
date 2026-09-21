--!strict
-- Unpublished Studio regression for server-persisted boss contribution.
assert(game.PlaceId == 0 and game.GameId == 0,
    "World boss contribution tests require unpublished Studio")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild(
    "WorldBossContributionRulesTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_WorldBossContributionRulesTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[World Boss Contribution Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[World Boss Contribution Focus] RESULT passed=1 total=1 failed=0")
