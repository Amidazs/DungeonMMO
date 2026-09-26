--!strict
-- Actual early Fighter bow/dagger rank effects and server class/weapon gates.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared

local Schema = require(Shared.ProfileSchema)
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Classes = require(Shared.ClassProgressionDefinitions)
local Items = require(Shared.ItemDefinitions)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)

local assertions = 0
local LEVELS = {5, 5, 5, 10, 10, 10, 15, 15, 15}

--[[
Asserts one source-level or server-owned combat skill condition.

Args:
    condition (boolean): Expected progression, item, or effect state.
    description (string): Diagnostic for a failing contract.

Returns:
    nil: Records a successful assertion or raises.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Base Fighter Weapons] " .. description)
end

--[[
Makes one detached Fighter profile for testing a source weapon family.

Args:
    user_id (number): Unique isolated runtime identity.
    weapon_id (string): Authored real bow or dagger equipment.

Returns:
    any: Server-style complete Fighter character.
]]
local function make_fighter(user_id: number, weapon_id: string): any
    local fighter = Schema.create_default(user_id).Characters.Slot1
    fighter.Identity.RaceId = "Human"
    fighter.Identity.BaseClassId = "Fighter"
    fighter.Identity.ClassId = "Fighter"
    fighter.Identity.CreationStage = "Complete"
    fighter.Equipment.Weapon = weapon_id
    return fighter
end

--[[
Checks every new rank's exact level band and real damage increase.

Args:
    skill_id (string): Source-inspired Fighter bow or dagger ability.
    weapon_id (string): Authorized equipped item.
    user_id (number): Separate test-only runtime identity.
    kind (string): Required authoritative combat executor.

Returns:
    nil: Verifies nine ranks, both class and real equipment gates.
]]
local function check_family(
    skill_id: string,
    weapon_id: string,
    user_id: number,
    kind: string
)
    local definition = assert(Skills.get(skill_id))
    check(definition.MaxRank == #LEVELS,
        skill_id .. " does not have nine source-band ranks")
    check(Classes.can_teach("Fighter", skill_id),
        skill_id .. " not registered at base Fighter trainer")
    check(not Classes.can_teach("Mage", skill_id),
        skill_id .. " leaked to Mage")
    local fighter = make_fighter(user_id, weapon_id)
    local weapon = assert(Items.get(weapon_id))
    local allowed = false
    for _, class_id in ipairs(weapon.AllowedBaseClasses) do
        if class_id == "Fighter" then
            allowed = true
        end
    end
    check(allowed, weapon_id .. " is not legal Fighter equipment")
    fighter.Level = 1
    check(not Unlocks.can_show(fighter, definition),
        skill_id .. " appeared before level five")
    local previous_damage = 0
    for rank, level in ipairs(LEVELS) do
        fighter.Level = level - 1
        check(not Unlocks.can_train(fighter, definition, rank),
            skill_id .. " rank " .. rank .. " skipped a level")
        fighter.Level = level
        check(Unlocks.can_train(fighter, definition, rank),
            skill_id .. " rank " .. rank .. " was blocked at level")
        check(definition.RankLevels[rank] == level,
            skill_id .. " source bracket differs at rank " .. rank)
        local effect = assert(Combat.get_for_rank(skill_id, rank))
        check(effect.KIND == kind and effect.BASE_DAMAGE > previous_damage,
            skill_id .. " rank is not a real increasing damage effect")
        previous_damage = effect.BASE_DAMAGE
    end
    fighter.Level = 15
    check(Trainers.can_offer(
        "FighterTrainer", fighter, skill_id
    ).ok, skill_id .. " cannot be offered by Fighter trainer")
    fighter.Progression.Skills[skill_id] = {
        Known = true, PurchasedRank = 9, Proficiency = 350,
    }
    fighter.Progression.Loadout[1] = skill_id
    Runtime.set_character(user_id, fighter)
    local usable, reason = Runtime.is_skill_usable(user_id, skill_id)
    check(usable, skill_id .. " blocked by " .. tostring(reason))
    fighter.Equipment.Weapon = nil
    Runtime.set_character(user_id, fighter)
    check(not Runtime.is_skill_usable(user_id, skill_id),
        skill_id .. " ignored missing required equipment")
    Runtime.clear_character(user_id)
end

check_family(
    "FighterBowShot", "apprentice_longbow", 77651,
    "RangerProjectile"
)
check_family(
    "FighterDaggerStrike", "scout_dagger", 77652, "Melee"
)
print(("[C4 Base Fighter Weapons] PASS: %d assertions.")
    :format(assertions))
