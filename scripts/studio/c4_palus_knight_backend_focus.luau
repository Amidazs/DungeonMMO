--!strict
-- Focused unpublished Palus Knight / Duskguard backend closure runner.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Duskguard backend focus requires an unpublished local place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local core_tests = ServerScriptService.Core.Tests
local combat_tests = ServerScriptService.Combat.Tests

local FIXTURE_TIMEOUT_SECONDS = 12

local FIXTURES = table.freeze({
    {Folder = core_tests, Name = "C4PalusKnightFoundationTest"},
    {Folder = core_tests, Name = "C4PalusKnightSourceEffectsTest"},
    {Folder = core_tests, Name = "C4DuskguardCastServiceTest"},
    {Folder = core_tests, Name = "C4DuskguardControlAuthoritiesTest"},
    {Folder = core_tests, Name = "C4Level30LaunchCoverageTest"},
    {Folder = core_tests, Name = "C4CreativeSkillLinkAuditTest"},
    {Folder = core_tests, Name = "C4Level30SkillTreeSourceTest"},
    {Folder = core_tests, Name = "C4SkillEffectSourceTest"},
    {Folder = core_tests, Name = "C4PrimaryStatReferenceTest"},
    {Folder = core_tests, Name = "C4OwnedPassiveSourceResolverTest"},
    {Folder = core_tests, Name = "C4UnifiedStatReferenceTest"},
    {Folder = core_tests, Name = "C4ResourceMigrationBoundaryTest"},
    {Folder = core_tests, Name = "C4StatusEffectReferenceTest"},
    {Folder = core_tests, Name = "C4SourceCastContractServiceTest"},
    {Folder = core_tests, Name = "C4SourceCastResourceServiceTest"},
    {Folder = core_tests, Name = "C4SourceCastTimingServiceTest"},
    {Folder = core_tests, Name = "C4SourceCastSchedulerServiceTest"},
    {Folder = core_tests, Name = "C4SourceCastRuntimeCompositionTest"},
    {Folder = core_tests, Name = "C4SourceCombatCalculationServiceTest"},
    {Folder = core_tests, Name = "C4SourceCombatExecutorTest"},
    {Folder = combat_tests, Name = "C4EnemyWeakeningTest"},
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
        "Missing Duskguard backend test: " .. fixture_spec.Name
    )
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_DUSKGUARD_" .. fixture_spec.Name
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
        warn("[Duskguard Backend] TIMEOUT " .. fixture_spec.Name)
        return false
    end

    fixture:Destroy()
    if not ok or result ~= true then
        warn(
            "[Duskguard Backend] FAIL "
                .. fixture_spec.Name
                .. ": "
                .. tostring(result)
        )
        return false
    end

    print("[Duskguard Backend] PASS " .. fixture_spec.Name)
    return true
end

--[[
Runs Palus Knight progression, effects, runtime and authority acceptance.

Args:
    None.

Returns:
    nil: Raises unless every bounded Duskguard backend suite passes.
]]
local function main()
    local passed = 0

    for _, fixture_spec in ipairs(FIXTURES) do
        if run_test(fixture_spec) then
            passed += 1
        end
    end

    print((
        "[Duskguard Backend] RESULT passed=%d total=%d"
    ):format(passed, #FIXTURES))

    assert(
        passed == #FIXTURES,
        "One or more Duskguard backend tests failed"
    )
end

main()
