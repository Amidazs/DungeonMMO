--!strict
-- Human Rogue/Elven Scout original level-24 active Accuracy source rank.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared
local Schema = require(Shared.ProfileSchema)
local Progression = require(Shared.SkillProgressionDefinitions)
local Rules = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local Accuracy = require(RS.Combat.Shared.ScoutAccuracyRules)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Toggle = require(SSS.Combat.ScoutAccuracyToggleService)

local SKILL_ID = "ScoutAccuracyToggle"
local checks = 0

--[[
Verifies a source, authorized-combat or server-owned probability invariant.

Args:
    condition (boolean): Required actual C4 source and gameplay contract.
    description (string): Diagnostic for the focused Studio fixture.

Returns:
    nil: Counts a successful test assertion or raises immediately.
]]
local function check(condition: boolean, description: string)
    checks += 1
    assert(condition, "[C4 Scout Accuracy] " .. description)
end

--[[
Creates an isolated Ranger/Rogue character of the requested race.

Args:
    user_id (number): Distinct server-authoritative runtime identity.
    race_id (string): Original Human or Elf C4 racial path.
    class_id (string): Authorized Rogue or Ranger branch.

Returns:
    any: Properly equipped character for trainer and runtime gates.
]]
local function make_character(
    user_id: number, race_id: string, class_id: string
): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = class_id
    character.Identity.ClassId = class_id
    character.Identity.CreationStage = "Complete"
    character.Equipment.Weapon = if class_id == "Ranger"
        then "apprentice_longbow" else "scout_dagger"
    character.Level = 24
    return character
end

--[[
Checks one legitimate source race/class and pre-training denial.

Args:
    owner (number): Unique runtime test user.
    race_id (string): Human or Elf original source class.
    class_id (string): Real trainer and authorized class branch.

Returns:
    nil: Asserts source level, training, ownership and equipment gates.
]]
local function check_source(
    owner: number, race_id: string, class_id: string
)
    local definition = assert(Progression.get(SKILL_ID))
    local effect = assert(Combat.get_for_rank(SKILL_ID, 1))
    local character = make_character(owner, race_id, class_id)
    check(definition.MaxRank == 1
        and definition.RankLevels[1] == 24,
        "Source must have one earned accuracy rank at level 24")
    check(effect.KIND == "ScoutAccuracyToggle"
        and effect.ACCURACY_BONUS == 0.12
        and effect.STAMINA_COST > 0
        and effect.UPKEEP_STAMINA_PER_SECOND > 0,
        "Accuracy rank must actually improve paid server hit resolution")
    character.Level = 23
    check(not Rules.can_show(character, definition),
        "The accuracy stance is prematurely visible before source level")
    character.Level = 24
    check(Rules.can_show(character, definition),
        "Original level-24 Accuracy rank is not visible")
    check(Trainers.can_offer(
        class_id .. "Trainer", character, SKILL_ID
    ).ok, "A legitimate C4 class trainer cannot teach Accuracy")
    check(not Runtime.is_skill_usable(owner, SKILL_ID),
        "Unpurchased stance cannot be invoked on a new character")
    character.Progression.Skills[SKILL_ID] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    character.Progression.Loadout[1] = SKILL_ID
    Runtime.set_character(owner, character)
    check(Runtime.is_skill_usable(owner, SKILL_ID),
        "Purchased and equipped accuracy rank is incorrectly rejected")
    Runtime.clear_character(owner)

    character.Identity.BaseClassId = "Mage"
    character.Identity.ClassId = "Mage"
    check(not Rules.can_show(character, definition),
        "Mage cannot learn a Rogue/Scout-only source rank")
end

--[[
Checks true PvE miss/hit probabilities without relying on random luck.

Args:
    None.

Returns:
    nil: Verifies actual NPC evasion, purchased effect and safe defaults.
]]
local function check_accuracy_math()
    check(Accuracy.hit_chance(0, 0) == 1,
        "Old NPCs without evasiveness must preserve guaranteed contact")
    check(math.abs(Accuracy.hit_chance(0.12, 0) - 0.88) < 0.0001,
        "Server-authored NPC evasion must lower real hit probability")
    check(Accuracy.hit_chance(0.12, 0.12) == 1,
        "Paid Accuracy must counter source-authored NPC evasion")
    check(not Accuracy.is_hit(0.12, 0, 0.9),
        "Unpaid Rogue attack cannot bypass an actual 0.9 evasion roll")
    check(Accuracy.is_hit(0.12, 0.12, 0.9),
        "Paid Accuracy must make the identical attack connect")
    check(Accuracy.hit_chance(100, 100) <= 1,
        "Forged or broken values cannot exceed bounded probability")
    check(Toggle.get_bonus(nil) == 0,
        "Missing authenticated client cannot receive free accuracy")
end

--[[
Executes original source and deterministic active-effect contracts.

Args:
    None.

Returns:
    nil: Prints actual verified assertions for focused Studio execution.
]]
local function main()
    check_source(99611, "Human", "Rogue")
    check_source(99612, "Elf", "Ranger")
    check_source(99613, "Human", "Ranger")
    check_source(99614, "Elf", "Rogue")
    check_accuracy_math()
    print(("[C4 Scout Accuracy] PASS: %d assertions")
        :format(checks))
end

main()
