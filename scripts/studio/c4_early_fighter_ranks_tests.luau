--!strict
-- Focused C4 Fighter content test in one unpublished Base composition.
assert(
    game.PlaceId == 0 and game.GameId == 0,
    "C4 rank test requires an unpublished Studio place"
)

local server = game:GetService("ServerScriptService")
local source = server.Core.Tests:WaitForChild(
    "C4EarlyFighterRanksTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4EarlyFighterRanks"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Early Fighter Focus] FAIL " .. tostring(reason))
    error(reason)
end

print("[C4 Early Fighter Focus] RESULT passed=1 total=1 failed=0")
