--!strict
local ProfessionRecipes = {}

local RECIPES = table.freeze({
    smelt_iron_bar = table.freeze({
        Id = "smelt_iron_bar",
        Name = "Smelt Iron Bar",
        ProfessionId = "Blacksmithing",
        StationId = "Blacksmithing",
        RequiredLevel = 1,
        Inputs = table.freeze({
            table.freeze({ItemId = "iron_ore", Quantity = 2}),
        }),
        Output = table.freeze({ItemId = "iron_bar", Quantity = 1}),
        XP = 10,
    }),
    forge_ironbound_gloves = table.freeze({
        Id = "forge_ironbound_gloves",
        Name = "Forge Ironbound Gloves",
        ProfessionId = "Blacksmithing",
        StationId = "Blacksmithing",
        RequiredLevel = 1,
        Inputs = table.freeze({
            table.freeze({ItemId = "iron_bar", Quantity = 3}),
        }),
        Output = table.freeze({ItemId = "ironbound_gloves", Quantity = 1}),
        XP = 20,
    }),
    distill_tempering_oil = table.freeze({
        Id = "distill_tempering_oil",
        Name = "Distill Tempering Oil",
        ProfessionId = "Alchemy",
        StationId = "Alchemy",
        RequiredLevel = 1,
        Inputs = table.freeze({
            table.freeze({ItemId = "silverleaf", Quantity = 3}),
        }),
        Output = table.freeze({ItemId = "tempering_oil", Quantity = 1}),
        XP = 20,
    }),
    temper_ironbound_gloves = table.freeze({
        Id = "temper_ironbound_gloves",
        Name = "Temper Ironbound Gloves",
        ProfessionId = "Blacksmithing",
        StationId = "Blacksmithing",
        RequiredLevel = 2,
        Inputs = table.freeze({
            table.freeze({ItemId = "ironbound_gloves", Quantity = 1}),
            table.freeze({ItemId = "iron_bar", Quantity = 1}),
            table.freeze({ItemId = "tempering_oil", Quantity = 1}),
        }),
        Output = table.freeze({ItemId = "tempered_ironbound_gloves", Quantity = 1}),
        XP = 30,
    }),
})

local STATION_ORDER = table.freeze({
    Blacksmithing = table.freeze({
        "smelt_iron_bar",
        "forge_ironbound_gloves",
        "temper_ironbound_gloves",
    }),
    Alchemy = table.freeze({
        "distill_tempering_oil",
    }),
})

function ProfessionRecipes.get(recipe_id: string): any?
    return RECIPES[recipe_id]
end

function ProfessionRecipes.all(): any
    return RECIPES
end

function ProfessionRecipes.for_station(station_id: string): {any}
    local result = {}
    local order = STATION_ORDER[station_id]
    if not order then
        return result
    end

    for _, recipe_id in ipairs(order) do
        local recipe = RECIPES[recipe_id]
        if recipe then
            table.insert(result, recipe)
        end
    end

    return result
end

return table.freeze(ProfessionRecipes)
