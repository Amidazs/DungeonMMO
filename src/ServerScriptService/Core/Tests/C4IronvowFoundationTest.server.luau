--!strict
-- Earned original Human Warrior skills, equipped gear and forged-class
-- safeguards must remain distinct from other first-transfer careers.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Progression = require(Shared.SkillProgressionDefinitions)
local Classes = require(Shared.ClassProgressionDefinitions)
local Rules = require(Shared.SkillUnlockRules)
local Identity = require(Shared.CharacterIdentityRules)
local FirstTransfers = require(Shared.OriginalFirstTransferDefinitions)
local Passives = require(Shared.PassiveSkillEffects)
local Schema = require(Shared.ProfileSchema)
local Combat = require(RS.Combat.Shared.SkillDefinitions)

local CHECKS = 0
local SWORD = "IronvowDrivingStrike"
local BLADE = "IronvowBladeTraining"
local CALL = "IronvowBattleCall"
local LIGHT = "IronvowLightArmorTraining"
local HEAVY = "IronvowHeavyArmorTraining"

--[[
Fails the isolated original Warrior test on the first false assertion.

Args:
    condition (boolean): Expected authored skill or denied class rule.
    message (string): Meaningful diagnostic for a failing test.

Returns:
    nil: Increments the assertion count after verification.
]]
local function check(condition: boolean, message: string)
    CHECKS += 1
    assert(condition, "[Ironvow Foundation] " .. message)
end

--[[
Creates one explicitly unearned, test-only forged Warrior profile.

Args:
    None.

Returns:
    any: Raw Fighter profile carrying unsupported class and skill claims.
]]
local function forged_character(): any
    local profile = Schema.create_default(-81023)
    local character = profile.Characters.Slot1
    character.Identity = {
        Version = 1, RaceId = "Human",
        BaseClassId = "Fighter", ClassId = "Ironvow",
        CreationStage = "Complete",
    }
    character.Level = 28
    character.Equipment.Weapon = "marauder_sword"
    character.Equipment.Body = "marauder_armor"
    for _, skill_id in ipairs({
        SWORD, BLADE, "IronvowPolearmTraining",
        "IronvowCrescentSweep", "IronvowStonebreaker",
        "IronvowEquipmentExpertise", "IronvowCommonItemCreation",
        "IronvowCriticalStance", "IronvowAccuracyStance",
        "IronvowFieldRecovery", "IronvowEnduranceSurge",
        CALL, LIGHT, HEAVY,
    }) do
        character.Progression.Skills[skill_id] = {
            Known = true, PurchasedRank = 3, Proficiency = 350,
        }
    end
    return character
end

