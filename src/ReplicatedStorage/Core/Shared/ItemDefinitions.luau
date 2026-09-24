--!strict
local ItemDefinitions = {}

local FIGHTER = table.freeze({"Fighter"})
local MAGE = table.freeze({"Mage"})
local RANGER = table.freeze({"Ranger"})
local FIGHTER_ROGUE = table.freeze({"Fighter", "Rogue"})
local FIGHTER_RANGER = table.freeze({"Fighter", "Ranger"})
local RANGER_ROGUE = table.freeze({"Ranger", "Rogue"})
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

    -- Authored functional blunt-weapon prototype. Its final appearance
    -- is intentionally deferred; no item may gain sword-only training.
    stonewatch_training_mace = table.freeze({
        Id = "stonewatch_training_mace",
        Name = "Stonewatch Training Mace",
        Kind = "Equipment",
        Slot = "Weapon",
        Category = "Blunt",
        AllowedBaseClasses = FIGHTER,
        Rarity = "Basic",
        Stackable = false,
        WeaponTags = table.freeze({"OneHandedBlunt"}),
        CombatModifiers = table.freeze({
            PhysicalDamageBonus = 0.10,
        }),
    }),

    -- Original DungeonMMO rogue trial weapons: personal, non-tradeable
    -- inventory equipment granted ONLY inside Vela stage-two commit.
    -- These remain placeholders pending final historical meshes/art.
    neti_trial_dagger = table.freeze({
        Id = "neti_trial_dagger",
        Name = "Vela's Trial Dagger",
        Kind = "Equipment",
        InventoryCategory = "Equipment",
        Slot = "Weapon",
        Category = "Dagger",
        AllowedRaces = table.freeze({"Human"}),
        AllowedBaseClasses = FIGHTER,
        Rarity = "Quest",
        Stackable = false,
        Bound = true,
        Tradeable = false,
        WeaponTags = table.freeze({"Dagger", "OneHandedSword"}),
    }),

    neti_trial_bow = table.freeze({
        Id = "neti_trial_bow",
        Name = "Vela's Trial Bow",
        Kind = "Equipment",
        InventoryCategory = "Equipment",
        Slot = "Weapon",
        Category = "Longbow",
        AllowedRaces = table.freeze({"Human"}),
        AllowedBaseClasses = FIGHTER,
        Rarity = "Quest",
        Stackable = false,
        Bound = true,
        Tradeable = false,
        CanBlock = false,
        WeaponTags = table.freeze({"Longbow"}),
        ReservedSlots = table.freeze({"OffHand"}),
    }),

    -- DungeonMMO source-monster quest materials belong to their earning
    -- character. Live drops require a verified one-use server-owned
    -- instanced combat receipt; an arbitrary item flag is not enough.
    stonewatch_badge = table.freeze({
        Id = "stonewatch_badge",
        Name = "Stonewatch Signal Badge",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Quest",
        Stackable = true,
        Bound = true,
        Tradeable = false,
    }),
    gloam_ward_seal = table.freeze({
        Id = "gloam_ward_seal",
        Name = "Gloam Ward Seal",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Quest",
        Stackable = false,
        Bound = true,
        Tradeable = false,
    }),

    ironroot_dispatch_marker = table.freeze({
        Id = "ironroot_dispatch_marker",
        Name = "Ironroot Dispatch Marker",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Quest",
        Stackable = true,
        Bound = true,
        Tradeable = false,
    }),
    ridgebreaker_oath_seal = table.freeze({
        Id = "ridgebreaker_oath_seal",
        Name = "Ridgebreaker's Oath Seal",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Quest",
        Stackable = false,
        Bound = true,
        Tradeable = false,
    }),

    spartoi_bone = table.freeze({
        Id = "spartoi_bone",
        Name = "Crypt Sentinel Fragment",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Quest",
        Stackable = true,
        Bound = true,
        Tradeable = false,
    }),

    prias_letter_1 = table.freeze({
        Id = "prias_letter_1",
        Name = "Cael's Field Report Fragment 1",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Quest",
        Stackable = false,
        Bound = true,
        Tradeable = false,
    }),

    prias_letter_2 = table.freeze({
        Id = "prias_letter_2",
        Name = "Cael's Field Report Fragment 2",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Quest",
        Stackable = false,
        Bound = true,
        Tradeable = false,
    }),

    prias_letter_3 = table.freeze({
        Id = "prias_letter_3",
        Name = "Cael's Field Report Fragment 3",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Quest",
        Stackable = false,
        Bound = true,
        Tradeable = false,
    }),

    prias_letter_4 = table.freeze({
        Id = "prias_letter_4",
        Name = "Cael's Field Report Fragment 4",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Quest",
        Stackable = false,
        Bound = true,
        Tradeable = false,
    }),

    bracken_ward_sigil = table.freeze({
        Id = "bracken_ward_sigil",
        Name = "Bracken Ward Sigil",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Quest",
        Stackable = false,
        Bound = true,
        Tradeable = false,
    }),

    cinder_cipher = table.freeze({
        Id = "cinder_cipher",
        Name = "Cinder Supply Cipher",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Quest",
        Stackable = false,
        Bound = true,
        Tradeable = false,
    }),

    cinder_route_map = table.freeze({
        Id = "cinder_route_map",
        Name = "Ashen Route Map",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Quest",
        Stackable = false,
        Bound = true,
        Tradeable = false,
    }),

    cinder_ward_seal = table.freeze({
        Id = "cinder_ward_seal",
        Name = "Cinder Ward Seal",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Quest",
        Stackable = false,
        Bound = true,
        Tradeable = false,
    }),

    cinder_tideglass_lens = table.freeze({
        Id = "cinder_tideglass_lens",
        Name = "Tideglass Lens",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Quest",
        Stackable = false,
        Bound = true,
        Tradeable = false,
    }),

    scout_dagger = table.freeze({
        Id = "scout_dagger",
        Name = "Scout Dagger",
        Kind = "Equipment",
        InventoryCategory = "Equipment",
        Slot = "Weapon",
        Category = "Dagger",
        AllowedBaseClasses = FIGHTER_ROGUE,
        Rarity = "Basic",
        Stackable = false,
        -- The dagger may still execute accepted starter sword hitboxes
        -- until its own meshes/animations are manufactured.
        WeaponTags = table.freeze({"Dagger", "OneHandedSword"}),
        CombatModifiers = table.freeze({
            PhysicalDamageBonus = 0.08,
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
        AllowedBaseClasses = FIGHTER_RANGER,
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

    apprentice_mystic_robe = table.freeze({
        Id = "apprentice_mystic_robe",
        Name = "Apprentice Mystic Robe",
        Kind = "Equipment",
        InventoryCategory = "Equipment",
        Slot = "Body",
        Category = "Robe",
        AllowedBaseClasses = MAGE,
        Rarity = "Basic",
        Stackable = false,
    }),

    scout_leather_vest = table.freeze({
        Id = "scout_leather_vest",
        Name = "Scout Leather Vest",
        Kind = "Equipment",
        InventoryCategory = "Equipment",
        Slot = "Body",
        Category = "LightArmor",
        AllowedBaseClasses = RANGER_ROGUE,
        Rarity = "Basic",
        Stackable = false,
    }),

    -- Craftable first-transfer light vest. Without paid equipment
    -- expertise it cannot be equipped, including through old profiles.
    scout_expert_leather_vest = table.freeze({
        Id = "scout_expert_leather_vest",
        Name = "Expert Scout Leather Vest",
        Kind = "Equipment",
        InventoryCategory = "Equipment",
        Slot = "Body",
        Category = "LightArmor",
        AllowedBaseClasses = RANGER_ROGUE,
        RequiredSkillId = "ScoutEquipmentExpertise",
        RequiredSkillRank = 1,
        Rarity = "Uncommon",
        Stackable = false,
        CombatModifiers = table.freeze({
            MaxHealthFlat = 12,
        }),
    }),

    -- Original light-armour proof item for the independent Warrior career.
    -- Definition alone does not mint a free item; acquisition remains
    -- a separately tested trading, loot or crafting integration task.
    ironroot_light_vest = table.freeze({
        Id = "ironroot_light_vest",
        Name = "Ironroot Light Vest",
        Kind = "Equipment",
        InventoryCategory = "Equipment",
        Slot = "Body",
        Category = "LightArmor",
        AllowedBaseClasses = FIGHTER,
        AllowedClasses = table.freeze({"Ironvow"}),
        Rarity = "Basic",
        Stackable = false,
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

    worldroot_relic = table.freeze({
        Id = "worldroot_relic",
        Name = "Worldroot Relic",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Uncommon",
        Stackable = false,
        Bound = true,
        Tradeable = false,
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

    raw_hide = table.freeze({
        Id = "raw_hide",
        Name = "Raw Hide",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Basic",
        Stackable = true,
    }),

    cured_leather = table.freeze({
        Id = "cured_leather",
        Name = "Cured Leather",
        Kind = "Material",
        InventoryCategory = "Materials",
        Rarity = "Basic",
        Stackable = true,
    }),

    warding_essence = table.freeze({
        Id = "warding_essence",
        Name = "Warding Essence",
        Kind = "Material",
        Category = "Reagent",
        InventoryCategory = "Reagents",
        Rarity = "Uncommon",
        Stackable = true,
    }),

    warding_rune = table.freeze({
        Id = "warding_rune",
        Name = "Warding Rune",
        Kind = "Material",
        Category = "Reagent",
        InventoryCategory = "Reagents",
        Rarity = "Uncommon",
        Stackable = true,
    }),

    forging_flux = table.freeze({
        Id = "forging_flux",
        Name = "Forging Flux",
        Kind = "Material",
        Category = "Reagent",
        InventoryCategory = "Reagents",
        Rarity = "Uncommon",
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

    leatherbound_gloves = table.freeze({
        Id = "leatherbound_gloves",
        Name = "Leatherbound Gloves",
        Kind = "Equipment",
        InventoryCategory = "Equipment",
        Slot = "Gloves",
        Category = "CraftedArmor",
        AllowedBaseClasses = ALL_CLASSES,
        Rarity = "Basic",
        Stackable = false,
        CombatModifiers = table.freeze({
            MaxHealthFlat = 4,
            CriticalChanceBonus = 0.01,
        }),
    }),

    warded_leatherbound_gloves = table.freeze({
        Id = "warded_leatherbound_gloves",
        Name = "Warded Leatherbound Gloves",
        Kind = "Equipment",
        InventoryCategory = "Equipment",
        Slot = "Gloves",
        Category = "CraftedArmor",
        AllowedBaseClasses = ALL_CLASSES,
        Rarity = "Rare",
        Stackable = false,
        CombatModifiers = table.freeze({
            MaxHealthFlat = 7,
            CriticalChanceBonus = 0.03,
        }),
    }),

    runic_ironbound_gloves = table.freeze({
        Id = "runic_ironbound_gloves",
        Name = "Runic Ironbound Gloves",
        Kind = "Equipment",
        InventoryCategory = "Equipment",
        Slot = "Gloves",
        Category = "CraftedArmor",
        AllowedBaseClasses = ALL_CLASSES,
        Rarity = "Rare",
        Stackable = false,
        CombatModifiers = table.freeze({
            MaxHealthFlat = 7,
            CriticalChanceBonus = 0.03,
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
