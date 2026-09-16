--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Services = ServerScriptService:WaitForChild("Core"):WaitForChild("Services")

local ItemDefinitions = require(Shared:WaitForChild("ItemDefinitions"))
local ProfessionDefinitions = require(Shared:WaitForChild("ProfessionDefinitions"))
local ProfessionRecipes = require(Shared:WaitForChild("ProfessionRecipes"))
local InventoryService = require(Services:WaitForChild("InventoryService"))

local ProfessionService = {}
ProfessionService.__index = ProfessionService

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

local function ensure_professions(character: any): any
    if type(character.Professions) ~= "table" then
        character.Professions = {}
    end

    for _, profession_id in ipairs(ProfessionDefinitions.order()) do
        local state = character.Professions[profession_id]
        if type(state) ~= "table" then
            state = {Level = 1, XP = 0}
            character.Professions[profession_id] = state
        end
    end

    return character.Professions
end

local function add_xp(state: any, amount: number): (number, number)
    local before_level = math.max(1, math.floor(tonumber(state.Level) or 1))
    local xp = math.max(0, math.floor(tonumber(state.XP) or 0))
    xp += math.max(0, math.floor(amount))
    local level = ProfessionDefinitions.level_from_xp(xp)
    state.XP = xp
    state.Level = level
    return before_level, level
end

local function inventory_counts(character: any): any
    local counts = {}
    if type(character) ~= "table" or type(character.Inventory) ~= "table" then
        return counts
    end

    for _, entry in ipairs(character.Inventory) do
        if type(entry) == "table" and type(entry.ItemId) == "string" then
            local quantity = math.max(0, math.floor(tonumber(entry.Quantity) or 0))
            counts[entry.ItemId] = (counts[entry.ItemId] or 0) + quantity
        end
    end

    return counts
end

local function crafting_minigame_id(profession_id: string): string?
    local definition = ProfessionDefinitions.get(profession_id)
    local value = definition and definition.CraftingMinigameId
    return if type(value) == "string" and value ~= "" then value else nil
end

local function validate_recipe_for_character(character: any, recipe: any): string?
    if type(character) ~= "table" then
        return "CharacterMissing"
    end

    local professions = ensure_professions(character)
    local state = professions[recipe.ProfessionId]
    local level = ProfessionDefinitions.level_from_xp(
        math.max(0, math.floor(tonumber(state and state.XP) or 0))
    )
    state.Level = level

    if level < recipe.RequiredLevel then
        return "ProfessionLevelTooLow"
    end

    for _, input in ipairs(recipe.Inputs) do
        if InventoryService.count_item(character, input.ItemId) < input.Quantity then
            return "MissingMaterials"
        end

        if type(character.Equipment) == "table" then
            for _, equipped_item_id in pairs(character.Equipment) do
                if equipped_item_id == input.ItemId then
                    return "IngredientEquipped"
                end
            end
        end
    end

    return nil
end

function ProfessionService.new(profile_service: any, inventory_service: any): any
    assert(profile_service, "ProfessionService requires ProfileService")
    assert(inventory_service, "ProfessionService requires InventoryService")
    return setmetatable({
        _profiles = profile_service,
        _inventory = inventory_service,
    }, ProfessionService)
end

function ProfessionService:build_snapshot(user_id: number): any
    local character = self._profiles:get_character(user_id, 1)
    if not character then
        return {ok = false, reason = "ProfileNotLoaded"}
    end

    local professions = {}
    local source = if type(character.Professions) == "table"
        then character.Professions
        else {}

    for _, profession_id in ipairs(ProfessionDefinitions.order()) do
        local state = source[profession_id]
        local xp = if type(state) == "table"
            then math.max(0, math.floor(tonumber(state.XP) or 0))
            else 0
        local level = ProfessionDefinitions.level_from_xp(xp)
        local progress, needed = ProfessionDefinitions.progress_in_level(xp)
        professions[profession_id] = {
            Level = level,
            XP = xp,
            Progress = progress,
            XPToNext = needed,
            CraftingMinigameId = crafting_minigame_id(profession_id),
        }
    end

    local recipes = {}
    for recipe_id, recipe in pairs(ProfessionRecipes.all()) do
        local state = professions[recipe.ProfessionId]
        recipes[recipe_id] = {
            Unlocked = state ~= nil and state.Level >= recipe.RequiredLevel,
            RequiredLevel = recipe.RequiredLevel,
            CraftingMinigameId = crafting_minigame_id(recipe.ProfessionId),
        }
    end

    return {
        ok = true,
        Professions = professions,
        Inventory = inventory_counts(character),
        Recipes = recipes,
    }
end

