--!strict
-- C4 level-one Mystic robe passives: true mana and attack timing effects.

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
local SKILLS = {
    "MysticRobeManaRecovery",
    "MysticRobeAttackSpeed",
}

--[[
Checks a bought skill, equipped robe or real runtime-stat condition.

Args:
    condition (boolean): Expected progression or server-stat invariant.
    description (string): Diagnostic on contract failure.

Returns:
    nil: Records one passing check or raises.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Base Robe] " .. description)
end

--[[
Builds an isolated level-one Mystic with its legitimate starter robe.

Args:
    user_id (number): Test-only runtime character key.
    race_id (string): Human or Elf starting Mystic race.

Returns:
    any: Mutable authoritative-style character fixture.
]]
local function make_mystic(user_id: number, race_id: string): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = "Mage"
    character.Identity.ClassId = "Mage"
    character.Identity.CreationStage = "Complete"
    character.Level = 1
    character.Equipment.Body = "apprentice_mystic_robe"
    character.Equipment.Weapon = "apprentice_arcane_wand"
    return character
end

--[[
Verifies both level-one robe passives increase actual authoritative
combat timing and mana regeneration while requiring real equipped gear.

Args:
    user_id (number): Isolated server runtime identity.
    race_id (string): Supported Human or Elf C4 Mystic.

Returns:
    nil: Checks real passive ranks, equipment and foreign-class denial.
]]
local function check_robe(user_id: number, race_id: string)
    local character = make_mystic(user_id, race_id)
    for _, skill_id in ipairs(SKILLS) do
        local definition = assert(Skills.get(skill_id))
        check(definition.Kind == "Passive"
            and definition.MaxRank == 1
            and definition.RankLevels[1] == 1,
            skill_id .. " is missing its level-one source rank")
        check(Unlocks.can_show(character, definition),
            skill_id .. " invisible to legitimate level-one Mystic")
        check(Trainers.can_offer(
            "MageTrainer", character, skill_id
        ).ok, skill_id .. " not authorized by the Mage trainer")
    end

    Runtime.set_character(user_id, character)
    local base_regen = Runtime.get_mana_regen_per_second(user_id)
    local base_rate = Runtime.get_basic_attack_rate(user_id)
    check(base_regen > 0 and base_rate > 0,
        "Starting mage needs positive mana and attack timing")
    for _, skill_id in ipairs(SKILLS) do
        character.Progression.Skills[skill_id] = {
            Known = true, PurchasedRank = 1, Proficiency = 0,
        }
    end
    Runtime.set_character(user_id, character)
    check(math.abs(
        Runtime.get_mana_regen_per_second(user_id)
            - base_regen * 1.15
    ) < 0.0001, "Robe training did not increase real mana regen")
    check(math.abs(
        Runtime.get_basic_attack_rate(user_id)
            - base_rate * 1.06
    ) < 0.0001, "Robe training did not accelerate basic attacks")
    character.Equipment.Body = nil
    Runtime.set_character(user_id, character)
    check(math.abs(
        Runtime.get_mana_regen_per_second(user_id) - base_regen
    ) < 0.0001, "Missing robe still increased mana regen")
    check(math.abs(
        Runtime.get_basic_attack_rate(user_id) - base_rate
    ) < 0.0001, "Missing robe still increased attack rate")
    character.Equipment.Body = "marauder_armor"
    Runtime.set_character(user_id, character)
    check(Passive.robe_mana_regen_bonus(character) == 0
        and Passive.robe_attack_rate_bonus(character) == 0,
        "Heavy armour illegally granted robe passives")
    character.Equipment.Body = "apprentice_mystic_robe"
    character.Identity.BaseClassId = "Fighter"
    Runtime.set_character(user_id, character)
    check(Passive.robe_mana_regen_bonus(character) == 0
        and Passive.robe_attack_rate_bonus(character) == 0,
        "Foreign class must not retain forged Mystic training")
    Runtime.clear_character(user_id)
end

check_robe(77691, "Human")
check_robe(77692, "Elf")
print(("[C4 Base Robe] PASS: %d assertions."):format(assertions))
