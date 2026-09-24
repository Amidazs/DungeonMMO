--!strict
-- Whole-source effect audit only; never updates live combat definitions.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 effect source test requires a disposable unpublished Base")

local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4SkillEffectSourceTest"
))
local module = Instance.new("ModuleScript")
module.Name = "TEMP_C4SkillEffectSource"
module.Source = source.Source .. "\nreturn true\n"
module.Parent = tests
local ok, result = pcall(require, module)
module:Destroy()
assert(ok and result == true,
    "C4 source skill effect catalogue failed: " .. tostring(result))
print("[C4 Skill Effects] VERIFIED_ALL_NINE_EFFECT_SOURCE_NOT_LIVE")
