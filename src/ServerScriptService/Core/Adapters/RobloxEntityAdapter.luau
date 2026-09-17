--!strict
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EnvironmentConfig = require(
    ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared"):WaitForChild("EnvironmentConfig")
)

local RobloxEntityAdapter = {}

function RobloxEntityAdapter.new(namespace: string): any
    assert(type(namespace) == "string" and namespace ~= "", "namespace required")
    local environment = EnvironmentConfig.get_environment()
    local store = DataStoreService:GetDataStore(
        environment .. "_DungeonMMO_" .. namespace .. "_v1"
    )
    local adapter = {}

    function adapter:load(key: string): (any?, string?)
        local ok, value = pcall(function()
            return store:GetAsync(key)
        end)
        if not ok then
            warn("[Shared Entity Persistence] GetAsync failed: " .. tostring(value))
            return nil, "DataStoreGetFailed"
        end
        return value, nil
    end

    function adapter:update(key: string, transform: (any?) -> any): (any?, string?)
        local ok, value = pcall(function()
            return store:UpdateAsync(key, function(old)
                return transform(old)
            end)
        end)
        if not ok then
            warn("[Shared Entity Persistence] UpdateAsync failed: " .. tostring(value))
            return nil, "DataStoreUpdateFailed"
        end
        if value == nil then
            return nil, "DataStoreUpdateCancelled"
        end
        return value, nil
    end

    function adapter:remove(key: string): (boolean, string?)
        local ok, err = pcall(function()
            store:RemoveAsync(key)
        end)
        if not ok then
            warn("[Shared Entity Persistence] RemoveAsync failed: " .. tostring(err))
            return false, "DataStoreRemoveFailed"
        end
        return true, nil
    end

    return table.freeze(adapter)
end

return table.freeze(RobloxEntityAdapter)
