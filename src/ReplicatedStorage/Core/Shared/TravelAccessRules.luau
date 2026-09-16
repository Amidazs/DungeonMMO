--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TravelConfig = require(
    ReplicatedStorage
        :WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("TravelConfig")
)

local TravelAccessRules = {}

function TravelAccessRules.within_service_distance(
    character_position: Vector3,
    service_position: Vector3
): boolean
    if typeof(character_position) ~= "Vector3"
        or typeof(service_position) ~= "Vector3"
    then
        return false
    end

    return (character_position - service_position).Magnitude
        <= TravelConfig.ACCESS_DISTANCE
end

function TravelAccessRules.already_at_destination(
    character_position: Vector3,
    destination_position: Vector3
): boolean
    if typeof(character_position) ~= "Vector3"
        or typeof(destination_position) ~= "Vector3"
    then
        return false
    end

    return (character_position - destination_position).Magnitude
        <= TravelConfig.ALREADY_THERE_DISTANCE
end

return table.freeze(TravelAccessRules)
