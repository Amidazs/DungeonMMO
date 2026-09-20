--!strict
-- Disposable higher-depth optional blockouts; no production release switch.
local SSS = game:GetService("ServerScriptService")
local W = game:GetService("Workspace")
local CS = game:GetService("CollectionService")
local Dungeon = SSS:WaitForChild("Dungeon")
local Physical = require(Dungeon.DungeonPlaceholderPhysicalContent)
local Layouts = require(Dungeon.DungeonRoomLayoutDefinitions)
local Gates = require(Dungeon.DungeonOptionalEntranceGates)

local assertions = 0

-- Checks a physical-layout invariant without leaking temporary instances.
-- Args: passed (boolean): Whether the expected geometry state holds.
--       description (string): Specific reason shown by the test runner.
-- Returns: nil: Raises for a failed assertion.
local function check(passed: boolean, description: string)
    assertions += 1
    assert(passed, "[Optional Depth Physical] " .. description)
end

-- Resolves an exact tagged temporary anchor in the test fixture.
-- Args: id (string): Expected authoritative environment anchor identity.
-- Returns: BasePart?: Corresponding physical marker, when generated.
local function anchor(id: string): BasePart?
    for _, item in ipairs(CS:GetTagged("DungeonMMOEnvironmentAnchor")) do
        if item:GetAttribute("AnchorId") == id then
            return item
        end
    end
    return nil
end

-- Checks one dungeon/difficulty geometry and its independent side gates.
-- Args: dungeon_id (string): Temple or Mine, no other roots supported.
--       depth (number): Temporary higher difficulty, from 2 through 4.
-- Returns: nil: Destroys the complete disposable physical fixture.
local function check_depth(dungeon_id: string, depth: number)
    local depth_id = "Depth" .. depth
    local prefix = if dungeon_id == "TestDungeon" then "Temple" else "Mine"
    W:SetAttribute("DungeonMMOStudioDifficultyId", depth_id)
    local holder = Instance.new("Folder")
    holder.Name = "OptionalDepthPhysicalFixture"
    holder.Parent = W
    local root = Physical.create(holder, dungeon_id, depth_id)
    local group = root:FindFirstChild(depth_id .. "_TEMP_PLAYABLE")
    check(group ~= nil, "opted-in depth must create its own side blockout")
    check(root:GetAttribute("DungeonMMOPlaceholderActiveDifficulty")
        == depth_id and root:GetAttribute(
            "DungeonMMOPlaceholderOptionalDepthRoutes") == true,
        "selected difficulty must remain explicit on physical root")
    local layout = assert(Layouts.get(dungeon_id, depth_id, true))
    local bindings = {by_slot = {}, ordered = {}}
    for index = 1, depth + 2 do
        local slot = "Room" .. index
        check(layout.Slots[slot] ~= nil,
            "original required combat room must still exist")
        if index == 1 then
            table.insert(bindings.ordered, {RoomSlotId = slot})
            table.insert(bindings.ordered, {RoomSlotId = "EventArena"})
        elseif index == depth + 1 then
            table.insert(bindings.ordered, {RoomSlotId = slot})
            table.insert(bindings.ordered, {RoomSlotId = "SecretArena"})
        else
            table.insert(bindings.ordered, {RoomSlotId = slot})
        end
    end
    bindings.by_slot.EventArena = {}
    bindings.by_slot.SecretArena = {}
    local state = {}
    local flow = {
        state_for_slot = function(_, slot_id: string)
            return state[slot_id]
        end,
    }
    for _, kind in ipairs({"Event", "Secret"}) do
        local slot_id = kind .. "Arena"
        local bridge = group:FindFirstChild(kind .. "Bridge")
        local room = group:FindFirstChild(slot_id)
        local gate = Gates.get(root, slot_id)
        local prefix_id = prefix .. "." .. depth_id .. "." .. kind .. "."
        check(layout.Slots[slot_id] ~= nil
            and room ~= nil and bridge ~= nil and gate ~= nil,
            "selected depth optional arena/bridge/gate must exist")
        check(anchor(prefix_id .. "Trigger") ~= nil
            and anchor(prefix_id .. "Checkpoint") ~= nil
            and anchor(prefix_id .. "BossSpawn") ~= nil,
            "optional arena must register three depth-specific anchors")
        local required = if kind == "Event" then 1 else depth + 1
        local main = group:FindFirstChild("Room" .. required)
        check(main and main:FindFirstChild("EastWall") == nil
            and main:FindFirstChild("EastWallNorth") ~= nil
            and main:FindFirstChild("EastWallSouth") ~= nil,
            "preceding main room must have a walkable side-wall opening")
        local main_floor = main:FindFirstChild("Floor")
        local bridge_floor = bridge:FindFirstChild("WalkableFloor")
        local optional_floor = room:FindFirstChild("Floor")
        check(main_floor and bridge_floor and optional_floor
            and math.abs(main_floor.Position.Y
                - bridge_floor.Position.Y) < 0.1
            and math.abs(bridge_floor.Position.Y
                - optional_floor.Position.Y) < 0.1,
            "main floor, side bridge and optional room must be level")
        check(gate.CanCollide, "side gate must start physically closed")
    end
    local old_event = root:FindFirstChild("EventBridge")
    local old_secret = root:FindFirstChild("SecretBridge")
    local old_event_gate = old_event:FindFirstChild("EntranceGate")
    local old_secret_gate = old_secret:FindFirstChild("EntranceGate")
    check(Gates.sync(root, bindings, flow).ok,
        "server must synchronize selected depth's own side gates")
    state.Room1 = "Cleared"
    check(Gates.sync(root, bindings, flow).ok
        and not Gates.get(root, "EventArena").CanCollide
        and Gates.get(root, "SecretArena").CanCollide,
        "Room1 opens only Event, not the deeper Secret")
    state.Room2 = "Cleared"
    check(Gates.sync(root, bindings, flow).ok
        and Gates.get(root, "SecretArena").CanCollide,
        "Secret must not open at Room2 in higher difficulties")
    state["Room" .. (depth + 1)] = "Cleared"
    check(Gates.sync(root, bindings, flow).ok
        and not Gates.get(root, "SecretArena").CanCollide,
        "Secret opens after selected depth's penultimate required room")
    check(old_event_gate.CanCollide and old_secret_gate.CanCollide,
        "old Depth1 side entrances must remain physically sealed")
    bindings.by_slot.SecretArena = nil
    check(Gates.sync(root, bindings, flow).ok
        and Gates.get(root, "SecretArena").CanCollide,
        "ineligible Secret remains sealed even with all rooms cleared")
    holder:Destroy()
end

local previous = {}
local keys = {
    "DungeonMMOStudioDifficultyId",
    "DungeonMMOEnvironmentMode",
    "DungeonMMOPlaceholderPhysicalContentEnabled",
    "DungeonMMOPlaceholderPlayableEnabled",
    "DungeonMMOPlaceholderOptionalPlayEnabled",
}
for _, name in ipairs(keys) do
    previous[name] = W:GetAttribute(name)
end
W:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
W:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderPlayableEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderOptionalPlayEnabled", true)

local passed, failure = pcall(function()
    for _, dungeon_id in ipairs({"TestDungeon", "AbandonedMine"}) do
        for depth = 2, 4 do
            check_depth(dungeon_id, depth)
        end
    end
end)
for _, name in ipairs(keys) do
    W:SetAttribute(name, previous[name])
end
check(passed, tostring(failure))
print(string.format(
    "[Optional Depth Physical Tests] PASS: %d assertions.", assertions
))
