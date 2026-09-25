--!strict
-- Historical reference-only Human Wizard skill-rank inventory through level 30.
-- Category keys are audit metadata, not copied player-facing game skills.
local Sources = {}

local HUMAN_WIZARD = table.freeze({
    SourceClass = "Human Wizard",
    SourceUrl = "https://l2hub.info/c4/classes/wizard",
    Levels = table.freeze({
        [20] = table.freeze({
            EquipmentExpertise = 1,
            CommonItemCreation = 1,
            WeaponMastery = 1,
            RobeMastery = 2,
            MagicResistance = 2,
            ManaRechargeEfficiency = 2,
            ManaCapacity = 1,
            SpellReuse = 1,
            FrostSlowBolt = 2,
            HealthDrain = 2,
            FireBolt = 2,
            CloseMagicBurst = 2,
            ServitorHeal = 3,
            AttackWeakness = 1,
            EfficientMagicBolt = 1,
            FireAreaAttack = 1,
            PoisonCurse = 1,
            ManaServitorSummon = 1,
            CombatServitorSummon = 1,
            CastConcentration = 1,
        }),
        [25] = table.freeze({
            WeaponMastery = 2,
            RobeMastery = 2,
            MagicResistance = 2,
            ManaRechargeEfficiency = 2,
            FastSpellCasting = 1,
            ManaRecovery = 1,
            HealthDrain = 2,
            FireBolt = 2,
            CloseMagicBurst = 2,
            ServitorHeal = 3,
            Sleep = 3,
            ServitorRecharge = 2,
            AttackWeakness = 1,
            FireVulnerability = 1,
            EfficientMagicBolt = 1,
            FireAreaAttack = 1,
            ManaServitorSummon = 1,
            CombatServitorSummon = 1,
            PoisonCloud = 1,
            HealthToMana = 1,
        }),
        [28] = table.freeze({
            CommonItemCreation = 1,
        }),
        [30] = table.freeze({
            WeaponMastery = 2,
            RobeMastery = 2,
            MagicResistance = 2,
            ManaRechargeEfficiency = 2,
            ManaCapacity = 1,
            SpellReuse = 1,
            FireBolt = 2,
            CloseMagicBurst = 2,
            ServitorHeal = 3,
            ServitorRecharge = 2,
            Sleep = 3,
            AttackWeakness = 1,
            FireVulnerability = 1,
            EfficientMagicBolt = 1,
            FireAreaAttack = 1,
            PoisonCurse = 1,
            ManaServitorSummon = 1,
            CombatServitorSummon = 1,
            CastConcentration = 1,
            CorpseHealthDrain = 1,
        }),
    }),
})

--[[
Returns the independently counted Human Wizard source-rank inventory.

Args:
    None.

Returns:
    any: Reference-only level-20/25/28/30 rank records.
]]
function Sources.get(): any
    return HUMAN_WIZARD
end

return table.freeze(Sources)
