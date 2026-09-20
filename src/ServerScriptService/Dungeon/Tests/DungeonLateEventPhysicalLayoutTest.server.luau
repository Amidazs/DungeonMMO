--!strict
-- A disposable late-Event bridge exists ONLY in explicitly opted-in,
-- unpublished Studio layouts; legacy routes stay physically independent.
local W = game:GetService("Workspace")
local CS = game:GetService("CollectionService")
local SSS = game:GetService("ServerScriptService")
local Dungeon = SSS.Dungeon
local Layouts = require(Dungeon.DungeonRoomLayoutDefinitions)
local Physical = require(Dungeon.DungeonPlaceholderPhysicalContent)
local Gates = require(Dungeon.DungeonOptionalEntranceGates)
local checks = 0
local function check(ok: boolean, message: string)
    checks += 1
    assert(ok, "[Late Event Physical] " .. message)
end
local keys = {
    "DungeonMMOStudioDifficultyId",
    "DungeonMMOEnvironmentMode",
    "DungeonMMOPlaceholderPhysicalContentEnabled",
    "DungeonMMOPlaceholderPlayableEnabled",
    "DungeonMMOPlaceholderOptionalPlayEnabled",
    "DungeonMMOPlaceholderLateEventPlayEnabled",
}
local old = {}
for _, key in ipairs(keys) do old[key] = W:GetAttribute(key) end
local function find_anchor(identifier: string): BasePart?
    for _, item in ipairs(CS:GetTagged("DungeonMMOEnvironmentAnchor")) do
        if item:GetAttribute("AnchorId") == identifier then
            return item
        end
    end
    return nil
end
local function scenario(dungeon_id: string, depth: number)
    local depth_id = "Depth" .. depth
    local prefix = if dungeon_id == "TestDungeon" then "Temple"
        else "Mine"
    W:SetAttribute("DungeonMMOStudioDifficultyId", depth_id)
    local holder = Instance.new("Folder")
    holder.Name = "LateEventPhysicalFixture"
    holder.Parent = W
    local passed, reason = pcall(function()
        local root = Physical.create(holder, dungeon_id, depth_id)
        local group = assert(root:FindFirstChild(
            depth_id .. "_TEMP_PLAYABLE"))
        check(root:GetAttribute("DungeonMMOPlaceholderLateEventRoute")
            == true, "selected higher depth registers its own late route")
        local layout = assert(Layouts.get(dungeon_id, depth_id))
        local slot = assert(layout.Slots.EventArenaLate)
        local after = if depth == 4 then "Depth4MiniBoss1"
            else depth_id .. "Combat2"
        check(slot.OptionalPlacementVerified == true
            and slot.OptionalInsertAfterId == after
            and slot.SupportsBoss == true,
            "layout verifies this depth's actual second required encounter")
        local room = assert(group:FindFirstChild("EventArenaLate"))
        local bridge = assert(group:FindFirstChild("EventBridgeLate"))
        local main = assert(group:FindFirstChild("Room2"))
        local gate = assert(Gates.get(root, "EventArenaLate"))
        check(gate.CanCollide
            and gate:GetAttribute("DungeonMMOOptionalArena")
                == "EventArenaLate",
            "new gate is initially closed and exclusively identifies its slot")
        check(main:FindFirstChild("EastWall") == nil
            and main:FindFirstChild("EastWallSouth") ~= nil
            and main:FindFirstChild("EastWallNorth") ~= nil,
            "Room2 has an intentional walkable east-side opening")
        local floor, bridge_floor, room_floor = assert(
            main:FindFirstChild("Floor")), assert(bridge:FindFirstChild(
                "WalkableFloor")), assert(room:FindFirstChild("Floor"))
        check(math.abs(floor.Position.Y - bridge_floor.Position.Y)
            < 0.1 and math.abs(room_floor.Position.Y
                - bridge_floor.Position.Y) < 0.1,
            "room and side bridge walkable surfaces are level")
        local root_id = prefix .. "." .. depth_id .. ".EventLate."
        check(slot.TriggerAnchor == root_id .. "Trigger"
            and slot.CheckpointAnchor == root_id .. "Checkpoint"
            and slot.BossSpawnAnchor == root_id .. "BossSpawn",
            "new slot has unique depth-specific authoritative IDs")
        check(find_anchor(slot.TriggerAnchor) ~= nil
            and find_anchor(slot.CheckpointAnchor) ~= nil
            and find_anchor(slot.BossSpawnAnchor) ~= nil,
            "late trigger, checkpoint and boss spawn are registered")
        local bindings = {
            by_slot = {EventArenaLate = {}, SecretArena = {}},
            ordered = {
                {RoomSlotId = "Room1"},
                {RoomSlotId = "Room2"},
                {RoomSlotId = "EventArenaLate"},
                {RoomSlotId = "SecretArena"},
            },
        }
        -- Gates use the SAVED ordered predecessor, not a hard-coded Room1.
        local state = {}
        local flow = {state_for_slot = function(_, id) return state[id] end}
        local old_event = assert(Gates.get(root, "EventArena"))
        local old_secret = assert(Gates.get(root, "SecretArena"))
        check(Gates.sync(root, bindings, flow).ok
            and old_event.CanCollide and old_secret.CanCollide
            and gate.CanCollide,
            "all entrances start sealed")
        state.Room1 = "Cleared"
        check(Gates.sync(root, bindings, flow).ok
            and gate.CanCollide and old_event.CanCollide,
            "Room1 cannot unlock late or unused early Event")
        state.Room2 = "Cleared"
        check(Gates.sync(root, bindings, flow).ok
            and not gate.CanCollide and old_event.CanCollide,
            "only selected late Event opens after Room2")
        state.Room2 = "Pending"
        check(Gates.sync(root, bindings, flow).ok
            and gate.CanCollide,
            "recovery closes late entrance before saved predecessor clears")
        state.Room2 = "Cleared"
        bindings.by_slot.EventArenaLate = nil
        check(Gates.sync(root, bindings, flow).ok
            and gate.CanCollide and old_event.CanCollide,
            "unselected late and early Events both stay closed")
        check(layout.Slots.EventArena ~= nil
            and layout.Slots.SecretArena ~= nil,
            "new physical route does not replace accepted side rooms")
    end)
    holder:Destroy()
    check(passed, tostring(reason))
end

W:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
W:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderPlayableEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderOptionalPlayEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderLateEventPlayEnabled", true)
local ok, err = pcall(function()
    for _, dungeon in ipairs({"TestDungeon", "AbandonedMine"}) do
        for depth = 2, 4 do scenario(dungeon, depth) end
    end
end)
for _, key in ipairs(keys) do W:SetAttribute(key, old[key]) end
check(ok, tostring(err))
print(string.format("[Late Event Physical Tests] PASS: %d assertions.", checks))
