--!strict
-- Focused specialisation skill test; does not re-run Dungeon regressions.
assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Advanced skills require an unpublished Studio place"
)

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild("AdvancedClassSkillTest")

local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_AdvancedClassSkillRunner"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()

if not ok then
    warn("[Advanced Class Skill Focus] FAIL " .. tostring(reason))
    error(reason)
end

print("[Advanced Class Skill Focus] RESULT passed=1 total=1 failed=0")
