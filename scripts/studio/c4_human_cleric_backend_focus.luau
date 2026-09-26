--!strict
-- Broad unpublished Human Cleric / Dawnkeeper backend acceptance runner.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Human Cleric backend focus requires an unpublished local place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local core_tests = ServerScriptService.Core.Tests
local combat_tests = ServerScriptService.Combat.Tests
local dungeon_tests = ServerScriptService.Dungeon.Tests

local FIXTURES = table.freeze({
    {Folder = core_tests, Name = "C4HumanClericFoundationTest"},
    {Folder = core_tests, Name = "C4HumanClericSourceEffectsTest"},
    {Folder = core_tests, Name = "C4CreativeSkillLinkAuditTest"},
    {Folder = core_tests, Name = "C4PrimaryStatReferenceTest"},
    {Folder = core_tests, Name = "C4OwnedPassiveSourceResolverTest"},
    {Folder = core_tests, Name = "C4UnifiedStatReferenceTest"},
    {Folder = core_tests, Name = "C4ResourceMigrationBoundaryTest"},
    {Folder = core_tests, Name = "C4Level30LaunchCoverageTest"},
    {Folder = core_tests, Name = "C4StatusEffectReferenceTest"},
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
        Name = "C4HumanClericDirectMagicBridgeTest",
    },
    {
        Folder = core_tests,
        Name = "C4SourceSupportMagicCastServiceTest",
    },
    {
        Folder = core_tests,
        Name = "C4ActiveSourceEffectStateTest",
    },
    {
        Folder = core_tests,
        Name = "C4SourceCastRuntimeCompositionTest",
    },
    {
        Folder = core_tests,
        Name = "C4SourceCombatCalculationServiceTest",
    },
    {Folder = core_tests, Name = "C4SourceCombatExecutorTest"},
    {Folder = combat_tests, Name = "MageHealServiceTest"},
    {
        Folder = dungeon_tests,
        Name = "DungeonDeathServiceTest",
    },
    {Folder = core_tests, Name = "RuntimeDefaultBindingTest"},
    {
        Folder = core_tests,
        Name = "C4DungeonSourceCastRuntimeTest",
    },
})

--[[
Runs one existing server test in a temporary ModuleScript beside its source.

Args:
    fixture_spec (any): Source folder and test script name.

Returns:
    boolean: True only when the copied test completes successfully.
]]
local function run_test(fixture_spec: any): boolean
    local source = assert(
        fixture_spec.Folder:FindFirstChild(fixture_spec.Name),
        "Missing Human Cleric backend test: "
            .. fixture_spec.Name
    )

    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_CLERIC_" .. fixture_spec.Name
    fixture.Source = source.Source .. "
return true
"
    fixture.Parent = source.Parent

    local ok, result = pcall(require, fixture)
    fixture:Destroy()

    if not ok or result ~= true then
        warn(
            "[Human Cleric Backend] FAIL "
                .. fixture_spec.Name
                .. ": "
                .. tostring(result)
        )
        return false
    end

    print(
        "[Human Cleric Backend] PASS "
            .. fixture_spec.Name
    )
    return true
end

--[[
Runs Human Cleric progression, source, support and hostile acceptance.

Args:
    None.

Returns:
    nil: Raises unless every bounded level-30 Cleric suite passes.
]]
local function main()
    local passed = 0

    for _, fixture_spec in ipairs(FIXTURES) do
        if run_test(fixture_spec) then
            passed += 1
        end
    end

    print((
        "[Human Cleric Backend] RESULT passed=%d total=%d"
    ):format(passed, #FIXTURES))

    assert(
        passed == #FIXTURES,
        "One or more Human Cleric backend tests failed"
    )
end

main()
