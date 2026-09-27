--!strict
-- Independent DungeonMMO Orc Raider progression definitions through level 30.

local OrcRaiderSkills = {}

local ORC = table.freeze({"Orc"})
local FIGHTER = table.freeze({"Fighter"})
local WARHOWL = table.freeze({"Warhowl"})
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
Creates one Warhowl progression definition.

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
        AllowedRaces = ORC,
        AllowedBaseClasses = FIGHTER,
        AllowedFirstTransferClasses = WARHOWL,
        RankLevels = levels,
        WeaponTags = weapon_tags,
    })
end

local DEFINITIONS = table.freeze({
    WarhowlWoundbind = make_skill(
        "WarhowlWoundbind",
        "Support",
        {{20, 1}},
        NO_WEAPON
    ),
    WarhowlFury = make_skill(
        "WarhowlFury",
        "Support",
        {{24, 1}},
        NO_WEAPON
    ),
    WarhowlSkullbreaker = make_skill(
        "WarhowlSkullbreaker",
        "Physical",
        {{20, 3}, {24, 3}, {28, 3}},
        table.freeze({"OneHandedBlunt", "TwoHandedBlunt"})
    ),
    WarhowlWarRoar = make_skill(
        "WarhowlWarRoar",
        "Support",
        {{28, 1}},
        NO_WEAPON
    ),
    WarhowlEndurance = make_skill(
        "WarhowlEndurance",
        "Passive",
        {{24, 1}},
        NO_WEAPON
    ),
    WarhowlBloodFortitude = make_skill(
        "WarhowlBloodFortitude",
        "Passive",
        {{20, 1}, {28, 1}},
        NO_WEAPON
    ),
    WarhowlRecovery = make_skill(
        "WarhowlRecovery",
        "Passive",
        {{24, 1}},
        NO_WEAPON
    ),
    WarhowlPolearmTraining = make_skill(
        "WarhowlPolearmTraining",
        "Passive",
        {{20, 1}, {24, 1}, {28, 2}},
        NO_WEAPON
    ),
    WarhowlLightArmorTraining = make_skill(
        "WarhowlLightArmorTraining",
        "Passive",
        {{20, 2}, {24, 2}, {28, 3}},
        NO_WEAPON
    ),
    WarhowlHeavyArmorTraining = make_skill(
        "WarhowlHeavyArmorTraining",
        "Passive",
        {{20, 2}, {24, 2}, {28, 3}},
        NO_WEAPON
    ),
    WarhowlSweepingArc = make_skill(
        "WarhowlSweepingArc",
        "Physical",
        {{20, 3}, {24, 3}, {28, 3}},
        table.freeze({"Polearm"})
    ),
    WarhowlCrushingBlow = make_skill(
        "WarhowlCrushingBlow",
        "Physical",
        {{20, 3}, {24, 3}, {28, 3}},
        table.freeze({"OneHandedSword", "OneHandedBlunt"})
    ),
    WarhowlPrecisionStance = make_skill(
        "WarhowlPrecisionStance",
        "Support",
        {{24, 1}},
        NO_WEAPON
    ),
    WarhowlSteelAndStoneTraining = make_skill(
        "WarhowlSteelAndStoneTraining",
        "Passive",
        {{20, 1}, {24, 1}, {28, 2}},
        NO_WEAPON
    ),
    WarhowlGreatWeaponTraining = make_skill(
        "WarhowlGreatWeaponTraining",
        "Passive",
        {{20, 1}, {24, 1}, {28, 1}},
        NO_WEAPON
    ),
    WarhowlPredatorStance = make_skill(
        "WarhowlPredatorStance",
        "Support",
        {{20, 1}, {24, 1}, {28, 1}},
        NO_WEAPON
    ),
})

--[[
Returns one independent Orc Raider progression definition.

Args:
    skill_id (string): DungeonMMO skill identifier.

Returns:
    any?: Frozen definition or nil for another class family.
]]
function OrcRaiderSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every Warhowl progression definition.

Args:
    None.

Returns:
    any: Frozen definition map.
]]
function OrcRaiderSkills.all(): any
    return DEFINITIONS
end

return table.freeze(OrcRaiderSkills)
