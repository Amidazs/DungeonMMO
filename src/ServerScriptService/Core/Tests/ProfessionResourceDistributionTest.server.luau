--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService
    :WaitForChild("Core")
    :WaitForChild("Services")
local ProfessionRuntime = require(
    Services:WaitForChild("ProfessionRuntime")
)

local definitions = ProfessionRuntime.node_definitions("Dungeon")
local groups: {[string]: {any}} = {}

for _, node in ipairs(definitions) do
    local group = node.PlacementGroup
    assert(
        type(group) == "string" and group ~= "",
        "Every dungeon resource must declare a placement group."
    )
    assert(
        (tonumber(node.MinSpacing) or 0) >= 18,
        "Dungeon resources must preserve at least 18 studs of runtime spacing."
    )
    assert(
        type(node.Probes) == "table" and #node.Probes >= 3,
        "Dungeon resources need multiple surface-placement fallbacks."
    )

    groups[group] = groups[group] or {}
    table.insert(groups[group], node)
end

for _, group_name in ipairs({"Temple.Room1", "Temple.Room2"}) do
    local nodes = groups[group_name]
    assert(nodes ~= nil and #nodes >= 3, group_name .. " must contain multiple resources.")

    -- Primary probe origins themselves must be distributed across the room;
    -- runtime hit-point spacing then provides a second safety net after raycasts.
    for left_index = 1, #nodes do
        local left_offset = nodes[left_index].Probes[1].Offset
        assert(typeof(left_offset) == "Vector3")
        for right_index = left_index + 1, #nodes do
            local right_offset = nodes[right_index].Probes[1].Offset
            assert(typeof(right_offset) == "Vector3")
            local left_flat = Vector3.new(left_offset.X, 0, left_offset.Z)
            local right_flat = Vector3.new(right_offset.X, 0, right_offset.Z)
            assert(
                (left_flat - right_flat).Magnitude >= 18,
                string.format(
                    "%s primary resource probes are too clustered: %s / %s",
                    group_name,
                    tostring(nodes[left_index].Id),
                    tostring(nodes[right_index].Id)
                )
            )
        end
    end
end

assert(
    ProfessionRuntime.is_position_spaced(
        Vector3.zero,
        {Vector3.new(18, 0, 0)},
        18
    ),
    "Exactly minimum spacing must be allowed."
)
assert(
    not ProfessionRuntime.is_position_spaced(
        Vector3.zero,
        {Vector3.new(17.99, 0, 0)},
        18
    ),
    "Positions inside minimum spacing must be rejected."
)

print("[Profession Resource Distribution Tests] PASS")
