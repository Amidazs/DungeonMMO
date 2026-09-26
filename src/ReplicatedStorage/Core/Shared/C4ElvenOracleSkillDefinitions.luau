--!strict
-- Independently named Elven Oracle first-transfer training definitions.

local ElvenOracleSkills = {}

local ELF_MAGE = table.freeze({"Mage"})
local ELF_RACE = table.freeze({"Elf"})
local LIFEBINDER = table.freeze({"Lifebinder"})
local ARCANE_WAND = table.freeze({"ArcaneWand"})
local NO_WEAPON = table.freeze({})

--[[
Expands source level/count pairs into creative rank requirements.

Args:
    schedule ({{number}}): Ordered {level, count} source brackets.

Returns:
    {[number]: number}: Creative rank to required character level.
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
Creates one Elven Oracle progression definition.

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
        AllowedBaseClasses = ELF_MAGE,
        AllowedRaces = ELF_RACE,
        AllowedFirstTransferClasses = LIFEBINDER,
        RankLevels = levels,
        WeaponTags = weapon_tags,
    })
end

local DEFINITIONS = table.freeze({
    LifebinderArcaneResistance = make_skill(
        "LifebinderArcaneResistance",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON
    ),
    LifebinderQuickPrayer = make_skill(
        "LifebinderQuickPrayer",
        "Passive",
        {{20, 1}, {30, 1}},
        NO_WEAPON
    ),
    LifebinderManaReservoir = make_skill(
        "LifebinderManaReservoir",
        "Passive",
        {{20, 1}, {30, 1}},
        NO_WEAPON
    ),
    LifebinderFastCasting = make_skill(
        "LifebinderFastCasting",
        "Passive",
        {{25, 1}},
        NO_WEAPON
    ),
    LifebinderManaRecovery = make_skill(
        "LifebinderManaRecovery",
        "Passive",
        {{25, 1}},
        NO_WEAPON
    ),
    LifebinderRobeTraining = make_skill(
        "LifebinderRobeTraining",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON
    ),
    LifebinderLightArmorTraining = make_skill(
        "LifebinderLightArmorTraining",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON
    ),
    LifebinderWeaponTraining = make_skill(
        "LifebinderWeaponTraining",
        "Passive",
        {{20, 1}, {25, 2}, {30, 2}},
        NO_WEAPON
    ),
    LifebinderHealingLight = make_skill(
        "LifebinderHealingLight",
        "Support",
        {{20, 3}, {25, 3}, {30, 3}},
        ARCANE_WAND
    ),
    LifebinderManaRecharge = make_skill(
        "LifebinderManaRecharge",
        "Support",
        {{30, 2}},
        ARCANE_WAND
    ),
    LifebinderBattleMend = make_skill(
        "LifebinderBattleMend",
        "Support",
        {{20, 3}, {25, 3}, {30, 3}},
        ARCANE_WAND
    ),
    LifebinderRevive = make_skill(
        "LifebinderRevive",
        "Support",
        {{20, 1}, {30, 1}},
        ARCANE_WAND
    ),
    LifebinderGroupMend = make_skill(
        "LifebinderGroupMend",
        "Support",
        {{20, 3}, {25, 3}, {30, 3}},
        ARCANE_WAND
    ),
    LifebinderExorcism = make_skill(
        "LifebinderExorcism",
        "Magic",
        {{20, 2}, {25, 2}, {30, 2}},
        ARCANE_WAND
    ),
    LifebinderMindWard = make_skill(
        "LifebinderMindWard",
        "Support",
        {{25, 1}},
        ARCANE_WAND
    ),
    LifebinderStoneWard = make_skill(
        "LifebinderStoneWard",
        "Support",
        {{25, 1}},
        ARCANE_WAND
    ),
    LifebinderSacredEdge = make_skill(
        "LifebinderSacredEdge",
        "Support",
        {{25, 1}},
        ARCANE_WAND
    ),
    LifebinderMight = make_skill(
        "LifebinderMight",
        "Support",
        {{20, 1}},
        ARCANE_WAND
    ),
    LifebinderSlumber = make_skill(
        "LifebinderSlumber",
        "Control",
        {{25, 3}, {30, 3}},
        ARCANE_WAND
    ),
    LifebinderBreathBlessing = make_skill(
        "LifebinderBreathBlessing",
        "Support",
        {{20, 1}},
        ARCANE_WAND
    ),
    LifebinderConcentration = make_skill(
        "LifebinderConcentration",
        "Support",
        {{20, 1}, {30, 1}},
        ARCANE_WAND
    ),
    LifebinderAgility = make_skill(
        "LifebinderAgility",
        "Support",
        {{25, 1}},
        ARCANE_WAND
    ),
    LifebinderRootbind = make_skill(
        "LifebinderRootbind",
        "Control",
        {{25, 3}, {30, 3}},
        ARCANE_WAND
    ),
    LifebinderWindstep = make_skill(
        "LifebinderWindstep",
        "Support",
        {{20, 1}, {30, 1}},
        ARCANE_WAND
    ),
    LifebinderWindShackle = make_skill(
        "LifebinderWindShackle",
        "Control",
        {{20, 1}, {25, 1}, {30, 1}},
        ARCANE_WAND
    ),
})

--[[
Returns one independently named Elven Oracle definition.

Args:
    skill_id (string): DungeonMMO skill identifier.

Returns:
    any?: Frozen definition or nil.
]]
function ElvenOracleSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every Elven Oracle definition.

Args:
    None.

Returns:
    any: Frozen definition map.
]]
function ElvenOracleSkills.all(): any
    return DEFINITIONS
end

return table.freeze(ElvenOracleSkills)
