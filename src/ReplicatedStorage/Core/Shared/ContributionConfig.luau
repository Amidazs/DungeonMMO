--!strict
local ContributionConfig = {
    Version = 1,

    EventTypes = {
        DamageDealt = {
            Channel = "Damage",
            Breakdown = "DamageDealt",
            Weight = 1.0,
        },

        DamageMitigated = {
            Channel = "Tank",
            Breakdown = "DamageMitigated",
            Weight = 1.0,
        },

        AggroHeld = {
            Channel = "Tank",
            Breakdown = "AggroHeld",
            Weight = 1.0,
        },

        EffectiveHealing = {
            Channel = "Support",
            Breakdown = "EffectiveHealing",
            Weight = 1.0,
        },

        EffectiveWard = {
            Channel = "Support",
            Breakdown = "EffectiveWard",
            Weight = 1.0,
        },

        UtilitySupport = {
            Channel = "Support",
            Breakdown = "UtilitySupport",
            Weight = 1.0,
        },
    },
}

for _, definition in pairs(ContributionConfig.EventTypes) do
    table.freeze(definition)
end

table.freeze(ContributionConfig.EventTypes)

return table.freeze(ContributionConfig)
