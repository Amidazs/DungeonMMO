--!strict
-- Real Mage robe and novice production-trainer purchases in isolated Studio.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 base training requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4BaseStarterTrainingTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4BaseStarterTraining"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Base Training Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Base Training Focus] RESULT passed=1 total=1 failed=0")
