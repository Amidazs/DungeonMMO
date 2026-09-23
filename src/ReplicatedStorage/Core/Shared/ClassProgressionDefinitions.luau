--!strict
local ClassProgressionDefinitions = {}

local HUMAN_ELF = table.freeze({"Human", "Elf"})

local DEFINITIONS = table.freeze({
    Fighter = table.freeze({
        Id = "Fighter",
        DisplayName = "Fighter",
        SourceC4StarterName = "Fighter",
        FreshCreationAllowed = true,
        AllowedRaces = HUMAN_ELF,
        StarterSkills = table.freeze({
            "ShieldBash",
            "Mend",
        }),
        StarterEquipment = table.freeze({}),
        TeachableSkills = table.freeze({
            "NoviceProtection",
            "C4RecipeReading",
            "C4CommonItemCreation",
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
            "FighterRestingRecovery",
            "ElvenFighterRenewal",
            "ElvenFighterGuard",
            "ElvenFighterBattleCry",
            "StalwartTraining",
        }),
    }),

    Mage = table.freeze({
        Id = "Mage",
        DisplayName = "Mystic",
        SourceC4StarterName = "Mystic",
        FreshCreationAllowed = true,
        AllowedRaces = HUMAN_ELF,
        StarterSkills = table.freeze({
            "WindStrike",
            "ArcaneWard",
            "MageHeal",
        }),
        StarterEquipment = table.freeze({
            Weapon = "apprentice_arcane_wand",
            Body = "apprentice_mystic_robe",
        }),
        TeachableSkills = table.freeze({
            "NoviceProtection",
            "C4RecipeReading",
            "C4CommonItemCreation",
            "DawnWard",
            "CinderBolt",
            "MysticWindBolt",
            "MysticFrostBolt",
            "MysticHealingPrayer",
            "MysticBattleHeal",
            "MysticPartyHeal",
            "MysticLifeDrain",
            "MysticPoisonCurse",
            "MysticCurePoison",
            "MysticRobeCasting",
            "MysticRobeManaRecovery",
            "MysticRobeAttackSpeed",
            "MysticWeaponTraining",
            "MysticArmorTraining",
            "MysticSpellResistance",
            "MysticBattleChant",
            "MysticStoneSkin",
            "AetherBolt",
            "RenewingLight",
            "ArcaneDiscipline",
            "RestorativeTraining",
        }),
    }),

    -- An original first-transfer award is separate from legacy Rogue/
    -- Ranger starter profiles and their old specialist class identities.
    Ashenblade = table.freeze({
        Id = "Ashenblade",
        DisplayName = "Ashenblade",
        FreshCreationAllowed = false,
        OriginalFirstTransferClass = true,
        AllowedRaces = table.freeze({"Human"}),
        StarterSkills = table.freeze({}),
        StarterEquipment = table.freeze({}),
        TeachableSkills = table.freeze({
            "HumanScoutSprint",
            "AshenbladeOpening",
            "WayfinderArrow",
            "WayfinderCut",
            "WayfinderBowMastery",
            "WayfinderDaggerMastery",
            "WayfinderWound",
            "ScoutEquipmentExpertise",
            "ScoutCommonItemCreation",
            "ScoutLightArmorMastery",
            "ScoutCriticalPowerToggle",
            "RangerLongRange",
            "ScoutLungCapacity",
            "ScoutFallResistance",
            "ScoutLockpicking",
            "ScoutEvasion",
            "ScoutAccuracyToggle",
            "ScoutFleetFoot",
            "ScoutRunningEvasion",
            "ScoutEvasiveFocus",
            "HumanScoutCriticalPower",
            "HumanScoutRestingRecovery",
            "HumanScoutPrecision",
        }),
    }),

    GreenwardScout = table.freeze({
        Id = "GreenwardScout",
        DisplayName = "Greenward Scout",
        FreshCreationAllowed = false,
        OriginalFirstTransferClass = true,
        AllowedRaces = table.freeze({"Elf"}),
        StarterSkills = table.freeze({}),
        StarterEquipment = table.freeze({}),
        TeachableSkills = table.freeze({
            "ElvenScoutGuard",
            "GreenwardRenewal",
            "WayfinderArrow",
            "WayfinderCut",
            "WayfinderBowMastery",
            "WayfinderDaggerMastery",
            "WayfinderWound",
            "GreenwardCalmingArrow",
            "ScoutEquipmentExpertise",
            "ScoutCommonItemCreation",
            "ScoutLightArmorMastery",
            "ScoutCriticalPowerToggle",
            "RangerLongRange",
            "ScoutLungCapacity",
            "ScoutFallResistance",
            "ScoutLockpicking",
            "ScoutEvasion",
            "ScoutAccuracyToggle",
            "ScoutFleetFoot",
            "ScoutRunningEvasion",
            "ScoutEvasiveFocus",
            "ElvenRenewal",
            "ElvenScoutCureWounds",
            "ElvenScoutPoisonRecovery",
            "ElvenScoutBattleFocus",
        }),
    }),

    -- Original Human Warrior foundation, intentionally unclaimable
    -- until its independent level-18 quest/world evidence is integrated.
    Ironvow = table.freeze({
        Id = "Ironvow",
        DisplayName = "Ironvow",
        FreshCreationAllowed = false,
        OriginalFirstTransferClass = true,
        AllowedRaces = table.freeze({"Human"}),
        StarterSkills = table.freeze({}),
        StarterEquipment = table.freeze({}),
        TeachableSkills = table.freeze({
            "IronvowDrivingStrike",
            "IronvowBladeTraining",
            "IronvowLightArmorTraining",
            "IronvowHeavyArmorTraining",
            "IronvowBattleCall",
            "IronvowFortitude",
            "IronvowRestRecovery",
        }),
    }),

    -- Planned original Human Knight. Fresh creation and actual class
    -- claims are disabled until the independent physical quest exists.
    Oathguard = table.freeze({
        Id = "Oathguard",
        DisplayName = "Oathguard",
        FreshCreationAllowed = false,
        OriginalFirstTransferClass = true,
        AllowedRaces = table.freeze({"Human"}),
        StarterSkills = table.freeze({}),
        StarterEquipment = table.freeze({}),
        TeachableSkills = table.freeze({
            "OathguardShieldImpact",
            "OathguardChallenge",
            "OathguardHeavyArmorTraining",
            "OathguardRunicResistance",
        }),
    }),

    Ranger = table.freeze({
        Id = "Ranger",
        DisplayName = "Ranger",
        FreshCreationAllowed = false,
        LegacySpecialistClass = true,
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
            "ScoutCriticalPowerToggle",
            "ScoutAccuracyToggle",
            "ScoutLockpicking",
            "ScoutEquipmentExpertise",
            "ScoutLungCapacity",
            "ScoutFallResistance",
            "C4RecipeReading",
            "ScoutCommonItemCreation",
            "ElvenScoutSnaringShot",
            "ArcherDraw",
            "RangerBowMastery",
            "ScoutBowDiscipline",
            "RangerLongRange",
            "RangerArrowVelocity",
            "ScoutLightArmorMastery",
            "ScoutFleetFoot",
            "ScoutEvasion",
            "ScoutRunningEvasion",
            "HumanScoutRestingRecovery",
            "ScoutRunningRecovery",
            "ScoutEvasiveFocus",
            "ElvenScoutGuard",
            "ElvenScoutPoisonRecovery",
            "ElvenScoutCureWounds",
            "ElvenScoutBattleFocus",
            "ElvenScoutWindRun",
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
        DisplayName = "Rogue",
        FreshCreationAllowed = false,
        LegacySpecialistClass = true,
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
            "ScoutCriticalPowerToggle",
            "ScoutAccuracyToggle",
            "ScoutLockpicking",
            "ScoutEquipmentExpertise",
            "ScoutLungCapacity",
            "ScoutFallResistance",
            "HumanScoutSprint",
            "C4RecipeReading",
            "ScoutCommonItemCreation",
            "RogueVitalBlow",
            "RogueBladeMastery",
            "RogueEdgeDiscipline",
            "ScoutLightArmorMastery",
            "ScoutFleetFoot",
            "ScoutEvasion",
            "ScoutRunningEvasion",
            "HumanScoutRestingRecovery",
            "ScoutRunningRecovery",
            "ScoutEvasiveFocus",
            "ElvenScoutGuard",
            "ElvenScoutPoisonRecovery",
            "ElvenScoutCureWounds",
            "ElvenScoutBattleFocus",
            "ElvenScoutWindRun",
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
