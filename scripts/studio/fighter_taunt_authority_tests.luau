--!strict
-- Local-only, authoritative Fighter Taunt class/rank contract.
assert(game.GameId == 0 and game.PlaceId == 0,
    "Fighter Taunt authority tests require unpublished Studio")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SkillDefinitions = require(RS.Combat.Shared.SkillDefinitions)
local ProgressionDefinitions = require(
    RS.Core.Shared.SkillProgressionDefinitions)
local ClassDefinitions = require(
    RS.Core.Shared.ClassProgressionDefinitions)
local ProfileSchema = require(RS.Core.Shared.ProfileSchema)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)

local FIGHTER_ID = 98501
local MAGE_ID = 98502
local assertions = 0

-- Args:
--   condition: boolean; expected server-authorized skill contract.
--   description: string; diagnostic if the contract fails.
-- Returns:
--   nil: increments the counter or raises a test failure.
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[Fighter Taunt] " .. description)
end

-- Args:
--   user_id: number; deterministic in-memory test identity.
--   base_class: string; authoritative character's starting class.
-- Returns:
--   any: one detached character with purchased/equipped Taunt.
local function character_with_taunt(user_id: number, base_class: string)
    local character = ProfileSchema.create_default(
        user_id).Characters.Slot1
    character.Identity.RaceId = "Human"
    character.Identity.BaseClassId = base_class
    character.Identity.ClassId = base_class
    character.Identity.CreationStage = "Complete"
    character.Progression.Skills.Taunt = {
        Known = true, PurchasedRank = 1,
    }
    character.Progression.Loadout[3] = "Taunt"
    return character
end

local taunt = assert(SkillDefinitions.get("Taunt"))
check(taunt.KIND == "Melee" and taunt.BASE_DAMAGE == 0,
    "Taunt must be a genuine zero-damage skill")
check(taunt.TAUNT_BONUS_THREAT > 0
    and taunt.COOLDOWN_SECONDS > 0
    and taunt.STAMINA_COST > 0,
    "Taunt requires finite positive threat, cooldown and stamina")
check(ProgressionDefinitions.get("Taunt").MaxRank == 3,
    "Taunt progression must support all three ranks")
check(ClassDefinitions.can_teach("Fighter", "Taunt")
    and not ClassDefinitions.can_teach("Mage", "Taunt")
    and not ClassDefinitions.can_teach("Rogue", "Taunt"),
    "only Fighter trainers may teach the Taunt ability")
check(SkillDefinitions.get_for_rank("Taunt", 3)
    .TAUNT_BONUS_THREAT > taunt.TAUNT_BONUS_THREAT,
    "purchased ranks must increase threat, never direct damage")

Runtime.set_character(
    FIGHTER_ID, character_with_taunt(FIGHTER_ID, "Fighter"))
local usable, reason = Runtime.is_skill_usable(FIGHTER_ID, "Taunt")
check(usable and reason == nil,
    "a purchased/equipped Fighter may use Taunt")

Runtime.set_character(
    MAGE_ID, character_with_taunt(MAGE_ID, "Mage"))
usable, reason = Runtime.is_skill_usable(MAGE_ID, "Taunt")
check(not usable and reason == "WrongClass",
    "a non-Fighter cannot use Taunt even with a malformed learned skill")
Runtime.clear_character(MAGE_ID)

local fighter = character_with_taunt(FIGHTER_ID, "Fighter")
fighter.Progression.Loadout = {}
Runtime.set_character(FIGHTER_ID, fighter)
usable, reason = Runtime.is_skill_usable(FIGHTER_ID, "Taunt")
check(not usable and reason == "SkillNotEquipped",
    "known Taunt cannot bypass authoritative loadout requirements")

Runtime.clear_character(FIGHTER_ID)
print(string.format(
    "[Fighter Taunt] PASS: %d assertions.", assertions))
