--!strict
-- Focused 20–36 rank-volume, class isolation and actual-effect contract.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared

local Schema = require(Shared.ProfileSchema)
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Classes = require(Shared.ClassProgressionDefinitions)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Reference = require(Shared.C4ScoutReferenceTargets)

local assertions = 0
local LEVELS = {20, 24, 28, 32, 36}

--[[
Asserts a single server-owned rank ladder or effect requirement.

Args:
    condition (boolean): Expected progression or effect invariant.
    description (string): Diagnostic if the condition is violated.

Returns:
    nil: Counts a pass or stops this focused contract.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 First Transfer] " .. description)
end

--[[
Creates a disposable complete server-character for one combat class.

Args:
    class_id (string): Ranger or Rogue first-transfer analogue.
    user_id (number): Unique isolated runtime key for the test.

Returns:
    any: Detached mutable character fixture.
]]
local function make_character(class_id: string, user_id: number): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = "Human"
    character.Identity.BaseClassId = class_id
    character.Identity.ClassId = class_id
    character.Identity.CreationStage = "Complete"
    return character
end

--[[
Validates that all fifteen ranks have the correct 20–36 level bands,
owned mastery and a distinct server-executed damage value.

Args:
    class_id (string): Expected owning base class.
    foreign_class (string): Class that must not learn this ladder.
    skill_id (string): Fifteen-rank skill being tested.
    basic_id (string): Basic prerequisite that must be mastered.
    weapon_id (string): Existing server-authorized equipped weapon.
    user_id (number): Unique isolated runtime state key.

Returns:
    nil: Completes rank, class, trainer and weapon contract assertions.
]]
local function check_ladder(
    class_id: string,
    foreign_class: string,
    skill_id: string,
    basic_id: string,
    weapon_id: string,
    user_id: number
)
    local definition = assert(Skills.get(skill_id))
    check(definition.MaxRank == 15, skill_id .. " needs 15 ranks")
    check(Classes.can_teach(class_id, skill_id),
        skill_id .. " is missing from the owned class")
    check(not Classes.can_teach(foreign_class, skill_id),
        skill_id .. " leaked to a foreign class")

    local character = make_character(class_id, user_id)
    character.Level = 20
    check(not Unlocks.can_show(character, definition),
        skill_id .. " visible without mastered base ability")
    character.Progression.Skills[basic_id] = {
        Known = true, PurchasedRank = 9, Proficiency = 349,
    }
    check(not Unlocks.can_show(character, definition),
        skill_id .. " cannot skip use-earned base proficiency")
    character.Progression.Skills[basic_id].Proficiency = 350
    check(Unlocks.can_show(character, definition),
        skill_id .. " should be visible to a mastered class")
    local trainer = class_id .. "Trainer"
    check(Trainers.can_offer(trainer, character, skill_id).ok,
        skill_id .. " should be offered at the valid trainer")
    local previous_damage = 0
    for rank = 1, definition.MaxRank do
        local level = LEVELS[math.ceil(rank / 3)]
        character.Level = level - 1
        check(not Unlocks.can_train(character, definition, rank),
            skill_id .. " rank may not bypass its level band")
        character.Level = level
        check(Unlocks.can_train(character, definition, rank),
            skill_id .. " rank should have its level band")
        check(definition.RankLevels[rank] == level,
            skill_id .. " has an incorrect level-band mapping")
        local effect = assert(Combat.get_for_rank(skill_id, rank))
        check(effect.BASE_DAMAGE > previous_damage,
            skill_id .. " rank does not increase real damage")
        previous_damage = effect.BASE_DAMAGE
        check(effect.STAMINA_COST > 0,
            skill_id .. " needs server-owned Stamina spending")
    end

    character.Level = 36
    character.Equipment.Weapon = weapon_id
    character.Progression.Skills[skill_id] = {
        Known = true, PurchasedRank = 15, Proficiency = 560,
    }
    character.Progression.Loadout[1] = skill_id
    Runtime.set_character(user_id, character)
    local usable, reason = Runtime.is_skill_usable(user_id, skill_id)
    check(usable, skill_id .. " blocked: " .. tostring(reason))
    Runtime.clear_character(user_id)
    local foreign = make_character(foreign_class, user_id + 100)
    foreign.Level = 36
    foreign.Progression.Skills[basic_id] = {
        Known = true, PurchasedRank = 9, Proficiency = 350,
    }
    check(not Unlocks.can_show(foreign, definition),
        skill_id .. " exposed to foreign-class player")
end

check_ladder(
    "Ranger", "Rogue", "ScoutFocusedShot", "ArcherDraw",
    "apprentice_longbow", 77594
)
check_ladder(
    "Rogue", "Ranger", "RogueFinishingCut", "RogueVitalBlow",
    "marauder_sword", 77595
)

-- C4's one Rogue/Scout class lists both weapon branches together.
-- The DungeonMMO split must not count those two reference entries twice.
local human = assert(Reference.get("Human"))
local elf = assert(Reference.get("Elf"))
for _, level in ipairs(LEVELS) do
    check(human.Levels[level] > 0 and elf.Levels[level] > 0,
        "Source bracket missing at level " .. tostring(level))
end
print(("[C4 First Transfer] PASS: %d assertions."):format(
    assertions
))
