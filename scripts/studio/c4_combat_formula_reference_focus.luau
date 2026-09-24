--!strict
-- Pure source formula runner; no live character or combat state is changed.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 combat formula test requires a disposable unpublished Base")

local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4CombatFormulaReferenceTest"
))
local module = Instance.new("ModuleScript")
module.Name = "TEMP_C4CombatFormulaReference"
module.Source = source.Source .. "\nreturn true\n"
module.Parent = tests
local ok, result = pcall(require, module)
module:Destroy()
assert(ok and result == true,
    "C4 combat formula reference failed: " .. tostring(result))
print("[C4 Combat Formula] VERIFIED_SOURCE_FORMULAS_NOT_LIVE")
