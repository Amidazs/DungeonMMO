--!strict
-- Focused, unpublished Studio check of the guardian target filter.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Boss damage filter needs an unpublished local Studio place")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Dungeon.Tests:WaitForChild("WorldBossDamageFilterTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_WorldBossDamageFilterTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[World Boss Damage Filter Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[World Boss Damage Filter Focus] RESULT passed=1 total=1 failed=0")
