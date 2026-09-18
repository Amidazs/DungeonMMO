--!strict
local DungeonRuntimeContentCatalog = {}

local EXECUTOR_IDS = table.freeze({
    "CombatPack",
    "Boss",
})

local BOSS_FACTORY_IDS = table.freeze({
    "MarauderCaptain",
    "CorruptedForeman",
})

-- Creates one immutable physical room-slot definition.
local function slot(
    trigger_anchor: string,
    checkpoint_anchor: string,
    environment_room_id: string,
    supports_combat: boolean,
    supports_boss: boolean,
    exit_barrier_room_id: string?,
    boss_spawn_anchor: string?
): any
    return table.freeze({
        TriggerAnchor = trigger_anchor,
        CheckpointAnchor = checkpoint_anchor,
        EnvironmentRoomId = environment_room_id,
        SupportsCombat = supports_combat,
        SupportsBoss = supports_boss,
        ExitBarrierRoomId = exit_barrier_room_id,
        BossSpawnAnchor = boss_spawn_anchor,
    })
end

local LAYOUTS = table.freeze({
    TestDungeon = table.freeze({
        Depth1 = table.freeze({
            Id = "Depth1",
            EntranceAnchor = "Temple.EntrySpawn",
            Slots = table.freeze({
                Room1 = slot(
                    "Temple.Room1.Trigger",
                    "Temple.Room1.Checkpoint",
                    "Room1",
                    true,
                    false,
                    "Room1",
                    nil
                ),
                Room2 = slot(
                    "Temple.Room2.Trigger",
                    "Temple.Room2.Checkpoint",
                    "Room2",
                    true,
                    false,
                    "Room2",
                    nil
                ),

                Room3 = slot(
                    "Temple.Room3.Trigger",
                    "Temple.Room3.Checkpoint",
                    "Room3",
                    false,
                    true,
                    nil,
                    "Temple.Room3.CaptainSpawn"
                ),
            }),
        }),
    }),
    AbandonedMine = table.freeze({
        Depth1 = table.freeze({
            Id = "Depth1",
            EntranceAnchor = "Mine.EntrySpawn",
            Slots = table.freeze({
                Room1 = slot(
                    "Mine.Room1.Trigger",
                    "Mine.Room1.Checkpoint",
                    "Room1",
                    true,
                    false,
                    "Room1",
                    nil
                ),

                Room2 = slot(
                    "Mine.Room2.Trigger",
                    "Mine.Room2.Checkpoint",
                    "Room2",
                    true,
                    false,
                    "Room2",
                    nil
                ),
                Room3 = slot(
                    "Mine.Room3.Trigger",
                    "Mine.Room3.Checkpoint",
                    "Room3",
                    false,
                    true,
                    nil,
                    "Mine.Room3.ForemanSpawn"
                ),
            }),
        }),
    }),
})

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

local EXECUTORS = table.freeze({
    CombatPack = true,
    Boss = true,
})

local BOSS_FACTORIES = table.freeze({
    MarauderCaptain = true,
    CorruptedForeman = true,
})

-- Returns one registered physical layout.
function DungeonRuntimeContentCatalog.get_layout(
    dungeon_id: string,
    layout_id: string
): any?
    local dungeon = LAYOUTS[dungeon_id]
    if not dungeon then
        return nil
    end
    return dungeon[layout_id]
end

-- Returns one registered combat-pack specification.
function DungeonRuntimeContentCatalog.get_pack(
    dungeon_id: string,
    pack_id: string
): any?

    local dungeon = PACKS[dungeon_id]
    if not dungeon then
        return nil
    end
    return dungeon[pack_id]
end

-- Returns one registered boss-content specification.
function DungeonRuntimeContentCatalog.get_boss(
    boss_id: string
): any?
    return BOSSES[boss_id]
end

-- Returns whether an encounter executor is implemented by the Dungeon server.
function DungeonRuntimeContentCatalog.is_executor_implemented(
    executor_id: string
): boolean
    return EXECUTORS[executor_id] == true
end

-- Returns whether a boss factory is implemented by the Dungeon server.
function DungeonRuntimeContentCatalog.is_boss_factory_implemented(
    factory_id: string
): boolean
    return BOSS_FACTORIES[factory_id] == true
end

-- Returns the stable implemented executor IDs.
function DungeonRuntimeContentCatalog.executor_ids(): {string}

    local result = {}
    for _, executor_id in ipairs(EXECUTOR_IDS) do
        table.insert(result, executor_id)
    end
    return result
end

-- Returns the stable implemented boss-factory IDs.
function DungeonRuntimeContentCatalog.boss_factory_ids(): {string}
    local result = {}
    for _, factory_id in ipairs(BOSS_FACTORY_IDS) do
        table.insert(result, factory_id)
    end
    return result
end

return table.freeze(DungeonRuntimeContentCatalog)
