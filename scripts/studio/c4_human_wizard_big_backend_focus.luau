--!strict
-- Broad unpublished Human Wizard backend acceptance runner.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Human Wizard big backend focus requires an unpublished local place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local core_tests = ServerScriptService.Core.Tests
local combat_tests = ServerScriptService.Combat.Tests
local dungeon_tests = ServerScriptService.Dungeon.Tests

local FIXTURES = table.freeze({
    {Folder = core_tests, Name = "C4FirstTransferBranchesTest"},
    {Folder = core_tests, Name = "C4FirstTransferRanksTest"},
    {
        Folder = core_tests,
        Name = "C4FirstTransferSelectionServiceTest",
    },
    {Folder = core_tests, Name = "C4FirstTransferTrainingTest"},
    {
        Folder = core_tests,
        Name = "C4OriginalFirstTransferQuestStagesTest",
    },
    {Folder = core_tests, Name = "C4HumanWizardFoundationTest"},
    {
        Folder = core_tests,
        Name = "C4HumanWizardQuestTransactionTest",
    },
    {Folder = core_tests, Name = "C4Level30SkillTreeSourceTest"},
    {Folder = core_tests, Name = "C4SkillEffectSourceTest"},
    {Folder = core_tests, Name = "C4SkillEffectFidelityAuditTest"},
    {Folder = core_tests, Name = "C4CreativeSkillLinkAuditTest"},
    {Folder = core_tests, Name = "C4PrimaryStatReferenceTest"},
    {Folder = core_tests, Name = "C4OwnedPassiveSourceResolverTest"},
    {Folder = core_tests, Name = "C4UnifiedStatReferenceTest"},
    {Folder = core_tests, Name = "C4ResourceMigrationBoundaryTest"},
    {
        Folder = core_tests,
        Name = "C4NineClassAuthenticatedSkillPreviewTest",
    },
    {Folder = core_tests, Name = "C4SkillRuntimeRulesTest"},
    {
        Folder = core_tests,
        Name = "C4SourceCastContractServiceTest",
    },
    {
        Folder = core_tests,
        Name = "C4SourceCastResourceServiceTest",
    },
    {
        Folder = core_tests,
        Name = "C4SourceCastTimingServiceTest",
    },
    {
        Folder = core_tests,
        Name = "C4SourceCastSchedulerServiceTest",
    },
    {
        Folder = core_tests,
        Name = "C4SourceDirectMagicCastServiceTest",
    },
    {
        Folder = core_tests,
        Name = "C4SourcePeriodicMagicCastServiceTest",
    },
    {
        Folder = core_tests,
        Name = "C4SourceCastRuntimeCompositionTest",
    },
    {
        Folder = core_tests,
        Name = "C4HumanWizardStagedCastIntegrationTest",
    },
    {
        Folder = core_tests,
        Name = "C4SourceCombatCalculationServiceTest",
    },
    {Folder = core_tests, Name = "C4SourceCombatExecutorTest"},
    {
        Folder = core_tests,
        Name = "C4NpcElementalVulnerabilityServiceTest",
    },
    {Folder = core_tests, Name = "C4CombatDispatchAdapterTest"},
    {Folder = combat_tests, Name = "ManaServiceTest"},
    {
        Folder = combat_tests,
        Name = "C4DamageDispatchIntegrationTest",
    },
    {
        Folder = combat_tests,
        Name = "ContributionDamageBridgeTest",
    },
    {Folder = core_tests, Name = "RuntimeDefaultBindingTest"},
    {
        Folder = core_tests,
        Name = "C4DungeonSourceCastRuntimeTest",
    },
    {
        Folder = dungeon_tests,
        Name = "Phase2AFailurePathTest",
    },
    {
        Folder = dungeon_tests,
        Name = "DungeonEncounterBindingsTest",
    },
})

--[[
Runs one existing server test in a temporary ModuleScript beside its source.

Keeping the copy beside the original preserves relative script.Parent paths for
both Core and Combat test suites.

Args:
    fixture_spec (any): Source folder and test script name.

Returns:
    boolean: True only when the copied test completes successfully.
]]
local function run_test(fixture_spec: any): boolean
    local source = assert(
        fixture_spec.Folder:FindFirstChild(fixture_spec.Name),
        "Missing Human Wizard big-focus test: "
            .. fixture_spec.Name
    )
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_BIG_" .. fixture_spec.Name
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = source.Parent

    local ok, result = pcall(require, fixture)
    fixture:Destroy()

    if not ok or result ~= true then
        warn(
            "[Human Wizard Big Backend] FAIL "
                .. fixture_spec.Name
                .. ": "
                .. tostring(result)
        )
        return false
    end

    print(
        "[Human Wizard Big Backend] PASS "
            .. fixture_spec.Name
    )
    return true
end

--[[
Runs progression, source, cast, dispatch and bookkeeping acceptance suites.

Args:
    None.

Returns:
    nil: Raises unless every staged Human Wizard backend suite passes.
]]
local function main()
    local passed = 0

    for _, fixture_spec in ipairs(FIXTURES) do
        if run_test(fixture_spec) then
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
