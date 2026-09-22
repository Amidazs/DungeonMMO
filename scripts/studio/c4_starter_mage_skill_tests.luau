--!strict
-- Run only the new Mage starter and level/proficiency training contract.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Mage progression test requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local source = server.Core.Tests:WaitForChild(
    "C4StarterMageSkillTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4StarterMageSkill"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Starter Mage Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Starter Mage Focus] RESULT passed=1 total=1 failed=0")
