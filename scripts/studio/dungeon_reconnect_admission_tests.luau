--!strict
-- Run the reconnect admission + lease contract in unpublished Studio.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Reconnect contract requires an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Dungeon.Tests:WaitForChild(
    "DungeonReconnectAdmissionTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_DungeonReconnectAdmission"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[Dungeon Reconnect Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[Dungeon Reconnect Focus] RESULT passed=1 total=1 failed=0")
