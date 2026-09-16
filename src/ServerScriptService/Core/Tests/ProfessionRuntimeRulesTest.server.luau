--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Services = ServerScriptService:WaitForChild("Core"):WaitForChild("Services")
local ProfessionRuntime = require(Services:WaitForChild("ProfessionRuntime"))

local assertions = 0
local function check(condition: boolean, message: string)
    assertions += 1
    if not condition then
        error("[Profession Runtime Rules Tests] " .. message, 2)
    end
end

local base_nodes = ProfessionRuntime.node_definitions("Base")
local dungeon_nodes = ProfessionRuntime.node_definitions("Dungeon")
check(#base_nodes == 2, "Base must retain the two foundation teaching nodes.")
check(#dungeon_nodes >= 6, "Temple must support multiple independent resource nodes per room.")

local room1_count = 0
local room2_count = 0
local seen_ids: {[string]: boolean} = {}
local has_wall_probe = false
local has_floor_probe = false

for _, node in ipairs(dungeon_nodes) do
    check(type(node.Id) == "string" and node.Id ~= "", "Every resource node needs a stable ID.")
    check(seen_ids[node.Id] ~= true, "Resource node IDs must be unique.")
    seen_ids[node.Id] = true
    check(type(node.Probes) == "table" and #node.Probes >= 1, "Dungeon nodes must resolve against real geometry.")
    check((tonumber(node.EmbedDepth) or 0) > 0, "Dungeon nodes must embed into their hit surface.")

    if node.AnchorId == "Temple.Room1.Checkpoint" then
        room1_count += 1
    elseif node.AnchorId == "Temple.Room2.Checkpoint" then
        room2_count += 1
    end

    for _, probe in ipairs(node.Probes) do
        has_wall_probe = has_wall_probe or probe.Mode == "Wall"
        has_floor_probe = has_floor_probe or probe.Mode == "Floor"
    end
end

check(room1_count >= 2 and room2_count >= 2, "Each Temple gathering room must be able to contain multiple nodes.")
check(has_wall_probe, "At least one Temple node must exercise reachable wall placement.")
check(has_floor_probe, "Temple nodes must support embedded floor placement.")

-- Deterministic floor placement test. The returned CFrame must sit partially
-- inside the surface rather than floating on top of it.
local test_root = Instance.new("Folder")
test_root.Name = "ProfessionRuntimePlacementTest"
test_root.Parent = Workspace

local floor = Instance.new("Part")
floor.Name = "Floor"
floor.Anchored = true
floor.Size = Vector3.new(30, 2, 30)
floor.Position = Vector3.new(0, 0, 0)
floor.Parent = test_root

local anchor = Instance.new("Part")
anchor.Name = "Anchor"
anchor.Anchored = true
anchor.CanQuery = false
anchor.CFrame = CFrame.new(0, 4, 0)
anchor.Parent = test_root

local test_node = {
    EmbedDepth = 0.5,
    Probes = {
        {
            Mode = "Floor",
            Offset = Vector3.new(0, 8, 0),
            Distance = 30,
        },
    },
}

local placement, mode = ProfessionRuntime.resolve_surface_placement(
    anchor,
    test_node,
    nil,
    test_root
)
check(placement ~= nil and mode == "Floor", "Floor probe must resolve against world geometry.")
if placement then
    check(placement.Position.Y < 1, "Embedded resource origin must be inside the floor surface, not floating above it.")
end

test_root:Destroy()

print(string.format("[Profession Runtime Rules Tests] PASS: %d assertions.", assertions))
