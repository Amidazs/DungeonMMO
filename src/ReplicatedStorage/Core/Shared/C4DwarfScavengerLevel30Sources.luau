--!strict
-- Historical Scavenger source-rank inventory through level 30.
-- Category keys are audit metadata, not player-facing skill names.

local Sources = {}

local SCAVENGER = table.freeze({
    SourceClass = "Scavenger",
    SourceClassId = 54,
    SourceUrl = "Pinned C4 skill_trees.sql class_id 54",
    SourceCommit = "07f8536384e799f128d44198dd7ab23519660eea",
    Levels = table.freeze({
        [20] = table.freeze({
            Bandage = 1,
            StunAttack = 3,
            BluntMastery = 1,
            BoostHP = 1,
            PolearmMastery = 1,
            LightArmorMastery = 2,
            HeavyArmorMastery = 2,
            WildSweep = 3,
            Spoil = 1,
        }),
        [24] = table.freeze({
            StunAttack = 3,
            VitalForce = 1,
            WeightLimit = 1,
            BluntMastery = 1,
            FastHPRecovery = 1,
            PolearmMastery = 1,
            LightArmorMastery = 2,
            HeavyArmorMastery = 2,
            WildSweep = 3,
        }),
        [28] = table.freeze({
            StunAttack = 3,
            BluntMastery = 2,
            BoostHP = 1,
            PolearmMastery = 2,
            LightArmorMastery = 3,
            HeavyArmorMastery = 3,
            WildSweep = 3,
            Spoil = 1,
            SpoilFestival = 1,
        }),
    }),
})

--[[
Returns the independently counted Scavenger source inventory.

Args:
    None.

Returns:
    any: Reference-only level-20/24/28 rank records.
]]
function Sources.get(): any
    return SCAVENGER
end

return table.freeze(Sources)
