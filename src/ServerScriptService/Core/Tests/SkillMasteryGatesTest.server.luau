--!strict
-- Focused first-class mastery and trainer visibility contract.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local shared = RS.Core.Shared
local core = SSS.Core

local Rules = require(shared:WaitForChild("SkillUnlockRules"))
local Definitions = require(
    shared:WaitForChild("SkillProgressionDefinitions")
)
local Trainers = require(shared:WaitForChild("TrainerCatalogues"))
local Snapshots = require(
    core.Services:WaitForChild("ProgressionSnapshotBuilder")
)
local Profiles = require(core.Services:WaitForChild("ProfileService"))
local Memory = require(
    core.Adapters:WaitForChild("InMemoryProfileAdapter")
)
local Inventory = require(
    core.Services:WaitForChild("InventoryService")
)
local Loadout = require(
    core.Services:WaitForChild("LoadoutService")
)
local Skills = require(
    core.Services:WaitForChild("SkillProgressionService")
)
local Quests = require(core.Services:WaitForChild("QuestService"))
local Advancement = require(
    core.Services:WaitForChild("ClassAdvancementService")
)
local Runtime = require(
    core.Services:WaitForChild("ProgressionRuntimeState")
)
local Dungeons = require(shared:WaitForChild("DungeonDefinitions"))
local CombatSkills = require(
    RS.Combat.Shared:WaitForChild("SkillDefinitions")
)

local USER_ID = 64001
local assertions = 0

-- Args:
--   condition (boolean): The expected level/mastery boundary.
--   message (string): Human-readable explanation on failure.
-- Returns:
--   nil: Raises if the assertion is false.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[Skill Mastery Gates Tests] " .. message)
end

-- Args:
--   profiles (any): In-memory profile writer for the test character.
--   level (number): Character level to set.
-- Returns:
--   nil: Sets only this fixture's level in authoritative profile data.
local function set_level(profiles: any, level: number)
    check(profiles:mutate(USER_ID, function(profile: any)
        profile.Characters.Slot1.Level = level
    end), "The test character's level must be persisted.")
end

-- Args:
--   profiles (any): In-memory profile writer for the test character.
--   skill_id (string): Registered basic skill to modify.
--   rank (number): Purchased rank, not merely known rank.
--   proficiency (number): Earned proficiency to persist.
-- Returns:
--   nil: Saves one character-owned skill mastery milestone.
local function set_skill(
    profiles: any,
    skill_id: string,
    rank: number,
    proficiency: number
)
    check(profiles:mutate(USER_ID, function(profile: any)
        profile.Characters.Slot1.Progression.Skills[skill_id] = {
            Known = true,
            StarterGranted = false,
            PurchasedRank = rank,
            Proficiency = proficiency,
        }
    end), "The skill mastery record must save.")
end

-- Args:
--   profiles (any): Profile containing a Human Fighter at level 7.
--   skills (any): Existing authoritative skill progression service.
-- Returns:
--   nil: Verifies hidden abilities, level-bracket rank purchase.
local function test_basic_levels(profiles: any, skills: any)
    local character = assert(profiles:get_character(USER_ID))
    local basic = assert(Definitions.get("GuardBreaker"))

    check(
        not Rules.can_show(character, basic),
        "Guard Breaker must be absent before level 8."
    )
    check(
        Snapshots.build(character).Skills.GuardBreaker == nil,
        "Unknown level-locked skills must not appear in the journal."
    )
    check(
        not Trainers.can_offer(
            "FighterTrainer", character, "GuardBreaker"
        ).ok,
        "The trainer must not advertise a locked basic skill."
    )
    check(
        skills:learn_trainer_skill(USER_ID, "GuardBreaker").reason
            == "CharacterLevelTooLow",
        "Direct calls cannot learn the hidden skill early."
    )

    set_level(profiles, 8)
    character = assert(profiles:get_character(USER_ID))
    check(
        Rules.can_show(character, basic)
            and Snapshots.build(character).Skills.GuardBreaker ~= nil,
        "Level 8 must reveal the first Guard Breaker rank."
    )
    check(
        skills:learn_trainer_skill(USER_ID, "GuardBreaker").ok,
        "The existing trainer must teach an eligible basic skill."
    )

    set_level(profiles, 13)
    set_skill(profiles, "GuardBreaker", 1, 100)
    check(
        skills:purchase_rank(USER_ID, "GuardBreaker").reason
            == "CharacterLevelTooLow",
        "Earned proficiency must not bypass rank-2 level 14."
    )
    set_level(profiles, 14)
    check(
        skills:purchase_rank(USER_ID, "GuardBreaker").rank == 2,
        "Rank 2 must require both proficiency and level 14."
    )
    set_level(profiles, 20)
    set_skill(profiles, "GuardBreaker", 2, 299)
    check(
        skills:purchase_rank(USER_ID, "GuardBreaker").reason
            == "ProficiencyThresholdNotMet",
        "Rank 3 must require 300 earned proficiency."
    )
    set_skill(profiles, "GuardBreaker", 2, 300)
    check(
        skills:purchase_rank(USER_ID, "GuardBreaker").rank == 3,
        "Level 20 and earned proficiency unlock basic rank 3."
    )
