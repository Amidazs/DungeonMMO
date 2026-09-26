--!strict
-- Focused unpublished runner for Moonweaver / Elven Wizard backend closure.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Moonweaver backend focus requires an unpublished local place"
)

local tests = game:GetService("ServerScriptService").Core.Tests

local FIXTURES = table.freeze({
    "C4ElvenWizardSourceAuditTest",
    "C4ElvenWizardFoundationTest",
    "C4Level30LaunchCoverageTest",
    "C4CreativeSkillLinkAuditTest",
    "C4Level30SkillTreeSourceTest",
    "C4SkillEffectSourceTest",
    "C4PrimaryStatReferenceTest",
    "C4OwnedPassiveSourceResolverTest",
    "C4ResourceMigrationBoundaryTest",
    "C4SourceDirectMagicCastServiceTest",
    "C4SourceSupportMagicCastServiceTest",
    "C4SourceCompanionCastServiceTest",
    "C4SourceCompanionServiceTest",
    "C4SourceCastRuntimeCompositionTest",
    "C4SourceCombatCalculationServiceTest",
    "C4SourceCombatExecutorTest",
})

--[[
Runs one existing server regression as an isolated temporary ModuleScript.

Args:
    test_name (string): Existing Core test script name.

Returns:
    boolean: True only when the copied test source completes successfully.
]]
local function run_test(test_name: string): boolean
    local source = assert(
        tests:FindFirstChild(test_name),
        "Missing Moonweaver backend test: " .. test_name
    )
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_MOONWEAVER_" .. test_name
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = tests

    local ok, result = pcall(require, fixture)
    fixture:Destroy()

    if not ok or result ~= true then
        warn(
            "[Moonweaver Backend] FAIL "
                .. test_name
                .. ": "
                .. tostring(result)
        )
        return false
    end

    print("[Moonweaver Backend] PASS " .. test_name)
    return true
end

--[[
Runs the bounded Elven Wizard progression/source/runtime regression set.

Args:
    None.

Returns:
    nil: Raises unless every Moonweaver backend dependency passes.
]]
local function main()
    local passed = 0

    for _, test_name in ipairs(FIXTURES) do
        if run_test(test_name) then
            passed += 1
        end
    end

    print((
        "[Moonweaver Backend] RESULT passed=%d total=%d"
    ):format(passed, #FIXTURES))

    assert(
        passed == #FIXTURES,
        "One or more Moonweaver backend tests failed"
    )
end

main()
