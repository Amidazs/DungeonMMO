--!strict
-- Independent DungeonMMO Artisan / Gearwright definitions through level 30.

local DwarfArtisanSkills = {}

local DWARF = table.freeze({"Dwarf"})
local FIGHTER = table.freeze({"Fighter"})
local GEARWRIGHT = table.freeze({"Gearwright"})
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
Creates one Gearwright progression definition.

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
        AllowedRaces = DWARF,
        AllowedBaseClasses = FIGHTER,
        AllowedFirstTransferClasses = GEARWRIGHT,
        RankLevels = levels,
        WeaponTags = weapon_tags,
    })
end

local DEFINITIONS = table.freeze({
    GearwrightClockworkGolem = make_skill(
        "GearwrightClockworkGolem",
        "Utility",
        {{28, 1}},
        NO_WEAPON
    ),
    GearwrightFieldBandage = make_skill(
        "GearwrightFieldBandage",
        "Support",
        {{20, 1}},
        NO_WEAPON
    ),
    GearwrightHammerShock = make_skill(
        "GearwrightHammerShock",
        "Physical",
        {{20, 3}, {24, 3}, {28, 3}},
        table.freeze({"OneHandedBlunt", "TwoHandedBlunt"})
    ),
    GearwrightRestorativeDiscipline = make_skill(
        "GearwrightRestorativeDiscipline",
        "Passive",
        {{24, 1}},
        NO_WEAPON
    ),
    GearwrightPackTraining = make_skill(
        "GearwrightPackTraining",
        "Passive",
        {{24, 1}},
        NO_WEAPON
    ),
    GearwrightBlueprintTraining = make_skill(
        "GearwrightBlueprintTraining",
        "Passive",
        {{20, 1}, {28, 1}},
        NO_WEAPON
    ),
    GearwrightBluntTraining = make_skill(
        "GearwrightBluntTraining",
        "Passive",
        {{20, 1}, {24, 1}, {28, 2}},
        NO_WEAPON
    ),
    GearwrightFortitude = make_skill(
        "GearwrightFortitude",
        "Passive",
        {{20, 1}, {28, 1}},
        NO_WEAPON
    ),
    GearwrightRecovery = make_skill(
        "GearwrightRecovery",
        "Passive",
        {{24, 1}},
        NO_WEAPON
    ),
    GearwrightPolearmTraining = make_skill(
        "GearwrightPolearmTraining",
        "Passive",
        {{20, 1}, {24, 1}, {28, 2}},
        NO_WEAPON
    ),
    GearwrightLightArmorTraining = make_skill(
        "GearwrightLightArmorTraining",
        "Passive",
        {{20, 2}, {24, 2}, {28, 3}},
        NO_WEAPON
    ),
    GearwrightHeavyArmorTraining = make_skill(
        "GearwrightHeavyArmorTraining",
        "Passive",
        {{20, 2}, {24, 2}, {28, 3}},
        NO_WEAPON
    ),
    GearwrightWildSweep = make_skill(
        "GearwrightWildSweep",
        "Physical",
        {{20, 3}, {24, 3}, {28, 3}},
        table.freeze({"Polearm"})
    ),
    GearwrightCrystallize = make_skill(
        "GearwrightCrystallize",
        "Utility",
        {{20, 1}},
        NO_WEAPON
    ),
})

--[[
Returns one Gearwright progression definition.

Args:
    skill_id (string): DungeonMMO skill identifier.

Returns:
    any?: Frozen definition or nil for another class family.
]]
function DwarfArtisanSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every Gearwright progression definition.

Args:
    None.

Returns:
    any: Frozen definition map.
]]
function DwarfArtisanSkills.all(): any
    return DEFINITIONS
end

return table.freeze(DwarfArtisanSkills)
