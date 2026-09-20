--!strict
-- Two deterministic, non-boss side encounters using the registered
-- CombatPack executor. No new client-triggered scheduler or reward service.
local Catalog = {}

local VARIANTS = table.freeze({
    TestDungeon = table.freeze({
        Ambush = table.freeze({
            Id = "TempleRelicAmbush",
            PackId = "TempleRelicAmbush",
            EnemyCount = 4,
            DisplayName = "Relic ambush",
        }),
        Surge = table.freeze({
            Id = "TempleGuardianSurge",
            PackId = "TempleGuardianSurge",
            EnemyCount = 8,
            DisplayName = "Guardian surge",
        }),
    }),
    AbandonedMine = table.freeze({
        Ambush = table.freeze({
            Id = "MineTunnelAmbush",
            PackId = "MineTunnelAmbush",
            EnemyCount = 4,
            DisplayName = "Tunnel ambush",
        }),
        Surge = table.freeze({
            Id = "MineDeepSurge",
            PackId = "MineDeepSurge",
            EnemyCount = 8,
            DisplayName = "Deep surge",
        }),
    }),
})

-- Looks up ONLY an explicitly registered, immutable server-selected variant.
function Catalog.get(dungeon_id: string, mechanic_id: string): any?
    local dungeon = VARIANTS[dungeon_id]
    return dungeon and dungeon[mechanic_id] or nil
end

-- Uses the same saved run seed on every recovery; issuer freezes this choice.
function Catalog.select(dungeon_id: string, seed: number): (string?, any?)
    if type(seed) ~= "number" or seed % 1 ~= 0
        or seed < 0 or seed == math.huge
    then
        return nil, nil
    end
    local id = if math.floor(seed / 2) % 2 == 0
        then "Ambush" else "Surge"
    return id, Catalog.get(dungeon_id, id)
end

return table.freeze(Catalog)
