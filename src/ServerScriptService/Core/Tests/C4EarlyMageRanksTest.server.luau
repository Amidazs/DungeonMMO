--!strict
-- Focused real six-rank healing progression, not a Dungeon regression.
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

local USER_ID = 67220
local SKILL_ID = "RenewingLight"
local RANK_LEVELS = {7, 7, 7, 14, 14, 14}
local THRESHOLDS = {0, 25, 50, 75, 110, 150}
local assertions = 0

-- Args:
--   condition (boolean): Expected server-backed progression rule.
--   message (string): Useful failure diagnostic.
-- Returns:
--   nil: Counts a passing check or raises.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[C4 Early Mage Ranks] " .. message)
end

-- Args:
--   profiles (any): Test character's in-memory profile.
--   level (number): Character level to persist.
-- Returns:
--   nil: Saves a legitimate character level without client input.
local function set_level(profiles: any, level: number)
    check(profiles:mutate(USER_ID, function(profile: any)
        profile.Characters.Slot1.Level = level
    end), "Mage level must persist.")
end

-- Args:
--   profiles (any): Mage profile below its first healing rank.
-- Returns:
--   nil: Ensures an unknown skill is hidden from both UI snapshots.
local function check_hidden(profiles: any)
    local character = assert(profiles:get_character(USER_ID))
    check(
        snapshots.build(character).Skills[SKILL_ID] == nil,
        "Unknown healing skill must be hidden until level seven."
    )
    check(
        not trainers.can_offer(
            "MageTrainer", character, SKILL_ID
        ).ok,
        "The Mage trainer cannot offer level-locked skills."
    )
end

-- Args:
--   profiles (any): Authenticated Mage character.
--   skills (any): Server-owned SP and rank authority.
--   proficiency (any): Real earned contribution service.
-- Returns:
--   nil: Learns six ranks with both level and mastery enforcement.
local function check_training(
    profiles: any,
    skills: any,
    proficiency: any
)
    check(
        skills:learn_trainer_skill(USER_ID, SKILL_ID).reason
            == "CharacterLevelTooLow",
        "Direct skill requests must not bypass the level gate."
    )
    set_level(profiles, 7)
    check(
        skills:learn_trainer_skill(USER_ID, SKILL_ID).rank == 1,
        "Level seven must unlock the first healing rank."
    )

    for rank = 2, 6 do
        local target = THRESHOLDS[rank]
        local contribution = proficiency:grant(
            USER_ID, SKILL_ID, target, {eligible = true}
        )
        check(
            contribution.ok and contribution.new_value == target,
            "Valid server contributions must reach the next rank cap."
        )
        if rank == 4 then
            check(
                skills:purchase_rank(USER_ID, SKILL_ID).reason
                    == "CharacterLevelTooLow",
                "Full mastery at level seven cannot unlock rank four."
            )
            set_level(profiles, 14)
        end
        check(
            skills:purchase_rank(USER_ID, SKILL_ID).rank == rank,
            "The trainer must grant the correct earned healing rank."
        )
    end
    check(
        skills:purchase_rank(USER_ID, SKILL_ID).reason == "MaxRank",
        "Rank six must not allow another SP purchase."
    )
end

-- Args:
--   profiles (any): Current Mage profile after rank six.
-- Returns:
--   nil: Proves effective healing ranks and saved character progress.
local function check_effects_and_reload(profiles: any)
    local definition = assert(definitions.get(SKILL_ID))
    local previous_healing = 0
    for rank = 1, definition.MaxRank do
        check(
            definition.RankLevels[rank] == RANK_LEVELS[rank],
            "Healing ranks must align to the level-seven/fourteen steps."
        )
        local effect = assert(combat.get_for_rank(SKILL_ID, rank))
        check(
            effect.KIND == "MageHeal"
                and effect.TOTAL_HEAL > previous_healing,
            "Each healing rank must improve real server-applied healing."
        )
        previous_healing = effect.TOTAL_HEAL
    end

    local character = assert(profiles:get_character(USER_ID))
    check(
        character.Progression.Skills[SKILL_ID].PurchasedRank == 6
            and character.Progression.Skills[SKILL_ID].Proficiency
                == 150,
        "Highest purchased rank and earned mastery must coexist."
    )
    check(profiles:save(USER_ID, "C4MageRankTest"),
        "Healing progression must save.")
    check(profiles:release(USER_ID, "C4MageRankTest"),
        "The profile must release before a fresh login.")
    check(profiles:load(USER_ID) ~= nil,
        "Mage progress must reload through profile migration.")
    character = assert(profiles:get_character(USER_ID))
    check(
        character.Progression.Skills[SKILL_ID].PurchasedRank == 6
            and character.Progression.Skills[SKILL_ID].Proficiency
                == 150,
        "Profile migration must preserve six-rank earned mastery."
    )
end

-- Args:
--   None.
-- Returns:
--   nil: Accepts the new Mage content with one focused local contract.
local function main()
    local profiles = profiles_class.new(memory.new())
    check(profiles:load(USER_ID) ~= nil,
        "A test Mage profile must load.")
    check(profiles:mutate(USER_ID, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 6
        character.Identity = {
            Version = 1,
            RaceId = "Human",
            BaseClassId = "Mage",
            ClassId = "Mage",
            CreationStage = "Complete",
        }
        character.Progression.SkillPointEntitlement = 40
    end), "A level-six Mage must be created.")
    check_hidden(profiles)

    local skills = skills_class.new(
        profiles, inventory.new(profiles), loadout.new(profiles)
    )
    local proficiency = proficiency_class.new(profiles)
    check_training(profiles, skills, proficiency)
    check_effects_and_reload(profiles)
    print(string.format(
        "[C4 Early Mage Ranks] PASS: %d assertions.", assertions
    ))
end

main()
