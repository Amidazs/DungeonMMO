--!strict
-- Historical reference-only Elven Wizard skill-rank inventory through level 30.
-- Category keys are audit metadata, not copied player-facing game skills.

local Sources = {}

local ELVEN_WIZARD = table.freeze({
    SourceClass = "Elven Wizard",
    SourceUrl = "C4 skill_trees.sql class_id=26",
    Levels = table.freeze({
        [20] = table.freeze({
            MagicResistance = 2,
            SpellReuse = 1,
            ManaCapacity = 1,
            RobeMastery = 2,
            WeaponMastery = 1,
            ManaRechargeEfficiency = 2,
            CastConcentration = 1,
            ServitorHeal = 3,
            AttackWeakness = 1,
            CloseMagicBurst = 2,
            WaterBolt = 2,
            FireAreaAttack = 1,
            FrostSlowBolt = 2,
            ManaServitorSummon = 1,
            CombatServitorSummon = 1,
            EfficientMagicBolt = 1,
        }),
        [25] = table.freeze({
            MagicResistance = 2,
            FastSpellCasting = 1,
            ManaRecovery = 1,
            RobeMastery = 2,
            WeaponMastery = 2,
            ManaRechargeEfficiency = 2,
            Sleep = 3,
            ServitorRecharge = 2,
            ServitorHeal = 3,
            AttackWeakness = 1,
            CloseMagicBurst = 2,
            WaterBolt = 2,
            FireAreaAttack = 1,
            ResistWater = 1,
            ManaServitorSummon = 1,
            CombatServitorSummon = 1,
            HolyBolt = 1,
            EfficientMagicBolt = 1,
        }),
        [30] = table.freeze({
            MagicResistance = 2,
            SpellReuse = 1,
            ManaCapacity = 1,
            RobeMastery = 2,
            WeaponMastery = 2,
            ManaRechargeEfficiency = 2,
            Sleep = 3,
            CastConcentration = 1,
            ServitorRecharge = 2,
            ServitorHeal = 3,
            AttackWeakness = 1,
            CloseMagicBurst = 2,
            WaterBolt = 2,
            FireAreaAttack = 1,
            ManaServitorSummon = 1,
            CombatServitorSummon = 1,
            HolyBolt = 1,
            EfficientMagicBolt = 1,
        }),
    }),
})

--[[
Returns the independently counted Elven Wizard source-rank inventory.

Args:
    None.

Returns:
    any: Reference-only level-20/25/30 rank records.
]]
function Sources.get(): any
    return ELVEN_WIZARD
end

return table.freeze(Sources)