--[[
Checks exactly which ranks can be offered once a real quest exists.

Args:
    skill_id (string): One of the three server-authored Warrior skills.
    expected ({number}): Explicit launch level for each available rank.

Returns:
    nil: Validates complete first Warrior slice without granting the class.
]]
local function check_ranks(skill_id: string, expected: {number})
    local definition = assert(Progression.get(skill_id))
    check(definition.MaxRank == #expected,
        "Authored maximum skill rank must match intended test brackets")
    for rank, level in ipairs(expected) do
        check(definition.RankLevels[rank] == level,
            "Warrior skill's separate rank requires its exact level")
    end
    check(definition.RankLevels[#expected + 1] == nil,
        "No extra above-cap Warrior rank may enter the launch slice")
    check(Classes.can_teach("Ironvow", skill_id)
        and not Classes.can_teach("Fighter", skill_id)
        and not Classes.can_teach("Ashenblade", skill_id),
        "Original Warrior skill must remain in its own class catalogue")
end

--[[
Verifies authored rank effects and genuinely unearnable premature class.

Args:
    None.

Returns:
    nil: Reports only the tests actually performed in unpublished Studio.
]]
local function main()
    check_ranks(SWORD, {20, 20, 20, 24, 24, 24, 28, 28, 28})
    check_ranks(BLADE, {20, 24, 28, 28})
    check_ranks("IronvowPolearmTraining", {20, 24, 28, 28})
    check_ranks("IronvowEquipmentExpertise", {20})
    check_ranks("IronvowCommonItemCreation", {20, 28})
    check_ranks("IronvowCriticalStance", {20, 24, 28})
    check_ranks("IronvowAccuracyStance", {24})
    check_ranks("IronvowFieldRecovery", {24})
    check_ranks("IronvowEnduranceSurge", {28})
    local surge = assert(Combat.get_for_rank(
        "IronvowEnduranceSurge", 1
    ))
    check(surge.KIND == "HealthSurge"
        and surge.MANA_COST == 13
        and surge.STAMINA_COST == 0
        and surge.MAX_HP_BONUS == 0.10
        and surge.RESTORE_FRACTION == 0.10
        and surge.DURATION_SECONDS == 600
        and surge.COOLDOWN_SECONDS > 0,
        "Paid Warrior surge must change true maximum HP and heal once")
    local health = assert(Progression.get("IronvowFieldRecovery"))
    check(health.Kind == "Passive"
        and health.HPRegenPerSecond == 1.1,
        "Warrior source HP recovery is actual bounded passive regeneration")
    local accuracy = assert(Combat.get_for_rank(
        "IronvowAccuracyStance", 1
    ))
    check(accuracy.KIND == "IronvowAccuracyToggle"
        and accuracy.MANA_COST == 1
        and accuracy.UPKEEP_MANA_PER_SECOND > 0
        and accuracy.STAMINA_COST == 0
        and accuracy.SOURCE_ACCURACY == 3,
        "Warrior's real accuracy source stance spends MP and affects hit")
    local critical_power = {35, 48, 64}
    local critical_mana = {4, 5, 5}
    for rank, power in ipairs(critical_power) do
        local stance = assert(Combat.get_for_rank(
            "IronvowCriticalStance", rank
        ))
        check(stance.KIND == "IronvowCriticalToggle"
            and stance.SOURCE_CRITICAL_POWER == power
            and stance.MANA_COST == critical_mana[rank]
            and stance.UPKEEP_MANA_PER_SECOND > 0
            and stance.STAMINA_COST == 0,
            "C4 Warrior critical stance spends MP with correct rank")
    end
    check_ranks(
        "IronvowCrescentSweep",
        {20, 20, 20, 24, 24, 24, 28, 28, 28}
    )
    check_ranks(
        "IronvowStonebreaker",
        {20, 20, 20, 24, 24, 24, 28, 28, 28}
    )
    local stun = assert(Progression.get("IronvowStonebreaker"))
    check(stun.WeaponTags[1] == "OneHandedBlunt"
        and stun.Prerequisites[1].SkillId == "IronvowBladeTraining",
        "Source blunt control requires earned mastery and actual blunt gear")
    local powers = {30, 33, 35, 41, 44, 48, 55, 59, 64}
    local costs = {22, 22, 22, 23, 24, 25, 27, 29, 30}
    for rank, expected in ipairs(powers) do
        local ability = assert(Combat.get_for_rank(
            "IronvowStonebreaker", rank
        ))
        check(ability.SOURCE_POWER == expected
            and ability.MANA_COST == costs[rank]
            and ability.STAMINA_COST == 0
            and ability.MAX_TARGETS == 1
            and ability.NO_STAGGER_REFRESH == true
            and ability.STAGGER_SECONDS > 0,
            "Blunt control preserves original C4 single-target power/MP")
    end
    local sweep = assert(Progression.get("IronvowCrescentSweep"))
    check(sweep.WeaponTags[1] == "Polearm"
        and sweep.Prerequisites[1].SkillId == "IronvowPolearmTraining",
        "Earned Warrior area skill requires the polearm mastery and gear")
    local source_power = {90, 97, 105, 123, 132, 143, 165, 177, 191}
    local source_mp = {22, 22, 22, 23, 24, 25, 27, 29, 30}
    for rank, expected in ipairs(source_power) do
        local ability = assert(Combat.get_for_rank(
            "IronvowCrescentSweep", rank
        ))
        check(ability.KIND == "Melee"
            and ability.SOURCE_POWER == expected
            and ability.MANA_COST == source_mp[rank]
            and ability.STAMINA_COST == 0
            and ability.MAX_TARGETS == 20
            and ability.STAGGER_SECONDS == 0,
            "Nine genuine polearm area ranks preserve source power and MP")
    end
    local polearm = assert(Progression.get("IronvowPolearmTraining"))
    local source_power = {4.5, 7.3, 8.9, 10.7}
    for rank, expected in ipairs(source_power) do
        check(polearm.SourcePhysicalAttackByRank[rank] == expected
            and polearm.SourceExtraHitTargets == 5,
            "Warrior polearm must preserve real C4 P.Atk and target rows")
    end
    local weapon_mastery = assert(Progression.get(BLADE))
    check(weapon_mastery.DamageBonusPerRank == 0.014
        and #weapon_mastery.WeaponTags == 0,
        "Bought Warrior sword/blunt family does not require sword at trainer")

    check_ranks(LIGHT, {20, 20, 24, 24, 28, 28, 28})
    check_ranks(HEAVY, {20, 20, 24, 24, 28, 28, 28})
    check_ranks(CALL, {20, 24, 28})
    local low = assert(Combat.get_for_rank(SWORD, 1))
    local high = assert(Combat.get_for_rank(SWORD, 9))
    check(low.KIND == "Melee"
        and high.BASE_DAMAGE > low.BASE_DAMAGE,
        "Sword executor must actually scale its purchased impact")
    local first = assert(Combat.get_for_rank(CALL, 1))
    local last = assert(Combat.get_for_rank(CALL, 3))
    check(first.KIND == "Buff"
        and last.BUFF_MAGNITUDE > first.BUFF_MAGNITUDE,
        "Battle call must have a real rank-scaled server self-buff")

    local unearned = forged_character()
    check(FirstTransfers.for_branch("HumanWarrior") ~= nil,
        "Warrior career must require a separately earned original quest")
    local eligible = FirstTransfers.can_transfer(
        unearned, "HumanWarrior"
    )
    check(not eligible,
        "Forged saved career without a true completed quest is refused")
    check(FirstTransfers.awarded(unearned) == nil
        and Identity.get_class_id(unearned) == nil,
        "Forging a raw Ironvow ClassId cannot produce an earned identity")
    check(not Identity.is_complete(unearned),
        "Unawarded forged advanced character fails identity validation")
    for _, skill_id in ipairs({
        SWORD, BLADE, "IronvowPolearmTraining",
        "IronvowCrescentSweep", "IronvowStonebreaker",
        "IronvowEquipmentExpertise", "IronvowCommonItemCreation",
        "IronvowCriticalStance", "IronvowAccuracyStance",
        "IronvowFieldRecovery", "IronvowEnduranceSurge",
        CALL, LIGHT, HEAVY,
    }) do
        local permitted = Rules.can_train(
            unearned, assert(Progression.get(skill_id)), 1
        )
        check(not permitted,
            "Unawarded original Warrior cannot buy its registered skill")
    end
    check(Passives.damage_bonus(unearned, BLADE) == 0,
        "Forged equipped sword must not receive Warrior passive damage")
    unearned.Equipment.Weapon = "stonewatch_training_mace"
    check(Passives.damage_bonus(unearned, BLADE) == 0,
        "Forged Warrior cannot get the same mastery with blunt equipment")
    unearned.Equipment.Weapon = "ironroot_training_halberd"
    check(Passives.damage_bonus(
        unearned, "IronvowPolearmTraining"
    ) == 0 and Passives.polearm_extra_targets(unearned) == 0,
        "Unearned polearm rank gives neither damage nor extra targets")
    check(Passives.ironvow_health_recovery(unearned) == 0,
        "Forged Fighter cannot gain free Warrior regenerative healing")
    check(not Passives.has_ironvow_equipment_expertise(unearned),
        "Forged Warrior cannot equip D-grade from an unearned rank")
    check(Passives.fighter_armor_reduction(unearned) == 0,
        "Forged Warrior cannot use a bought heavy-armour rank")
    print(("[Ironvow Foundation] PASS: %d assertions")
        :format(CHECKS))
end

main()
