--!strict
-- Unpublished Base Studio acceptance for profession-aware Adventure content.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Profession quest focus requires an unpublished Studio place"
)

local ServerScriptService = game:GetService("ServerScriptService")

local TESTS = table.freeze({
    table.freeze({
        Parent = ServerScriptService.Core.Tests,
        Name = "QuestDefinitionsTest",
    }),
    table.freeze({
        Parent = ServerScriptService.Core.Tests,
        Name = "QuestServiceTest",
    }),
    table.freeze({
        Parent = ServerScriptService.Core.Tests,
        Name = "ProfessionQuestRewardIntegrationTest",
    }),
    table.freeze({
        Parent = ServerScriptService.Core.Tests,
        Name = "ProfessionLaunchEconomyTopologyTest",
    }),
    table.freeze({
        Parent = ServerScriptService.Core.Tests,
        Name = "ProfessionBlueprintAcquisitionIntegrationTest",
    }),
    table.freeze({
        Parent = ServerScriptService.Core.Tests,
        Name = "ProfessionGatherTierTest",
    }),
    table.freeze({
        Parent = ServerScriptService.Base.Tests,
        Name = "BaseEnvironmentContractTest",
    }),
    table.freeze({
        Parent = ServerScriptService.Base.Tests,
        Name = "BaseQuestBoardContractTest",
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
        "Profession quest test missing: " .. test_name
    )
    assert(
        source:IsA("LuaSourceContainer"),
        "Profession quest fixture must contain Luau: " .. test_name
    )

    local holder = Instance.new("ModuleScript")
    holder.Name = "TEMP_ProfessionQuest_" .. test_name
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
Runs the complete profession-aware Adventure content package.

Args:
    None.

Returns:
    nil: Prints a stable marker only after every included suite passes.
]]
local function main()
    for _, test in ipairs(TESTS) do
        run_test(test.Parent, test.Name)
    end

    print(
        ("[Profession Quest Content Focus] %d/%d PASS")
            :format(#TESTS, #TESTS)
    )
    print(
        "VERIFIED_PROFESSION_QUEST_CONTENT_FOCUS_PASS "
            .. tostring(#TESTS)
    )
end

main()
