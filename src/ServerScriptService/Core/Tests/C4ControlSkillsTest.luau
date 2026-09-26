--!strict
-- New Ranger/Rogue control ranks must have real server-owned effects.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local shared = RS.Core.Shared
local Skills = require(shared.SkillProgressionDefinitions)
local Unlocks = require(shared.SkillUnlockRules)
local Trainers = require(shared.TrainerCatalogues)
local Classes = require(shared.ClassProgressionDefinitions)
local Schema = require(shared.ProfileSchema)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)

local assertions = 0

--[[
Checks one authoritative skill-content invariant.

Args:
    condition (boolean): Whether the expected condition is met.
    description (string): Failure diagnostic.

Returns:
    nil: Counts a successful assertion or fails the focused test.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Control Skills] " .. description)
end

--[[
Builds a fresh profile-backed character for one class.

Args:
    class_id (string): Supported starting combat class.

Returns:
    any: Mutable isolated character fixture, never a real player's save.
]]
local function character_for(class_id: string): any
    local character = Schema.create_default(77583)
        .Characters.Slot1
    character.Identity.RaceId = "Human"
    character.Identity.BaseClassId = class_id
    character.Identity.ClassId = class_id
    character.Identity.CreationStage = "Complete"
    character.Level = 1
    return character
end

--[[
Verifies distinct gameplay effect, level gates, class restriction and
rank-accurate training for one new control skill.

Args:
    class_id (string): Owning class.
    foreign_class (string): Class that cannot train this skill.
    trainer_id (string): Existing class trainer.
    skill_id (string): Authoritative new skill ID.
    equipment_id (string): Valid owned weapon used for the live skill.
    control_key (string): Server control-effect field that grows by rank.

Returns:
    nil: Validates all three real rank effects and runtime eligibility.
]]
local function check_skill(
    class_id: string,
    foreign_class: string,
    trainer_id: string,
    skill_id: string,
    equipment_id: string,
    control_key: string
)
    local definition = assert(Skills.get(skill_id),
        "Missing progression definition " .. skill_id)
    local character = character_for(class_id)
    check(not Unlocks.can_show(character, definition),
        skill_id .. " must be hidden at level one")
    check(not Trainers.can_offer(trainer_id, character, skill_id).ok,
        skill_id .. " must not appear in level-one trainer")
    check(Classes.can_teach(class_id, skill_id),
        skill_id .. " missing from authoritative teachable skills")
    character.Level = 5
    check(Unlocks.can_show(character, definition),
        skill_id .. " must appear at first level bracket")
    check(Trainers.can_offer(trainer_id, character, skill_id).ok,
        skill_id .. " first-rank trainer offering missing")
    local foreign = character_for(foreign_class)
    foreign.Level = 15
    check(not Unlocks.can_show(foreign, definition),
        skill_id .. " leaked to another base class")

    local previous_control = 0
    for rank = 1, 3 do
        local band = ({5, 10, 15})[rank]
        character.Level = band - 1
        check(not Unlocks.can_train(character, definition, rank),
            skill_id .. " rank bypasses its level gate")
        character.Level = band
        check(Unlocks.can_train(character, definition, rank),
            skill_id .. " rank is blocked at its proper level")
        local effect = assert(Combat.get_for_rank(skill_id, rank),
            "Missing actual combat definition " .. skill_id)
        check((tonumber(effect[control_key]) or 0) > previous_control,
            skill_id .. " rank does not improve its control effect")
        check(effect.BASE_DAMAGE > 0,
            skill_id .. " must retain a real damage component")
        previous_control = effect[control_key]
    end

    character.Progression.Skills[skill_id] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    character.Progression.Loadout[1] = skill_id
    character.Equipment.Weapon = equipment_id
    Runtime.set_character(77583, character)
    check(Runtime.is_skill_usable(77583, skill_id),
        skill_id .. " must be usable with its actual owned weapon")
    Runtime.clear_character(77583)
end

check_skill(
    "Ranger", "Rogue", "RangerTrainer", "BriarVolley",
    "apprentice_longbow", "HUMAN_SLOW_SECONDS"
)
check_skill(
    "Rogue", "Ranger", "RogueTrainer", "DisruptingCut",
    "marauder_sword", "STAGGER_SECONDS"
)

local briar = assert(Combat.get_for_rank("BriarVolley", 1))
check(briar.KIND == "RangerProjectile" and briar.MAX_TARGETS == 2,
    "Briar Volley must control two arrow targets")
check(briar.HUMAN_SLOW_FRACTION > 0 and briar.ELF_SLOW_FRACTION > 0,
    "Briar Volley needs both races' server slow magnitudes")
local cut = assert(Combat.get_for_rank("DisruptingCut", 1))
check(cut.KIND == "Melee" and cut.STAGGER_SECONDS > 0,
    "Disrupting Cut must execute the real melee stagger pipeline")

local reference = require(shared.C4ScoutReferenceTargets)
local expected = {
    Human = {20, 19, 20, 19, 21},
    Elf = {26, 25, 26, 25, 27},
}
for race, totals in pairs(expected) do
    local source = assert(reference.get(race))
    check(string.find(source.SourceUrl, "/c4/classes/", 1, true)
        ~= nil, race .. " must use the C4, not a later Chronicle")
    for index, level in ipairs({20, 24, 28, 32, 36}) do
        check(source.Levels[level] == totals[index],
            race .. " scout reference count at level "
                .. tostring(level) .. " has changed")
    end
end
check(reference.get("Orc") == nil,
    "Unmapped race must not be presented as source-verified")

local thunder = assert(Skills.get("ThunderShot"))
local ranger = character_for("Ranger")
ranger.Level = 36
check(not Unlocks.can_show(ranger, thunder),
    "Thunder Shot must stay hidden without prior mastered skills")
for _, required in ipairs(thunder.Prerequisites) do
    ranger.Progression.Skills[required.SkillId] = {
        Known = true, PurchasedRank = required.Rank - 1,
        Proficiency = required.Proficiency,
    }
end
check(not Unlocks.can_show(ranger, thunder),
    "Proficiency cannot replace required purchased bow ranks")
for _, required in ipairs(thunder.Prerequisites) do
    ranger.Progression.Skills[required.SkillId] = {
        Known = true, PurchasedRank = required.Rank,
        Proficiency = required.Proficiency - 1,
    }
end
check(not Unlocks.can_show(ranger, thunder),
    "Purchased basic ranks cannot bypass earned mastery")
for _, required in ipairs(thunder.Prerequisites) do
    ranger.Progression.Skills[required.SkillId] = {
        Known = true, PurchasedRank = required.Rank,
        Proficiency = required.Proficiency,
    }
end
check(Unlocks.can_show(ranger, thunder),
    "Mastered Ranger should see level-36 Thunder Shot")
check(Trainers.can_offer("RangerTrainer", ranger, "ThunderShot").ok,
    "Mastered Ranger trainer must offer real Thunder Shot")
check(not Unlocks.can_train(ranger, thunder, 1 + thunder.MaxRank),
    "Thunder Shot cannot buy an undefined fourth rank")
local previous_stagger = 0
for rank = 1, 3 do
    local effect = assert(Combat.get_for_rank("ThunderShot", rank))
    check(effect.KIND == "RangerProjectile"
        and effect.MAX_TARGETS == 1,
        "Thunder Shot must use real single-target Ranger delivery")
    check(effect.STAGGER_SECONDS > previous_stagger,
        "Every Thunder Shot rank must increase actual server stagger")
    check(effect.HUMAN_SLOW_SECONDS == 0
        and effect.ELF_SLOW_SECONDS == 0,
        "Thunder Shot must not inherit unrelated slow effects")
    previous_stagger = effect.STAGGER_SECONDS
end
print(("[C4 Control Skills] PASS: %d assertions."):format(assertions))
