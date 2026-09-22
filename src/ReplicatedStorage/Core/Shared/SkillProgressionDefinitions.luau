--!strict
local SkillProgressionDefinitions = {}

local DEFINITIONS = table.freeze({
    -- C4 level-one starting-class protection analogue. The actual
    -- server mitigation expires upon reaching first-transfer level 20.
    NoviceProtection = table.freeze({
        Id = "NoviceProtection",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedRaces = table.freeze({"Human", "Elf"}),
        AllowedBaseClasses = table.freeze({"Fighter", "Mage"}),
        RankLevels = table.freeze({[1] = 1}),
        MaximumLevel = 19,
        PhysicalReductionPerRank = 0.02,
        WeaponTags = table.freeze({}),
    }),

    Mend = table.freeze({
        Id = "Mend",
        Tier = "Common",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Support",
        WeaponTags = table.freeze({}),
    }),

    Taunt = table.freeze({
        Id = "Taunt",
        Tier = "Common",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Control",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        WeaponTags = table.freeze({}),
    }),

    ShieldBash = table.freeze({
        Id = "ShieldBash",
        Tier = "Uncommon",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Physical",
        WeaponTags = table.freeze({}),
    }),

    ArcSlash = table.freeze({
        Id = "ArcSlash",
        Tier = "Rare",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Physical",
        WeaponTags = table.freeze({
            "OneHandedSword",
        }),
    }),

    WindStrike = table.freeze({
        Id = "WindStrike",
        Tier = "Common",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Magic",
        WeaponTags = table.freeze({
            "ArcaneWand",
        }),
    }),

    ArcaneWard = table.freeze({
        Id = "ArcaneWard",
        Tier = "Common",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Support",
        WeaponTags = table.freeze({
            "ArcaneWand",
        }),
    }),

    MageHeal = table.freeze({
        Id = "MageHeal",
        Tier = "Common",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Support",
        WeaponTags = table.freeze({
            "ArcaneWand",
        }),
    }),

    PiercingShot = table.freeze({
        Id = "PiercingShot",
        Tier = "Common",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Physical",
        WeaponTags = table.freeze({
            "Longbow",
        }),
    }),

    CripplingShot = table.freeze({
        Id = "CripplingShot",
        Tier = "Common",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Control",
        WeaponTags = table.freeze({
            "Longbow",
        }),
    }),

    Volley = table.freeze({
        Id = "Volley",
        Tier = "Common",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Physical",
        WeaponTags = table.freeze({
            "Longbow",
        }),
    }),

    -- C4 base Mystic level-one robe passives. These are purchased
    -- through the existing trainer and require a real equipped robe.
    MysticRobeCasting = table.freeze({
        Id = "MysticRobeCasting",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({[1] = 1}),
        CastingRateBonusPerRank = 0.06,
        WeaponTags = table.freeze({}),
    }),
    MysticRobeManaRecovery = table.freeze({
        Id = "MysticRobeManaRecovery",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({[1] = 1}),
        ManaRegenBonusPerRank = 0.15,
        WeaponTags = table.freeze({}),
    }),
    MysticRobeAttackSpeed = table.freeze({
        Id = "MysticRobeAttackSpeed",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({[1] = 1}),
        AttackRateBonusPerRank = 0.06,
        WeaponTags = table.freeze({}),
    }),

    -- Source C4 Mystic Wind Strike continuation: two ranks at 7,
    -- two at 14; the base WindStrike remains the level-one starter.
    MysticWindBolt = table.freeze({
        Id = "MysticWindBolt",
        Tier = "Common",
        MaxRank = 4,
        Kind = "Magic",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({
            [1] = 7, [2] = 7, [3] = 14, [4] = 14,
        }),
        RankThresholds = table.freeze({
            [2] = 40, [3] = 100, [4] = 160,
        }),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "WindStrike", Rank = 1,
                Proficiency = 0,
            }),
        }),
        WeaponTags = table.freeze({"ArcaneWand"}),
    }),

    -- Source C4 Mystic level-7/14 healing ranks, while the level-one
    -- MageHeal starter remains a distinct earlier self-heal analogue.
    MysticHealingPrayer = table.freeze({
        Id = "MysticHealingPrayer",
        Tier = "Common",
        MaxRank = 6,
        Kind = "Support",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({
            [1] = 7, [2] = 7, [3] = 7,
            [4] = 14, [5] = 14, [6] = 14,
        }),
        RankThresholds = table.freeze({
            [2] = 40, [3] = 80, [4] = 130,
            [5] = 190, [6] = 260,
        }),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "MageHeal", Rank = 1,
                Proficiency = 0,
            }),
        }),
        WeaponTags = table.freeze({"ArcaneWand"}),
    }),

    -- C4 Mystic Ice Bolt first-tier source ranks: two at 7/14.
    -- Server projectile impact applies real enemy movement impairment.
    MysticFrostBolt = table.freeze({
        Id = "MysticFrostBolt",
        Tier = "Common",
        MaxRank = 4,
        Kind = "Control",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({
            [1] = 7, [2] = 7, [3] = 14, [4] = 14,
        }),
        RankThresholds = table.freeze({
            [2] = 40, [3] = 100, [4] = 160,
        }),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "WindStrike", Rank = 1,
                Proficiency = 0,
            }),
        }),
        WeaponTags = table.freeze({"ArcaneWand"}),
    }),

    -- C4 Mystic physical/magic weapon mastery at levels 7 and 14.
    MysticWeaponTraining = table.freeze({
        Id = "MysticWeaponTraining",
        Tier = "Common",
        MaxRank = 2,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({[1] = 7, [2] = 14}),
        DamageBonusPerRank = 0.02,
        WeaponTags = table.freeze({}),
    }),

    -- C4 Mystic physical armour mastery at 7/14/14.
    MysticArmorTraining = table.freeze({
        Id = "MysticArmorTraining",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({
            [1] = 7, [2] = 14, [3] = 14,
        }),
        PhysicalReductionPerRank = 0.008,
        WeaponTags = table.freeze({}),
    }),

    -- C4 Mystic magic resistance 7/7/14/14; affects incoming
    -- magical attacks, not generic physical NPC damage.
    MysticSpellResistance = table.freeze({
        Id = "MysticSpellResistance",
        Tier = "Common",
        MaxRank = 4,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({
            [1] = 7, [2] = 7, [3] = 14, [4] = 14,
        }),
        MagicReductionPerRank = 0.015,
        WeaponTags = table.freeze({}),
    }),

    ElvenFighterGuard = table.freeze({
        Id = "ElvenFighterGuard",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Support",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        AllowedRaces = table.freeze({"Elf"}),
        RankLevels = table.freeze({[1] = 5}),
        WeaponTags = table.freeze({}),
    }),

    ElvenFighterBattleCry = table.freeze({
        Id = "ElvenFighterBattleCry",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Support",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        AllowedRaces = table.freeze({"Elf"}),
        RankLevels = table.freeze({[1] = 10}),
        WeaponTags = table.freeze({}),
    }),

    MysticBattleChant = table.freeze({
        Id = "MysticBattleChant",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Support",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({[1] = 7}),
        WeaponTags = table.freeze({}),
    }),

    MysticStoneSkin = table.freeze({
        Id = "MysticStoneSkin",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Support",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({[1] = 7}),
        WeaponTags = table.freeze({}),
    }),

    -- L2 C4-inspired rank milestones: skills are taught at the
    -- trainer only after the character earns each level bracket.
    GuardBreaker = table.freeze({
        Id = "GuardBreaker",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Control",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        RankLevels = table.freeze({[1] = 5, [2] = 10, [3] = 15}),
        WeaponTags = table.freeze({}),
    }),
    IronCleave = table.freeze({
        Id = "IronCleave",
        Tier = "Common",
        MaxRank = 9,
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        RankLevels = table.freeze({
            [1] = 5, [2] = 5, [3] = 5,
            [4] = 10, [5] = 10, [6] = 10,
            [7] = 15, [8] = 15, [9] = 15,
        }),
        RankThresholds = table.freeze({
            [2] = 20, [3] = 50, [4] = 90,
            [5] = 130, [6] = 180, [7] = 230,
            [8] = 290, [9] = 350,
        }),
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),

    PursuitStep = table.freeze({
        Id = "PursuitStep",
        Tier = "Common",
        MaxRank = 9,
        Kind = "Mobility",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        RankLevels = table.freeze({
            [1] = 5, [2] = 5, [3] = 5,
            [4] = 10, [5] = 10, [6] = 10,
            [7] = 15, [8] = 15, [9] = 15,
        }),
        RankThresholds = table.freeze({
            [2] = 20, [3] = 50, [4] = 90,
            [5] = 130, [6] = 180, [7] = 230,
            [8] = 290, [9] = 350,
        }),
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),

    -- Passive ranks are purchased at class-training levels, not earned
    -- by casting a passive. Each rank changes real server damage scaling.
    IronDiscipline = table.freeze({
        Id = "IronDiscipline",
        Tier = "Common",
        MaxRank = 6,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        RankLevels = table.freeze({
            [1] = 5, [2] = 5, [3] = 5,
            [4] = 10, [5] = 10, [6] = 10,
        }),
        RankThresholds = table.freeze({
            [2] = 0, [3] = 0, [4] = 0,
            [5] = 0, [6] = 0,
        }),
        DamageBonusPerRank = 0.01,
        WeaponTags = table.freeze({}),
    }),

    -- C4 base Fighter source: three bow ranks at levels 5/10/15.
    FighterBowShot = table.freeze({
        Id = "FighterBowShot",
        Tier = "Common",
        MaxRank = 9,
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        RankLevels = table.freeze({
            [1] = 5,
            [2] = 5,
            [3] = 5,
            [4] = 10,
            [5] = 10,
            [6] = 10,
            [7] = 15,
            [8] = 15,
            [9] = 15,
        }),
        RankThresholds = table.freeze({
            [2] = 40,
            [3] = 80,
            [4] = 120,
            [5] = 160,
            [6] = 200,
            [7] = 240,
            [8] = 280,
            [9] = 320,
        }),
        WeaponTags = table.freeze({"Longbow"}),
    }),

    -- C4 base Fighter source: three dagger ranks at levels 5/10/15.
    FighterDaggerStrike = table.freeze({
        Id = "FighterDaggerStrike",
        Tier = "Common",
        MaxRank = 9,
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        RankLevels = table.freeze({
            [1] = 5,
            [2] = 5,
            [3] = 5,
            [4] = 10,
            [5] = 10,
            [6] = 10,
            [7] = 15,
            [8] = 15,
            [9] = 15,
        }),
        RankThresholds = table.freeze({
            [2] = 40,
            [3] = 80,
            [4] = 120,
            [5] = 160,
            [6] = 200,
            [7] = 240,
            [8] = 280,
            [9] = 320,
        }),
        WeaponTags = table.freeze({"Dagger"}),
    }),

    -- C4 source Fighter attack mastery: 1 rank at 5, 10 and 15.
    FighterPhysicalTraining = table.freeze({
        Id = "FighterPhysicalTraining",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        RankLevels = table.freeze({[1] = 5, [2] = 10, [3] = 15}),
        DamageBonusPerRank = 0.02,
        WeaponTags = table.freeze({}),
    }),

    -- C4 base Fighter armour mastery: one rank at level 5,
    -- two at 10 and two at 15; real mitigation requires worn body gear.
    FighterArmorTraining = table.freeze({
        Id = "FighterArmorTraining",
        Tier = "Common",
        MaxRank = 5,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        RankLevels = table.freeze({
            [1] = 5, [2] = 10, [3] = 10,
            [4] = 15, [5] = 15,
        }),
        PhysicalReductionPerRank = 0.007,
        WeaponTags = table.freeze({}),
    }),

    -- C4 Elven Fighter Elemental Heal ranks 1-3 at level 15.
    -- Authored server self-renewal needs the correct race and class.
    ElvenFighterRenewal = table.freeze({
        Id = "ElvenFighterRenewal",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Support",
        AllowedRaces = table.freeze({"Elf"}),
        AllowedBaseClasses = table.freeze({"Fighter"}),
        RankLevels = table.freeze({
            [1] = 15, [2] = 15, [3] = 15,
        }),
        RankThresholds = table.freeze({
            [2] = 40, [3] = 100,
        }),
        WeaponTags = table.freeze({}),
    }),

    -- The shield-line counterpart to Iron Discipline: purchased ranks
    -- add real maximum HP without creating an inert combat action.
    StalwartTraining = table.freeze({
        Id = "StalwartTraining",
        Tier = "Common",
        MaxRank = 6,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        RankLevels = table.freeze({
            [1] = 5, [2] = 5, [3] = 5,
            [4] = 10, [5] = 10, [6] = 10,
        }),
        RankThresholds = table.freeze({
            [2] = 0, [3] = 0, [4] = 0,
            [5] = 0, [6] = 0,
        }),
        HealthBonusPerRank = 5,
        WeaponTags = table.freeze({}),
    }),

    -- An early Mystic support line, with a real heal multiplier.
    RestorativeTraining = table.freeze({
        Id = "RestorativeTraining",
        Tier = "Common",
        MaxRank = 6,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({
            [1] = 7, [2] = 7, [3] = 7,
            [4] = 14, [5] = 14, [6] = 14,
        }),
        RankThresholds = table.freeze({
            [2] = 0, [3] = 0, [4] = 0,
            [5] = 0, [6] = 0,
        }),
        HealBonusPerRank = 0.012,
        WeaponTags = table.freeze({}),
    }),

    ArcaneDiscipline = table.freeze({
        Id = "ArcaneDiscipline",
        Tier = "Common",
        MaxRank = 6,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({
            [1] = 7, [2] = 7, [3] = 7,
            [4] = 14, [5] = 14, [6] = 14,
        }),
        RankThresholds = table.freeze({
            [2] = 0, [3] = 0, [4] = 0,
            [5] = 0, [6] = 0,
        }),
        DamageBonusPerRank = 0.015,
        WeaponTags = table.freeze({}),
    }),

    -- Accessible introductory Mage options, distinct from the starters.
    -- Each subsequent rank is a separate level-gated trainer offering.
    DawnWard = table.freeze({
        Id = "DawnWard",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Support",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({[1] = 1, [2] = 7, [3] = 14}),
        RankThresholds = table.freeze({[2] = 35, [3] = 100}),
        WeaponTags = table.freeze({"ArcaneWand"}),
    }),
    CinderBolt = table.freeze({
        Id = "CinderBolt",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Magic",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({[1] = 1, [2] = 7, [3] = 14}),
        RankThresholds = table.freeze({[2] = 35, [3] = 100}),
        WeaponTags = table.freeze({"ArcaneWand"}),
    }),

    AetherBolt = table.freeze({
        Id = "AetherBolt",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Magic",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({[1] = 7, [2] = 14, [3] = 20}),
        WeaponTags = table.freeze({"ArcaneWand"}),
    }),
    RenewingLight = table.freeze({
        Id = "RenewingLight",
        Tier = "Common",
        MaxRank = 6,
        Kind = "Support",
        AllowedBaseClasses = table.freeze({"Mage"}),
        RankLevels = table.freeze({
            [1] = 7, [2] = 7, [3] = 7,
            [4] = 14, [5] = 14, [6] = 14,
        }),
        RankThresholds = table.freeze({
            [2] = 25, [3] = 50, [4] = 75,
            [5] = 110, [6] = 150,
        }),
        WeaponTags = table.freeze({"ArcaneWand"}),
    }),

    TrackerShot = table.freeze({
        Id = "TrackerShot",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Ranger"}),
        RankLevels = table.freeze({[1] = 5, [2] = 10, [3] = 15}),
        WeaponTags = table.freeze({"Longbow"}),
    }),
    ViperStrike = table.freeze({
        Id = "ViperStrike",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        RankLevels = table.freeze({[1] = 5, [2] = 10, [3] = 15}),
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),

    -- Control alternatives to raw damage: a two-target slowing arrow and
    -- a close-range disruption strike. Rank upgrades improve actual control.
    BriarVolley = table.freeze({
        Id = "BriarVolley",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Control",
        AllowedBaseClasses = table.freeze({"Ranger"}),
        RankLevels = table.freeze({[1] = 5, [2] = 10, [3] = 15}),
        RankThresholds = table.freeze({[2] = 40, [3] = 110}),
        WeaponTags = table.freeze({"Longbow"}),
    }),
    -- C4 Rogue/Scout gain stun-capable bow attacks in their level-36
    -- bracket. The new ability needs the completed basic bow line and
    -- our earlier control arrow before it becomes visible or trainable.
    ThunderShot = table.freeze({
        Id = "ThunderShot",
        Tier = "Rare",
        MaxRank = 3,
        Kind = "Control",
        AllowedBaseClasses = table.freeze({"Ranger"}),
        RankLevels = table.freeze({[1] = 36, [2] = 36, [3] = 36}),
        RankThresholds = table.freeze({[2] = 50, [3] = 125}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "ArcherDraw", Rank = 9, Proficiency = 350,
            }),
            table.freeze({
                SkillId = "BriarVolley", Rank = 3, Proficiency = 110,
            }),
        }),
        WeaponTags = table.freeze({"Longbow"}),
    }),
    -- The C4 first-transfer Rogue/Scout line adds Bleed at 24/32.
    -- This original analogue requires fully trained early dagger/bleed
    -- foundations; only confirmed NPC hits may start its damage-over-time.
    LaceratingCut = table.freeze({
        Id = "LaceratingCut",
        Tier = "Rare",
        MaxRank = 2,
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        RankLevels = table.freeze({[1] = 24, [2] = 32}),
        RankThresholds = table.freeze({[2] = 120}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "RogueVitalBlow", Rank = 9,
                Proficiency = 350,
            }),
            table.freeze({
                SkillId = "DisruptingCut", Rank = 3,
                Proficiency = 110,
            }),
        }),
        WeaponTags = table.freeze({"Dagger"}),
    }),
    DisruptingCut = table.freeze({
        Id = "DisruptingCut",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Control",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        RankLevels = table.freeze({[1] = 5, [2] = 10, [3] = 15}),
        RankThresholds = table.freeze({[2] = 40, [3] = 110}),
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),

    -- 15 source-band shot ranks (20/24/28/32/36).
    ScoutFocusedShot = table.freeze({
        Id = "ScoutFocusedShot",
        Tier = "Common",
        MaxRank = 15,
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Ranger"}),
        RankLevels = table.freeze({
            [1] = 20,
            [2] = 20,
            [3] = 20,
            [4] = 24,
            [5] = 24,
            [6] = 24,
            [7] = 28,
            [8] = 28,
            [9] = 28,
            [10] = 32,
            [11] = 32,
            [12] = 32,
            [13] = 36,
            [14] = 36,
            [15] = 36,
        }),
        RankThresholds = table.freeze({
            [2] = 40,
            [3] = 80,
            [4] = 120,
            [5] = 160,
            [6] = 200,
            [7] = 240,
            [8] = 280,
            [9] = 320,
            [10] = 360,
            [11] = 400,
            [12] = 440,
            [13] = 480,
            [14] = 520,
            [15] = 560,
        }),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "ArcherDraw", Rank = 9, Proficiency = 350,
            }),
        }),
        WeaponTags = table.freeze({"Longbow"}),
    }),
    -- 15 source-band melee ranks; sword pending dagger support.
    RogueFinishingCut = table.freeze({
        Id = "RogueFinishingCut",
        Tier = "Common",
        MaxRank = 15,
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        RankLevels = table.freeze({
            [1] = 20,
            [2] = 20,
            [3] = 20,
            [4] = 24,
            [5] = 24,
            [6] = 24,
            [7] = 28,
            [8] = 28,
            [9] = 28,
            [10] = 32,
            [11] = 32,
            [12] = 32,
            [13] = 36,
            [14] = 36,
            [15] = 36,
        }),
        RankThresholds = table.freeze({
            [2] = 40,
            [3] = 80,
            [4] = 120,
            [5] = 160,
            [6] = 200,
            [7] = 240,
            [8] = 280,
            [9] = 320,
            [10] = 360,
            [11] = 400,
            [12] = 440,
            [13] = 480,
            [14] = 520,
            [15] = 560,
        }),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "RogueVitalBlow", Rank = 9, Proficiency = 350,
            }),
        }),
        WeaponTags = table.freeze({"Dagger"}),
    }),

    -- Fifteen C4 first-transfer bow-mastery brackets; real ranged damage.
    ScoutBowDiscipline = table.freeze({
        Id = "ScoutBowDiscipline",
        Tier = "Common",
        MaxRank = 15,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Ranger"}),
        RankLevels = table.freeze({
            [1] = 20,
            [2] = 20,
            [3] = 20,
            [4] = 24,
            [5] = 24,
            [6] = 24,
            [7] = 28,
            [8] = 28,
            [9] = 28,
            [10] = 32,
            [11] = 32,
            [12] = 32,
            [13] = 36,
            [14] = 36,
            [15] = 36,
        }),
        RankThresholds = table.freeze({
            [2] = 0,
            [3] = 0,
            [4] = 0,
            [5] = 0,
            [6] = 0,
            [7] = 0,
            [8] = 0,
            [9] = 0,
            [10] = 0,
            [11] = 0,
            [12] = 0,
            [13] = 0,
            [14] = 0,
            [15] = 0,
        }),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "RangerBowMastery", Rank = 6, Proficiency = 0,
            }),
        }),
        DamageBonusPerRank = 0.006,
        WeaponTags = table.freeze({"Longbow"}),
    }),
    -- Eight first-transfer blade mastery ranks, for owned melee damage.
    RogueEdgeDiscipline = table.freeze({
        Id = "RogueEdgeDiscipline",
        Tier = "Common",
        MaxRank = 8,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        RankLevels = table.freeze({
            [1] = 20,
            [2] = 24,
            [3] = 28,
            [4] = 28,
            [5] = 32,
            [6] = 32,
            [7] = 36,
            [8] = 36,
        }),
        RankThresholds = table.freeze({
            [2] = 0,
            [3] = 0,
            [4] = 0,
            [5] = 0,
            [6] = 0,
            [7] = 0,
            [8] = 0,
        }),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "RogueBladeMastery", Rank = 6, Proficiency = 0,
            }),
        }),
        DamageBonusPerRank = 0.01,
        WeaponTags = table.freeze({"Dagger"}),
    }),
    -- Ten light-body armour mastery ranks reduce actual incoming physical damage.
    ScoutLightArmorMastery = table.freeze({
        Id = "ScoutLightArmorMastery",
        Tier = "Common",
        MaxRank = 10,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Ranger", "Rogue"}),
        RankLevels = table.freeze({
            [1] = 20,
            [2] = 20,
            [3] = 24,
            [4] = 24,
            [5] = 28,
            [6] = 28,
            [7] = 32,
            [8] = 32,
            [9] = 36,
            [10] = 36,
        }),
        RankThresholds = table.freeze({
            [2] = 0,
            [3] = 0,
            [4] = 0,
            [5] = 0,
            [6] = 0,
            [7] = 0,
            [8] = 0,
            [9] = 0,
            [10] = 0,
        }),
        PhysicalReductionPerRank = 0.008,
        WeaponTags = table.freeze({}),
    }),

    -- Elf-only fifteen-rank self-heal-over-time, source levels 20–36.
    ElvenRenewal = table.freeze({
        Id = "ElvenRenewal",
        Tier = "Common",
        MaxRank = 15,
        Kind = "Support",
        AllowedRaces = table.freeze({"Elf"}),
        AllowedBaseClasses = table.freeze({"Ranger", "Rogue"}),
        RankLevels = table.freeze({
            [1] = 20,
            [2] = 20,
            [3] = 20,
            [4] = 24,
            [5] = 24,
            [6] = 24,
            [7] = 28,
            [8] = 28,
            [9] = 28,
            [10] = 32,
            [11] = 32,
            [12] = 32,
            [13] = 36,
            [14] = 36,
            [15] = 36,
        }),
        RankThresholds = table.freeze({
            [2] = 40,
            [3] = 80,
            [4] = 120,
            [5] = 160,
            [6] = 200,
            [7] = 240,
            [8] = 280,
            [9] = 320,
            [10] = 360,
            [11] = 400,
            [12] = 440,
            [13] = 480,
            [14] = 520,
            [15] = 560,
        }),
        WeaponTags = table.freeze({}),
    }),
    -- Elf-only fifteen-rank attack that reduces actual per-enemy threat.
    ElvenCalmingShot = table.freeze({
        Id = "ElvenCalmingShot",
        Tier = "Common",
        MaxRank = 15,
        Kind = "Control",
        AllowedRaces = table.freeze({"Elf"}),
        AllowedBaseClasses = table.freeze({"Ranger"}),
        RankLevels = table.freeze({
            [1] = 20,
            [2] = 20,
            [3] = 20,
            [4] = 24,
            [5] = 24,
            [6] = 24,
            [7] = 28,
            [8] = 28,
            [9] = 28,
            [10] = 32,
            [11] = 32,
            [12] = 32,
            [13] = 36,
            [14] = 36,
            [15] = 36,
        }),
        RankThresholds = table.freeze({
            [2] = 40,
            [3] = 80,
            [4] = 120,
            [5] = 160,
            [6] = 200,
            [7] = 240,
            [8] = 280,
            [9] = 320,
            [10] = 360,
            [11] = 400,
            [12] = 440,
            [13] = 480,
            [14] = 520,
            [15] = 560,
        }),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "CripplingShot", Rank = 3, Proficiency = 0,
            }),
        }),
        WeaponTags = table.freeze({"Longbow"}),
    }),

    -- C4 first-transfer Long Shot and arrow-velocity roles. Both alter
    -- genuine Ranger projectile travel after being purchased and equipped.
    RangerLongRange = table.freeze({
        Id = "RangerLongRange",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Ranger"}),
        RankLevels = table.freeze({[1] = 20}),
        BowRangeBonusStudsPerRank = 12,
        WeaponTags = table.freeze({"Longbow"}),
    }),
    RangerArrowVelocity = table.freeze({
        Id = "RangerArrowVelocity",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Ranger"}),
        RankLevels = table.freeze({[1] = 32}),
        ArrowSpeedBonusPerRank = 18,
        WeaponTags = table.freeze({"Longbow"}),
    }),

    -- Human first-transfer critical power (C4 levels 24 and 32).
    -- Purchased ranks affect real critical-hit damage, not raw attack.
    HumanScoutCriticalPower = table.freeze({
        Id = "HumanScoutCriticalPower",
        Tier = "Common",
        MaxRank = 2,
        Kind = "Passive",
        AllowedRaces = table.freeze({"Human"}),
        AllowedBaseClasses = table.freeze({"Ranger", "Rogue"}),
        RankLevels = table.freeze({[1] = 24, [2] = 32}),
        RankThresholds = table.freeze({[2] = 0}),
        CriticalDamageBonusPerRank = 0.08,
        WeaponTags = table.freeze({}),
    }),

    -- C4 first-transfer critical-rate training differs by race:
    -- Human Rogue learns it at 28, Elven Scout at 32.
    HumanScoutPrecision = table.freeze({
        Id = "HumanScoutPrecision",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedRaces = table.freeze({"Human"}),
        AllowedBaseClasses = table.freeze({"Ranger", "Rogue"}),
        RankLevels = table.freeze({[1] = 28}),
        CriticalChanceBonusPerRank = 0.02,
        WeaponTags = table.freeze({}),
    }),
    ElvenScoutPrecision = table.freeze({
        Id = "ElvenScoutPrecision",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedRaces = table.freeze({"Elf"}),
        AllowedBaseClasses = table.freeze({"Ranger", "Rogue"}),
        RankLevels = table.freeze({[1] = 32}),
        CriticalChanceBonusPerRank = 0.02,
        WeaponTags = table.freeze({}),
    }),

    -- Both C4 Rogue and Elven Scout learn movement speed at level 28.
    -- The purchased passive increases real server-owned Humanoid speed.
    ScoutFleetFoot = table.freeze({
        Id = "ScoutFleetFoot",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedRaces = table.freeze({"Human", "Elf"}),
        AllowedBaseClasses = table.freeze({"Ranger", "Rogue"}),
        RankLevels = table.freeze({[1] = 28}),
        MovementBonusPerRank = 0.06,
        WeaponTags = table.freeze({}),
    }),

    -- Human C4 Rogue attack-speed training at the level-36 bracket.
    -- A bought rank shortens actual server basic-attack timing.
    HumanScoutRapidHands = table.freeze({
        Id = "HumanScoutRapidHands",
        Tier = "Common",
        MaxRank = 1,
        Kind = "Passive",
        AllowedRaces = table.freeze({"Human"}),
        AllowedBaseClasses = table.freeze({"Ranger", "Rogue"}),
        RankLevels = table.freeze({[1] = 36}),
        AttackRateBonusPerRank = 0.06,
        WeaponTags = table.freeze({}),
    }),

    -- Repeated early bow and dagger training (C4-inspired effects):
    -- a stronger single-target shot/blow and weapon damage masteries.
    ArcherDraw = table.freeze({
        Id = "ArcherDraw",
        Tier = "Common",
        MaxRank = 9,
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Ranger"}),
        RankLevels = table.freeze({
            [1] = 5, [2] = 5, [3] = 5,
            [4] = 10, [5] = 10, [6] = 10,
            [7] = 15, [8] = 15, [9] = 15,
        }),
        RankThresholds = table.freeze({
            [2] = 20, [3] = 50, [4] = 90,
            [5] = 130, [6] = 180, [7] = 230,
            [8] = 290, [9] = 350,
        }),
        WeaponTags = table.freeze({"Longbow"}),
    }),
    RangerBowMastery = table.freeze({
        Id = "RangerBowMastery",
        Tier = "Common",
        MaxRank = 6,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Ranger"}),
        RankLevels = table.freeze({
            [1] = 5, [2] = 5, [3] = 5,
            [4] = 10, [5] = 10, [6] = 10,
        }),
        RankThresholds = table.freeze({
            [2] = 0, [3] = 0, [4] = 0,
            [5] = 0, [6] = 0,
        }),
        DamageBonusPerRank = 0.012,
        WeaponTags = table.freeze({"Longbow"}),
    }),
    RogueVitalBlow = table.freeze({
        Id = "RogueVitalBlow",
        Tier = "Common",
        MaxRank = 9,
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        RankLevels = table.freeze({
            [1] = 5, [2] = 5, [3] = 5,
            [4] = 10, [5] = 10, [6] = 10,
            [7] = 15, [8] = 15, [9] = 15,
        }),
        RankThresholds = table.freeze({
            [2] = 20, [3] = 50, [4] = 90,
            [5] = 130, [6] = 180, [7] = 230,
            [8] = 290, [9] = 350,
        }),
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    RogueBladeMastery = table.freeze({
        Id = "RogueBladeMastery",
        Tier = "Common",
        MaxRank = 6,
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        RankLevels = table.freeze({
            [1] = 5, [2] = 5, [3] = 5,
            [4] = 10, [5] = 10, [6] = 10,
        }),
        RankThresholds = table.freeze({
            [2] = 0, [3] = 0, [4] = 0,
            [5] = 0, [6] = 0,
        }),
        DamageBonusPerRank = 0.012,
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    ArcanistEmber = table.freeze({
        Id = "ArcanistEmber",
        Tier = "Rare",
        MaxRank = 3,
        Kind = "Magic",
        AllowedBaseClasses = table.freeze({"Mage"}),
        AllowedAdvancedClasses = table.freeze({"HumanArcanist"}),
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "AetherBolt", Rank = 3, Proficiency = 300,
            }),
            table.freeze({
                SkillId = "WindStrike", Rank = 3, Proficiency = 300,
            }),
        }),
        WeaponTags = table.freeze({"ArcaneWand"}),
    }),
    SpellweaverAegis = table.freeze({
        Id = "SpellweaverAegis",
        Tier = "Rare",
        MaxRank = 3,
        Kind = "Support",
        AllowedBaseClasses = table.freeze({"Mage"}),
        AllowedAdvancedClasses = table.freeze({"ElfSpellweaver"}),
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "DawnWard", Rank = 3, Proficiency = 100,
            }),
            table.freeze({
                SkillId = "ArcaneWard", Rank = 3, Proficiency = 300,
            }),
        }),
        WeaponTags = table.freeze({"ArcaneWand"}),
    }),

    -- Advanced skill purchase and combat use require the same
    -- persisted, race-specific advanced class, not just a base class.
    VanguardChallenge = table.freeze({
        Id = "VanguardChallenge",
        Tier = "Rare",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "GuardBreaker", Rank = 3, Proficiency = 300,
            }),
            table.freeze({
                SkillId = "ShieldBash", Rank = 3,
                Proficiency = 400,
            }),
        }),
        Kind = "Control",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        AllowedAdvancedClasses = table.freeze({"HumanVanguard"}),
        WeaponTags = table.freeze({}),
    }),
    ThornwardenBash = table.freeze({
        Id = "ThornwardenBash",
        Tier = "Rare",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "GuardBreaker", Rank = 3, Proficiency = 300,
            }),
            table.freeze({
                SkillId = "ShieldBash", Rank = 3,
                Proficiency = 400,
            }),
        }),
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        AllowedAdvancedClasses = table.freeze({"ElfThornwarden"}),
        WeaponTags = table.freeze({}),
    }),
    SharpshooterPierce = table.freeze({
        Id = "SharpshooterPierce",
        Tier = "Rare",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "TrackerShot", Rank = 3, Proficiency = 300,
            }),
            table.freeze({
                SkillId = "PiercingShot", Rank = 3,
                Proficiency = 300,
            }),
        }),
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Ranger"}),
        AllowedAdvancedClasses = table.freeze({"HumanSharpshooter"}),
        WeaponTags = table.freeze({"Longbow"}),
    }),
    WindrunnerVolley = table.freeze({
        Id = "WindrunnerVolley",
        Tier = "Rare",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "TrackerShot", Rank = 3, Proficiency = 300,
            }),
            table.freeze({
                SkillId = "PiercingShot", Rank = 3,
                Proficiency = 300,
            }),
        }),
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Ranger"}),
        AllowedAdvancedClasses = table.freeze({"ElfWindrunner"}),
        WeaponTags = table.freeze({"Longbow"}),
    }),

    QuickStrike = table.freeze({
        Id = "QuickStrike",
        Tier = "Common",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    Backstab = table.freeze({
        Id = "Backstab",
        Tier = "Uncommon",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    Feint = table.freeze({
        Id = "Feint",
        Tier = "Common",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Physical",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    ShadowDash = table.freeze({
        Id = "ShadowDash",
        Tier = "Uncommon",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Mobility",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    EvasiveStep = table.freeze({
        Id = "EvasiveStep",
        Tier = "Common",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Mobility",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    CriticalFocus = table.freeze({
        Id = "CriticalFocus",
        Tier = "Uncommon",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    LightFoot = table.freeze({
        Id = "LightFoot",
        Tier = "Common",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Passive",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        WeaponTags = table.freeze({}),
    }),
    ThreatDrop = table.freeze({
        Id = "ThreatDrop",
        Tier = "Uncommon",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 1, [2] = 8, [3] = 16}),
        Kind = "Utility",
        AllowedBaseClasses = table.freeze({"Rogue"}),
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),

    DuelistAmbush = table.freeze({
        Id = "DuelistAmbush",
        Tier = "Rare",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "RogueVitalBlow", Rank = 9,
                Proficiency = 350,
            }),
            table.freeze({
                SkillId = "Backstab", Rank = 3,
                Proficiency = 400,
            }),
        }),
        AllowedBaseClasses = table.freeze({"Rogue"}),
        AllowedAdvancedClasses = table.freeze({"HumanRogueDuelist"}),
        Kind = "Mobility",
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    DuelistDeadlyBlow = table.freeze({
        Id = "DuelistDeadlyBlow",
        Tier = "Rare",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "RogueVitalBlow", Rank = 9,
                Proficiency = 350,
            }),
            table.freeze({
                SkillId = "Backstab", Rank = 3,
                Proficiency = 400,
            }),
        }),
        AllowedBaseClasses = table.freeze({"Rogue"}),
        AllowedAdvancedClasses = table.freeze({"HumanRogueDuelist"}),
        Kind = "Physical",
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    DuelistExposeWeakness = table.freeze({
        Id = "DuelistExposeWeakness",
        Tier = "Uncommon",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "ViperStrike", Rank = 3,
                Proficiency = 300,
            }),
            table.freeze({
                SkillId = "Feint", Rank = 3,
                Proficiency = 300,
            }),
        }),
        AllowedBaseClasses = table.freeze({"Rogue"}),
        AllowedAdvancedClasses = table.freeze({"HumanRogueDuelist"}),
        Kind = "Physical",
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    DuelistRush = table.freeze({
        Id = "DuelistRush",
        Tier = "Uncommon",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "ViperStrike", Rank = 3,
                Proficiency = 300,
            }),
            table.freeze({
                SkillId = "ShadowDash", Rank = 3,
                Proficiency = 400,
            }),
        }),
        AllowedBaseClasses = table.freeze({"Rogue"}),
        AllowedAdvancedClasses = table.freeze({"HumanRogueDuelist"}),
        Kind = "Mobility",
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    DuelistCriticalMastery = table.freeze({
        Id = "DuelistCriticalMastery",
        Tier = "Rare",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "RogueBladeMastery", Rank = 6,
                Proficiency = 0,
            }),
            table.freeze({
                SkillId = "CriticalFocus", Rank = 3,
                Proficiency = 400,
            }),
        }),
        AllowedBaseClasses = table.freeze({"Rogue"}),
        AllowedAdvancedClasses = table.freeze({"HumanRogueDuelist"}),
        Kind = "Passive",
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),

    WindstalkerFlurry = table.freeze({
        Id = "WindstalkerFlurry",
        Tier = "Rare",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "RogueVitalBlow", Rank = 9,
                Proficiency = 350,
            }),
            table.freeze({
                SkillId = "Backstab", Rank = 3,
                Proficiency = 400,
            }),
        }),
        AllowedBaseClasses = table.freeze({"Rogue"}),
        AllowedAdvancedClasses = table.freeze({"ElfRogueWindstalker"}),
        Kind = "Physical",
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    WindstalkerSlipstream = table.freeze({
        Id = "WindstalkerSlipstream",
        Tier = "Uncommon",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "ViperStrike", Rank = 3,
                Proficiency = 300,
            }),
            table.freeze({
                SkillId = "ShadowDash", Rank = 3,
                Proficiency = 400,
            }),
        }),
        AllowedBaseClasses = table.freeze({"Rogue"}),
        AllowedAdvancedClasses = table.freeze({"ElfRogueWindstalker"}),
        Kind = "Mobility",
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    WindstalkerBlur = table.freeze({
        Id = "WindstalkerBlur",
        Tier = "Rare",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "ViperStrike", Rank = 3,
                Proficiency = 300,
            }),
            table.freeze({
                SkillId = "EvasiveStep", Rank = 3,
                Proficiency = 300,
            }),
        }),
        AllowedBaseClasses = table.freeze({"Rogue"}),
        AllowedAdvancedClasses = table.freeze({"ElfRogueWindstalker"}),
        Kind = "Mobility",
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    WindstalkerQuickstep = table.freeze({
        Id = "WindstalkerQuickstep",
        Tier = "Common",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "ViperStrike", Rank = 3,
                Proficiency = 300,
            }),
            table.freeze({
                SkillId = "ShadowDash", Rank = 3,
                Proficiency = 400,
            }),
        }),
        AllowedBaseClasses = table.freeze({"Rogue"}),
        AllowedAdvancedClasses = table.freeze({"ElfRogueWindstalker"}),
        Kind = "Mobility",
        WeaponTags = table.freeze({"OneHandedSword"}),
    }),
    WindstalkerEvasionMastery = table.freeze({
        Id = "WindstalkerEvasionMastery",
        Tier = "Rare",
        MaxRank = 3,
        RankLevels = table.freeze({[1] = 24, [2] = 28, [3] = 32}),
        Prerequisites = table.freeze({
            table.freeze({
                SkillId = "RogueBladeMastery", Rank = 6,
                Proficiency = 0,
            }),
            table.freeze({
                SkillId = "LightFoot", Rank = 3,
                Proficiency = 300,
            }),
        }),
        AllowedBaseClasses = table.freeze({"Rogue"}),
        AllowedAdvancedClasses = table.freeze({"ElfRogueWindstalker"}),
        Kind = "Passive",
        WeaponTags = table.freeze({}),
    }),
})

function SkillProgressionDefinitions.get(
    skill_id: string
): any?
    return DEFINITIONS[skill_id]
end

function SkillProgressionDefinitions.all(): any
    return DEFINITIONS
end

return table.freeze(
    SkillProgressionDefinitions
)
