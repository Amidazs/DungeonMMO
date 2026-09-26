--!strict
-- Independently named Human Wizard first-transfer training definitions.
-- These definitions map C4 training schedules only. Combat/summon effects
-- remain separately gated and are not certified by rank-row coverage.

local HumanWizardSkills = {}

local HUMAN_MAGE = table.freeze({"Mage"})
local HUMAN_RACE = table.freeze({"Human"})
local EMBERWEAVER = table.freeze({"Emberweaver"})
local ARCANE_WAND = table.freeze({"ArcaneWand"})
local NO_WEAPON = table.freeze({})

--[[
Expands compact level/count pairs into a rank-indexed training schedule.

Args:
    schedule ({{number}}): Ordered {level, count} source training brackets.

Returns:
    {[number]: number}: Rank number to required character level.
]]
local function build_rank_levels(schedule: {{number}}): {[number]: number}
    local levels = {}
    local rank = 1

    for _, entry in ipairs(schedule) do
        local level = entry[1]
        local count = entry[2]

        for _ = 1, count do
            levels[rank] = level
            rank += 1
        end
    end

    return table.freeze(levels)
end

--[[
Creates one schedule-mapped Human Wizard first-transfer skill definition.

Args:
    skill_id (string): Original DungeonMMO player-facing skill identifier.
    kind (string): Existing progression skill family.
    schedule ({{number}}): Ordered {level, count} training brackets.
    weapon_tags ({string}): Server-owned allowed weapon tags.
    extra (any?): Optional immutable metadata merged into the definition.

Returns:
    any: Frozen progression definition with exact source rank levels.
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
        AllowedBaseClasses = HUMAN_MAGE,
        AllowedRaces = HUMAN_RACE,
        AllowedFirstTransferClasses = EMBERWEAVER,
        RankLevels = levels,
        WeaponTags = weapon_tags,
    }

    for key, value in pairs(extra or {}) do
        definition[key] = value
    end

    return table.freeze(definition)
end

local DEFINITIONS = table.freeze({
    EmberweaverEquipmentExpertise = make_skill(
        "EmberweaverEquipmentExpertise",
        "Passive",
        {{20, 1}},
        NO_WEAPON,
        {AdvancedEquipmentEnabled = true}
    ),
    EmberweaverCommonItemCreation = make_skill(
        "EmberweaverCommonItemCreation",
        "Passive",
        {{20, 1}, {28, 1}},
        NO_WEAPON,
        {
            RequiresCraftingProfessionChoice = true,
            Prerequisites = table.freeze({
                table.freeze({
                    SkillId = "C4CommonItemCreation",
                    Rank = 1,
                    Proficiency = 0,
                }),
            }),
        }
    ),
    EmberweaverFocusTraining = make_skill(
        "EmberweaverFocusTraining",
        "Passive",
        {{20, 1}, {25, 2}, {30, 2}},
        NO_WEAPON,
        nil
    ),
    EmberweaverRobeTraining = make_skill(
        "EmberweaverRobeTraining",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON,
        nil
    ),
    EmberweaverArcaneResistance = make_skill(
        "EmberweaverArcaneResistance",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON,
        nil
    ),
    EmberweaverManaChanneling = make_skill(
        "EmberweaverManaChanneling",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON,
        nil
    ),
    EmberweaverManaReservoir = make_skill(
        "EmberweaverManaReservoir",
        "Passive",
        {{20, 1}, {30, 1}},
        NO_WEAPON,
        nil
    ),
    EmberweaverQuickWeave = make_skill(
        "EmberweaverQuickWeave",
        "Passive",
        {{20, 1}, {30, 1}},
        NO_WEAPON,
        nil
    ),
    EmberweaverFrostLance = make_skill(
        "EmberweaverFrostLance",
        "Control",
        {{20, 2}},
        ARCANE_WAND,
        nil
    ),
    EmberweaverLifeSiphon = make_skill(
        "EmberweaverLifeSiphon",
        "Magic",
        {{20, 2}, {25, 2}},
        ARCANE_WAND,
        nil
    ),
    EmberweaverEmberBolt = make_skill(
        "EmberweaverEmberBolt",
        "Magic",
        {{20, 2}, {25, 2}, {30, 2}},
        ARCANE_WAND,
        nil
    ),
    EmberweaverFlameBurst = make_skill(
        "EmberweaverFlameBurst",
        "Magic",
        {{20, 2}, {25, 2}, {30, 2}},
        ARCANE_WAND,
        nil
    ),
    EmberweaverWitheringHex = make_skill(
        "EmberweaverWitheringHex",
        "Control",
        {{20, 1}, {25, 1}, {30, 1}},
        ARCANE_WAND,
        nil
    ),
    EmberweaverFocusedBolt = make_skill(
        "EmberweaverFocusedBolt",
        "Magic",
        {{20, 1}, {25, 1}, {30, 1}},
        ARCANE_WAND,
        nil
    ),
    EmberweaverEmberField = make_skill(
        "EmberweaverEmberField",
        "Magic",
        {{20, 1}, {25, 1}, {30, 1}},
        ARCANE_WAND,
        nil
    ),
    EmberweaverVenomHex = make_skill(
        "EmberweaverVenomHex",
        "Control",
        {{20, 1}, {30, 1}},
        ARCANE_WAND,
        nil
    ),
    EmberweaverConcentration = make_skill(
        "EmberweaverConcentration",
        "Passive",
        {{20, 1}, {30, 1}},
        NO_WEAPON,
        nil
    ),
    EmberweaverFastCasting = make_skill(
        "EmberweaverFastCasting",
        "Passive",
        {{25, 1}},
        NO_WEAPON,
        nil
    ),
    EmberweaverManaRecovery = make_skill(
        "EmberweaverManaRecovery",
        "Passive",
        {{25, 1}},
        NO_WEAPON,
        nil
    ),
    EmberweaverSlumberHex = make_skill(
        "EmberweaverSlumberHex",
        "Control",
        {{25, 3}, {30, 3}},
        ARCANE_WAND,
        nil
    ),
    EmberweaverScorchMark = make_skill(
        "EmberweaverScorchMark",
        "Control",
        {{25, 1}, {30, 1}},
        ARCANE_WAND,
        nil
    ),
    EmberweaverVenomCloud = make_skill(
        "EmberweaverVenomCloud",
        "Control",
        {{25, 1}},
        ARCANE_WAND,
        nil
    ),
    EmberweaverBloodToMana = make_skill(
        "EmberweaverBloodToMana",
        "Support",
        {{25, 1}},
        ARCANE_WAND,
        nil
    ),
    EmberweaverCorpseSiphon = make_skill(
        "EmberweaverCorpseSiphon",
        "Support",
        {{30, 1}},
        ARCANE_WAND,
        nil
    ),
    EmberweaverManaCompanion = make_skill(
        "EmberweaverManaCompanion",
        "Summon",
        {{20, 1}, {25, 1}, {30, 1}},
        ARCANE_WAND,
        {SourceCompanionRole = "Mana"}
    ),
    EmberweaverServitorRecharge = make_skill(
        "EmberweaverServitorRecharge",
        "Support",
        {{25, 2}, {30, 2}},
        ARCANE_WAND,
        {RequiresOwnedCompanion = true}
    ),
    EmberweaverServitorHeal = make_skill(
        "EmberweaverServitorHeal",
        "Support",
        {{20, 3}, {25, 3}, {30, 3}},
        ARCANE_WAND,
        {RequiresOwnedCompanion = true}
    ),
    EmberweaverCombatCompanion = make_skill(
        "EmberweaverCombatCompanion",
        "Summon",
        {{20, 1}, {25, 1}, {30, 1}},
        ARCANE_WAND,
        {SourceCompanionRole = "Combat"}
    ),
})

--[[
Returns one independently named Human Wizard progression definition.

Args:
    skill_id (string): DungeonMMO skill identifier.

Returns:
    any?: Frozen definition, or nil for another class family.
]]
function HumanWizardSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every schedule-mapped Human Wizard skill definition.

Args:
    None.

Returns:
    any: Frozen definition map for shared catalogue composition.
]]
function HumanWizardSkills.all(): any
    return DEFINITIONS
end

return table.freeze(HumanWizardSkills)
