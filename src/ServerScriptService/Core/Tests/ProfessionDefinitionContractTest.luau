--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")

local ItemDefinitions = require(Shared:WaitForChild("ItemDefinitions"))
local ProfessionDefinitions = require(Shared:WaitForChild("ProfessionDefinitions"))
local ProfessionRecipes = require(Shared:WaitForChild("ProfessionRecipes"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Profession Definition Contract Tests] " .. message, 2)
    end
end

for _, profession_id in ipairs({
    "Mining", "Blacksmithing", "Herbalism", "Alchemy",
    "Skinning", "Leatherworking", "Enchanting",
}) do
    check(ProfessionDefinitions.get(profession_id) ~= nil,
        profession_id .. " definition missing.")
end


local blacksmithing = ProfessionDefinitions.get("Blacksmithing")
local alchemy = ProfessionDefinitions.get("Alchemy")
local mining = ProfessionDefinitions.get("Mining")
local herbalism = ProfessionDefinitions.get("Herbalism")
local skinning = ProfessionDefinitions.get("Skinning")
local leatherworking = ProfessionDefinitions.get("Leatherworking")
local enchanting = ProfessionDefinitions.get("Enchanting")
check(blacksmithing.CraftingMinigameId == "BlacksmithingForge",
    "Blacksmithing minigame hook missing.")
check(alchemy.CraftingMinigameId == "AlchemyBrewing",
    "Alchemy minigame hook missing.")
check(leatherworking.CraftingMinigameId == "LeatherworkingStitching",
    "Leatherworking minigame hook missing.")
check(enchanting.CraftingMinigameId == "EnchantingImbuing",
    "Enchanting minigame hook missing.")
check(mining.CraftingMinigameId == nil
    and herbalism.CraftingMinigameId == nil
    and skinning.CraftingMinigameId == nil,
    "Gathering professions must not masquerade as crafting minigames.")

for _, item_id in ipairs({
    "iron_ore", "iron_bar", "silverleaf", "raw_hide",
    "cured_leather", "tempering_oil", "forging_flux",
    "warding_essence", "warding_rune",
    "deep_iron_ore", "moonpetal", "thick_hide",
    "deep_iron_bar", "moonpetal_extract",
    "reinforced_leather", "resonant_rune",
    "hardened_fittings", "prismatic_catalyst",
    "rune_binding", "prismatic_seal",
    "masterwork_frame", "aetheric_catalyst",
    "masterwork_lining", "arcane_matrix",
}) do
    local definition = ItemDefinitions.get(item_id)
    check(definition ~= nil, item_id .. " missing.")
    check(definition.Stackable == true, item_id .. " must be stackable.")
end

local basic = ItemDefinitions.get("ironbound_gloves")
local tempered = ItemDefinitions.get("tempered_ironbound_gloves")
check(basic and basic.Kind == "Equipment" and basic.Slot == "Gloves", "Ironbound Gloves equipment definition invalid.")
check(tempered and tempered.Kind == "Equipment" and tempered.Slot == "Gloves", "Tempered gloves equipment definition invalid.")
local leather = ItemDefinitions.get("leatherbound_gloves")
local warded = ItemDefinitions.get("warded_leatherbound_gloves")
check(leather and leather.Kind == "Equipment"
    and leather.Slot == "Gloves",
    "Leatherbound Gloves equipment definition invalid.")
check(warded and warded.Kind == "Equipment"
    and warded.Slot == "Gloves"
    and warded.Rarity == "Rare",
    "Warded leather gloves equipment definition invalid.")

local allowed = {}
for _, class_id in ipairs(basic.AllowedBaseClasses or {}) do
    allowed[class_id] = true
end
check(allowed.Fighter and allowed.Mage and allowed.Ranger and allowed.Rogue,
    "Foundation crafted gloves must stay usable by every base class.")

for _, recipe_id in ipairs({
    "smelt_iron_bar",
    "forge_ironbound_gloves",
    "distill_tempering_oil",
    "temper_ironbound_gloves",
    "cure_raw_hide",
    "stitch_leatherbound_gloves",
    "distill_warding_essence",
    "inscribe_warding_rune",
    "enchant_leatherbound_gloves",
}) do
    check(ProfessionRecipes.get(recipe_id) ~= nil, recipe_id .. " missing.")
end

local basic_recipe = ProfessionRecipes.get("forge_ironbound_gloves")
local tempered_recipe = ProfessionRecipes.get("temper_ironbound_gloves")
local leather_recipe = ProfessionRecipes.get("stitch_leatherbound_gloves")
local enchant_recipe = ProfessionRecipes.get("enchant_leatherbound_gloves")
check(basic_recipe.RequiredLevel == 1,
    "Basic gloves must remain entry-level and self-sufficient.")
check(tempered_recipe.RequiredLevel == 2,
    "Tempered gloves must demonstrate recipe progression.")
check(leather_recipe.RequiredLevel == 1
    and leather_recipe.StationId == "Leatherworking",
    "Leatherworking base equipment recipe must use its own station.")
check(enchant_recipe.RequiredLevel == 2
    and enchant_recipe.StationId == "Enchanting",
    "Advanced enchant must demonstrate Enchanting progression.")
--[[
Returns the one-based position of a recipe in a station list.

Args:
    recipes (any): Ordered station recipe collection.
    recipe_id (string): Stable recipe identifier to locate.

Returns:
    number?: One-based recipe position, or nil when absent.
]]
local function station_index(
    recipes: any,
    recipe_id: string
): number?
    for index, recipe in ipairs(recipes) do
        if recipe.Id == recipe_id then
            return index
        end
    end

    return nil
end

local leather_station = ProfessionRecipes.for_station("Leatherworking")
local enchanting_station = ProfessionRecipes.for_station("Enchanting")
local cure_index = station_index(leather_station, "cure_raw_hide")
local stitch_index =
    station_index(leather_station, "stitch_leatherbound_gloves")
local thick_index = station_index(leather_station, "cure_thick_hide")
local master_lining_index =
    station_index(leather_station, "stitch_masterwork_lining")
check(
    cure_index ~= nil
        and stitch_index ~= nil
        and thick_index ~= nil
        and master_lining_index ~= nil
        and cure_index < stitch_index
        and stitch_index < thick_index
        and thick_index < master_lining_index,
    "Leatherworking station preserves foundation then advanced progression."
)

local rune_index =
    station_index(enchanting_station, "inscribe_warding_rune")
local gloves_index =
    station_index(enchanting_station, "enchant_leatherbound_gloves")
local resonant_index =
    station_index(enchanting_station, "inscribe_resonant_rune")
local matrix_index =
    station_index(enchanting_station, "inscribe_arcane_matrix")
check(
    rune_index ~= nil
        and gloves_index ~= nil
        and resonant_index ~= nil
        and matrix_index ~= nil
        and rune_index < gloves_index
        and gloves_index < resonant_index
        and resonant_index < matrix_index,
    "Enchanting station preserves foundation then advanced progression."
)

local needs_oil = false
for _, input in ipairs(tempered_recipe.Inputs) do
    if input.ItemId == "tempering_oil" then
        needs_oil = true
    end
end
check(needs_oil, "Tempered gloves must require the Alchemy reagent.")

print(string.format("[Profession Definition Contract Tests] PASS: %d assertions.", assertions))
