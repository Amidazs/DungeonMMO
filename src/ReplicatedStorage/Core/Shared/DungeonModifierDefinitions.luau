--!strict

local DungeonModifierDefinitions = {}

local ORDER = table.freeze({
    "Fortified",
    "RichDeposits",
    "Bounty",
})

local DEFINITIONS = table.freeze({
    Fortified = table.freeze({
        Id = "Fortified",
        DisplayName = "Fortified",
        EnemyHealthMultiplier = 1.20,
    }),
    RichDeposits = table.freeze({
        Id = "RichDeposits",
        DisplayName = "Rich Deposits",
        GatherYieldBonus = 1,
    }),
    Bounty = table.freeze({
        Id = "Bounty",
        DisplayName = "Bounty",
        MonsterGoldMultiplier = 1.10,
    }),
})
local function stable_hash(value: string): number
    local hash = 2166136261
    for index = 1, #value do
        hash = bit32.bxor(hash, string.byte(value, index))
        hash = (hash * 16777619) % 4294967296
    end
    return hash
end

function DungeonModifierDefinitions.get(id: string): any?
    return DEFINITIONS[id]
end

function DungeonModifierDefinitions.all(): {any}
    local result = {}
    for _, id in ipairs(ORDER) do
        table.insert(result, DEFINITIONS[id])
    end
    return result
end

function DungeonModifierDefinitions.resolve(
    dungeon_id: string,
    session_id: string,
    rotation_key: string
): string
    local seed = table.concat({dungeon_id, session_id, rotation_key}, ":")
    local index = (stable_hash(seed) % #ORDER) + 1
    return ORDER[index]
end

return table.freeze(DungeonModifierDefinitions)
