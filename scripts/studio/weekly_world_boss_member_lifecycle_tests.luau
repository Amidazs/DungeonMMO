--!strict
-- Focused unpublished Studio runner for world-boss member death/recovery.
assert(game.PlaceId == 0 and game.GameId == 0,
    "World-boss lifecycle tests require unpublished Studio")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild(
    "WorldBossMemberLifecycleTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_WorldBossMemberLifecycleTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[World Boss Member Lifecycle Focus] FAIL "
        .. tostring(reason))
    error(reason)
end
print(
    "[World Boss Member Lifecycle Focus] RESULT passed=1 total=1 failed=0")
