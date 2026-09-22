--!strict
-- Real equipped Ranger/Rogue first-transfer passive rank effects.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared

local Schema = require(Shared.ProfileSchema)
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Classes = require(Shared.ClassProgressionDefinitions)
local Passive = require(Shared.PassiveSkillEffects)
local CombatStats = require(Shared.CharacterCombatStats)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)

local LEVELS_BOW = {20, 20, 20, 24, 24, 24, 28, 28, 28,
    32, 32, 32, 36, 36, 36}
local LEVELS_BLADE = {20, 24, 28, 28, 32, 32, 36, 36}
local LEVELS_ARMOR = {20, 20, 24, 24, 28, 28, 32, 32, 36, 36}
local assertions = 0

--[[
Checks a single server-owned rank or passive-effect property.

Args:
    condition (boolean): Expected authoritative skill or equipment state.
    description (string): Diagnostic on failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Scout Passives] " .. description)
end

--[[
Builds a detached and complete character with legitimate starting equipment.

Args:
    class_id (string): Ranger or Rogue.
    user_id (number): Isolated runtime identity.

Returns:
    any: Mutable test character.
]]
local function make_character(class_id: string, user_id: number): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = "Human"
    character.Identity.BaseClassId = class_id
    character.Identity.ClassId = class_id
    character.Identity.CreationStage = "Complete"
    character.Level = 36
    character.Equipment.Weapon = if class_id == "Ranger"
        then "apprentice_longbow" else "scout_dagger"
    character.Equipment.Body = "scout_leather_vest"
    return character
end

--[[
Checks every rank's source-band level and class/earned-basic gating.

Args:
    character (any): Owned test character.
    skill_id (string): Server-owned passive skill.
    levels ({number}): Explicit level for each rank.
    basic_id (string?): Prerequisite starter weapon mastery when needed.

Returns:
    nil: Verifies the complete ladder and trainer eligibility.
]]
local function check_ladder(
    character: any, skill_id: string, levels: {number},
    basic_id: string?
)
    local definition = assert(Skills.get(skill_id))
    local class_id = character.Identity.BaseClassId
    check(definition.Kind == "Passive"
        and definition.MaxRank == #levels,
        skill_id .. " has an invalid passive rank count")
    check(Classes.can_teach(class_id, skill_id),
        class_id .. " is not authorized for " .. skill_id)
    character.Level = 20
    check(not Unlocks.can_show(character, definition)
        or basic_id == nil,
        skill_id .. " must require mastered initial basics")
    if basic_id then
        character.Progression.Skills[basic_id] = {
            Known = true, PurchasedRank = 6, Proficiency = 0,
        }
    end

    for rank, level in ipairs(levels) do
        character.Level = level - 1
        check(not Unlocks.can_train(character, definition, rank),
            skill_id .. " rank bypasses its level band")
        character.Level = level
        check(Unlocks.can_train(character, definition, rank),
            skill_id .. " rank is blocked at its earned level")
        check(definition.RankLevels[rank] == level,
            skill_id .. " rank has an incorrect authored level")
    end

    character.Level = 36
    check(Trainers.can_offer(
        class_id .. "Trainer", character, skill_id
    ).ok, "Mastered character cannot train " .. skill_id)
    check(not Unlocks.can_train(
        character, definition, definition.MaxRank + 1
    ), "Undefined " .. skill_id .. " rank was offered")
end

--[[
Tests that acquired ranks actually alter the server's damage multipliers.

Args:
    character (any): Owned Ranger or Rogue with authentic weapon.
    user_id (number): Isolated runtime state ID.
    skill_id (string): New bow or blade mastery.
    rank (number): Source-mapped maximum purchased rank.
    ranged (boolean): True for the Ranger's ranged multiplier.

Returns:
    nil: Confirms a meaningful increase in real authoritative combat stats.
]]
local function check_damage(
    character: any, user_id: number, skill_id: string,
    rank: number, ranged: boolean
)
    Runtime.set_character(user_id, character)
    local baseline = if ranged
        then Runtime.get_ranged_physical_multiplier(user_id)
        else Runtime.get_physical_multiplier(user_id)
    character.Progression.Skills[skill_id] = {
        Known = true, PurchasedRank = rank, Proficiency = 0,
    }
    Runtime.set_character(user_id, character)
    local improved = if ranged
        then Runtime.get_ranged_physical_multiplier(user_id)
        else Runtime.get_physical_multiplier(user_id)
    check(improved > baseline,
        skill_id .. " has no actual authoritative damage effect")
    check(math.abs(
        improved - baseline
            - Passive.damage_bonus(character, skill_id)
    ) < 0.0001, skill_id .. " damage did not match its passive")
    Runtime.clear_character(user_id)
end

local ranger = make_character("Ranger", 77601)
local rogue = make_character("Rogue", 77602)
check_ladder(
    ranger, "ScoutBowDiscipline", LEVELS_BOW, "RangerBowMastery"
)
check_ladder(
    rogue, "RogueEdgeDiscipline", LEVELS_BLADE, "RogueBladeMastery"
)
check_ladder(ranger, "ScoutLightArmorMastery", LEVELS_ARMOR, nil)
check_ladder(rogue, "ScoutLightArmorMastery", LEVELS_ARMOR, nil)

check_damage(ranger, 77601, "ScoutBowDiscipline", 15, true)
check_damage(rogue, 77602, "RogueEdgeDiscipline", 8, false)

for _, character in ipairs({ranger, rogue}) do
    local definition = assert(Skills.get("ScoutLightArmorMastery"))
    character.Progression.Skills.ScoutLightArmorMastery = {
        Known = true, PurchasedRank = 10, Proficiency = 0,
    }
    local user_id = if character == ranger then 77601 else 77602
    Runtime.set_character(user_id, character)
    check(math.abs(
        Runtime.get_light_armor_reduction(user_id) - 0.08
    ) < 0.0001, "Earned rank-ten light armour needs 8% mitigation")
    character.Equipment.Body = nil
    Runtime.set_character(user_id, character)
    check(Runtime.get_light_armor_reduction(user_id) == 0,
        "Unequipping the leather body must remove passive mitigation")
    character.Equipment.Body = "marauder_armor"
    Runtime.set_character(user_id, character)
    check(Runtime.get_light_armor_reduction(user_id) == 0,
        "Heavy body armour must not grant light-armour mitigation")
    Runtime.clear_character(user_id)
end

-- Range and arrow-speed passives must change actual server projectile inputs.
check_ladder(ranger, "RangerLongRange", {20}, nil)
check_ladder(ranger, "RangerArrowVelocity", {32}, nil)
Runtime.set_character(77601, ranger)
check(Runtime.get_ranged_range_bonus(77601) == 0,
    "Unpurchased Longbow range must not be granted")
check(Runtime.get_ranged_arrow_speed_bonus(77601) == 0,
    "Unpurchased arrow velocity must not be granted")
ranger.Progression.Skills.RangerLongRange = {
    Known = true, PurchasedRank = 1, Proficiency = 0,
}
ranger.Progression.Skills.RangerArrowVelocity = {
    Known = true, PurchasedRank = 1, Proficiency = 0,
}
Runtime.set_character(77601, ranger)
check(Runtime.get_ranged_range_bonus(77601) == 12,
    "Purchased long-range passive must add twelve actual studs")
check(Runtime.get_ranged_arrow_speed_bonus(77601) == 18,
    "Purchased arrow-speed passive must add real flight velocity")
ranger.Equipment.Weapon = nil
Runtime.set_character(77601, ranger)
check(Runtime.get_ranged_range_bonus(77601) == 0,
    "Unequipped Longbow must not grant projectile range")
check(Runtime.get_ranged_arrow_speed_bonus(77601) == 0,
    "Unequipped Longbow must not grant arrow velocity")
Runtime.clear_character(77601)
check(not Classes.can_teach("Rogue", "RangerLongRange"),
    "Rogue cannot learn the Ranger-only range passive")
check(not Classes.can_teach("Rogue", "RangerArrowVelocity"),
    "Rogue cannot learn the Ranger-only arrow-speed passive")

-- Human Rogue/Scout critical-damage power exists at C4 levels 24/32.
-- Its purchased rank must change the actual critical multiplier, not
-- a display-only inventory value; Elf and wrong-class data fail closed.
local critical = assert(Skills.get("HumanScoutCriticalPower"))
check(critical.MaxRank == 2
    and critical.RankLevels[1] == 24
    and critical.RankLevels[2] == 32,
    "Human critical-power source levels must be 24 and 32")
for _, character in ipairs({ranger, rogue}) do
    local user_id = if character == ranger then 77601 else 77602
    character.Identity.RaceId = "Human"
    character.Level = 24
    check(Unlocks.can_show(character, critical),
        "Eligible Human scout cannot see level-24 critical power")
    check(Trainers.can_offer(
        character.Identity.BaseClassId .. "Trainer",
        character,
        "HumanScoutCriticalPower"
    ).ok, "Human critical-power rank missing from the trainer")
    character.Progression.Skills.HumanScoutCriticalPower = nil
    Runtime.set_character(user_id, character)
    local baseline = Runtime.get_critical_damage_multiplier(user_id)
    for rank = 1, 2 do
        character.Level = critical.RankLevels[rank] - 1
        check(not Unlocks.can_train(character, critical, rank),
            "Critical rank may not bypass its character level")
        character.Level = critical.RankLevels[rank]
        check(Unlocks.can_train(character, critical, rank),
            "Eligible critical rank was incorrectly locked")
        character.Progression.Skills.HumanScoutCriticalPower = {
            Known = true, PurchasedRank = rank, Proficiency = 0,
        }
        Runtime.set_character(user_id, character)
        local expected = baseline + rank * 0.08
        check(math.abs(
            Runtime.get_critical_damage_multiplier(user_id) - expected
        ) < 0.0001, "Critical power failed to alter real combat stats")
    end
    character.Identity.RaceId = "Elf"
    Runtime.set_character(user_id, character)
    check(not Unlocks.can_show(character, critical),
        "Human-only critical power leaked to Elf trainer")
    check(math.abs(
        Runtime.get_critical_damage_multiplier(user_id)
        - CombatStats.critical_damage_multiplier("Elf")
    ) < 0.0001, "Forged Human rank altered Elf critical damage")
    check(Passive.critical_damage_bonus(character) == 0,
        "Forged Human passive must not boost an Elf")
    Runtime.clear_character(user_id)
end

--[[
Checks race-unique C4 critical-rate ranks and actual combat-stat changes.

Args:
    race_id (string): Human or Elf race whose training band is tested.
    skill_id (string): Matching race-specific critical chance skill.
    level (number): Source-verified purchase level.
    user_id (number): Isolated server-side runtime identity.

Returns:
    nil: Verifies rank visibility, class, race, and critical-rate effect.
]]
local function check_scout_precision(
    race_id: string,
    skill_id: string,
    level: number,
    user_id: number
)
    local character = make_character("Ranger", user_id)
    character.Identity.RaceId = race_id
    character.Level = level - 1
    local definition = assert(Skills.get(skill_id))
    check(definition.MaxRank == 1
        and definition.RankLevels[1] == level,
        skill_id .. " has the wrong race-specific C4 level")
    check(not Unlocks.can_show(character, definition),
        skill_id .. " appeared below its level")
    character.Level = level
    check(Unlocks.can_show(character, definition),
        skill_id .. " was hidden from its rightful race")
    check(Trainers.can_offer(
        "RangerTrainer", character, skill_id
    ).ok, skill_id .. " was missing from the Ranger trainer")
    Runtime.set_character(user_id, character)
    local baseline = Runtime.get_critical_chance(user_id)
    character.Progression.Skills[skill_id] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    Runtime.set_character(user_id, character)
    check(math.abs(
        Runtime.get_critical_chance(user_id) - baseline - 0.02
    ) < 0.0001, skill_id .. " failed to increase server critical rate")
    character.Identity.RaceId = if race_id == "Human"
        then "Elf" else "Human"
    Runtime.set_character(user_id, character)
    check(not Unlocks.can_show(character, definition),
        skill_id .. " leaked to an ineligible race")
    check(Passive.critical_chance_bonus(character) == 0,
        skill_id .. " allowed forged foreign-race critical bonus")
    Runtime.clear_character(user_id)
end

check_scout_precision("Human", "HumanScoutPrecision", 28, 77611)
check_scout_precision("Elf", "ElvenScoutPrecision", 32, 77612)

-- Both races receive one real movement-speed rank at source level 28.
local fleet_foot = assert(Skills.get("ScoutFleetFoot"))
check(fleet_foot.MaxRank == 1
    and fleet_foot.RankLevels[1] == 28,
    "Fleet Foot must only unlock at first-transfer level 28")
for _, race_id in ipairs({"Human", "Elf"}) do
    for _, class_id in ipairs({"Ranger", "Rogue"}) do
        local user_id = if race_id == "Human"
            then (if class_id == "Ranger" then 77631 else 77632)
            else (if class_id == "Ranger" then 77633 else 77634)
        local character = make_character(class_id, user_id)
        character.Identity.RaceId = race_id
        character.Level = 27
        check(not Unlocks.can_show(character, fleet_foot),
            race_id .. " " .. class_id .. " exposed early movement")
        character.Level = 28
        check(Trainers.can_offer(
            class_id .. "Trainer", character, "ScoutFleetFoot"
        ).ok, "Eligible Scout cannot learn its movement passive")
        Runtime.set_character(user_id, character)
        check(Runtime.get_movement_multiplier(user_id) == 1,
            "Untrained Scout must have neutral movement")
        character.Progression.Skills.ScoutFleetFoot = {
            Known = true, PurchasedRank = 1, Proficiency = 0,
        }
        Runtime.set_character(user_id, character)
        check(math.abs(
            Runtime.get_movement_multiplier(user_id) - 1.06
        ) < 0.0001, "Purchased Fleet Foot did not improve server speed")
        character.Identity.BaseClassId = "Mage"
        Runtime.set_character(user_id, character)
        check(Runtime.get_movement_multiplier(user_id) == 1,
            "Foreign-class movement rank must not grant speed")
        Runtime.clear_character(user_id)
    end
end

print(("[C4 Scout Passives] PASS: %d assertions."):format(assertions))
