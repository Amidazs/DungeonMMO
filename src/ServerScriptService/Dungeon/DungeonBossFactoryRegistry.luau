--!strict
local DungeonBossFactoryRegistry = {}
DungeonBossFactoryRegistry.__index = DungeonBossFactoryRegistry

local function result(
    ok: boolean,
    reason: string?
): any
    return {
        ok = ok,
        reason = reason,
    }
end

-- Creates an empty server-owned boss-factory registry.
function DungeonBossFactoryRegistry.new(): any
    return setmetatable({
        _factories = {},
    }, DungeonBossFactoryRegistry)
end

-- Registers one stable BossId exactly once.
function DungeonBossFactoryRegistry:register(
    boss_id: string,
    factory: any
): any
    if type(boss_id) ~= "string"
        or boss_id == ""
        or type(factory) ~= "table"
        or type(factory.create) ~= "function"
    then
        return result(false, "InvalidBossFactory")
    end

    if self._factories[boss_id] ~= nil then
        return result(false, "BossFactoryAlreadyRegistered")
    end

    self._factories[boss_id] = factory
    return result(true, nil)
end

-- Returns the registered factory for one BossId.
function DungeonBossFactoryRegistry:get(
    boss_id: string
): any?
    return self._factories[boss_id]
end

return table.freeze(DungeonBossFactoryRegistry)
