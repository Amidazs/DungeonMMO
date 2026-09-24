--!strict
-- Server-only chip damage for a genuine blocked hostile physical strike.
-- Timed parries and dodges are intentionally handled before this module.

local BlockedHitDamageRules = {}

local BLOCK_DAMAGE_FRACTION = 0.45
local MINIMUM_INCOMING_FRACTION = 0.20

--[[
Resolves a blocked hit after earned armour, shield and active guard.

A shield block cannot turn an incoming hostile physical strike into
invulnerability. The minimum is applied before any separately earned
temporary ward, so this does not invent damage through an actual ward.

Args:
    incoming_damage (number): Positive hit before defence reductions.
    defended_damage (number): Server-authoritative damage after armour,
        shield mastery and active defensive buffs.
    source_kind (string): Incoming damage category from the server.
    blocked (boolean?): True only for a genuine DefenseService block.

Returns:
    number: Bounded damage before any separate temporary ward absorbs it.
]]
function BlockedHitDamageRules.resolve(
    incoming_damage: number,
    defended_damage: number,
    source_kind: string,
    blocked: boolean?
): number
    if blocked ~= true or source_kind ~= "EnemyMelee" then
        return defended_damage
    end
    if incoming_damage <= 0 or defended_damage <= 0 then
        return defended_damage
    end

    local chip_damage = defended_damage * BLOCK_DAMAGE_FRACTION
    local minimum_damage = incoming_damage * MINIMUM_INCOMING_FRACTION
    return math.clamp(
        math.max(chip_damage, minimum_damage),
        0,
        incoming_damage
    )
end

return table.freeze(BlockedHitDamageRules)
