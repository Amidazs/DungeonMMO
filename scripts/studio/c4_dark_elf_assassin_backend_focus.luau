--!strict
-- Focused unpublished Dark Elf Assassin / Veilblade backend checkpoint runner.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Veilblade backend focus requires an unpublished local place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local core_tests = ServerScriptService.Core.Tests

local FIXTURE_TIMEOUT_SECONDS = 12

local FIXTURES = table.freeze({
    {Folder = core_tests, Name = "C4DarkElfAssassinFoundationTest"},
    {Folder = core_tests, Name = "C4VeilbladeCastServiceTest"},
    {Folder = core_tests, Name = "C4RogueBleedTest"},
    {Folder = core_tests, Name = "C4RogueBleedTrainingTest"},
    {Folder = core_tests, Name = "C4ScoutAccuracyToggleTest"},
    {Folder = core_tests, Name = "C4ScoutActiveStatusTest"},
    {Folder = core_tests, Name = "C4ScoutCriticalPowerToggleTest"},
    {Folder = core_tests, Name = "C4ScoutCriticalTrainingTest"},
    {Folder = core_tests, Name = "C4ScoutEnvironmentEquipmentTest"},
    {Folder = core_tests, Name = "C4ScoutInventoryTest"},
    {Folder = core_tests, Name = "C4ScoutLockpickingTest"},
    {Folder = core_tests, Name = "C4ScoutPassivesTest"},
    {Folder = core_tests, Name = "C4Level30LaunchCoverageTest"},
    {Folder = core_tests, Name = "C4CreativeSkillLinkAuditTest"},
    {Folder = core_tests, Name = "C4Level30SkillTreeSourceTest"},
    {Folder = core_tests, Name = "C4SkillEffectSourceTest"},
    {Folder = core_tests, Name = "C4PrimaryStatReferenceTest"},
    {Folder = core_tests, Name = "C4OwnedPassiveSourceResolverTest"},
    {Folder = core_tests, Name = "C4UnifiedStatReferenceTest"},
    {Folder = core_tests, Name = "C4ResourceMigrationBoundaryTest"},
    {Folder = core_tests, Name = "C4SourceCastContractServiceTest"},
    {Folder = core_tests, Name = "C4SourceCastTimingServiceTest"},
    {Folder = core_tests, Name = "C4SourceCastSchedulerServiceTest"},
    {Folder = core_tests, Name = "C4SourceCastRuntimeCompositionTest"},
    {Folder = core_tests, Name = "C4SourceCombatCalculationServiceTest"},
    {Folder = core_tests, Name = "C4SourceCombatExecutorTest"},
    {Folder = core_tests, Name = "RuntimeDefaultBindingTest"},
    {Folder = core_tests, Name = "C4DungeonSourceCastRuntimeTest"},
})

--[[
Runs one existing regression beside its original source.

Args:
    fixture_spec (any): Source folder and test script name.

Returns:
    boolean: True only when the copied test completes successfully.
]]
local function run_test(fixture_spec: any): boolean
    local source = assert(
        fixture_spec.Folder:FindFirstChild(fixture_spec.Name),
        "Missing Veilblade backend test: " .. fixture_spec.Name
    )
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_VEILBLADE_" .. fixture_spec.Name
    fixture.Source = source.Source .. "
return true
"
    fixture.Parent = source.Parent

    local finished = false
    local ok = false
    local result = nil
    local thread = task.spawn(function()
        ok, result = pcall(require, fixture)
        finished = true
    end)
    local deadline = os.clock() + FIXTURE_TIMEOUT_SECONDS

    while not finished and os.clock() < deadline do
        task.wait(0.05)
    end

    if not finished then
        task.cancel(thread)
        fixture:Destroy()
        warn("[Veilblade Backend] TIMEOUT " .. fixture_spec.Name)
        return false
    end

    fixture:Destroy()
    if not ok or result ~= true then
        warn(
            "[Veilblade Backend] FAIL "
                .. fixture_spec.Name
                .. ": "
                .. tostring(result)
        )
        return false
    end

    print("[Veilblade Backend] PASS " .. fixture_spec.Name)
    return true
end

--[[
Runs Veilblade progression, shared-scout, source and cast acceptance.

Args:
    None.

Returns:
    nil: Raises unless every bounded checkpoint suite passes.
]]
local function main()
    local passed = 0

    for _, fixture_spec in ipairs(FIXTURES) do
        if run_test(fixture_spec) then
            passed += 1
        end
    end

    print((
        "[Veilblade Backend] RESULT passed=%d total=%d"
    ):format(passed, #FIXTURES))

    assert(
        passed == #FIXTURES,
        "One or more Veilblade backend tests failed"
    )
end

main()
