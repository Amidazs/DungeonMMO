--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local DungeonRuntimeContentCatalog = require(
    Shared:WaitForChild("DungeonRuntimeContentCatalog")
)

local DungeonEncounterSpawnCatalog = {}

-- Returns whether one immutable instance-state bonus rule applies.
local function rule_matches(rule: any, state: any): boolean
    if rule.Type == "InstanceFlag" then
        return type(rule.Key) == "string"
            and state[rule.Key] == rule.Value
    end

    if rule.Type == "RareState" then
        return type(rule.Id) == "string"
            and state.RareStateId == rule.Id
    end

    return false
end

-- Returns one server-owned combat-pack spawn specification.
function DungeonEncounterSpawnCatalog.get_pack(
    dungeon_id: string,
    pack_id: string
): any?
    return DungeonRuntimeContentCatalog.get_pack(
        dungeon_id,
        pack_id
    )
end

-- Returns one registered enemy-archetype spawn specification.
function DungeonEncounterSpawnCatalog.get_enemy_archetype(
    archetype_id: string
): any?
    return DungeonRuntimeContentCatalog.get_enemy_archetype(
        archetype_id
    )
end

-- Resolves ordered entry counts from immutable server-owned instance state.
function DungeonEncounterSpawnCatalog.resolve_pack_entries(
    pack: any,
    instance_state: any?
): {any}
    local state = if type(instance_state) == "table"
        then instance_state
        else {}
    local resolved = {}

    for _, entry in ipairs(pack.Entries or {}) do
        local count = math.max(
            0,
            math.floor(tonumber(entry.BaseCount) or 0)
        )

        for _, rule in ipairs(pack.BonusRules or {}) do
            if rule.EntryId == entry.EntryId
                and rule_matches(rule, state)
            then
                count += math.max(
                    0,
                    math.floor(tonumber(rule.Add) or 0)
                )
            end
        end

        table.insert(resolved, {
            Entry = entry,
            Count = count,
        })
    end

    return resolved
end

-- Resolves the total number of enemies in one combat pack.
function DungeonEncounterSpawnCatalog.resolve_pack_count(
    pack: any,
    instance_state: any?
): number
    local count = 0

    for _, resolved in ipairs(
        DungeonEncounterSpawnCatalog.resolve_pack_entries(
            pack,
            instance_state
        )
    ) do
        count += resolved.Count
    end

    return count
end

-- Returns one implemented boss spawn specification.
function DungeonEncounterSpawnCatalog.get_boss(
    boss_id: string
): any?
    return DungeonRuntimeContentCatalog.get_boss(boss_id)
end

return table.freeze(DungeonEncounterSpawnCatalog)
