--!strict
-- Focused unpublished acceptance for original C4 starter-class identity.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Starter identity acceptance requires unpublished Studio")

local tests = game:GetService("ServerScriptService").Core.Tests
local names = {
    "IdentityServiceTest",
    "MageIdentityServiceTest",
    "RangerIdentityServiceTest",
}
local passed = 0
local failed = 0

--[[
Executes one source-controlled identity fixture in its normal context.

Args:
    name (string): Exact test name in ServerScriptService.Core.Tests.

Returns:
    boolean: True only if the original fixture runs successfully.
]]
local function run_fixture(name: string): boolean
    local source = tests:FindFirstChild(name)
    if not source or not source:IsA("LuaSourceContainer") then
        warn("[C4 Starter Identity Focus] MISSING " .. name)
        return false
    end
    local runner = Instance.new("ModuleScript")
    runner.Name = "TEMP_" .. name
    runner.Source = source.Source .. "\nreturn true\n"
    runner.Parent = source.Parent
    local ok, result = pcall(require, runner)
    runner:Destroy()
    if not ok or result ~= true then
        warn("[C4 Starter Identity Focus] FAIL "
            .. name .. " " .. tostring(result))
        return false
    end
    print("[C4 Starter Identity Focus] PASS " .. name)
    return true
end

--[[
Runs only identity tests affected by Fighter/Mystic-only fresh creation.

Args:
    None.

Returns:
    nil: Fails if any fresh or legacy identity contract regresses.
]]
local function main()
    for _, name in ipairs(names) do
        if run_fixture(name) then
            passed += 1
        else
            failed += 1
        end
    end
    print(("[C4 Starter Identity Focus] RESULT passed=%d "
        .. "failed=%d total=%d"):format(passed, failed, #names))
    assert(failed == 0, "Original C4 starter identity acceptance failed")
end

main()
