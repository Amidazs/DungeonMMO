--!strict
-- Run only new C4 Mage training content in an unpublished Base place.
assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Mage rank tests require an unpublished Studio place"
)

local server = game:GetService("ServerScriptService")
local source = server.Core.Tests:WaitForChild(
    "C4EarlyMageRanksTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4EarlyMageRanks"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Early Mage Focus] FAIL " .. tostring(reason))
    error(reason)
end

print("[C4 Early Mage Focus] RESULT passed=1 total=1 failed=0")
