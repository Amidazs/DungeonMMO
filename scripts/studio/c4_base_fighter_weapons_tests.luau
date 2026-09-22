--!strict
-- Focused early Fighter bow/dagger tests in an unpublished Base place.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Fighter weapon tests require an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4BaseFighterWeaponsTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4BaseFighterWeapons"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Base Fighter Weapons Focus] FAIL " .. tostring(reason))
    error(reason)
end
print(
    "[C4 Base Fighter Weapons Focus] "
        .. "RESULT passed=1 total=1 failed=0"
)
