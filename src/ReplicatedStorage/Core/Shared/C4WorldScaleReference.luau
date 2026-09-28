--!strict
-- Reviewed launch mapping between C4 source distance units and Roblox studs.

local C4WorldScaleReference = {}

local SOURCE_UNITS_PER_STUD = 14

--[[
Returns the reviewed launch source-distance scale.

The value is a gameplay/world calibration, not a claim that the original
client exposed an exact physical metre conversion. It keeps C4's authored
distances intact and provides one shared Roblox conversion for live spatial
rules.

Args:
    None.

Returns:
    number: Positive C4 source units represented by one Roblox stud.
]]
function C4WorldScaleReference.source_units_per_stud(): number
    return SOURCE_UNITS_PER_STUD
end

--[[
Converts a finite non-negative C4 source distance to Roblox studs.

Args:
    source_units (number): Distance expressed in source units.

Returns:
    number: Equivalent Roblox studs under the reviewed launch mapping.
]]
function C4WorldScaleReference.to_studs(
    source_units: number
): number
    assert(
        type(source_units) == "number"
            and source_units == source_units
            and source_units >= 0
            and source_units < math.huge,
        "C4 source distance must be finite and non-negative"
    )

    return source_units / SOURCE_UNITS_PER_STUD
end

--[[
Converts a finite non-negative Roblox distance to C4 source units.

Args:
    studs (number): Server-owned Roblox distance in studs.

Returns:
    number: Equivalent C4 source units under the reviewed launch mapping.
]]
function C4WorldScaleReference.to_source_units(
    studs: number
): number
    assert(
        type(studs) == "number"
            and studs == studs
            and studs >= 0
            and studs < math.huge,
        "Roblox distance must be finite and non-negative"
    )

    return studs * SOURCE_UNITS_PER_STUD
end

--[[
Returns detached calibration evidence for diagnostics and acceptance tests.

Args:
    None.

Returns:
    any: Reviewed scale and representative launch conversions.
]]
function C4WorldScaleReference.capability(): any
    return table.freeze({
        SourceUnitsPerStud = SOURCE_UNITS_PER_STUD,
        SpoilFestivalRadiusStuds =
            C4WorldScaleReference.to_studs(200),
        SweepingArcRadiusStuds =
            C4WorldScaleReference.to_studs(150),
        CloseCastRangeStuds =
            C4WorldScaleReference.to_studs(40),
        SweepCastRangeStuds =
            C4WorldScaleReference.to_studs(20),
        SixHundredRangeStuds =
            C4WorldScaleReference.to_studs(600),
        OneThousandRadiusStuds =
            C4WorldScaleReference.to_studs(1000),
        CollisionRadiiAppliedSeparately = true,
        ExactSourceMetadataPreserved = true,
        LaunchCalibrationReviewed = true,
    })
end

return table.freeze(C4WorldScaleReference)
