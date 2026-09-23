--!strict
-- Run source-rank launch-audit acceptance in an unpublished local Base.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Level-30 launch coverage test requires an unpublished Studio place")

local tests = game:GetService("ServerScriptService").Core.Tests

--[[
Executes the actual source-owned, isolated level-30 reference audit.

Args:
    None.

Returns:
    nil: Fails if the real 18-branch/source-rank audit does not execute.
]]
local function main()
    local source = assert(tests:FindFirstChild(
        "C4Level30LaunchCoverageTest"
    ), "Level-30 audit source test is missing from the Base project")
    assert(source:IsA("LuaSourceContainer"),
        "Level-30 audit must be an executable server test source")
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "C4Level30LaunchCoverage_TEMP"
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = tests
    local ok, result = pcall(require, fixture)
    fixture:Destroy()
    assert(ok and result == true,
        "Level-30 launch audit failed: " .. tostring(result))
    print("[Level 30 Launch] VERIFIED_SOURCE_RANK_AUDIT_PASS")
end

main()
