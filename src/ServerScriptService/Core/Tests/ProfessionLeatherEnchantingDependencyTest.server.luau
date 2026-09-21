--!strict
-- Backend-only acceptance for Skinning -> Leatherworking and the
-- Blacksmithing/Alchemy/Leatherworking -> Enchanting dependency chain.
-- Uses the real Profile/Inventory/Profession services with in-memory storage.
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Core = SSS.Core
local Shared = RS.Core.Shared

local Adapter = require(Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Core.Services.ProfileService)
local Inventory = require(Core.Services.InventoryService)
local Professions = require(Core.Services.ProfessionService)
local Definitions = require(Shared.ProfessionDefinitions)
local Recipes = require(Shared.ProfessionRecipes)

local assertions = 0
local function check(ok: boolean, message: string)
    assertions += 1
    assert(ok, "[Leather/Enchant Dependency] " .. message)
end

local adapter = Adapter.new()
local profiles = Profiles.new(adapter)
local user_id = 67101
check(profiles:load(user_id), "fresh disposable profile loads")
local inventory = Inventory.new(profiles)
local professions = Professions.new(profiles, inventory)

local function qty(item_id: string): number
    return Inventory.count_item(
        assert(profiles:get_character(user_id, 1)), item_id)
end

local function gather(profession_id: string, item_id: string, amount: number)
    for _ = 1, amount do
        local result = professions:gather(user_id, {
            ProfessionId = profession_id,
            ItemId = item_id,
            Quantity = 1,
            XP = 8,
        })
        check(result.ok, profession_id .. " gather must succeed")
    end
end

local function craft(recipe_id: string): any
    local prepared = professions:prepare_craft(user_id, recipe_id)
    check(prepared.ok, recipe_id .. " must prepare")
    local result = professions:complete_craft(
        user_id,
        recipe_id,
        Professions.foundation_success_outcome(prepared.minigame_id)
    )
    check(result.ok, recipe_id .. " must complete")
    return result
end

check(Definitions.get("Skinning").Kind == "Gathering"
    and Definitions.get("Leatherworking").Pair == "Skinning"
    and Definitions.get("Enchanting").Kind == "Creation",
    "new professions use the existing shared progression framework")

local cure = assert(Recipes.get("cure_raw_hide"))
local stitch = assert(Recipes.get("stitch_leatherbound_gloves"))
local essence = assert(Recipes.get("distill_warding_essence"))
local rune = assert(Recipes.get("inscribe_warding_rune"))
local enchant = assert(Recipes.get("enchant_leatherbound_gloves"))
check(cure.ProfessionId == "Leatherworking"
    and stitch.ProfessionId == "Leatherworking"
    and rune.ProfessionId == "Enchanting"
    and enchant.RequiredLevel == 2,
    "Leatherworking/Enchanting recipes are registered at expected levels")

local empty = professions:prepare_craft(user_id, cure.Id)
check(not empty.ok and empty.reason == "MissingMaterials",
    "Leatherworking cannot fabricate hide or Alchemy reagent")

-- Supply enough ordinary gathered resources for the full dependency chain.
gather("Mining", "iron_ore", 8)
gather("Herbalism", "silverleaf", 9)
gather("Skinning", "raw_hide", 3)
check(qty("raw_hide") == 3 and qty("silverleaf") == 9,
    "Skinning and Herbalism materials enter authoritative inventory")

-- Four Blacksmithing bars are needed across Leatherworking/Alchemy/Enchanting.
for _ = 1, 4 do
    craft("smelt_iron_bar")
end
check(qty("iron_bar") == 4 and qty("iron_ore") == 0,
    "Blacksmithing produces exact bars needed by other professions")

-- Alchemy contributes curing oil; Leatherworking produces the base gear.
craft("distill_tempering_oil")
craft(cure.Id)
check(qty("raw_hide") == 0
    and qty("tempering_oil") == 0
    and qty("cured_leather") == 1,
    "Leatherworking consumes Skinning hide plus Alchemy oil atomically")
