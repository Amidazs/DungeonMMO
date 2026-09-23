--!strict
-- A server-owned NPC evasion check for real physical melee and arrows.
-- Unauthored NPCs have zero evasion and retain their established hit rate.
local ScoutAccuracyRules = {}

--[[
Computes physical hit probability from server-authored NPC evasiveness.

Args:
    evasion (number): NPC evasion probability authored by the server.
    accuracy_bonus (number): Authorized active purchased stance bonus.

Returns:
    number: Validated probability in the inclusive zero-to-one range.
]]
function ScoutAccuracyRules.hit_chance(
    evasion: number, accuracy_bonus: number
): number
    local safe_evasion = math.clamp(
        if type(evasion) == "number" and evasion == evasion
            then evasion else 0, 0, 0.4
    )
    local safe_bonus = math.clamp(
        if type(accuracy_bonus) == "number"
            and accuracy_bonus == accuracy_bonus
            then accuracy_bonus else 0, 0, 0.2
    )
    return math.clamp(1 - safe_evasion + safe_bonus, 0, 1)
end

--[[
Resolves an exclusively server-supplied random roll for one physical hit.

Args:
    evasion (number): Current server-owned NPC physical evasiveness.
    accuracy_bonus (number): Active source-rank accuracy bonus.
    roll (number): Uniform random input in the unit interval.

Returns:
    boolean: True only when the attack beats the target's evasion.
]]
function ScoutAccuracyRules.is_hit(
    evasion: number, accuracy_bonus: number, roll: number
): boolean
    assert(type(roll) == "number" and roll == roll
        and roll >= 0 and roll <= 1, "Hit roll must be normalized")
    return roll < ScoutAccuracyRules.hit_chance(evasion, accuracy_bonus)
end

return table.freeze(ScoutAccuracyRules)
