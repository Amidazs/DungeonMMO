--!strict
-- Isolated first-transfer skill ranks; no published player state.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 first-transfer test requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild("C4FirstTransferRanksTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4FirstTransfer"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 First Transfer Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 First Transfer Focus] RESULT passed=1 total=1 failed=0")
