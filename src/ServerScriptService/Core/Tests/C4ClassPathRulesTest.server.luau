--!strict
-- Original C4 selection must be explicit, earned and quest-backed.
local RS = game:GetService("ReplicatedStorage")
local Shared = RS.Core.Shared
local Schema = require(Shared.ProfileSchema)
local Rules = require(Shared.C4ClassPathRules)

local checks = 0

--[[
Checks one protected original class selection or level/quest invariant.

Args:
    condition (boolean): True only for expected original C4 behavior.
    label (string): Specific failed selection rule.

Returns:
    nil: Adds one actual assertion or fails the Studio test.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Class Path Rules] " .. label)
end

--[[
Builds a genuine original source starting-class profile for one race.

Args:
    user_id (number): Isolated profile character identity.
    race_id (string): Original source race for the request.
    class_id (string): Original Fighter/Mage or legacy game specialist.

Returns:
    any: Detached character used solely for source validation.
]]
local function character_for(
    user_id: number, race_id: string, class_id: string
): any
    local character = Schema.create_default(user_id).Characters.Slot1
    character.Identity = {
        Version = 1,
        RaceId = race_id,
        BaseClassId = class_id,
        ClassId = class_id,
        CreationStage = "Complete",
    }
    character.Level = 18
    return character
end

--[[
Checks correct explicit source choice and impossible early/gratis transfers.

Args:
    None.

Returns:
    nil: Proves level and source quest block unsupported class awards.
]]
local function check_human()
    local fighter = character_for(99811, "Human", "Fighter")
    local choices = Rules.options(fighter)
    check(choices.ok and #choices.branches == 3,
        "Human Fighter must choose explicitly among three paths")
    fighter.Level = 17
    local too_early = Rules.validate(
        fighter, "HumanRogue", "QuestStart"
    )
    check(too_early.reason == "OriginalTransferLevelTooLow",
        "Level 17 must not start its original level-18 class quest")
    fighter.Level = 18
    local quest = Rules.validate(
        fighter, "HumanRogue", "QuestStart"
    )
    check(quest.reason == "OriginalQuestNotImplemented",
        "An authored quest name alone cannot fake implemented objectives")
    check(quest.branch.Id == "HumanRogue",
        "Quest refusal still identifies the player's exact chosen class")
    local before_transfer = Rules.validate(
        fighter, "HumanRogue", "Transfer"
    )
    check(before_transfer.reason == "OriginalTransferLevelTooLow",
        "Completing a source quest at 18 cannot transfer before 20")
    fighter.Level = 20
    check(Rules.validate(
        fighter, "HumanRogue", "Transfer"
    ).reason == "OriginalQuestNotImplemented",
        "Complete mapped ranks cannot bypass a missing branch quest")
    check(Rules.validate(
        fighter, "ElvenScout", "Transfer"
    ).reason == "OriginalClassChoiceUnavailable",
        "Wrong race's path cannot be selected by a Human Fighter")
    check(Rules.validate(
        fighter, "HumanRogue", "InstantTransfer"
    ).reason == "InvalidTransferPhase",
        "Client cannot invent a faster advancement phase")
end

--[[
Checks source races not yet playable and old role IDs cannot auto-advance.

Args:
    None.

Returns:
    nil: Verifies source catalogue does not silently enable broken gameplay.
]]
local function check_unimplemented_families()
    local dwarf = character_for(99812, "Dwarf", "Fighter")
    check(Rules.options(dwarf).reason == "OriginalRaceNotYetPlayable",
        "Dwarf source metadata cannot unlock an unimplemented race")
    local human_legacy = character_for(99813, "Human", "Rogue")
    check(Rules.options(human_legacy).reason
        == "OriginalStartingClassRequired",
        "Legacy Rogue starting role cannot skip original Fighter path")
    local mage = character_for(99814, "Elf", "Mage")
    local choices = Rules.options(mage)
    check(choices.ok and #choices.branches == 2,
        "Elven Mystic must have original Wizard/Oracle choices")
    check(Rules.validate(
        mage, "ElvenOracle", "QuestStart"
    ).reason == "OriginalQuestNotImplemented",
        "An unmapped Oracle may not be awarded via a generic Mage quest")
    check(Rules.validate(
        mage, "HumanCleric", "QuestStart"
    ).reason == "OriginalClassChoiceUnavailable",
        "Cross-race Mystic healing path must be rejected")
    check(Rules.validate(
        mage, "HumanWizard", "QuestStart"
    ).reason == "OriginalClassChoiceUnavailable",
        "Similar Wizard combat roles are not equivalent class identities")
end

--[[
Runs genuine original C4 progression decision and fail-closed tests.

Args:
    None.

Returns:
    nil: Emits the number of successfully verified pathway gates.
]]
local function main()
    check_human()
    check_unimplemented_families()
    print(("[C4 Class Path Rules] PASS: %d assertions")
        :format(checks))
end

main()
