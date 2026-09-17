--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Services = ServerScriptService:WaitForChild("Core"):WaitForChild("Services")

local ItemDefinitions = require(Shared:WaitForChild("ItemDefinitions"))
local ProfessionDefinitions = require(Shared:WaitForChild("ProfessionDefinitions"))
local ProfessionRecipes = require(Shared:WaitForChild("ProfessionRecipes"))
local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local InventoryService = require(Services:WaitForChild("InventoryService"))

local RecipeKnowledgeService = {}
RecipeKnowledgeService.__index = RecipeKnowledgeService

local function selected_character(profile: any): any?
    if type(profile) ~= "table"
        or type(profile.Account) ~= "table"
        or type(profile.Characters) ~= "table"
    then
        return nil
    end

    local selected = math.floor(
        tonumber(profile.Account.SelectedCharacterSlot) or 1
    )
    return profile.Characters["Slot" .. tostring(selected)]
end

local function ensure_knowledge(character: any): any
    if type(character.CraftingKnowledge) ~= "table" then
        character.CraftingKnowledge = {}
    end

    local knowledge = character.CraftingKnowledge
    knowledge.Version = 1

    if type(knowledge.LearnedRecipes) ~= "table" then
        knowledge.LearnedRecipes = {}
    end

    return knowledge
end

local function read_knowledge(character: any): any
    local source = if type(character) == "table"
            and type(character.CraftingKnowledge) == "table"
        then character.CraftingKnowledge
        else {}

    local learned = if type(source.LearnedRecipes) == "table"
        then source.LearnedRecipes
        else {}

    return {
        Version = 1,
        LearnedRecipes = learned,
    }
end

local function resolve_learning_recipe(
    recipe_learning: any
): (any?, string?)
    if type(recipe_learning) ~= "table"
        or type(recipe_learning.RecipeId) ~= "string"
        or recipe_learning.RecipeId == ""
        or type(recipe_learning.ProfessionId) ~= "string"
        or recipe_learning.ProfessionId == ""
        or type(recipe_learning.RequiredProfessionLevel) ~= "number"
        or recipe_learning.RequiredProfessionLevel < 1
        or recipe_learning.RequiredProfessionLevel % 1 ~= 0
    then
        return nil, "InvalidRecipeLearningDefinition"
    end

    local match = nil

    for _, recipe in pairs(ProfessionRecipes.all()) do
        local knowledge = recipe.Knowledge

        if type(knowledge) == "table"
            and knowledge.Mode == "Learned"
            and knowledge.RecipeId == recipe_learning.RecipeId
        then
            if match ~= nil then
                return nil, "InvalidRecipeLearningDefinition"
            end
            match = recipe
        end
    end

    if not match
        or match.ProfessionId ~= recipe_learning.ProfessionId
        or match.RequiredLevel ~= recipe_learning.RequiredProfessionLevel
    then
        return nil, "InvalidRecipeLearningDefinition"
    end

    return match, nil
end

local function profession_rejection(
    character: any,
    profession_id: string,
    required_level: number
): string?
    if type(character) ~= "table"
        or type(character.Professions) ~= "table"
    then
        return "ProfessionUnavailable"
    end

    local state = character.Professions[profession_id]
    if type(state) ~= "table" then
        return "ProfessionUnavailable"
    end

    local level = ProfessionDefinitions.level_from_xp(
        math.max(0, math.floor(tonumber(state.XP) or 0))
    )

    if level < required_level then
        return "ProfessionLevelTooLow"
    end

    return nil
end

function RecipeKnowledgeService.recipe_rejection_for_character(
    character: any,
    recipe: any
): string?
    if type(recipe) ~= "table"
        or type(recipe.Knowledge) ~= "table"
        or type(recipe.Knowledge.Mode) ~= "string"
    then
        return "InvalidRecipeKnowledgeDefinition"
    end

    local mode = recipe.Knowledge.Mode

    if mode == "Default" then
        return nil
    end

    if mode ~= "Learned"
        or type(recipe.Knowledge.RecipeId) ~= "string"
        or recipe.Knowledge.RecipeId == ""
    then
        return "InvalidRecipeKnowledgeDefinition"
    end

    local knowledge = read_knowledge(character)

    if knowledge.LearnedRecipes[recipe.Knowledge.RecipeId] ~= true then
        return "RecipeNotLearned"
    end

    return nil
end

