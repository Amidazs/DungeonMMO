--!strict
-- Genuine unpublished Studio acceptance for Scout environment and gear.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Scout environment tests must run on an unpublished Studio place")

local tests = game:GetService("ServerScriptService").Core.Tests
local test_names = {
    "C4ScoutEnvironmentEquipmentTest",
    "C4ScoutInventoryTest",
    "C4CatalogueCoverageTest",
    "EquipmentServiceTest",
}
local passed = 0
local failed = 0

--[[
Executes an existing checked-in source test without editing its script.

Args:
    name (string): Original test name in ServerScriptService.Core.Tests.

Returns:
    boolean: True if the actual original Studio fixture succeeds.
]]
local function run_fixture(name: string): boolean
    local source = tests:FindFirstChild(name)
    if not source or not source:IsA("LuaSourceContainer") then
        warn("[Scout Environment Focus] MISSING " .. name)
        return false
    end
    local runner = Instance.new("ModuleScript")
    runner.Name = "TEMP_" .. name
    runner.Source = source.Source .. "\nreturn true\n"
    runner.Parent = source.Parent
    local ok, result = pcall(require, runner)
    runner:Destroy()
    if not ok or result ~= true then
        warn("[Scout Environment Focus] FAIL " .. name
            .. " " .. tostring(result))
        return false
    end
    print("[Scout Environment Focus] PASS " .. name)
    return true
end

--[[
Runs only the modified authoritative source and equipment contracts.

Args:
    None.

Returns:
    nil: Prints test counts and fails if any original fixture fails.
]]
local function main()
    for _, name in ipairs(test_names) do
        if run_fixture(name) then
            passed += 1
        else
            failed += 1
        end
    end
    print(("[Scout Environment Focus] RESULT passed=%d "
        .. "failed=%d total=%d"):format(passed, failed, #test_names))
    assert(failed == 0, "Scout environmental acceptance failed")
end

main()
