--!strict
-- Development-only, rig-independent quadruped motion mathematics.
-- Does not pose a model, change a rig, or apply gameplay damage.
local QuadrupedMotionCore = {}

export type PawOffset = {
    forward: number,
    up: number,
    planted: boolean,
}

export type GaitSample = {
    FrontLeft: PawOffset,
    FrontRight: PawOffset,
    HindLeft: PawOffset,
    HindRight: PawOffset,
}

export type IKResult = {
    knee: Vector3,
    paw: Vector3,
    reachError: number,
}

local PHASES: {[string]: {[string]: number}} = {
    Walk = {
        FrontLeft = 0,
        FrontRight = 0.5,
        HindLeft = 0.75,
        HindRight = 0.25,
    },
    Trot = {
        FrontLeft = 0,
        FrontRight = 0.5,
        HindLeft = 0.5,
        HindRight = 0,
    },
}

local PAWS = {"FrontLeft", "FrontRight", "HindLeft", "HindRight"}

-- Args:
--   value: number; unconstrained periodic phase.
-- Returns:
--   number: phase in [0, 1), including for negative input.
local function wrap_phase(value: number): number
    return value % 1
end

-- Args:
--   value: number; value to ease between zero and one.
-- Returns:
--   number: smoothly interpolated, clamped value.
local function smoothstep(value: number): number
    local x = math.clamp(value, 0, 1)
    return x * x * (3 - 2 * x)
end

-- Args:
--   gait: string; Walk or Trot.
--   phase: number; cycle phase (one revolution equals one step cycle).
--   stride: number; total front-to-back paw displacement in studs.
--   lift: number; swing-phase height in studs.
--   stance_fraction: number?; fraction of the cycle with a planted
--     paw, default 0.62 for Walk and 0.55 for Trot.
-- Returns:
--   GaitSample: local forward/up offsets and stance flags for each
--     anatomical limb. These are goals, NOT rig/bone transforms.
function QuadrupedMotionCore.sample_gait(
    gait: string,
    phase: number,
    stride: number,
    lift: number,
    stance_fraction: number?
): GaitSample
    assert(PHASES[gait] ~= nil, "Unsupported quadruped gait: " .. gait)
    assert(phase == phase and math.abs(phase) < math.huge,
        "phase must be finite")
    assert(stride > 0 and stride < math.huge,
        "stride must be positive and finite")
    assert(lift >= 0 and lift < math.huge,
        "lift must be finite and non-negative")
    local stance = if stance_fraction ~= nil then stance_fraction
        else if gait == "Walk" then 0.62 else 0.55
    assert(stance > 0 and stance < 1, "Invalid stance fraction")

    local result: {[string]: PawOffset} = {}
    for _, paw in PAWS do
        local p = wrap_phase(phase + PHASES[gait][paw])
        if p < stance then
            -- A planted paw travels back relative to a moving torso.
            -- The later rig adapter must keep it fixed in world space.
            result[paw] = {
                forward = stride * (0.5 - p / stance),
                up = 0,
                planted = true,
            }
        else
            local swing = (p - stance) / (1 - stance)
            result[paw] = {
                forward = stride * (smoothstep(swing) - 0.5),
                up = lift * math.sin(math.pi * swing),
                planted = false,
            }
        end
    end
    return result :: GaitSample
end

-- Args:
--   hip: Vector3; first joint world position.
--   desired_paw: Vector3; world-space paw goal.
--   upper_length: number; length of thigh/upper segment.
--   lower_length: number; length of shin/lower segment.
--   bend_pole: Vector3; preferred world-space knee/hock direction.
-- Returns:
--   IKResult: knee and reachable paw positions with reach error.
--   A rig adapter still needs to convert these points into approved
--   Bone/Motor6D rotations, using the rig's REST axes.
function QuadrupedMotionCore.solve_two_bone(
    hip: Vector3,
    desired_paw: Vector3,
    upper_length: number,
    lower_length: number,
    bend_pole: Vector3
): IKResult
    assert(upper_length > 0 and lower_length > 0,
        "Both limb segments must have positive length")
    local separation = desired_paw - hip
    local distance = separation.Magnitude
    local direction = if distance > 1e-6 then separation.Unit
        else Vector3.new(0, -1, 0)
    local minimum = math.abs(upper_length - lower_length) + 1e-4
    local maximum = upper_length + lower_length - 1e-4
    assert(minimum < maximum,
        "IK segments are too unequal to resolve at this tolerance")
    local reach = math.clamp(distance, minimum, maximum)
    local paw = hip + direction * reach
    local along = (
        upper_length * upper_length
        - lower_length * lower_length
        + reach * reach
    ) / (2 * reach)
    local across = math.sqrt(math.max(
        0, upper_length * upper_length - along * along
    ))
    local pole = bend_pole - direction * bend_pole:Dot(direction)
    if pole.Magnitude < 1e-5 then
        local fallback = if math.abs(direction.Y) < 0.9
            then Vector3.yAxis else Vector3.xAxis
        pole = fallback - direction * fallback:Dot(direction)
    end
    local knee = hip + direction * along + pole.Unit * across
    return {
        knee = knee,
        paw = paw,
        reachError = (paw - desired_paw).Magnitude,
    }
end

return table.freeze(QuadrupedMotionCore)
