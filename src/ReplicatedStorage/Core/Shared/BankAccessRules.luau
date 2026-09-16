--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BankConfig = require(
    ReplicatedStorage
        :WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("BankConfig")
)

local BankAccessRules = {}

function BankAccessRules.within_distance(
    character_position: Vector3,
    bank_position: Vector3
): boolean
    if typeof(character_position) ~= "Vector3"
        or typeof(bank_position) ~= "Vector3"
    then
        return false
    end

    return (character_position - bank_position).Magnitude
        <= BankConfig.ACCESS_DISTANCE
end

return table.freeze(BankAccessRules)
