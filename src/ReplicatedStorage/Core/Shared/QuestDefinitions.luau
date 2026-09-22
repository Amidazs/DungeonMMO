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

    WorldrootRelic = table.freeze({
        Id = "WorldrootRelic",
        DisplayName = "A Relic Beneath the World Tree",
        Kind = "Adventure",
        MinimumLevel = 1,
        AllowedRaces = table.freeze({"Human", "Elf"}),
        AllowedBaseClasses = table.freeze({
            "Fighter", "Mage", "Ranger", "Rogue",
        }),
        Objectives = table.freeze({
            table.freeze({
                Id = "ClearTemple",
                Type = "DungeonClear",
                TargetId = DungeonDefinitions.TEST_DUNGEON.Id,
                Required = 1,
            }),
        }),
        Reward = table.freeze({
            Gold = 25,
            ItemId = "worldroot_relic",
            Quantity = 1,
        }),
    }),

    MineEchoes = table.freeze({
        Id = "MineEchoes",
        DisplayName = "Echoes from the Abandoned Mine",
        Kind = "Adventure",
        MinimumLevel = 1,
        PrerequisiteQuestId = "WorldrootRelic",
        AllowedRaces = table.freeze({"Human", "Elf"}),
        AllowedBaseClasses = table.freeze({
            "Fighter", "Mage", "Ranger", "Rogue",
        }),
        Objectives = table.freeze({
            table.freeze({
                Id = "ClearAbandonedMine",
                Type = "DungeonClear",
                TargetId = DungeonDefinitions.ABANDONED_MINE.Id,
                Required = 1,
            }),
        }),
        Reward = table.freeze({
            Gold = 50,
            ItemId = "iron_ore",
            Quantity = 5,
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

-- Returns available non-advancement quest definitions in story order.
--
-- Args:
--   None.
-- Returns:
--   {any}: Frozen quest catalogue for server-authorized board snapshots.
function QuestDefinitions.adventures(): {any}
    return table.freeze({
        DEFINITIONS.WorldrootRelic,
        DEFINITIONS.MineEchoes,
    })
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
        and (
            definition.PrerequisiteQuestId == nil
            or (
                type(character.Quests) == "table"
                and type(character.Quests.Completed) == "table"
                and character.Quests.Completed[
                    definition.PrerequisiteQuestId
                ] == true
            )
        )
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
