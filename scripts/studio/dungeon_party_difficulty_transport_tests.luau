--!strict
-- Unpublished verification of one authoritative dungeon entry contract.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Party difficulty tests require an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild("TeleportCoordinatorTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_TeleportCoordinatorTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[Party Difficulty Transport Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[Party Difficulty Transport Focus] RESULT passed=1 total=1 failed=0")
