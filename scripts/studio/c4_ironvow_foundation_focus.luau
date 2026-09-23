--!strict
-- Run only the pending original Human Warrior skill-foundation contract.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Ironvow foundation tests require unpublished local Base Studio")

local tests = game:GetService("ServerScriptService").Core.Tests

--[[
Runs the GitHub-owned original Warrior server fixture in disposable Studio.

Args:
    None.

Returns:
    nil: Asserts the test executes fully without enabling an unbuilt quest.
]]
local function main()
    local source = assert(tests:FindFirstChild(
        "C4IronvowFoundationTest"
    ), "Original Warrior foundation fixture was not built into Base")
    assert(source:IsA("LuaSourceContainer"),
        "Original Warrior fixture must contain executable Luau source")
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "C4IronvowFoundation_TEMP"
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = tests
    local ok, result = pcall(require, fixture)
    fixture:Destroy()
    assert(ok and result == true,
        "Original Warrior skill foundation rejected: " .. tostring(result))
    print("[Ironvow Foundation] VERIFIED_FOUNDATION_PASS")
end

main()
