--!strict
local DungeonEnemyFactoryRegistry = {}
DungeonEnemyFactoryRegistry.__index =
    DungeonEnemyFactoryRegistry

local function result(
    ok: boolean,
    reason: string?
): any
    return {
        ok = ok,
        reason = reason,
    }
end

-- Creates an empty server-owned enemy-factory registry.
function DungeonEnemyFactoryRegistry.new(): any
    return setmetatable({
        _factories = {},
    }, DungeonEnemyFactoryRegistry)
end

-- Registers one stable enemy FactoryId exactly once.
function DungeonEnemyFactoryRegistry:register(
    factory_id: string,
    factory: any
): any

    if type(factory_id) ~= "string"
        or factory_id == ""
        or type(factory) ~= "table"
        or type(factory.create) ~= "function"
    then
        return result(false, "InvalidEnemyFactory")
    end

    if self._factories[factory_id] ~= nil then
        return result(false, "EnemyFactoryAlreadyRegistered")
    end

    self._factories[factory_id] = factory
    return result(true, nil)
end

-- Returns the registered factory for one stable FactoryId.
function DungeonEnemyFactoryRegistry:get(
    factory_id: string
): any?
    return self._factories[factory_id]
end

-- Returns whether one stable FactoryId is registered.
function DungeonEnemyFactoryRegistry:is_registered(
    factory_id: string
): boolean
    return self:get(factory_id) ~= nil
end

return table.freeze(DungeonEnemyFactoryRegistry)
