--!strict
-- Focused disposable Dungeon original Warrior physical enemy regression.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Oathguard quest world tests require unpublished Studio")
local tests = game:GetService("ServerScriptService").Dungeon.Tests

--[[
Executes the separate real Dungeon enemy/ledger source fixture.

Args:
    None.

Returns:
    nil: Asserts actual registered striker and single-boss contracts pass.
]]
local function main()
    local source = assert(tests:FindFirstChild(
        "C4OathguardQuestWorldTest"
    ), "Original Warrior Dungeon world fixture missing")
    assert(source:IsA("LuaSourceContainer"),
        "Original Warrior world fixture must contain executable source")
    local module = Instance.new("ModuleScript")
    module.Name = "OathguardWorldFocus_TEMP"
    module.Source = source.Source .. "\nreturn true\n"
    module.Parent = tests
    local ok, result = pcall(require, module)
    module:Destroy()
    assert(ok and result == true,
        "Oathguard world failed: " .. tostring(result))
    print("[Oathguard World] VERIFIED_RAIDER_AND_BOSS_PASS")
end

main()
