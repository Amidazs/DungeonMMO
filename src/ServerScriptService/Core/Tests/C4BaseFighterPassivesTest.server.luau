--!strict
-- Real physical output and worn-armour effects for the C4 base Fighter.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared

local Schema = require(Shared.ProfileSchema)
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Passive = require(Shared.PassiveSkillEffects)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)

local assertions = 0
local DAMAGE_LEVELS = {5, 10, 15}
local ARMOR_LEVELS = {5, 10, 10, 15, 15}

--[[
Checks one real rank, owned-equipment, or combat-stat expectation.

Args:
    condition (boolean): Whether the authoritative condition holds.
    description (string): Test failure diagnostic.

Returns:
    nil: Increments successful assertion count or stops execution.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Base Fighter Passives] " .. description)
end

--[[
Creates a fully owned base Fighter with legal equipped armour.

Args:
    user_id (number): Isolated runtime owner of the character.
    race_id (string): Human or Elf starting Fighter race.

Returns:
    any: Detached server-style Fighter character.
]]
local function make_fighter(user_id: number, race_id: string): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = "Fighter"
    character.Identity.ClassId = "Fighter"
    character.Identity.CreationStage = "Complete"
    character.Level = 15
    character.Equipment.Weapon = "marauder_sword"
    character.Equipment.Body = "marauder_armor"
    return character
end

--[[
Verifies the complete per-level C4 passive rank ladder for both races.

Args:
    character (any): Current server-owned Fighter.
    skill_id (string): Physical attack or armour mastery skill.
    levels ({number}): One source level per purchased rank.

Returns:
    nil: Verifies visibility, trainer permission and every source band.
]]
local function check_ladder(
    character: any, skill_id: string, levels: {number}
)
    local definition = assert(Skills.get(skill_id))
    check(definition.MaxRank == #levels,
        skill_id .. " has an incorrect rank count")
    character.Level = 4
    check(not Unlocks.can_show(character, definition),
        skill_id .. " appeared before the level-five source band")
    character.Level = 5
    check(Trainers.can_offer(
        "FighterTrainer", character, skill_id
    ).ok, skill_id .. " absent from the Fighter trainer")
    for rank, level in ipairs(levels) do
        character.Level = level - 1
        check(not Unlocks.can_train(character, definition, rank),
            skill_id .. " rank bypassed its level requirement")
        character.Level = level
        check(Unlocks.can_train(character, definition, rank),
            skill_id .. " rank locked at the required level")
        check(definition.RankLevels[rank] == level,
            skill_id .. " rank has the wrong source bracket")
    end
end

--[[
Tests that both trained passives change actual authoritative combat stats.

Args:
    character (any): Human/Elf Fighter with legal starter body armour.
    user_id (number): Isolated runtime identity.

Returns:
    nil: Proves owned damage ranks and worn armour mitigation.
]]
local function check_effects(character: any, user_id: number)
    character.Level = 15
    Runtime.set_character(user_id, character)
    local baseline_damage = Runtime.get_physical_multiplier(user_id)
    check(Runtime.get_fighter_armor_reduction(user_id) == 0,
        "Untrained Fighter must have no rank-based armour reduction")
    character.Progression.Skills.FighterPhysicalTraining = {
        Known = true, PurchasedRank = 3, Proficiency = 0,
    }
    character.Progression.Skills.FighterArmorTraining = {
        Known = true, PurchasedRank = 5, Proficiency = 0,
    }
    Runtime.set_character(user_id, character)
    check(math.abs(
        Runtime.get_physical_multiplier(user_id)
            - baseline_damage - 0.06
    ) < 0.0001, "Three bought Fighter mastery ranks add no damage")
    check(math.abs(
        Runtime.get_fighter_armor_reduction(user_id) - 0.035
    ) < 0.0001, "Five Fighter armour ranks need 3.5% physical reduction")
    character.Equipment.Body = nil
    Runtime.set_character(user_id, character)
    check(Runtime.get_fighter_armor_reduction(user_id) == 0,
        "Unequipped Fighter cannot keep armour mastery")
    character.Equipment.Body = "scout_leather_vest"
    Runtime.set_character(user_id, character)
    check(math.abs(
        Runtime.get_fighter_armor_reduction(user_id) - 0.035
    ) < 0.0001, "Source armour mastery must support real light Body gear")
    character.Identity.BaseClassId = "Mage"
    Runtime.set_character(user_id, character)
    check(Passive.fighter_armor_reduction(character) == 0,
        "Forged Fighter armour rank must not improve Mage defense")
    Runtime.clear_character(user_id)
end

local human = make_fighter(77681, "Human")
local elf = make_fighter(77682, "Elf")
for _, character in ipairs({human, elf}) do
    check_ladder(
        character, "FighterPhysicalTraining", DAMAGE_LEVELS
    )
    check_ladder(character, "FighterArmorTraining", ARMOR_LEVELS)
end
check_effects(human, 77681)
check_effects(elf, 77682)

print(("[C4 Base Fighter Passives] PASS: %d assertions.")
    :format(assertions))
