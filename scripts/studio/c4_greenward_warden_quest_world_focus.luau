--!strict
-- Disposable unpublished Dungeon source-quest monster world contract.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Warden quest world test requires an unpublished Dungeon place")
local source = assert(game:GetService("ServerScriptService")
    .Dungeon.Tests:FindFirstChild("C4GreenwardWardenQuestWorldTest"))
local runner = Instance.new("ModuleScript")
runner.Name = "TEMP_WardenQuestWorldTest"
runner.Source = source.Source .. "\nreturn true\n"
runner.Parent = source.Parent
local ok, result = pcall(require, runner)
runner:Destroy()
assert(ok and result == true,
    "Warden physical quest world test failed: " .. tostring(result))
print("[Greenward Warden World] VERIFIED_FOCUS_PASS")
