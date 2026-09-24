--!strict
-- Disposable unpublished Base reference test; no player stat migration.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 unified stat focus requires an unpublished local Base place")
local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4UnifiedStatReferenceTest"
))
local module = Instance.new("ModuleScript")
module.Name = "TEMP_C4UnifiedStatReferenceFocus"
module.Source = source.Source .. "\nreturn true\n"
module.Parent = tests
local ok, value = pcall(require, module)
module:Destroy()
assert(ok and value == true,
    "C4 unified source reference failed: " .. tostring(value))
print("[C4 Unified Stats] VERIFIED_SOURCE_ONLY_NOT_LIVE")
