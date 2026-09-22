--!strict
-- C4 Mage first-tier physical, magical, and worn-robe mastery contracts.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared

local Schema = require(Shared.ProfileSchema)
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Passive = require(Shared.PassiveSkillEffects)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)

local LEVELS = {
    MysticWeaponTraining = {7, 14},
    MysticArmorTraining = {7, 14, 14},
    MysticSpellResistance = {7, 7, 14, 14},
}
local assertions = 0

--[[
Asserts a rank or real-effect property of the authoritative Mage state.

Args:
    condition (boolean): Requirement established by the isolated test.
    description (string): Useful diagnostic if the check is false.

Returns:
    nil: Counts a passing check or stops on failure.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Base Mystic Passives] " .. description)
end

--[[
Creates a detached Mage with valid starting wand and robe equipment.

Args:
    user_id (number): Isolated runtime character ID.
    race_id (string): Human or Elf source Mystic.

Returns:
    any: Complete mutable Mage profile for focused testing.
]]
local function make_mage(user_id: number, race_id: string): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = "Mage"
    character.Identity.ClassId = "Mage"
    character.Identity.CreationStage = "Complete"
    character.Level = 14
    character.Equipment.Weapon = "apprentice_arcane_wand"
    character.Equipment.Body = "apprentice_mystic_robe"
    return character
end

--[[
Checks all source-level ranks, including repeated ranks in one bracket.

Args:
    character (any): Authoritative Mage test profile.
    skill_id (string): One of the three learned mastery families.

Returns:
    nil: Verifies full rank count, level gates and trainer authorization.
]]
local function check_ladder(character: any, skill_id: string)
    local definition = assert(Skills.get(skill_id))
    local levels = LEVELS[skill_id]
    check(definition.MaxRank == #levels,
        skill_id .. " has an invalid source rank count")
    character.Level = 6
    check(not Unlocks.can_show(character, definition),
        skill_id .. " appeared before level seven")
    character.Level = 7
    check(Trainers.can_offer(
        "MageTrainer", character, skill_id
    ).ok, skill_id .. " unavailable at the Mage trainer")
    for rank, level in ipairs(levels) do
        character.Level = level - 1
        check(not Unlocks.can_train(character, definition, rank),
            skill_id .. " rank bypasses its level")
        character.Level = level
        check(Unlocks.can_train(character, definition, rank),
            skill_id .. " rank is blocked at its C4 level")
        check(definition.RankLevels[rank] == level,
            skill_id .. " rank has incorrect authored level")
    end
end

--[[
Verifies the real, independent Mystic weapon and defence multipliers.

Args:
    character (any): Mage with owned wand and robe.
    user_id (number): Isolated server runtime identity.

Returns:
    nil: Confirms purchased ranks affect actual server combat stats.
]]
local function check_effects(character: any, user_id: number)
    character.Level = 14
    Runtime.set_character(user_id, character)
    local physical = Runtime.get_physical_multiplier(user_id)
    local magical = Runtime.get_magical_multiplier(user_id)
    check(Runtime.get_mystic_armor_reduction(user_id) == 0,
        "Untrained Mage robe must not gain passive armour")
    check(Runtime.get_mystic_magic_reduction(user_id) == 0,
        "Untrained Mage must not gain free spell resistance")

    character.Progression.Skills.MysticWeaponTraining = {
        Known = true, PurchasedRank = 2, Proficiency = 0,
    }
    character.Progression.Skills.MysticArmorTraining = {
        Known = true, PurchasedRank = 3, Proficiency = 0,
    }
    character.Progression.Skills.MysticSpellResistance = {
        Known = true, PurchasedRank = 4, Proficiency = 0,
    }
    Runtime.set_character(user_id, character)
    check(math.abs(
        Runtime.get_physical_multiplier(user_id) - physical - 0.04
    ) < 0.0001, "Mystic attack mastery did not improve physical damage")
    check(math.abs(
        Runtime.get_magical_multiplier(user_id) - magical - 0.04
    ) < 0.0001, "Mystic attack mastery did not improve magic damage")
    check(math.abs(
        Runtime.get_mystic_armor_reduction(user_id) - 0.024
    ) < 0.0001, "Three robe ranks did not mitigate physical damage")
    check(math.abs(
        Runtime.get_mystic_magic_reduction(user_id) - 0.06
    ) < 0.0001, "Four anti-magic ranks did not mitigate magic damage")

    character.Equipment.Body = nil
    Runtime.set_character(user_id, character)
    check(Runtime.get_mystic_armor_reduction(user_id) == 0,
        "Unequipping the robe must cancel physical mastery")
    check(math.abs(
        Runtime.get_mystic_magic_reduction(user_id) - 0.06
    ) < 0.0001, "Spell resistance must not depend on worn Body")
    character.Equipment.Body = "marauder_armor"
    Runtime.set_character(user_id, character)
    check(Runtime.get_mystic_armor_reduction(user_id) == 0,
        "Heavy armour cannot activate the Mystic robe skill")
    character.Identity.BaseClassId = "Fighter"
    Runtime.set_character(user_id, character)
    check(Passive.mystic_magic_reduction(character) == 0,
        "Foreign-class saved Mystic rank cannot confer spell resistance")
    Runtime.clear_character(user_id)
end

--[[
Exercises each C4 source family for both Human and Elven Mystics.

Args:
    None.

Returns:
    nil: Prints the successful rank and actual-effect assertion count.
]]
local function main()
    for index, race_id in ipairs({"Human", "Elf"}) do
        local user_id = 77690 + index
        local character = make_mage(user_id, race_id)
        for skill_id in pairs(LEVELS) do
            check_ladder(character, skill_id)
        end
        check_effects(character, user_id)
    end
    print(("[C4 Base Mystic Passives] PASS: %d assertions.")
        :format(assertions))
end

main()
