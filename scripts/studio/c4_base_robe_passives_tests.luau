--!strict
-- Isolated real Mystic level-one robe effects in unpublished Studio.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Robe passive tests require an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4BaseRobePassivesTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4BaseRobePassives"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Base Robe Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Base Robe Focus] RESULT passed=1 total=1 failed=0")
