--!strict
-- Unpublished original Knight early rank and forged-class test fixture.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Original Knight focused test requires an unpublished Base place")
local tests = game:GetService("ServerScriptService").Core.Tests

--[[
Runs the real source-controlled Knight foundation fixture exactly once.

Args:
    None.

Returns:
    nil: Verifies the test executed and reported no unsupported class award.
]]
local function main()
    local source = assert(tests:FindFirstChild(
        "C4OathguardFoundationTest"
    ), "Source-controlled Oathguard foundation fixture missing")
    assert(source:IsA("LuaSourceContainer"),
        "Knight foundation fixture must contain executable source")
    local module = Instance.new("ModuleScript")
    module.Name = "OathguardFoundation_TEMP"
    module.Source = source.Source .. "\nreturn true\n"
    module.Parent = tests
    local ok, result = pcall(require, module)
    module:Destroy()
    assert(ok and result == true,
        "Oathguard foundation test failed: " .. tostring(result))
    print("[Oathguard Foundation] VERIFIED_RANK_GATES_PASS")
end

main()
