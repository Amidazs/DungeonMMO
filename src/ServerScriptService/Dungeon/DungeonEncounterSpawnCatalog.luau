--!strict
local DungeonEncounterSpawnCatalog = {}

local PACKS = table.freeze({
    TestDungeon = table.freeze({
        StandardRoom1 = table.freeze({
            BaseCount = 2,
            RewardKey = "StandardMarauderReward",
            MaxHealthKey = "StandardMarauderMaxHealth",
            EnemyNamePrefix = "Room1_Marauder_",
            SpawnIndexBase = 100,
            BonusRules = table.freeze({}),
        }),
        StandardRoom2 = table.freeze({
            BaseCount = 3,
            RewardKey = "StandardMarauderReward",
            MaxHealthKey = "StandardMarauderMaxHealth",
            EnemyNamePrefix = "Room2_Marauder_",
            SpawnIndexBase = 200,
            BonusRules = table.freeze({}),
        }),
    }),
    AbandonedMine = table.freeze({
        StandardRoom1 = table.freeze({
            BaseCount = 2,
            RewardKey = "StandardMarauderReward",
            MaxHealthKey = "StandardMarauderMaxHealth",
            EnemyNamePrefix = "Room1_Marauder_",
            SpawnIndexBase = 100,
            BonusRules = table.freeze({
                table.freeze({
                    Type = "InstanceFlag",
                    Key = "EventActive",
                    Value = true,
                    Add = 1,
                }),
            }),
        }),
        StandardRoom2 = table.freeze({
            BaseCount = 3,
            RewardKey = "StandardMarauderReward",
            MaxHealthKey = "StandardMarauderMaxHealth",
            EnemyNamePrefix = "Room2_Marauder_",
            SpawnIndexBase = 200,
            BonusRules = table.freeze({
                table.freeze({
                    Type = "RareState",
                    Id = "CrystalBloom",
                    Add = 1,
                }),
            }),
        }),
    }),
})

local BOSSES = table.freeze({
    MarauderCaptain = table.freeze({
        FactoryId = "MarauderCaptain",
        RewardKey = "MarauderCaptainReward",
        DisplayName = "Marauder Captain",
    }),
    CorruptedForeman = table.freeze({
        FactoryId = "CorruptedForeman",
        RewardKey = "MarauderCaptainReward",
        DisplayName = "Corrupted Foreman",
    }),
})

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
    local dungeon_packs = PACKS[dungeon_id]
    if not dungeon_packs then
        return nil
    end

    return dungeon_packs[pack_id]
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
    return BOSSES[boss_id]
end

return table.freeze(DungeonEncounterSpawnCatalog)
