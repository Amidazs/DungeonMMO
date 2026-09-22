--!strict
-- C4-inspired level bands, early skill mastery and advanced-class gates.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local Services = ServerScriptService.Core.Services
local ProfileSchema = require(Shared.ProfileSchema)
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Quests = require(Shared.QuestDefinitions)
local Trainers = require(Shared.TrainerCatalogues)
local Passives = require(Shared.PassiveSkillEffects)
local Combat = require(ReplicatedStorage.Combat.Shared.SkillDefinitions)
local Snapshots = require(Services.ProgressionSnapshotBuilder)

local assertions = 0

-- Args:
--   condition (boolean): Authoritative progression invariant to verify.
--   message (string): Regression description shown on failure.
-- Returns:
--   nil: Records a passing assertion or stops at the first failure.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[C4 Skill Progression] " .. message)
end

-- Args:
--   race_id (string): Registered race of the test character.
--   base_class (string): Fighter, Mage, Ranger or Rogue.
-- Returns:
--   any: Independent, complete server-owned character profile.
local function character_for(race_id: string, base_class: string)
    local character = ProfileSchema.create_default(77502)
        .Characters.Slot1
    character.Identity = {
        Version = 1,
        RaceId = race_id,
        BaseClassId = base_class,
        ClassId = base_class,
        CreationStage = "Complete",
    }
    character.Progression.SkillPointEntitlement = 100
    return character
end

-- Args:
--   character (any): Mutable test character.
--   skill_id (string): Authoritative skill definition identifier.
--   rank (number): Purchased rank already earned.
--   proficiency (number): Server-awarded use-based proficiency.
-- Returns:
--   nil: Records one legitimate, purchased skill state in the fixture.
local function seed_skill(character, skill_id, rank, proficiency)
    character.Progression.Skills[skill_id] = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = rank,
        Proficiency = proficiency,
    }
end

local cases = {
    {"Fighter", "IronCleave", "GuardBreaker", "FighterTrainer",
        "FighterAdvancementTrial", "HumanVanguard",
        "VanguardTrainer", "VanguardChallenge"},
    {"Mage", "AetherBolt", "CinderBolt", "MageTrainer",
        "MageAdvancementTrial", "HumanArcanist",
        "ArcanistTrainer", "ArcanistEmber"},
    {"Ranger", "ArcherDraw", "TrackerShot", "RangerTrainer",
        "RangerAdvancementTrial", "HumanSharpshooter",
        "SharpshooterTrainer", "SharpshooterPierce"},
    {"Rogue", "RogueVitalBlow", "ViperStrike", "RogueTrainer",
        "RogueAdvancementTrial", "HumanRogueDuelist",
        "DuelistTrainer", "DuelistDeadlyBlow"},
}

