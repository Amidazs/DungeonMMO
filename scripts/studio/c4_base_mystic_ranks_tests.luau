--!strict
-- Source-bracket base Mage rank tests in unpublished Studio Base.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 Mystic tests require an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4BaseMysticRanksTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4BaseMysticRanks"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Base Mystic Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Base Mystic Focus] RESULT passed=1 total=1 failed=0")
