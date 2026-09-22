--!strict
-- C4 source-ranked Mystic poison and Elf Scout self-cleansing contracts.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared

local Schema = require(Shared.ProfileSchema)
local Progression = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Poison = require(SSS.Combat.PoisonStatusService)

local assertions = 0

--[[
Checks a genuine source rank, purchased skill or poison effect invariant.

Args:
    condition (boolean): Whether an authoritative condition holds.
    description (string): Identifies the failed C4 poison contract.

Returns:
    nil: Counts the passing assertion or raises immediately.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Poison Skills] " .. description)
end

--[[
Creates a detached character for legitimate race/class gating.

Args:
    user_id (number): Isolated server runtime key.
    race_id (string): Human or Elf.
    class_id (string): Original starting or Scout analogue class.
    level (number): Actual source level used in the progression test.

Returns:
    any: Mutable server-owned style character.
]]
local function make_character(
    user_id: number,
    race_id: string,
    class_id: string,
    level: number
): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = class_id
    character.Identity.ClassId = class_id
    character.Identity.CreationStage = "Complete"
    character.Level = level
    character.Equipment.Weapon = "apprentice_arcane_wand"
    return character
end

--[[
Verifies level-seven Mage source poison damage and healthy-ally cure.

Args:
    race_id (string): Human or Elf Mystic.
    user_id (number): Isolated authentic runtime identity.

Returns:
    nil: Checks trainer gates, race restrictions and authored effects.
]]
local function check_mystic(race_id: string, user_id: number)
    local character = make_character(user_id, race_id, "Mage", 6)
    local curse = assert(Progression.get("MysticPoisonCurse"))
    local cure = assert(Progression.get("MysticCurePoison"))
    check(not Unlocks.can_show(character, cure),
        "Level-six Mystic learned level-seven poison cure")
    character.Progression.Skills.MageHeal = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    character.Progression.Skills.MysticWindBolt = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    character.Level = 7
    check(Trainers.can_offer(
        "MageTrainer", character, cure.Id
    ).ok, "Legitimate Mystic cannot train poison cure")
    check(Unlocks.can_show(character, curse) == (race_id == "Human"),
        "Human-only Mystic poison curse leaked to Elf or disappeared")

    local support = assert(Combat.get_for_rank(cure.Id, 1))
    check(support.KIND == "MageHeal"
        and support.TOTAL_HEAL == 0
        and support.CURE_POISON_TIER == 3
        and support.MANA_COST > 0,
        "Cure Poison must remove real poison, not heal HP")
    if race_id == "Human" then
        local spell = assert(Combat.get_for_rank(curse.Id, 1))
        check(spell.KIND == "MagicProjectile"
            and spell.POISON_TICK_DAMAGE == 4
            and spell.POISON_TICK_COUNT == 3
            and spell.POISON_TIER == 1,
            "Human Mystic curse has no genuine bounded poison ticks")
        character.Progression.Skills[curse.Id] = {
            Known = true, PurchasedRank = 1, Proficiency = 0,
        }
        character.Progression.Loadout[1] = curse.Id
        Runtime.set_character(user_id, character)
        check(Runtime.is_skill_usable(user_id, curse.Id),
            "Purchased Human curse cannot enter the real loadout")
    end
    character.Progression.Skills[cure.Id] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    character.Progression.Loadout[1] = cure.Id
    Runtime.set_character(user_id, character)
    check(Runtime.is_skill_usable(user_id, cure.Id),
        "Purchased Mage cure cannot enter the real loadout")
    Runtime.clear_character(user_id)
end

--[[
Verifies the source Elf-only level-24 Scout self-cleansing skill.

Args:
    class_id (string): Supported Ranger or Rogue gameplay analogue.
    user_id (number): Isolated runtime owner.

Returns:
    nil: Checks source gating, actual self target and false-race denial.
]]
local function check_scout(class_id: string, user_id: number)
    local character = make_character(user_id, "Elf", class_id, 23)
    local skill = assert(Progression.get("ElvenScoutPoisonRecovery"))
    check(not Unlocks.can_show(character, skill),
        "Elven Scout poison recovery appeared before level 24")
    character.Level = 24
    check(Trainers.can_offer(
        class_id .. "Trainer", character, skill.Id
    ).ok, "Elven Scout trainer cannot teach poison recovery")
    local effect = assert(Combat.get_for_rank(skill.Id, 1))
    check(effect.KIND == "MageHeal"
        and effect.SELF_ONLY == true
        and effect.TOTAL_HEAL == 0
        and effect.CURE_POISON_TIER == 3,
        "Scout cure must cleanse self rather than heal another player")
    character.Identity.RaceId = "Human"
    check(not Unlocks.can_show(character, skill),
        "Elf-only poison recovery leaked to Human Scout")
end

--[[
Runs all source skill and fail-closed absent-status checks.

Args:
    None.

Returns:
    nil: Prints the verified source/skill assertion count.
]]
local function main()
    check_mystic("Human", 78111)
    check_mystic("Elf", 78112)
    check_scout("Ranger", 78113)
    check_scout("Rogue", 78114)
    check(not Poison.is_poisoned(nil),
        "Missing model was treated as real poison")
    check(not Poison.cure(nil, 3),
        "Missing model was allowed a free cleansing effect")
    print(("[C4 Poison Skills] PASS: %d assertions.")
        :format(assertions))
end

main()
