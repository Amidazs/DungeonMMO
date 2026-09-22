--!strict
-- Test actual saved Rogue starter equipment without editing local source.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Rogue dagger test requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "RogueProgressionServiceTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4RogueDagger"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Rogue Dagger Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Rogue Dagger Focus] RESULT passed=1 total=1 failed=0")
