--!strict
-- Focused early Mage combat content and hidden/locked trainer ranks.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local shared = RS.Core.Shared
local core = SSS.Core

local ProfileService = require(core.Services.ProfileService)
local Memory = require(core.Adapters.InMemoryProfileAdapter)
local Inventory = require(core.Services.InventoryService)
local Loadout = require(core.Services.LoadoutService)
local Skills = require(core.Services.SkillProgressionService)
local Snapshot = require(core.Services.ProgressionSnapshotBuilder)
local Trainers = require(shared.TrainerCatalogues)
local CombatSkills = require(RS.Combat.Shared.SkillDefinitions)

local assertions = 0

-- Args:
--   condition (boolean): Expected server-owned progression invariant.
--   message (string): Failure explanation for the focused regression.
-- Returns:
--   nil: Counts the assertion or raises.
local function check(condition: boolean, message: string)
    assertions += 1
    assert(condition, "[C4 Starter Mage Tests] " .. message)
end

-- Args:
--   profiles (any): Isolated authoritative profile service.
--   user_id (number): Independent test Mage identity.
-- Returns:
--   nil: Seeds a level-one character with unspent skill points.
local function seed_mage(profiles: any, user_id: number)
    check(profiles:load(user_id) ~= nil, "Profile must load.")
    check(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 1
        character.Identity = {
            Version = 1,
            RaceId = "Human",
            BaseClassId = "Mage",
            ClassId = "Mage",
            CreationStage = "Complete",
        }
        character.Progression.SkillPointEntitlement = 30
    end), "The Mage and training budget must persist.")
end

-- Args:
--   profiles (any): Profile service that owns the test character.
--   user_id (number): Authenticated fixture character.
--   skill_id (string): Learned active skill to advance.
--   level (number): Next actual training level.
--   proficiency (number): Trusted-use proficiency seeded by this test.
-- Returns:
--   nil: Persists the new level/proficiency without awarding a rank.
local function seed_training(
    profiles: any,
    user_id: number,
    skill_id: string,
    level: number,
    proficiency: number
)
    check(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = level
        character.Progression.Skills[skill_id].Proficiency =
            proficiency
    end), "Only the profile service may advance level and proficiency.")
end

-- Args:
--   skills (any): Production skill learning and rank purchase service.
--   profiles (any): Isolated character store.
--   user_id (number): Test Mage identity.
--   skill_id (string): DawnWard or CinderBolt.
-- Returns:
--   nil: Checks rank-one gate, mastered level-seven/two and level-14/three.
local function verify_rank_ladder(
    skills: any,
    profiles: any,
    user_id: number,
    skill_id: string
)
    check(skills:learn_trainer_skill(user_id, skill_id).ok,
        "Level one must unlock the first actual Mage ability rank.")
    local character = assert(profiles:get_character(user_id))
    local state = Snapshot.build(character).Skills[skill_id]
    check(state.Known and state.Rank == 1
        and not state.NextRankUnlocked
        and state.NextRequiredLevel == 7,
        "Known skills stay visible, but their next rank is level-gated.")
    check(
        skills:purchase_rank(user_id, skill_id).reason
            == "CharacterLevelTooLow",
        "Direct rank purchases cannot bypass character level."
    )

    seed_training(profiles, user_id, skill_id, 7, 0)
    check(
        skills:purchase_rank(user_id, skill_id).reason
            == "ProficiencyThresholdNotMet",
        "Level seven alone cannot bypass earned skill proficiency."
    )
    seed_training(profiles, user_id, skill_id, 7, 35)
    check(skills:purchase_rank(user_id, skill_id).rank == 2,
        "Level seven and proficiency 35 unlock rank two.")
    check(
        skills:purchase_rank(user_id, skill_id).reason
            == "CharacterLevelTooLow",
        "Rank three remains locked below level fourteen."
    )
    seed_training(profiles, user_id, skill_id, 14, 100)
    check(skills:purchase_rank(user_id, skill_id).rank == 3,
        "Level fourteen and proficiency 100 unlock final rank.")
    check(skills:purchase_rank(user_id, skill_id).reason == "MaxRank",
        "No fourth rank can be purchased.")
end

-- Args:
--   profiles (any): Independent Mage profile store.
--   user_id (number): Test character.
-- Returns:
--   nil: Verifies the skill catalogue is filtered for that character.
local function verify_visibility(profiles: any, user_id: number)
    local character = assert(profiles:get_character(user_id))
    local first = Snapshot.build(character)
    check(
        first.Skills.DawnWard ~= nil
            and first.Skills.CinderBolt ~= nil
            and first.Skills.AetherBolt == nil,
        "Only eligible level-one skills appear in the player catalogue."
    )
    local trainer = Trainers.resolve_for_character(
        "MageTrainer", character
    )
    local offered = {}
    for _, entry in ipairs(trainer.Skills) do
        offered[entry.SkillId] = true
    end
    check(offered.DawnWard and offered.CinderBolt
        and not offered.AetherBolt,
        "The Mage trainer must hide unknown level-seven skills.")
    check(
        Trainers.can_offer(
            "FighterTrainer", character, "DawnWard"
        ).ok == false,
        "Another base class cannot offer the Mage ability."
    )
end

-- Args: None.
-- Returns:
--   nil: Runs focused skill progression and effect compatibility.
local function main()
    local profiles = ProfileService.new(Memory.new())
    local skills = Skills.new(
        profiles, Inventory.new(profiles), Loadout.new(profiles)
    )
    seed_mage(profiles, 68501)
    seed_mage(profiles, 68502)
    verify_visibility(profiles, 68501)

    for _, entry in ipairs({
        {UserId = 68501, SkillId = "DawnWard", Field = "WARD_AMOUNT",
            Kind = "Ward", Values = {14, 21, 29}},
        {UserId = 68502, SkillId = "CinderBolt",
            Field = "BASE_DAMAGE", Kind = "MagicProjectile",
            Values = {12, 18, 25}},
    }) do
        verify_rank_ladder(
            skills, profiles, entry.UserId, entry.SkillId
        )
        for rank, expected in ipairs(entry.Values) do
            local definition = CombatSkills.get_for_rank(
                entry.SkillId, rank
            )
            check(
                definition.KIND == entry.Kind
                    and definition[entry.Field] == expected,
                "Every ranked skill must have a real defence/damage effect."
            )
        end
    end

    check(profiles:save(68501, "C4StarterMage"),
        "Dawn Ward rank must be durable.")
    check(profiles:release(68501, "C4StarterMage"),
        "Dawn Ward character must release its profile.")
    check(profiles:load(68501) ~= nil,
        "Dawn Ward must reload from persistent test storage.")
    check(
        profiles:get_character(68501).Progression.Skills
            .DawnWard.PurchasedRank == 3,
        "Reloading cannot refund a paid rank or lose a learned spell."
    )
    print(string.format(
        "[C4 Starter Mage Tests] PASS: %d assertions.", assertions
    ))
end

main()
