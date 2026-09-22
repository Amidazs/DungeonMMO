--!strict
-- Source-counted Chronicle 4 Rogue/Elven Scout first-transfer ranks.
-- Raw rows belong to ONE C4 class, not two DungeonMMO classes.
-- Mechanics implemented by DungeonMMO are original analogue effects.
local C4ScoutSkillInventory = {}

local IMPLEMENTATIONS = table.freeze({
    BowAttack = table.freeze({
        SkillId = "ScoutFocusedShot",
        Owner = "Ranger",
        DaggerEquipmentPending = false,
    }),
    BowRange = table.freeze({
        SkillId = "RangerLongRange",
        Owner = "Ranger",
        DaggerEquipmentPending = false,
    }),
    ArrowSpeed = table.freeze({
        SkillId = "RangerArrowVelocity",
        Owner = "Ranger",
        DaggerEquipmentPending = false,
    }),

    DaggerAttack = table.freeze({
        SkillId = "RogueFinishingCut",
        Owner = "Rogue",
        DaggerEquipmentPending = false,
    }),
    BowMastery = table.freeze({
        SkillId = "ScoutBowDiscipline",
        Owner = "Ranger",
        DaggerEquipmentPending = false,
    }),
    DaggerMastery = table.freeze({
        SkillId = "RogueEdgeDiscipline",
        Owner = "Rogue",
        DaggerEquipmentPending = false,
    }),
    LightArmorMastery = table.freeze({
        SkillId = "ScoutLightArmorMastery",
        Owner = "RangerRogue",
        DaggerEquipmentPending = false,
    }),
    StunShot = table.freeze({
        SkillId = "ThunderShot",
        Owner = "Ranger",
        DaggerEquipmentPending = false,
    }),
    Bleed = table.freeze({
        SkillId = "LaceratingCut",
        Owner = "Rogue",
        DaggerEquipmentPending = false,
    }),
    AttackSpeed = table.freeze({
        SkillId = "HumanScoutRapidHands",
        Owner = "RangerRogue",
        DaggerEquipmentPending = false,
    }),
    ActiveEvasion = table.freeze({
        SkillId = "ScoutEvasiveFocus",
        Owner = "RangerRogue",
        DaggerEquipmentPending = false,
    }),
    DefenseBuff = table.freeze({
        SkillId = "ElvenScoutGuard",
        Owner = "RangerRogue",
        DaggerEquipmentPending = false,
    }),
    SittingRecovery = table.freeze({
        SkillId = "HumanScoutRestingRecovery",
        Owner = "RangerRogue",
        DaggerEquipmentPending = false,
    }),
    RunningRecovery = table.freeze({
        SkillId = "ScoutRunningRecovery",
        Owner = "RangerRogue",
        DaggerEquipmentPending = false,
    }),
    EvasionPassive = table.freeze({
        SkillId = "ScoutEvasion",
        Owner = "RangerRogue",
        DaggerEquipmentPending = false,
    }),
    RunningEvasion = table.freeze({
        SkillId = "ScoutRunningEvasion",
        Owner = "RangerRogue",
        DaggerEquipmentPending = false,
    }),
    MovementPassive = table.freeze({
        SkillId = "ScoutFleetFoot",
        Owner = "RangerRogue",
        DaggerEquipmentPending = false,
    }),
    CriticalDamagePassive = table.freeze({
        SkillId = "HumanScoutCriticalPower",
        Owner = "RangerRogue",
        DaggerEquipmentPending = false,
    }),
    HPRegeneration = table.freeze({
        SkillId = "ElvenRenewal",
        Owner = "RangerRogue",
        DaggerEquipmentPending = false,
    }),
    ThreatCharm = table.freeze({
        SkillId = "ElvenCalmingShot",
        Owner = "Ranger",
        DaggerEquipmentPending = false,
    }),
})

-- One source family has different purchase levels for Human and Elf.
local PRECISION_BY_RACE = table.freeze({
    Human = table.freeze({
        SkillId = "HumanScoutPrecision",
        Owner = "RangerRogue",
        DaggerEquipmentPending = false,
    }),
    Elf = table.freeze({
        SkillId = "ElvenScoutPrecision",
        Owner = "RangerRogue",
        DaggerEquipmentPending = false,
    }),
})

