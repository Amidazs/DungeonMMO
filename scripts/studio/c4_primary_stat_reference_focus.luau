--!strict
-- Isolated unpublished source test; never migrates the player's profile.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 stat source inspection requires a disposable local place")

local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4PrimaryStatReferenceTest"
))
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_C4PrimaryStatReference"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = tests

local ok, result = pcall(require, runner)
runner:Destroy()
assert(ok and result == true,
    "C4 primary stat source regression failed: " .. tostring(result))
print("[C4 Primary Stats] VERIFIED_EXACT_SOURCE_NOT_LIVE_MIGRATION")
