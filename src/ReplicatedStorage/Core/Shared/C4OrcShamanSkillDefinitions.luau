--!strict
-- Independently named Orc Shaman first-transfer training definitions.

local OrcShamanSkills = {}

local ORC = table.freeze({"Orc"})
local MAGE = table.freeze({"Mage"})
local ASHSPEAKER = table.freeze({"Ashspeaker"})
local NO_WEAPON = table.freeze({})
local BLUNT = table.freeze({"OneHandedBlunt", "TwoHandedBlunt"})

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
Creates one Ashspeaker progression definition.

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
        AllowedBaseClasses = MAGE,
        AllowedRaces = ORC,
        AllowedFirstTransferClasses = ASHSPEAKER,
        RankLevels = levels,
        WeaponTags = weapon_tags,
    })
end

local DEFINITIONS = table.freeze({
    AshspeakerSkullshock = make_skill(
        "AshspeakerSkullshock",
        "Physical",
        {{20, 3}, {25, 3}, {30, 3}},
        BLUNT
    ),
    AshspeakerArcaneResistance = make_skill(
        "AshspeakerArcaneResistance",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON
    ),
    AshspeakerQuickPrayer = make_skill(
        "AshspeakerQuickPrayer",
        "Passive",
        {{20, 1}, {30, 1}},
        NO_WEAPON
    ),
    AshspeakerManaReservoir = make_skill(
        "AshspeakerManaReservoir",
        "Passive",
        {{20, 1}, {30, 1}},
        NO_WEAPON
    ),
    AshspeakerFastCasting = make_skill(
        "AshspeakerFastCasting",
        "Passive",
        {{25, 1}},
        NO_WEAPON
    ),
    AshspeakerManaRecovery = make_skill(
        "AshspeakerManaRecovery",
        "Passive",
        {{25, 1}},
        NO_WEAPON
    ),
    AshspeakerWeaponTraining = make_skill(
        "AshspeakerWeaponTraining",
        "Passive",
        {{20, 1}, {25, 2}, {30, 2}},
        NO_WEAPON
    ),
    AshspeakerRobeTraining = make_skill(
        "AshspeakerRobeTraining",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON
    ),
    AshspeakerLightArmorTraining = make_skill(
        "AshspeakerLightArmorTraining",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON
    ),
    AshspeakerHeavyArmorTraining = make_skill(
        "AshspeakerHeavyArmorTraining",
        "Passive",
        {{20, 2}, {25, 2}, {30, 2}},
        NO_WEAPON
    ),
    AshspeakerSoulCry = make_skill(
        "AshspeakerSoulCry",
        "Support",
        {{25, 1}},
        NO_WEAPON
    ),
    AshspeakerFlameChant = make_skill(
        "AshspeakerFlameChant",
        "Support",
        {{30, 1}},
        NO_WEAPON
    ),
    AshspeakerWarPower = make_skill(
        "AshspeakerWarPower",
        "Support",
        {{30, 1}},
        NO_WEAPON
    ),
    AshspeakerFireChant = make_skill(
        "AshspeakerFireChant",
        "Support",
        {{20, 1}},
        NO_WEAPON
    ),
    AshspeakerBattleChant = make_skill(
        "AshspeakerBattleChant",
        "Support",
        {{25, 1}},
        NO_WEAPON
    ),
    AshspeakerShieldingChant = make_skill(
        "AshspeakerShieldingChant",
        "Support",
        {{20, 1}, {30, 1}},
        NO_WEAPON
    ),
    AshspeakerSoulShield = make_skill(
        "AshspeakerSoulShield",
        "Support",
        {{25, 1}},
        NO_WEAPON
    ),
    AshspeakerLifeDrain = make_skill(
        "AshspeakerLifeDrain",
        "Magic",
        {{20, 1}, {25, 1}, {30, 1}},
        NO_WEAPON
    ),
    AshspeakerFear = make_skill(
        "AshspeakerFear",
        "Control",
        {{20, 1}, {25, 1}, {30, 1}},
        NO_WEAPON
    ),
    AshspeakerVenom = make_skill(
        "AshspeakerVenom",
        "Magic",
        {{20, 1}},
        NO_WEAPON
    ),
    AshspeakerChaosSeal = make_skill(
        "AshspeakerChaosSeal",
        "Control",
        {{30, 1}},
        NO_WEAPON
    ),
    AshspeakerDreamingSpirit = make_skill(
        "AshspeakerDreamingSpirit",
        "Control",
        {{20, 1}, {25, 1}, {30, 1}},
        NO_WEAPON
    ),
    AshspeakerBlazeQuake = make_skill(
        "AshspeakerBlazeQuake",
        "Magic",
        {{25, 1}},
        NO_WEAPON
    ),
    AshspeakerAuraSink = make_skill(
        "AshspeakerAuraSink",
        "Control",
        {{25, 1}},
        NO_WEAPON
    ),
    AshspeakerMadness = make_skill(
        "AshspeakerMadness",
        "Control",
        {{20, 1}, {25, 1}, {30, 1}},
        NO_WEAPON
    ),
    AshspeakerFrostFlame = make_skill(
        "AshspeakerFrostFlame",
        "Magic",
        {{20, 1}, {30, 1}},
        NO_WEAPON
    ),
    AshspeakerBindingSeal = make_skill(
        "AshspeakerBindingSeal",
        "Control",
        {{25, 1}, {30, 1}},
        NO_WEAPON
    ),
    AshspeakerPoisonSeal = make_skill(
        "AshspeakerPoisonSeal",
        "Magic",
        {{20, 1}, {30, 1}},
        NO_WEAPON
    ),
    AshspeakerLifeChant = make_skill(
        "AshspeakerLifeChant",
        "Support",
        {{20, 1}, {25, 1}, {30, 1}},
        NO_WEAPON
    ),
})

--[[
Returns one independently named Orc Shaman definition.

Args:
    skill_id (string): DungeonMMO skill identifier.

Returns:
    any?: Frozen definition or nil for another class family.
]]
function OrcShamanSkills.get(skill_id: string): any?
    return DEFINITIONS[skill_id]
end

--[[
Returns every Ashspeaker progression definition.

Args:
    None.

Returns:
    any: Frozen definition map.
]]
function OrcShamanSkills.all(): any
    return DEFINITIONS
end

return table.freeze(OrcShamanSkills)
