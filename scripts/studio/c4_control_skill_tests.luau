--!strict
-- Run the new control-skill gates in disposable unpublished Studio only.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Control-skill tests require an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild("C4ControlSkillsTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4ControlSkill"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Control Skill Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Control Skill Focus] RESULT passed=1 total=1 failed=0")
