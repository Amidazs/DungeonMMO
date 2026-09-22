--!strict
-- Purchased C4 Fighter/Scout stamina recovery in unpublished Studio.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 recovery tests require an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4ConditionalRecoveryTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4ConditionalRecovery"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Conditional Recovery Focus] FAIL " .. tostring(reason))
    error(reason)
end
print(
    "[C4 Conditional Recovery Focus] "
        .. "RESULT passed=1 total=1 failed=0"
)
