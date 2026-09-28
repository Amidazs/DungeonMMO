--!strict
-- Unpublished Studio acceptance for the launch profession economy ladder.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Profession launch economy focus requires an unpublished Studio place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local Tests = ServerScriptService.Core.Tests

local TESTS = table.freeze({
    "ProfessionDefinitionContractTest",
    "ProfessionProfileMigrationTest",
    "ProfessionServiceTest",
    "ProfessionGatherTierTest",
    "ProfessionCrossDependencyTest",
    "ProfessionLeatherEnchantingDependencyTest",
    "ProfessionExclusiveChoiceTradeTest",
    "ProfessionLaunchEconomyTopologyTest",
    "ProfessionLaunchEconomyIntegrationTest",
    "GearwrightPremiumEconomyIntegrationTest",
    "ProfessionRuntimeRulesTest",
    "ProfessionResourceDistributionTest",
    "ProfessionCraftRequestGuardTest",
    "ProfessionReconnectRecoveryTest",
    "SkinningEligibilityTest",
    "CorpseSkinningRuntimeTest",
    "CorpseSkinningTwoUserTest",
    "RecipeKnowledgeCraftingGateTest",
    "RecipeKnowledgeDefinitionsTest",
    "C4ProfessionCraftSkillsTest",
    "DwarfArtisanProfessionCapacityTest",
    "DwarfScavengerProfessionCapacityTest",
})

--[[
Runs one source-controlled backend test through a disposable module copy.

Args:
    test_name (string): Exact child name under Core.Tests.

Returns:
    (boolean, string?): Success or captured failure text.
]]
local function run_test(test_name: string): (boolean, string?)
    local source = Tests:FindFirstChild(test_name)
    if not source or not source:IsA("LuaSourceContainer") then
        return false, "MissingTest:" .. test_name
    end

    local holder = Instance.new("ModuleScript")
    holder.Name = "TEMP_ProfessionEconomy_" .. test_name
    holder.Source = source.Source .. "\nreturn true\n"
    holder.Parent = ServerScriptService

    local ok, result = pcall(require, holder)
    holder:Destroy()

    if not ok or result ~= true then
        return false, tostring(result)
    end

    return true, nil
end

--[[
Runs the complete launch profession economy focus package.

Args:
    None.

Returns:
    nil: Prints a stable marker only when every test passes.
]]
local function main()
    local failures = {}

    for _, test_name in ipairs(TESTS) do
        local ok, reason = run_test(test_name)
        if ok then
            print("[Profession Economy Focus] PASS " .. test_name)
        else
            table.insert(
                failures,
                test_name .. ": " .. tostring(reason)
            )
        end
    end

    print(
        ("[Profession Economy Focus] RESULT passed=%d total=%d failed=%d")
            :format(
                #TESTS - #failures,
                #TESTS,
                #failures
            )
    )

    assert(#failures == 0, table.concat(failures, " | "))
    print(
        "VERIFIED_PROFESSION_LAUNCH_ECONOMY_FOCUS_PASS "
            .. tostring(#TESTS)
    )
end

main()
