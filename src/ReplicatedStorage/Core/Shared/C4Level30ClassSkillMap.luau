--!strict
-- Explicit source-category to independently authored DungeonMMO ability map.
-- This is a rank-inventory audit, NOT proof of complete playable effects.
local SkillMap = {}

local COMMON = table.freeze({
    EquipmentExpertise = "ScoutEquipmentExpertise",
    CommonItemCreation = "ScoutCommonItemCreation",
    BowMastery = "WayfinderBowMastery",
    DaggerMastery = "WayfinderDaggerMastery",
    LightArmorMastery = "ScoutLightArmorMastery",
    DaggerAttack = "WayfinderCut",
    BowAttack = "WayfinderArrow",
    CriticalPowerToggle = "ScoutCriticalPowerToggle",
    BowRange = "RangerLongRange",
    LungCapacity = "ScoutLungCapacity",
    FallResistance = "ScoutFallResistance",
    Lockpicking = "ScoutLockpicking",
    EvasionPassive = "ScoutEvasion",
    Bleed = "WayfinderWound",
    AccuracyToggle = "ScoutAccuracyToggle",
    MovementPassive = "ScoutFleetFoot",
    RunningEvasion = "ScoutRunningEvasion",
    ActiveEvasion = "ScoutEvasiveFocus",
})

local HUMAN = table.freeze({
    Sprint = "HumanScoutSprint",
    CriticalDamagePassive = "HumanScoutCriticalPower",
    SittingRecovery = "HumanScoutRestingRecovery",
    CriticalRatePassive = "HumanScoutPrecision",
})

local ELF = table.freeze({
    HPRegeneration = "ElvenRenewal",
    ThreatCharm = "GreenwardCalmingArrow",
    DefenseBuff = "ElvenScoutGuard",
    CureWounds = "ElvenScoutCureWounds",
    CurePoison = "ElvenScoutPoisonRecovery",
    AttackBuff = "ElvenScoutBattleFocus",
})

-- Warrior mapping is deliberately partial. Sword/blunt, polearm,
-- critical, health and equipment source families require their own
-- genuine implemented effects before any rank coverage can be claimed.
local WARRIOR = table.freeze({
    SwordPowerAttack = "IronvowDrivingStrike",
    SwordBluntMastery = "IronvowBladeTraining",
    PolearmMastery = "IronvowPolearmTraining",
    PolearmAreaAttack = "IronvowCrescentSweep",
    BluntControl = "IronvowStonebreaker",
    EquipmentExpertise = "IronvowEquipmentExpertise",
    CommonItemCreation = "IronvowCommonItemCreation",
    CriticalStance = "IronvowCriticalStance",
    LightArmorMastery = "IronvowLightArmorTraining",
    HeavyArmorMastery = "IronvowHeavyArmorTraining",
    BattleCry = "IronvowBattleCall",
    HealthTraining = "IronvowFortitude",
    RestingRecovery = "IronvowRestRecovery",
})

-- Knight mapping is partial: the remaining distinct protection,
-- resistance, drain, shield and common-utility effects still need work.
local KNIGHT = table.freeze({
    ShieldControl = "OathguardShieldImpact",
    HeavyArmorMastery = "OathguardHeavyArmorTraining",
    MagicResistance = "OathguardRunicResistance",
    ShieldMastery = "OathguardShieldMastery",
    DefensiveStance = "OathguardSteadfastStance",
    LastStand = "OathguardLastBastion",
    BowDefense = "OathguardArrowWard",
    SwordBluntMastery = "OathguardSteelAndStoneTraining",
    EquipmentExpertise = "OathguardEquipmentExpertise",
    CommonItemCreation = "OathguardCommonItemCreation",
    LifeDrain = "OathguardUmbralSiphon",
    SelfRecovery = "OathguardMendingOath",
    TargetTaunt = "OathguardChallenge",
})

--[[
Resolves the explicitly reviewed source family without legacy class aliases.

Args:
    branch_id (string): Original Human Rogue or Elven Scout branch.
    source_category (string): Historical source rank-family identifier.

Returns:
    string?: Actual DungeonMMO class/utility skill or nil when unmapped.
]]
function SkillMap.get(
    branch_id: string, source_category: string
): string?
    if branch_id == "HumanWarrior" then
        return WARRIOR[source_category]
    end
    if branch_id == "HumanKnight" then
        return KNIGHT[source_category]
    end
    if branch_id ~= "HumanRogue" and branch_id ~= "ElvenScout"
    then
        return nil
    end
    local shared = COMMON[source_category]
    if shared then return shared end
    if branch_id == "HumanRogue" then
        return HUMAN[source_category]
    end
    return ELF[source_category]
end

return table.freeze(SkillMap)
