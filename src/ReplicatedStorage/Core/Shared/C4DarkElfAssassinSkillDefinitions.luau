--!strict
-- Independently named Dark Elf Assassin first-transfer skill definitions.

local AssassinSkills = {}

local DARK_FIGHTER = table.freeze({"Fighter"})
local DARK_ELF = table.freeze({"DarkElf"})
local VEILBLADE = table.freeze({"Veilblade"})
local NO_WEAPON = table.freeze({})
local SWORD_OR_DAGGER = table.freeze({
    "OneHandedSword",
    "Dagger",
    "DualSword",
})

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
Creates one Veilblade progression definition.

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
        AllowedFirstTransferClasses = VEILBLADE,
        RankLevels = levels,
        WeaponTags = weapon_tags,
    })
end

local DEFINITIONS = table.freeze({
    VeilbladeMindRend = make_skill(
        "VeilbladeMindRend",
        "Control",
        {{24, 1}, {28, 1}},
        NO_WEAPON
    ),
    VeilbladeUmbralSiphon = make_skill(
        "VeilbladeUmbralSiphon",
        "Magic",
        {{20, 2}, {24, 3}, {28, 3}},
        NO_WEAPON
    ),
    VeilbladeDefenseAura = make_skill(
        "VeilbladeDefenseAura",
        "Support",
        {{20, 1}},
        NO_WEAPON
    ),
    VeilbladeVenomHex = make_skill(
        "VeilbladeVenomHex",
        "Control",
        {{20, 1}},
        NO_WEAPON
    ),
    VeilbladeCriticalPower = make_skill(
        "VeilbladeCriticalPower",
        "Passive",
        {{24, 1}},
        NO_WEAPON
    ),
    VeilbladeCrimsonSting = make_skill(
        "VeilbladeCrimsonSting",
        "Physical",
        {{24, 3}, {28, 3}},
        SWORD_OR_DAGGER
    ),
    VeilbladeAttackAura = make_skill(
        "VeilbladeAttackAura",
        "Support",
        {{28, 1}},
        NO_WEAPON
    ),
})

--[[
Returns one Dark Elf Assassin creative progression definition.

Args:
    skill_id (string): DungeonMMO skill identifier.

Returns:
    any?: Frozen definition or nil.
]]
function AssassinSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every Dark Elf Assassin-specific progression definition.

Args:
    None.

Returns:
    any: Frozen definition map.
]]
function AssassinSkills.all(): any
    return DEFINITIONS
end

return table.freeze(AssassinSkills)
