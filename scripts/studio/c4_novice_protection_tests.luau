--!strict
-- Level-one novice mitigation and transfer expiry in an unpublished Base.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 novice test requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild(
    "C4NoviceProtectionTest"
)
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4NoviceProtection"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Novice Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Novice Focus] RESULT passed=1 total=1 failed=0")
