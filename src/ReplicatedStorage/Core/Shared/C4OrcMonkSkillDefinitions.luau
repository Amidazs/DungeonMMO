--!strict
-- Independent DungeonMMO Orc Monk progression definitions through level 30.

local OrcMonkSkills = {}

local ORC = table.freeze({"Orc"})
local FIGHTER = table.freeze({"Fighter"})
local SPIRITCLAW = table.freeze({"Spiritclaw"})
local FIST = table.freeze({"Fist", "DualFist"})
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
Creates one Spiritclaw progression definition.

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
        AllowedFirstTransferClasses = SPIRITCLAW,
        RankLevels = levels,
        WeaponTags = weapon_tags,
    })
end

local DEFINITIONS = table.freeze({
    SpiritclawIronFist = make_skill(
        "SpiritclawIronFist",
        "Physical",
        {{20, 3}, {24, 3}, {28, 3}},
        FIST
    ),
    SpiritclawForceFocus = make_skill(
        "SpiritclawForceFocus",
        "Support",
        {{24, 1}},
        FIST
    ),
    SpiritclawForceBurst = make_skill(
        "SpiritclawForceBurst",
        "Physical",
        {{24, 3}, {28, 3}},
        FIST
    ),
    SpiritclawBearAspect = make_skill(
        "SpiritclawBearAspect",
        "Support",
        {{28, 1}},
        NO_WEAPON
    ),
    SpiritclawWolfAspect = make_skill(
        "SpiritclawWolfAspect",
        "Support",
        {{20, 1}},
        NO_WEAPON
    ),
    SpiritclawCripplingPalm = make_skill(
        "SpiritclawCripplingPalm",
        "Control",
        {{20, 1}, {24, 1}, {28, 1}},
        FIST
    ),
    SpiritclawStunningFist = make_skill(
        "SpiritclawStunningFist",
        "Physical",
        {{20, 3}, {24, 3}, {28, 3}},
        FIST
    ),
    SpiritclawFistMastery = make_skill(
        "SpiritclawFistMastery",
        "Passive",
        {{20, 1}, {24, 1}, {28, 2}},
        NO_WEAPON
    ),
    SpiritclawLightArmorTraining = make_skill(
        "SpiritclawLightArmorTraining",
        "Passive",
        {{20, 2}, {24, 2}, {28, 2}},
        NO_WEAPON
    ),
    SpiritclawAgileMovement = make_skill(
        "SpiritclawAgileMovement",
        "Passive",
        {{20, 1}},
        NO_WEAPON
    ),
})

--[[
Returns one independent Orc Monk progression definition.

Args:
    skill_id (string): DungeonMMO skill identifier.

Returns:
    any?: Frozen definition or nil for another class family.
]]
function OrcMonkSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every Spiritclaw progression definition.

Args:
    None.

Returns:
    any: Frozen definition map.
]]
function OrcMonkSkills.all(): any
    return DEFINITIONS
end

return table.freeze(OrcMonkSkills)
