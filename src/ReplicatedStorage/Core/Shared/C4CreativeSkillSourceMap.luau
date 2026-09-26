--!strict
-- Explicit C4 source-to-creative CANDIDATES across tracked level-30 paths.
-- Entries are not evidence of effect/formula equivalence.
local C4CreativeSkillSourceMap = {}

local MAPS = table.freeze({
    HumanFighter = table.freeze({
        [3] = table.freeze({SkillId = "IronCleave"}),
        [16] = table.freeze({SkillId = "FighterDaggerStrike"}),
        [56] = table.freeze({SkillId = "FighterBowShot"}),
        [141] = table.freeze({SkillId = "FighterPhysicalTraining"}),
        [142] = table.freeze({SkillId = "FighterArmorTraining"}),
        [226] = table.freeze({SkillId = "FighterRestingRecovery"}),
        [1320] = table.freeze({SkillId = "C4CommonItemCreation"}),
    }),
    HumanMystic = table.freeze({
        [146] = table.freeze({SkillId = "MysticSpellResistance"}),
        [214] = table.freeze({SkillId = "MysticRobeManaRecovery", Review = "Source mana recovery may have different triggers from current robe-only bonus"}),
        [244] = table.freeze({SkillId = "MysticArmorTraining"}),
        [249] = table.freeze({SkillId = "MysticWeaponTraining"}),
        [1011] = table.freeze({SkillId = "MysticHealingPrayer"}),
        [1012] = table.freeze({SkillId = "MysticCurePoison"}),
        [1015] = table.freeze({SkillId = "MysticBattleHeal"}),
        [1027] = table.freeze({SkillId = "MysticPartyHeal"}),
        [1040] = table.freeze({SkillId = "MysticStoneSkin"}),
        [1068] = table.freeze({SkillId = "MysticBattleChant"}),
        [1147] = table.freeze({SkillId = "MysticLifeDrain"}),
        [1168] = table.freeze({SkillId = "MysticPoisonCurse"}),
        [1177] = table.freeze({SkillId = "MysticWindBolt", Offset = 1, StarterSkillId = "WindStrike"}),
        [1164] = table.freeze({SkillId = "MysticFeebleCurse"}),
        [1184] = table.freeze({SkillId = "MysticFrostBolt"}),
        [1216] = table.freeze({SkillId = "MageHeal"}),
        [1320] = table.freeze({SkillId = "C4CommonItemCreation"}),
    }),
    ElvenFighter = table.freeze({
        [3] = table.freeze({SkillId = "IronCleave"}),
        [16] = table.freeze({SkillId = "FighterDaggerStrike"}),
        [56] = table.freeze({SkillId = "FighterBowShot"}),
        [58] = table.freeze({SkillId = "ElvenFighterRenewal"}),
        [77] = table.freeze({SkillId = "ElvenFighterBattleCry"}),
        [91] = table.freeze({SkillId = "ElvenFighterGuard"}),
        [141] = table.freeze({SkillId = "FighterPhysicalTraining"}),
        [142] = table.freeze({SkillId = "FighterArmorTraining"}),
        [1320] = table.freeze({SkillId = "C4CommonItemCreation"}),
    }),
    ElvenMystic = table.freeze({
        [146] = table.freeze({SkillId = "MysticSpellResistance"}),
        [214] = table.freeze({SkillId = "MysticRobeManaRecovery", Review = "Source mana recovery may have different triggers from current robe-only bonus"}),
        [244] = table.freeze({SkillId = "MysticArmorTraining"}),
        [249] = table.freeze({SkillId = "MysticWeaponTraining"}),
        [1011] = table.freeze({SkillId = "MysticHealingPrayer"}),
        [1012] = table.freeze({SkillId = "MysticCurePoison"}),
        [1015] = table.freeze({SkillId = "MysticBattleHeal"}),
        [1027] = table.freeze({SkillId = "MysticPartyHeal"}),
        [1040] = table.freeze({SkillId = "MysticStoneSkin"}),
        [1068] = table.freeze({SkillId = "MysticBattleChant"}),
        [1177] = table.freeze({SkillId = "MysticWindBolt", Offset = 1, StarterSkillId = "WindStrike"}),
        [1164] = table.freeze({SkillId = "MysticFeebleCurse"}),
        [1184] = table.freeze({SkillId = "MysticFrostBolt"}),
        [1206] = table.freeze({SkillId = "ElvenMysticLanguor"}),
        [1216] = table.freeze({SkillId = "MageHeal"}),
        [1320] = table.freeze({SkillId = "C4CommonItemCreation"}),
    }),
    HumanWizard = table.freeze({
        [146] = table.freeze({
            SkillId = "EmberweaverArcaneResistance",
            Offset = 4,
        }),
        [164] = table.freeze({SkillId = "EmberweaverQuickWeave"}),
        [213] = table.freeze({SkillId = "EmberweaverManaReservoir"}),
        [228] = table.freeze({SkillId = "EmberweaverFastCasting"}),
        [229] = table.freeze({SkillId = "EmberweaverManaRecovery"}),
        [234] = table.freeze({SkillId = "EmberweaverRobeTraining"}),
        [239] = table.freeze({
            SkillId = "EmberweaverEquipmentExpertise",
        }),
        [249] = table.freeze({
            SkillId = "EmberweaverFocusTraining",
            Offset = 2,
        }),
        [285] = table.freeze({SkillId = "EmberweaverManaChanneling"}),
        [1069] = table.freeze({SkillId = "EmberweaverSlumberHex"}),
        [1078] = table.freeze({
            SkillId = "EmberweaverConcentration",
        }),
        [1083] = table.freeze({SkillId = "EmberweaverScorchMark"}),
        [1111] = table.freeze({SkillId = "EmberweaverManaCompanion"}),
        [1126] = table.freeze({SkillId = "EmberweaverServitorRecharge"}),
        [1127] = table.freeze({SkillId = "EmberweaverServitorHeal"}),
        [1147] = table.freeze({
            SkillId = "EmberweaverLifeSiphon",
            Offset = 2,
        }),
        [1151] = table.freeze({SkillId = "EmberweaverCorpseSiphon"}),
        [1157] = table.freeze({SkillId = "EmberweaverBloodToMana"}),
        [1164] = table.freeze({
            SkillId = "EmberweaverWitheringHex",
            Offset = 1,
        }),
        [1167] = table.freeze({SkillId = "EmberweaverVenomCloud"}),
        [1168] = table.freeze({
            SkillId = "EmberweaverVenomHex",
            Offset = 1,
        }),
        [1172] = table.freeze({SkillId = "EmberweaverFlameBurst"}),
        [1181] = table.freeze({SkillId = "EmberweaverEmberField"}),
        [1184] = table.freeze({
            SkillId = "EmberweaverFrostLance",
            Offset = 4,
        }),
        [1220] = table.freeze({SkillId = "EmberweaverEmberBolt"}),
        [1225] = table.freeze({SkillId = "EmberweaverCombatCompanion"}),
        [1274] = table.freeze({SkillId = "EmberweaverFocusedBolt"}),
        [1320] = table.freeze({
            SkillId = "EmberweaverCommonItemCreation",
            Offset = 1,
        }),
    }),
    HumanCleric = table.freeze({
        [146] = table.freeze({
            SkillId = "DawnkeeperArcaneResistance",
            Offset = 4,
        }),
        [164] = table.freeze({SkillId = "DawnkeeperQuickPrayer"}),
        [213] = table.freeze({SkillId = "DawnkeeperManaReservoir"}),
        [228] = table.freeze({SkillId = "DawnkeeperFastCasting"}),
        [229] = table.freeze({SkillId = "DawnkeeperManaRecovery"}),
        [235] = table.freeze({SkillId = "DawnkeeperRobeTraining"}),
        [236] = table.freeze({
            SkillId = "DawnkeeperLightArmorTraining",
        }),
        [249] = table.freeze({
            SkillId = "DawnkeeperWeaponTraining",
            Offset = 2,
        }),
        [1011] = table.freeze({
            SkillId = "DawnkeeperHealingLight",
            Offset = 6,
        }),
        [1015] = table.freeze({
            SkillId = "DawnkeeperBattleMend",
            Offset = 3,
        }),
        [1016] = table.freeze({SkillId = "DawnkeeperRevive"}),
        [1027] = table.freeze({
            SkillId = "DawnkeeperGroupMend",
            Offset = 3,
        }),
        [1031] = table.freeze({SkillId = "DawnkeeperExorcism"}),
        [1035] = table.freeze({SkillId = "DawnkeeperMindWard"}),
        [1040] = table.freeze({
            SkillId = "DawnkeeperStoneWard",
            Offset = 1,
        }),
        [1043] = table.freeze({SkillId = "DawnkeeperSacredEdge"}),
        [1068] = table.freeze({
            SkillId = "DawnkeeperMight",
            Offset = 1,
        }),
        [1069] = table.freeze({SkillId = "DawnkeeperSlumber"}),
        [1073] = table.freeze({
            SkillId = "DawnkeeperBreathBlessing",
        }),
        [1077] = table.freeze({SkillId = "DawnkeeperFocus"}),
        [1078] = table.freeze({
            SkillId = "DawnkeeperConcentration",
        }),
        [1085] = table.freeze({SkillId = "DawnkeeperInsight"}),
        [1191] = table.freeze({SkillId = "DawnkeeperFireWard"}),
        [1201] = table.freeze({SkillId = "DawnkeeperRootbind"}),
        [1204] = table.freeze({SkillId = "DawnkeeperWindstep"}),
    }),
    ElvenWizard = table.freeze({
        [146] = table.freeze({
            SkillId = "MoonweaverArcaneResistance",
            Offset = 4,
        }),
        [164] = table.freeze({SkillId = "MoonweaverQuickWeave"}),
        [213] = table.freeze({SkillId = "MoonweaverManaReservoir"}),
        [228] = table.freeze({SkillId = "MoonweaverFastCasting"}),
        [229] = table.freeze({SkillId = "MoonweaverManaRecovery"}),
        [234] = table.freeze({SkillId = "MoonweaverRobeTraining"}),
        [249] = table.freeze({
            SkillId = "MoonweaverFocusTraining",
            Offset = 2,
        }),
        [285] = table.freeze({SkillId = "MoonweaverManaChanneling"}),
        [1069] = table.freeze({SkillId = "MoonweaverSlumberHex"}),
        [1078] = table.freeze({SkillId = "MoonweaverConcentration"}),
        [1126] = table.freeze({SkillId = "MoonweaverServitorRecharge"}),
        [1127] = table.freeze({SkillId = "MoonweaverServitorHeal"}),
        [1164] = table.freeze({
            SkillId = "MoonweaverWitheringHex",
            Offset = 1,
        }),
        [1172] = table.freeze({SkillId = "MoonweaverFlameBurst"}),
        [1175] = table.freeze({SkillId = "MoonweaverTidalBolt"}),
        [1181] = table.freeze({SkillId = "MoonweaverEmberField"}),
        [1182] = table.freeze({SkillId = "MoonweaverTidalWard"}),
        [1184] = table.freeze({
            SkillId = "MoonweaverFrostLance",
            Offset = 4,
        }),
        [1226] = table.freeze({SkillId = "MoonweaverManaCompanion"}),
        [1227] = table.freeze({SkillId = "MoonweaverCombatCompanion"}),
        [1264] = table.freeze({SkillId = "MoonweaverSolarSpark"}),
        [1274] = table.freeze({SkillId = "MoonweaverFocusedBolt"}),
    }),
    HumanWarrior = table.freeze({
        [78] = table.freeze({SkillId = "IronvowBattleCall"}),
        [100] = table.freeze({SkillId = "IronvowStonebreaker"}),
        [121] = table.freeze({SkillId = "IronvowEnduranceSurge"}),
        [148] = table.freeze({SkillId = "IronvowFieldRecovery", Review = "Vital Force versus authored field recovery needs stat-semantic review"}),
        [211] = table.freeze({SkillId = "IronvowFortitude"}),
        [212] = table.freeze({SkillId = "IronvowRestRecovery"}),
        [216] = table.freeze({SkillId = "IronvowPolearmTraining"}),
        [227] = table.freeze({SkillId = "IronvowLightArmorTraining"}),
        [231] = table.freeze({SkillId = "IronvowHeavyArmorTraining"}),
        [239] = table.freeze({SkillId = "IronvowEquipmentExpertise"}),
        [245] = table.freeze({SkillId = "IronvowCrescentSweep"}),
        [255] = table.freeze({SkillId = "IronvowDrivingStrike"}),
        [256] = table.freeze({SkillId = "IronvowAccuracyStance"}),
        [257] = table.freeze({SkillId = "IronvowBladeTraining"}),
        [312] = table.freeze({SkillId = "IronvowCriticalStance"}),
        [1320] = table.freeze({SkillId = "IronvowCommonItemCreation", Offset = 1}),
    }),
    HumanKnight = table.freeze({
        [28] = table.freeze({SkillId = "OathguardChallenge"}),
        [45] = table.freeze({SkillId = "OathguardMendingOath"}),
        [70] = table.freeze({SkillId = "OathguardUmbralSiphon"}),
        [82] = table.freeze({SkillId = "OathguardSteadfastStance"}),
        [92] = table.freeze({SkillId = "OathguardShieldImpact"}),
        [110] = table.freeze({SkillId = "OathguardLastBastion"}),
        [112] = table.freeze({SkillId = "OathguardArrowWard"}),
        [147] = table.freeze({SkillId = "OathguardRunicResistance"}),
        [153] = table.freeze({SkillId = "OathguardShieldMastery"}),
        [217] = table.freeze({SkillId = "OathguardSteelAndStoneTraining"}),
        [232] = table.freeze({SkillId = "OathguardHeavyArmorTraining"}),
        [239] = table.freeze({SkillId = "OathguardEquipmentExpertise"}),
        [1320] = table.freeze({SkillId = "OathguardCommonItemCreation", Offset = 1}),
    }),
    HumanRogue = table.freeze({
        [4] = table.freeze({SkillId = "HumanScoutSprint"}),
        [16] = table.freeze({SkillId = "WayfinderCut", Offset = 9}),
        [27] = table.freeze({SkillId = "ScoutLockpicking"}),
        [56] = table.freeze({SkillId = "WayfinderArrow", Offset = 9}),
        [96] = table.freeze({SkillId = "WayfinderWound"}),
        [111] = table.freeze({SkillId = "ScoutEvasiveFocus"}),
        [113] = table.freeze({SkillId = "RangerLongRange"}),
        [137] = table.freeze({SkillId = "HumanScoutPrecision"}),
        [148] = table.freeze({SkillId = "AshenbladeVitalForce"}),
        [169] = table.freeze({SkillId = "ScoutFleetFoot"}),
        [173] = table.freeze({SkillId = "ScoutFallResistance"}),
        [193] = table.freeze({SkillId = "HumanScoutCriticalPower"}),
        [195] = table.freeze({SkillId = "ScoutLungCapacity"}),
        [198] = table.freeze({SkillId = "ScoutEvasion"}),
        [208] = table.freeze({SkillId = "WayfinderBowMastery"}),
        [209] = table.freeze({SkillId = "WayfinderDaggerMastery"}),
        [225] = table.freeze({SkillId = "ScoutRunningEvasion"}),
        [233] = table.freeze({SkillId = "ScoutLightArmorMastery"}),
        [239] = table.freeze({SkillId = "ScoutEquipmentExpertise"}),
        [256] = table.freeze({SkillId = "ScoutAccuracyToggle"}),
        [312] = table.freeze({SkillId = "ScoutCriticalPowerToggle"}),
        [1320] = table.freeze({SkillId = "ScoutCommonItemCreation", Offset = 1}),
    }),
    ElvenKnight = table.freeze({
        [15] = table.freeze({SkillId = "GreenwardWardenCharm"}),
        [21] = table.freeze({SkillId = "GreenwardWardenPoisonRecovery"}),
        [28] = table.freeze({SkillId = "GreenwardWardenAggression"}),
        [58] = table.freeze({SkillId = "GreenwardWardenElementalHeal", Offset = 3}),
        [61] = table.freeze({SkillId = "GreenwardWardenBleedRecovery"}),
        [77] = table.freeze({SkillId = "GreenwardWardenAttackAura", Offset = 1}),
        [91] = table.freeze({SkillId = "GreenwardWardenDefenseAura", Offset = 1}),
        [110] = table.freeze({SkillId = "GreenwardWardenLastStand"}),
        [112] = table.freeze({SkillId = "GreenwardWardenBowWard"}),
        [147] = table.freeze({SkillId = "GreenwardWardenMagicResistance"}),
        [153] = table.freeze({SkillId = "GreenwardWardenShieldMastery"}),
        [217] = table.freeze({SkillId = "GreenwardWardenSteelTraining"}),
        [232] = table.freeze({SkillId = "GreenwardWardenHeavyArmorTraining"}),
        [239] = table.freeze({SkillId = "GreenwardWardenEquipmentExpertise"}),
        [1320] = table.freeze({SkillId = "GreenwardWardenCommonItemCreation", Offset = 1}),
    }),
    ElvenScout = table.freeze({
        [15] = table.freeze({SkillId = "GreenwardCalmingArrow", Review = "Current calming attack is bow-only; source Charm has spell-like targeting"}),
        [16] = table.freeze({SkillId = "WayfinderCut", Offset = 9}),
        [21] = table.freeze({SkillId = "ElvenScoutPoisonRecovery"}),
        [27] = table.freeze({SkillId = "ScoutLockpicking"}),
        [56] = table.freeze({SkillId = "WayfinderArrow", Offset = 9}),
        [58] = table.freeze({
            SkillId = "GreenwardScoutElementalHeal",
            Offset = 3,
        }),
        [61] = table.freeze({SkillId = "ElvenScoutCureWounds"}),
        [77] = table.freeze({SkillId = "ElvenScoutBattleFocus", Offset = 1}),
        [91] = table.freeze({SkillId = "ElvenScoutGuard", Offset = 1}),
        [96] = table.freeze({SkillId = "WayfinderWound"}),
        [111] = table.freeze({SkillId = "ScoutEvasiveFocus"}),
        [113] = table.freeze({SkillId = "RangerLongRange"}),
        [169] = table.freeze({SkillId = "ScoutFleetFoot"}),
        [173] = table.freeze({SkillId = "ScoutFallResistance"}),
        [195] = table.freeze({SkillId = "ScoutLungCapacity"}),
        [198] = table.freeze({SkillId = "ScoutEvasion"}),
        [208] = table.freeze({SkillId = "WayfinderBowMastery"}),
        [209] = table.freeze({SkillId = "WayfinderDaggerMastery"}),
        [225] = table.freeze({SkillId = "ScoutRunningEvasion"}),
        [233] = table.freeze({SkillId = "ScoutLightArmorMastery"}),
        [239] = table.freeze({SkillId = "ScoutEquipmentExpertise"}),
        [256] = table.freeze({SkillId = "ScoutAccuracyToggle"}),
        [312] = table.freeze({SkillId = "ScoutCriticalPowerToggle"}),
        [1320] = table.freeze({SkillId = "ScoutCommonItemCreation", Offset = 1}),
    }),
})

