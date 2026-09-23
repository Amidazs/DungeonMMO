--!strict
local ProfessionRecipes = {}

local RECIPES = table.freeze({
    -- Three genuine first-transfer C4 ranks per selected crafting career.
    -- Higher ranks consume real materials made by other professions;
    -- skill mastery never grants an additional creation profession.
    scout_forge_bars_rank_1 = table.freeze({
        Id = "scout_forge_bars_rank_1",
        Name = "Scout Iron Bars (Rank 1)",
        ProfessionId = "Blacksmithing",
        StationId = "Blacksmithing",
        RequiredLevel = 1,
        RequiredSkillId = "ScoutCommonItemCreation",
        RequiredSkillRank = 1,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "iron_ore", Quantity = 2}),
        }),
        Output = table.freeze({
            ItemId = "iron_bar", Quantity = 2,
        }),
        XP = 18,
    }),
    scout_forge_bars_rank_2 = table.freeze({
        Id = "scout_forge_bars_rank_2",
        Name = "Scout Iron Bars (Rank 2)",
        ProfessionId = "Blacksmithing",
        StationId = "Blacksmithing",
        RequiredLevel = 2,
        RequiredSkillId = "ScoutCommonItemCreation",
        RequiredSkillRank = 2,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "iron_ore", Quantity = 2}),
            table.freeze({ItemId = "forging_flux", Quantity = 1}),
        }),
        Output = table.freeze({
            ItemId = "iron_bar", Quantity = 3,
        }),
        XP = 32,
    }),
    scout_forge_bars_rank_3 = table.freeze({
        Id = "scout_forge_bars_rank_3",
        Name = "Scout Iron Bars (Rank 3)",
        ProfessionId = "Blacksmithing",
        StationId = "Blacksmithing",
        RequiredLevel = 3,
        RequiredSkillId = "ScoutCommonItemCreation",
        RequiredSkillRank = 3,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "iron_ore", Quantity = 3}),
            table.freeze({ItemId = "forging_flux", Quantity = 1}),
            table.freeze({ItemId = "warding_rune", Quantity = 1}),
        }),
        Output = table.freeze({
            ItemId = "iron_bar", Quantity = 5,
        }),
        XP = 54,
    }),
    scout_distill_oil_rank_1 = table.freeze({
        Id = "scout_distill_oil_rank_1",
        Name = "Scout Tempering Oil (Rank 1)",
        ProfessionId = "Alchemy",
        StationId = "Alchemy",
        RequiredLevel = 1,
        RequiredSkillId = "ScoutCommonItemCreation",
        RequiredSkillRank = 1,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "silverleaf", Quantity = 2}),
        }),
        Output = table.freeze({
            ItemId = "tempering_oil", Quantity = 2,
        }),
        XP = 18,
    }),
    scout_distill_oil_rank_2 = table.freeze({
        Id = "scout_distill_oil_rank_2",
        Name = "Scout Tempering Oil (Rank 2)",
        ProfessionId = "Alchemy",
        StationId = "Alchemy",
        RequiredLevel = 2,
        RequiredSkillId = "ScoutCommonItemCreation",
        RequiredSkillRank = 2,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "silverleaf", Quantity = 2}),
            table.freeze({ItemId = "iron_bar", Quantity = 1}),
        }),
        Output = table.freeze({
            ItemId = "tempering_oil", Quantity = 3,
        }),
        XP = 32,
    }),
    scout_distill_oil_rank_3 = table.freeze({
        Id = "scout_distill_oil_rank_3",
        Name = "Scout Tempering Oil (Rank 3)",
        ProfessionId = "Alchemy",
        StationId = "Alchemy",
        RequiredLevel = 3,
        RequiredSkillId = "ScoutCommonItemCreation",
        RequiredSkillRank = 3,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "silverleaf", Quantity = 3}),
            table.freeze({ItemId = "iron_bar", Quantity = 1}),
            table.freeze({ItemId = "warding_rune", Quantity = 1}),
        }),
        Output = table.freeze({
            ItemId = "tempering_oil", Quantity = 5,
        }),
        XP = 54,
    }),
    scout_cure_leather_rank_1 = table.freeze({
        Id = "scout_cure_leather_rank_1",
        Name = "Scout Cured Leather (Rank 1)",
        ProfessionId = "Leatherworking",
        StationId = "Leatherworking",
        RequiredLevel = 1,
        RequiredSkillId = "ScoutCommonItemCreation",
        RequiredSkillRank = 1,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "raw_hide", Quantity = 2}),
            table.freeze({ItemId = "tempering_oil", Quantity = 1}),
        }),
        Output = table.freeze({
            ItemId = "cured_leather", Quantity = 2,
        }),
        XP = 18,
    }),
    scout_cure_leather_rank_2 = table.freeze({
        Id = "scout_cure_leather_rank_2",
        Name = "Scout Cured Leather (Rank 2)",
        ProfessionId = "Leatherworking",
        StationId = "Leatherworking",
        RequiredLevel = 2,
        RequiredSkillId = "ScoutCommonItemCreation",
        RequiredSkillRank = 2,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "raw_hide", Quantity = 3}),
            table.freeze({ItemId = "tempering_oil", Quantity = 1}),
            table.freeze({ItemId = "iron_bar", Quantity = 1}),
        }),
        Output = table.freeze({
            ItemId = "cured_leather", Quantity = 3,
        }),
        XP = 32,
    }),
    scout_cure_leather_rank_3 = table.freeze({
        Id = "scout_cure_leather_rank_3",
        Name = "Scout Cured Leather (Rank 3)",
        ProfessionId = "Leatherworking",
        StationId = "Leatherworking",
        RequiredLevel = 3,
        RequiredSkillId = "ScoutCommonItemCreation",
        RequiredSkillRank = 3,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "raw_hide", Quantity = 4}),
            table.freeze({ItemId = "tempering_oil", Quantity = 1}),
            table.freeze({ItemId = "warding_rune", Quantity = 1}),
        }),
        Output = table.freeze({
            ItemId = "cured_leather", Quantity = 5,
        }),
        XP = 54,
    }),
    scout_inscribe_runes_rank_1 = table.freeze({
        Id = "scout_inscribe_runes_rank_1",
        Name = "Scout Warding Runes (Rank 1)",
        ProfessionId = "Enchanting",
        StationId = "Enchanting",
        RequiredLevel = 1,
        RequiredSkillId = "ScoutCommonItemCreation",
        RequiredSkillRank = 1,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "warding_essence", Quantity = 1}),
            table.freeze({ItemId = "iron_bar", Quantity = 1}),
        }),
        Output = table.freeze({
            ItemId = "warding_rune", Quantity = 2,
        }),
        XP = 18,
    }),
    scout_inscribe_runes_rank_2 = table.freeze({
        Id = "scout_inscribe_runes_rank_2",
        Name = "Scout Warding Runes (Rank 2)",
        ProfessionId = "Enchanting",
        StationId = "Enchanting",
        RequiredLevel = 2,
        RequiredSkillId = "ScoutCommonItemCreation",
        RequiredSkillRank = 2,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "warding_essence", Quantity = 1}),
            table.freeze({ItemId = "iron_bar", Quantity = 1}),
            table.freeze({ItemId = "tempering_oil", Quantity = 1}),
        }),
        Output = table.freeze({
            ItemId = "warding_rune", Quantity = 3,
        }),
        XP = 32,
    }),
    scout_inscribe_runes_rank_3 = table.freeze({
        Id = "scout_inscribe_runes_rank_3",
        Name = "Scout Warding Runes (Rank 3)",
        ProfessionId = "Enchanting",
        StationId = "Enchanting",
        RequiredLevel = 3,
        RequiredSkillId = "ScoutCommonItemCreation",
        RequiredSkillRank = 3,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "warding_essence", Quantity = 2}),
            table.freeze({ItemId = "iron_bar", Quantity = 1}),
            table.freeze({ItemId = "cured_leather", Quantity = 1}),
        }),
        Output = table.freeze({
            ItemId = "warding_rune", Quantity = 5,
        }),
        XP = 54,
    }),
    -- Optional real inventory/XP recipes, not free goods or extra careers.
    -- Each alternative needs a purchased source C4 level-five passive
    -- and remains bound to the player's single selected crafting career.
    c4_common_iron_bar = table.freeze({
        Id = "c4_common_iron_bar",
        Name = "Common Iron Bar",
        ProfessionId = "Blacksmithing",
        StationId = "Blacksmithing",
        RequiredLevel = 1,
        RequiredSkillId = "C4CommonItemCreation",
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "iron_ore", Quantity = 1}),
        }),
        Output = table.freeze({ItemId = "iron_bar", Quantity = 1}),
        XP = 6,
    }),
    c4_common_tempering_oil = table.freeze({
        Id = "c4_common_tempering_oil",
        Name = "Common Tempering Oil",
        ProfessionId = "Alchemy",
        StationId = "Alchemy",
        RequiredLevel = 1,
        RequiredSkillId = "C4CommonItemCreation",
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "silverleaf", Quantity = 2}),
        }),
        Output = table.freeze({ItemId = "tempering_oil", Quantity = 1}),
        XP = 8,
    }),
    c4_common_cured_leather = table.freeze({
        Id = "c4_common_cured_leather",
        Name = "Common Cured Leather",
        ProfessionId = "Leatherworking",
        StationId = "Leatherworking",
        RequiredLevel = 1,
        RequiredSkillId = "C4CommonItemCreation",
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "raw_hide", Quantity = 2}),
            table.freeze({ItemId = "tempering_oil", Quantity = 1}),
        }),
        Output = table.freeze({ItemId = "cured_leather", Quantity = 1}),
        XP = 12,
    }),
    c4_common_warding_rune = table.freeze({
        Id = "c4_common_warding_rune",
        Name = "Common Warding Rune",
        ProfessionId = "Enchanting",
        StationId = "Enchanting",
        RequiredLevel = 1,
        RequiredSkillId = "C4CommonItemCreation",
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "warding_essence", Quantity = 1}),
        }),
        Output = table.freeze({ItemId = "warding_rune", Quantity = 1}),
        XP = 16,
    }),
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
    cure_raw_hide = table.freeze({
        Id = "cure_raw_hide",
        Name = "Cure Raw Hide",
        ProfessionId = "Leatherworking",
        StationId = "Leatherworking",
        RequiredLevel = 1,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "raw_hide", Quantity = 3}),
            -- Alchemy supplies the curing oil.
            table.freeze({ItemId = "tempering_oil", Quantity = 1}),
        }),
        Output = table.freeze({ItemId = "cured_leather", Quantity = 1}),
        XP = 20,
    }),
    stitch_leatherbound_gloves = table.freeze({
        Id = "stitch_leatherbound_gloves",
        Name = "Stitch Leatherbound Gloves",
        ProfessionId = "Leatherworking",
        StationId = "Leatherworking",
        RequiredLevel = 1,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "cured_leather", Quantity = 1}),
            -- Blacksmithing supplies the metal fittings.
            table.freeze({ItemId = "iron_bar", Quantity = 1}),
        }),
        Output = table.freeze({
            ItemId = "leatherbound_gloves", Quantity = 1,
        }),
        XP = 20,
    }),
    distill_warding_essence = table.freeze({
        Id = "distill_warding_essence",
        Name = "Distill Warding Essence",
        ProfessionId = "Alchemy",
        StationId = "Alchemy",
        RequiredLevel = 1,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "silverleaf", Quantity = 2}),
            table.freeze({ItemId = "forging_flux", Quantity = 1}),
        }),
        Output = table.freeze({ItemId = "warding_essence", Quantity = 1}),
        XP = 25,
    }),
    inscribe_warding_rune = table.freeze({
        Id = "inscribe_warding_rune",
        Name = "Inscribe Warding Rune",
        ProfessionId = "Enchanting",
        StationId = "Enchanting",
        RequiredLevel = 1,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            table.freeze({ItemId = "warding_essence", Quantity = 1}),
            table.freeze({ItemId = "iron_bar", Quantity = 1}),
        }),
        Output = table.freeze({ItemId = "warding_rune", Quantity = 1}),
        XP = 30,
    }),
    enchant_leatherbound_gloves = table.freeze({
        Id = "enchant_leatherbound_gloves",
        Name = "Enchant Leatherbound Gloves",
        ProfessionId = "Enchanting",
        StationId = "Enchanting",
        RequiredLevel = 2,
        Knowledge = table.freeze({Mode = "Default"}),
        Inputs = table.freeze({
            -- Leatherworking, Enchanting and Alchemy must contribute.
            table.freeze({ItemId = "leatherbound_gloves", Quantity = 1}),
            table.freeze({ItemId = "warding_rune", Quantity = 1}),
            table.freeze({ItemId = "forging_flux", Quantity = 1}),
        }),
        Output = table.freeze({
            ItemId = "warded_leatherbound_gloves", Quantity = 1,
        }),
        XP = 45,
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
        "scout_forge_bars_rank_1",
        "scout_forge_bars_rank_2",
        "scout_forge_bars_rank_3",
        "c4_common_iron_bar",
        "smelt_iron_bar",
        "forge_ironbound_gloves",
        "forge_blueprinted_ironbound_gloves",
        "temper_ironbound_gloves",
        "forge_runic_ironbound_gloves",
    }),
    Alchemy = table.freeze({
        "scout_distill_oil_rank_1",
        "scout_distill_oil_rank_2",
        "scout_distill_oil_rank_3",
        "c4_common_tempering_oil",
        "distill_tempering_oil",
        "distill_blueprinted_tempering_oil",
        "distill_forging_flux",
        "distill_warding_essence",
    }),
    Leatherworking = table.freeze({
        "scout_cure_leather_rank_1",
        "scout_cure_leather_rank_2",
        "scout_cure_leather_rank_3",
        "c4_common_cured_leather",
        "cure_raw_hide",
        "stitch_leatherbound_gloves",
    }),
    Enchanting = table.freeze({
        "scout_inscribe_runes_rank_1",
        "scout_inscribe_runes_rank_2",
        "scout_inscribe_runes_rank_3",
        "c4_common_warding_rune",
        "inscribe_warding_rune",
        "enchant_leatherbound_gloves",
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
