--!strict
-- Unpublished focused progression and advanced-skill visibility test.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Skill mastery test requires an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild("SkillMasteryGatesTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_SkillMasteryGatesRunner"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[Skill Mastery Focus] FAIL " .. tostring(reason))
    error(reason)
end

print("[Skill Mastery Focus] RESULT passed=1 total=1 failed=0")
