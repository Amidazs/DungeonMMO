--!strict
-- Unpublished Studio: run only newly changed C4 Elf Scout contracts.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Elf Scout focused test requires an unpublished local Studio place")

local server = game:GetService("ServerScriptService")
local sources = {
    {server.Core.Tests, "C4ElvenScoutNewSkillsTest"},
    {server.Core.Tests, "C4ScoutCriticalPowerToggleTest"},
    {server.Core.Tests, "C4ScoutAccuracyToggleTest"},
    {server.Core.Tests, "C4ScoutInventoryTest"},
    {server.Core.Tests, "C4CatalogueCoverageTest"},
    {server.Core.Tests, "C4ElvenScoutSupportTest"},
    {server.Combat.Tests, "RangerSlowServiceTest"},
}
local passed = 0
local failed = 0

--[[
Runs one original GitHub test in a disposable local Studio module.

Args:
    parent (Instance): Existing genuine test source folder.
    test_name (string): Exact checked-in fixture name.

Returns:
    boolean: True only after an actual Luau execution succeeded.
]]
local function run_fixture(parent: Instance, test_name: string): boolean
    local fixture = parent:FindFirstChild(test_name)
    if not fixture or not fixture:IsA("LuaSourceContainer") then
        warn("[Elf Scout Focus] MISSING " .. test_name)
        return false
    end
    local runner = Instance.new("ModuleScript")
    runner.Name = "TEMP_" .. test_name
    runner.Source = fixture.Source .. "\nreturn true\n"
    -- Preserve the original test's script.Parent-relative require paths.
    runner.Parent = parent
    local ok, reason = pcall(require, runner)
    runner:Destroy()
    if not ok then
        warn("[Elf Scout Focus] FAIL " .. test_name .. ": "
            .. tostring(reason))
        return false
    end
    print("[Elf Scout Focus] PASS " .. test_name)
    return true
end

--[[
Executes only affected rank and combat status regression fixtures.

Args:
    None.

Returns:
    nil: Reports actual Studio pass counts or fails with diagnostics.
]]
local function main()
    for _, entry in ipairs(sources) do
        if run_fixture(entry[1], entry[2]) then
            passed += 1
        else
            failed += 1
        end
    end
    print(("[Elf Scout Focus] RESULT passed=%d failed=%d total=%d")
        :format(passed, failed, #sources))
    assert(failed == 0, "C4 Elf Scout focused acceptance failed")
end

main()
