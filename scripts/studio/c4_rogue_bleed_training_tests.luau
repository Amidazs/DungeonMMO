--!strict
-- Isolated trainer/reload test for the new Rogue bleed skill.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Bleed trainer focus requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4RogueBleedTrainingTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4BleedTraining"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Bleed Training Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Bleed Training Focus] RESULT passed=1 total=1 failed=0")
