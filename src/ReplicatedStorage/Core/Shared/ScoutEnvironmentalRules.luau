--!strict
-- Pure purchased-rank effects for the first-transfer Scout environment.
local PassiveSkillEffects = require(
    script.Parent:WaitForChild("PassiveSkillEffects")
)

local ScoutEnvironmentalRules = {}

local BASE_OXYGEN_SECONDS = 12
local FALL_SPEED_THRESHOLD = 70
local FALL_DAMAGE_PER_STUD_PER_SECOND = 0.6

--[[
Computes real maximum breathing reserve for an authenticated character.

Args:
    character (any): Authoritative server-selected race, class and skills.

Returns:
    number: Breathing seconds, 12 baseline or 27 when rank is purchased.
]]
function ScoutEnvironmentalRules.max_oxygen(character: any): number
    return BASE_OXYGEN_SECONDS
        + PassiveSkillEffects.scout_oxygen_bonus(character)
end

--[[
Updates server-side air reserve from genuine submerged head exposure.

Args:
    oxygen (number): Previous seconds of breathable air.
    delta_seconds (number): Actual bounded elapsed server time.
    submerged (boolean): Server-sampled head position inside terrain water.
    character (any): Selected server profile, never client-sent skill ranks.

Returns:
    number: Remaining air in seconds, bounded by current purchased rank.
]]
function ScoutEnvironmentalRules.next_oxygen(
    oxygen: number, delta_seconds: number, submerged: boolean,
    character: any
): number
    local maximum = ScoutEnvironmentalRules.max_oxygen(character)
    if not submerged then
        return maximum
    end
    if type(oxygen) ~= "number" or oxygen ~= oxygen then
        oxygen = maximum
    end
    if type(delta_seconds) ~= "number" or delta_seconds ~= delta_seconds
        or delta_seconds < 0
    then
        delta_seconds = 0
    end
    return math.clamp(oxygen - math.min(delta_seconds, 1), 0, maximum)
end

--[[
Calculates only actual hard-landing injury from a measured world impact.

Args:
    character (any): Authenticated class and purchased Fall Resistance rank.
    downward_speed (number): Peak downward velocity of genuine freefall.

Returns:
    number: Server-side fall injury, reduced solely by the trained passive.
]]
function ScoutEnvironmentalRules.fall_damage(
    character: any, downward_speed: number
): number
    if type(downward_speed) ~= "number"
        or downward_speed ~= downward_speed
        or downward_speed <= FALL_SPEED_THRESHOLD
    then
        return 0
    end
    local injury = math.min(
        (downward_speed - FALL_SPEED_THRESHOLD)
            * FALL_DAMAGE_PER_STUD_PER_SECOND,
        120
    )
    return injury * (
        1 - PassiveSkillEffects.scout_fall_reduction(character)
    )
end

return table.freeze(ScoutEnvironmentalRules)
