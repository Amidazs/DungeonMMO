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

-- Resolves a pack count from immutable server-owned instance state.
function DungeonEncounterSpawnCatalog.resolve_pack_count(
    pack: any,
    instance_state: any?
): number
    local count = math.max(
        0,
        math.floor(tonumber(pack.BaseCount) or 0)
    )
    local state = if type(instance_state) == "table"
        then instance_state
        else {}

    for _, rule in ipairs(pack.BonusRules or {}) do
        if rule_matches(rule, state) then
            count += math.max(
                0,
                math.floor(tonumber(rule.Add) or 0)
            )
        end
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
