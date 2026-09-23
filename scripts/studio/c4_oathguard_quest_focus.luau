--!strict
-- Real profile/rank fixtures for the independent original Human Knight.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Oathguard quest and award focus must run in unpublished Base Studio")
local tests = game:GetService("ServerScriptService").Core.Tests

--[[
Runs the original Knight source quest, class award and rank-gate suites.

Args:
    None.

Returns:
    nil: Reports one genuine suite result only after all tests execute.
]]
local function main()
    for _, name in ipairs({
        "C4OathguardQuestAwardTest", "C4OathguardFoundationTest",
    }) do
        local source = assert(tests:FindFirstChild(name),
            "Missing source-controlled Knight quest fixture " .. name)
        assert(source:IsA("LuaSourceContainer"),
            "Knight fixture must contain executable Luau")
        local module = Instance.new("ModuleScript")
        module.Name = "TEMP_" .. name
        module.Source = source.Source .. "\nreturn true\n"
        module.Parent = tests
        local ok, outcome = pcall(require, module)
        module:Destroy()
        assert(ok and outcome == true,
            "Oathguard fixture failed: " .. name .. ": " .. tostring(outcome))
        print("[Oathguard Focus] VERIFIED_" .. name .. "_PASS")
    end
    print("[Oathguard Focus] VERIFIED_QUEST_AWARD_RANKS_PASS")
end

main()
