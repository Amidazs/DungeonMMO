--!strict
-- Actual C4 first-tier healing purchases in isolated unpublished Studio.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 Mystic trainer tests require an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4BaseHealingTrainingTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4BaseHealingTraining"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Mystic Training Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Mystic Training Focus] RESULT passed=1 total=1 failed=0")