local GAPS = table.freeze({
    HumanFighter = table.freeze({
        [194] = "Lucky is not represented by a verified equivalent",
        [1322] = "Common Craft is not the current recipe-reading passive",
    }),
    HumanMystic = table.freeze({
        [118] = "Magicians Movement has no verified creative analogue",
        [163] = "Spellcraft has no verified creative analogue",
        [194] = "Lucky has no verified creative analogue",

        [1322] = "Common Craft is not the current recipe-reading passive",
    }),
    ElvenFighter = table.freeze({
        [194] = "Lucky has no verified creative analogue",
        [1322] = "Common Craft is not the current recipe-reading passive",
    }),
    ElvenMystic = table.freeze({
        [118] = "Magicians Movement has no verified creative analogue",
        [163] = "Spellcraft has no verified creative analogue",
        [194] = "Lucky has no verified creative analogue",


        [1322] = "Common Craft is not the current recipe-reading passive",
    }),
    HumanWizard = table.freeze({

    }),
    HumanCleric = table.freeze({

    }),
    ElvenWizard = table.freeze({

    }),
    HumanWarrior = table.freeze({

    }),
    HumanKnight = table.freeze({

    }),
    HumanRogue = table.freeze({

    }),
    ElvenKnight = table.freeze({

    }),
    ElvenScout = table.freeze({

    }),
})

