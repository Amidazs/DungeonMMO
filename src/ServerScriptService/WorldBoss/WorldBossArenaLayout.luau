--!strict
-- Minimal geometric test arena. No asset manufacturing or Roblox publish.
-- The production place may replace this prototype with authored geometry.
local WorldBossArenaLayout = {}

local ARENA_HALF_SIZE = 42
local WALL_HEIGHT = 24
local WALL_THICKNESS = 4

-- Args:
--   arena: Model; the new arena parent.
--   name: string; stable child name.
--   size: Vector3; collision dimensions.
--   location: Vector3; local arena-space centre.
-- Returns:
--   Part: an anchored geometric placeholder for the encounter.
local function make_part(
    arena: Model,
    name: string,
    size: Vector3,
    location: Vector3
): Part
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = location
    part.Anchored = true
    part.Material = Enum.Material.Slate
    part.Parent = arena
    return part
end

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

    make_part(arena, "Floor", Vector3.new(88, 4, 88),
        Vector3.new(0, -2, 0))
    make_part(arena, "NorthWall", Vector3.new(88, WALL_HEIGHT, WALL_THICKNESS),
        Vector3.new(0, WALL_HEIGHT / 2, -ARENA_HALF_SIZE))
    make_part(arena, "SouthWall", Vector3.new(88, WALL_HEIGHT, WALL_THICKNESS),
        Vector3.new(0, WALL_HEIGHT / 2, ARENA_HALF_SIZE))
    make_part(arena, "EastWall", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, 88),
        Vector3.new(ARENA_HALF_SIZE, WALL_HEIGHT / 2, 0))
    make_part(arena, "WestWall", Vector3.new(WALL_THICKNESS, WALL_HEIGHT, 88),
        Vector3.new(-ARENA_HALF_SIZE, WALL_HEIGHT / 2, 0))

    local spawn = make_part(arena, "WorldBossArenaSpawn",
        Vector3.new(6, 1, 6), Vector3.new(0, 0.5, 22))
    spawn.Transparency = 1
    spawn.CanCollide = false
    return spawn
end

return table.freeze(WorldBossArenaLayout)
