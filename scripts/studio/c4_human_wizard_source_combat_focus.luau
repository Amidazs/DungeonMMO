--!strict
-- Focused unpublished runner for Human Wizard C4 source-combat integration.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Human Wizard source-combat focus requires an unpublished local place"
)

local tests = game:GetService("ServerScriptService").Core.Tests

local FIXTURES = table.freeze({
    "C4SourceCombatCalculationServiceTest",
    "C4Level30SkillTreeSourceTest",
    "C4SkillEffectSourceTest",
    "C4PrimaryStatReferenceTest",
    "C4CreativeSkillLinkAuditTest",
    "C4NineClassAuthenticatedSkillPreviewTest",
})

--[[
Runs one existing server regression as an isolated temporary ModuleScript.

Args:
    test_name (string): Existing Core test script name.

Returns:
    boolean: True only when the copied source completes successfully.
]]
local function run_test(test_name: string): boolean
    local source = assert(
        tests:FindFirstChild(test_name),
        "Missing Human Wizard source-combat test: " .. test_name
    )
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_" .. test_name
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = tests

    local ok, result = pcall(require, fixture)
    fixture:Destroy()

    if not ok or result ~= true then
        warn(
            "[Human Wizard Source Combat] FAIL "
                .. test_name
                .. ": "
                .. tostring(result)
        )
        return false
    end

    print("[Human Wizard Source Combat] PASS " .. test_name)
    return true
end

--[[
Runs the bounded source-data and calculator regression for Human Wizard.

Args:
    None.

Returns:
    nil: Raises unless every focused source contract passes.
]]
local function main()
    local passed = 0

    for _, test_name in ipairs(FIXTURES) do
        if run_test(test_name) then
            passed += 1
        end
    end

    print((
        "[Human Wizard Source Combat] RESULT passed=%d total=%d"
    ):format(passed, #FIXTURES))

    assert(
        passed == #FIXTURES,
        "One or more Human Wizard source-combat tests failed"
    )
end

main()
