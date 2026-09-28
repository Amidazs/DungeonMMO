--!strict
-- Unpublished Dungeon acceptance for released EnemyDefeat Adventures.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Launch bounty focus requires an unpublished Studio place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local Tests = ServerScriptService.Dungeon.Tests

local TESTS = table.freeze({
    "DungeonWolfFactoryTest",
    "MarauderCaptainContractTest",
    "EncounterServiceTest",
    "ForestWolfBountyDungeonIntegrationTest",
    "MarauderCaptainBountyDungeonIntegrationTest",
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
        "Launch bounty test missing: " .. test_name
    )
    assert(
        source:IsA("LuaSourceContainer"),
        "Launch bounty fixture must contain Luau: " .. test_name
    )

    local holder = Instance.new("ModuleScript")
    holder.Name = "TEMP_LaunchBounty_" .. test_name
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
Runs all released EnemyDefeat Adventure integration checks.

Args:
    None.

Returns:
    nil: Prints a stable marker after every suite passes.
]]
local function main()
    for _, test_name in ipairs(TESTS) do
        run_test(test_name)
    end

    print("[Launch Bounty Dungeon] 5/5 PASS")
    print("VERIFIED_LAUNCH_BOUNTY_DUNGEON_PASS 5")
end

main()
