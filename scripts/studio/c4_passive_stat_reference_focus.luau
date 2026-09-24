--!strict
-- Source-only C4 passive stat arithmetic in unpublished Base Studio.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 passive reference requires a disposable unpublished Base place")
local tests = game:GetService("ServerScriptService").Core.Tests
local source = assert(tests:FindFirstChild("C4PassiveStatReferenceTest"))
local temporary = Instance.new("ModuleScript")
temporary.Name = "TEMP_C4PassiveStatReference"
temporary.Source = source.Source .. "\nreturn true\n"
temporary.Parent = tests
local ok, result = pcall(require, temporary)
temporary:Destroy()
assert(ok and result == true,
    "C4 passive source arithmetic failed: " .. tostring(result))
print("[C4 Passive Reference] VERIFIED_SOURCE_ONLY_NOT_LIVE")
