--!strict
-- Pure Chronicle 4 spatial combat semantics for server-owned world inputs.

local C4CombatSpatialReference = {}

local POSITION_HALF_ANGLE_DEGREES = 45
local SHIELD_BASE_ANGLE_DEGREES = 120
local ELEVATION_THRESHOLD_SOURCE_UNITS = 50

local FRONT_BONUS_PERCENT = 0
local SIDE_BONUS_PERCENT = 5
local BACK_BONUS_PERCENT = 10
local HIGH_BONUS_PERCENT = 3
local LOW_BONUS_PERCENT = -3
local DARK_BONUS_PERCENT = -10

--[[
Returns a normalized horizontal direction from defender to attacker.

Args:
    attacker_position (Vector3): Server-owned attacker world position.
    defender_cframe (CFrame): Server-owned defender transform.

Returns:
    (Vector3?, string?): Horizontal unit direction or strict denial reason.
]]
local function horizontal_attacker_direction(
    attacker_position: Vector3,
    defender_cframe: CFrame
): (Vector3?, string?)
    local offset = attacker_position - defender_cframe.Position
    local horizontal = Vector3.new(offset.X, 0, offset.Z)

    if horizontal.Magnitude <= 0.000001 then
        return nil, "SourceHorizontalDirectionUnavailable"
    end

    return horizontal.Unit, nil
end

--[[
Returns the defender's normalized horizontal facing direction.

Args:
    defender_cframe (CFrame): Server-owned defender transform.

Returns:
    (Vector3?, string?): Horizontal unit look direction or denial reason.
]]
local function horizontal_look_direction(
    defender_cframe: CFrame
): (Vector3?, string?)
    local look = defender_cframe.LookVector
    local horizontal = Vector3.new(look.X, 0, look.Z)

    if horizontal.Magnitude <= 0.000001 then
        return nil, "SourceDefenderFacingUnavailable"
    end

    return horizontal.Unit, nil
end

--[[
Classifies attacker position using the reviewed C4 45-degree front/back arcs.

The source treats an attacker inside +/-45 degrees of the defender's forward
heading as Front, inside +/-45 degrees of the rear heading as Back, and all
remaining horizontal directions as Side.

Args:
    attacker_position (Vector3): Server-owned attacker position.
    defender_cframe (CFrame): Server-owned defender transform.

Returns:
    (string?, string?): Front, Side or Back, or strict denial reason.
]]
function C4CombatSpatialReference.classify_position(
    attacker_position: Vector3,
    defender_cframe: CFrame
): (string?, string?)
    local to_attacker, direction_reason =
        horizontal_attacker_direction(
            attacker_position,
            defender_cframe
        )
    if not to_attacker then
        return nil, direction_reason
    end

    local look, look_reason =
        horizontal_look_direction(defender_cframe)
    if not look then
        return nil, look_reason
    end

    local threshold = math.cos(
        math.rad(POSITION_HALF_ANGLE_DEGREES)
    )
    local dot = look:Dot(to_attacker)

    if dot >= threshold then
        return "Front", nil
    end
    if dot <= -threshold then
        return "Back", nil
    end
    return "Side", nil
end

