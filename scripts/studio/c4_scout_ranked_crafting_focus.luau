--!strict
-- Unpublished Studio acceptance of new Scout crafting and source coverage.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Ranked crafting tests require an unpublished local Studio place")

local server = game:GetService("ServerScriptService")
local names = {
    "C4ScoutRankedCraftingTest",
    "C4ScoutInventoryTest",
    "C4CatalogueCoverageTest",
    "C4ProfessionCraftSkillsTest",
    "ProfessionCrossDependencyTest",
}
local passed = 0
local failed = 0

--[[
Executes one real source-controlled server test in its original folder.

Args:
    test_name (string): Exact name of the original focused test script.

Returns:
    boolean: True only if the actual Studio fixture completed.
]]
local function run_fixture(test_name: string): boolean
    local source = server.Core.Tests:FindFirstChild(test_name)
    if not source or not source:IsA("LuaSourceContainer") then
        warn("[Scout Craft Focus] MISSING " .. test_name)
        return false
    end
    local runner = Instance.new("ModuleScript")
    runner.Name = "TEMP_" .. test_name
    runner.Source = source.Source .. "\nreturn true\n"
    runner.Parent = source.Parent
    local ok, reason = pcall(require, runner)
    runner:Destroy()
    if not ok then
        warn("[Scout Craft Focus] FAIL " .. test_name
            .. " " .. tostring(reason))
        return false
    end
    print("[Scout Craft Focus] PASS " .. test_name)
    return true
end

--[[
Runs affected profession, real-market and source-rank acceptance only.

Args:
    None.

Returns:
    nil: Fails if any source-controlled focused suite fails in Studio.
]]
local function main()
    for _, name in ipairs(names) do
        if run_fixture(name) then
            passed += 1
        else
            failed += 1
        end
    end
    print(("[Scout Craft Focus] RESULT passed=%d failed=%d total=%d")
        :format(passed, failed, #names))
    assert(failed == 0, "Ranked Scout crafting acceptance failed")
end

main()
