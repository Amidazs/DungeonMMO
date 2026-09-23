--!strict
-- Run against a disposable unpublished Rojo Base/Dungeon .rbxlx.
-- Studio CLI: --task RunScript --localPlaceFile <place>
-- --runScriptFile <this file> --outputFile <log> --quitAfterExecution
assert(game.PlaceId == 0 and game.GameId == 0,
    "Profession tests must run in an unpublished local place.")

local server = game:GetService("ServerScriptService")
local tests = server.Core.Tests
local names = {
    "ProfessionExclusiveChoiceTradeTest",
    "ProfessionServiceTest",
    "ProfessionCrossDependencyTest",
    "ProfessionLeatherEnchantingDependencyTest",
    "ProfessionReconnectRecoveryTest",
    "RecipeKnowledgeCraftingGateTest",
    "RecipeKnowledgeServiceTest",
    "ProfileMigrationDungeonDifficultyV13Test",
}
local passed = 0
local failed = 0

--[[
Runs an existing server fixture as a disposable command-bar module.

Args:
    test_name (string): Source-controlled name of the test script.

Returns:
    boolean: True only if the real Studio test completed successfully.
]]
local function run_fixture(test_name: string): boolean
    local fixture = tests:FindFirstChild(test_name)
    if not fixture or not fixture:IsA("LuaSourceContainer") then
        warn("[Profession Focus] MISSING " .. test_name)
        return false
    end

    local runner = Instance.new("ModuleScript")
    runner.Name = "TEMP_" .. test_name
    runner.Source = fixture.Source .. "\nreturn true\n"
    runner.Parent = server
    local ok, reason = pcall(require, runner)
    runner:Destroy()
    if not ok then
        warn("[Profession Focus] FAIL " .. test_name .. " "
            .. tostring(reason))
        return false
    end
    print("[Profession Focus] PASS " .. test_name)
    return true
end

--[[
Runs the independent real market and selection integration fixtures.

Args:
    None.

Returns:
    nil: Emits per-fixture results and fails the run if any test fails.
]]
local function main()
    for _, name in ipairs(names) do
        if run_fixture(name) then
            passed += 1
        else
            failed += 1
        end
    end
    print(("[Profession Focus] RESULT passed=%d failed=%d total=%d")
        :format(passed, failed, #names))
    assert(failed == 0, "Profession focused acceptance failed")
end

main()
