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

local ENEMY_FACTORY_IDS = table.freeze({
    "Marauder",
})

local ENEMY_ARCHETYPES = table.freeze({
    Marauder = table.freeze({
        FactoryId = "Marauder",
        RewardKey = "StandardMarauderReward",
        MaxHealthKey = "StandardMarauderMaxHealth",
    }),
})

local ENEMY_FACTORIES = table.freeze({
    Marauder = true,
})

-- Creates one immutable physical room-slot definition.
local function slot(
    trigger_anchor: string,
    checkpoint_anchor: string,
    environment_room_id: string,
    enemy_spawn_group: string?,
    enemy_spawn_prefix: string?,
    enemy_spawn_min_count: number?,
    supports_combat: boolean,
    supports_boss: boolean,
    exit_barrier_room_id: string?,
    exit_barrier_anchor: string?,
    boss_spawn_anchor: string?
): any
    return table.freeze({
        TriggerAnchor = trigger_anchor,
        CheckpointAnchor = checkpoint_anchor,
        EnvironmentRoomId = environment_room_id,
        EnemySpawnGroup = enemy_spawn_group,
        EnemySpawnPrefix = enemy_spawn_prefix,
        EnemySpawnMinCount = enemy_spawn_min_count,
        SupportsCombat = supports_combat,
        SupportsBoss = supports_boss,
        ExitBarrierRoomId = exit_barrier_room_id,
        ExitBarrierAnchor = exit_barrier_anchor,
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
                    "Room1EnemySpawns",
                    "Temple.Room1.EnemySpawn.",
                    2,
                    true,
                    false,
                    "Room1",
                    "Temple.Room1.ExitBarrier",
                    nil
                ),
                Room2 = slot(
                    "Temple.Room2.Trigger",
                    "Temple.Room2.Checkpoint",
                    "Room2",
                    "Room2EnemySpawns",
                    "Temple.Room2.EnemySpawn.",
                    3,
                    true,
                    false,
                    "Room2",
                    "Temple.Room2.ExitBarrier",
                    nil
                ),

                Room3 = slot(
                    "Temple.Room3.Trigger",
                    "Temple.Room3.Checkpoint",
                    "Room3",
                    nil,
                    nil,
                    nil,
                    false,
                    true,
                    nil,
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
                    "MineRoom1EnemySpawns",
                    "Mine.Room1.EnemySpawn.",
                    3,
                    true,
                    false,
                    "Room1",
                    "Mine.Room1.ExitBarrier",
                    nil
                ),

                Room2 = slot(
                    "Mine.Room2.Trigger",
                    "Mine.Room2.Checkpoint",
                    "Room2",
                    "MineRoom2EnemySpawns",
                    "Mine.Room2.EnemySpawn.",
                    4,
                    true,
                    false,
                    "Room2",
                    "Mine.Room2.ExitBarrier",
                    nil
                ),
                Room3 = slot(
                    "Mine.Room3.Trigger",
                    "Mine.Room3.Checkpoint",
                    "Room3",
                    nil,
                    nil,
                    nil,
                    false,
                    true,
                    nil,
                    nil,
                    "Mine.Room3.ForemanSpawn"
                ),
            }),
        }),
    }),
})

local function pack_entry(
    entry_id: string,
    enemy_archetype_id: string,
    base_count: number,
    enemy_name_prefix: string,
    spawn_index_base: number
): any
    return table.freeze({
        EntryId = entry_id,
        EnemyArchetypeId = enemy_archetype_id,
        BaseCount = base_count,
        EnemyNamePrefix = enemy_name_prefix,
        SpawnIndexBase = spawn_index_base,
    })
end

local PACKS = table.freeze({
    TestDungeon = table.freeze({
        StandardRoom1 = table.freeze({
            Entries = table.freeze({
                pack_entry(
                    "Marauders",
                    "Marauder",
                    2,
                    "Room1_Marauder_",
                    100
                ),
            }),
            BonusRules = table.freeze({}),
        }),
        StandardRoom2 = table.freeze({
            Entries = table.freeze({
                pack_entry(
                    "Marauders",
                    "Marauder",
                    3,
                    "Room2_Marauder_",
                    200
                ),
            }),
            BonusRules = table.freeze({}),
        }),
    }),
    AbandonedMine = table.freeze({
        StandardRoom1 = table.freeze({
            Entries = table.freeze({
                pack_entry(
                    "Marauders",
                    "Marauder",
                    2,
                    "Room1_Marauder_",
                    100
                ),
            }),
            BonusRules = table.freeze({
                table.freeze({
                    Type = "InstanceFlag",
                    Key = "EventActive",
                    Value = true,
                    EntryId = "Marauders",
                    Add = 1,
                }),
            }),
        }),
        StandardRoom2 = table.freeze({
            Entries = table.freeze({
                pack_entry(
                    "Marauders",
                    "Marauder",
                    3,
                    "Room2_Marauder_",
                    200
                ),
            }),
            BonusRules = table.freeze({
                table.freeze({
                    Type = "RareState",
                    Id = "CrystalBloom",
                    EntryId = "Marauders",
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

-- Returns one registered enemy-archetype specification.
function DungeonRuntimeContentCatalog.get_enemy_archetype(
    archetype_id: string
): any?
    return ENEMY_ARCHETYPES[archetype_id]
end

-- Returns whether an enemy factory is implemented by the Dungeon server.
function DungeonRuntimeContentCatalog.is_enemy_factory_implemented(
    factory_id: string
): boolean
    return ENEMY_FACTORIES[factory_id] == true
end

-- Returns the stable implemented enemy-factory IDs.
function DungeonRuntimeContentCatalog.enemy_factory_ids(): {string}
    local result = {}
    for _, factory_id in ipairs(ENEMY_FACTORY_IDS) do
        table.insert(result, factory_id)
    end
    return result
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