end

-- Args:
--   profiles (any): Loaded Human Fighter profile.
--   quests (any): Existing trusted event and quest service.
--   advancement (any): Existing class trial and claim service.
-- Returns:
--   nil: Verifies the rank, proficiency and level gates on trials.
local function test_advancement(
    profiles: any,
    quests: any,
    advancement: any
)
    set_skill(profiles, "ShieldBash", 3, 399)
    set_skill(profiles, "Mend", 3, 300)
    local blocked = advancement:start_trial(USER_ID)
    check(
        blocked.reason == "AdvancementRequirementsNotMet"
            and blocked.requirement_reason
                == "PrerequisiteSkillProficiency",
        "Full skill ranks alone cannot bypass earned mastery."
    )
    set_skill(profiles, "ShieldBash", 2, 400)
    check(
        advancement:start_trial(USER_ID).requirement_reason
            == "PrerequisiteSkillRank",
        "Proficiency alone cannot replace a full purchased skill rank."
    )
    set_skill(profiles, "ShieldBash", 3, 400)
    set_level(profiles, 19)
    check(
        advancement:start_trial(USER_ID).requirement_reason
            == "CharacterLevelTooLow",
        "Two mastered skills cannot bypass the class level gate."
    )
    set_level(profiles, 20)
    check(
        advancement:start_trial(USER_ID).ok,
        "Level 20 plus two fully mastered skills unlocks the trial."
    )
    check(
        quests:record_event(USER_ID, {
            EventId = "mastery-quest-temple-clear",
            Type = "DungeonClear",
            TargetId = Dungeons.TEST_DUNGEON.Id,
            Amount = 1,
        }).ok,
        "Only a trusted service's dungeon-clear event readies trial."
    )
    set_skill(profiles, "ShieldBash", 2, 400)
    check(
        advancement:claim(USER_ID).reason
            == "AdvancementRequirementsNotMet",
        "Respeccing required mastery during a trial blocks its claim."
    )
    set_skill(profiles, "ShieldBash", 3, 400)
    check(
        advancement:claim(USER_ID).class_id == "HumanVanguard",
        "A ready trial grants only the character's approved class."
    )
end

