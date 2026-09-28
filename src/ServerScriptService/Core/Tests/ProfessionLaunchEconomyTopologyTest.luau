--!strict
-- Pure launch-economy topology regression for profession tiers three to five.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Core.Shared
local Items = require(Shared.ItemDefinitions)
local Recipes = require(Shared.ProfessionRecipes)

local checks = 0

local GENERIC_LADDER = table.freeze({
    Blacksmithing = table.freeze({
        "smelt_deep_iron_bar",
        "forge_hardened_fittings",
        "forge_masterwork_frame",
    }),
    Alchemy = table.freeze({
        "distill_moonpetal_extract",
        "distill_prismatic_catalyst",
        "distill_aetheric_catalyst",
    }),
    Leatherworking = table.freeze({
        "cure_thick_hide",
        "stitch_rune_binding",
        "stitch_masterwork_lining",
    }),
    Enchanting = table.freeze({
        "inscribe_resonant_rune",
        "inscribe_prismatic_seal",
        "inscribe_arcane_matrix",
    }),
})

local GEARWRIGHT_PREMIUM = table.freeze({
    Blacksmithing = "gearwright_precision_assembly",
    Alchemy = "gearwright_stabilizing_compound",
    Leatherworking = "gearwright_articulated_binding",
    Enchanting = "gearwright_runic_matrix",
})

local SALVAGE_ITEMS = table.freeze({
    dense_mineral_shard = true,
    salvaged_mechanism_fragment = true,
    ancient_binding_fragment = true,
})

--[[
Counts one launch-economy assertion.

Args:
    condition (boolean): Expected recipe or item invariant.
    label (string): Failure context.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Profession Economy Topology] " .. label)
end

--[[
Returns whether a recipe consumes one item ID.

Args:
    recipe (any): Registered profession recipe.
    item_id (string): Ingredient identifier to find.

Returns:
    boolean: True when the ingredient is present.
]]
local function consumes(recipe: any, item_id: string): boolean
    for _, input in ipairs(recipe.Inputs) do
        if input.ItemId == item_id then
            return true
        end
    end

    return false
end

--[[
Builds a map from crafted item ID to producing profession.

Args:
    None.

Returns:
    {[string]: string}: Output item to profession map.
]]
local function producer_map(): {[string]: string}
    local result = {}

    for _, recipe in pairs(Recipes.all()) do
        local output = recipe.Output
        if type(output) == "table"
            and type(output.ItemId) == "string"
        then
            result[output.ItemId] = recipe.ProfessionId
        end
    end

    return result
end

--[[
Runs the launch profession economy structure audit.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all checks succeed.
]]
local function main()
    local producers = producer_map()

    for profession_id, recipe_ids in pairs(GENERIC_LADDER) do
        local station_recipes = {}
        for _, recipe in ipairs(
            Recipes.for_station(profession_id)
        ) do
            station_recipes[recipe.Id] = true
        end

        for index, recipe_id in ipairs(recipe_ids) do
            local recipe = assert(Recipes.get(recipe_id))
            local expected_level = index + 2

            check(
                recipe.ProfessionId == profession_id
                    and recipe.RequiredLevel == expected_level,
                recipe_id .. " owns its intended profession tier"
            )
            check(
                station_recipes[recipe_id] == true,
                recipe_id .. " appears in station ordering"
            )
            check(
                recipe.RequiredSkillId == nil,
                recipe_id .. " remains normal profession progression"
            )

            local output = Items.get(recipe.Output.ItemId)
            check(
                output ~= nil
                    and output.Tradeable == true
                    and output.Bound == false,
                recipe_id .. " produces a tradeable component"
            )

            local cross_profession_input = false
            for _, input in ipairs(recipe.Inputs) do
                check(
                    SALVAGE_ITEMS[input.ItemId] ~= true,
                    recipe_id
                        .. " cannot require Deepclaimer salvage"
                )
                local producer = producers[input.ItemId]
                if producer and producer ~= profession_id then
                    cross_profession_input = true
                end
            end

            check(
                cross_profession_input,
                recipe_id
                    .. " requires at least one other crafting profession"
            )
        end
    end

    for profession_id, recipe_id in pairs(GEARWRIGHT_PREMIUM) do
        local recipe = assert(Recipes.get(recipe_id))
        check(
            recipe.ProfessionId == profession_id
                and recipe.RequiredLevel == 5
                and recipe.RequiredSkillId
                    == "GearwrightBlueprintTraining"
                and recipe.RequiredSkillRank == 2,
            recipe_id .. " is a level-five Gearwright blueprint"
        )

        local salvage_count = 0
        local non_salvage_count = 0
        for _, input in ipairs(recipe.Inputs) do
            if SALVAGE_ITEMS[input.ItemId] then
                salvage_count += 1
                local salvage = Items.get(input.ItemId)
                check(
                    salvage ~= nil
                        and salvage.Tradeable == true
                        and salvage.Bound == false,
                    input.ItemId .. " remains a tradeable salvage good"
                )
            else
                non_salvage_count += 1
            end
        end

        check(
            salvage_count == 1 and non_salvage_count >= 2,
            recipe_id
                .. " mixes optional salvage with normal profession goods"
        )
        check(
            not consumes(recipe, "deep_iron_ore")
                and not consumes(recipe, "moonpetal")
                and not consumes(recipe, "thick_hide"),
            recipe_id
                .. " cannot bypass other professions by consuming raw goods"
        )

        local output = Items.get(recipe.Output.ItemId)
        check(
            output ~= nil
                and output.Tradeable == true
                and output.Bound == false,
            recipe_id .. " produces a tradeable premium component"
        )
    end

    print(
        ("[Profession Economy Topology] PASS: %d assertions")
            :format(checks)
    )
end

main()
