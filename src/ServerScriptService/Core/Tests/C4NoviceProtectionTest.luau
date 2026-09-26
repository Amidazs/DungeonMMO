--!strict
-- C4 level-one novice protection must stop at first-transfer level 20.
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared

local Schema = require(Shared.ProfileSchema)
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)

local SOURCE_RACES = {"Human", "Elf"}
local SOURCE_CLASSES = {"Fighter", "Mage"}
local assertions = 0

--[[
Checks one server-owned novice skill, trainer or runtime invariant.

Args:
    condition (boolean): Expected early-character defensive effect.
    description (string): Actionable failure diagnostic.

Returns:
    nil: Counts the passing assertion or raises.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Novice Protection] " .. description)
end

--[[
Constructs an isolated original C4 starting-class character.

Args:
    user_id (number): Isolated server runtime identity.
    race_id (string): Human or Elf.
    class_id (string): Starting Fighter or Mage.

Returns:
    any: Editable detached character used only in Studio tests.
]]
local function make_character(
    user_id: number, race_id: string, class_id: string
): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = class_id
    character.Identity.ClassId = class_id
    character.Identity.CreationStage = "Complete"
    character.Level = 1
    return character
end

--[[
Checks that actual owned novice mitigation is level-limited and class
gated, even if a stale or foreign-class purchased rank survives a change.

Args:
    race_id (string): Supported C4 race.
    class_id (string): Starting source class.
    user_id (number): Unique isolated server runtime identity.

Returns:
    nil: Verifies level-one ownership, trainer and level-20 expiry.
]]
local function check_novice(
    race_id: string, class_id: string, user_id: number
)
    local definition = assert(Skills.get("NoviceProtection"))
    local character = make_character(user_id, race_id, class_id)
    check(definition.MaxRank == 1
        and definition.RankLevels[1] == 1
        and definition.MaximumLevel == 19,
        "Novice source rank needs a level-one and expiry contract")
    check(Unlocks.can_show(character, definition),
        race_id .. " " .. class_id .. " cannot see novice skill")
    check(Trainers.can_offer(
        class_id .. "Trainer", character, "NoviceProtection"
    ).ok, "Starting class lacks novice trainer permission")
    Runtime.set_character(user_id, character)
    check(Runtime.get_novice_physical_reduction(user_id) == 0,
        "Untrained novice cannot receive purchased rank mitigation")
    character.Progression.Skills.NoviceProtection = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    Runtime.set_character(user_id, character)
    check(math.abs(
        Runtime.get_novice_physical_reduction(user_id) - 0.02
    ) < 0.0001, "Bought novice protection does not defend at level 1")
    character.Level = 19
    Runtime.set_character(user_id, character)
    check(math.abs(
        Runtime.get_novice_physical_reduction(user_id) - 0.02
    ) < 0.0001, "Novice protection expired before level 20")
    character.Level = 20
    Runtime.set_character(user_id, character)
    check(Runtime.get_novice_physical_reduction(user_id) == 0,
        "Novice protection continued after first-transfer level")
    check(not Unlocks.can_train(character, definition, 1),
        "Novice protection remained purchasable after level 19")
    character.Level = 10
    character.Identity.BaseClassId = "Rogue"
    Runtime.set_character(user_id, character)
    check(Runtime.get_novice_physical_reduction(user_id) == 0,
        "Forged novice protection granted a foreign class reduction")
    Runtime.clear_character(user_id)
end

local user_id = 77800
for _, race_id in ipairs(SOURCE_RACES) do
    for _, class_id in ipairs(SOURCE_CLASSES) do
        user_id += 1
        check_novice(race_id, class_id, user_id)
    end
end
print(("[C4 Novice Protection] PASS: %d assertions.")
    :format(assertions))