-- Args:
--   profiles (any): Human Vanguard with a completed class trial.
--   skills (any): Existing skill-point authority.
-- Returns:
--   nil: Verifies late trainer visibility and learned-skill restrictions.
local function test_advanced_ability(profiles: any, skills: any)
    local character = assert(profiles:get_character(USER_ID))
    local ability = assert(Definitions.get("VanguardChallenge"))
    check(
        not Rules.can_show(character, ability)
            and not Trainers.can_offer(
                "VanguardTrainer", character, ability.Id
            ).ok,
        "An earned advanced class must still wait for skill level 24."
    )
    check(
        skills:learn_trainer_skill(USER_ID, ability.Id).reason
            == "CharacterLevelTooLow",
        "Direct specialist skill purchases must enforce level 24."
    )
    set_level(profiles, 24)
    set_skill(profiles, "GuardBreaker", 3, 299)
    character = assert(profiles:get_character(USER_ID))
    check(
        not Rules.can_show(character, ability),
        "Level 24 alone must not reveal skills without basic mastery."
    )
    check(
        skills:learn_trainer_skill(USER_ID, ability.Id).reason
            == "PrerequisiteSkillProficiency",
        "Specialist skills require 300 earned Guard Breaker proficiency."
    )
    set_skill(profiles, "GuardBreaker", 3, 300)
    character = assert(profiles:get_character(USER_ID))
    check(
        Rules.can_show(character, ability)
            and Trainers.can_offer(
                "VanguardTrainer", character, ability.Id
            ).ok,
        "Earned class, level and maxed basic skill unlock the trainer."
    )
    check(
        skills:learn_trainer_skill(USER_ID, ability.Id).ok,
        "Vanguard may learn the new role skill at its trainer."
    )

    Runtime.set_character(
        USER_ID, assert(profiles:get_character(USER_ID))
    )
    local usable = Runtime.is_skill_usable(USER_ID, ability.Id, {})
    check(usable, "The active specialist must be able to use the skill.")
    set_skill(profiles, "GuardBreaker", 2, 300)
    Runtime.set_character(
        USER_ID, assert(profiles:get_character(USER_ID))
    )
    local allowed, reason = Runtime.is_skill_usable(
        USER_ID, ability.Id, {}
    )
    check(
        not allowed and reason == "PrerequisiteSkillRank",
        "Dropping the basic rank must disable advanced combat use."
    )
    Runtime.clear_character(USER_ID)
end

-- Args:
--   None.
-- Returns:
--   nil: Checks every base-class ability uses the same level-8 visibility
--       and registered server-owned combat skill definition.
local function test_all_basic_classes()
    local examples = {
        {"Fighter", "GuardBreaker", "FighterTrainer", "Melee"},
        {"Mage", "AetherBolt", "MageTrainer", "MagicProjectile"},
        {"Ranger", "TrackerShot", "RangerTrainer", "RangerProjectile"},
        {"Rogue", "ViperStrike", "RogueTrainer", "Melee"},
    }

    for _, example in ipairs(examples) do
        local class_id = example[1]
        local skill_id = example[2]
        local trainer_id = example[3]
        local expected_kind = example[4]
        local character = {
            Level = 7,
            Identity = {
                Version = 1,
                RaceId = "Human",
                BaseClassId = class_id,
                ClassId = class_id,
                CreationStage = "Complete",
            },
            Progression = {Skills = {}},
            ClassAdvancement = {},
        }
        local definition = assert(Definitions.get(skill_id))
        check(
            not Rules.can_show(character, definition),
            "Each class's new basic ability must be hidden at level 7."
        )
        character.Level = 8
        check(
            Rules.can_show(character, definition)
                and Trainers.can_offer(
                    trainer_id, character, skill_id
                ).ok,
            "Each class must see its own base skill at level 8."
        )
        check(
            CombatSkills.get(skill_id).KIND == expected_kind,
            "Each class's base skill needs a real combat definition."
        )
        character.Identity.BaseClassId = "OtherClass"
        check(
            not Rules.can_show(character, definition),
            "A different base class must not see the new skill."
        )
    end
end

-- Args:
--   None.
-- Returns:
--   nil: Verifies first mastery progression without unrelated dungeon tests.
local function main()
    local profiles = Profiles.new(Memory.new())
    check(profiles:load(USER_ID) ~= nil, "Fixture must load.")
    check(profiles:mutate(USER_ID, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 7
        character.Identity = {
            Version = 1,
            RaceId = "Human",
            BaseClassId = "Fighter",
            ClassId = "Fighter",
            CreationStage = "Complete",
        }
        character.Progression.SkillPointEntitlement = 60
    end), "The test Fighter must be an authenticated character.")

    local inventory = Inventory.new(profiles)
    local loadout = Loadout.new(profiles)
    local skills = Skills.new(profiles, inventory, loadout)
    local quests = Quests.new(profiles)
    local advancement = Advancement.new(profiles, quests, "Base")

    test_all_basic_classes()
    test_basic_levels(profiles, skills)
    test_advancement(profiles, quests, advancement)
    test_advanced_ability(profiles, skills)
    print(string.format(
        "[Skill Mastery Gates Tests] PASS: %d assertions.", assertions
    ))
end

main()
