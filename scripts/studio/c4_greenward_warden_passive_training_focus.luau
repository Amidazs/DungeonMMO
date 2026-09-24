--!strict
-- Executes the actual isolated Elven Knight passive/quest award test.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Greenward Warden passive tests require an unpublished Base")
local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4GreenwardWardenPassiveTrainingTest"
))
local fixture = Instance.new("ModuleScript")
fixture.Name = "TEMP_GreenwardWardenPassiveTraining"
fixture.Source = source.Source .. "\nreturn true\n"
fixture.Parent = tests
local ok, result = pcall(require, fixture)
fixture:Destroy()
assert(ok and result == true,
    "Greenward Warden passive tests failed: " .. tostring(result))
print("[Greenward Warden Passives] VERIFIED_FOCUS_PASS")
