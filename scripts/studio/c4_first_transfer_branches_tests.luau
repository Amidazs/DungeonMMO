--!strict
-- Verify all source C4 first-transfer choices in an unpublished Base.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 first-transfer audit requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4FirstTransferBranchesTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4FirstTransferBranches"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 First Transfers Focus] FAIL " .. tostring(reason))
    error(reason)
end
print(
    "[C4 First Transfers Focus] RESULT passed=1 total=1 failed=0"
)
