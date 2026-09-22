--!strict
-- Strict all-supported-classes C4 coverage in an unpublished Studio Base.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 completion audit requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4CatalogueCoverageTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4CatalogueCoverage"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Catalogue Coverage Focus] FAIL " .. tostring(reason))
    error(reason)
end
print(
    "[C4 Catalogue Coverage Focus] RESULT passed=1 total=1 failed=0"
)
