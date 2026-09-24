--!strict
-- Data-driven trainer catalogue and pure trainer authorization.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local CharacterIdentityRules = require(
    Shared:WaitForChild("CharacterIdentityRules")
)
local SkillDefinitions = require(
    Shared:WaitForChild("SkillProgressionDefinitions")
)
local SkillUnlockRules = require(
    Shared:WaitForChild("SkillUnlockRules")
)

local DEFINITIONS = table.freeze({
    -- The physical Knight trainer requires an authentic personal quest
    -- and first-transfer mentor; server checks proximity and ownership.
    OathguardTrainer = table.freeze({
        Id = "OathguardTrainer",
        DisplayName = "Oathguard Shield Training",
        AllowedRaces = table.freeze({"Human"}),
        AllowedBaseClasses = table.freeze({"Fighter"}),
        AllowedClasses = table.freeze({"Oathguard"}),
        Skills = table.freeze({
            table.freeze({
                SkillId = "OathguardShieldImpact", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "OathguardChallenge", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "OathguardHeavyArmorTraining",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "OathguardRunicResistance",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "OathguardMendingOath",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "OathguardShieldMastery",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "OathguardSteadfastStance",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "OathguardLastBastion",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "OathguardUmbralSiphon",
                Mode = "LearnOrRank",
            }),
        }),
    }),
    IronvowTrainer = table.freeze({
        Id = "IronvowTrainer",
        DisplayName = "Marshal Torren's Ironvow Training",
        AllowedRaces = table.freeze({"Human"}),
        AllowedBaseClasses = table.freeze({"Fighter"}),
        AllowedClasses = table.freeze({"Ironvow"}),
        Skills = table.freeze({
            table.freeze({
                SkillId = "IronvowDrivingStrike", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "IronvowBladeTraining", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "IronvowLightArmorTraining",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "IronvowHeavyArmorTraining",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "IronvowBattleCall", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "IronvowFortitude", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "IronvowRestRecovery", Mode = "LearnOrRank",
            }),
        }),
    }),
    AshenbladeTrainer = table.freeze({
        Id = "AshenbladeTrainer",
        DisplayName = "Marshal Briar's Ashenblade Training",
        AllowedRaces = table.freeze({"Human"}),
        AllowedBaseClasses = table.freeze({"Fighter"}),
        AllowedClasses = table.freeze({"Ashenblade"}),
        Skills = table.freeze({
            table.freeze({
                SkillId = "HumanScoutSprint",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "AshenbladeOpening",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "WayfinderArrow", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "WayfinderCut", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "WayfinderBowMastery", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "WayfinderDaggerMastery", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "WayfinderWound", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutEquipmentExpertise", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutCommonItemCreation", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutLightArmorMastery", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutCriticalPowerToggle", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "RangerLongRange", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutLungCapacity", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutFallResistance", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutLockpicking", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutEvasion", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutAccuracyToggle", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutFleetFoot", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutRunningEvasion", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutEvasiveFocus", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "HumanScoutCriticalPower", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "HumanScoutRestingRecovery", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "HumanScoutPrecision", Mode = "LearnOrRank",
            }),
        }),
    }),

    GreenwardScoutTrainer = table.freeze({
        Id = "GreenwardScoutTrainer",
        DisplayName = "Pathwarden Siora's Greenward Training",
        AllowedRaces = table.freeze({"Elf"}),
        AllowedBaseClasses = table.freeze({"Fighter"}),
        AllowedClasses = table.freeze({"GreenwardScout"}),
        Skills = table.freeze({
            table.freeze({
                SkillId = "ElvenScoutGuard",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "GreenwardRenewal",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "WayfinderArrow", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "WayfinderCut", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "WayfinderBowMastery", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "WayfinderDaggerMastery", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "WayfinderWound", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "GreenwardCalmingArrow", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutEquipmentExpertise", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutCommonItemCreation", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutLightArmorMastery", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutCriticalPowerToggle", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "RangerLongRange", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutLungCapacity", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutFallResistance", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutLockpicking", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutEvasion", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutAccuracyToggle", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutFleetFoot", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutRunningEvasion", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutEvasiveFocus", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenRenewal", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutCureWounds", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutPoisonRecovery", Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutBattleFocus", Mode = "LearnOrRank",
            }),
        }),
    }),

    FighterTrainer = table.freeze({
        Id = "FighterTrainer",
        DisplayName = "Fighter Trainer",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        Skills = table.freeze({
            table.freeze({
                SkillId = "NoviceProtection",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ShieldBash",
                Mode = "Rank",
            }),
            table.freeze({
                SkillId = "Mend",
                Mode = "Rank",
            }),
            table.freeze({
                SkillId = "ArcSlash",
                Mode = "LearnOrRank",
                SourceItemId = "arc_slash_book_bound",
            }),
            table.freeze({
                SkillId = "Taunt",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "GuardBreaker",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "IronCleave",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "FighterBowShot",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "FighterDaggerStrike",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "PursuitStep",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "IronDiscipline",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "FighterPhysicalTraining",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "FighterArmorTraining",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "FighterRestingRecovery",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "C4RecipeReading",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "C4CommonItemCreation",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenFighterRenewal",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenFighterGuard",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenFighterBattleCry",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "StalwartTraining",
                Mode = "LearnOrRank",
            }),
        }),
    }),

    MageTrainer = table.freeze({
        Id = "MageTrainer",
        DisplayName = "Mage Trainer",
        AllowedBaseClasses = table.freeze({"Mage"}),
        Skills = table.freeze({
            table.freeze({
                SkillId = "NoviceProtection",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "WindStrike",
                Mode = "Rank",
            }),
            table.freeze({
                SkillId = "ArcaneWard",
                Mode = "Rank",
            }),
            table.freeze({
                SkillId = "MageHeal",
                Mode = "Rank",
            }),
            table.freeze({
                SkillId = "DawnWard",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "CinderBolt",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticWindBolt",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticFrostBolt",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticHealingPrayer",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticBattleHeal",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticPartyHeal",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticLifeDrain",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticPoisonCurse",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticCurePoison",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticFeebleCurse",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenMysticLanguor",
                Mode = "LearnOrRank",
            }),


            table.freeze({
                SkillId = "MysticRobeCasting",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "C4RecipeReading",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "C4CommonItemCreation",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticRobeManaRecovery",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticRobeAttackSpeed",
                Mode = "LearnOrRank",
            }),

            table.freeze({
                SkillId = "MysticWeaponTraining",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticArmorTraining",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticSpellResistance",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticBattleChant",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "MysticStoneSkin",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "AetherBolt",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "RenewingLight",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ArcaneDiscipline",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "RestorativeTraining",
                Mode = "LearnOrRank",
            }),
        }),
    }),

    RangerTrainer = table.freeze({
        Id = "RangerTrainer",
        DisplayName = "Ranger Trainer",
        AllowedBaseClasses = table.freeze({"Ranger"}),
        Skills = table.freeze({
            table.freeze({SkillId = "PiercingShot", Mode = "Rank"}),
            table.freeze({SkillId = "CripplingShot", Mode = "Rank"}),
            table.freeze({SkillId = "Volley", Mode = "Rank"}),
            table.freeze({
                SkillId = "TrackerShot",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "BriarVolley",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ThunderShot",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutFocusedShot",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutCriticalPowerToggle",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutAccuracyToggle",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutLockpicking",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutEquipmentExpertise",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutLungCapacity",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutFallResistance",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "C4RecipeReading",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutCommonItemCreation",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutSnaringShot",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ArcherDraw",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "RangerBowMastery",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutBowDiscipline",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "RangerLongRange",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "RangerArrowVelocity",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutLightArmorMastery",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutFleetFoot",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutEvasion",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutRunningEvasion",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "HumanScoutRestingRecovery",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutRunningRecovery",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutEvasiveFocus",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutGuard",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutPoisonRecovery",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutCureWounds",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutBattleFocus",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutWindRun",
                Mode = "LearnOrRank",
            }),


            table.freeze({
                SkillId = "HumanScoutRapidHands",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "HumanScoutCriticalPower",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "HumanScoutPrecision",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutPrecision",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenRenewal",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenCalmingShot",
                Mode = "LearnOrRank",
            }),
        }),
    }),

    RogueTrainer = table.freeze({
        Id = "RogueTrainer",
        DisplayName = "Rogue Trainer",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        Skills = table.freeze({
            table.freeze({SkillId = "QuickStrike", Mode = "Rank"}),
            table.freeze({SkillId = "Backstab", Mode = "Rank"}),
            table.freeze({SkillId = "EvasiveStep", Mode = "Rank"}),
            table.freeze({SkillId = "Feint", Mode = "LearnOrRank"}),
            table.freeze({SkillId = "ShadowDash", Mode = "LearnOrRank"}),
            table.freeze({SkillId = "CriticalFocus", Mode = "LearnOrRank"}),
            table.freeze({SkillId = "LightFoot", Mode = "LearnOrRank"}),
            table.freeze({SkillId = "ThreatDrop", Mode = "LearnOrRank"}),
            table.freeze({
                SkillId = "ViperStrike",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "DisruptingCut",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "LaceratingCut",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "RogueFinishingCut",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutCriticalPowerToggle",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutAccuracyToggle",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutLockpicking",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutEquipmentExpertise",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutLungCapacity",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutFallResistance",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "HumanScoutSprint",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "C4RecipeReading",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutCommonItemCreation",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "RogueVitalBlow",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "RogueBladeMastery",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "RogueEdgeDiscipline",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutLightArmorMastery",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutFleetFoot",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutEvasion",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutRunningEvasion",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "HumanScoutRestingRecovery",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutRunningRecovery",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ScoutEvasiveFocus",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutGuard",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutPoisonRecovery",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutCureWounds",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutBattleFocus",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutWindRun",
                Mode = "LearnOrRank",
            }),


            table.freeze({
                SkillId = "HumanScoutRapidHands",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "HumanScoutCriticalPower",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "HumanScoutPrecision",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenScoutPrecision",
                Mode = "LearnOrRank",
            }),
            table.freeze({
                SkillId = "ElvenRenewal",
                Mode = "LearnOrRank",
            }),
        }),
    }),

    VanguardTrainer = table.freeze({
        Id = "VanguardTrainer",
        DisplayName = "Vanguard Trainer",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        AllowedAdvancedClasses = table.freeze({"HumanVanguard"}),
        Skills = table.freeze({
            table.freeze({
                SkillId = "VanguardChallenge",
                Mode = "LearnOrRank",
            }),
        }),
    }),

    ThornwardenTrainer = table.freeze({
        Id = "ThornwardenTrainer",
        DisplayName = "Thornwarden Trainer",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        AllowedAdvancedClasses = table.freeze({"ElfThornwarden"}),
        Skills = table.freeze({
            table.freeze({
                SkillId = "ThornwardenBash",
                Mode = "LearnOrRank",
            }),
        }),
    }),

    SharpshooterTrainer = table.freeze({
        Id = "SharpshooterTrainer",
        DisplayName = "Sharpshooter Trainer",
        AllowedBaseClasses = table.freeze({"Ranger"}),
        AllowedAdvancedClasses = table.freeze({"HumanSharpshooter"}),
        Skills = table.freeze({
            table.freeze({
                SkillId = "SharpshooterPierce",
                Mode = "LearnOrRank",
            }),
        }),
    }),

    WindrunnerTrainer = table.freeze({
        Id = "WindrunnerTrainer",
        DisplayName = "Windrunner Trainer",
        AllowedBaseClasses = table.freeze({"Ranger"}),
        AllowedAdvancedClasses = table.freeze({"ElfWindrunner"}),
        Skills = table.freeze({
            table.freeze({
                SkillId = "WindrunnerVolley",
                Mode = "LearnOrRank",
            }),
        }),
    }),

    ArcanistTrainer = table.freeze({
        Id = "ArcanistTrainer",
        DisplayName = "Arcanist Trainer",
        AllowedBaseClasses = table.freeze({"Mage"}),
        AllowedAdvancedClasses = table.freeze({"HumanArcanist"}),
        Skills = table.freeze({
            table.freeze({
                SkillId = "ArcanistEmber",
                Mode = "LearnOrRank",
            }),
        }),
    }),
    SpellweaverTrainer = table.freeze({
        Id = "SpellweaverTrainer",
        DisplayName = "Spellweaver Trainer",
        AllowedBaseClasses = table.freeze({"Mage"}),
        AllowedAdvancedClasses = table.freeze({"ElfSpellweaver"}),
        Skills = table.freeze({
            table.freeze({
                SkillId = "SpellweaverAegis",
                Mode = "LearnOrRank",
            }),
        }),
    }),

    DuelistTrainer = table.freeze({
        Id = "DuelistTrainer",
        DisplayName = "Duelist Trainer",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        AllowedAdvancedClasses = table.freeze({"HumanRogueDuelist"}),
        Skills = table.freeze({
            table.freeze({SkillId = "DuelistAmbush", Mode = "LearnOrRank"}),
            table.freeze({SkillId = "DuelistDeadlyBlow", Mode = "LearnOrRank"}),
            table.freeze({SkillId = "DuelistExposeWeakness", Mode = "LearnOrRank"}),
            table.freeze({SkillId = "DuelistRush", Mode = "LearnOrRank"}),
            table.freeze({SkillId = "DuelistCriticalMastery", Mode = "LearnOrRank"}),
        }),
    }),

    WindstalkerTrainer = table.freeze({
        Id = "WindstalkerTrainer",
        DisplayName = "Windstalker Trainer",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        AllowedAdvancedClasses = table.freeze({"ElfRogueWindstalker"}),
        Skills = table.freeze({
            table.freeze({SkillId = "WindstalkerFlurry", Mode = "LearnOrRank"}),
            table.freeze({SkillId = "WindstalkerSlipstream", Mode = "LearnOrRank"}),
            table.freeze({SkillId = "WindstalkerBlur", Mode = "LearnOrRank"}),
            table.freeze({SkillId = "WindstalkerQuickstep", Mode = "LearnOrRank"}),
            table.freeze({SkillId = "WindstalkerEvasionMastery", Mode = "LearnOrRank"}),
        }),
    }),
})

