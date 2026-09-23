--!strict
-- Original first-transfer quest proof and skill-catalogue accounting in Studio.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 source quests must be tested in an unpublished local Studio place")
local tests = game:GetService("ServerScriptService").Core.Tests
local names = {
    "C4OriginalFirstTransferQuestStagesTest",
    "C4FirstTransferSelectionServiceTest",
    "C4ClassPathRulesTest",
    "C4CatalogueCoverageTest",
    "ProfileMigrationQuestAdvancementV8Test",
}
local passed, failed = 0, 0

--[[
Executes the unchanged source-controlled focused server test fixture.

Args:
    name (string): Original source fixture in the correct server folder.

Returns:
    boolean: Actual Studio pass, not a static source or parser check.
]]
local function run_test(name: string): boolean
    local source = tests:FindFirstChild(name)
    if not source or not source:IsA("LuaSourceContainer") then
        warn("[C4 Quest Skill Focus] MISSING " .. name)
        return false
    end
    local fixture = Instance.new("ModuleScript")
    fixture.Name = "TEMP_" .. name
    fixture.Source = source.Source .. "\nreturn true\n"
    fixture.Parent = source.Parent
    local ok, outcome = pcall(require, fixture)
    fixture:Destroy()
    if not ok or outcome ~= true then
        warn("[C4 Quest Skill Focus] FAIL " .. name .. " "
            .. tostring(outcome))
        return false
    end
    print("[C4 Quest Skill Focus] PASS " .. name)
    return true
end

--[[
Runs only original class progression and profile-skill state affected here.

Args:
    None.

Returns:
    nil: Reports all executed fixtures and fails on any test failure.
]]
local function main()
    for _, name in ipairs(names) do
        if run_test(name) then passed += 1 else failed += 1 end
    end
    print(("[C4 Quest Skill Focus] RESULT passed=%d failed=%d total=%d")
        :format(passed, failed, #names))
    assert(failed == 0, "Original class quest/skill proof tests failed")
end

main()
