--!strict
-- One focused C4-density content check, not a general dungeon regression.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local shared = ReplicatedStorage.Core.Shared
local core = ServerScriptService.Core
local services = core.Services
local definitions = require(
    shared:WaitForChild("SkillProgressionDefinitions")
)
local trainers = require(shared:WaitForChild("TrainerCatalogues"))
local snapshots = require(
    services:WaitForChild("ProgressionSnapshotBuilder")
)
local combat = require(
    ReplicatedStorage.Combat.Shared:WaitForChild("SkillDefinitions")
)
local profiles_class = require(services:WaitForChild("ProfileService"))
local memory = require(core.Adapters:WaitForChild("InMemoryProfileAdapter"))
local inventory = require(services:WaitForChild("InventoryService"))
local loadout = require(services:WaitForChild("LoadoutService"))
local skills_class = require(
    services:WaitForChild("SkillProgressionService")
)
local proficiency_class = require(
    services:WaitForChild("ProficiencyService")
)

local USER_ID = 67210
local SKILLS = {"IronCleave", "PursuitStep"}
local RANK_LEVELS = {5, 5, 5, 10, 10, 10, 15, 15, 15}
local THRESHOLDS = {0, 20, 50, 90, 130, 180, 230, 290, 350}
local assertions = 0

-- Args:
--   condition (boolean): Expected rank/content rule.
--   message (string): Diagnostic for a failed contract.
-- Returns:
--   nil: Counts a passing assertion or fails with the reason.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[C4 Early Fighter Ranks] " .. message)
end

-- Args:
--   profiles (any): Isolated in-memory profile service.
--   level (number): Server-owned character level.
-- Returns:
--   nil: Persists the level without manipulating client input.
local function set_level(profiles: any, level: number)
    check(profiles:mutate(USER_ID, function(profile: any)
        profile.Characters.Slot1.Level = level
    end), "The character level must save.")
end

-- Args:
--   profiles (any): Isolated in-memory profile service.
--   skill_id (string): Registered Fighter skill to advance.
--   proficiency (number): Earned mastery recorded for the current rank.
-- Returns:
--   nil: Persists a test contribution for the next rank boundary.
local function set_proficiency(
    profiles: any,
    skill_id: string,
    proficiency: number
)
    check(profiles:mutate(USER_ID, function(profile: any)
        profile.Characters.Slot1.Progression.Skills[
            skill_id
        ].Proficiency = proficiency
    end), "Earned proficiency must save.")
end

-- Args:
--   profiles (any): Profile for a valid, level-four Fighter.
-- Returns:
--   nil: Checks both skills are hidden before their first level bracket.
local function check_initial_visibility(profiles: any)
    local character = assert(profiles:get_character(USER_ID))
    local snapshot = snapshots.build(character)
    for _, skill_id in ipairs(SKILLS) do
        check(
            snapshot.Skills[skill_id] == nil,
            "An unknown skill is hidden before its unlock level."
        )
        check(
            trainers.can_offer(
                "FighterTrainer", character, skill_id
            ).ok == false,
            "The trainer must hide unknown level-locked skills."
        )
    end
end

-- Args:
--   profiles (any): Test profile with SP and an eligible Fighter.
--   skills (any): Real server-backed trainer/purchase service.
--   skill_id (string): One of the two new usable skills.
-- Returns:
--   nil: Trains all nine ranked effects at their exact level brackets.
local function check_skill_ladder(
    profiles: any,
    skills: any,
    skill_id: string
)
    check(
        skills:learn_trainer_skill(USER_ID, skill_id).reason
            == "CharacterLevelTooLow",
        "Direct skill purchases must reject level four."
    )
    set_level(profiles, 5)
    check(
        skills:learn_trainer_skill(USER_ID, skill_id).rank == 1,
        "The first rank is available at level five."
    )

    for rank = 2, 9 do
        if rank == 4 or rank == 7 then
            set_proficiency(
                profiles, skill_id, THRESHOLDS[rank]
            )
            check(
                skills:purchase_rank(USER_ID, skill_id).reason
                    == "CharacterLevelTooLow",
                "Earned proficiency cannot skip the next level bracket."
            )
            set_level(profiles, RANK_LEVELS[rank])
        end

        set_proficiency(
            profiles, skill_id, THRESHOLDS[rank] - 1
        )
        check(
            skills:purchase_rank(USER_ID, skill_id).reason
                == "ProficiencyThresholdNotMet",
            "Each intermediate rank requires earned proficiency."
        )
        set_proficiency(profiles, skill_id, THRESHOLDS[rank])
        check(
            skills:purchase_rank(USER_ID, skill_id).rank == rank,
            "A purchased rank must follow the preceding rank."
        )
    end

    check(
        skills:purchase_rank(USER_ID, skill_id).reason == "MaxRank",
        "Nine is the maximum rank; later purchases cannot spend SP."
    )
    check(
        profiles:get_character(USER_ID).Progression.Skills[
            skill_id
        ].PurchasedRank == 9,
        "The final skill rank must be persisted in the character."
    )
end

-- Args:
--   skill_id (string): Registered skill with nine actual combat ranks.
-- Returns:
--   nil: Confirms every authored rank changes a real damage magnitude.
local function check_combat_ranks(skill_id: string)
    local definition = assert(definitions.get(skill_id))
    check(
        definition.MaxRank == 9,
        "The authored skill must contain nine training ranks."
    )
    local previous_damage = 0
    for rank = 1, 9 do
        check(
            definition.RankLevels[rank] == RANK_LEVELS[rank],
            "Each rank needs the correct five/ten/fifteen level bracket."
        )
        local effect = assert(combat.get_for_rank(skill_id, rank))
        check(
            effect.KIND == "Melee"
                and effect.BASE_DAMAGE > previous_damage,
            "Every rank must improve actual server combat damage."
        )
        previous_damage = effect.BASE_DAMAGE
    end
end

-- Args:
--   None.
-- Returns:
--   nil: Verifies both real nine-rank skills without old dungeon tests.
local function main()
    local profiles = profiles_class.new(memory.new())
    check(profiles:load(USER_ID) ~= nil, "The test profile must load.")
    check(profiles:mutate(USER_ID, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 4
        character.Identity = {
            Version = 1,
            RaceId = "Human",
            BaseClassId = "Fighter",
            ClassId = "Fighter",
            CreationStage = "Complete",
        }
        character.Progression.SkillPointEntitlement = 80
    end), "The Fighter profile must be valid.")
    check_initial_visibility(profiles)

    local skills = skills_class.new(
        profiles, inventory.new(profiles), loadout.new(profiles)
    )
    for _, skill_id in ipairs(SKILLS) do
        set_level(profiles, 4)
        check_skill_ladder(profiles, skills, skill_id)
        check_combat_ranks(skill_id)
    end

    local saved = profiles:get_character(USER_ID)
    check(
        saved.Progression.Skills.IronCleave.PurchasedRank == 9
            and saved.Progression.Skills.PursuitStep.PurchasedRank == 9,
        "Both real skill ladders must persist independently."
    )
    print(string.format(
        "[C4 Early Fighter Ranks] PASS: %d assertions.", assertions
    ))
end

main()
