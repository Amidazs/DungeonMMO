--!strict
-- Independently named Elven Wizard first-transfer training definitions.

local ElvenWizardSkills = {}

local MAGE = table.freeze({"Mage"})
local ELF = table.freeze({"Elf"})
local MOONWEAVER = table.freeze({"Moonweaver"})
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
Creates one Elven Wizard progression definition.

Args:
    skill_id (string): DungeonMMO-facing skill identifier.
    kind (string): Progression skill family.
    schedule ({{number}}): Exact level/count source brackets.
    weapon_tags ({string}): Server-owned allowed weapon tags.
    extra (any?): Optional immutable skill metadata.

Returns:
    any: Frozen progression definition.
]]
local function make_skill(
    skill_id: string,
    kind: string,
    schedule: {{number}},
    weapon_tags: {string},
    extra: any?
): any
    local definition = {
        Id = skill_id,
        Tier = "Common",
        MaxRank = #build_rank_levels(schedule),
        Kind = kind,
        AllowedBaseClasses = MAGE,
        AllowedRaces = ELF,
        AllowedFirstTransferClasses = MOONWEAVER,
        RankLevels = build_rank_levels(schedule),
        WeaponTags = weapon_tags,
    }

    for key, value in pairs(extra or {}) do
        definition[key] = value
    end

    return table.freeze(definition)
end

local DEFINITIONS = table.freeze({
    MoonweaverArcaneResistance = make_skill(
        "MoonweaverArcaneResistance",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON,
        nil
    ),
    MoonweaverQuickWeave = make_skill(
        "MoonweaverQuickWeave",
        "Passive",
        {{20, 1}, {30, 1}},
        NO_WEAPON,
        nil
    ),
    MoonweaverManaReservoir = make_skill(
        "MoonweaverManaReservoir",
        "Passive",
        {{20, 1}, {30, 1}},
        NO_WEAPON,
        nil
    ),
    MoonweaverFastCasting = make_skill(
        "MoonweaverFastCasting",
        "Passive",
        {{25, 1}},
        NO_WEAPON,
        nil
    ),
    MoonweaverManaRecovery = make_skill(
        "MoonweaverManaRecovery",
        "Passive",
        {{25, 1}},
        NO_WEAPON,
        nil
    ),
    MoonweaverRobeTraining = make_skill(
        "MoonweaverRobeTraining",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON,
        nil
    ),
    MoonweaverFocusTraining = make_skill(
        "MoonweaverFocusTraining",
        "Passive",
        {{20, 1}, {25, 2}, {30, 2}},
        NO_WEAPON,
        nil
    ),
    MoonweaverManaChanneling = make_skill(
        "MoonweaverManaChanneling",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON,
        nil
    ),
    MoonweaverSlumberHex = make_skill(
        "MoonweaverSlumberHex",
        "Control",
        {{25, 3}, {30, 3}},
        ARCANE_WAND,
        nil
    ),
    MoonweaverConcentration = make_skill(
        "MoonweaverConcentration",
        "Passive",
        {{20, 1}, {30, 1}},
        NO_WEAPON,
        nil
    ),
    MoonweaverServitorRecharge = make_skill(
        "MoonweaverServitorRecharge",
        "Support",
        {{25, 2}, {30, 2}},
        ARCANE_WAND,
        {RequiresOwnedCompanion = true}
    ),
    MoonweaverServitorHeal = make_skill(
        "MoonweaverServitorHeal",
        "Support",
        {{20, 3}, {25, 3}, {30, 3}},
        ARCANE_WAND,
        {RequiresOwnedCompanion = true}
    ),
    MoonweaverWitheringHex = make_skill(
        "MoonweaverWitheringHex",
        "Control",
        {{20, 1}, {25, 1}, {30, 1}},
        ARCANE_WAND,
        nil
    ),
    MoonweaverFlameBurst = make_skill(
        "MoonweaverFlameBurst",
        "Magic",
        {{20, 2}, {25, 2}, {30, 2}},
        ARCANE_WAND,
        nil
    ),
    MoonweaverTidalBolt = make_skill(
        "MoonweaverTidalBolt",
        "Magic",
        {{20, 2}, {25, 2}, {30, 2}},
        ARCANE_WAND,
        nil
    ),
    MoonweaverEmberField = make_skill(
        "MoonweaverEmberField",
        "Magic",
        {{20, 1}, {25, 1}, {30, 1}},
        ARCANE_WAND,
        nil
    ),
    MoonweaverTidalWard = make_skill(
        "MoonweaverTidalWard",
        "Support",
        {{25, 1}},
        ARCANE_WAND,
        nil
    ),
    MoonweaverFrostLance = make_skill(
        "MoonweaverFrostLance",
        "Control",
        {{20, 2}},
        ARCANE_WAND,
        nil
    ),
    MoonweaverManaCompanion = make_skill(
        "MoonweaverManaCompanion",
        "Summon",
        {{20, 1}, {25, 1}, {30, 1}},
        ARCANE_WAND,
        {SourceCompanionRole = "Mana"}
    ),
    MoonweaverCombatCompanion = make_skill(
        "MoonweaverCombatCompanion",
        "Summon",
        {{20, 1}, {25, 1}, {30, 1}},
        ARCANE_WAND,
        {SourceCompanionRole = "Combat"}
    ),
    MoonweaverSolarSpark = make_skill(
        "MoonweaverSolarSpark",
        "Magic",
        {{25, 1}, {30, 1}},
        ARCANE_WAND,
        nil
    ),
    MoonweaverFocusedBolt = make_skill(
        "MoonweaverFocusedBolt",
        "Magic",
        {{20, 1}, {25, 1}, {30, 1}},
        ARCANE_WAND,
        nil
    ),
})

--[[
Returns one independently named Elven Wizard progression definition.

Args:
    skill_id (string): DungeonMMO skill identifier.

Returns:
    any?: Frozen definition, or nil for another class family.
]]
function ElvenWizardSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every schedule-mapped Elven Wizard skill definition.

Args:
    None.

Returns:
    any: Frozen definition map for shared catalogue composition.
]]
function ElvenWizardSkills.all(): any
    return DEFINITIONS
end

return table.freeze(ElvenWizardSkills)
