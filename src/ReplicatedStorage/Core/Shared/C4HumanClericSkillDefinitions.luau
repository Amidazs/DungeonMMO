--!strict
-- Independently named Human Cleric first-transfer training definitions.

local HumanClericSkills = {}

local HUMAN_MAGE = table.freeze({"Mage"})
local HUMAN_RACE = table.freeze({"Human"})
local DAWNKEEPER = table.freeze({"Dawnkeeper"})
local ARCANE_WAND = table.freeze({"ArcaneWand"})
local NO_WEAPON = table.freeze({})

--[[
Expands level/count pairs into a rank-indexed training schedule.

Args:
    schedule ({{number}}): Ordered {level, count} source brackets.

Returns:
    {[number]: number}: Rank number to required character level.
]]
local function build_rank_levels(
    schedule: {{number}}
): {[number]: number}
    local levels = {}
    local rank = 1

    for _, entry in ipairs(schedule) do
        for _ = 1, entry[2] do
            levels[rank] = entry[1]
            rank += 1
        end
    end

    return table.freeze(levels)
end

--[[
Creates one Human Cleric progression definition.

Args:
    skill_id (string): DungeonMMO-facing skill identifier.
    kind (string): Progression skill family.
    schedule ({{number}}): Exact level/count training brackets.
    weapon_tags ({string}): Server-owned allowed weapon tags.

Returns:
    any: Frozen progression definition.
]]
local function make_skill(
    skill_id: string,
    kind: string,
    schedule: {{number}},
    weapon_tags: {string}
): any
    local levels = build_rank_levels(schedule)

    return table.freeze({
        Id = skill_id,
        Tier = "Common",
        MaxRank = #levels,
        Kind = kind,
        AllowedBaseClasses = HUMAN_MAGE,
        AllowedRaces = HUMAN_RACE,
        AllowedFirstTransferClasses = DAWNKEEPER,
        RankLevels = levels,
        WeaponTags = weapon_tags,
    })
end

local DEFINITIONS = table.freeze({
    DawnkeeperArcaneResistance = make_skill(
        "DawnkeeperArcaneResistance",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON
    ),
    DawnkeeperQuickPrayer = make_skill(
        "DawnkeeperQuickPrayer",
        "Passive",
        {{20, 1}, {30, 1}},
        NO_WEAPON
    ),
    DawnkeeperManaReservoir = make_skill(
        "DawnkeeperManaReservoir",
        "Passive",
        {{20, 1}, {30, 1}},
        NO_WEAPON
    ),
    DawnkeeperFastCasting = make_skill(
        "DawnkeeperFastCasting",
        "Passive",
        {{25, 1}},
        NO_WEAPON
    ),
    DawnkeeperManaRecovery = make_skill(
        "DawnkeeperManaRecovery",
        "Passive",
        {{25, 1}},
        NO_WEAPON
    ),
    DawnkeeperRobeTraining = make_skill(
        "DawnkeeperRobeTraining",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON
    ),
    DawnkeeperLightArmorTraining = make_skill(
        "DawnkeeperLightArmorTraining",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON
    ),
    DawnkeeperWeaponTraining = make_skill(
        "DawnkeeperWeaponTraining",
        "Passive",
        {{20, 1}, {25, 2}, {30, 2}},
        NO_WEAPON
    ),
    DawnkeeperHealingLight = make_skill(
        "DawnkeeperHealingLight",
        "Support",
        {{20, 3}, {25, 3}, {30, 3}},
        ARCANE_WAND
    ),
    DawnkeeperBattleMend = make_skill(
        "DawnkeeperBattleMend",
        "Support",
        {{20, 3}, {25, 3}, {30, 3}},
        ARCANE_WAND
    ),
    DawnkeeperRevive = make_skill(
        "DawnkeeperRevive",
        "Support",
        {{20, 1}, {30, 1}},
        ARCANE_WAND
    ),
    DawnkeeperGroupMend = make_skill(
        "DawnkeeperGroupMend",
        "Support",
        {{20, 3}, {25, 3}, {30, 3}},
        ARCANE_WAND
    ),
    DawnkeeperExorcism = make_skill(
        "DawnkeeperExorcism",
        "Magic",
        {{20, 2}, {25, 2}, {30, 2}},
        ARCANE_WAND
    ),
    DawnkeeperMindWard = make_skill(
        "DawnkeeperMindWard",
        "Support",
        {{25, 1}},
        ARCANE_WAND
    ),
    DawnkeeperStoneWard = make_skill(
        "DawnkeeperStoneWard",
        "Support",
        {{25, 1}},
        ARCANE_WAND
    ),
    DawnkeeperSacredEdge = make_skill(
        "DawnkeeperSacredEdge",
        "Support",
        {{25, 1}},
        ARCANE_WAND
    ),
    DawnkeeperMight = make_skill(
        "DawnkeeperMight",
        "Support",
        {{20, 1}},
        ARCANE_WAND
    ),
    DawnkeeperSlumber = make_skill(
        "DawnkeeperSlumber",
        "Control",
        {{25, 3}, {30, 3}},
        ARCANE_WAND
    ),
    DawnkeeperBreathBlessing = make_skill(
        "DawnkeeperBreathBlessing",
        "Support",
        {{20, 1}},
        ARCANE_WAND
    ),
    DawnkeeperFocus = make_skill(
        "DawnkeeperFocus",
        "Support",
        {{25, 1}},
        ARCANE_WAND
    ),
    DawnkeeperConcentration = make_skill(
        "DawnkeeperConcentration",
        "Support",
        {{20, 1}, {30, 1}},
        ARCANE_WAND
    ),
    DawnkeeperInsight = make_skill(
        "DawnkeeperInsight",
        "Support",
        {{20, 1}},
        ARCANE_WAND
    ),
    DawnkeeperFireWard = make_skill(
        "DawnkeeperFireWard",
        "Support",
        {{30, 1}},
        ARCANE_WAND
    ),
    DawnkeeperRootbind = make_skill(
        "DawnkeeperRootbind",
        "Control",
        {{25, 3}, {30, 3}},
        ARCANE_WAND
    ),
    DawnkeeperWindstep = make_skill(
        "DawnkeeperWindstep",
        "Support",
        {{20, 1}, {30, 1}},
        ARCANE_WAND
    ),
})

--[[
Returns one independently named Human Cleric definition.

Args:
    skill_id (string): DungeonMMO skill identifier.

Returns:
    any?: Frozen definition or nil.
]]
function HumanClericSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every Human Cleric definition.

Args:
    None.

Returns:
    any: Frozen definition map.
]]
function HumanClericSkills.all(): any
    return DEFINITIONS
end

return table.freeze(HumanClericSkills)
