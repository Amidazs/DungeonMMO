--!strict
-- Focused unpublished runner for Human Wizard source cast authority.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Human Wizard source-cast focus requires an unpublished local place"
)

local tests = game:GetService("ServerScriptService").Core.Tests

local FIXTURES = table.freeze({
    "C4SkillRuntimeRulesTest",
    "C4SourceCastContractServiceTest",
    "C4SourceCastResourceServiceTest",
    "C4SourceCastTimingServiceTest",
    "C4SourceCombatCalculationServiceTest",
})

--[[
Runs one existing server test as an isolated temporary ModuleScript.

Args:
    test_name (string): Existing Core test script name.

Returns:
    boolean: True only when the copied test source completes successfully.
]]
local function run_test(test_name: string): boolean
    local source = assert(
        tests:FindFirstChild(test_name),
        "Missing Human Wizard source-cast test: " .. test_name
    )
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_" .. test_name
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = tests

    local ok, result = pcall(require, fixture)
    fixture:Destroy()

    if not ok or result ~= true then
        warn(
            "[Human Wizard Source Cast] FAIL "
                .. test_name
                .. ": "
                .. tostring(result)
        )
        return false
    end

    print("[Human Wizard Source Cast] PASS " .. test_name)
    return true
end

--[[
Runs the bounded source cast and direct MDAM regressions.

Args:
    None.

Returns:
    nil: Raises unless both source-only contracts pass.
]]
local function main()
    local passed = 0

    for _, test_name in ipairs(FIXTURES) do
        if run_test(test_name) then
            passed += 1
        end
    end

    print((
        "[Human Wizard Source Cast] RESULT passed=%d total=%d"
    ):format(passed, #FIXTURES))

    assert(
        passed == #FIXTURES,
        "One or more Human Wizard source-cast tests failed"
    )
end

main()
