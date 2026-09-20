--!strict
local ProfessionRecipes = {}

local RECIPES = table.freeze({
    smelt_iron_bar = table.freeze({
        Id = "smelt_iron_bar",
        Name = "Smelt Iron Bar",
        ProfessionId = "Blacksmithing",
        StationId = "Blacksmithing",
        RequiredLevel = 1,
        Knowledge = table.freeze({Mode = "Default"}),
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
        Knowledge = table.freeze({Mode = "Default"}),
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
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "silverleaf", Quantity = 3}),
        }),
        Output = table.freeze({ItemId = "tempering_oil", Quantity = 1}),
        XP = 20,
    }),
    forge_blueprinted_ironbound_gloves = table.freeze({
        Id = "forge_blueprinted_ironbound_gloves",
        Name = "Forge Blueprint Ironbound Gloves",
        ProfessionId = "Blacksmithing",
        StationId = "Blacksmithing",
        RequiredLevel = 2,
        Knowledge = table.freeze({
            Mode = "Learned",
            RecipeId = "blacksmith_iron_guard_blueprint",
        }),
        Inputs = table.freeze({
            table.freeze({ItemId = "iron_bar", Quantity = 3}),
        }),
        Output = table.freeze({
            ItemId = "ironbound_gloves",
            Quantity = 1,
        }),
        XP = 20,
    }),
    distill_blueprinted_tempering_oil = table.freeze({
        Id = "distill_blueprinted_tempering_oil",
        Name = "Distill Blueprint Tempering Oil",
        ProfessionId = "Alchemy",
        StationId = "Alchemy",
        RequiredLevel = 2,
        Knowledge = table.freeze({
            Mode = "Learned",
            RecipeId = "alchemy_restorative_tonic_recipe",
        }),
        Inputs = table.freeze({
            table.freeze({ItemId = "silverleaf", Quantity = 3}),
        }),
        Output = table.freeze({
            ItemId = "tempering_oil",
            Quantity = 1,
        }),
        XP = 20,
    }),
    distill_forging_flux = table.freeze({
        Id = "distill_forging_flux",
        Name = "Distill Forging Flux",
        ProfessionId = "Alchemy",
        StationId = "Alchemy",
        RequiredLevel = 1,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "silverleaf", Quantity = 2}),
            -- The alchemist needs a bar made by a blacksmith.
            table.freeze({ItemId = "iron_bar", Quantity = 1}),
        }),
        Output = table.freeze({ItemId = "forging_flux", Quantity = 1}),
        XP = 25,
    }),
    forge_runic_ironbound_gloves = table.freeze({
        Id = "forge_runic_ironbound_gloves",
        Name = "Forge Runic Ironbound Gloves",
        ProfessionId = "Blacksmithing",
        StationId = "Blacksmithing",
        RequiredLevel = 2,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "ironbound_gloves", Quantity = 1}),
            table.freeze({ItemId = "iron_bar", Quantity = 1}),
            -- The smith cannot finish these without Alchemy's flux.
            table.freeze({ItemId = "forging_flux", Quantity = 1}),
        }),
        Output = table.freeze({
            ItemId = "runic_ironbound_gloves", Quantity = 1,
        }),
        XP = 35,
    }),
    temper_ironbound_gloves = table.freeze({
        Id = "temper_ironbound_gloves",
        Name = "Temper Ironbound Gloves",
        ProfessionId = "Blacksmithing",
        StationId = "Blacksmithing",
        RequiredLevel = 2,
        Knowledge = table.freeze({Mode = "Default"}),
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
        "forge_blueprinted_ironbound_gloves",
        "temper_ironbound_gloves",
        "forge_runic_ironbound_gloves",
    }),
    Alchemy = table.freeze({
        "distill_tempering_oil",
        "distill_blueprinted_tempering_oil",
        "distill_forging_flux",
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
