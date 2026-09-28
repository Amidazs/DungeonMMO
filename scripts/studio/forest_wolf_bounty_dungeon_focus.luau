--!strict
-- Unpublished Dungeon acceptance for trusted Forest Wolf quest deaths.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Forest Wolf Dungeon focus requires an unpublished Studio place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local Tests = ServerScriptService.Dungeon.Tests

local TESTS = table.freeze({
    "DungeonWolfFactoryTest",
    "EncounterServiceTest",
})

--[[
Runs one Dungeon test through a disposable ModuleScript copy.

Args:
    test_name (string): Exact Dungeon.Tests child name.

Returns:
    nil: Raises when the test is missing or fails.
]]
local function run_test(test_name: string)
    local source = assert(
        Tests:FindFirstChild(test_name),
        "Forest Wolf Dungeon test missing: " .. test_name
    )
    assert(
        source:IsA("LuaSourceContainer"),
        "Forest Wolf Dungeon fixture must contain Luau: " .. test_name
    )

    local holder = Instance.new("ModuleScript")
    holder.Name = "TEMP_WolfBounty_" .. test_name
    holder.Source = source.Source .. "\nreturn true\n"
    holder.Parent = ServerScriptService

    local ok, result = pcall(require, holder)
    holder:Destroy()

    assert(
        ok and result == true,
        test_name .. " failed: " .. tostring(result)
    )
end

--[[
Runs the Dungeon-side Forest Wolf bounty package.

Args:
    None.

Returns:
    nil: Prints a stable marker after both Dungeon suites pass.
]]
local function main()
    for _, test_name in ipairs(TESTS) do
        run_test(test_name)
    end

    print("[Forest Wolf Bounty Dungeon] 2/2 PASS")
    print("VERIFIED_FOREST_WOLF_BOUNTY_DUNGEON_PASS 2")
end

main()
