--!strict
-- Historical Artisan source-rank inventory through level 30.
-- Category keys are audit metadata, not player-facing skill names.

local Sources = {}

local ARTISAN = table.freeze({
    SourceClass = "Artisan",
    SourceClassId = 56,
    SourceUrl = "Pinned C4 skill_trees.sql class_id 56",
    SourceCommit = "07f8536384e799f128d44198dd7ab23519660eea",
    Levels = table.freeze({
        [20] = table.freeze({
            Bandage = 1,
            StunAttack = 3,
            CreateItem = 1,
            BluntMastery = 1,
            BoostHP = 1,
            PolearmMastery = 1,
            LightArmorMastery = 2,
            HeavyArmorMastery = 2,
            WildSweep = 3,
            Crystallize = 1,
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
            MechanicGolem = 1,
            StunAttack = 3,
            CreateItem = 1,
            BluntMastery = 2,
            BoostHP = 1,
            PolearmMastery = 2,
            LightArmorMastery = 3,
            HeavyArmorMastery = 3,
            WildSweep = 3,
        }),
    }),
})

--[[
Returns the independently counted Artisan source inventory.

Args:
    None.

Returns:
    any: Reference-only level-20/24/28 rank records.
]]
function Sources.get(): any
    return ARTISAN
end

return table.freeze(Sources)
