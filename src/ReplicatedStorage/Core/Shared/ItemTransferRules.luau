--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemDefinitions = require(
    ReplicatedStorage
        :WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("ItemDefinitions")
)

local ItemTransferRules = {}

function ItemTransferRules.can_trade(item_id: string): (boolean, string?)
    if type(item_id) ~= "string" or item_id == "" then
        return false, "UnknownItem"
    end
    local definition = ItemDefinitions.get(item_id)
    if not definition then
        return false, "UnknownItem"
    end
    if definition.Bound == true or definition.Tradeable == false then
        return false, "ItemNotTradeable"
    end
    return true, nil
end

function ItemTransferRules.can_bank(item_id: string): (boolean, string?)
    if type(item_id) ~= "string" or item_id == "" then
        return false, "UnknownItem"
    end

    local definition = ItemDefinitions.get(item_id)
    if not definition then
        return false, "UnknownItem"
    end

    if definition.Bound == true or definition.Tradeable == false then
        return false, "ItemNotBankable"
    end

    return true, nil
end

return table.freeze(ItemTransferRules)
