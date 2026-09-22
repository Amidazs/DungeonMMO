--!strict
-- Isolated real SP/level/mastery purchase test for 30 first-transfer ranks.
assert(game.PlaceId == 0 and game.GameId == 0,
    "First-transfer training requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4FirstTransferTrainingTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4FirstTransferTraining"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 First Transfer Training Focus] FAIL " .. tostring(reason))
    error(reason)
end
print(
    "[C4 First Transfer Training Focus] "
        .. "RESULT passed=1 total=1 failed=0"
)
