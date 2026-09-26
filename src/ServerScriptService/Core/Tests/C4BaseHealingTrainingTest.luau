--!strict
-- Authentic C4 Mystic trainer purchases for battle heal and life drain.

local SSS = game:GetService("ServerScriptService")
local Core = SSS.Core
local Profiles = require(Core.Services.ProfileService)
local Memory = require(Core.Adapters.InMemoryProfileAdapter)
local Inventory = require(Core.Services.InventoryService)
local Loadout = require(Core.Services.LoadoutService)
local Skills = require(Core.Services.SkillProgressionService)

local HUMAN_ID = 77921
local ELF_ID = 77922
local assertions = 0

--[[
Checks one production trainer purchase or in-memory profile result.

Args:
    condition (boolean): Expected authorized rank or durable save state.
    description (string): Specific diagnostic for failed progression.

Returns:
    nil: Counts a passing check or raises.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Mystic Training] " .. description)
end

--[[
Seeds test-owned level-13 Mage prerequisites via the real profile API.

Args:
    profiles (any): Isolated in-memory production ProfileService.
    user_id (number): Fake authenticated training owner.
    race_id (string): Human or Elf original Mystic race.

Returns:
    nil: Creates a selected Mage with purchased prerequisite ranks.
]]
local function seed_mystic(
    profiles: any,
    user_id: number,
    race_id: string
)
    check(profiles:load(user_id) ~= nil,
        "Isolated Mystic profile failed to load")
    check(profiles:mutate(user_id, function(profile: any)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1,
            RaceId = race_id,
            BaseClassId = "Mage",
            ClassId = "Mage",
            CreationStage = "Complete",
        }
        character.Level = 13
        character.Progression.SkillPointEntitlement = 100
        character.Equipment.Weapon = "apprentice_arcane_wand"
        character.Progression.Skills.MysticWindBolt = {
            Known = true, PurchasedRank = 2, Proficiency = 100,
        }
        character.Progression.Skills.MysticHealingPrayer = {
            Known = true, PurchasedRank = 3, Proficiency = 130,
        }
    end), "Cannot seed bought Mystic training prerequisites")
end

--[[
Advances a single isolated Mage to the source training level.

Args:
    profiles (any): In-memory production profile service.
    user_id (number): Selected character owner.
    level (number): New authoritative character level.

Returns:
    nil: Saves the requested character level.
]]
local function set_level(profiles: any, user_id: number, level: number)
    check(profiles:mutate(user_id, function(profile: any)
        profile.Characters.Slot1.Level = level
    end), "Could not advance the isolated Mystic")
end

--[[
Raises earned use-proficiency through the profile authority to test
later paid ranks without bypassing the actual purchase service.

Args:
    profiles (any): Isolated production profile service.
    user_id (number): Selected character owner.
    skill_id (string): Skill whose prior rank earned proficiency.
    proficiency (number): Legitimately required rank threshold.

Returns:
    nil: Records test-only earned proficiency before real rank purchase.
]]
local function set_proficiency(
    profiles: any,
    user_id: number,
    skill_id: string,
    proficiency: number
)
    check(profiles:mutate(user_id, function(profile: any)
        profile.Characters.Slot1.Progression.Skills[skill_id]
            .Proficiency = proficiency
    end), "Cannot record earned skill proficiency")
end

--[[
Purchases all ranks of one source skill with required earned
proficiency and confirms the final rank survives save/release/reload.

Args:
    profiles (any): In-memory production profile service.
    skills (any): Actual trainer/rank-purchase service.
    user_id (number): Selected character owner.
    skill_id (string): Battle Heal or Human-only Life Drain.
    thresholds ({number}): Earned proficiency for subsequent ranks.

Returns:
    nil: Verifies real authorized purchases and durable maximum rank.
]]
local function buy_all(
    profiles: any,
    skills: any,
    user_id: number,
    skill_id: string,
    thresholds: {number}
)
    local bought = skills:learn_trainer_skill(user_id, skill_id)
    check(bought.ok and bought.rank == 1,
        skill_id .. " rank one failed the legitimate trainer")
    for index, proficiency in ipairs(thresholds) do
        set_proficiency(profiles, user_id, skill_id, proficiency)
        local next_rank = skills:purchase_rank(user_id, skill_id)
        check(next_rank.ok and next_rank.rank == index + 1,
            skill_id .. " failed earned rank " .. tostring(index + 1))
    end
    check(not skills:purchase_rank(user_id, skill_id).ok,
        skill_id .. " sold a nonexistent higher rank")
    check(profiles:save(user_id, "C4MysticTraining"),
        skill_id .. " failed to save")
    check(profiles:release(user_id, "C4MysticTraining"),
        skill_id .. " failed to release")
    check(profiles:load(user_id) ~= nil,
        skill_id .. " saved profile failed to reload")
    local character = assert(profiles:get_character(user_id))
    check(character.Progression.Skills[skill_id].PurchasedRank
        == #thresholds + 1,
        skill_id .. " lost purchased ranks on profile reload")
end

--[[
Runs Human and Elf source-level, race-gated, earned proficiency and
saved-profile trainer acceptance without touching actual player data.

Args:
    None.

Returns:
    nil: Prints the completed production trainer assertion count.
]]
local function main()
    local profiles = Profiles.new(Memory.new())
    local skills = Skills.new(
        profiles, Inventory.new(profiles), Loadout.new(profiles)
    )
    seed_mystic(profiles, HUMAN_ID, "Human")
    seed_mystic(profiles, ELF_ID, "Elf")
    check(not skills:learn_trainer_skill(
        HUMAN_ID, "MysticBattleHeal"
    ).ok, "Battle Heal ignored the C4 level-14 requirement")
    check(not skills:learn_trainer_skill(
        HUMAN_ID, "MysticLifeDrain"
    ).ok, "Life Drain ignored the C4 level-14 requirement")
    set_level(profiles, HUMAN_ID, 14)
    set_level(profiles, ELF_ID, 14)
    check(not skills:learn_trainer_skill(
        ELF_ID, "MysticLifeDrain"
    ).ok, "Elf bought Human-only Mystic Life Drain")

    buy_all(
        profiles, skills, HUMAN_ID, "MysticBattleHeal", {55, 125}
    )
    buy_all(
        profiles, skills, HUMAN_ID, "MysticLifeDrain", {65}
    )
    buy_all(
        profiles, skills, ELF_ID, "MysticBattleHeal", {55, 125}
    )
    print(("[C4 Mystic Training] PASS: %d assertions.")
        :format(assertions))
end

main()
