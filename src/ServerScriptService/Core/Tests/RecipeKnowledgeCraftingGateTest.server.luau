--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Adapters = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Adapters")
local Services = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Services")

local ProfessionDefinitions = require(Shared:WaitForChild("ProfessionDefinitions"))
local InMemoryProfileAdapter = require(Adapters:WaitForChild("InMemoryProfileAdapter"))
local ProfileService = require(Services:WaitForChild("ProfileService"))
local InventoryService = require(Services:WaitForChild("InventoryService"))
local ProfessionService = require(Services:WaitForChild("ProfessionService"))
local RecipeKnowledgeService = require(
    Services:WaitForChild("RecipeKnowledgeService")
)

local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Recipe Knowledge Crafting Gate Tests] " .. message, 2)
    end
end

local level_two = assert(ProfessionDefinitions.xp_to_next(1))

local profiles = ProfileService.new(InMemoryProfileAdapter.new())
assert(profiles:load(8601))
assert(profiles:load(8602))
local inventory = InventoryService.new(profiles)
local professions = ProfessionService.new(profiles, inventory)
local knowledge = RecipeKnowledgeService.new(profiles, inventory)
assert(professions:choose_profession(8601, "Blacksmithing").ok)
assert(professions:choose_profession(8602, "Alchemy").ok)

assert(profiles:mutate(8601, function(profile: any)
    local character = profile.Characters.Slot1
    character.Professions.Blacksmithing.XP = level_two
end))
assert(profiles:mutate(8602, function(profile: any)
    profile.Characters.Slot1.Professions.Alchemy.XP = level_two
end))

assert(inventory:add_item(8601, "iron_bar", 6).ok)
assert(inventory:add_item(8602, "silverleaf", 6).ok)
assert(inventory:add_item(8601, "blacksmith_iron_guard_blueprint", 1).ok)
assert(inventory:add_item(8602, "alchemy_restorative_tonic_recipe", 1).ok)

local before_iron = InventoryService.count_item(
    assert(profiles:get_character(8601, 1)),
    "iron_bar"
)

local blocked = professions:prepare_craft(
    8601,
    "forge_blueprinted_ironbound_gloves"
)
check(
    blocked.ok == false and blocked.reason == "RecipeNotLearned",
    "Learned Blacksmithing recipe must reject before learning."
)
check(
    InventoryService.count_item(
        assert(profiles:get_character(8601, 1)),
        "iron_bar"
    ) == before_iron,
    "Knowledge rejection must happen before material consumption."
)

local default_recipe = professions:prepare_craft(
    8601,
    "forge_ironbound_gloves"
)
check(
    default_recipe.reason ~= "RecipeNotLearned",
    "Existing default recipe must not be blocked by knowledge."
)

check(
    knowledge:learn_from_item(
        8601,
        "blacksmith_iron_guard_blueprint"
    ).ok == true,
    "Blacksmithing blueprint learning must succeed."
)

local blacksmith_ready = professions:prepare_craft(
    8601,
    "forge_blueprinted_ironbound_gloves"
)
check(
    blacksmith_ready.ok == true,
    "Known Blacksmithing learned recipe must pass knowledge gate."
)

local alchemy_blocked = professions:prepare_craft(
    8602,
    "distill_blueprinted_tempering_oil"
)
check(
    alchemy_blocked.ok == false
        and alchemy_blocked.reason == "RecipeNotLearned",
    "Learned Alchemy recipe must reject before learning."
)

check(
    knowledge:learn_from_item(
        8602,
        "alchemy_restorative_tonic_recipe"
    ).ok == true,
    "Alchemy recipe learning must succeed."
)

local alchemy_ready = professions:prepare_craft(
    8602,
    "distill_blueprinted_tempering_oil"
)
check(
    alchemy_ready.ok == true,
    "Known Alchemy learned recipe must pass knowledge gate."
)

-- Knowledge must not bypass normal material validation.
assert(profiles:mutate(8601, function(profile: any)
    profile.Characters.Slot1.Inventory = {}
end))

local missing_materials = professions:prepare_craft(
    8601,
    "forge_blueprinted_ironbound_gloves"
)
check(
    missing_materials.ok == false
        and missing_materials.reason == "MissingMaterials",
    "Known recipe must still require materials."
)

local snapshot = professions:build_snapshot(8601)
check(snapshot.ok == true, "Profession snapshot must build.")
check(
    snapshot.Recipes.forge_blueprinted_ironbound_gloves.Known == true,
    "Snapshot must expose learned recipe knowledge."
)
check(
    snapshot.Recipes.distill_blueprinted_tempering_oil.Known == false
        and snapshot.Recipes.distill_blueprinted_tempering_oil.Unlocked == false,
    "The smith cannot unlock another player's Alchemy recipe."
)
local alchemist_snapshot = professions:build_snapshot(8602)
check(
    alchemist_snapshot.Recipes.distill_blueprinted_tempering_oil.Known
        == true
        and alchemist_snapshot.Recipes.distill_blueprinted_tempering_oil.Unlocked
            == true,
    "The separate Alchemist alone owns and may use the learned recipe."
)

print(string.format(
    "[Recipe Knowledge Crafting Gate Tests] PASS: %d assertions.",
    assertions
))
