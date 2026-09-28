--!strict
-- Unpublished Base acceptance for launch quest variety and transfer quest arcs.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Quest variety focus requires an unpublished Studio place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local Tests = ServerScriptService.Core.Tests

local TESTS = table.freeze({
    "QuestDefinitionsTest",
    "AdventureEligibilityTest",
    "HiddenRoomQuestIntegrationTest",
    "LostSurveyorEscortIntegrationTest",
    "C4OriginalFirstTransferQuestArcsTest",
    "C4OriginalFirstTransferQuestStagesTest",
})

--[[
Runs one source-controlled Core test through a disposable ModuleScript.

Args:
    test_name (string): Exact Core.Tests child name.

Returns:
    nil: Raises when the test is missing or fails.
]]
local function run_test(test_name: string)
    local source = assert(
        Tests:FindFirstChild(test_name),
        "Quest variety test missing: " .. test_name
    )
    assert(
        source:IsA("LuaSourceContainer"),
        "Quest variety fixture must contain Luau: " .. test_name
    )

    local holder = Instance.new("ModuleScript")
    holder.Name = "TEMP_QuestVariety_" .. test_name
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
Runs launch quest-variety and three-quest advancement acceptance.

Args:
    None.

Returns:
    nil: Prints stable markers only after every suite passes.
]]
local function main()
    for _, test_name in ipairs(TESTS) do
        run_test(test_name)
    end

    print(
        ("[Quest Variety Focus] %d/%d PASS")
            :format(#TESTS, #TESTS)
    )
    print(
        "VERIFIED_QUEST_VARIETY_FOCUS_PASS "
            .. tostring(#TESTS)
    )
end

main()
