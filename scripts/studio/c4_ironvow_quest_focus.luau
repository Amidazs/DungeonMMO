--!strict
-- Test-only source runner in an unpublished, disposable local Base.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Original Ironroot quest testing requires unpublished Studio")

local tests = game:GetService("ServerScriptService").Core.Tests

--[[
Runs the real source-owned original Ironroot quest fixture in Studio.

Args:
    None.

Returns:
    nil: Fails unless personal loot/quest/save assertions execute.
]]
local function main()
    local source = assert(tests:FindFirstChild(
        "C4IronvowQuestServiceTest"
    ), "New original Warrior quest fixture missing from Base")
    assert(source:IsA("LuaSourceContainer"),
        "Original Warrior quest test source is not executable")
    local module = Instance.new("ModuleScript")
    module.Name = "C4IronvowQuestFocus_TEMP"
    module.Source = source.Source .. "\nreturn true\n"
    module.Parent = tests
    local ok, result = pcall(require, module)
    module:Destroy()
    assert(ok and result == true,
        "Original Warrior source quest failed: " .. tostring(result))
    print("[Ironvow Quest] VERIFIED_ORDERED_SOURCE_QUEST_PASS")
end

main()
