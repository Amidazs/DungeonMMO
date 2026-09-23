--!strict
-- Unpublished Studio audit of the user's exact original C4 class decision.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Original C4 source audit requires an unpublished local Studio place")

local tests = game:GetService("ServerScriptService").Core.Tests
local names = {
    "C4FirstTransferBranchesTest",
    "C4CatalogueCoverageTest",
}
local passed = 0
local failed = 0

--[[
Executes an existing test inside its original require context.

Args:
    name (string): Exact source-controlled focused Studio test.

Returns:
    boolean: Whether real test execution completed without an error.
]]
local function run_test(name: string): boolean
    local source = tests:FindFirstChild(name)
    if not source or not source:IsA("LuaSourceContainer") then
        warn("[C4 Structure Focus] MISSING " .. name)
        return false
    end
    local runner = Instance.new("ModuleScript")
    runner.Name = "TEMP_" .. name
    runner.Source = source.Source .. "\nreturn true\n"
    runner.Parent = source.Parent
    local ok, reason = pcall(require, runner)
    runner:Destroy()
    if not ok or reason ~= true then
        warn("[C4 Structure Focus] FAIL " .. name
            .. ": " .. tostring(reason))
        return false
    end
    print("[C4 Structure Focus] PASS " .. name)
    return true
end

--[[
Runs only affected exact C4 first-transfer structure and coverage tests.

Args:
    None.

Returns:
    nil: Fails on an omitted test or an incorrectly completed class path.
]]
local function main()
    for _, name in ipairs(names) do
        if run_test(name) then
            passed += 1
        else
            failed += 1
        end
    end
    print(("[C4 Structure Focus] RESULT passed=%d failed=%d total=%d")
        :format(passed, failed, #names))
    assert(failed == 0, "Exact C4 original source structure has regressed")
end

main()
