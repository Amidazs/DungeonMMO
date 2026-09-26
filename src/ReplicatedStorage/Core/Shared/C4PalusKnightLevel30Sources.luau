--!strict
-- Historical Palus Knight source-rank inventory through level 30.
-- Category keys are audit metadata, not copied player-facing skill names.

local Sources = {}

local PALUS_KNIGHT = table.freeze({
    SourceClass = "Palus Knight",
    SourceClassId = 32,
    SourceUrl = "Pinned C4 skill_trees.sql class_id 32",
    SourceCommit = "07f8536384e799f128d44198dd7ab23519660eea",
    Levels = table.freeze({
        [20] = table.freeze({
            HealthDrain = 2,
            DefenseAura = 1,
            UltimateDefense = 1,
            Poison = 1,
            MagicResistance = 2,
            ShieldMastery = 1,
            SwordBluntMastery = 1,
            HeavyArmorMastery = 3,
        }),
        [24] = table.freeze({
            Confusion = 1,
            Aggression = 3,
            HealthDrain = 3,
            BowDefense = 1,
            MagicResistance = 3,
            SwordBluntMastery = 1,
            BleedAttack = 3,
            HeavyArmorMastery = 3,
        }),
        [28] = table.freeze({
            Confusion = 1,
            Aggression = 3,
            HealthDrain = 3,
            AttackAura = 1,
            MagicResistance = 3,
            ShieldMastery = 1,
            SwordBluntMastery = 2,
            BleedAttack = 3,
            HeavyArmorMastery = 3,
        }),
    }),
})

--[[
Returns the independently counted Palus Knight source-rank inventory.

Args:
    None.

Returns:
    any: Reference-only level-20/24/28 rank records.
]]
function Sources.get(): any
    return PALUS_KNIGHT
end

return table.freeze(Sources)
