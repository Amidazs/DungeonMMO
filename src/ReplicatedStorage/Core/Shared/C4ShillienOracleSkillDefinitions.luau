--!strict
-- Independently named Shillien Oracle first-transfer training definitions.

local ShillienOracleSkills = {}

local DARK_MAGE = table.freeze({"Mage"})
local DARK_ELF = table.freeze({"DarkElf"})
local DUSKSEER = table.freeze({"Duskseer"})
local ARCANE_WAND = table.freeze({"ArcaneWand"})
local NO_WEAPON = table.freeze({})

--[[
Expands exact source level/count brackets into creative rank levels.

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
Creates one Duskseer progression definition.

Args:
    skill_id (string): DungeonMMO-facing skill identifier.
    kind (string): Progression family.
    schedule ({{number}}): Exact source training brackets.
    weapon_tags ({string}): Server-owned allowed weapon tags.

Returns:
    any: Frozen creative progression definition.
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
        AllowedBaseClasses = DARK_MAGE,
        AllowedRaces = DARK_ELF,
        AllowedFirstTransferClasses = DUSKSEER,
        RankLevels = levels,
        WeaponTags = weapon_tags,
    })
end

local DEFINITIONS = table.freeze({
    DuskseerArcaneResistance = make_skill(
        "DuskseerArcaneResistance", "Passive",
        {{20, 2}, {25, 2}, {30, 2}}, NO_WEAPON
    ),
    DuskseerQuickPrayer = make_skill(
        "DuskseerQuickPrayer", "Passive",
        {{20, 1}, {30, 1}}, NO_WEAPON
    ),
    DuskseerManaReservoir = make_skill(
        "DuskseerManaReservoir", "Passive",
        {{20, 1}, {30, 1}}, NO_WEAPON
    ),
    DuskseerFastCasting = make_skill(
        "DuskseerFastCasting", "Passive",
        {{25, 1}}, NO_WEAPON
    ),
    DuskseerManaRecovery = make_skill(
        "DuskseerManaRecovery", "Passive",
        {{25, 1}}, NO_WEAPON
    ),
    DuskseerRobeTraining = make_skill(
        "DuskseerRobeTraining", "Passive",
        {{20, 2}, {25, 2}, {30, 2}}, NO_WEAPON
    ),
    DuskseerLightArmorTraining = make_skill(
        "DuskseerLightArmorTraining", "Passive",
        {{20, 2}, {25, 2}, {30, 2}}, NO_WEAPON
    ),
    DuskseerWeaponTraining = make_skill(
        "DuskseerWeaponTraining", "Passive",
        {{20, 1}, {25, 2}, {30, 2}}, NO_WEAPON
    ),
    DuskseerHealingLight = make_skill(
        "DuskseerHealingLight", "Support",
        {{20, 3}, {25, 3}, {30, 3}}, ARCANE_WAND
    ),
    DuskseerManaRecharge = make_skill(
        "DuskseerManaRecharge", "Support",
        {{30, 2}}, ARCANE_WAND
    ),
    DuskseerBattleMend = make_skill(
        "DuskseerBattleMend", "Support",
        {{20, 3}, {25, 3}, {30, 3}}, ARCANE_WAND
    ),
    DuskseerRevive = make_skill(
        "DuskseerRevive", "Support",
        {{20, 1}, {30, 1}}, ARCANE_WAND
    ),
    DuskseerGroupMend = make_skill(
        "DuskseerGroupMend", "Support",
        {{20, 3}, {25, 3}, {30, 3}}, ARCANE_WAND
    ),
    DuskseerExorcism = make_skill(
        "DuskseerExorcism", "Magic",
        {{20, 2}, {25, 2}, {30, 2}}, ARCANE_WAND
    ),
    DuskseerMindWard = make_skill(
        "DuskseerMindWard", "Support",
        {{25, 1}}, ARCANE_WAND
    ),
    DuskseerStoneWard = make_skill(
        "DuskseerStoneWard", "Support",
        {{25, 1}}, ARCANE_WAND
    ),
    DuskseerEmpower = make_skill(
        "DuskseerEmpower", "Support",
        {{25, 1}}, ARCANE_WAND
    ),
    DuskseerMight = make_skill(
        "DuskseerMight", "Support",
        {{20, 1}}, ARCANE_WAND
    ),
    DuskseerSlumber = make_skill(
        "DuskseerSlumber", "Control",
        {{25, 3}, {30, 3}}, ARCANE_WAND
    ),
    DuskseerBreathBlessing = make_skill(
        "DuskseerBreathBlessing", "Support",
        {{20, 1}}, ARCANE_WAND
    ),
    DuskseerFocus = make_skill(
        "DuskseerFocus", "Support",
        {{25, 1}}, ARCANE_WAND
    ),
    DuskseerConcentration = make_skill(
        "DuskseerConcentration", "Support",
        {{20, 1}, {30, 1}}, ARCANE_WAND
    ),
    DuskseerRootbind = make_skill(
        "DuskseerRootbind", "Control",
        {{25, 3}, {30, 3}}, ARCANE_WAND
    ),
    DuskseerWindstep = make_skill(
        "DuskseerWindstep", "Support",
        {{20, 1}, {30, 1}}, ARCANE_WAND
    ),
    DuskseerWindShackle = make_skill(
        "DuskseerWindShackle", "Control",
        {{20, 1}, {25, 1}, {30, 1}}, ARCANE_WAND
    ),
    DuskseerBloodRite = make_skill(
        "DuskseerBloodRite", "Support",
        {{30, 1}}, ARCANE_WAND
    ),
})

--[[
Returns one independently named Shillien Oracle definition.

Args:
    skill_id (string): DungeonMMO skill identifier.

Returns:
    any?: Frozen definition or nil for another class family.
]]
function ShillienOracleSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every Duskseer progression definition.

Args:
    None.

Returns:
    any: Frozen definition map.
]]
function ShillienOracleSkills.all(): any
    return DEFINITIONS
end

return table.freeze(ShillienOracleSkills)
