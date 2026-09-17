--!strict
local ItemDefinitions = {}

local FIGHTER = table.freeze({"Fighter"})
local MAGE = table.freeze({"Mage"})
local RANGER = table.freeze({"Ranger"})
local FIGHTER_ROGUE = table.freeze({"Fighter", "Rogue"})
local ALL_CLASSES = table.freeze({"Fighter", "Mage", "Ranger", "Rogue"})
local ELF = table.freeze({"Elf"})

local DEFINITIONS = table.freeze({
    marauder_sword = table.freeze({
        Id = "marauder_sword",
        Name = "Marauder Sword",
        Kind = "Equipment",
        Slot = "Weapon",
        Category = "Sword",
        AllowedBaseClasses = FIGHTER_ROGUE,
        Rarity = "Basic",
        Stackable = false,
        WeaponTags = table.freeze({"OneHandedSword"}),
        CombatModifiers = table.freeze({
            PhysicalDamageBonus = 0.10,
        }),
    }),

    apprentice_arcane_wand = table.freeze({
        Id = "apprentice_arcane_wand",
        Name = "Apprentice Arcane Wand",
        Kind = "Equipment",
        Slot = "Weapon",
        Category = "Wand",
        AllowedBaseClasses = MAGE,
        Rarity = "Basic",
        Stackable = false,
        WeaponTags = table.freeze({"ArcaneWand"}),
    }),

    apprentice_longbow = table.freeze({
        Id = "apprentice_longbow",
        Name = "Apprentice Longbow",
        Kind = "Equipment",
        Slot = "Weapon",
        Category = "Longbow",
        AllowedBaseClasses = RANGER,
        Rarity = "Basic",
        Stackable = false,
        CanBlock = false,
        WeaponTags = table.freeze({"Longbow"}),
        ReservedSlots = table.freeze({"OffHand"}),
    }),

    marauder_shield = table.freeze({
        Id = "marauder_shield",
        Name = "Marauder Shield",
        Kind = "Equipment",
        Slot = "OffHand",
        Category = "Shield",
        AllowedBaseClasses = FIGHTER,
        Rarity = "Basic",
        Stackable = false,
        CombatModifiers = table.freeze({
            MaxHealthFlat = 8,
        }),
    }),

    marauder_armor = table.freeze({
        Id = "marauder_armor",
        Name = "Marauder Armour",
        Kind = "Equipment",
        Slot = "Body",
        Category = "HeavyArmor",
        AllowedBaseClasses = FIGHTER,
        Rarity = "Basic",
        Stackable = false,
        CombatModifiers = table.freeze({
            MaxHealthFlat = 10,
        }),
    }),

    marauder_helmet = table.freeze({
        Id = "marauder_helmet",
        Name = "Marauder Helmet",
        Kind = "Equipment",
        Slot = "Helmet",
        Category = "HeavyArmor",
        AllowedBaseClasses = FIGHTER,
        Rarity = "Basic",
        Stackable = false,
        CombatModifiers = table.freeze({
            MaxHealthFlat = 4,
        }),
    }),

    marauder_gloves = table.freeze({
        Id = "marauder_gloves",
        Name = "Marauder Gloves",
        Kind = "Equipment",
        Slot = "Gloves",
        Category = "HeavyArmor",
        AllowedBaseClasses = FIGHTER,
        Rarity = "Basic",
        Stackable = false,
        CombatModifiers = table.freeze({
            PhysicalDamageBonus = 0.03,
            CriticalChanceBonus = 0.01,
        }),
    }),

    marauder_boots = table.freeze({
        Id = "marauder_boots",
        Name = "Marauder Boots",
        Kind = "Equipment",
        Slot = "Boots",
        Category = "HeavyArmor",
        AllowedBaseClasses = FIGHTER,
        Rarity = "Basic",
        Stackable = false,
        CombatModifiers = table.freeze({
            MaxHealthFlat = 3,
        }),
    }),

    test_elf_helmet = table.freeze({
        Id = "test_elf_helmet",
        Name = "TEST Elven Helmet",
        Kind = "Equipment",
        Slot = "Helmet",
        Category = "LightArmor",
        AllowedRaces = ELF,
        AllowedBaseClasses = FIGHTER,
        Rarity = "Basic",
        Stackable = false,
        TestOnly = true,
    }),

    iron_ore = table.freeze({
        Id = "iron_ore",
        Name = "Iron Ore",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Basic",
        Stackable = true,
    }),

    iron_bar = table.freeze({
        Id = "iron_bar",
        Name = "Iron Bar",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Basic",
        Stackable = true,
    }),

    silverleaf = table.freeze({
        Id = "silverleaf",
        Name = "Silverleaf",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Basic",
        Stackable = true,
    }),

    tempering_oil = table.freeze({
        Id = "tempering_oil",
        Name = "Tempering Oil",
        Kind = "Material",
        Category = "Reagent",
        InventoryCategory = "Reagents",
        Rarity = "Uncommon",
        Stackable = true,
    }),

    ironbound_gloves = table.freeze({
        Id = "ironbound_gloves",
        Name = "Ironbound Gloves",
        Kind = "Equipment",
        InventoryCategory = "Equipment",
        Slot = "Gloves",
        Category = "CraftedArmor",
        AllowedBaseClasses = ALL_CLASSES,
        Rarity = "Basic",
        Stackable = false,
        CombatModifiers = table.freeze({
            MaxHealthFlat = 5,
        }),
    }),

    tempered_ironbound_gloves = table.freeze({
        Id = "tempered_ironbound_gloves",
        Name = "Tempered Ironbound Gloves",
        Kind = "Equipment",
        InventoryCategory = "Equipment",
        Slot = "Gloves",
        Category = "CraftedArmor",
        AllowedBaseClasses = ALL_CLASSES,
        Rarity = "Uncommon",
        Stackable = false,
        CombatModifiers = table.freeze({
            MaxHealthFlat = 6,
            CriticalChanceBonus = 0.02,
        }),
    }),

    captain_emblem = table.freeze({
        Id = "captain_emblem",
        Name = "Captain's Emblem",
        Kind = "Material",
        Rarity = "Uncommon",
        Stackable = true,
    }),

    blacksmith_iron_guard_blueprint = table.freeze({
        Id = "blacksmith_iron_guard_blueprint",
        Name = "Iron Guard Blueprint",
        Kind = "RecipeBlueprint",
        InventoryCategory = "Recipes",
        Rarity = "Uncommon",
        Stackable = true,
        RecipeLearning = table.freeze({
            RecipeId = "blacksmith_iron_guard_blueprint",
            ProfessionId = "Blacksmithing",
            RequiredProfessionLevel = 2,
        }),
    }),

    alchemy_restorative_tonic_recipe = table.freeze({
        Id = "alchemy_restorative_tonic_recipe",
        Name = "Restorative Tonic Recipe",
        Kind = "RecipeBlueprint",
        InventoryCategory = "Recipes",
        Rarity = "Uncommon",
        Stackable = true,
        RecipeLearning = table.freeze({
            RecipeId = "alchemy_restorative_tonic_recipe",
            ProfessionId = "Alchemy",
            RequiredProfessionLevel = 2,
        }),
    }),

    recipe_blueprint_invalid_test = table.freeze({
        Id = "recipe_blueprint_invalid_test",
        Name = "TEST Invalid Recipe Blueprint",
        Kind = "RecipeBlueprint",
        InventoryCategory = "Recipes",
        Rarity = "Basic",
        Stackable = true,
        TestOnly = true,
        RecipeLearning = table.freeze({
            RecipeId = "invalid_recipe_test",
        }),
    }),

    skill_book_test = table.freeze({
        Id = "skill_book_test",
        Name = "Unidentified Skill Book",
        Kind = "SkillBook",
        Rarity = "Rare",
        Stackable = true,
        Learnable = false,
        TestOnly = true,
    }),

    arc_slash_book = table.freeze({
        Id = "arc_slash_book",
        Name = "Arc Slash Skill Book",
        Kind = "SkillBook",
        Rarity = "Rare",
        Stackable = true,
        Learnable = true,
        Bound = false,
        Tradeable = true,
        SkillId = "ArcSlash",
    }),

    arc_slash_book_bound = table.freeze({
        Id = "arc_slash_book_bound",
        Name = "Arc Slash Skill Book",
        Kind = "SkillBook",
        Rarity = "Rare",
        Stackable = false,
        Learnable = true,
        Bound = true,
        Tradeable = false,
        SkillId = "ArcSlash",
    }),
})

function ItemDefinitions.get(item_id: string): any?
    return DEFINITIONS[item_id]
end

function ItemDefinitions.all(): any
    return DEFINITIONS
end

return table.freeze(ItemDefinitions)
