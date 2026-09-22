--!strict
-- Verify nine authentic Mage mastery ranks in a disposable Base place.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Mystic mastery tests require an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4BaseMysticPassivesTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4BaseMysticPassives"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Base Mystic Passives Focus] FAIL " .. tostring(reason))
    error(reason)
end
print(
    "[C4 Base Mystic Passives Focus] "
        .. "RESULT passed=1 total=1 failed=0"
)
