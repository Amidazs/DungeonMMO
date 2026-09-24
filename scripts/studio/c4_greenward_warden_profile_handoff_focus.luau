--!strict
-- Disposable Base profile store test; not an actual Roblox teleport.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Warden handoff requires a local unpublished Base place")
local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4GreenwardWardenProfileHandoffTest"
))
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_WardenHandoffProfile"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = tests
local ok, result = pcall(require, runner)
runner:Destroy()
assert(ok and result == true,
    "Warden isolated profile handoff failed: " .. tostring(result))
print("[Warden Handoff] VERIFIED_FOCUS_PASS")
