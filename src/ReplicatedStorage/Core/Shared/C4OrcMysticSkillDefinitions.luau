--!strict
-- Orc Mystic class-49 progression definitions through first transfer.

local OrcMysticSkills = {}

local ORC = table.freeze({"Orc"})
local MAGE = table.freeze({"Mage"})
local NO_WEAPON = table.freeze({})

--[[
Builds a frozen rank-level table from exact source brackets.

Args:
    schedule ({{number}}): Ordered {level, count} source brackets.

Returns:
    {[number]: number}: Creative rank-to-level schedule.
]]
local function build_rank_levels(
    schedule: {{number}}
): {[number]: number}
    local result = {}
    local rank = 1

    for _, entry in ipairs(schedule) do
        for _ = 1, entry[2] do
            result[rank] = entry[1]
            rank += 1
        end
    end

    return table.freeze(result)
end

--[[
Creates one Orc Mystic progression definition.

Args:
    skill_id (string): DungeonMMO-facing skill identifier.
    kind (string): Progression family.
    schedule ({{number}}): Exact source training brackets.

Returns:
    any: Frozen creative progression definition.
]]
local function make_skill(
    skill_id: string,
    kind: string,
    schedule: {{number}}
): any
    local levels = build_rank_levels(schedule)

    return table.freeze({
        Id = skill_id,
        Tier = "Common",
        MaxRank = #levels,
        Kind = kind,
        AllowedBaseClasses = MAGE,
        AllowedRaces = ORC,
        RankLevels = levels,
        WeaponTags = NO_WEAPON,
    })
end

local DEFINITIONS = table.freeze({
    OrcMysticMovement = make_skill(
        "OrcMysticMovement", "Passive", {{1, 1}}
    ),
    OrcMysticToughness = make_skill(
        "OrcMysticToughness", "Passive", {{1, 1}}
    ),
    OrcMysticArcaneResistance = make_skill(
        "OrcMysticArcaneResistance", "Passive",
        {{7, 2}, {14, 2}}
    ),
    OrcMysticSpellcraft = make_skill(
        "OrcMysticSpellcraft", "Passive", {{1, 1}}
    ),
    OrcMysticLucky = make_skill(
        "OrcMysticLucky", "Passive", {{1, 1}}
    ),
    OrcMysticManaRecovery = make_skill(
        "OrcMysticManaRecovery", "Passive", {{1, 1}}
    ),
    OrcMysticWeaponTraining = make_skill(
        "OrcMysticWeaponTraining", "Passive",
        {{7, 1}, {14, 1}}
    ),
    OrcMysticRobeTraining = make_skill(
        "OrcMysticRobeTraining", "Passive",
        {{7, 2}, {14, 2}}
    ),
    OrcMysticLightArmorTraining = make_skill(
        "OrcMysticLightArmorTraining", "Passive",
        {{7, 2}, {14, 2}}
    ),
    OrcMysticHeavyArmorTraining = make_skill(
        "OrcMysticHeavyArmorTraining", "Passive",
        {{14, 2}}
    ),
    OrcMysticSoulCry = make_skill(
        "OrcMysticSoulCry", "Support",
        {{1, 1}, {14, 1}}
    ),
    OrcMysticBattleChant = make_skill(
        "OrcMysticBattleChant", "Support", {{14, 1}}
    ),
    OrcMysticSoulShield = make_skill(
        "OrcMysticSoulShield", "Support", {{7, 1}}
    ),
    OrcMysticLifeDrain = make_skill(
        "OrcMysticLifeDrain", "Magic",
        {{7, 1}, {14, 1}}
    ),
    OrcMysticFear = make_skill(
        "OrcMysticFear", "Control", {{14, 1}}
    ),
    OrcMysticVenom = make_skill(
        "OrcMysticVenom", "Magic",
        {{7, 1}, {14, 1}}
    ),
    OrcMysticDreamingSpirit = make_skill(
        "OrcMysticDreamingSpirit", "Control",
        {{7, 1}, {14, 1}}
    ),
    OrcMysticChillFlame = make_skill(
        "OrcMysticChillFlame", "Magic",
        {{7, 1}, {14, 1}}
    ),
    OrcMysticCommonCraft = table.freeze({
        Id = "OrcMysticCommonCraft",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Utility",
        AllowedBaseClasses = MAGE,
        AllowedRaces = ORC,
        RankLevels = table.freeze({[1] = 1}),
        RequiresCraftingProfessionChoice = true,
        CommonCraftEnabled = true,
        WeaponTags = NO_WEAPON,
    }),
})

--[[
Returns one Orc Mystic progression definition.

Args:
    skill_id (string): DungeonMMO skill identifier.

Returns:
    any?: Frozen definition or nil for another class family.
]]
function OrcMysticSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every Orc Mystic progression definition.

Args:
    None.

Returns:
    any: Frozen creative definition map.
]]
function OrcMysticSkills.all(): any
    return DEFINITIONS
end

return table.freeze(OrcMysticSkills)
