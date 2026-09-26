--!strict
-- Real saved-profile purchases for the race-specific C4 scout crit ranks.

local SSS = game:GetService("ServerScriptService")
local Core = SSS.Core
local Profiles = require(Core.Services.ProfileService)
local Memory = require(Core.Adapters.InMemoryProfileAdapter)
local Inventory = require(Core.Services.InventoryService)
local Loadout = require(Core.Services.LoadoutService)
local Skills = require(Core.Services.SkillProgressionService)

local HUMAN_ID = 68671
local ELF_ID = 68672
local assertions = 0

--[[
Checks one authoritative training or profile-persistence condition.

Args:
    condition (boolean): Whether the service behaved as expected.
    description (string): Diagnostic if the requirement failed.

Returns:
    nil: Counts a successful check or stops the focused test.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Scout Critical Training] " .. description)
end

--[[
Creates an isolated completed character with owned training points.

Args:
    profiles (any): Test-only production profile service.
    user_id (number): Fake persistent owner ID.
    race_id (string): Human or Elf.
    class_id (string): Ranger or Rogue.

Returns:
    nil: Stores a race/class-specific test character.
]]
local function seed_character(
    profiles: any, user_id: number, race_id: string, class_id: string
)
    check(profiles:load(user_id) ~= nil, "Test profile did not load")
    check(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1,
            RaceId = race_id,
            BaseClassId = class_id,
            ClassId = class_id,
            CreationStage = "Complete",
        }
        character.Level = 1
        character.Progression.SkillPointEntitlement = 30
    end), "Failed to seed isolated critical-training character")
end

--[[
Updates only a detached test character's training level.

Args:
    profiles (any): Isolated profile service.
    user_id (number): Fake character ID to progress.
    level (number): Authoritative level for the next purchase attempt.

Returns:
    nil: Saves the new level in test-profile state.
]]
local function set_level(
    profiles: any, user_id: number, level: number
)
    check(profiles:mutate(user_id, function(profile: any)
        profile.Characters.Slot1.Level = level
    end), "Cannot set test character's training level")
end

--[[
Checks source-level denial, purchase and durable rank-one persistence.

Args:
    profiles (any): Isolated persistent profile service.
    skills (any): Production trainer and skill-purchase service.
    user_id (number): Fake character owner.
    skill_id (string): Human/Elf race-specific Scout passive.
    level (number): C4 source training level.

Returns:
    nil: Proves actual purchased rank survives save/release/reload.
]]
local function check_single_rank(
    profiles: any, skills: any, user_id: number,
    skill_id: string, level: number
)
    set_level(profiles, user_id, level - 1)
    check(not skills:learn_trainer_skill(user_id, skill_id).ok,
        skill_id .. " cannot be bought below its C4 level")
    set_level(profiles, user_id, level)
    check(skills:learn_trainer_skill(user_id, skill_id).rank == 1,
        skill_id .. " should be sold by the authorized trainer")
    check(skills:purchase_rank(user_id, skill_id).reason == "MaxRank",
        skill_id .. " must not sell a nonexistent second rank")
    check(profiles:save(user_id, "C4ScoutPrecision"),
        skill_id .. " rank failed to save")
    check(profiles:release(user_id, "C4ScoutPrecision"),
        skill_id .. " profile release failed")
    check(profiles:load(user_id) ~= nil,
        skill_id .. " saved character failed to reload")
    local character = assert(profiles:get_character(user_id))
    check(character.Progression.Skills[skill_id].PurchasedRank == 1,
        skill_id .. " rank was lost after reload")
end

--[[
Runs actual race, level, purchase and save/reload acceptance.

Args:
    None.

Returns:
    nil: Emits a focused assertion count only after all purchases pass.
]]
local function main()
    local profiles = Profiles.new(Memory.new())
    local skills = Skills.new(
        profiles, Inventory.new(profiles), Loadout.new(profiles)
    )
    seed_character(profiles, HUMAN_ID, "Human", "Ranger")
    seed_character(profiles, ELF_ID, "Elf", "Rogue")

    set_level(profiles, HUMAN_ID, 36)
    set_level(profiles, ELF_ID, 36)
    check(not skills:learn_trainer_skill(
        HUMAN_ID, "ElvenScoutPrecision"
    ).ok, "Human must not learn the Elf precision skill")
    check(not skills:learn_trainer_skill(
        ELF_ID, "HumanScoutPrecision"
    ).ok, "Elf must not learn Human precision")
    check(not skills:learn_trainer_skill(
        ELF_ID, "HumanScoutCriticalPower"
    ).ok, "Elf must not buy the Human critical-power skill")

    set_level(profiles, HUMAN_ID, 23)
    check(not skills:learn_trainer_skill(
        HUMAN_ID, "HumanScoutCriticalPower"
    ).ok, "Human critical power cannot be bought below 24")
    set_level(profiles, HUMAN_ID, 24)
    check(skills:learn_trainer_skill(
        HUMAN_ID, "HumanScoutCriticalPower"
    ).rank == 1, "Human level-24 critical power did not train")
    check(skills:purchase_rank(
        HUMAN_ID, "HumanScoutCriticalPower"
    ).reason == "CharacterLevelTooLow",
        "Human critical-power rank two ignored the level-32 gate")
    set_level(profiles, HUMAN_ID, 32)
    check(skills:purchase_rank(
        HUMAN_ID, "HumanScoutCriticalPower"
    ).rank == 2, "Level-32 Human must buy critical-power rank two")
    check(profiles:save(HUMAN_ID, "C4HumanCriticalPower"),
        "Human critical-power rank two did not save")
    check(profiles:release(HUMAN_ID, "C4HumanCriticalPower"),
        "Human critical-power profile release failed")
    check(profiles:load(HUMAN_ID) ~= nil,
        "Human critical-power profile reload failed")
    check(profiles:get_character(HUMAN_ID).Progression.Skills
        .HumanScoutCriticalPower.PurchasedRank == 2,
        "Human critical-power rank two was lost after reload")

    check_single_rank(
        profiles, skills, HUMAN_ID, "HumanScoutPrecision", 28
    )
    check_single_rank(
        profiles, skills, ELF_ID, "ElvenScoutPrecision", 32
    )
    print(("[C4 Scout Critical Training] PASS: %d assertions.")
        :format(assertions))
end

main()
