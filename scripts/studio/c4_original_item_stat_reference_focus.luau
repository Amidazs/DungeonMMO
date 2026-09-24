--!strict
-- Disposable Base-only item stat reference; no live player equipment.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 original item focus requires unpublished local Base")
local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4OriginalItemStatReferenceTest"
))
local module = Instance.new("ModuleScript")
module.Name = "TEMP_C4OriginalItemStatReference"
module.Source = source.Source .. "\nreturn true\n"
module.Parent = tests
local ok, result = pcall(require, module)
module:Destroy()
assert(ok and result == true,
    "C4 original gear reference failed: " .. tostring(result))
print("[C4 Original Item Stats] VERIFIED_SOURCE_ONLY_NOT_LIVE")
