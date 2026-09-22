--!strict
local SkillProgressionDefinitions = {}

local DEFINITIONS = table.freeze({
    Mend = table.freeze({
        Id = "Mend",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Support",
        WeaponTags = table.freeze({}),
    }),

    Taunt = table.freeze({
        Id = "Taunt",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Control",
        AllowedBaseClasses = table.freeze({"Fighter"}),
        WeaponTags = table.freeze({}),
    }),

    ShieldBash = table.freeze({
        Id = "ShieldBash",
        Tier = "Uncommon",
        MaxRank = 3,
        Kind = "Physical",
        WeaponTags = table.freeze({}),
    }),

    ArcSlash = table.freeze({
        Id = "ArcSlash",
        Tier = "Rare",
        MaxRank = 3,
        Kind = "Physical",
        WeaponTags = table.freeze({
            "OneHandedSword",
        }),
    }),

    WindStrike = table.freeze({
        Id = "WindStrike",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Magic",
        WeaponTags = table.freeze({
            "ArcaneWand",
        }),
    }),

    ArcaneWard = table.freeze({
        Id = "ArcaneWard",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Support",
        WeaponTags = table.freeze({
            "ArcaneWand",
        }),
    }),

    MageHeal = table.freeze({
        Id = "MageHeal",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Support",
        WeaponTags = table.freeze({
            "ArcaneWand",
        }),
    }),

    PiercingShot = table.freeze({
        Id = "PiercingShot",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Physical",
        WeaponTags = table.freeze({
            "Longbow",
        }),
    }),

    CripplingShot = table.freeze({
        Id = "CripplingShot",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Control",
        WeaponTags = table.freeze({
            "Longbow",
        }),
    }),

    Volley = table.freeze({
        Id = "Volley",
        Tier = "Common",
        MaxRank = 3,
        Kind = "Physical",
        WeaponTags = table.freeze({
            "Longbow",
        }),
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

    QuickStrike = table.freeze({Id="QuickStrike",Tier="Common",MaxRank=3,Kind="Physical",WeaponTags=table.freeze({"OneHandedSword"})}),
    Backstab = table.freeze({Id="Backstab",Tier="Uncommon",MaxRank=3,Kind="Physical",WeaponTags=table.freeze({"OneHandedSword"})}),
    Feint = table.freeze({Id="Feint",Tier="Common",MaxRank=3,Kind="Physical",WeaponTags=table.freeze({"OneHandedSword"})}),
    ShadowDash = table.freeze({Id="ShadowDash",Tier="Uncommon",MaxRank=3,Kind="Mobility",WeaponTags=table.freeze({"OneHandedSword"})}),
    EvasiveStep = table.freeze({Id="EvasiveStep",Tier="Common",MaxRank=3,Kind="Mobility",WeaponTags=table.freeze({"OneHandedSword"})}),
    CriticalFocus = table.freeze({Id="CriticalFocus",Tier="Uncommon",MaxRank=3,Kind="Passive",WeaponTags=table.freeze({"OneHandedSword"})}),
    LightFoot = table.freeze({Id="LightFoot",Tier="Common",MaxRank=3,Kind="Passive",WeaponTags=table.freeze({})}),
    ThreatDrop = table.freeze({Id="ThreatDrop",Tier="Uncommon",MaxRank=3,Kind="Utility",WeaponTags=table.freeze({"OneHandedSword"})}),

    DuelistAmbush = table.freeze({Id="DuelistAmbush",Tier="Rare",MaxRank=3,Kind="Mobility",WeaponTags=table.freeze({"OneHandedSword"})}),
    DuelistDeadlyBlow = table.freeze({Id="DuelistDeadlyBlow",Tier="Rare",MaxRank=3,Kind="Physical",WeaponTags=table.freeze({"OneHandedSword"})}),
    DuelistExposeWeakness = table.freeze({Id="DuelistExposeWeakness",Tier="Uncommon",MaxRank=3,Kind="Physical",WeaponTags=table.freeze({"OneHandedSword"})}),
    DuelistRush = table.freeze({Id="DuelistRush",Tier="Uncommon",MaxRank=3,Kind="Mobility",WeaponTags=table.freeze({"OneHandedSword"})}),
    DuelistCriticalMastery = table.freeze({Id="DuelistCriticalMastery",Tier="Rare",MaxRank=3,Kind="Passive",WeaponTags=table.freeze({"OneHandedSword"})}),

    WindstalkerFlurry = table.freeze({Id="WindstalkerFlurry",Tier="Rare",MaxRank=3,Kind="Physical",WeaponTags=table.freeze({"OneHandedSword"})}),
    WindstalkerSlipstream = table.freeze({Id="WindstalkerSlipstream",Tier="Uncommon",MaxRank=3,Kind="Mobility",WeaponTags=table.freeze({"OneHandedSword"})}),
    WindstalkerBlur = table.freeze({Id="WindstalkerBlur",Tier="Rare",MaxRank=3,Kind="Mobility",WeaponTags=table.freeze({"OneHandedSword"})}),
    WindstalkerQuickstep = table.freeze({Id="WindstalkerQuickstep",Tier="Common",MaxRank=3,Kind="Mobility",WeaponTags=table.freeze({"OneHandedSword"})}),
    WindstalkerEvasionMastery = table.freeze({Id="WindstalkerEvasionMastery",Tier="Rare",MaxRank=3,Kind="Passive",WeaponTags=table.freeze({})}),
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
