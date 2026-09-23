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
    for _, fixture_name in ipairs({
        "C4IronvowQuestServiceTest",
        "C4IronvowAwardServiceTest",
        "C4IronvowFoundationTest",
    }) do
        local source = assert(tests:FindFirstChild(fixture_name),
            "Missing original Warrior server fixture " .. fixture_name)
        assert(source:IsA("LuaSourceContainer"),
            "Original Warrior test source is not executable")
        local module = Instance.new("ModuleScript")
        module.Name = "TEMP_" .. fixture_name
        module.Source = source.Source .. "\nreturn true\n"
        module.Parent = tests
        local ok, result = pcall(require, module)
        module:Destroy()
        assert(ok and result == true,
            "Original Warrior focused fixture failed: " .. fixture_name
                .. ": " .. tostring(result))
        print("[Ironvow Quest] VERIFIED_" .. fixture_name .. "_PASS")
    end
    print("[Ironvow Quest] VERIFIED_QUEST_AWARD_SKILLS_PASS")
end

main()
