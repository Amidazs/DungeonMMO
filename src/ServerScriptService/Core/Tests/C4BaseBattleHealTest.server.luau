--!strict
-- Source-ranked Battle Heal works with earned healing and server mana.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared

local Schema = require(Shared.ProfileSchema)
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)

local LEVELS = {14, 14, 14}
local assertions = 0

--[[
Checks a source level, prerequisite or authoritative healing property.

Args:
    condition (boolean): Whether the server-owned skill is correct.
    description (string): Clear diagnostic for the failing contract.

Returns:
    nil: Records the assertion or raises on an invalid rank.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Battle Heal] " .. description)
end

--[[
Creates an early Mystic with a legitimate equipped arcane wand.

Args:
    user_id (number): Isolated server runtime owner.
    race_id (string): Human or Elf source Mage race.

Returns:
    any: Editable detached authoritative-style test character.
]]
local function make_mystic(user_id: number, race_id: string): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = "Mage"
    character.Identity.ClassId = "Mage"
    character.Identity.CreationStage = "Complete"
    character.Equipment.Weapon = "apprentice_arcane_wand"
    character.Level = 14
    return character
end

--[[
Validates C4 source-level ranks and a real MageHeal executor for both
races without permitting unearned prerequisite or foreign-class use.

Args:
    race_id (string): Human or Elf first-tier Mystic.
    user_id (number): Isolated server runtime identity.

Returns:
    nil: Checks every rank, friendly healing and weapon gating.
]]
local function check_battle_heal(race_id: string, user_id: number)
    local character = make_mystic(user_id, race_id)
    local definition = assert(Skills.get("MysticBattleHeal"))
    check(definition.MaxRank == #LEVELS,
        "Battle Heal must have all three source-level ranks")
    check(not Unlocks.can_show(character, definition),
        "Battle Heal was visible without purchased Healing Prayer")

    character.Progression.Skills.MysticHealingPrayer = {
        Known = true, PurchasedRank = 3, Proficiency = 130,
    }
    character.Level = 13
    check(not Unlocks.can_show(character, definition),
        "Battle Heal appeared before C4 source level 14")
    character.Level = 14
    check(Unlocks.can_show(character, definition),
        "Legitimate level-14 Mystic cannot see Battle Heal")
    check(Trainers.can_offer(
        "MageTrainer", character, "MysticBattleHeal"
    ).ok, "Mage trainer cannot teach the earned healing line")

    local previous_heal = 0
    for rank, level in ipairs(LEVELS) do
        check(definition.RankLevels[rank] == level,
            "Battle Heal rank has an incorrect C4 level")
        local effect = assert(Combat.get_for_rank(
            "MysticBattleHeal", rank
        ))
        check(effect.KIND == "MageHeal"
            and effect.MANA_COST > 0
            and effect.TOTAL_HEAL > previous_heal,
            "Battle Heal lacks actual increasing friendly heal effects")
        previous_heal = effect.TOTAL_HEAL
    end

    character.Progression.Skills.MysticBattleHeal = {
        Known = true, PurchasedRank = 3, Proficiency = 125,
    }
    character.Progression.Loadout[1] = "MysticBattleHeal"
    Runtime.set_character(user_id, character)
    local usable, reason = Runtime.is_skill_usable(
        user_id, "MysticBattleHeal"
    )
    check(usable, "Owned Battle Heal blocked: " .. tostring(reason))
    character.Equipment.Weapon = nil
    Runtime.set_character(user_id, character)
    check(not Runtime.is_skill_usable(user_id, "MysticBattleHeal"),
        "Battle Heal ignored the required equipped wand")
    character.Equipment.Weapon = "apprentice_arcane_wand"
    character.Identity.BaseClassId = "Fighter"
    Runtime.set_character(user_id, character)
    check(not Runtime.is_skill_usable(user_id, "MysticBattleHeal"),
        "Foreign Fighter class used bought Mage Battle Heal")
    Runtime.clear_character(user_id)
end

check_battle_heal("Human", 77831)
check_battle_heal("Elf", 77832)

print(("[C4 Battle Heal] PASS: %d assertions."):format(assertions))