--[[
Resolves an original source learning rank to an existing creative ID.

Args:
    scope_id (string): One tracked original level-30 class path.
    source_skill_id (number): Original C4 XML and learning-tree ID.
    source_level (number): Original C4 rank, not the character level.

Returns:
    any?: Candidate/rank or explicit gap; nil for unexamined source IDs.
]]
function C4CreativeSkillSourceMap.resolve(
    scope_id: string, source_skill_id: number, source_level: number
): any?
    local scope = MAPS[scope_id]
    local gaps = GAPS[scope_id]
    if not scope or not gaps then return nil end
    local reason = gaps[source_skill_id]
    if reason then
        return {
            Status = "Missing", Reason = reason,
            SourceSkillId = source_skill_id, SourceLevel = source_level,
            ExactEffectCertified = false,
        }
    end
    local candidate = scope[source_skill_id]
    if not candidate then return nil end
    local skill_id = candidate.SkillId
    local rank = source_level - (candidate.Offset or 0)
    if candidate.StarterSkillId and source_level == 1 then
        skill_id = candidate.StarterSkillId
        rank = 1
    end
    return {
        Status = "Candidate",
        SourceSkillId = source_skill_id, SourceLevel = source_level,
        CreativeSkillId = skill_id, CreativeRank = rank,
        Review = candidate.Review,
        ExactEffectCertified = false,
    }
end

--[[
Returns explicit mapped and deliberately unresolved C4 source families.

Args:
    scope_id (string): Original Human/Elf starter or first-transfer path.

Returns:
    any?: Candidate and gap tables, or nil for an unknown class.
]]
function C4CreativeSkillSourceMap.get_scope(scope_id: string): any?
    if not MAPS[scope_id] then return nil end
    return {Candidates = MAPS[scope_id], Gaps = GAPS[scope_id]}
end

return table.freeze(C4CreativeSkillSourceMap)
