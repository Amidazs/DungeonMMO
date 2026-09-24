--!strict
-- The independent Human Knight must fail closed before its world quest.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Skills = require(Shared.SkillProgressionDefinitions)
local Classes = require(Shared.ClassProgressionDefinitions)
local Catalogues = require(Shared.TrainerCatalogues)
local Rules = require(Shared.SkillUnlockRules)
local Identity = require(Shared.CharacterIdentityRules)
local Careers = require(Shared.OriginalFirstTransferDefinitions)
local Passives = require(Shared.PassiveSkillEffects)
local Schema = require(Shared.ProfileSchema)
local Combat = require(RS.Combat.Shared.SkillDefinitions)

local CHECKS = 0
local IMPACT = "OathguardShieldImpact"
local CHALLENGE = "OathguardChallenge"
local ARMOR = "OathguardHeavyArmorTraining"

--[[
Counts one current original Knight skill or authority assertion.

Args:
    yes (boolean): Tested class, combat or equipment property.
    why (string): Diagnostic if the newly introduced rule is broken.

Returns:
    nil: Throws before claiming an untested advancement.
]]
local function check(yes: boolean, why: string)
    CHECKS += 1
    assert(yes, "[Oathguard Foundation] " .. why)
end

--[[
Audits every individually purchasable first-transfer rank bracket.

Args:
    skill_id (string): Registered Oathguard-specific skill line.
    ranks ({number}): Exact authored level for each separate rank.

Returns:
    nil: Confirms the rank cannot silently exceed release level thirty.
]]
local function check_ranks(skill_id: string, ranks: {number})
    local definition = assert(Skills.get(skill_id))
    check(definition.MaxRank == #ranks,
        "Original Knight skill has an explicit separate rank schedule")
    for rank, level in ipairs(ranks) do
        check(definition.RankLevels[rank] == level
            and level <= 30,
            "Original Knight rank requires the correct launch bracket")
    end
    check(Classes.can_teach("Oathguard", skill_id)
        and not Classes.can_teach("Fighter", skill_id)
        and not Classes.can_teach("Ironvow", skill_id)
        and Catalogues.get("OathguardTrainer") ~= nil,
        "Only planned Oathguard career and trainer may teach this line")
end

--[[
Builds a forged profile with bought ranks but no independently earned quest.

Args:
    None.

Returns:
    any: Unawarded apparent Knight who must fail all authority checks.
]]
local function forged(): any
    local profile = Schema.create_default(-448712)
    local owner = profile.Characters.Slot1
    owner.Identity = {
        Version = 1, RaceId = "Human",
        BaseClassId = "Fighter", ClassId = "Oathguard",
        CreationStage = "Complete",
    }
    owner.Level = 28
    owner.Equipment.Body = "marauder_armor"
    owner.Equipment.OffHand = "marauder_shield"
    for _, skill_id in ipairs({
        IMPACT, CHALLENGE, ARMOR,
        "OathguardRunicResistance", "OathguardMendingOath",
        "OathguardShieldMastery", "OathguardSteadfastStance",
        "OathguardUmbralSiphon",
    }) do
        owner.Progression.Skills[skill_id] = {
            Known = true, PurchasedRank = 9, Proficiency = 320,
        }
    end
    return owner
end

--[[
Verifies real melee hit/threat definitions and zero unearned class effects.

Args:
    None.

Returns:
    nil: Reports only authored and genuinely tested backend foundations.
]]
local function main()
    check_ranks(
        IMPACT, {20, 20, 20, 24, 24, 24, 28, 28, 28}
    )
    check_ranks(CHALLENGE, {24, 24, 24, 28, 28, 28})
    check_ranks(
        ARMOR, {20, 20, 20, 24, 24, 24, 28, 28, 28}
    )
    check_ranks(
        "OathguardRunicResistance",
        {20, 20, 24, 24, 24, 28, 28, 28}
    )
    check_ranks("OathguardMendingOath", {28, 28, 28})
    check_ranks("OathguardShieldMastery", {20, 28})
    check_ranks("OathguardSteadfastStance", {20})
    check_ranks(
        "OathguardUmbralSiphon", {20, 20, 24, 24, 28, 28, 28}
    )
    local reference_power = {20, 22, 24, 26, 28, 29, 31}
    local reference_mana = {12, 13, 14, 15, 15, 17, 17}
    for rank = 1, 7 do
        local drain = assert(Combat.get_for_rank(
            "OathguardUmbralSiphon", rank
        ))
        check(drain.KIND == "MagicProjectile"
            and drain.BASE_DAMAGE == reference_power[rank]
            and drain.MANA_COST == reference_mana[rank]
            and drain.LIFE_DRAIN_FRACTION == 0.20
            and drain.STAMINA_COST == 0,
            "Knight drain retains the C4 rank-specific power and mana")
    end
    local stance = assert(Combat.get_for_rank(
        "OathguardSteadfastStance", 1
    ))
    check(stance.KIND == "Buff" and stance.SELF_ONLY
        and stance.BUFF_KIND == "PhysicalGuard"
        and stance.BUFF_MAGNITUDE == 0.10
        and stance.BUFF_SECONDS == 10
        and stance.STAMINA_COST == 14
        and stance.COOLDOWN_SECONDS == 24,
        "Earned Knight stance gives timed paid self-only physical guard")
    local early_heal = assert(Combat.get_for_rank(
        "OathguardMendingOath", 1
    ))
    local late_heal = assert(Combat.get_for_rank(
        "OathguardMendingOath", 3
    ))
    check(early_heal.KIND == "MageHeal"
        and early_heal.SELF_ONLY
        and late_heal.TOTAL_HEAL > early_heal.TOTAL_HEAL,
        "Paid Knight recovery genuinely scales server-owned self-heal")
    local low = assert(Combat.get_for_rank(IMPACT, 1))
    local high = assert(Combat.get_for_rank(IMPACT, 9))
    check(low.KIND == "Melee"
        and high.BASE_DAMAGE > low.BASE_DAMAGE
        and Skills.get(IMPACT).RequiresShield == true,
        "Genuine shield strike scales actual melee impact by paid rank")
    local first = assert(Combat.get_for_rank(CHALLENGE, 1))
    local last = assert(Combat.get_for_rank(CHALLENGE, 6))
    check(first.KIND == "Melee"
        and first.BASE_DAMAGE == 0
        and last.BASE_DAMAGE == 0
        and last.TAUNT_BONUS_THREAT > first.TAUNT_BONUS_THREAT,
        "Real zero-damage taunt creates greater threat at later ranks")
    local owner = forged()
    check(Careers.for_branch("HumanKnight") ~= nil,
        "Independent Knight career requires its own completed personal quest")
    check(not Identity.is_complete(owner)
        and Careers.awarded(owner) == nil,
        "Claiming a raw Knight class ID cannot create mentor receipt")
    for _, skill_id in ipairs({
        IMPACT, CHALLENGE, ARMOR,
        "OathguardRunicResistance", "OathguardMendingOath",
        "OathguardShieldMastery", "OathguardSteadfastStance",
        "OathguardUmbralSiphon",
    }) do
        check(not Rules.can_train(
            owner, assert(Skills.get(skill_id)), 1
        ), "An unawarded Fighter cannot purchase original Knight abilities")
    end
    check(Passives.fighter_armor_reduction(owner) == 0,
        "Forged rank-nine heavy armor must not reduce any NPC damage")
    check(Passives.oathguard_shield_reduction(owner) == 0,
        "Unawarded Knight receives no protection from a forged shield rank")
    print(("[Oathguard Foundation] PASS: %d assertions")
        :format(CHECKS))
end

main()
