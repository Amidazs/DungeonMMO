--!strict
-- Source learning-tree audit only; no trainer or profile mutation.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 skill-tree source test requires a disposable unpublished Base")

local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4Level30SkillTreeSourceTest"
))
local module = Instance.new("ModuleScript")
module.Name = "TEMP_C4Level30SkillTreeSource"
module.Source = source.Source .. "\nreturn true\n"
module.Parent = tests
local ok, result = pcall(require, module)
module:Destroy()
assert(ok and result == true,
    "C4 level-30 skill tree source failed: " .. tostring(result))
print("[C4 Skill Tree] VERIFIED_ALL_NINE_SOURCE_ROWS_NOT_LIVE")