function ProfessionService:gather(user_id: number, node: any): any
    if type(node) ~= "table" then
        return {ok = false, reason = "UnknownNode"}
    end

    local profession_id = node.ProfessionId
    local item_id = node.ItemId
    local quantity = math.floor(tonumber(node.Quantity) or 0)
    local xp = math.floor(tonumber(node.XP) or 0)

    if not ProfessionDefinitions.get(profession_id) then
        return {ok = false, reason = "UnknownProfession"}
    end
    if not ItemDefinitions.get(item_id) or quantity < 1 or xp < 0 then
        return {ok = false, reason = "InvalidNodeDefinition"}
    end

    local result: any = nil
    local ok, err = self._profiles:mutate(user_id, function(profile: any)
        local character = selected_character(profile)
        if not character then
            error("CharacterMissing")
        end

        local professions = ensure_professions(character)
        local state = professions[profession_id]
        local before_level, after_level = add_xp(state, xp)
        local added = InventoryService.apply_item_to_character(
            character,
            item_id,
            quantity
        )
        if not added.ok then
            error(tostring(added.reason))
        end

        result = {
            ok = true,
            profession_id = profession_id,
            item_id = item_id,
            quantity = quantity,
            xp = xp,
            level_before = before_level,
            level_after = after_level,
            total_quantity = added.total_quantity,
        }
    end)

    if not ok then
        return {ok = false, reason = err or "ProfileMutationFailed"}
    end
    return result
end

-- Non-mutating eligibility phase. A future profession-specific minigame starts
-- only after this returns ok=true. Completion revalidates before committing.
function ProfessionService:prepare_craft(user_id: number, recipe_id: string): any
    local recipe = ProfessionRecipes.get(recipe_id)
    if not recipe then
        return {ok = false, reason = "UnknownRecipe"}
    end

    if not ItemDefinitions.get(recipe.Output.ItemId) then
        return {ok = false, reason = "UnknownOutput"}
    end

    local minigame_id = crafting_minigame_id(recipe.ProfessionId)
    if not minigame_id then
        return {ok = false, reason = "CraftingMinigameNotConfigured"}
    end

    local character = self._profiles:get_character(user_id, 1)
    if not character then
        return {ok = false, reason = "ProfileNotLoaded"}
    end

    local rejection = validate_recipe_for_character(character, recipe)
    if rejection then
        return {ok = false, reason = rejection}
    end

    return {
        ok = true,
        recipe_id = recipe.Id,
        profession_id = recipe.ProfessionId,
        station_id = recipe.StationId,
        minigame_id = minigame_id,
        output_item_id = recipe.Output.ItemId,
        output_quantity = recipe.Output.Quantity,
    }
end

-- Commit phase used after a server-validated crafting minigame outcome. The
-- current foundation runtime passes an explicit auto-success outcome; later
-- minigames can replace that without changing inventory/progression authority.
function ProfessionService:complete_craft(
    user_id: number,
    recipe_id: string,
    outcome: any
): any
    if type(outcome) ~= "table" or outcome.Succeeded ~= true then
        return {ok = false, reason = "MinigameNotCompleted"}
    end

    local prepared = self:prepare_craft(user_id, recipe_id)
    if not prepared.ok then
        return prepared
    end

    if type(outcome.MinigameId) == "string"
        and outcome.MinigameId ~= prepared.minigame_id
    then
        return {ok = false, reason = "MinigameMismatch"}
    end

    local score = math.clamp(tonumber(outcome.Score) or 1, 0, 1)
    local recipe = assert(ProfessionRecipes.get(recipe_id))
    local result: any = nil
    local rejection: string? = nil

    local ok, err = self._profiles:mutate(user_id, function(profile: any)
        local character = selected_character(profile)
        if not character then
            rejection = "CharacterMissing"
            error(rejection)
        end

        -- Revalidate inside the single mutation so materials/equipment cannot
        -- change between minigame start and authoritative completion.
        rejection = validate_recipe_for_character(character, recipe)
        if rejection then
            error(rejection)
        end

        local professions = ensure_professions(character)
        local state = professions[recipe.ProfessionId]

        for _, input in ipairs(recipe.Inputs) do
            local removed = InventoryService.apply_remove_from_character(
                character,
                input.ItemId,
                input.Quantity
            )
            if not removed.ok then
                rejection = tostring(removed.reason or "MaterialConsumeFailed")
                error(rejection)
            end
        end

        local added = InventoryService.apply_item_to_character(
            character,
            recipe.Output.ItemId,
            recipe.Output.Quantity
        )
        if not added.ok then
            rejection = tostring(added.reason or "OutputGrantFailed")
            error(rejection)
        end

        local before_level, after_level = add_xp(state, recipe.XP)
        result = {
            ok = true,
            recipe_id = recipe.Id,
            profession_id = recipe.ProfessionId,
            minigame_id = prepared.minigame_id,
            minigame_score = score,
            output_item_id = recipe.Output.ItemId,
            output_quantity = recipe.Output.Quantity,
            xp = recipe.XP,
            level_before = before_level,
            level_after = after_level,
        }
    end)

    if not ok then
        return {ok = false, reason = rejection or err or "ProfileMutationFailed"}
    end
    return result
end

function ProfessionService.foundation_success_outcome(minigame_id: string): any
    return {
        Succeeded = true,
        Score = 1,
        MinigameId = minigame_id,
        Mode = "FoundationAutoSuccess",
    }
end

-- Compatibility entry point for focused tests and any older caller. It still
-- travels through the same prepare -> outcome -> atomic completion boundary.
function ProfessionService:craft(user_id: number, recipe_id: string): any
    local prepared = self:prepare_craft(user_id, recipe_id)
    if not prepared.ok then
        return prepared
    end

    return self:complete_craft(
        user_id,
        recipe_id,
        ProfessionService.foundation_success_outcome(prepared.minigame_id)
    )
end

return table.freeze(ProfessionService)
