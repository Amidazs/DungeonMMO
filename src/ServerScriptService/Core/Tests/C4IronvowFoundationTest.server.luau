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
        SWORD, BLADE, CALL, LIGHT, HEAVY,
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
        SWORD, BLADE, CALL, LIGHT, HEAVY,
    }) do
        local permitted = Rules.can_train(
            unearned, assert(Progression.get(skill_id)), 1
        )
        check(not permitted,
            "Unawarded original Warrior cannot buy its registered skill")
    end
    check(Passives.damage_bonus(unearned, BLADE) == 0,
        "Forged equipped sword must not receive Warrior passive damage")
    check(Passives.fighter_armor_reduction(unearned) == 0,
        "Forged Warrior cannot use a bought heavy-armour rank")
    print(("[Ironvow Foundation] PASS: %d assertions")
        :format(CHECKS))
end

main()
