--!strict
-- Disposable Base read-only authenticated original C4 skill tree.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 skill preview must run only in unpublished local Base")
local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4NineClassAuthenticatedSkillPreviewTest"
))
local module = Instance.new("ModuleScript")
module.Name = "TEMP_C4NineClassSkillPreview"
module.Source = source.Source .. "\nreturn true\n"
module.Parent = tests
local ok, result = pcall(require, module)
module:Destroy()
assert(ok and result == true,
    "Nine-class original C4 skill tree preview failed: "
        .. tostring(result))
print("[C4 Nine-Class Skills] VERIFIED_SOURCE_ONLY_NOT_LIVE")
