--!strict
-- Unpublished TEMP local Studio edit-mode backend contract matrix.
-- Each copied test retains its original assertions; require in an isolated
-- ModuleScript to make script execution errors observable as failures.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Gameplay backend matrix requires an unpublished TEMP place")
local SSS = game:GetService("ServerScriptService")
-- DefensiveCombatIntegrationTest needs a running Play-mode TrainingMarauder;
-- run it in the live Dungeon regression rather than a stopped edit DataModel.
local tests = {
    {"Combat", "BasicAttackTimingRulesTest"},
    {"Combat", "DefenseServiceTest"},
    {"Combat", "DodgeDirectionRulesTest"},
    {"Combat", "DodgePriorityStateRulesTest"},
    {"Combat", "DodgeSweptClearanceTest"},
    {"Combat", "DamageServiceTest"},
    {"Combat", "StaminaServiceTest"},
    {"Combat", "MeleeHitServiceTest"},
    {"Combat", "CombatLifecycleStateTest"},
    {"Combat", "OptionalBossAttackRulesTest"},
    {"Core", "DungeonDifficultyDefinitionsTest"},
    {"Core", "DungeonDifficultyProgressionServiceTest"},
    {"Core", "DungeonDifficultySessionPersistenceTest"},
    {"Core", "DungeonDifficultyTuningTest"},
    {"Core", "DungeonDifficultyInstanceDirectorTest"},
    {"Core", "RewardServiceTest"},
    {"Core", "RareSkillBookRewardTest"},
    {"Core", "CompletionRewardPresentationTest"},
    {"Core", "DungeonOptionalBossRecoveryTest"},
    {"Dungeon", "DungeonDifficultyCompletionUnlockTest"},
    {"Dungeon", "DungeonEnemyDifficultyScalingTest"},
    {"Dungeon", "AutomaticFreeReviveTest"},
    {"Dungeon", "DungeonDeathServiceTest"},
    {"Dungeon", "DungeonRecoveryRulesTest"},
    {"Dungeon", "CompletionServiceTest"},
    {"Dungeon", "DungeonOptionalBossRewardTest"},
    {"Dungeon", "DungeonPresentationLayerTest"},
    {"Dungeon", "DungeonAdmissionTest"},
    {"Dungeon", "DungeonEncounterBindingsTest"},
    {"Dungeon", "DungeonEncounterFlowTest"},
}
local failures = {}
for _, descriptor in ipairs(tests) do
    local group, name = descriptor[1], descriptor[2]
    local script_source = SSS:WaitForChild(group)
        :WaitForChild("Tests"):WaitForChild(name)
    assert(script_source:IsA("LuaSourceContainer"),
        "Missing original gameplay test " .. group .. "/" .. name)
    local holder = Instance.new("ModuleScript")
    holder.Name = "TEMP_Phase4_" .. name
    holder.Source = script_source.Source .. "\nreturn true\n"
    holder.Parent = SSS
    local ok, reason = pcall(require, holder)
    holder:Destroy()
    if ok then
        print("[Phase4 Gameplay Matrix] PASS " .. group .. "/" .. name)
    else
        local failure = group .. "/" .. name .. ": " .. tostring(reason)
        table.insert(failures, failure)
        warn("[Phase4 Gameplay Matrix] FAIL " .. failure)
    end
end
print(string.format("[Phase4 Gameplay Matrix] RESULT passed=%d total=%d failed=%d",
    #tests - #failures, #tests, #failures))
assert(#failures == 0, "[Phase4 Gameplay Matrix] FAILED: "
    .. table.concat(failures, " | "))
print("[Phase4 Gameplay Matrix] ALL_SELECTED_BACKEND_TESTS_PASS")
