--!strict
-- Disposable unpublished runner for Human Wizard v2.94 foundation work.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Human Wizard foundation focus requires an unpublished local place"
)

local tests = game:GetService("ServerScriptService").Core.Tests

local FIXTURES = table.freeze({
    "C4HumanWizardFoundationTest",
    "C4HumanWizardQuestTransactionTest",
    "C4Level30LaunchCoverageTest",
})

--[[
Runs one source test as an isolated temporary ModuleScript.

Args:
    test_name (string): Existing server test source to execute.

Returns:
    boolean: True only when the source completes and returns successfully.
]]
local function run_test(test_name: string): boolean
    local source = assert(
        tests:FindFirstChild(test_name),
        "Missing Human Wizard focused test: " .. test_name
    )
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_" .. test_name
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = tests

    local ok, result = pcall(require, fixture)
    fixture:Destroy()

    if not ok or result ~= true then
        warn(
            "[Human Wizard v2.94 Focus] FAIL "
                .. test_name
                .. ": "
                .. tostring(result)
        )
        return false
    end

    print("[Human Wizard v2.94 Focus] PASS " .. test_name)
    return true
end

--[[
Executes the focused Wizard foundation and launch-audit regressions.

Args:
    None.

Returns:
    nil: Raises if either focused test fails.
]]
local function main()
    local passed = 0

    for _, test_name in ipairs(FIXTURES) do
        if run_test(test_name) then
            passed += 1
        end
    end

    print((
        "[Human Wizard v2.94 Focus] RESULT passed=%d total=%d"
    ):format(passed, #FIXTURES))

    assert(
        passed == #FIXTURES,
        "One or more Human Wizard v2.94 focused tests failed"
    )
end

main()
