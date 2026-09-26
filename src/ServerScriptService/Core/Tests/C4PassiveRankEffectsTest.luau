--!strict
-- Focused rank-1..6 proof for actual Fighter and Mage passive effects.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Core = SSS.Core

local ProfileService = require(
    Core.Services:WaitForChild("ProfileService")
)
local Memory = require(
    Core.Adapters:WaitForChild("InMemoryProfileAdapter")
)
local Inventory = require(
    Core.Services:WaitForChild("InventoryService")
)
local Loadout = require(
    Core.Services:WaitForChild("LoadoutService")
)
local Skills = require(
    Core.Services:WaitForChild("SkillProgressionService")
)
local Runtime = require(
    Core.Services:WaitForChild("ProgressionRuntimeState")
)
local Trainers = require(Shared:WaitForChild("TrainerCatalogues"))
local Passive = require(Shared:WaitForChild("PassiveSkillEffects"))

local assertions = 0

-- Args:
--   condition (boolean): One purchased-rank or combat-effect invariant.
--   message (string): Reason for the failed assertion.
-- Returns:
--   nil: Records the check or raises an actionable error.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[C4 Passive Rank Effects Tests] " .. message)
end

-- Args:
--   profiles (any): In-memory authoritative profile service.
--   user_id (number): Independent test player's identity.
--   base_class (string): Fighter or Mage class selection.
--   level (number): Level before the first passive unlock.
-- Returns:
--   nil: Seeds the chosen character without giving it any passive ranks.
local function seed_player(
    profiles: any,
    user_id: number,
    base_class: string,
    level: number
)
    check(profiles:load(user_id) ~= nil, "Test profile must load.")
    check(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = level
        character.Identity = {
            Version = 1,
            RaceId = "Human",
            BaseClassId = base_class,
            ClassId = base_class,
            CreationStage = "Complete",
        }
        character.Progression.SkillPointEntitlement = 60
    end), "The selected character must save its class and level.")
end

-- Args:
--   profiles (any): Authoritative test profile service.
--   user_id (number): Existing selected character owner.
--   level (number): New level reached by that character.
-- Returns:
--   nil: Saves the next level bracket.
local function set_level(profiles: any, user_id: number, level: number)
    check(profiles:mutate(user_id, function(profile: any)
        profile.Characters.Slot1.Level = level
    end), "Level bracket must save.")
end

-- Args:
--   profiles (any): Authoritative selected-character profiles.
--   user_id (number): Fighter or Mage test character owner.
--   skill_id (string): Known passive being trained.
--   multiplier (string): The physical or magical getter to check.
--   per_rank (number): Server-authored bonus earned at each rank.
--   baseline (number): Measured no-passive server damage multiplier.
-- Returns:
--   nil: Verifies rank 1-6 grant real damage, not inert metadata.
local function verify_effects(
    profiles: any,
    user_id: number,
    skill_id: string,
    multiplier: string,
    per_rank: number,
    baseline: number
)
    local character = assert(profiles:get_character(user_id))
    Runtime.set_character(user_id, character)
    local actual = Runtime[multiplier](user_id)
    local rank = character.Progression.Skills[skill_id].PurchasedRank
    check(
        math.abs(Passive.damage_bonus(character, skill_id)
            - rank * per_rank) < 0.00001,
        "Purchased passive rank must determine its server bonus."
    )
    check(
        math.abs(actual - baseline - rank * per_rank) < 0.00001,
        "Runtime multiplier must include the learned passive effect."
    )
end

