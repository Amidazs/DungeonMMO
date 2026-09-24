--!strict
-- Source-test runner for a disposable, unpublished Base Studio place.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Greenward Warden foundation tests require an unpublished Base")
local SSS = game:GetService("ServerScriptService")
local tests = SSS.Core.Tests
local source = assert(tests:FindFirstChild(
    "C4GreenwardWardenFoundationTest"
))
local fixture = Instance.new("ModuleScript")
fixture.Name = "TEMP_GreenwardWardenFoundation"
fixture.Source = source.Source .. "\nreturn true\n"
fixture.Parent = tests
local ok, result = pcall(require, fixture)
fixture:Destroy()
assert(ok and result == true,
    "Greenward Warden foundation test failed: " .. tostring(result))
print("[Greenward Warden Foundation] VERIFIED_FOCUS_PASS")
