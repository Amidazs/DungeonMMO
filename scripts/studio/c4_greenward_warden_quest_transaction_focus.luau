--!strict
-- Runs the isolated full Greenward Warden quest transaction test.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Greenward Warden quest test requires an unpublished Base")
local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4GreenwardWardenQuestTransactionTest"
))
local fixture = Instance.new("ModuleScript")
fixture.Name = "TEMP_GreenwardWardenQuestTransaction"
fixture.Source = source.Source .. "\nreturn true\n"
fixture.Parent = tests
local ok, result = pcall(require, fixture)
fixture:Destroy()
assert(ok and result == true,
    "Greenward Warden quest transaction failed: " .. tostring(result))
print("[Greenward Warden Quest] VERIFIED_TRANSACTION_PASS")
