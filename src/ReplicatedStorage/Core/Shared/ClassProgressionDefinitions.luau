--!strict
local ClassProgressionDefinitions = {}

local HUMAN_ELF = table.freeze({"Human", "Elf"})

local DEFINITIONS = table.freeze({
    Fighter = table.freeze({
        Id = "Fighter",
        AllowedRaces = HUMAN_ELF,
        StarterSkills = table.freeze({
            "ShieldBash",
            "Mend",
        }),
        StarterEquipment = table.freeze({}),
        TeachableSkills = table.freeze({
            "ArcSlash",
            "Taunt",
            "GuardBreaker",
            "IronCleave",
            "FighterBowShot",
            "FighterDaggerStrike",
            "PursuitStep",
            "IronDiscipline",
            "FighterPhysicalTraining",
            "FighterArmorTraining",
            "StalwartTraining",
        }),
    }),

    Mage = table.freeze({
        Id = "Mage",
        AllowedRaces = HUMAN_ELF,
        StarterSkills = table.freeze({
            "WindStrike",
            "ArcaneWard",
            "MageHeal",
        }),
        StarterEquipment = table.freeze({
            Weapon = "apprentice_arcane_wand",
        }),
        TeachableSkills = table.freeze({
            "DawnWard",
            "CinderBolt",
            "MysticWindBolt",
            "MysticHealingPrayer",
            "MysticWeaponTraining",
            "MysticArmorTraining",
            "MysticSpellResistance",
            "AetherBolt",
            "RenewingLight",
            "ArcaneDiscipline",
            "RestorativeTraining",
        }),
    }),

    Ranger = table.freeze({
        Id = "Ranger",
        AllowedRaces = HUMAN_ELF,
        StarterSkills = table.freeze({
            "PiercingShot",
            "CripplingShot",
            "Volley",
        }),
        StarterEquipment = table.freeze({
            Weapon = "apprentice_longbow",
            Body = "scout_leather_vest",
        }),
        TeachableSkills = table.freeze({
            "TrackerShot",
            "BriarVolley",
            "ThunderShot",
            "ScoutFocusedShot",
            "ArcherDraw",
            "RangerBowMastery",
            "ScoutBowDiscipline",
            "RangerLongRange",
            "RangerArrowVelocity",
            "ScoutLightArmorMastery",
            "ScoutFleetFoot",
            "HumanScoutRapidHands",
            "HumanScoutCriticalPower",
            "HumanScoutPrecision",
            "ElvenScoutPrecision",
            "ElvenRenewal",
            "ElvenCalmingShot",
        }),
    }),

    Rogue = table.freeze({
        Id = "Rogue",
        AllowedRaces = HUMAN_ELF,
        StarterSkills = table.freeze({
            "QuickStrike",
            "Backstab",
            "EvasiveStep",
        }),
        StarterEquipment = table.freeze({
            Weapon = "scout_dagger",
            Body = "scout_leather_vest",
        }),
        TeachableSkills = table.freeze({
            "Feint",
            "ShadowDash",
            "CriticalFocus",
            "LightFoot",
            "ThreatDrop",
            "ViperStrike",
            "DisruptingCut",
            "LaceratingCut",
            "RogueFinishingCut",
            "RogueVitalBlow",
            "RogueBladeMastery",
            "RogueEdgeDiscipline",
            "ScoutLightArmorMastery",
            "ScoutFleetFoot",
            "HumanScoutRapidHands",
            "HumanScoutCriticalPower",
            "HumanScoutPrecision",
            "ElvenScoutPrecision",
            "ElvenRenewal",
        }),
    }),
})

function ClassProgressionDefinitions.get(
    class_id: string
): any?
    return DEFINITIONS[class_id]
end

function ClassProgressionDefinitions.can_teach(
    class_id: string,
    skill_id: string
): boolean
    local definition = DEFINITIONS[class_id]

    if not definition then
        return false
    end

    for _, allowed_skill in ipairs(
        definition.TeachableSkills
    ) do
        if allowed_skill == skill_id then
            return true
        end
    end

    return false
end

return table.freeze(
    ClassProgressionDefinitions
)
