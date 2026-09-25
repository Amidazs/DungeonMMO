--!strict
-- Broad unpublished Human Wizard backend acceptance runner.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Human Wizard big backend focus requires an unpublished local place"
)

local tests = game:GetService("ServerScriptService").Core.Tests

local FIXTURES = table.freeze({
    "C4FirstTransferBranchesTest",
    "C4FirstTransferRanksTest",
    "C4FirstTransferSelectionServiceTest",
    "C4FirstTransferTrainingTest",
    "C4OriginalFirstTransferQuestStagesTest",
    "C4HumanWizardFoundationTest",
    "C4HumanWizardQuestTransactionTest",
    "C4Level30SkillTreeSourceTest",
    "C4SkillEffectSourceTest",
    "C4SkillEffectFidelityAuditTest",
    "C4CreativeSkillLinkAuditTest",
    "C4PrimaryStatReferenceTest",
    "C4OwnedPassiveSourceResolverTest",
    "C4UnifiedStatReferenceTest",
    "C4ResourceMigrationBoundaryTest",
    "C4NineClassAuthenticatedSkillPreviewTest",
    "C4SkillRuntimeRulesTest",
    "C4SourceCastContractServiceTest",
    "C4SourceCastResourceServiceTest",
    "C4SourceCastTimingServiceTest",
    "C4SourceCastSchedulerServiceTest",
    "C4SourceDirectMagicCastServiceTest",
    "C4SourcePeriodicMagicCastServiceTest",
    "C4HumanWizardStagedCastIntegrationTest",
    "C4SourceCombatCalculationServiceTest",
    "C4SourceCombatExecutorTest",
})

--[[
Runs one existing server test as an isolated temporary ModuleScript.

Args:
    test_name (string): Existing Core test script name.

Returns:
    boolean: True only when the copied test completes successfully.
]]
local function run_test(test_name: string): boolean
    local source = assert(
        tests:FindFirstChild(test_name),
        "Missing Human Wizard big-focus test: " .. test_name
    )
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_BIG_" .. test_name
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = tests

    local ok, result = pcall(require, fixture)
    fixture:Destroy()

    if not ok or result ~= true then
        warn(
            "[Human Wizard Big Backend] FAIL "
                .. test_name
                .. ": "
                .. tostring(result)
        )
        return false
    end

    print("[Human Wizard Big Backend] PASS " .. test_name)
    return true
end

--[[
Runs the broad Human Wizard progression/source/cast/combat acceptance set.

Args:
    None.

Returns:
    nil: Raises unless every staged Human Wizard backend suite passes.
]]
local function main()
    local passed = 0

    for _, test_name in ipairs(FIXTURES) do
        if run_test(test_name) then
            passed += 1
        end
    end

    print((
        "[Human Wizard Big Backend] RESULT passed=%d total=%d"
    ):format(passed, #FIXTURES))

    assert(
        passed == #FIXTURES,
        "One or more Human Wizard big backend tests failed"
    )
end

main()
