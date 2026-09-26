--!strict
-- Focused Fighter HP and Mage healing ranks with real server stat effects.
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
--   condition (boolean): Required skill or stat behaviour.
--   message (string): Explanation for a failing assertion.
-- Returns:
--   nil: Counts a passing check or raises on failure.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[C4 Vitality Restoration Tests] " .. message)
end

-- Args:
--   profiles (any): Isolated authoritative profile service.
--   entry (any): Fighter or Mage identity and level information.
-- Returns:
--   nil: Sets up a character without buying the new passive.
local function seed_character(profiles: any, entry: any)
    check(profiles:load(entry.UserId) ~= nil, "Profile must load.")
    check(profiles:mutate(entry.UserId, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = entry.FirstLevel - 1
        character.Identity = {
            Version = 1,
            RaceId = "Human",
            BaseClassId = entry.ClassId,
            ClassId = entry.ClassId,
            CreationStage = "Complete",
        }
        character.Progression.SkillPointEntitlement = 40
    end), "The selected character and SP budget must save.")
end

-- Args:
--   profiles (any): Authoritative profile owner.
--   user_id (number): Selected test character.
--   level (number): New server-owned training level.
-- Returns:
--   nil: Persists the requested training level.
local function set_level(profiles: any, user_id: number, level: number)
    check(profiles:mutate(user_id, function(profile: any)
        profile.Characters.Slot1.Level = level
    end), "The new level must save.")
end

-- Args:
--   entry (any): Skill, role, trainer and stat-effect test case.
--   profiles (any): Server-owned in-memory profiles.
--   skills (any): Existing skill purchase service.
-- Returns:
--   nil: Validates hidden gates, six real ranks and save/reload.
local function verify_passive(
    entry: any,
    profiles: any,
    skills: any
)
    local user_id = entry.UserId
    local skill_id = entry.SkillId
    seed_character(profiles, entry)

    local character = assert(profiles:get_character(user_id))
    Runtime.set_character(user_id, character)
    local baseline = Runtime[entry.StatGetter](user_id)

    check(
        not Trainers.can_offer(
            entry.TrainerId, character, skill_id
        ).ok,
        "Unknown passive must be hidden below the first training level."
    )
    check(
        skills:learn_trainer_skill(user_id, skill_id).reason
            == "CharacterLevelTooLow",
        "Direct trainer calls cannot bypass the level gate."
    )
    set_level(profiles, user_id, entry.FirstLevel)
    character = assert(profiles:get_character(user_id))
    check(
        Trainers.can_offer(entry.TrainerId, character, skill_id).ok,
        "The passive must appear at its first training bracket."
    )
    check(
        skills:learn_trainer_skill(user_id, skill_id).ok,
        "First passive rank must be purchased using normal SP."
    )

    for rank = 1, 6 do
        if rank > 1 then
            if rank == 4 then
                check(
                    skills:purchase_rank(user_id, skill_id).reason
                        == "CharacterLevelTooLow",
                    "Second training bracket cannot be skipped."
                )
                set_level(profiles, user_id, entry.SecondLevel)
            end
            local result = skills:purchase_rank(user_id, skill_id)
            check(
                result.ok and result.rank == rank,
                "Purchased rank must require level/SP, not casting."
            )
        end

        character = assert(profiles:get_character(user_id))
        Runtime.set_character(user_id, character)
        local actual = Runtime[entry.StatGetter](user_id)
        check(
            math.abs(actual - baseline - rank * entry.PerRank)
                < 0.00001,
            "Every passive rank must change the real server stat."
        )
        check(
            math.abs(
                Passive[entry.BonusGetter](character)
                    - rank * entry.PerRank
            ) < 0.00001,
            "Only purchased ranks may grant the stat bonus."
        )
    end

    check(
        skills:purchase_rank(user_id, skill_id).reason == "MaxRank",
        "A rank-seven purchase must be rejected."
    )
    check(
        profiles:save(user_id, "C4VitalityRestoration"),
        "All six ranks must save."
    )
    check(
        profiles:release(user_id, "C4VitalityRestoration"),
        "Profile lease must release."
    )
    check(
        profiles:load(user_id) ~= nil,
        "The character must reload without a free rank reset."
    )
    character = assert(profiles:get_character(user_id))
    check(
        character.Progression.Skills[skill_id].PurchasedRank == 6,
        "Six trained ranks must survive save/reload."
    )
    local foreign = table.clone(character)
    foreign.Identity = table.clone(character.Identity)
    foreign.Identity.BaseClassId = "Rogue"
    check(
        Passive[entry.BonusGetter](foreign) == 0,
        "A different class cannot inherit another class's passive."
    )
    Runtime.clear_character(user_id)
end

-- Args:
--   None.
-- Returns:
--   nil: Executes both genuinely new passive gameplay cases.
local function main()
    local profiles = ProfileService.new(Memory.new())
    local skills = Skills.new(
        profiles,
        Inventory.new(profiles),
        Loadout.new(profiles)
    )
    local cases = {
        {
            UserId = 64301,
            ClassId = "Fighter",
            SkillId = "StalwartTraining",
            TrainerId = "FighterTrainer",
            FirstLevel = 5,
            SecondLevel = 10,
            StatGetter = "get_max_health",
            BonusGetter = "health_bonus",
            PerRank = 5,
        },
        {
            UserId = 64302,
            ClassId = "Mage",
            SkillId = "RestorativeTraining",
            TrainerId = "MageTrainer",
            FirstLevel = 7,
            SecondLevel = 14,
            StatGetter = "get_heal_multiplier",
            BonusGetter = "heal_bonus",
            PerRank = 0.012,
        },
    }
    for _, entry in ipairs(cases) do
        verify_passive(entry, profiles, skills)
    end
    print(string.format(
        "[C4 Vitality Restoration Tests] PASS: %d assertions.",
        assertions
    ))
end

main()
