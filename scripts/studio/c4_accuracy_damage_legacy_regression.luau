--!strict
-- The existing non-evasive melee/critical damage contract must not regress.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Damage regression may run only in an unpublished Studio place")

local tests = game:GetService("ServerScriptService").Combat.Tests
local source = assert(tests:FindFirstChild("DamageServiceTest"),
    "Original source-controlled DamageServiceTest is missing")
assert(source:IsA("LuaSourceContainer"),
    "Original damage regression is not a Luau source script")

--[[
Executes the unmodified checked-in legacy damage fixture in place.

Args:
    None.

Returns:
    nil: Raises on failed regression and emits the actual test result.
]]
local function main()
    local runner = Instance.new("ModuleScript")
    runner.Name = "TEMP_AccuracyLegacyDamageRegression"
    runner.Source = source.Source .. "\nreturn true\n"
    runner.Parent = tests
    local ok, result = pcall(require, runner)
    runner:Destroy()
    assert(ok and result == true,
        "[C4 Accuracy Damage Regression] FAIL " .. tostring(result))
    print("[C4 Accuracy Damage Regression] PASS")
end

main()
