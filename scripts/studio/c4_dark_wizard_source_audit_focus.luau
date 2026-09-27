--!strict
-- Focused unpublished Dark Wizard class-39 source-audit runner.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Dark Wizard source audit requires an unpublished local place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local core_tests = ServerScriptService.Core.Tests

local FIXTURE_TIMEOUT_SECONDS = 12

local FIXTURES = table.freeze({
    {Folder = core_tests, Name = "C4DarkWizardSourceAuditTest"},
    {Folder = core_tests, Name = "C4Level30LaunchCoverageTest"},
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
        "Missing Dark Wizard source test: " .. fixture_spec.Name
    )
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_DARK_WIZARD_" .. fixture_spec.Name
    fixture.Source = source.Source .. "\nreturn true\n"
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
        warn("[Dark Wizard Source Audit] TIMEOUT " .. fixture_spec.Name)
        return false
    end

    fixture:Destroy()
    if not ok or result ~= true then
        warn(
            "[Dark Wizard Source Audit] FAIL "
                .. fixture_spec.Name
                .. ": "
                .. tostring(result)
        )
        return false
    end

    print("[Dark Wizard Source Audit] PASS " .. fixture_spec.Name)
    return true
end

--[[
Runs the bounded Dark Wizard source-audit acceptance.

Args:
    None.

Returns:
    nil: Raises unless both source-audit fixtures pass.
]]
local function main()
    local passed = 0

    for _, fixture_spec in ipairs(FIXTURES) do
        if run_test(fixture_spec) then
            passed += 1
        end
    end

    print(
        ("[Dark Wizard Source Audit] RESULT passed=%d total=%d")
            :format(passed, #FIXTURES)
    )
    assert(
        passed == #FIXTURES,
        "One or more Dark Wizard source-audit tests failed"
    )
end

main()
