--!strict
-- First-tier three-rank Battle Heal in unpublished Roblox Studio.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 Battle Heal tests require an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4BaseBattleHealTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4BaseBattleHeal"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Battle Heal Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Battle Heal Focus] RESULT passed=1 total=1 failed=0")
