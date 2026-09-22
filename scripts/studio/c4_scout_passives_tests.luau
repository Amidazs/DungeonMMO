--!strict
-- Focused first-transfer mastery contract in an unpublished Base build.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Scout passive tests require an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild("C4ScoutPassivesTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4ScoutPassives"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Scout Passives Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Scout Passives Focus] RESULT passed=1 total=1 failed=0")