local TrainerCatalogues = {}

local function failure(reason: string): any
    return {
        ok = false,
        reason = reason,
    }
end

local function allowed(whitelist: any, value: any): boolean
    if whitelist == nil then
        return true
    end

    if type(whitelist) ~= "table" then
        return false
    end

    for _, candidate in ipairs(whitelist) do
        if candidate == value then
            return true
        end
    end

    return false
end

local function copy_trainer(
    definition: any,
    character: any
): any
    local skills = {}

    for _, entry in ipairs(definition.Skills) do
        local skill = SkillDefinitions.get(entry.SkillId)
        if skill and SkillUnlockRules.can_show(character, skill) then
            table.insert(skills, {
                SkillId = entry.SkillId,
                Mode = entry.Mode,
                SourceItemId = entry.SourceItemId,
            })
        end
    end

    return {
        Id = definition.Id,
        DisplayName = definition.DisplayName,
        Skills = skills,
    }
end

function TrainerCatalogues.get(trainer_id: string): any?
    return DEFINITIONS[trainer_id]
end

function TrainerCatalogues.resolve_for_character(
    trainer_id: string,
    character: any
): any
    local definition = DEFINITIONS[trainer_id]

    if not definition then
        return failure("UnknownTrainer")
    end

    if (
        type(character) ~= "table"
        or not CharacterIdentityRules.is_complete(character)
    ) then
        return failure("IdentityIncomplete")
    end

    local identity = character.Identity

    if not allowed(definition.AllowedRaces, identity.RaceId) then
        return failure("TrainerRestricted")
    end

    if not allowed(definition.AllowedBaseClasses, identity.BaseClassId) then
        return failure("TrainerRestricted")
    end

    if not allowed(definition.AllowedClasses, identity.ClassId) then
        return failure("TrainerRestricted")
    end

    local active_advanced_class = if type(character.ClassAdvancement) == "table"
        then character.ClassAdvancement.ActiveClassId
        else nil
    if not allowed(definition.AllowedAdvancedClasses, active_advanced_class) then
        return failure("TrainerRestricted")
    end

    local trainer_copy = copy_trainer(definition, character)

    return {
        ok = true,
        Trainer = trainer_copy,
        TrainerId = trainer_copy.Id,
        DisplayName = trainer_copy.DisplayName,
        Skills = trainer_copy.Skills,
    }
end

function TrainerCatalogues.can_offer(
    trainer_id: string,
    character: any,
    skill_id: string
): any
    local resolved = TrainerCatalogues.resolve_for_character(
        trainer_id,
        character
    )

    if not resolved.ok then
        return resolved
    end

    for _, entry in ipairs(resolved.Trainer.Skills) do
        if entry.SkillId == skill_id then
            return {
                ok = true,
                Entry = entry,
                Trainer = resolved.Trainer,
            }
        end
    end

    return failure("SkillNotTeachableHere")
end

return table.freeze(TrainerCatalogues)
