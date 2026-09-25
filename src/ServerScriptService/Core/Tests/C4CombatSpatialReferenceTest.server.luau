--!strict
-- Deterministic C4 spatial-combat regression; no live world mutation.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Spatial = require(
    ReplicatedStorage.Core.Shared.C4CombatSpatialReference
)

local checks = 0
local EPSILON = 0.00001
local ORIGIN = CFrame.new(0, 0, 0)

--[[
Counts one spatial source assertion.

Args:
    valid (boolean): Expected source-semantic result.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Combat Spatial] " .. label)
end

--[[
Checks one floating spatial value within deterministic tolerance.

Args:
    actual (number): Calculated source value.
    expected (number): Expected source value.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check_close(
    actual: number,
    expected: number,
    label: string
)
    check(math.abs(actual - expected) <= EPSILON, label)
end

--[[
Runs source front/side/back, elevation, night and shield-facing vectors.

Args:
    None.

Returns:
    nil: Prints deterministic spatial-source acceptance evidence.
]]
local function main()
    local front = assert(Spatial.classify_position(
        Vector3.new(0, 0, -10),
        ORIGIN
    ))
    local side = assert(Spatial.classify_position(
        Vector3.new(10, 0, 0),
        ORIGIN
    ))
    local back = assert(Spatial.classify_position(
        Vector3.new(0, 0, 10),
        ORIGIN
    ))

    check(front == "Front", "defender forward arc maps to source Front")
    check(side == "Side", "orthogonal attacker maps to source Side")
    check(back == "Back", "rear attacker maps to source Back")

    local neutral = assert(Spatial.hit_condition(
        "Front",
        0,
        false
    ))
    check_close(
        neutral.Multiplier,
        1,
        "front level daylight source condition is neutral"
    )

    local side_high = assert(Spatial.hit_condition(
        "Side",
        51,
        false
    ))
    check_close(
        side_high.Multiplier,
        1.08,
        "source side plus high-ground bonus sums to eight percent"
    )

    local back_night_low = assert(Spatial.hit_condition(
        "Back",
        -51,
        true
    ))
    check_close(
        back_night_low.Multiplier,
        0.97,
        "back plus low plus dark source bonuses compose exactly"
    )

    local at_high_threshold = assert(Spatial.hit_condition(
        "Front",
        50,
        false
    ))
    check(
        at_high_threshold.ElevationRelation == "Level",
        "source high-ground bonus starts only above 50 units"
    )

    local facing = assert(Spatial.shield_facing(
        Vector3.new(0, 0, -10),
        ORIGIN,
        120
    ))
    check(
        facing.Eligible,
        "attacker directly ahead is inside source 120-degree shield arc"
    )

    local outside = assert(Spatial.shield_facing(
        Vector3.new(10, 0, 0),
        ORIGIN,
        120
    ))
    check(
        not outside.Eligible,
        "side attacker is outside source 120-degree shield arc"
    )

    local full_arc = assert(Spatial.shield_facing(
        Vector3.new(10, 0, 0),
        ORIGIN,
        360
    ))
    check(
        full_arc.Eligible,
        "source shield arc at 360 degrees accepts every direction"
    )

    local constants = Spatial.constants()
    check(
        constants.PositionHalfAngleDegrees == 45
            and constants.ShieldBaseAngleDegrees == 120
            and constants.ElevationThresholdSourceUnits == 50
            and constants.SideBonusPercent == 5
            and constants.BackBonusPercent == 10
            and constants.DarkBonusPercent == -10,
        "reviewed source spatial constants remain pinned"
    )

    print((
        "[C4 Combat Spatial] SOURCE_SPATIAL_PASS: %d assertions "
            .. "live=false"
    ):format(checks))
end

main()
