--!strict
-- Real trainer purchases for first-transfer fifteen-rank combat ladders.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Core = SSS.Core

local Profiles = require(Core.Services.ProfileService)
local Memory = require(Core.Adapters.InMemoryProfileAdapter)
local Inventory = require(Core.Services.InventoryService)
local Loadout = require(Core.Services.LoadoutService)
local SkillService = require(Core.Services.SkillProgressionService)
local Combat = require(RS.Combat.Shared.SkillDefinitions)

local assertions = 0
local LEVELS = {20, 24, 28, 32, 36}

--[[
Counts one actual server-owned trainer or persistence assertion.

Args:
    condition (boolean): Expected operation result.
    description (string): Failure diagnostic.

Returns:
    nil: Records a pass or halts the focused contract.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 First Transfer Training] " .. description)
end

--[[
Creates a detached test character and its mastered starting attack.

Args:
    profiles (any): Isolated production profile service.
    user_id (number): Unique fake character owner.
    class_id (string): Ranger or Rogue.
    basic_id (string): Required basic attack at rank nine.

Returns:
    nil: Commits level-one test identity and earned prerequisite state.
]]
local function seed_character(
    profiles: any, user_id: number, class_id: string,
    basic_id: string
)
    check(profiles:load(user_id) ~= nil, "Cannot load test profile")
    check(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = 1
        character.Identity = {
            Version = 1, RaceId = "Human",
            BaseClassId = class_id, ClassId = class_id,
            CreationStage = "Complete",
        }
        character.Progression.SkillPointEntitlement = 150
        character.Equipment.Weapon = if class_id == "Ranger"
            then "apprentice_longbow"
            else "scout_dagger"
        character.Progression.Skills[basic_id] = {
            Known = true, PurchasedRank = 9, Proficiency = 350,
        }
    end), "Could not seed legitimate first-transfer basics")
end

--[[
Sets only the next character level and earned skill-use proficiency.

Args:
    profiles (any): Authoritative isolated profile service.
    user_id (number): Test character whose rank is advancing.
    skill_id (string): Already learned active skill.
    level (number): Server-owned level reached by the character.
    proficiency (number): Earned use proficiency for next rank.

Returns:
    nil: Mutates only the detached test profile.
]]
local function set_progress(
    profiles: any, user_id: number, skill_id: string,
    level: number, proficiency: number
)
    check(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Level = level
        local learned = character.Progression.Skills[skill_id]
        if learned then
            learned.Proficiency = proficiency
        end
    end), "Could not update test level and earned proficiency")
end

--[[
Buys all fifteen ranks with genuine class, level and mastery gates.

Args:
    profiles (any): Isolated durable character service.
    skills (any): Production skill training service.
    user_id (number): Fake character owner.
    skill_id (string): Ranger or Rogue first-transfer combat skill.

Returns:
    nil: Confirms all fifteen purchases and saved final rank.
]]
local function test_ladder(
    profiles: any, skills: any, user_id: number, skill_id: string
)
    check(not skills:learn_trainer_skill(user_id, skill_id).ok,
        skill_id .. " cannot be bought before level twenty")
    set_progress(profiles, user_id, skill_id, 20, 0)
    check(skills:learn_trainer_skill(user_id, skill_id).rank == 1,
        skill_id .. " earned rank one must be trainable")
    for rank = 2, 15 do
        local level = LEVELS[math.ceil(rank / 3)]
        set_progress(profiles, user_id, skill_id, level - 1, 560)
        check(skills:purchase_rank(user_id, skill_id).reason
            == "CharacterLevelTooLow",
            skill_id .. " rank " .. rank .. " skipped character level")
        set_progress(profiles, user_id, skill_id, level, (rank - 1) * 40 - 1)
        check(skills:purchase_rank(user_id, skill_id).reason
            == "ProficiencyThresholdNotMet",
            skill_id .. " rank " .. rank .. " skipped skill mastery")
        set_progress(profiles, user_id, skill_id, level, (rank - 1) * 40)
        check(skills:purchase_rank(user_id, skill_id).rank == rank,
            skill_id .. " rank " .. rank .. " was not bought")
    end
    check(skills:purchase_rank(user_id, skill_id).reason == "MaxRank",
        skill_id .. " accepted a nonexistent sixteenth rank")
    check(Combat.get_for_rank(skill_id, 15).BASE_DAMAGE
        > Combat.get_for_rank(skill_id, 1).BASE_DAMAGE,
        "Final rank lacks a real stronger combat effect")
    check(profiles:save(user_id, "C4FirstTransferTraining"),
        skill_id .. " rank fifteen failed to save")
    check(profiles:release(user_id, "C4FirstTransferTraining"),
        skill_id .. " character failed to release")
    check(profiles:load(user_id) ~= nil,
        skill_id .. " saved character failed to reload")
    check(profiles:get_character(user_id).Progression.Skills
        [skill_id].PurchasedRank == 15,
        skill_id .. " lost its purchased rank on reload")
end

--[[
Exercises the same server-owned training flow for both weapon careers.

Args:
    None.

Returns:
    nil: Emits a focused count only when both rank ladders persist.
]]
local function main()
    local profiles = Profiles.new(Memory.new())
    local skills = SkillService.new(
        profiles, Inventory.new(profiles), Loadout.new(profiles)
    )
    seed_character(profiles, 68541, "Ranger", "ArcherDraw")
    seed_character(profiles, 68542, "Rogue", "RogueVitalBlow")
    test_ladder(profiles, skills, 68541, "ScoutFocusedShot")
    test_ladder(profiles, skills, 68542, "RogueFinishingCut")
    check(not skills:learn_trainer_skill(
        68541, "RogueFinishingCut"
    ).ok, "Ranger must not learn Rogue's first-transfer attack")
    check(not skills:learn_trainer_skill(
        68542, "ScoutFocusedShot"
    ).ok, "Rogue must not learn Ranger's first-transfer attack")
    print(("[C4 First Transfer Training] PASS: %d assertions.")
        :format(assertions))
end

main()