craft(stitch.Id)
check(qty("leatherbound_gloves") == 1
    and qty("cured_leather") == 0
    and qty("iron_bar") == 3,
    "Leatherworking equipment consumes its cured leather and smith bar")

-- Enchanting requires Alchemy reagents which themselves need smith input.
craft("distill_forging_flux")
craft(essence.Id)
check(qty("warding_essence") == 1
    and qty("forging_flux") == 0,
    "Alchemy chains forging flux into warding essence")
craft(rune.Id)
check(qty("warding_rune") == 1
    and qty("warding_essence") == 0
    and qty("iron_bar") == 1,
    "Enchanting rune consumes Alchemy essence and another smith bar")

local snapshot = professions:build_snapshot(user_id)
check(snapshot.ok
    and snapshot.Professions.Leatherworking.Level >= 2
    and snapshot.Professions.Enchanting.Level >= 2
    and snapshot.Recipes[enchant.Id].Unlocked == true,
    "profession XP from real crafts unlocks the level-two enchant recipe")

-- Final enchant also requires a second Alchemy flux.
craft("distill_forging_flux")
check(qty("forging_flux") == 1 and qty("iron_bar") == 0,
    "final cross-profession reagent is created exactly once")

-- Equipped source gear cannot be consumed.
check(profiles:mutate(user_id, function(profile: any)
    profile.Characters.Slot1.Equipment.Gloves = "leatherbound_gloves"
end), "fixture equips the Leatherworking output")
local equipped = professions:prepare_craft(user_id, enchant.Id)
check(not equipped.ok and equipped.reason == "IngredientEquipped"
    and qty("leatherbound_gloves") == 1
    and qty("warding_rune") == 1
    and qty("forging_flux") == 1,
    "Enchanting cannot consume equipped gear or partial ingredients")
check(profiles:mutate(user_id, function(profile: any)
    profile.Characters.Slot1.Equipment.Gloves = nil
end), "fixture unequips source gear")

local prepared = professions:prepare_craft(user_id, enchant.Id)
check(prepared.ok and prepared.minigame_id == "EnchantingImbuing",
    "Enchanting uses its own existing minigame identity")
local wrong = professions:complete_craft(user_id, enchant.Id, {
    Succeeded = true,
    MinigameId = "LeatherworkingStitching",
})
check(not wrong.ok and wrong.reason == "MinigameMismatch"
    and qty("warding_rune") == 1
    and qty("forging_flux") == 1,
    "fabricated wrong-profession completion cannot consume ingredients")

local result = professions:complete_craft(
    user_id, enchant.Id,
    Professions.foundation_success_outcome(prepared.minigame_id)
)
check(result.ok
    and result.output_item_id == "warded_leatherbound_gloves",
    "server completes the registered multi-profession equipment output")
check(qty("warded_leatherbound_gloves") == 1
    and qty("leatherbound_gloves") == 0
    and qty("warding_rune") == 0
    and qty("forging_flux") == 0,
    "successful enchant consumes every dependency exactly once")

local duplicate = professions:craft(user_id, enchant.Id)
check(not duplicate.ok and duplicate.reason == "MissingMaterials"
    and qty("warded_leatherbound_gloves") == 1,
    "retry without inputs cannot duplicate enchanted equipment")

check(profiles:save(user_id, "LeatherEnchantingDependencyTest"),
    "extended profession state persists")
local recovered = Profiles.new(adapter)
check(recovered:load(user_id), "saved profile reloads")
local character = assert(recovered:get_character(user_id, 1))
check(Inventory.count_item(character, "warded_leatherbound_gloves") == 1
    and character.Professions.Leatherworking.Level >= 2
    and character.Professions.Enchanting.Level >= 2,
    "reloaded character keeps output and both profession progressions")

print(string.format(
    "[Leather/Enchant Dependency] PASS: %d assertions.", assertions))
