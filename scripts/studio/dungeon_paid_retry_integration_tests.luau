--!strict
-- Unpublished proof of the real server paid-revive and retry services.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Paid revive integration test requires unpublished Studio")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Dungeon.Tests:WaitForChild(
    "DungeonPaidReviveIntegrationTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_DungeonPaidRetryIntegration"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[Dungeon Paid Retry Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[Dungeon Paid Retry Focus] RESULT passed=1 total=1 failed=0")
