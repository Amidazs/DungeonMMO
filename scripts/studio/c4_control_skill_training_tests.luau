--!strict
-- Isolated class training test; no live player data or Roblox publication.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Control-skill training requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild("C4ControlSkillTrainingTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4ControlTraining"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Control Training Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Control Training Focus] RESULT passed=1 total=1 failed=0")
