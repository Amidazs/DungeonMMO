--!strict
local DungeonRoomLayoutDefinitions = {}

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

-- Returns one registered physical dungeon layout.
function DungeonRoomLayoutDefinitions.get(
    dungeon_id: string,
    layout_id: string
): any?
    local dungeon = LAYOUTS[dungeon_id]
    if not dungeon then
        return nil
    end
    return dungeon[layout_id]
end

-- Returns whether a physical layout is currently registered.
function DungeonRoomLayoutDefinitions.is_registered(
    dungeon_id: string,
    layout_id: string
): boolean
    return DungeonRoomLayoutDefinitions.get(
        dungeon_id,
        layout_id
    ) ~= nil
end

return table.freeze(DungeonRoomLayoutDefinitions)
