--!strict
-- C4 first-tier Human/Elven Mystic wind and healing rank contracts.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared

local Schema = require(Shared.ProfileSchema)
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)

local assertions = 0
local WIND_LEVELS = {7, 7, 14, 14}
local HEAL_LEVELS = {7, 7, 7, 14, 14, 14}

--[[
Asserts one source-level training gate or actual combat effect.

Args:
    condition (boolean): Expected server-owned skill behaviour.
    description (string): Failure diagnostic.

Returns:
    nil: Records a pass or stops on a regression.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Base Mystic Ranks] " .. description)
end

--[[
Creates a complete test character with its legitimate starter skill.

Args:
    user_id (number): Isolated server runtime identity.
    race_id (string): Human or Elf Mystic.
    starter_id (string): Rank-one prerequisite learned at level one.

Returns:
    any: Mutable detached Mage progression character.
]]
local function make_mystic(
    user_id: number, race_id: string, starter_id: string
): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = "Mage"
    character.Identity.ClassId = "Mage"
    character.Identity.CreationStage = "Complete"
    character.Equipment.Weapon = "apprentice_arcane_wand"
    character.Progression.Skills[starter_id] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    return character
end

--[[
Verifies all wind/healing ranks use authentic level bands and real
increasing server-resolved projectile/heal magnitudes.

Args:
    skill_id (string): MysticWindBolt or MysticHealingPrayer.
    starter_id (string): Authored learned starter prerequisite.
    levels ({number}): Exact source bands, one per rank.
    race_id (string): Human or Elf.
    user_id (number): Isolated runtime owner.

Returns:
    nil: Verifies the full rank ladder, trainer and weapon restrictions.
]]
local function check_family(
    skill_id: string, starter_id: string, levels: {number},
    race_id: string, user_id: number
)
    local definition = assert(Skills.get(skill_id))
    local character = make_mystic(user_id, race_id, starter_id)
    check(definition.MaxRank == #levels,
        skill_id .. " has the wrong number of source ranks")
    character.Level = 6
    check(not Unlocks.can_show(character, definition),
        skill_id .. " appeared before level seven")
    character.Level = 7
    check(Unlocks.can_show(character, definition),
        skill_id .. " was hidden at its first source level")
    local previous_magnitude = 0
    for rank, level in ipairs(levels) do
        character.Level = level - 1
        check(not Unlocks.can_train(character, definition, rank),
            skill_id .. " rank bypassed the source-level gate")
        character.Level = level
        check(Unlocks.can_train(character, definition, rank),
            skill_id .. " rank was locked at source level")
        check(definition.RankLevels[rank] == level,
            skill_id .. " has a mismatched rank training bracket")
        local effect = assert(Combat.get_for_rank(skill_id, rank))
        local magnitude = if skill_id == "MysticWindBolt"
            then effect.BASE_DAMAGE else effect.TOTAL_HEAL
        check(magnitude > previous_magnitude and effect.MANA_COST > 0,
            skill_id .. " rank lacks a genuine increasing effect")
        previous_magnitude = magnitude
    end
    character.Level = 14
    check(Trainers.can_offer(
        "MageTrainer", character, skill_id
    ).ok, skill_id .. " missing from eligible Mystic trainer")
    character.Progression.Skills[skill_id] = {
        Known = true,
        PurchasedRank = #levels,
        Proficiency = 300,
    }
    character.Progression.Loadout[1] = skill_id
    Runtime.set_character(user_id, character)
    local usable, reason = Runtime.is_skill_usable(user_id, skill_id)
    check(usable, skill_id .. " unusable: " .. tostring(reason))
    character.Equipment.Weapon = nil
    Runtime.set_character(user_id, character)
    check(not Runtime.is_skill_usable(user_id, skill_id),
        skill_id .. " may not ignore owned wand requirements")
    Runtime.clear_character(user_id)
end

check_family(
    "MysticWindBolt", "WindStrike", WIND_LEVELS, "Human", 77661
)
check_family(
    "MysticHealingPrayer", "MageHeal", HEAL_LEVELS, "Elf", 77662
)

print(("[C4 Base Mystic Ranks] PASS: %d assertions.")
    :format(assertions))
