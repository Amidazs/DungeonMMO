--!strict
-- Verify exact C4 source family counts in an unpublished base build.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Source audit requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4BaseSourceInventoryTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4BaseSource"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Base Source Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Base Source Focus] RESULT passed=1 total=1 failed=0")
