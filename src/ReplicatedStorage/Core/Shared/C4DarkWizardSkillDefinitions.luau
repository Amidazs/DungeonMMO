--!strict
-- Independently named Dark Wizard first-transfer training definitions.
-- These schedules preserve exact class-39 C4 rank brackets through level 30.

local DarkWizardSkills = {}

local DARK_MAGE = table.freeze({"Mage"})
local DARK_ELF = table.freeze({"DarkElf"})
local NIGHTWEAVER = table.freeze({"Nightweaver"})
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
Creates one Nightweaver progression definition.

Args:
    skill_id (string): DungeonMMO-facing skill identifier.
    kind (string): Progression family.
    schedule ({{number}}): Exact source training brackets.
    weapon_tags ({string}): Server-owned allowed weapon tags.
    extra (any?): Optional immutable metadata.

Returns:
    any: Frozen creative progression definition.
]]
local function make_skill(
    skill_id: string,
    kind: string,
    schedule: {{number}},
    weapon_tags: {string},
    extra: any?
): any
    local levels = build_rank_levels(schedule)
    local definition = {
        Id = skill_id,
        Tier = "Common",
        MaxRank = #levels,
        Kind = kind,
        AllowedBaseClasses = DARK_MAGE,
        AllowedRaces = DARK_ELF,
        AllowedFirstTransferClasses = NIGHTWEAVER,
        RankLevels = levels,
        WeaponTags = weapon_tags,
    }

    for key, value in pairs(extra or {}) do
        definition[key] = value
    end

    return table.freeze(definition)
end

local DEFINITIONS = table.freeze({
    NightweaverArcaneResistance = make_skill(
        "NightweaverArcaneResistance", "Passive",
        {{20, 2}, {25, 2}, {30, 2}}, NO_WEAPON, nil
    ),
    NightweaverQuickWeave = make_skill(
        "NightweaverQuickWeave", "Passive",
        {{20, 1}, {30, 1}}, NO_WEAPON, nil
    ),
    NightweaverManaReservoir = make_skill(
        "NightweaverManaReservoir", "Passive",
        {{20, 1}, {30, 1}}, NO_WEAPON, nil
    ),
    NightweaverRobeTraining = make_skill(
        "NightweaverRobeTraining", "Passive",
        {{20, 2}, {25, 2}, {30, 2}}, NO_WEAPON, nil
    ),
    NightweaverFocusTraining = make_skill(
        "NightweaverFocusTraining", "Passive",
        {{20, 1}, {25, 2}, {30, 2}}, NO_WEAPON, nil
    ),
    NightweaverManaChanneling = make_skill(
        "NightweaverManaChanneling", "Passive",
        {{20, 2}, {25, 2}, {30, 2}}, NO_WEAPON, nil
    ),
    NightweaverConcentration = make_skill(
        "NightweaverConcentration", "Support",
        {{20, 1}, {30, 1}}, ARCANE_WAND, nil
    ),
    NightweaverServitorHeal = make_skill(
        "NightweaverServitorHeal", "Support",
        {{20, 3}, {25, 3}, {30, 3}}, ARCANE_WAND,
        {RequiresOwnedCompanion = true}
    ),
    NightweaverShadowCompanion = make_skill(
        "NightweaverShadowCompanion", "Summon",
        {{20, 1}, {25, 1}, {30, 1}}, ARCANE_WAND,
        {SourceCompanionRole = "Combat"}
    ),
    NightweaverUmbralSiphon = make_skill(
        "NightweaverUmbralSiphon", "Magic",
        {{20, 2}, {25, 2}}, ARCANE_WAND, nil
    ),
    NightweaverVenomHex = make_skill(
        "NightweaverVenomHex", "Control",
        {{20, 1}, {30, 1}}, ARCANE_WAND, nil
    ),
    NightweaverFlameBurst = make_skill(
        "NightweaverFlameBurst", "Magic",
        {{20, 2}, {25, 2}, {30, 2}}, ARCANE_WAND, nil
    ),
    NightweaverGaleBolt = make_skill(
        "NightweaverGaleBolt", "Magic",
        {{20, 2}, {25, 2}, {30, 2}}, ARCANE_WAND, nil
    ),
    NightweaverEmberField = make_skill(
        "NightweaverEmberField", "Magic",
        {{20, 1}, {25, 1}, {30, 1}}, ARCANE_WAND, nil
    ),
    NightweaverFrostLance = make_skill(
        "NightweaverFrostLance", "Control",
        {{20, 2}}, ARCANE_WAND, nil
    ),
    NightweaverSilhouetteCompanion = make_skill(
        "NightweaverSilhouetteCompanion", "Summon",
        {{20, 1}, {25, 1}, {30, 1}}, ARCANE_WAND,
        {SourceCompanionRole = "Combat"}
    ),
    NightweaverFastCasting = make_skill(
        "NightweaverFastCasting", "Passive",
        {{25, 1}}, NO_WEAPON, nil
    ),
    NightweaverManaRecovery = make_skill(
        "NightweaverManaRecovery", "Passive",
        {{25, 1}}, NO_WEAPON, nil
    ),
    NightweaverSlumberHex = make_skill(
        "NightweaverSlumberHex", "Control",
        {{25, 3}, {30, 3}}, ARCANE_WAND, nil
    ),
    NightweaverServitorRecharge = make_skill(
        "NightweaverServitorRecharge", "Support",
        {{25, 2}, {30, 2}}, ARCANE_WAND,
        {RequiresOwnedCompanion = true}
    ),
    NightweaverBloodToMana = make_skill(
        "NightweaverBloodToMana", "Support",
        {{25, 1}}, ARCANE_WAND, nil
    ),
    NightweaverVenomCloud = make_skill(
        "NightweaverVenomCloud", "Control",
        {{25, 1}}, ARCANE_WAND, nil
    ),
    NightweaverVenomRend = make_skill(
        "NightweaverVenomRend", "Control",
        {{25, 1}, {30, 1}}, ARCANE_WAND, nil
    ),
    NightweaverShadowSpark = make_skill(
        "NightweaverShadowSpark", "Magic",
        {{25, 1}, {30, 1}}, ARCANE_WAND, nil
    ),
    NightweaverCorpseSiphon = make_skill(
        "NightweaverCorpseSiphon", "Support",
        {{30, 1}}, ARCANE_WAND, nil
    ),
})

--[[
Returns one independently named Dark Wizard progression definition.

Args:
    skill_id (string): DungeonMMO skill identifier.

Returns:
    any?: Frozen definition or nil for another class family.
]]
function DarkWizardSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every schedule-mapped Dark Wizard skill definition.

Args:
    None.

Returns:
    any: Frozen definition map for shared catalogue composition.
]]
function DarkWizardSkills.all(): any
    return DEFINITIONS
end

return table.freeze(DarkWizardSkills)