function RecipeKnowledgeService.new(
    profile_service: any,
    inventory_service: any
): any
    assert(profile_service, "RecipeKnowledgeService requires ProfileService")
    assert(inventory_service, "RecipeKnowledgeService requires InventoryService")

    return setmetatable({
        _profiles = profile_service,
        _inventory = inventory_service,
    }, RecipeKnowledgeService)
end

function RecipeKnowledgeService:knows_recipe(
    user_id: number,
    recipe_id: string
): any
    local recipe = ProfessionRecipes.get(recipe_id)
    if not recipe then
        return {ok = false, reason = "UnknownRecipe"}
    end

    local character = self._profiles:get_character(user_id, 1)
    if not character then
        return {ok = false, reason = "ProfileNotLoaded"}
    end

    local rejection =
        RecipeKnowledgeService.recipe_rejection_for_character(
            character,
            recipe
        )

    if rejection == nil then
        return {
            ok = true,
            known = true,
            recipe_id = recipe_id,
        }
    end

    if rejection == "RecipeNotLearned" then
        return {
            ok = true,
            known = false,
            recipe_id = recipe_id,
        }
    end

    return {
        ok = false,
        reason = rejection,
    }
end

function RecipeKnowledgeService:get_snapshot(user_id: number): any
    local character = self._profiles:get_character(user_id, 1)
    if not character then
        return {ok = false, reason = "ProfileNotLoaded"}
    end

    local knowledge = read_knowledge(character)

    return {
        ok = true,
        Version = 1,
        LearnedRecipes = ProfileSchema.deep_clone(
            knowledge.LearnedRecipes
        ),
    }
end

function RecipeKnowledgeService:learn_from_item(
    user_id: number,
    item_id: string
): any
    local item = if type(item_id) == "string"
        then ItemDefinitions.get(item_id)
        else nil

    if not item or item.Kind ~= "RecipeBlueprint" then
        return {ok = false, reason = "UnknownBlueprintItem"}
    end

    local recipe, definition_error =
        resolve_learning_recipe(item.RecipeLearning)

    if not recipe then
        return {
            ok = false,
            reason = definition_error
                or "InvalidRecipeLearningDefinition",
        }
    end

    local character = self._profiles:get_character(user_id, 1)
    if not character then
        return {ok = false, reason = "ProfileNotLoaded"}
    end

    if InventoryService.count_item(character, item_id) < 1 then
        return {ok = false, reason = "BlueprintNotOwned"}
    end

    local profession_error = profession_rejection(
        character,
        item.RecipeLearning.ProfessionId,
        item.RecipeLearning.RequiredProfessionLevel
    )
    if profession_error then
        return {ok = false, reason = profession_error}
    end

    local current = read_knowledge(character)
    if current.LearnedRecipes[item.RecipeLearning.RecipeId] == true then
        return {ok = false, reason = "RecipeAlreadyKnown"}
    end

    local result: any = nil
    local rejection: string? = nil

    local ok, mutation_error = self._profiles:mutate(
        user_id,
        function(profile: any)
            local selected = selected_character(profile)
            if not selected then
                rejection = "ProfileNotLoaded"
                error(rejection)
            end

            if InventoryService.count_item(selected, item_id) < 1 then
                rejection = "BlueprintNotOwned"
                error(rejection)
            end

            local inside_profession_error = profession_rejection(
                selected,
                item.RecipeLearning.ProfessionId,
                item.RecipeLearning.RequiredProfessionLevel
            )
            if inside_profession_error then
                rejection = inside_profession_error
                error(rejection)
            end

            local knowledge = ensure_knowledge(selected)
            if knowledge.LearnedRecipes[
                item.RecipeLearning.RecipeId
            ] == true then
                rejection = "RecipeAlreadyKnown"
                error(rejection)
            end

            local removed =
                InventoryService.apply_remove_from_character(
                    selected,
                    item_id,
                    1
                )

            if not removed.ok then
                rejection = "BlueprintNotOwned"
                error(rejection)
            end

            knowledge.LearnedRecipes[
                item.RecipeLearning.RecipeId
            ] = true

            result = {
                ok = true,
                ItemId = item_id,
                RecipeId = item.RecipeLearning.RecipeId,
                CraftRecipeId = recipe.Id,
                ProfessionId = recipe.ProfessionId,
                RemainingBlueprints = removed.total_quantity,
            }
        end
    )

    if not ok then
        return {
            ok = false,
            reason = rejection
                or mutation_error
                or "RecipeKnowledgeMutationFailed",
        }
    end

    return result
end

return table.freeze(RecipeKnowledgeService)
