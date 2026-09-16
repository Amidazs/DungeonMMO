--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Core = ServerScriptService:WaitForChild("Core")
local Adapters = Core:WaitForChild("Adapters")
local Services = Core:WaitForChild("Services")

local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local ProfileService = require(Services:WaitForChild("ProfileService"))
local InventoryService = require(Services:WaitForChild("InventoryService"))
local ProfessionService = require(Services:WaitForChild("ProfessionService"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Profession Service Tests] " .. message, 2)
    end
end

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
assert(profiles:load(4101))
local inventory = InventoryService.new(profiles)
local professions = ProfessionService.new(profiles, inventory)

local no_materials = professions:prepare_craft(4101, "smelt_iron_bar")
check(no_materials.ok == false and no_materials.reason == "MissingMaterials", "Prepare must fail cleanly without materials.")
check(InventoryService.count_item(assert(profiles:get_character(4101, 1)), "iron_bar") == 0, "Failed prepare must not create output.")

local invalid_node = professions:gather(4101, {ProfessionId = "Missing", ItemId = "iron_ore", Quantity = 1, XP = 8})
check(invalid_node.ok == false, "Unknown profession node must fail closed.")

for _ = 1, 6 do
    local result = professions:gather(4101, {
        ProfessionId = "Mining",
        ItemId = "iron_ore",
        Quantity = 1,
        XP = 8,
    })
    check(result.ok == true, "Mining gather must succeed.")
end

local character = assert(profiles:get_character(4101, 1))
check(InventoryService.count_item(character, "iron_ore") == 6, "Six gathers must produce six Iron Ore.")

local prepared_smelt = professions:prepare_craft(4101, "smelt_iron_bar")
check(prepared_smelt.ok == true, "Smelt must prepare with materials present.")
check(prepared_smelt.minigame_id == "BlacksmithingForge", "Prepared Blacksmithing craft must identify its minigame hook.")

local failed_outcome = professions:complete_craft(4101, "smelt_iron_bar", {
    Succeeded = false,
    MinigameId = "BlacksmithingForge",
    Score = 0,
})
check(failed_outcome.ok == false and failed_outcome.reason == "MinigameNotCompleted", "Failed minigame outcome must reject crafting.")
character = assert(profiles:get_character(4101, 1))
check(InventoryService.count_item(character, "iron_ore") == 6, "Failed minigame must not consume ingredients.")

local mismatched = professions:complete_craft(4101, "smelt_iron_bar", {
    Succeeded = true,
    MinigameId = "AlchemyBrewing",
    Score = 1,
})
check(mismatched.ok == false and mismatched.reason == "MinigameMismatch", "Wrong minigame result must fail closed.")

for _ = 1, 3 do
    local prepared = professions:prepare_craft(4101, "smelt_iron_bar")
    check(prepared.ok == true, "Each Iron Bar smelt must prepare.")
    local result = professions:complete_craft(
        4101,
        "smelt_iron_bar",
        ProfessionService.foundation_success_outcome(prepared.minigame_id)
    )
    check(result.ok == true, "Iron Bar completion must succeed.")
end

local snapshot = professions:build_snapshot(4101)
check(snapshot.Professions.Blacksmithing.Level == 2, "Three smelts must unlock Blacksmithing level 2.")
check(snapshot.Recipes.temper_ironbound_gloves.Unlocked == true, "Tempered recipe must unlock at level 2.")
check(snapshot.Professions.Blacksmithing.CraftingMinigameId == "BlacksmithingForge", "Snapshot must expose Blacksmithing minigame identity.")

local basic_gloves = professions:craft(4101, "forge_ironbound_gloves")
check(basic_gloves.ok == true, "Basic gloves must be craftable without Alchemy.")

local before_failed_temper = assert(profiles:get_character(4101, 1))
local basic_before = InventoryService.count_item(before_failed_temper, "ironbound_gloves")
local failed_temper = professions:craft(4101, "temper_ironbound_gloves")
check(failed_temper.ok == false and failed_temper.reason == "MissingMaterials", "Tempered recipe must require its cross-profession materials.")
local after_failed_temper = assert(profiles:get_character(4101, 1))
check(InventoryService.count_item(after_failed_temper, "ironbound_gloves") == basic_before, "Rejected craft must preserve input equipment atomically.")

for _ = 1, 3 do
    local herb = professions:gather(4101, {
        ProfessionId = "Herbalism",
        ItemId = "silverleaf",
        Quantity = 1,
        XP = 8,
    })
    check(herb.ok == true, "Herbalism gather must succeed.")
end
local oil_prepare = professions:prepare_craft(4101, "distill_tempering_oil")
check(oil_prepare.ok == true and oil_prepare.minigame_id == "AlchemyBrewing", "Alchemy prepare must identify the brewing minigame hook.")
local oil = professions:complete_craft(
    4101,
    "distill_tempering_oil",
    ProfessionService.foundation_success_outcome(oil_prepare.minigame_id)
)
check(oil.ok == true, "Alchemy must create Tempering Oil from gathered Silverleaf.")

-- Add one bar for the tempered recipe; the basic gloves and oil already exist.
assert(inventory:add_item(4101, "iron_bar", 1).ok)
assert(profiles:mutate(4101, function(profile: any)
    profile.Characters.Slot1.Equipment.Gloves = "ironbound_gloves"
end))
local equipped_reject = professions:craft(4101, "temper_ironbound_gloves")
check(equipped_reject.ok == false and equipped_reject.reason == "IngredientEquipped", "Crafting must not consume currently equipped gear.")
assert(profiles:mutate(4101, function(profile: any)
    profile.Characters.Slot1.Equipment.Gloves = nil
end))
local tempered = professions:craft(4101, "temper_ironbound_gloves")
check(tempered.ok == true, "Cross-profession tempered gloves must craft when all requirements are met.")

character = assert(profiles:get_character(4101, 1))
check(InventoryService.count_item(character, "tempered_ironbound_gloves") == 1, "Tempered gloves output must enter Inventory.")

print(string.format("[Profession Service Tests] PASS: %d assertions.", assertions))
