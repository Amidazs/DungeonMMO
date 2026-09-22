--!strict
-- Verify source-ranked Scout active buffs in an unpublished Studio Base.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 active Scout status tests require an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4ScoutActiveStatusTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4ScoutActiveStatus"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Scout Active Status Focus] FAIL " .. tostring(reason))
    error(reason)
end
print(
    "[C4 Scout Active Status Focus] "
        .. "RESULT passed=1 total=1 failed=0"
)
