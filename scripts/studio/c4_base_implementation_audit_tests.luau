--!strict
-- All supported base-class source ranks versus real executable game ranks.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Base coverage audit requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4BaseImplementationAuditTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4BaseCoverage"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Base Coverage Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Base Coverage Focus] RESULT passed=1 total=1 failed=0")
