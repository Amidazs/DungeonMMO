--!strict
-- Focused three-rank Elven Fighter self-heal in disposable Base Studio.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Elven recovery test requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4ElvenFighterHealTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4ElvenFighterHeal"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Elven Fighter Heal Focus] FAIL " .. tostring(reason))
    error(reason)
end
print(
    "[C4 Elven Fighter Heal Focus] "
        .. "RESULT passed=1 total=1 failed=0"
)
