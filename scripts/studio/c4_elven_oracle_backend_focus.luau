--!strict
-- Focused unpublished Lifebinder / Elven Oracle backend closure runner.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Lifebinder backend focus requires an unpublished local place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local core_tests = ServerScriptService.Core.Tests
local combat_tests = ServerScriptService.Combat.Tests
local dungeon_tests = ServerScriptService.Dungeon.Tests

local FIXTURES = table.freeze({
    {Folder = core_tests, Name = "C4ElvenOracleSourceAuditTest"},
    {Folder = core_tests, Name = "C4ElvenOracleFoundationTest"},
    {Folder = core_tests, Name = "C4Level30LaunchCoverageTest"},
    {Folder = core_tests, Name = "C4CreativeSkillLinkAuditTest"},
    {Folder = core_tests, Name = "C4Level30SkillTreeSourceTest"},
    {Folder = core_tests, Name = "C4SkillEffectSourceTest"},
    {Folder = core_tests, Name = "C4PrimaryStatReferenceTest"},
    {Folder = core_tests, Name = "C4OwnedPassiveSourceResolverTest"},
    {Folder = core_tests, Name = "C4UnifiedStatReferenceTest"},
    {Folder = core_tests, Name = "C4ResourceMigrationBoundaryTest"},
    {Folder = core_tests, Name = "C4StatusEffectReferenceTest"},
    {Folder = core_tests, Name = "C4SourceDirectMagicCastServiceTest"},
    {Folder = core_tests, Name = "C4SourceSupportMagicCastServiceTest"},
    {Folder = core_tests, Name = "C4ActiveSourceEffectStateTest"},
    {Folder = core_tests, Name = "C4SourceCastRuntimeCompositionTest"},
    {Folder = core_tests, Name = "C4SourceCombatCalculationServiceTest"},
    {Folder = core_tests, Name = "C4SourceCombatExecutorTest"},
    {Folder = combat_tests, Name = "ManaServiceTest"},
    {Folder = combat_tests, Name = "C4EnemyWeakeningTest"},
    {Folder = dungeon_tests, Name = "DungeonDeathServiceTest"},
    {Folder = core_tests, Name = "RuntimeDefaultBindingTest"},
    {Folder = core_tests, Name = "C4DungeonSourceCastRuntimeTest"},
})

--[[
Runs one existing regression beside its original source.

Args:
    fixture_spec (any): Source folder and test script name.

Returns:
    boolean: True only when the copied test source completes successfully.
]]
local function run_test(fixture_spec: any): boolean
    local source = assert(
        fixture_spec.Folder:FindFirstChild(fixture_spec.Name),
        "Missing Lifebinder backend test: " .. fixture_spec.Name
    )
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_LIFEBINDER_" .. fixture_spec.Name
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = source.Parent

    local ok, result = pcall(require, fixture)
    fixture:Destroy()

    if not ok or result ~= true then
        warn(
            "[Lifebinder Backend] FAIL "
                .. fixture_spec.Name
                .. ": "
                .. tostring(result)
        )
        return false
    end

    print("[Lifebinder Backend] PASS " .. fixture_spec.Name)
    return true
end

--[[
Runs Elven Oracle progression, source, support and hostile acceptance.

Args:
    None.

Returns:
    nil: Raises unless every bounded level-30 Oracle suite passes.
]]
local function main()
    local passed = 0

    for _, fixture_spec in ipairs(FIXTURES) do
        if run_test(fixture_spec) then
            passed += 1
        end
    end

    print((
        "[Lifebinder Backend] RESULT passed=%d total=%d"
    ):format(passed, #FIXTURES))

    assert(
        passed == #FIXTURES,
        "One or more Lifebinder backend tests failed"
    )
end

main()
