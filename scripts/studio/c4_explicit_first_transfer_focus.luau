--!strict
-- Original C4 class choice and pre-existing quest/history acceptance.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Original class choice acceptance requires unpublished Studio")

local tests = game:GetService("ServerScriptService").Core.Tests
local names = {
    "C4FirstTransferSelectionServiceTest",
    "ClassAdvancementServiceTest",
    "ProfileMigrationQuestAdvancementV8Test",
    "ProfileMigrationRaceChangeV12Test",
    "RaceChangeServiceTest",
    "C4FirstTransferBranchesTest",
    "C4ClassPathRulesTest",
    "C4CatalogueCoverageTest",
}
local passed = 0
local failed = 0

--[[
Executes a checked-in focused fixture with its original require context.

Args:
    name (string): Existing source-controlled server test script.

Returns:
    boolean: True only if the real original Studio test completes.
]]
local function run_fixture(name: string): boolean
    local source = tests:FindFirstChild(name)
    if not source or not source:IsA("LuaSourceContainer") then
        warn("[C4 Transfer Choice Focus] MISSING " .. name)
        return false
    end
    local runner = Instance.new("ModuleScript")
    runner.Name = "TEMP_" .. name
    runner.Source = source.Source .. "\nreturn true\n"
    runner.Parent = source.Parent
    local ok, result = pcall(require, runner)
    runner:Destroy()
    if not ok or result ~= true then
        warn("[C4 Transfer Choice Focus] FAIL " .. name
            .. " " .. tostring(result))
        return false
    end
    print("[C4 Transfer Choice Focus] PASS " .. name)
    return true
end

--[[
Runs only explicit first-transfer, legacy migration and source coverage.

Args:
    None.

Returns:
    nil: Fails if an affected fixture did not execute successfully.
]]
local function main()
    for _, name in ipairs(names) do
        if run_fixture(name) then
            passed += 1
        else
            failed += 1
        end
    end
    print(("[C4 Transfer Choice Focus] RESULT passed=%d "
        .. "failed=%d total=%d"):format(passed, failed, #names))
    assert(failed == 0, "Original C4 explicit class choice acceptance failed")
end

main()
