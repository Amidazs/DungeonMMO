--!strict
-- TEMP Studio physical-layout overlay. Never register these layouts in the
-- shared production content catalogue or change difficulty release flags.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage:WaitForChild("Core")
    :WaitForChild("Shared"):WaitForChild("DungeonRuntimeContentCatalog"))

local Layouts = {}
local PREFIX = {TestDungeon = "Temple", AbandonedMine = "Mine"}
local LATE_INSERT = {
    Depth2 = "Depth2Combat2",
    Depth3 = "Depth3Combat2",
    Depth4 = "Depth4MiniBoss1",
}

local function slot(trigger: string, checkpoint: string,
    room_id: string, group: string?, spawn_prefix: string?,
    min_count: number?, boss_spawn: string?,
    insert_after: string?): any
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
        OptionalInsertAfterId = insert_after,
        OptionalPlacementVerified = insert_after ~= nil,
    })
end

function Layouts.get(dungeon_id: string, layout_id: string,
    include_optional: boolean, include_late: boolean?): any?
    local prefix = PREFIX[dungeon_id]
    if not prefix then return nil end
    if layout_id == "Depth1" then
        local original = Catalog.get_layout(dungeon_id, "Depth1")
        if not original or not include_optional then return original end
        local slots = {}
        for id, definition in pairs(original.Slots) do
            slots[id] = definition
        end
        for _, kind in ipairs({"Event", "Secret"}) do
            local slot_id = kind .. "Arena"
            local root = prefix .. "." .. kind .. "."
            slots[slot_id] = slot(root .. "Trigger",
                root .. "Checkpoint", slot_id, nil, nil, nil,
                root .. "BossSpawn")
        end
        return table.freeze({
            Id = "Depth1",
            EntranceAnchor = original.EntranceAnchor,
            Slots = table.freeze(slots),
        })
    end
    local depth = tonumber(string.match(layout_id, "^Depth([234])$"))
    if not depth then return nil end
    local slots = {}
    local room_count = depth + 2
    for number = 1, room_count do
        local id = "Room" .. number
        local root = prefix .. "." .. layout_id .. "." .. id .. "."
        local boss = number == room_count
            or (depth == 4 and (number == 2 or number == 4 or number == 5))
        slots[id] = slot(root .. "Trigger",
            root .. "Checkpoint", id,
            if boss then nil else layout_id .. id .. "EnemySpawns",
            if boss then nil else root .. "EnemySpawn.",
            if boss then nil else 8,
            if boss then root .. "BossSpawn" else nil)
    end
    -- Only the explicitly opted-in unpublished Studio layout receives
    -- higher-depth side arenas. The production catalogue stays unchanged.
    if include_optional then
        for _, kind in ipairs({"Event", "Secret"}) do
            local room_slot_id = kind .. "Arena"
            local root = prefix .. "." .. layout_id .. "." .. kind .. "."
            slots[room_slot_id] = slot(
                root .. "Trigger", root .. "Checkpoint",
                room_slot_id, nil, nil, nil, root .. "BossSpawn"
            )
        end
        if include_late == true then
            local root = prefix .. "." .. layout_id .. ".EventLate."
            slots.EventArenaLate = slot(
                root .. "Trigger", root .. "Checkpoint",
                "EventArenaLate",
                layout_id .. "LateEventEnemySpawns",
                root .. "EnemySpawn.", 8,
                root .. "BossSpawn", LATE_INSERT[layout_id]
            )
        end
    end
    return table.freeze({
        Id = layout_id,
        EntranceAnchor = prefix .. "." .. layout_id .. ".EntrySpawn",
        -- Existing dungeon professions and Mine state presentation still
        -- consume the original Depth1 resource/checkpoint anchors. Keep
        -- them resolved as auxiliary anchors during TEMP depth previews.
        AuxiliaryAnchors = table.freeze({
            prefix .. ".Room1.Checkpoint",
            prefix .. ".Room2.Checkpoint",
        }),
        Slots = table.freeze(slots),
    })
end

return table.freeze(Layouts)