for _, case in ipairs(cases) do
    local base_class = case[1]
    local basic_id = case[2]
    local trainer_id = case[4]
    local trial_id = case[5]
    local advanced_class = case[6]
    local advanced_trainer = case[7]
    local advanced_skill = case[8]
    local character = character_for("Human", base_class)
    local basic = assert(Skills.get(basic_id))
    local advanced = assert(Skills.get(advanced_skill))
    local trial = assert(Quests.get(trial_id))

    check(
        not Unlocks.can_show(character, basic),
        base_class .. ": basic skill must be hidden before its level."
    )
    check(
        Trainers.resolve_for_character(
            trainer_id, character
        ).ok,
        base_class .. ": starter trainer must remain accessible."
    )
    check(
        Trainers.can_offer(
            trainer_id, character, basic_id
        ).ok == false,
        base_class .. ": trainer cannot offer an early skill at level 1."
    )
    check(
        Snapshots.build(character).Skills[basic_id] == nil,
        base_class .. ": locked skill cannot leak into player snapshot."
    )

    character.Level = basic.RankLevels[1]
    check(
        Unlocks.can_show(character, basic)
            and Trainers.can_offer(
                trainer_id, character, basic_id
            ).ok,
        base_class .. ": the correct level must reveal its skill."
    )
    check(
        not Unlocks.can_train(character, basic, 2),
        base_class .. ": second rank must obey its level bracket."
    )

    character.Level = 20
    check(
        Unlocks.can_train(character, basic, 1),
        base_class .. ": eligible player may learn first rank."
    )
    check(
        Quests.is_character_eligible(
            character, trial
        ) == false,
        base_class .. ": level alone must not unlock advancement."
    )

    for _, requirement in ipairs(trial.SkillPrerequisites) do
        seed_skill(
            character,
            requirement.SkillId,
            requirement.Rank - 1,
            requirement.Proficiency
        )
    end
    check(
        not Unlocks.can_start_trial(character, trial),
        base_class .. ": known-but-unmastered skills do not unlock trial."
    )
    for _, requirement in ipairs(trial.SkillPrerequisites) do
        seed_skill(
            character,
            requirement.SkillId,
            requirement.Rank,
            requirement.Proficiency - 1
        )
    end
    check(
        not Unlocks.can_start_trial(character, trial),
        base_class .. ": skill rank cannot replace earned proficiency."
    )
    for _, requirement in ipairs(trial.SkillPrerequisites) do
        seed_skill(
            character,
            requirement.SkillId,
            requirement.Rank,
            requirement.Proficiency
        )
    end
    check(
        Unlocks.can_start_trial(character, trial)
            and Quests.is_character_eligible(character, trial),
        base_class .. ": the fully mastered level-20 trial must unlock."
    )

    check(
        not Unlocks.can_show(character, advanced),
        base_class .. ": advanced skills stay hidden before class change."
    )
    character.ClassAdvancement.ActiveClassId = advanced_class
    character.ClassAdvancement.CompletedByRace = {
        Human = {[advanced_class] = true},
    }
    check(
        not Unlocks.can_show(character, advanced),
        base_class .. ": class at level 20 must not reveal level-24 skill."
    )
    character.Level = 24
    check(
        not Unlocks.can_show(character, advanced),
        base_class .. ": mastery, not just class and level, is required."
    )
    for _, requirement in ipairs(advanced.Prerequisites) do
        seed_skill(
            character,
            requirement.SkillId,
            requirement.Rank,
            requirement.Proficiency
        )
    end
    check(
        Unlocks.can_show(character, advanced)
            and Trainers.can_offer(
                advanced_trainer, character, advanced_skill
            ).ok,
        base_class .. ": owned class and basics unlock its specialist."
    )
    check(
        not Unlocks.can_train(character, advanced, 2),
        base_class .. ": specialist rank 2 must wait until level 28."
    )
    check(
        Combat.get_for_rank(advanced_skill, 3) ~= nil,
        base_class .. ": advanced ability needs actual combat effects."
    )
end

-- Independent Elf classes must not see or buy the Human specialization.
for _, case in ipairs(cases) do
    local elf = character_for("Elf", case[1])
    elf.Level = 32
    elf.ClassAdvancement.ActiveClassId = case[6]
    for _, requirement in ipairs(
        assert(Skills.get(case[8])).Prerequisites
    ) do
        seed_skill(
            elf, requirement.SkillId, requirement.Rank,
            requirement.Proficiency
        )
    end
    check(
        not Unlocks.can_show(elf, assert(Skills.get(case[8]))),
        "Race and completed class must protect specialist visibility."
    )
end

for _, pair in ipairs({
    {"Ranger", "RangerBowMastery"},
    {"Rogue", "RogueBladeMastery"},
}) do
    local character = character_for("Human", pair[1])
    character.Level = 15
    local definition = assert(Skills.get(pair[2]))
    seed_skill(character, pair[2], definition.MaxRank, 0)
    check(
        Passives.damage_bonus(character, pair[2]) > 0,
        pair[1] .. ": mastered weapon passive must change damage."
    )
end

print(string.format(
    "[C4 Skill Progression] PASS: %d assertions.", assertions
))
