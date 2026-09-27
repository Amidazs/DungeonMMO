--!strict
-- Orc Fighter class-44 progression definitions through first transfer.

local OrcFighterSkills = {}

local ORC = table.freeze({"Orc"})
local FIGHTER = table.freeze({"Fighter"})
local NO_WEAPON = table.freeze({})

--[[
Builds a frozen rank-level table for repeated three-rank brackets.

Args:
    levels ({number}): Ordered source purchase levels.

Returns:
    {[number]: number}: Rank-to-level schedule.
]]
local function three_rank_brackets(
    levels: {number}
): {[number]: number}
    local result = {}
    local rank = 1

    for _, level in ipairs(levels) do
        for _ = 1, 3 do
            result[rank] = level
            rank += 1
        end
    end

    return table.freeze(result)
end

local DEFINITIONS = table.freeze({
    OrcToughness = table.freeze({
        Id = "OrcToughness",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedRaces = ORC,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({[1] = 1}),
        WeaponTags = NO_WEAPON,
    }),

    OrcLucky = table.freeze({
        Id = "OrcLucky",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedRaces = ORC,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({[1] = 1}),
        WeaponTags = NO_WEAPON,
    }),

    OrcCommonCraft = table.freeze({
        Id = "OrcCommonCraft",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Utility",
        AllowedRaces = ORC,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({[1] = 1}),
        RequiresCraftingProfessionChoice = true,
        CommonCraftEnabled = true,
        WeaponTags = NO_WEAPON,
    }),

    OrcPowerStrike = table.freeze({
        Id = "OrcPowerStrike",
        Tier = "Common",
        MaxRank = 9,
        Kind = "Physical",
        AllowedRaces = ORC,
        AllowedBaseClasses = FIGHTER,
        RankLevels = three_rank_brackets({5, 10, 15}),
        WeaponTags = table.freeze({
            "OneHandedSword",
            "TwoHandedSword",
            "OneHandedBlunt",
            "TwoHandedBlunt",
        }),
    }),

    OrcIronPunch = table.freeze({
        Id = "OrcIronPunch",
        Tier = "Common",
        MaxRank = 9,
        Kind = "Physical",
        AllowedRaces = ORC,
        AllowedBaseClasses = FIGHTER,
        RankLevels = three_rank_brackets({5, 10, 15}),
        WeaponTags = table.freeze({"Fist", "DualFist"}),
    }),

    OrcWeaponTraining = table.freeze({
        Id = "OrcWeaponTraining",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Passive",
        AllowedRaces = ORC,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({
            [1] = 5,
            [2] = 10,
            [3] = 15,
        }),
        WeaponTags = NO_WEAPON,
    }),

    OrcArmorTraining = table.freeze({
        Id = "OrcArmorTraining",
        Tier = "Common",
        MaxRank = 5,
        Kind = "Passive",
        AllowedRaces = ORC,
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

    OrcRelax = table.freeze({
        Id = "OrcRelax",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Utility",
        AllowedRaces = ORC,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({[1] = 5}),
        WeaponTags = NO_WEAPON,
    }),

    OrcIronBody = table.freeze({
        Id = "OrcIronBody",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedRaces = ORC,
        AllowedBaseClasses = FIGHTER,
        RankLevels = table.freeze({[1] = 15}),
        WeaponTags = NO_WEAPON,
    }),
})

--[[
Returns one Orc Fighter progression definition.

Args:
    skill_id (string): DungeonMMO creative skill identifier.

Returns:
    any?: Frozen definition or nil for another class family.
]]
function OrcFighterSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every Orc Fighter progression definition.

Args:
    None.

Returns:
    any: Frozen creative definition map.
]]
function OrcFighterSkills.all(): any
    return DEFINITIONS
end

return table.freeze(OrcFighterSkills)