local SOURCES = table.freeze({
    Human = table.freeze({
        SourceUrl = "https://l2hub.info/c4/classes/rogue",
        Levels = table.freeze({
            [20] = table.freeze({
                EquipmentExpertise = 1,
                CommonItemCreation = 1,
                BowMastery = 3,
                DaggerMastery = 1,
                LightArmorMastery = 2,
                DaggerAttack = 3,
                BowAttack = 3,
                CriticalPowerToggle = 1,
                BowRange = 1,
                LungCapacity = 1,
                FallResistance = 1,
                Sprint = 1,
                Lockpicking = 1,
            }),
            [24] = table.freeze({
                BowMastery = 3,
                DaggerMastery = 1,
                LightArmorMastery = 2,
                DaggerAttack = 3,
                BowAttack = 3,
                CriticalPowerToggle = 1,
                CriticalDamagePassive = 1,
                EvasionPassive = 1,
                SittingRecovery = 1,
                Bleed = 1,
                AccuracyToggle = 1,
                Lockpicking = 1,
            }),
            [28] = table.freeze({
                CommonItemCreation = 1,
                BowMastery = 3,
                DaggerMastery = 2,
                LightArmorMastery = 2,
                DaggerAttack = 3,
                BowAttack = 3,
                CriticalPowerToggle = 1,
                CriticalRatePassive = 1,
                MovementPassive = 1,
                RunningEvasion = 1,
                Lockpicking = 1,
                ActiveEvasion = 1,
            }),
            [32] = table.freeze({
                BowMastery = 3,
                DaggerMastery = 2,
                LightArmorMastery = 2,
                DaggerAttack = 3,
                BowAttack = 3,
                CriticalPowerToggle = 1,
                ArrowSpeed = 1,
                CriticalDamagePassive = 1,
                SittingRecovery = 1,
                Bleed = 1,
                Lockpicking = 1,
            }),
            [36] = table.freeze({
                CommonItemCreation = 1,
                BowMastery = 3,
                DaggerMastery = 2,
                LightArmorMastery = 2,
                DaggerAttack = 3,
                BowAttack = 3,
                StunShot = 3,
                CriticalPowerToggle = 1,
                AttackSpeed = 1,
                RunningRecovery = 1,
                Lockpicking = 1,
            }),
        }),
    }),
    Elf = table.freeze({
        SourceUrl = "https://l2hub.info/c4/classes/elven_scout",
        Levels = table.freeze({
            [20] = table.freeze({
                EquipmentExpertise = 1,
                CommonItemCreation = 1,
                BowMastery = 3,
                DaggerMastery = 1,
                LightArmorMastery = 2,
                DaggerAttack = 3,
                BowAttack = 3,
                HPRegeneration = 3,
                ThreatCharm = 3,
                CriticalPowerToggle = 1,
                DefenseBuff = 1,
                BowRange = 1,
                LungCapacity = 1,
                FallResistance = 1,
                Lockpicking = 1,
            }),
            [24] = table.freeze({
                BowMastery = 3,
                DaggerMastery = 1,
                LightArmorMastery = 2,
                DaggerAttack = 3,
                BowAttack = 3,
                HPRegeneration = 3,
                ThreatCharm = 3,
                CriticalPowerToggle = 1,
                EvasionPassive = 1,
                CureWounds = 1,
                CurePoison = 1,
                Bleed = 1,
                AccuracyToggle = 1,
                Lockpicking = 1,
            }),
            [28] = table.freeze({
                CommonItemCreation = 1,
                BowMastery = 3,
                DaggerMastery = 2,
                LightArmorMastery = 2,
                DaggerAttack = 3,
                BowAttack = 3,
                HPRegeneration = 3,
                ThreatCharm = 3,
                CriticalPowerToggle = 1,
                MovementPassive = 1,
                RunningEvasion = 1,
                AttackBuff = 1,
                Lockpicking = 1,
                ActiveEvasion = 1,
            }),
            [32] = table.freeze({
                BowMastery = 3,
                DaggerMastery = 2,
                LightArmorMastery = 2,
                DaggerAttack = 3,
                BowAttack = 3,
                HPRegeneration = 3,
                ThreatCharm = 3,
                CriticalPowerToggle = 1,
                CriticalRatePassive = 1,
                ArrowSpeed = 1,
                SpeedBuff = 1,
                Bleed = 1,
                Lockpicking = 1,
            }),
            [36] = table.freeze({
                CommonItemCreation = 1,
                BowMastery = 3,
                DaggerMastery = 2,
                LightArmorMastery = 2,
                DaggerAttack = 3,
                BowAttack = 3,
                HPRegeneration = 3,
                ThreatCharm = 3,
                StunShot = 3,
                CriticalPowerToggle = 1,
                MovementSlow = 1,
                RunningRecovery = 1,
                Lockpicking = 1,
            }),
        }),
    }),
})

--[[
Returns the C4 class source and its raw per-level rank-entry families.

Args:
    race_id (string): Human Rogue or Elf Elven Scout.

Returns:
    any?: Frozen source family counts, or nil for an unmapped race.
]]
function C4ScoutSkillInventory.get(race_id: string): any?
    return SOURCES[race_id]
end

--[[
Returns the DungeonMMO functional analogue for one source family.

Args:
    category (string): Source-family category from an authored level.
    race_id (string?): Optional source race for differing purchase levels.

Returns:
    any?: Skill ID, owned branch and dagger-equipment warning when mapped.
]]
function C4ScoutSkillInventory.implementation(
    category: string,
    race_id: string?
): any?
    if category == "CriticalRatePassive" then
        return PRECISION_BY_RACE[race_id]
    end
    return IMPLEMENTATIONS[category]
end

--[[
Audits the source rank entries without double-counting shared class skills.

Args:
    race_id (string): Human or Elf source class.

Returns:
    any?: Raw total, functional analogue, equipment-mismatch and
        not-yet-implemented source rank counts and missing families.
]]
function C4ScoutSkillInventory.audit(race_id: string): any?
    local source = SOURCES[race_id]
    if not source then
        return nil
    end

    local result = {
        Raw = 0,
        Functional = 0,
        EquipmentMismatch = 0,
        Missing = 0,
        MissingFamilies = {},
        Levels = {},
    }
    for level, categories in pairs(source.Levels) do
        local bracket = {Raw = 0, Functional = 0, Missing = 0}
        for category, count in pairs(categories) do
            bracket.Raw += count
            local mapping = C4ScoutSkillInventory.implementation(
                category, race_id
            )
            if mapping then
                bracket.Functional += count
                if mapping.DaggerEquipmentPending then
                    result.EquipmentMismatch += count
                end
            else
                bracket.Missing += count
                result.MissingFamilies[category] = (
                    result.MissingFamilies[category] or 0
                ) + count
            end
        end
        result.Levels[level] = bracket
        result.Raw += bracket.Raw
        result.Functional += bracket.Functional
        result.Missing += bracket.Missing
    end
    return result
end

return table.freeze(C4ScoutSkillInventory)
