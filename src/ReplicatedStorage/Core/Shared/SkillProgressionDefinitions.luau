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
