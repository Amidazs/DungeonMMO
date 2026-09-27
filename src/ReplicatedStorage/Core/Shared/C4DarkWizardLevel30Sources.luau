--!strict
-- Historical Dark Wizard source-rank inventory through level 30.
-- Category keys are audit metadata, not copied player-facing skill names.

local Sources = {}

local DARK_WIZARD = table.freeze({
    SourceClass = "Dark Wizard",
    SourceClassId = 39,
    SourceUrl = "Pinned C4 skill_trees.sql class_id 39",
    SourceCommit = "07f8536384e799f128d44198dd7ab23519660eea",
    Levels = table.freeze({
        [20] = table.freeze({
            AntiMagic = 2,
            QuickRecovery = 1,
            BoostMana = 1,
            RobeMastery = 2,
            WeaponMastery = 1,
            HigherManaGain = 2,
            Concentration = 1,
            ServitorHeal = 3,
            SummonShadow = 1,
            VampiricTouch = 2,
            Poison = 1,
            AuraBurn = 2,
            Twister = 2,
            FlameStrike = 1,
            IceBolt = 2,
            SummonSilhouette = 1,
        }),
        [25] = table.freeze({
            AntiMagic = 2,
            FastSpellCasting = 1,
            FastManaRecovery = 1,
            RobeMastery = 2,
            WeaponMastery = 2,
            HigherManaGain = 2,
            Sleep = 3,
            ServitorRecharge = 2,
            ServitorHeal = 3,
            SummonShadow = 1,
            VampiricTouch = 2,
            BodyToMind = 1,
            PoisonCloud = 1,
            AuraBurn = 2,
            Twister = 2,
            FlameStrike = 1,
            SurrenderToPoison = 1,
            SummonSilhouette = 1,
            ShadowSpark = 1,
        }),
        [30] = table.freeze({
            AntiMagic = 2,
            QuickRecovery = 1,
            BoostMana = 1,
            RobeMastery = 2,
            WeaponMastery = 2,
            HigherManaGain = 2,
            Sleep = 3,
            Concentration = 1,
            ServitorRecharge = 2,
            ServitorHeal = 3,
            SummonShadow = 1,
            CorpseLifeDrain = 1,
            Poison = 1,
            AuraBurn = 2,
            Twister = 2,
            FlameStrike = 1,
            SurrenderToPoison = 1,
            SummonSilhouette = 1,
            ShadowSpark = 1,
        }),
    }),
})

--[[
Returns the independently counted Dark Wizard source-rank inventory.

Args:
    None.

Returns:
    any: Reference-only level-20/25/30 rank records.
]]
function Sources.get(): any
    return DARK_WIZARD
end

return table.freeze(Sources)
