--!strict
-- Disposable unpublished Dungeon factory-rig contract regression.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Marauder rig focus must run only in a local unpublished place")
local tests = game:GetService("ServerScriptService").Combat.Tests
local source = assert(tests:FindFirstChild("MarauderRigContractTest"))
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_MarauderRigContractFocus"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = tests
local ok, result = pcall(require, runner)
runner:Destroy()
assert(ok and result == true,
    "Marauder factory rig contract failed: " .. tostring(result))
print("[Marauder Rig Contract] VERIFIED_FOCUS_PASS")
