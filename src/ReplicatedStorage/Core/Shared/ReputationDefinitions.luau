--!strict
local ReputationDefinitions = {}

local DEFINITIONS = table.freeze({
    Scholars = table.freeze({
        Id = "Scholars",
        DisplayName = "Scholars",
    }),
})

function ReputationDefinitions.get(faction_id: string): any?
    return DEFINITIONS[faction_id]
end

function ReputationDefinitions.all(): {[string]: any}
    return DEFINITIONS
end

function ReputationDefinitions.validate(): (boolean, string?)
    for faction_id, definition in pairs(DEFINITIONS) do
        if type(faction_id) ~= "string" or faction_id == "" then
            return false, "InvalidFactionId"
        end
        if type(definition) ~= "table"
            or definition.Id ~= faction_id
            or type(definition.DisplayName) ~= "string"
            or definition.DisplayName == ""
        then
            return false, "InvalidFactionDefinition:" .. faction_id
        end
    end
    return true, nil
end

return table.freeze(ReputationDefinitions)