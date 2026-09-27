--!strict
-- Independent DungeonMMO Scavenger / Deepclaimer definitions through level 30.

local DwarfScavengerSkills = {}

local DWARF = table.freeze({"Dwarf"})
local FIGHTER = table.freeze({"Fighter"})
local DEEPCLAIMER = table.freeze({"Deepclaimer"})
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
Creates one Deepclaimer progression definition.

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
        AllowedFirstTransferClasses = DEEPCLAIMER,
        RankLevels = levels,
        WeaponTags = weapon_tags,
    })
end

local DEFINITIONS = table.freeze({
    DeepclaimerFieldBandage = make_skill(
        "DeepclaimerFieldBandage",
        "Support",
        {{20, 1}},
        NO_WEAPON
    ),
    DeepclaimerHammerShock = make_skill(
        "DeepclaimerHammerShock",
        "Physical",
        {{20, 3}, {24, 3}, {28, 3}},
        table.freeze({"OneHandedBlunt", "TwoHandedBlunt"})
    ),
    DeepclaimerRestorativeDiscipline = make_skill(
        "DeepclaimerRestorativeDiscipline",
        "Passive",
        {{24, 1}},
        NO_WEAPON
    ),
    DeepclaimerPackTraining = make_skill(
        "DeepclaimerPackTraining",
        "Passive",
        {{24, 1}},
        NO_WEAPON
    ),
    DeepclaimerBluntTraining = make_skill(
        "DeepclaimerBluntTraining",
        "Passive",
        {{20, 1}, {24, 1}, {28, 2}},
        NO_WEAPON
    ),
    DeepclaimerFortitude = make_skill(
        "DeepclaimerFortitude",
        "Passive",
        {{20, 1}, {28, 1}},
        NO_WEAPON
    ),
    DeepclaimerRecovery = make_skill(
        "DeepclaimerRecovery",
        "Passive",
        {{24, 1}},
        NO_WEAPON
    ),
    DeepclaimerPolearmTraining = make_skill(
        "DeepclaimerPolearmTraining",
        "Passive",
        {{20, 1}, {24, 1}, {28, 2}},
        NO_WEAPON
    ),
    DeepclaimerLightArmorTraining = make_skill(
        "DeepclaimerLightArmorTraining",
        "Passive",
        {{20, 2}, {24, 2}, {28, 3}},
        NO_WEAPON
    ),
    DeepclaimerHeavyArmorTraining = make_skill(
        "DeepclaimerHeavyArmorTraining",
        "Passive",
        {{20, 2}, {24, 2}, {28, 3}},
        NO_WEAPON
    ),
    DeepclaimerWildSweep = make_skill(
        "DeepclaimerWildSweep",
        "Physical",
        {{20, 3}, {24, 3}, {28, 3}},
        table.freeze({"Polearm"})
    ),
    DeepclaimerSalvageMark = make_skill(
        "DeepclaimerSalvageMark",
        "Utility",
        {{20, 1}, {28, 1}},
        NO_WEAPON
    ),
    DeepclaimerSalvageFestival = make_skill(
        "DeepclaimerSalvageFestival",
        "Utility",
        {{28, 1}},
        NO_WEAPON
    ),
})

--[[
Returns one Deepclaimer progression definition.

Args:
    skill_id (string): DungeonMMO skill identifier.

Returns:
    any?: Frozen definition or nil for another class family.
]]
function DwarfScavengerSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every Deepclaimer progression definition.

Args:
    None.

Returns:
    any: Frozen definition map.
]]
function DwarfScavengerSkills.all(): any
    return DEFINITIONS
end

return table.freeze(DwarfScavengerSkills)
