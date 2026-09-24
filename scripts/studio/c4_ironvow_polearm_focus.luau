--!strict
-- Run isolated real-NPC polearm swing tests in unpublished Dungeon Studio.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Polearm test must use a local unpublished Dungeon composition")

local SSS = game:GetService("ServerScriptService")
local tests = SSS.Combat.Tests

--[[
Runs the authored source-owned multi-target melee fixture once.

Args:
    None.

Returns:
    nil: Propagates failing NPC HP assertions instead of reporting PASS.
]]
local function main()
    local fixture = assert(tests:FindFirstChild(
        "C4IronvowPolearmHitCapTest"
    ), "Polearm hit-cap fixture not present in disposable Dungeon")
    local source = Instance.new("ModuleScript")
    source.Name = "TEMP_WarriorPolearmHitCap"
    source.Source = fixture.Source .. "\nreturn true\n"
    source.Parent = tests
    local ok, result = pcall(require, source)
    source:Destroy()
    assert(ok and result == true,
        "Warrior polearm real NPC hit-cap test failed: "
            .. tostring(result))
    print("[Warrior Polearm] VERIFIED_REAL_NPC_HIT_CAP_PASS")
end

main()
