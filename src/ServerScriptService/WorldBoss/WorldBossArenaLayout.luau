--!strict
-- Minimal geometric test arena. No asset manufacturing or Roblox publish.
-- The production place may replace this prototype with authored geometry.
local WorldBossArenaLayout = {}

local ARENA_HALF_SIZE = 42
local WALL_HEIGHT = 24
local WALL_THICKNESS = 4

-- Args:
--   parent: Instance; destination for this standalone prototype.
--   name: string; uniquely identifies a disposable arena.
-- Returns:
--   Part: server-owned entry and return anchor for the guardian.
function WorldBossArenaLayout.create(
    parent: Instance,
    name: string
): BasePart
    assert(typeof(parent) == "Instance", "Arena parent is required")
    assert(type(name) == "string" and name ~= "",
        "Arena requires a nonempty unique name")
    assert(parent:FindFirstChild(name) == nil,
        "Arena has already been created")

    local arena = Instance.new("Model")
    arena.Name = name
    arena.Parent = parent

    -- Args:
    --   part_name: string; child name for service/test discovery.
    --   size: Vector3; solid arena geometry dimensions.
    --   location: Vector3; deterministic centre in local arena space.
    -- Returns:
    --   Part: anchored Roblox primitive with no external asset.
    local function make_part(
        part_name: string,
        size: Vector3,
        location: Vector3
    ): Part
        local part = Instance.new("Part")
        part.Name = part_name
        part.Size = size
        part.Position = location
        part.Anchored = true
        part.Material = Enum.Material.Slate
        part.Parent = arena
        return part
    end

    make_part("Floor", Vector3.new(88, 4, 88),
        Vector3.new(0, -2, 0))
    make_part("NorthWall", Vector3.new(88, WALL_HEIGHT, WALL_THICKNESS),
        Vector3.new(0, WALL_HEIGHT / 2, -ARENA_HALF_SIZE))
    make_part("SouthWall", Vector3.new(88, WALL_HEIGHT, WALL_THICKNESS),
        Vector3.new(0, WALL_HEIGHT / 2, ARENA_HALF_SIZE))
    make_part("EastWall", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, 88),
        Vector3.new(ARENA_HALF_SIZE, WALL_HEIGHT / 2, 0))
    make_part("WestWall", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, 88),
        Vector3.new(-ARENA_HALF_SIZE, WALL_HEIGHT / 2, 0))

    local spawn = make_part("WorldBossArenaSpawn",
        Vector3.new(6, 1, 6), Vector3.new(0, 0.5, 22))
    spawn.Transparency = 1
    spawn.CanCollide = false
    return spawn
end

return table.freeze(WorldBossArenaLayout)
