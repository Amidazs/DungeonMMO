--!strict
-- Independently named Palus Knight first-transfer training definitions.

local PalusKnightSkills = {}

local DARK_FIGHTER = table.freeze({"Fighter"})
local DARK_ELF = table.freeze({"DarkElf"})
local DUSKGUARD = table.freeze({"Duskguard"})
local SWORD = table.freeze({"OneHandedSword"})
local SWORD_OR_DAGGER = table.freeze({
    "OneHandedSword",
    "Dagger",
    "DualSword",
})
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
Creates one Palus Knight progression definition.

Args:
    skill_id (string): DungeonMMO-facing skill identifier.
    kind (string): Progression family.
    schedule ({{number}}): Exact level/count training brackets.
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
        AllowedBaseClasses = DARK_FIGHTER,
        AllowedRaces = DARK_ELF,
        AllowedFirstTransferClasses = DUSKGUARD,
        RankLevels = levels,
        WeaponTags = weapon_tags,
    })
end

local DEFINITIONS = table.freeze({
    DuskguardUmbralSiphon = make_skill(
        "DuskguardUmbralSiphon",
        "Magic",
        {{20, 2}, {24, 3}, {28, 3}},
        NO_WEAPON
    ),
    DuskguardDefenseAura = make_skill(
        "DuskguardDefenseAura",
        "Support",
        {{20, 1}},
        NO_WEAPON
    ),
    DuskguardLastStand = make_skill(
        "DuskguardLastStand",
        "Support",
        {{20, 1}},
        NO_WEAPON
    ),
    DuskguardVenomHex = make_skill(
        "DuskguardVenomHex",
        "Control",
        {{20, 1}},
        NO_WEAPON
    ),
    DuskguardRunicResistance = make_skill(
        "DuskguardRunicResistance",
        "Passive",
        {{20, 2}, {24, 3}, {28, 3}},
        NO_WEAPON
    ),
    DuskguardShieldMastery = make_skill(
        "DuskguardShieldMastery",
        "Passive",
        {{20, 1}, {28, 1}},
        NO_WEAPON
    ),
    DuskguardSteelTraining = make_skill(
        "DuskguardSteelTraining",
        "Passive",
        {{20, 1}, {24, 1}, {28, 2}},
        SWORD
    ),
    DuskguardHeavyArmorTraining = make_skill(
        "DuskguardHeavyArmorTraining",
        "Passive",
        {{20, 3}, {24, 3}, {28, 3}},
        NO_WEAPON
    ),
    DuskguardMindRend = make_skill(
        "DuskguardMindRend",
        "Control",
        {{24, 1}, {28, 1}},
        NO_WEAPON
    ),
    DuskguardChallenge = make_skill(
        "DuskguardChallenge",
        "Control",
        {{24, 3}, {28, 3}},
        NO_WEAPON
    ),
    DuskguardArrowWard = make_skill(
        "DuskguardArrowWard",
        "Support",
        {{24, 1}},
        NO_WEAPON
    ),
    DuskguardCrimsonSting = make_skill(
        "DuskguardCrimsonSting",
        "Physical",
        {{24, 3}, {28, 3}},
        SWORD_OR_DAGGER
    ),
    DuskguardAttackAura = make_skill(
        "DuskguardAttackAura",
        "Support",
        {{28, 1}},
        NO_WEAPON
    ),
})

--[[
Returns one Palus Knight creative progression definition.

Args:
    skill_id (string): DungeonMMO skill identifier.

Returns:
    any?: Frozen definition or nil.
]]
function PalusKnightSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every Palus Knight creative progression definition.

Args:
    None.

Returns:
    any: Frozen definition map.
]]
function PalusKnightSkills.all(): any
    return DEFINITIONS
end

return table.freeze(PalusKnightSkills)
