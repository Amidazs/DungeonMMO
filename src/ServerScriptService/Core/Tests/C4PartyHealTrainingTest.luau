--!strict
-- Focused source-level/actual rank and trainer gates for C4 Party Heal.
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

--[[
Asserts one legitimate trainer, C4 source or server combat contract.

Args:
    condition (boolean): Invariant checked in unpublished Studio.
    description (string): Focused failure diagnostic.

Returns:
    nil: Counts a passing check or raises immediately.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Party Heal Training] " .. description)
end

--[[
Creates a detached genuine Mystic profile with an equipped wand.

Args:
    user_id (number): Isolated server test player identity.
    race_id (string): Human or Elf original source Mystic.

Returns:
    any: Mutable profile character for rank/proficiency/level gating.
]]
local function make_mystic(user_id: number, race_id: string): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity = {
        Version = 1,
        RaceId = race_id,
        BaseClassId = "Mage",
        ClassId = "Mage",
        CreationStage = "Complete",
    }
    character.Equipment.Weapon = "apprentice_arcane_wand"
    character.Level = 14
    character.Progression.Skills.MageHeal = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    return character
end

--[[
Checks the three party-only healing ranks for one source Mystic race.

Args:
    user_id (number): Isolated progression runtime key.
    race_id (string): Human or Elf source race.

Returns:
    nil: Validates rank thresholds, actual healing and wand restrictions.
]]
local function check_mystic(user_id: number, race_id: string)
    local character = make_mystic(user_id, race_id)
    local definition = assert(Skills.get("MysticPartyHeal"))
    check(definition.MaxRank == 3,
        "Party Heal must provide three original C4 ranks")
    check(not Unlocks.can_show(character, definition),
        "Party Heal appeared without purchased Healing Prayer")
    character.Progression.Skills.MysticHealingPrayer = {
        Known = true, PurchasedRank = 3, Proficiency = 260,
    }
    character.Level = 13
    check(not Unlocks.can_show(character, definition),
        "Party Heal appeared before source level fourteen")
    character.Level = 14
    check(Unlocks.can_show(character, definition),
        "Learned healing prerequisite did not unlock Party Heal")
    check(Trainers.can_offer(
        "MageTrainer", character, "MysticPartyHeal"
    ).ok, "Mage trainer did not offer party-only heal")

    local prior = 0
    for rank = 1, 3 do
        check(definition.RankLevels[rank] == 14,
            "Party Heal source purchase level differs")
        local effect = assert(Combat.get_for_rank("MysticPartyHeal", rank))
        check(effect.KIND == "MageHeal"
            and effect.PARTY_HEAL == true
            and effect.MANA_COST > 0
            and effect.COOLDOWN_SECONDS > 0
            and effect.TOTAL_HEAL > prior
            and effect.RANGE_STUDS <= 40,
            "Rank lacks an actual multi-target mana-costed heal")
        prior = effect.TOTAL_HEAL
    end

    character.Progression.Skills.MysticPartyHeal = {
        Known = true, PurchasedRank = 3, Proficiency = 140,
    }
    character.Progression.Loadout[1] = "MysticPartyHeal"
    Runtime.set_character(user_id, character)
    local usable, reason = Runtime.is_skill_usable(
        user_id, "MysticPartyHeal"
    )
    check(usable, "Owned source rank is blocked: " .. tostring(reason))
    character.Equipment.Weapon = nil
    Runtime.set_character(user_id, character)
    check(not Runtime.is_skill_usable(user_id, "MysticPartyHeal"),
        "Party Heal bypassed its required equipped wand")
    character.Equipment.Weapon = "apprentice_arcane_wand"
    character.Identity.BaseClassId = "Fighter"
    Runtime.set_character(user_id, character)
    check(not Runtime.is_skill_usable(user_id, "MysticPartyHeal"),
        "A Fighter cannot cast Mage party-heal ranks")
    Runtime.clear_character(user_id)
end

--[[
Runs source-accurate training and server-side rank proof.

Args:
    None.

Returns:
    nil: Prints the dedicated party-healing validation result.
]]
local function main()
    check_mystic(99301, "Human")
    check_mystic(99302, "Elf")
    print(("[C4 Party Heal Training] PASS: %d assertions.")
        :format(assertions))
end

main()
