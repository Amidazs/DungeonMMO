--!strict
-- Unpublished Dungeon fixture: real source-monster model registration.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Original quest combat ledger requires an unpublished local place")

local tests = game:GetService("ServerScriptService").Dungeon.Tests

--[[
Executes the source-controlled Dungeon server registration fixture.

Args:
    None.

Returns:
    nil: Raises if any physical monster registration check fails.
]]
local function main()
    local source = assert(tests:FindFirstChild(
        "C4QuestMonsterCombatLedgerTest"
    ), "Original quest monster registration fixture is missing")
    assert(source:IsA("LuaSourceContainer"))
    local test_module = Instance.new("ModuleScript")
    test_module.Name = "TEMP_C4QuestMonsterCombatLedgerTest"
    test_module.Source = source.Source .. "\nreturn true\n"
    test_module.Parent = tests
    local ok, outcome = pcall(require, test_module)
    test_module:Destroy()
    assert(ok and outcome == true,
        "Original quest monster registration fixture failed: "
            .. tostring(outcome))
    print("[C4 Quest Combat Ledger Focus] PASS 1/1")
end

main()
