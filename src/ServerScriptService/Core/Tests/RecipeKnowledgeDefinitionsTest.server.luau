--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local ItemDefinitions = require(Shared:WaitForChild("ItemDefinitions"))
local ProfessionRecipes = require(Shared:WaitForChild("ProfessionRecipes"))

local assertions = 0

local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Recipe Knowledge Definitions Tests] " .. message, 2)
    end
end

local default_recipe = assert(
    ProfessionRecipes.get("forge_ironbound_gloves"),
    "Default Blacksmithing recipe missing."
)
check(
    type(default_recipe.Knowledge) == "table"
        and default_recipe.Knowledge.Mode == "Default",
    "Existing baseline recipe must remain default-known."
)

local blacksmith_recipe = assert(
    ProfessionRecipes.get("forge_blueprinted_ironbound_gloves"),
    "Blacksmithing learned proof recipe missing."
)
check(
    blacksmith_recipe.Knowledge.Mode == "Learned",
    "Blacksmithing proof recipe must require learned knowledge."
)
check(
    blacksmith_recipe.Knowledge.RecipeId == "blacksmith_iron_guard_blueprint",
    "Blacksmithing knowledge ID mismatch."
)
check(
    blacksmith_recipe.ProfessionId == "Blacksmithing"
        and blacksmith_recipe.RequiredLevel == 2,
    "Blacksmithing learned recipe requirements mismatch."
)

local blacksmith_blueprint = assert(
    ItemDefinitions.get("blacksmith_iron_guard_blueprint"),
    "Blacksmithing blueprint item missing."
)
check(
    blacksmith_blueprint.Kind == "RecipeBlueprint",
    "Blacksmithing blueprint Kind mismatch."
)
check(
    blacksmith_blueprint.Stackable == true,
    "Blacksmithing blueprint must be stackable for duplicate tests."
)
check(
    blacksmith_blueprint.RecipeLearning.RecipeId
        == "blacksmith_iron_guard_blueprint",
    "Blacksmithing blueprint knowledge ID mismatch."
)
check(
    blacksmith_blueprint.RecipeLearning.ProfessionId == "Blacksmithing"
        and blacksmith_blueprint.RecipeLearning.RequiredProfessionLevel == 2,
    "Blacksmithing blueprint requirements mismatch."
)

local alchemy_recipe = assert(
    ProfessionRecipes.get("distill_blueprinted_tempering_oil"),
    "Alchemy learned proof recipe missing."
)
check(
    alchemy_recipe.Knowledge.Mode == "Learned",
    "Alchemy proof recipe must require learned knowledge."
)
check(
    alchemy_recipe.Knowledge.RecipeId == "alchemy_restorative_tonic_recipe",
    "Alchemy knowledge ID mismatch."
)
check(
    alchemy_recipe.ProfessionId == "Alchemy"
        and alchemy_recipe.RequiredLevel == 2,
    "Alchemy learned recipe requirements mismatch."
)

local alchemy_blueprint = assert(
    ItemDefinitions.get("alchemy_restorative_tonic_recipe"),
    "Alchemy blueprint item missing."
)
check(
    alchemy_blueprint.Kind == "RecipeBlueprint",
    "Alchemy blueprint Kind mismatch."
)
check(
    alchemy_blueprint.RecipeLearning.RecipeId
        == "alchemy_restorative_tonic_recipe",
    "Alchemy blueprint knowledge ID mismatch."
)
check(
    alchemy_blueprint.RecipeLearning.ProfessionId == "Alchemy"
        and alchemy_blueprint.RecipeLearning.RequiredProfessionLevel == 2,
    "Alchemy blueprint requirements mismatch."
)

local invalid_blueprint = assert(
    ItemDefinitions.get("recipe_blueprint_invalid_test"),
    "Malformed blueprint test definition missing."
)
check(
    invalid_blueprint.TestOnly == true
        and invalid_blueprint.Kind == "RecipeBlueprint",
    "Malformed blueprint fixture must remain test-only."
)

print(string.format(
    "[Recipe Knowledge Definitions Tests] PASS: %d assertions.",
    assertions
))
