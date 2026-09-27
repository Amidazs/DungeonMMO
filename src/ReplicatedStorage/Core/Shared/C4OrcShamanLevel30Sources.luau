--!strict
-- Historical Orc Shaman source-rank inventory through level 30.
-- Category keys are audit metadata, not player-facing skill names.

local Sources = {}

local ORC_SHAMAN = table.freeze({
    SourceClass = "Orc Shaman",
    SourceClassId = 50,
    SourceUrl = "Pinned C4 skill_trees.sql class_id 50",
    SourceCommit = "07f8536384e799f128d44198dd7ab23519660eea",
    Levels = table.freeze({
        [20] = table.freeze({
            StunAttack = 3,
            AntiMagic = 2,
            QuickRecovery = 1,
            BoostMana = 1,
            WeaponMastery = 1,
            RobeMastery = 2,
            LightArmorMastery = 2,
            HeavyArmorMastery = 2,
            ChantOfFire = 1,
            ChantOfShielding = 1,
            LifeDrain = 1,
            Fear = 1,
            Venom = 1,
            DreamingSpirit = 1,
            Madness = 1,
            FrostFlame = 1,
            SealOfPoison = 1,
            ChantOfLife = 1,
        }),
        [25] = table.freeze({
            StunAttack = 3,
            AntiMagic = 2,
            FastSpellCasting = 1,
            FastManaRecovery = 1,
            WeaponMastery = 2,
            RobeMastery = 2,
            LightArmorMastery = 2,
            HeavyArmorMastery = 2,
            SoulCry = 1,
            ChantOfBattle = 1,
            SoulShield = 1,
            LifeDrain = 1,
            Fear = 1,
            DreamingSpirit = 1,
            BlazeQuake = 1,
            AuraSink = 1,
            Madness = 1,
            SealOfBinding = 1,
            ChantOfLife = 1,
        }),
        [30] = table.freeze({
            StunAttack = 3,
            AntiMagic = 2,
            QuickRecovery = 1,
            BoostMana = 1,
            WeaponMastery = 2,
            RobeMastery = 2,
            LightArmorMastery = 2,
            HeavyArmorMastery = 2,
            ChantOfFlame = 1,
            PowerOfPaagrio = 1,
            ChantOfShielding = 1,
            LifeDrain = 1,
            Fear = 1,
            SealOfChaos = 1,
            DreamingSpirit = 1,
            Madness = 1,
            FrostFlame = 1,
            SealOfBinding = 1,
            SealOfPoison = 1,
            ChantOfLife = 1,
        }),
    }),
})

--[[
Returns the independently counted Orc Shaman source inventory.

Args:
    None.

Returns:
    any: Reference-only level-20/25/30 rank records.
]]
function Sources.get(): any
    return ORC_SHAMAN
end

return table.freeze(Sources)
