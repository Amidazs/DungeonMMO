--!strict
-- Unpublished in-memory acceptance for fresh session identity after wipe.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Fresh retry contract requires unpublished Studio")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Core.Tests:WaitForChild("DungeonSessionServiceTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_DungeonFreshRetryTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[Fresh Dungeon Retry Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[Fresh Dungeon Retry Focus] RESULT passed=1 total=1 failed=0")
