--!strict
-- Reviewed C4 source-to-Roblox world scale regression.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local WorldScale = require(
    ReplicatedStorage.Core.Shared.C4WorldScaleReference
)

local checks = 0

--[[
Counts one world-scale assertion.

Args:
    valid (boolean): Expected conversion condition.
    label (string): Diagnostic description for failure.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 World Scale] " .. label)
end

--[[
Checks two finite numeric values are equal within a small tolerance.

Args:
    actual (number): Observed conversion.
    expected (number): Reviewed expected conversion.
    label (string): Diagnostic description for failure.

Returns:
    nil: Delegates the result to the common assertion counter.
]]
local function check_close(
    actual: number,
    expected: number,
    label: string
)
    check(math.abs(actual - expected) < 0.000001, label)
end

--[[
Runs the reviewed launch world-scale contract.

Args:
    None.

Returns:
    nil: Prints a stable pass marker after all conversions succeed.
]]
local function main()
    check(
        WorldScale.source_units_per_stud() == 14,
        "launch mapping keeps 14 source units per stud"
    )
    check_close(
        WorldScale.to_studs(200),
        200 / 14,
        "Spoil Festival radius 200 converts consistently"
    )
    check_close(
        WorldScale.to_studs(150),
        150 / 14,
        "reviewed 150 source radius converts consistently"
    )
    check_close(
        WorldScale.to_studs(40),
        40 / 14,
        "close castRange 40 converts consistently"
    )
    check_close(
        WorldScale.to_studs(20),
        20 / 14,
        "Sweep castRange 20 converts consistently"
    )
    check_close(
        WorldScale.to_studs(600),
        600 / 14,
        "source range 600 converts consistently"
    )
    check_close(
        WorldScale.to_studs(1000),
        1000 / 14,
        "source radius 1000 converts consistently"
    )
    check_close(
        WorldScale.to_source_units(10),
        140,
        "ten Roblox studs convert back to 140 source units"
    )

    local capability = WorldScale.capability()
    check(
        capability.SourceUnitsPerStud == 14
            and capability.CollisionRadiiAppliedSeparately
            and capability.ExactSourceMetadataPreserved
            and capability.LaunchCalibrationReviewed,
        "capability distinguishes mapping from exact source metadata"
    )

    print(
        ("[C4 World Scale] PASS: %d assertions")
            :format(checks)
    )
end

main()
