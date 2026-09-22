--!strict
-- Only contracts directly changed by class/skill visibility and level gates.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Skill contract checks require an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")

local TESTS = {
    "QuestDefinitionsTest",
    "RogueAdvancementTest",
    "TrainerCataloguesTest",
    "ProgressionSnapshotBuilderTest",
    "SkillProgressionServiceTest",
}

-- Args:
--   name (string): Existing directly affected service test module.
-- Returns:
--   nil: Executes one unchanged test and propagates its failure.
local function run_contract(name: string)
    local source = SSS.Core.Tests:WaitForChild(name)
    local runner = Instance.new("ModuleScript")
    runner.Name = "TEMP_" .. name
    runner.Source = source.Source .. "\nreturn true\n"
    runner.Parent = SSS

    local ok, reason = pcall(require, runner)
    runner:Destroy()
    if not ok then
        warn("[Mastery Affected Contracts] FAIL " .. name)
        error(reason)
    end
    print("[Mastery Affected Contracts] PASS " .. name)
end

-- Args:
--   None.
-- Returns:
--   nil: Checks only the skill/class components modified by mastery.
local function main()
    for _, name in ipairs(TESTS) do
        run_contract(name)
    end
    print(string.format(
        "[Mastery Affected Contracts] RESULT passed=%d total=%d failed=0",
        #TESTS, #TESTS
    ))
end

main()
