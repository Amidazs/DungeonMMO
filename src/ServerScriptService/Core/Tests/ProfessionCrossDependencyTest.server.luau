--!strict
-- Backend-only, actual inventory/profile mutation test of two-way
-- Blacksmithing -> Alchemy -> Blacksmithing dependencies.
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Core = SSS.Core
local Adapter = require(Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Core.Services.ProfileService)
local Inventory = require(Core.Services.InventoryService)
local Professions = require(Core.Services.ProfessionService)
local Recipes = require(RS.Core.Shared.ProfessionRecipes)
local Items = require(RS.Core.Shared.ItemDefinitions)

local checks = 0
local function check(ok: boolean, label: string)
    checks += 1
    assert(ok, "[Profession Cross Dependency] " .. label)
end
local source = Adapter.new()
local profiles = Profiles.new(source)
local user_id = 66081
check(profiles:load(user_id), "disposable character loads")
local inventory = Inventory.new(profiles)
local crafting = Professions.new(profiles, inventory)
local function quantity(id: string): number
    return Inventory.count_item(
        assert(profiles:get_character(user_id, 1)), id)
end
local function craft(recipe_id: string): any
    local prepared = crafting:prepare_craft(user_id, recipe_id)
    check(prepared.ok, recipe_id .. " must prepare")
    local result = crafting:complete_craft(
        user_id, recipe_id,
        Professions.foundation_success_outcome(prepared.minigame_id))
    check(result.ok, recipe_id .. " must commit")
    return result
end
local smelt = assert(Recipes.get("smelt_iron_bar"))
local flux = assert(Recipes.get("distill_forging_flux"))
local runic = assert(Recipes.get("forge_runic_ironbound_gloves"))
check(smelt.ProfessionId == "Blacksmithing"
    and flux.ProfessionId == "Alchemy"
    and runic.ProfessionId == "Blacksmithing"
    and flux.Inputs[2].ItemId == "iron_bar"
    and runic.Inputs[3].ItemId == "forging_flux",
    "recipes must form two-way cross-profession dependency")
check(Items.get("forging_flux") ~= nil
    and Items.get("runic_ironbound_gloves") ~= nil
    and Items.get("runic_ironbound_gloves").Kind == "Equipment",
    "new reagent and equipable output are registered")
check(not crafting:prepare_craft(
    user_id, runic.Id).ok,
    "runic gloves cannot be made with an empty inventory")
for _ = 1, 10 do
    check(crafting:gather(user_id, {
        ProfessionId = "Mining", ItemId = "iron_ore",
        Quantity = 1, XP = 8,
    }).ok, "ore gather must use existing authoritative service")
end
for _ = 1, 5 do craft(smelt.Id) end
check(quantity("iron_bar") == 5
    and quantity("iron_ore") == 0,
    "smelting consumes ore once and yields exactly five bars")
craft("forge_ironbound_gloves")
check(quantity("ironbound_gloves") == 1
    and quantity("iron_bar") == 2,
    "basic gloves consume three of the forged bars")
local missing = crafting:prepare_craft(user_id, runic.Id)
check(not missing.ok and missing.reason == "MissingMaterials"
    and quantity("ironbound_gloves") == 1
    and quantity("iron_bar") == 2,
    "no flux must prevent runic forging without eating ingredients")
for _ = 1, 2 do
    check(crafting:gather(user_id, {
        ProfessionId = "Herbalism", ItemId = "silverleaf",
        Quantity = 1, XP = 8,
    }).ok, "herb gather must use authoritative service")
end
craft(flux.Id)
check(quantity("iron_bar") == 1
    and quantity("silverleaf") == 0
    and quantity("forging_flux") == 1,
    "alchemist consumes a smith-made bar and gathered herbs for flux")
local snapshot = crafting:build_snapshot(user_id)
check(snapshot.ok
    and snapshot.Recipes[runic.Id].Unlocked
    and snapshot.Recipes[flux.Id].Unlocked,
    "normal profession snapshot exposes two-way recipes")
check(profiles:mutate(user_id, function(profile: any)
    profile.Characters.Slot1.Equipment.Gloves = "ironbound_gloves"
end), "test character equips the ingredient")
local denied = crafting:craft(user_id, runic.Id)
check(not denied.ok and denied.reason == "IngredientEquipped"
    and quantity("ironbound_gloves") == 1
    and quantity("forging_flux") == 1
    and quantity("iron_bar") == 1,
    "equipped ingredient rejection preserves all materials")
check(profiles:mutate(user_id, function(profile: any)
    profile.Characters.Slot1.Equipment.Gloves = nil
end), "test character unequips the ingredient")
local ready = crafting:prepare_craft(user_id, runic.Id)
check(ready.ok and ready.minigame_id == "BlacksmithingForge",
    "final cross-profession craft uses the smith minigame contract")
local mismatch = crafting:complete_craft(user_id, runic.Id, {
    Succeeded = true, MinigameId = "AlchemyBrewing",
})
check(not mismatch.ok and mismatch.reason == "MinigameMismatch"
    and quantity("forging_flux") == 1,
    "wrong minigame cannot consume Alchemy's ingredient")
local result = crafting:complete_craft(user_id, runic.Id,
    Professions.foundation_success_outcome(ready.minigame_id))
check(result.ok and result.output_item_id
    == "runic_ironbound_gloves",
    "server commits the actual runic output")
check(quantity("runic_ironbound_gloves") == 1
    and quantity("ironbound_gloves") == 0
    and quantity("iron_bar") == 0
    and quantity("forging_flux") == 0,
    "successful craft consumes each profession input exactly once")
local replay = crafting:craft(user_id, runic.Id)
check(not replay.ok and replay.reason == "MissingMaterials"
    and quantity("runic_ironbound_gloves") == 1,
    "repeating craft without reagents cannot duplicate equipment")
check(profiles:save(user_id, "ProfessionCrossDependencyTest"),
    "completed cross-profession craft persists")
local recovered_profiles = Profiles.new(source)
check(recovered_profiles:load(user_id),
    "saved character can reload in fresh profile service")
check(Inventory.count_item(
    assert(recovered_profiles:get_character(user_id, 1)),
    "runic_ironbound_gloves") == 1,
    "reloaded inventory retains exactly one finished item")
print(string.format(
    "[Profession Cross Dependency] PASS: %d assertions.", checks
))
