--!strict
-- Local unpublished test for terminal dungeon wipe return authorization.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Failed dungeon return test requires unpublished Studio")

local SSS = game:GetService("ServerScriptService")
local source = SSS.Dungeon.Tests:WaitForChild(
    "ReturnPortalServiceTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_FailedDungeonReturnTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = SSS

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[Failed Dungeon Return Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[Failed Dungeon Return Focus] RESULT passed=1 total=1 failed=0")
