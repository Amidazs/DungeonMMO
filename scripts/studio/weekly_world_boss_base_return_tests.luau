--!strict
-- Studio-only real session return contract in the Base composition.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Weekly boss Base return requires an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Base.Tests:WaitForChild(
    "WeeklyWorldBossBaseReturnTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_WorldBossBaseReturnTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[World Boss Base Return Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[World Boss Base Return Focus] RESULT passed=1 total=1 failed=0")
