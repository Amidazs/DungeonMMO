--!strict
-- Unpublished Studio transport contract; fake reservation and teleport.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Weekly boss travel tests require an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild(
    "WeeklyWorldBossTravelTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_WeeklyBossTravelTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[World Boss Travel Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[World Boss Travel Focus] RESULT passed=1 total=1 failed=0")
