--!strict
-- TEST Temple's replaceable physical blockout layouts. This module does
-- not register anything by itself: the shared catalogue gates each lookup
-- against DungeonTestPlaceholderRelease's exact TEST place allowlist.
local Layouts = {}

local function slot(trigger: string, checkpoint: string,
    room_id: string, group: string?, spawn_prefix: string?,
    min_count: number?, boss_spawn: string?): any
    return table.freeze({
        TriggerAnchor = trigger,
        CheckpointAnchor = checkpoint,
        EnvironmentRoomId = room_id,
        EnemySpawnGroup = group,
        EnemySpawnPrefix = spawn_prefix,
        EnemySpawnMinCount = min_count,
        SupportsCombat = group ~= nil,
        SupportsBoss = boss_spawn ~= nil,
        ExitBarrierRoomId = nil,
        ExitBarrierAnchor = nil,
        BossSpawnAnchor = boss_spawn,
    })
end

function Layouts.get(dungeon_id: string, layout_id: string,
    depth1_base: any?): any?
    if dungeon_id ~= "TestDungeon" then return nil end
    if layout_id == "Depth1" then
        if not depth1_base then return nil end
        local slots = {}
        for id, definition in pairs(depth1_base.Slots) do
            slots[id] = definition
        end
        for _, kind in ipairs({"Event", "Secret"}) do
            local root = "Temple." .. kind .. "."
            slots[kind .. "Arena"] = slot(root .. "Trigger",
                root .. "Checkpoint", kind .. "Arena", nil, nil, nil,
                root .. "BossSpawn")
        end
        return table.freeze({
            Id = "Depth1",
            EntranceAnchor = depth1_base.EntranceAnchor,
            Slots = table.freeze(slots),
        })
    end
    local depth = tonumber(string.match(layout_id, "^Depth([234])$"))
    if not depth then return nil end
    local slots = {}
    for number = 1, depth + 2 do
        local id = "Room" .. number
        local root = "Temple." .. layout_id .. "." .. id .. "."
        local boss = number == depth + 2 or (depth == 4
            and (number == 2 or number == 4 or number == 5))
        slots[id] = slot(root .. "Trigger", root .. "Checkpoint", id,
            if boss then nil else layout_id .. id .. "EnemySpawns",
            if boss then nil else root .. "EnemySpawn.",
            if boss then nil else 8,
            if boss then root .. "BossSpawn" else nil)
    end
    return table.freeze({
        Id = layout_id,
        EntranceAnchor = "Temple." .. layout_id .. ".EntrySpawn",
        AuxiliaryAnchors = table.freeze({
            "Temple.Room1.Checkpoint",
            "Temple.Room2.Checkpoint",
        }),
        Slots = table.freeze(slots),
    })
end

return table.freeze(Layouts)
