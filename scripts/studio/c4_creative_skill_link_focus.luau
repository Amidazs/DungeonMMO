--!strict
-- Full nine-original-class mapping test in an unpublished Base place.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 creative skill audit requires an unpublished disposable Base")
local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild(
    "C4CreativeSkillLinkAuditTest"
))
local temporary = Instance.new("ModuleScript")
temporary.Name = "TEMP_C4CreativeSkillLinkAudit"
temporary.Source = source.Source .. "\nreturn true\n"
temporary.Parent = tests
local ok, result = pcall(require, temporary)
temporary:Destroy()
assert(ok and result == true,
    "Nine-class creative C4 map audit failed: " .. tostring(result))
print("[C4 CREATIVE LINK] VERIFIED_SOURCE_MAPPING_PARITY_NOT_CERTIFIED")
