--!strict
-- Exact C4 Rogue/Scout first-transfer source-vs-game inventory focus.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Source inventory test requires an unpublished Studio place")

local server = game:GetService("ServerScriptService")
local fixture = server.Core.Tests:WaitForChild("C4ScoutInventoryTest")
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4ScoutInventory"
runner.Source = fixture.Source .. "\nreturn true\n"
runner.Parent = server

local ok, reason = pcall(require, runner)
runner:Destroy()
if not ok then
    warn("[C4 Scout Inventory Focus] FAIL " .. tostring(reason))
    error(reason)
end
print("[C4 Scout Inventory Focus] RESULT passed=1 total=1 failed=0")
