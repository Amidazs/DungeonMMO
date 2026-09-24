--!strict
-- Focused source-formula runner; no live stat or profile mutation.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 derived stat test requires a disposable unpublished Base")

local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4DerivedStatReferenceTest"
))
local module = Instance.new("ModuleScript")
module.Name = "TEMP_C4DerivedStatReference"
module.Source = source.Source .. "\nreturn true\n"
module.Parent = tests
local ok, result = pcall(require, module)
module:Destroy()
assert(ok and result == true,
    "C4 derived stat reference failed: " .. tostring(result))
print("[C4 Derived Stats] VERIFIED_SOURCE_FORMULAS_NOT_LIVE")
