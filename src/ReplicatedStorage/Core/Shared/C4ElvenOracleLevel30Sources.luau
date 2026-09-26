--!strict
-- Historical reference-only Elven Oracle skill-rank inventory through level 30.
-- Category keys are audit metadata, not copied player-facing game skills.

local Sources = {}

local ELVEN_ORACLE = table.freeze({
    SourceClass = "Elven Oracle",
    SourceClassId = 29,
    SourceUrl = "Pinned C4 skill_trees.sql class_id 29",
    SourceCommit = "07f8536384e799f128d44198dd7ab23519660eea",
    Levels = table.freeze({
        [20] = table.freeze({
            MagicResistance = 2,
            SpellReuse = 1,
            ManaCapacity = 1,
            RobeMastery = 2,
            LightArmorMastery = 2,
            WeaponMastery = 1,
            Heal = 3,
            BattleHeal = 3,
            Resurrection = 1,
            GroupHeal = 3,
            DisruptUndead = 2,
            Might = 1,
            KissOfEva = 1,
            Concentration = 1,
            WindWalk = 1,
            WindShackle = 1,
        }),
        [25] = table.freeze({
            MagicResistance = 2,
            FastSpellCasting = 1,
            ManaRecovery = 1,
            RobeMastery = 2,
            LightArmorMastery = 2,
            WeaponMastery = 2,
            Heal = 3,
            BattleHeal = 3,
            GroupHeal = 3,
            DisruptUndead = 2,
            MentalShield = 1,
            Shield = 1,
            HolyWeapon = 1,
            Sleep = 3,
            Agility = 1,
            DryadRoot = 3,
            WindShackle = 1,
        }),
        [30] = table.freeze({
            MagicResistance = 2,
            SpellReuse = 1,
            ManaCapacity = 1,
            RobeMastery = 2,
            LightArmorMastery = 2,
            WeaponMastery = 2,
            Heal = 3,
            Recharge = 2,
            BattleHeal = 3,
            Resurrection = 1,
            GroupHeal = 3,
            DisruptUndead = 2,
            Sleep = 3,
            Concentration = 1,
            DryadRoot = 3,
            WindWalk = 1,
            WindShackle = 1,
        }),
    }),
})

--[[
Returns the independently counted Elven Oracle source-rank inventory.

Args:
    None.

Returns:
    any: Reference-only level-20/25/30 rank records.
]]
function Sources.get(): any
    return ELVEN_ORACLE
end

return table.freeze(Sources)
