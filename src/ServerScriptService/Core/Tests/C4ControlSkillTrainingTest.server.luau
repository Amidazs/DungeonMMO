--!strict
-- Trainer purchase, rank prerequisites and persistence for new control skills.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local core = SSS.Core
local shared = RS.Core.Shared
local Profiles = require(core.Services.ProfileService)
local Memory = require(core.Adapters.InMemoryProfileAdapter)
local Inventory = require(core.Services.InventoryService)
local Loadout = require(core.Services.LoadoutService)
local SkillService = require(core.Services.SkillProgressionService)
local Snapshots = require(core.Services.ProgressionSnapshotBuilder)
local Combat = require(RS.Combat.Shared.SkillDefinitions)

local assertions = 0

--[[
Checks an expected result from the production progression services.

Args:
    condition (boolean): Expected server-owned progression condition.
    description (string): Actionable failure explanation.

Returns:
    nil: Counts one passing assertion or raises a focused failure.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Control Training] " .. description)
end

--[[
Creates a complete isolated level-one character with sufficient earned SP.

Args:
    profiles (any): Independent in-memory profile service.
    user_id (number): Test-only character ID.
    class_id (string): Allowed or deliberately foreign base class.

Returns:
    nil: Commits only the isolated test character's starting identity.
]]
local function seed_character(profiles: any, user_id: number, class_id: string)
    check(profiles:load(user_id) ~= nil, "Test profile failed to load")
    check(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 1
        character.Identity = {
            Version = 1, RaceId = "Human",
            BaseClassId = class_id, ClassId = class_id,
            CreationStage = "Complete",
        }
        character.Progression.SkillPointEntitlement = 100
    end), "Test identity or earned SP did not persist")
end

--[[
Updates level and use-earned proficiency inside the trusted fixture store.

Args:
    profiles (any): Authoritative test profile service.
    user_id (number): Test-only character ID.
    skill_id (string): Already purchased skill.
    level (number): New character training level.
    proficiency (number): Test-seeded server-owned proficiency.

Returns:
    nil: Stores the next legitimate rank-training conditions.
]]
local function set_training(
    profiles: any,
    user_id: number,
    skill_id: string,
    level: number,
    proficiency: number
)
    check(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = level
        local state = character.Progression.Skills[skill_id]
        if state then
            state.Proficiency = proficiency
        end
    end), "Level or earned proficiency update failed")
end

--[[
Verifies real purchases reject early/unearned ranks and survive save/reload.

Args:
    profiles (any): Isolated durable profile service.
    skills (any): Real server-authoritative learning service.
    user_id (number): Test-only character ID.
    skill_id (string): Ranger or Rogue three-rank control ability.

Returns:
    nil: Checks the full rank 1/2/3 ladder and durability.
]]
local function verify_skill(profiles: any, skills: any, user_id: number,
    skill_id: string)
    local character = assert(profiles:get_character(user_id))
    check(Snapshots.build(character).Skills[skill_id] == nil,
        "Level-one player must not see " .. skill_id)
    check(not skills:learn_trainer_skill(user_id, skill_id).ok,
        "Level-one trainer must reject " .. skill_id)
    set_training(profiles, user_id, skill_id, 5, 0)
    check(skills:learn_trainer_skill(user_id, skill_id).ok,
        "Correct class/level must learn " .. skill_id)
    check(skills:purchase_rank(user_id, skill_id).reason
        == "CharacterLevelTooLow",
        "Rank two cannot skip level ten")
    set_training(profiles, user_id, skill_id, 10, 39)
    check(skills:purchase_rank(user_id, skill_id).reason
        == "ProficiencyThresholdNotMet",
        "Rank two cannot skip earned proficiency 40")
    set_training(profiles, user_id, skill_id, 10, 40)
    check(skills:purchase_rank(user_id, skill_id).rank == 2,
        "Level ten/mastery 40 must buy rank two")
    check(skills:purchase_rank(user_id, skill_id).reason
        == "CharacterLevelTooLow",
        "Rank three must wait until level fifteen")
    set_training(profiles, user_id, skill_id, 15, 109)
    check(skills:purchase_rank(user_id, skill_id).reason
        == "ProficiencyThresholdNotMet",
        "Rank three cannot skip earned proficiency 110")
    set_training(profiles, user_id, skill_id, 15, 110)
    check(skills:purchase_rank(user_id, skill_id).rank == 3,
        "Level fifteen/mastery 110 must buy rank three")
    check(skills:purchase_rank(user_id, skill_id).reason == "MaxRank",
        "Rank four must remain unavailable")
    check(Combat.get_for_rank(skill_id, 3) ~= nil,
        "Final purchased rank must resolve real combat effects")
    check(profiles:save(user_id, "C4ControlTraining"),
        "Trained rank must save")
    check(profiles:release(user_id, "C4ControlTraining"),
        "Trained rank must release")
    check(profiles:load(user_id) ~= nil,
        "Trained character must reload")
    check(profiles:get_character(user_id).Progression.Skills
        [skill_id].PurchasedRank == 3,
        "Reload lost the final earned skill rank")
end

--[[
Runs two isolated class-specific learning ladders and a foreign-class denial.

Args:
    None.

Returns:
    nil: Reports focused server purchase and persistence assertions.
]]
local function main()
    local profiles = Profiles.new(Memory.new())
    local skills = SkillService.new(
        profiles, Inventory.new(profiles), Loadout.new(profiles)
    )
    seed_character(profiles, 68511, "Ranger")
    seed_character(profiles, 68512, "Rogue")
    verify_skill(profiles, skills, 68511, "BriarVolley")
    verify_skill(profiles, skills, 68512, "DisruptingCut")
    check(
        not skills:learn_trainer_skill(68511, "DisruptingCut").ok,
        "Ranger cannot learn Rogue control skill"
    )
    check(
        not skills:learn_trainer_skill(68512, "BriarVolley").ok,
        "Rogue cannot learn Ranger control skill"
    )
    print(("[C4 Control Training] PASS: %d assertions."):format(
        assertions
    ))
end

main()
