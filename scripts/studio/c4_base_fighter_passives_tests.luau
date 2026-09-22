--!strict
-- Focused C4 early Fighter passive and equipment acceptance in Studio.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Fighter mastery tests require an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4BaseFighterPassivesTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4BaseFighterPassives"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Base Fighter Passives Focus] FAIL " .. tostring(reason))
    error(reason)
end
print(
    "[C4 Base Fighter Passives Focus] "
        .. "RESULT passed=1 total=1 failed=0"
)