--[[
Resolves the exact reviewed C4 hit-condition multiplier.

The caller supplies height delta in source coordinate units rather than
assuming Roblox studs equal C4 world units. Night state is also server-owned.

Args:
    position_relation (string): Front, Side or Back.
    height_delta_source_units (number): Attacker Z/Y minus defender height in
        the source coordinate scale.
    is_night (boolean): Server-owned source-equivalent night state.

Returns:
    (any?, string?): Multiplier and condition evidence or denial reason.
]]
function C4CombatSpatialReference.hit_condition(
    position_relation: string,
    height_delta_source_units: number,
    is_night: boolean
): (any?, string?)
    if position_relation ~= "Front"
        and position_relation ~= "Side"
        and position_relation ~= "Back"
    then
        return nil, "InvalidSourcePositionRelation"
    end
    if type(height_delta_source_units) ~= "number"
        or height_delta_source_units ~= height_delta_source_units
        or math.abs(height_delta_source_units) >= math.huge
    then
        return nil, "InvalidSourceHeightDelta"
    end
    if type(is_night) ~= "boolean" then
        return nil, "InvalidSourceNightState"
    end

    local position_bonus = if position_relation == "Back"
        then BACK_BONUS_PERCENT
        elseif position_relation == "Side"
            then SIDE_BONUS_PERCENT
            else FRONT_BONUS_PERCENT

    local elevation_bonus = 0
    local elevation_relation = "Level"
    if height_delta_source_units
        > ELEVATION_THRESHOLD_SOURCE_UNITS
    then
        elevation_bonus = HIGH_BONUS_PERCENT
        elevation_relation = "High"
    elseif height_delta_source_units
        < -ELEVATION_THRESHOLD_SOURCE_UNITS
    then
        elevation_bonus = LOW_BONUS_PERCENT
        elevation_relation = "Low"
    end

    local dark_bonus = if is_night
        then DARK_BONUS_PERCENT
        else 0
    local total_percent =
        100 + position_bonus + elevation_bonus + dark_bonus

    return {
        Multiplier = math.max(total_percent / 100, 0),
        PositionRelation = position_relation,
        PositionBonusPercent = position_bonus,
        ElevationRelation = elevation_relation,
        ElevationBonusPercent = elevation_bonus,
        DarkBonusPercent = dark_bonus,
        HeightDeltaSourceUnits = height_delta_source_units,
        IsNight = is_night,
    }, nil
end

--[[
Resolves exact C4 shield-facing eligibility for a supplied shield arc.

The reviewed launch shield base arc is 120 degrees. Source isFacing divides the
full arc by two, so 120 degrees means +/-60 degrees around defender forward.

Args:
    attacker_position (Vector3): Server-owned attacker world position.
    defender_cframe (CFrame): Server-owned defender transform.
    shield_angle_degrees (number?): Full source shield arc. Defaults to 120.

Returns:
    (any?, string?): Facing eligibility plus angular evidence.
]]
function C4CombatSpatialReference.shield_facing(
    attacker_position: Vector3,
    defender_cframe: CFrame,
    shield_angle_degrees: number?
): (any?, string?)
    local angle = shield_angle_degrees or SHIELD_BASE_ANGLE_DEGREES
    if type(angle) ~= "number"
        or angle ~= angle
        or angle < 0
        or angle >= math.huge
    then
        return nil, "InvalidSourceShieldAngle"
    end

    if angle >= 360 then
        return {
            Eligible = true,
            ShieldAngleDegrees = angle,
            Dot = nil,
        }, nil
    end

    local to_attacker, direction_reason =
        horizontal_attacker_direction(
            attacker_position,
            defender_cframe
        )
    if not to_attacker then
        return nil, direction_reason
    end

    local look, look_reason =
        horizontal_look_direction(defender_cframe)
    if not look then
        return nil, look_reason
    end

    local dot = look:Dot(to_attacker)
    local threshold = math.cos(math.rad(angle / 2))

    return {
        Eligible = dot >= threshold,
        ShieldAngleDegrees = angle,
        Dot = dot,
        Threshold = threshold,
    }, nil
end

--[[
Returns reviewed source constants for audit and tests.

Args:
    None.

Returns:
    any: Immutable spatial source constants.
]]
function C4CombatSpatialReference.constants(): any
    return table.freeze({
        PositionHalfAngleDegrees = POSITION_HALF_ANGLE_DEGREES,
        ShieldBaseAngleDegrees = SHIELD_BASE_ANGLE_DEGREES,
        ElevationThresholdSourceUnits =
            ELEVATION_THRESHOLD_SOURCE_UNITS,
        FrontBonusPercent = FRONT_BONUS_PERCENT,
        SideBonusPercent = SIDE_BONUS_PERCENT,
        BackBonusPercent = BACK_BONUS_PERCENT,
        HighBonusPercent = HIGH_BONUS_PERCENT,
        LowBonusPercent = LOW_BONUS_PERCENT,
        DarkBonusPercent = DARK_BONUS_PERCENT,
    })
end

return table.freeze(C4CombatSpatialReference)
