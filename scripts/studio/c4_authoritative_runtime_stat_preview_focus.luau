--!strict
-- Unpublished Base-only server-owned source stat preview regression.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 runtime stat preview must run in unpublished local Base")
local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4AuthoritativeRuntimeStatPreviewTest"
))
local module = Instance.new("ModuleScript")
module.Name = "TEMP_C4RuntimeStatPreview"
module.Source = source.Source .. "\nreturn true\n"
module.Parent = tests
local ok, result = pcall(require, module)
module:Destroy()
assert(ok and result == true,
    "C4 authoritative stat preview failed: " .. tostring(result))
print("[C4 Runtime Stat Preview] VERIFIED_SOURCE_ONLY_NOT_LIVE")
