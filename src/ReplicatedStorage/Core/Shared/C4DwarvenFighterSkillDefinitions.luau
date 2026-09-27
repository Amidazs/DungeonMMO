--!strict
-- Dwarven Fighter class-53 progression definitions through first transfer.

local DwarvenFighterSkills = {}

local DWARF = table.freeze({"Dwarf"})
local FIGHTER = table.freeze({"Fighter"})
local NO_WEAPON = table.freeze({})

local DEFINITIONS = table.freeze({
    DwarfWorkshopCraft = table.freeze({
        Id = "DwarfWorkshopCraft",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Utility",
        AllowedRaces = DWARF,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({[1] = 1}),
        DwarvenCraftEnabled = true,
        WeaponTags = NO_WEAPON,
    }),
    DwarfSalvageClaim = table.freeze({
        Id = "DwarfSalvageClaim",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Utility",
        AllowedRaces = DWARF,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({[1] = 10}),
        WeaponTags = NO_WEAPON,
    }),
    DwarfWeaponTraining = table.freeze({
        Id = "DwarfWeaponTraining",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Passive",
        AllowedRaces = DWARF,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({
            [1] = 5,
            [2] = 10,
            [3] = 15,
        }),
        WeaponTags = NO_WEAPON,
    }),
    DwarfArmorTraining = table.freeze({
        Id = "DwarfArmorTraining",
        Tier = "Common",
        MaxRank = 5,
        Kind = "Passive",
        AllowedRaces = DWARF,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({
            [1] = 5,
            [2] = 10,
            [3] = 10,
            [4] = 15,
            [5] = 15,
        }),
        WeaponTags = NO_WEAPON,
    }),
    DwarfPackTraining = table.freeze({
        Id = "DwarfPackTraining",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedRaces = DWARF,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({[1] = 10}),
        WeaponTags = NO_WEAPON,
    }),
    DwarfBlueprintFoundation = table.freeze({
        Id = "DwarfBlueprintFoundation",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedRaces = DWARF,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({[1] = 5}),
        DwarvenCreateItemRank = 1,
        WeaponTags = NO_WEAPON,
    }),
    DwarfFortune = table.freeze({
        Id = "DwarfFortune",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedRaces = DWARF,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({[1] = 1}),
        WeaponTags = NO_WEAPON,
    }),
    DwarfSalvageMark = table.freeze({
        Id = "DwarfSalvageMark",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Utility",
        AllowedRaces = DWARF,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({[1] = 10}),
        WeaponTags = NO_WEAPON,
    }),
    DwarfCommonCraft = table.freeze({
        Id = "DwarfCommonCraft",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Utility",
        AllowedRaces = DWARF,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({[1] = 1}),
        RequiresCraftingProfessionChoice = true,
        CommonCraftEnabled = true,
        WeaponTags = NO_WEAPON,
    }),
})

--[[
Returns one Dwarven Fighter progression definition.

Args:
    skill_id (string): DungeonMMO creative skill identifier.

Returns:
    any?: Frozen definition or nil for another class family.
]]
function DwarvenFighterSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every Dwarven Fighter progression definition.

Args:
    None.

Returns:
    any: Frozen creative definition map.
]]
function DwarvenFighterSkills.all(): any
    return DEFINITIONS
end

return table.freeze(DwarvenFighterSkills)
