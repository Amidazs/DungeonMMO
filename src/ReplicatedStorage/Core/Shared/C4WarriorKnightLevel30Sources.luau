--!strict
-- Historical reference-only class skill-rank inventory for levels 20-30.
-- Category keys are audit metadata, NOT copied player-facing game skills.
local Sources = {}

local CLASSES = table.freeze({
    HumanWarrior = table.freeze({
        SourceUrl = "https://l2hub.info/c4/classes/warrior",
        Levels = table.freeze({
            [20] = table.freeze({
                EquipmentExpertise = 1, CommonItemCreation = 1,
                SwordBluntMastery = 1, PolearmMastery = 1,
                LightArmorMastery = 2, HeavyArmorMastery = 2,
                SwordPowerAttack = 3, BluntControl = 3,
                PolearmAreaAttack = 3, CriticalStance = 1,
                HealthTraining = 1, BattleCry = 1,
            }),
            [24] = table.freeze({
                SwordBluntMastery = 1, PolearmMastery = 1,
                LightArmorMastery = 2, HeavyArmorMastery = 2,
                SwordPowerAttack = 3, BluntControl = 3,
                PolearmAreaAttack = 3, CriticalStance = 1,
                HealthRecovery = 1, RestingRecovery = 1,
                AccuracyStance = 1,
            }),
            [28] = table.freeze({
                CommonItemCreation = 1, SwordBluntMastery = 2,
                PolearmMastery = 2, LightArmorMastery = 3,
                HeavyArmorMastery = 3, SwordPowerAttack = 3,
                BluntControl = 3, PolearmAreaAttack = 3,
                CriticalStance = 1, HealthTraining = 1,
                EnduranceSurge = 1,
            }),
        }),
    }),
    HumanKnight = table.freeze({
        SourceUrl = "https://l2hub.info/c4/classes/knight",
        Levels = table.freeze({
            [20] = table.freeze({
                EquipmentExpertise = 1, CommonItemCreation = 1,
                SwordBluntMastery = 1, HeavyArmorMastery = 3,
                MagicResistance = 2, LifeDrain = 2,
                ShieldControl = 3, ShieldMastery = 1,
                DefensiveStance = 1, LastStand = 1,
            }),
            [24] = table.freeze({
                SwordBluntMastery = 1, HeavyArmorMastery = 3,
                MagicResistance = 3, LifeDrain = 2,
                ShieldControl = 3, TargetTaunt = 3,
                BowDefense = 1,
            }),
            [28] = table.freeze({
                CommonItemCreation = 1, SwordBluntMastery = 2,
                HeavyArmorMastery = 3, MagicResistance = 3,
                LifeDrain = 3, ShieldControl = 3,
                TargetTaunt = 3, SelfRecovery = 3,
                ShieldMastery = 1,
            }),
        }),
    }),
})

--[[
Returns independently counted historical skill-rank brackets at the cap.

Args:
    branch_id (string): Human Warrior or Knight reference class path.

Returns:
    any?: Reference-only level-20/24/28 rank records, or nil.
]]
function Sources.get(branch_id: string): any?
    return CLASSES[branch_id]
end

return table.freeze(Sources)
