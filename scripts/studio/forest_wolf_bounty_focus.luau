--!strict
-- Focused unpublished-Studio acceptance for the optional Forest Wolf bounty.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Forest Wolf bounty focus requires an unpublished Studio place"
)

local ServerScriptService = game:GetService("ServerScriptService")

local TESTS = table.freeze({
    table.freeze({
        Parent = ServerScriptService.Core.Tests,
        Name = "QuestDefinitionsTest",
    }),
    table.freeze({
        Parent = ServerScriptService.Core.Tests,
        Name = "AdventureEligibilityTest",
    }),
    table.freeze({
        Parent = ServerScriptService.Core.Tests,
        Name = "QuestServiceTest",
    }),
    table.freeze({
        Parent = ServerScriptService.Core.Tests,
        Name = "DarkElfAdventureIntegrationTest",
    }),
    table.freeze({
        Parent = ServerScriptService.Base.Tests,
        Name = "BaseQuestBoardContractTest",
    }),
    table.freeze({
        Parent = ServerScriptService.Dungeon.Tests,
        Name = "DungeonWolfFactoryTest",
    }),
    table.freeze({
        Parent = ServerScriptService.Dungeon.Tests,
        Name = "EncounterServiceTest",
    }),
})

--[[
Runs one source-controlled test through a disposable ModuleScript.

Args:
    parent (Instance): Folder containing the test source.
    test_name (string): Exact LuaSourceContainer child name.

Returns:
    nil: Raises when the test is missing or fails.
]]
local function run_test(
    parent: Instance,
    test_name: string
)
    local source = assert(
        parent:FindFirstChild(test_name),
        "Forest Wolf bounty test missing: " .. test_name
    )
    assert(
        source:IsA("LuaSourceContainer"),
        "Forest Wolf bounty fixture must contain Luau: "
            .. test_name
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
Runs the complete Forest Wolf bounty acceptance package.

Args:
    None.

Returns:
    nil: Prints a stable marker after every included suite succeeds.
]]
local function main()
    for _, test in ipairs(TESTS) do
        run_test(test.Parent, test.Name)
    end

    print(
        ("[Forest Wolf Bounty Focus] %d/%d PASS")
            :format(#TESTS, #TESTS)
    )
    print(
        "VERIFIED_FOREST_WOLF_BOUNTY_FOCUS_PASS "
            .. tostring(#TESTS)
    )
end

main()
