--!strict
-- One focused passive rank test in an unpublished Base composition.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Passive rank tests require an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild("C4PassiveRankEffectsTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4PassiveRankEffects"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Passive Rank Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Passive Rank Focus] RESULT passed=1 total=1 failed=0")
