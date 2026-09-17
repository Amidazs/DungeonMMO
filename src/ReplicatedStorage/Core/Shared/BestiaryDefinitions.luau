--!strict
local ReputationDefinitions = require(
    script.Parent:WaitForChild("ReputationDefinitions")
)

local BestiaryDefinitions = {}

local DEFINITIONS = table.freeze({
    marauder = table.freeze({
        Id = "marauder",
        DisplayName = "Marauder",
        Milestones = table.freeze({
            table.freeze({
                Id = "first_defeat",
                RequiredKills = 1,
                Reputation = table.freeze({
                    FactionId = "Scholars",
                    Points = 5,
                }),
            }),
            table.freeze({
                Id = "field_notes",
                RequiredKills = 5,
                Reputation = table.freeze({
                    FactionId = "Scholars",
                    Points = 10,
                }),
            }),
            table.freeze({
                Id = "dossier_complete",
                RequiredKills = 15,
                Reputation = table.freeze({
                    FactionId = "Scholars",
                    Points = 20,
                }),
            }),
        }),
    }),
    marauder_captain = table.freeze({
        Id = "marauder_captain",
        DisplayName = "Marauder Captain",
        Milestones = table.freeze({
            table.freeze({
                Id = "captain_defeated",
                RequiredKills = 1,
                Reputation = table.freeze({
                    FactionId = "Scholars",
                    Points = 15,
                }),
            }),
            table.freeze({
                Id = "captain_studied",
                RequiredKills = 3,
                Reputation = table.freeze({
                    FactionId = "Scholars",
                    Points = 25,
                }),
            }),
        }),
    }),
})

function BestiaryDefinitions.get(creature_id: string): any?
    return DEFINITIONS[creature_id]
end

function BestiaryDefinitions.all(): {[string]: any}
    return DEFINITIONS
end

function BestiaryDefinitions.validate(): (boolean, string?)
    local reputation_ok, reputation_reason =
        ReputationDefinitions.validate()
    if not reputation_ok then
        return false, reputation_reason
    end

    for creature_id, definition in pairs(DEFINITIONS) do
        if definition.Id ~= creature_id
            or type(definition.DisplayName) ~= "string"
            or definition.DisplayName == ""
            or type(definition.Milestones) ~= "table"
        then
            return false, "InvalidCreatureDefinition:" .. creature_id
        end

        local seen = {}
        local last_required = 0

        for _, milestone in ipairs(definition.Milestones) do
            if type(milestone.Id) ~= "string"
                or milestone.Id == ""
                or seen[milestone.Id]
                or type(milestone.RequiredKills) ~= "number"
                or milestone.RequiredKills ~= milestone.RequiredKills
                or milestone.RequiredKills >= math.huge
                or milestone.RequiredKills % 1 ~= 0
                or milestone.RequiredKills <= last_required
            then
                return false, "InvalidMilestone:" .. creature_id
            end

            local reward = milestone.Reputation
            if type(reward) ~= "table"
                or ReputationDefinitions.get(reward.FactionId) == nil
                or type(reward.Points) ~= "number"
                or reward.Points ~= reward.Points
                or reward.Points >= math.huge
                or reward.Points % 1 ~= 0
                or reward.Points <= 0
            then
                return false, "InvalidMilestoneReward:" .. creature_id
            end

            seen[milestone.Id] = true
            last_required = milestone.RequiredKills
        end
    end

    return true, nil
end

return table.freeze(BestiaryDefinitions)