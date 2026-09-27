--!strict
-- Historical Orc Raider source-rank inventory through level 30.
-- Category keys are audit metadata, not copied player-facing skill names.

local Sources = {}

local ORC_RAIDER = table.freeze({
    SourceClass = "Orc Raider",
    SourceClassId = 45,
    SourceUrl = "Pinned C4 skill_trees.sql class_id 45",
    SourceCommit = "07f8536384e799f128d44198dd7ab23519660eea",
    Levels = table.freeze({
        [20] = table.freeze({
            Bandage = 1,
            StunAttack = 3,
            BoostHP = 1,
            PolearmMastery = 1,
            LightArmorMastery = 2,
            HeavyArmorMastery = 2,
            WildSweep = 3,
            PowerSmash = 3,
            SwordBluntMastery = 1,
            TwoHandedWeaponMaster = 1,
            ViciousStance = 1,
        }),
        [24] = table.freeze({
            Rage = 1,
            StunAttack = 3,
            VitalForce = 1,
            FastHPRecovery = 1,
            PolearmMastery = 1,
            LightArmorMastery = 2,
            HeavyArmorMastery = 2,
            WildSweep = 3,
            PowerSmash = 3,
            Accuracy = 1,
            SwordBluntMastery = 1,
            TwoHandedWeaponMaster = 1,
            ViciousStance = 1,
        }),
        [28] = table.freeze({
            StunAttack = 3,
            BattleRoar = 1,
            BoostHP = 1,
            PolearmMastery = 2,
            LightArmorMastery = 3,
            HeavyArmorMastery = 3,
            WildSweep = 3,
            PowerSmash = 3,
            SwordBluntMastery = 2,
            TwoHandedWeaponMaster = 1,
            ViciousStance = 1,
        }),
    }),
})

--[[
Returns the independently counted Orc Raider source-rank inventory.

Args:
    None.

Returns:
    any: Reference-only level-20/24/28 rank records.
]]
function Sources.get(): any
    return ORC_RAIDER
end

return table.freeze(Sources)
