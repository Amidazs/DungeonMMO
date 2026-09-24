--!strict
-- Run real world-NPC rank-one and rank-nine Warrior area skill tests.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Source area skill regression requires unpublished local Dungeon")

local SSS = game:GetService("ServerScriptService")

--[[
Runs the original source-driven server combat fixture in local Studio.

Args:
    None.

Returns:
    nil: Throws if any actual NPC HP or area cap assertion fails.
]]
local function main()
    local tests = SSS.Combat.Tests
    local fixture = assert(tests:FindFirstChild(
        "C4IronvowCrescentSweepTest"
    ), "Missing original Warrior polearm area skill fixture")
    local script_copy = Instance.new("ModuleScript")
    script_copy.Name = "TEMP_CrescentSweepSourceFixture"
    script_copy.Source = fixture.Source .. "\nreturn true\n"
    script_copy.Parent = tests
    local ok, result = pcall(require, script_copy)
    script_copy:Destroy()
    assert(ok and result == true,
        "Warrior C4 area attack real HP regression failed: "
            .. tostring(result))
    print("[Warrior Crescent Sweep] VERIFIED_REAL_NPC_AREA_PASS")
end

main()