-- Args:
--   profiles (any): Independent saved character profiles.
--   skills (any): Existing, server-owned skill purchase service.
--   entry (any): One passive's level, trainer and multiplier contract.
-- Returns:
--   nil: Exercises hidden level gates, six purchases and persistence.
local function test_passive(profiles: any, skills: any, entry: any)
    local user_id = entry.UserId
    local skill_id = entry.SkillId
    seed_player(profiles, user_id, entry.ClassId, entry.FirstLevel - 1)

    local character = assert(profiles:get_character(user_id))
    Runtime.set_character(user_id, character)
    local baseline = Runtime[entry.Multiplier](user_id)
    check(
        Passive.damage_bonus(character, skill_id) == 0,
        "Unlearned passive must not modify damage."
    )
    check(
        not Trainers.can_offer(
            entry.TrainerId, character, skill_id
        ).ok,
        "Unknown passive must be hidden before its first level."
    )
    check(
        skills:learn_trainer_skill(user_id, skill_id).reason
            == "CharacterLevelTooLow",
        "A forged direct request cannot bypass the hidden level gate."
    )
    set_level(profiles, user_id, entry.FirstLevel)
    check(
        Trainers.can_offer(
            entry.TrainerId, profiles:get_character(user_id),
            skill_id
        ).ok,
        "The passive must become teachable at its first bracket."
    )
    check(
        skills:learn_trainer_skill(user_id, skill_id).ok,
        "Rank one must be bought from the existing skill service."
    )

    for target_rank = 2, 6 do
        if target_rank == 4 then
            check(
                skills:purchase_rank(user_id, skill_id).reason
                    == "CharacterLevelTooLow",
                "The next bracket cannot be bought early."
            )
            set_level(profiles, user_id, entry.SecondLevel)
        end
        local purchased = skills:purchase_rank(user_id, skill_id)
        check(
            purchased.ok and purchased.rank == target_rank,
            "Passive rank requires SP and the level, not cast proficiency."
        )
        verify_effects(
            profiles, user_id, skill_id, entry.Multiplier,
            entry.PerRank, baseline
        )
    end
    check(
        skills:purchase_rank(user_id, skill_id).reason == "MaxRank",
        "Fully trained rank six must not grant an extra bonus."
    )
    local character_after = assert(profiles:get_character(user_id))
    check(
        Passive.damage_bonus(character_after, skill_id)
            == 6 * entry.PerRank,
        "The fully trained passive must provide its complete bonus."
    )
    check(profiles:save(user_id, "C4Passive"),
        "All purchased passive ranks must save.")
    check(profiles:release(user_id, "C4Passive"),
        "The saved character must release its writer lease.")
    check(profiles:load(user_id) ~= nil,
        "The same player must reload their earned passive.")
    character_after = assert(profiles:get_character(user_id))
    check(
        character_after.Progression.Skills[skill_id].PurchasedRank == 6,
        "Profile reload must retain all six purchased ranks."
    )
    local wrong_class = table.clone(character_after)
    wrong_class.Identity = table.clone(character_after.Identity)
    wrong_class.Identity.BaseClassId = "Rogue"
    check(
        Passive.damage_bonus(wrong_class, skill_id) == 0,
        "Other classes cannot inherit the Fighter/Mage passive bonus."
    )
    Runtime.clear_character(user_id)
end

-- Args:
--   None.
-- Returns:
--   nil: Tests the two new passive skill families and their damage use.
local function main()
    local profiles = ProfileService.new(Memory.new())
    local inventory = Inventory.new(profiles)
    local loadout = Loadout.new(profiles)
    local skills = Skills.new(profiles, inventory, loadout)

    local cases = {
        {
            UserId = 64201,
            ClassId = "Fighter",
            TrainerId = "FighterTrainer",
            SkillId = "IronDiscipline",
            FirstLevel = 5,
            SecondLevel = 10,
            Multiplier = "get_physical_multiplier",
            PerRank = 0.01,
        },
        {
            UserId = 64202,
            ClassId = "Mage",
            TrainerId = "MageTrainer",
            SkillId = "ArcaneDiscipline",
            FirstLevel = 7,
            SecondLevel = 14,
            Multiplier = "get_magical_multiplier",
            PerRank = 0.015,
        },
    }
    for _, entry in ipairs(cases) do
        test_passive(profiles, skills, entry)
    end
    print(string.format(
        "[C4 Passive Rank Effects Tests] PASS: %d assertions.",
        assertions
    ))
end

main()
