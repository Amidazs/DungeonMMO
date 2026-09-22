--!strict
-- C4 Fighter and Scout seated/moving stamina recovery rank effects.

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Shared = RS.Core.Shared

local Schema = require(Shared.ProfileSchema)
local Skills = require(Shared.SkillProgressionDefinitions)
local Unlocks = require(Shared.SkillUnlockRules)
local Trainers = require(Shared.TrainerCatalogues)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)

local assertions = 0

--[[
Checks one authoritative source-rank or conditional resource effect.

Args:
    condition (boolean): The expected rank or resource invariant.
    description (string): Diagnostic of a failed condition.

Returns:
    nil: Increments the passing assertion count or raises.
]]
local function check(condition: boolean, description: string)
    assertions += 1
    assert(condition, "[C4 Conditional Recovery] " .. description)
end

--[[
Creates a detached valid starting or Scout character.

Args:
    user_id (number): Isolated fake runtime owner.
    race_id (string): Human or Elf.
    class_id (string): Fighter, Ranger, or Rogue.

Returns:
    any: Mutable character for real purchased-rank evaluation.
]]
local function character_for(
    user_id: number, race_id: string, class_id: string
): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = class_id
    character.Identity.ClassId = class_id
    character.Identity.CreationStage = "Complete"
    return character
end

--[[
Verifies Human Fighter's real seated stamina regeneration rank.

Args:
    None.

Returns:
    nil: Asserts level, race, trainer, standing and sitting gates.
]]
local function check_fighter_recovery()
    local user_id = 77871
    local character = character_for(user_id, "Human", "Fighter")
    local definition = assert(Skills.get("FighterRestingRecovery"))
    character.Level = 4
    check(not Unlocks.can_show(character, definition),
        "Fighter recovery appeared below C4 level five")
    character.Level = 5
    check(Trainers.can_offer(
        "FighterTrainer", character, definition.Id
    ).ok, "Human Fighter cannot train resting recovery")
    Runtime.set_character(user_id, character)
    check(Runtime.get_stamina_recovery_multiplier(
        user_id, true, false
    ) == 1, "Untrained Fighter gained sitting recovery")
    character.Progression.Skills[definition.Id] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    Runtime.set_character(user_id, character)
    check(math.abs(
        Runtime.get_stamina_recovery_multiplier(
            user_id, true, false
        ) - 1.15
    ) < 0.0001, "Seated Fighter rank failed to increase recovery")
    check(Runtime.get_stamina_recovery_multiplier(
        user_id, false, true
    ) == 1, "Fighter resting rank leaked into moving recovery")
    character.Identity.RaceId = "Elf"
    Runtime.set_character(user_id, character)
    check(Runtime.get_stamina_recovery_multiplier(
        user_id, true, false
    ) == 1, "Human-only Fighter rank affected an Elf")
    Runtime.clear_character(user_id)
end

--[[
Verifies both source Scout classes have distinct real seated/moving
recovery ranks and cannot transfer Human-only sitting ranks to Elf.

Args:
    race_id (string): Human or Elf source Scout race.
    class_id (string): Ranger or Rogue owner class.
    user_id (number): Isolated server runtime identity.

Returns:
    nil: Proves both source levels, owned rank effect, and race gating.
]]
local function check_scout_recovery(
    race_id: string, class_id: string, user_id: number
)
    local character = character_for(user_id, race_id, class_id)
    local sitting = assert(Skills.get("HumanScoutRestingRecovery"))
    local running = assert(Skills.get("ScoutRunningRecovery"))
    character.Level = 23
    check(not Unlocks.can_show(character, sitting),
        "Human Scout sitting rank appeared before level 24")
    character.Level = 24
    if race_id == "Human" then
        check(Trainers.can_offer(
            class_id .. "Trainer", character, sitting.Id
        ).ok, "Human Scout cannot train level-24 resting recovery")
    else
        check(not Unlocks.can_show(character, sitting),
            "Human-only sitting recovery leaked to Elven Scout")
    end
    character.Level = 35
    check(not Unlocks.can_show(character, running),
        "Scout moving recovery appeared before level 36")
    character.Level = 36
    check(Trainers.can_offer(
        class_id .. "Trainer", character, running.Id
    ).ok, "Real Scout running rank not offered at level 36")
    Runtime.set_character(user_id, character)
    check(Runtime.get_stamina_recovery_multiplier(
        user_id, false, true
    ) == 1, "Untrained Scout gained moving recovery")
    character.Progression.Skills[running.Id] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    if race_id == "Human" then
        character.Progression.Skills[sitting.Id] = {
            Known = true, PurchasedRank = 2, Proficiency = 0,
        }
    end
    Runtime.set_character(user_id, character)
    local sitting_expected = if race_id == "Human"
        then 1.20 else 1
    check(math.abs(
        Runtime.get_stamina_recovery_multiplier(
            user_id, true, false
        ) - sitting_expected
    ) < 0.0001, "Human-only seated Scout recovery wrong")
    check(math.abs(
        Runtime.get_stamina_recovery_multiplier(
            user_id, false, true
        ) - 1.10
    ) < 0.0001, "Actual moving Scout recovery rank was ignored")
    check(Runtime.get_stamina_recovery_multiplier(
        user_id, false, false
    ) == 1, "Idle standing Scout gained conditional recovery")
    character.Identity.BaseClassId = "Mage"
    Runtime.set_character(user_id, character)
    check(Runtime.get_stamina_recovery_multiplier(
        user_id, true, true
    ) == 1, "Foreign class gained forged Scout recovery")
    Runtime.clear_character(user_id)
end

--[[
Runs all supported early source class/race stamina recovery contracts.

Args:
    None.

Returns:
    nil: Reports only fully verified conditions.
]]
local function main()
    check_fighter_recovery()
    local user_id = 77880
    for _, race_id in ipairs({"Human", "Elf"}) do
        for _, class_id in ipairs({"Ranger", "Rogue"}) do
            check_scout_recovery(race_id, class_id, user_id)
            user_id += 1
        end
    end
    print(("[C4 Conditional Recovery] PASS: %d assertions.")
        :format(assertions))
end

main()
