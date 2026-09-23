--!strict
-- Source-ranked dungeon lockpicking and focused original C4 coverage.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Lockpicking acceptance must run in an unpublished Studio place")

local tests = game:GetService("ServerScriptService").Core.Tests
local names = {
    "C4ScoutLockpickingTest",
    "C4ScoutInventoryTest",
    "C4CatalogueCoverageTest",
}
local successes = 0
local failures = 0

--[[
Runs an original checked-in test beside its real require dependencies.

Args:
    name (string): Exact original LuaSourceContainer test name.

Returns:
    boolean: True only after actual Luau execution succeeded.
]]
local function run_fixture(name: string): boolean
    local source = tests:FindFirstChild(name)
    if not source or not source:IsA("LuaSourceContainer") then
        warn("[Scout Lock Focus] MISSING " .. name)
        return false
    end
    local runner = Instance.new("ModuleScript")
    runner.Name = "TEMP_" .. name
    runner.Source = source.Source .. "\nreturn true\n"
    runner.Parent = source.Parent
    local ok, reason = pcall(require, runner)
    runner:Destroy()
    if not ok then
        warn("[Scout Lock Focus] FAIL " .. name .. " "
            .. tostring(reason))
        return false
    end
    print("[Scout Lock Focus] PASS " .. name)
    return true
end

--[[
Executes only the new secure lock interaction and exact C4 source checks.

Args:
    None.

Returns:
    nil: Fails on any unexecuted or failed fixture, reporting counts.
]]
local function main()
    for _, name in ipairs(names) do
        if run_fixture(name) then
            successes += 1
        else
            failures += 1
        end
    end
    print(("[Scout Lock Focus] RESULT passed=%d failed=%d total=%d")
        :format(successes, failures, #names))
    assert(failures == 0, "Scout lockpicking source acceptance failed")
end

main()
