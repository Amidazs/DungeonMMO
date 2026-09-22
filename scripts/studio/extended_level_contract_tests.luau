--!strict
-- One focused test for the new reachable post-20 skill level bracket.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Extended-level contract requires an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild(
    "Phase2BProgressionServiceTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_ExtendedLevelContract"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[Extended Level Focus] FAIL " .. tostring(reason))
    error(reason)
end

print("[Extended Level Focus] RESULT passed=1 total=1 failed=0")
