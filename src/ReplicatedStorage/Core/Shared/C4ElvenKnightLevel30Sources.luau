--!strict
-- Historical C4 Elven Knight training-rank inventory through level 30.
-- These are source metadata, not purchasable skills or playable class IDs.
local Sources = {}

local SOURCE = table.freeze({
    SourceUrl = "https://l2hub.info/c4/classes/elven_knight",
    Levels = table.freeze({
        [20] = table.freeze({
            EquipmentExpertise = 1,
            CommonItemCreation = 1,
            SwordBluntMastery = 1,
            HeavyArmorMastery = 3,
            MagicResistance = 2,
            ElementalHeal = 3,
            Charm = 3,
            DefenseAura = 1,
            ShieldMastery = 1,
            UltimateDefense = 1,
            PoisonRecovery = 1,
        }),
        [24] = table.freeze({
            SwordBluntMastery = 1,
            HeavyArmorMastery = 3,
            MagicResistance = 3,
            ElementalHeal = 3,
            Charm = 3,
            Aggression = 3,
            BowDefense = 1,
            BleedRecovery = 1,
        }),
        [28] = table.freeze({
            CommonItemCreation = 1,
            SwordBluntMastery = 2,
            HeavyArmorMastery = 3,
            MagicResistance = 3,
            ElementalHeal = 3,
            Charm = 3,
            Aggression = 3,
            ShieldMastery = 1,
            AttackAura = 1,
        }),
    }),
})

--[[
Returns the Elven Knight's distinct historical level-20/24/28 ranks.

Args:
    None.

Returns:
    any: Frozen source-only skill-family counts and reference URL.
]]
function Sources.get(): any
    return SOURCE
end

return table.freeze(Sources)
