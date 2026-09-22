--!strict
-- Focused C4 human/elf scout critical trainer and reload contract.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Critical training tests require an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4ScoutCriticalTrainingTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4ScoutCriticalTraining"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Scout Critical Training Focus] FAIL " .. tostring(reason))
    error(reason)
end
print(
    "[C4 Scout Critical Training Focus] "
        .. "RESULT passed=1 total=1 failed=0"
)
