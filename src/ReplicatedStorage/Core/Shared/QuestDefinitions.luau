--!strict
local DungeonDefinitions = require(script.Parent.DungeonDefinitions)
local CharacterIdentityRules = require(script.Parent.CharacterIdentityRules)

local QuestDefinitions = {}

local DEFINITIONS = table.freeze({
    MageAdvancementTrial = table.freeze({
        Id = "MageAdvancementTrial",
        DisplayName = "Mage Advancement Trial",
        Kind = "ClassAdvancement",
        MinimumLevel = 20,
        AllowedRaces = table.freeze({"Human", "Elf"}),
        AllowedBaseClasses = table.freeze({"Mage"}),
        Objectives = table.freeze({
            table.freeze({
                Id = "ClearTemple",
                Type = "DungeonClear",
                TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
                Required = 1,
            }),
        }),
    }),

    RogueAdvancementTrial = table.freeze({
        Id = "RogueAdvancementTrial",
        DisplayName = "Rogue Advancement Trial",
        Kind = "ClassAdvancement",
        MinimumLevel = 20,
        AllowedRaces = table.freeze({"Human", "Elf"}),
        AllowedBaseClasses = table.freeze({"Rogue"}),
        Objectives = table.freeze({
            table.freeze({
                Id = "ClearAbandonedMine",
                Type = "DungeonClear",
                TargetId = DungeonDefinitions.ABANDONED_MINE.Id,
                Required = 1,
            }),
        }),
    }),
})

local function list_contains(values: any, expected: string): boolean
    if type(values) ~= "table" then
        return false
    end

    for _, value in ipairs(values) do
        if value == expected then
            return true
        end
    end

    return false
end

function QuestDefinitions.get(quest_id: string): any?
    return DEFINITIONS[quest_id]
end

function QuestDefinitions.is_character_eligible(
    character: any,
    definition: any
): boolean
    if type(character) ~= "table"
        or type(definition) ~= "table"
        or not CharacterIdentityRules.is_complete(character)
    then
        return false
    end

    local identity = character.Identity
    local race_id = identity.RaceId
    local base_class_id = identity.BaseClassId
    local level = tonumber(character.Level) or 0

    return (
        type(race_id) == "string"
        and type(base_class_id) == "string"
        and level >= (tonumber(definition.MinimumLevel) or 1)
        and list_contains(definition.AllowedRaces, race_id)
        and list_contains(definition.AllowedBaseClasses, base_class_id)
    )
end

function QuestDefinitions.objective_matches(
    objective: any,
    event: any
): boolean
    if type(objective) ~= "table" or type(event) ~= "table" then
        return false
    end

    if objective.Type ~= event.Type then
        return false
    end

    if type(objective.TargetId) == "string"
        and objective.TargetId ~= event.TargetId
    then
        return false
    end

    return true
end

return table.freeze(QuestDefinitions)
