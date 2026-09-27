--!strict
-- Historical Dark Elf Assassin source-rank inventory through level 30.
-- Category keys are audit metadata, not copied player-facing skill names.

local Sources = {}

local DARK_ELF_ASSASSIN = table.freeze({
    SourceClass = "Assassin",
    SourceClassId = 35,
    SourceUrl = "Pinned C4 skill_trees.sql class_id 35",
    SourceCommit = "07f8536384e799f128d44198dd7ab23519660eea",
    Levels = table.freeze({
        [20] = table.freeze({
            MortalBlow = 3,
            Unlock = 1,
            PowerShot = 3,
            HealthDrain = 2,
            DefenseAura = 1,
            BowRange = 1,
            Poison = 1,
            FallResistance = 1,
            LungCapacity = 1,
            BowMastery = 3,
            DaggerMastery = 1,
            LightArmorMastery = 2,
            CriticalPowerToggle = 1,
        }),
        [24] = table.freeze({
            Confusion = 1,
            MortalBlow = 3,
            Unlock = 1,
            PowerShot = 3,
            HealthDrain = 3,
            Bleed = 1,
            CriticalPower = 1,
            Evasion = 1,
            BowMastery = 3,
            DaggerMastery = 1,
            Sting = 3,
            LightArmorMastery = 2,
            AccuracyToggle = 1,
            CriticalPowerToggle = 1,
        }),
        [28] = table.freeze({
            Confusion = 1,
            MortalBlow = 3,
            Unlock = 1,
            PowerShot = 3,
            HealthDrain = 3,
            AttackAura = 1,
            UltimateEvasion = 1,
            QuickStep = 1,
            BowMastery = 3,
            DaggerMastery = 2,
            Sting = 3,
            AcrobaticMove = 1,
            LightArmorMastery = 2,
            CriticalPowerToggle = 1,
        }),
    }),
})

--[[
Returns the independently counted Dark Elf Assassin source-rank inventory.

Args:
    None.

Returns:
    any: Reference-only level-20/24/28 rank records.
]]
function Sources.get(): any
    return DARK_ELF_ASSASSIN
end

return table.freeze(Sources)
