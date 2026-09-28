--!strict
-- Unpublished Base acceptance for the optional Forest Wolf bounty.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Forest Wolf Base focus requires an unpublished Studio place"
)

local ServerScriptService = game:GetService("ServerScriptService")

local TESTS = table.freeze({
    "QuestDefinitionsTest",
    "AdventureEligibilityTest",
    "QuestServiceTest",
    "DarkElfAdventureIntegrationTest",
})

--[[
Runs one Core test through a disposable ModuleScript copy.

Args:
    test_name (string): Exact Core.Tests child name.

Returns:
    nil: Raises when the test is missing or fails.
]]
local function run_core_test(test_name: string)
    local source = assert(
        ServerScriptService.Core.Tests:FindFirstChild(test_name),
        "Forest Wolf Base test missing: " .. test_name
    )
    assert(
        source:IsA("LuaSourceContainer"),
        "Forest Wolf Base fixture must contain Luau: " .. test_name
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
Runs the Base-side Forest Wolf bounty package.

Args:
    None.

Returns:
    nil: Prints a stable marker after all Base suites pass.
]]
local function main()
    for _, test_name in ipairs(TESTS) do
        run_core_test(test_name)
    end

    local board = assert(
        ServerScriptService.Base.Tests:FindFirstChild(
            "BaseQuestBoardContractTest"
        ),
        "BaseQuestBoardContractTest missing"
    )
    local holder = Instance.new("ModuleScript")
    holder.Name = "TEMP_WolfBounty_BaseQuestBoardContractTest"
    holder.Source = board.Source .. "\nreturn true\n"
    holder.Parent = ServerScriptService

    local ok, result = pcall(require, holder)
    holder:Destroy()
    assert(
        ok and result == true,
        "BaseQuestBoardContractTest failed: " .. tostring(result)
    )

    print("[Forest Wolf Bounty Base] 5/5 PASS")
    print("VERIFIED_FOREST_WOLF_BOUNTY_BASE_PASS 5")
end

main()
