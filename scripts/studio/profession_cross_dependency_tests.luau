--!strict
-- Unpublished local Studio edit-mode regression for the first broader
-- cross-profession backend milestone. No player DataStore or station UI.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Profession regression requires an unpublished local Studio place")
local SSS = game:GetService("ServerScriptService")
local paths = {
    "ProfessionDefinitionContractTest",
    "ProfessionProfileMigrationTest",
    "ProfessionServiceTest",
    "ProfessionCrossDependencyTest",
    "ProfessionLeatherEnchantingDependencyTest",
    "ProfessionRuntimeRulesTest",
    "ProfessionCraftRequestGuardTest",
    "ProfessionReconnectRecoveryTest",
    "SkinningEligibilityTest",
    "CorpseSkinningRuntimeTest",
    "CorpseSkinningTwoUserTest",
    "RecipeKnowledgeCraftingGateTest",
    "RecipeKnowledgeDefinitionsTest",
    "InventoryServiceTest",
}
local failures = {}
for _, name in ipairs(paths) do
    local source = SSS.Core.Tests:WaitForChild(name)
    local holder = Instance.new("ModuleScript")
    holder.Name = "TEMP_Profession_" .. name
    holder.Source = source.Source .. "\nreturn true\n"
    holder.Parent = SSS
    local ok, reason = pcall(require, holder)
    holder:Destroy()
    if ok then
        print("[Profession Backend Focus] PASS " .. name)
    else
        warn("[Profession Backend Focus] FAIL " .. name
            .. ": " .. tostring(reason))
        table.insert(failures, name .. ": " .. tostring(reason))
    end
end
print(string.format(
    "[Profession Backend Focus] RESULT passed=%d total=%d failed=%d",
    #paths - #failures, #paths, #failures))
assert(#failures == 0, table.concat(failures, " | "))
