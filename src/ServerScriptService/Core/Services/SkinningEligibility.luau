--!strict
-- Server-owned skinning eligibility catalogue. Adding a creature to the
-- combat game never makes it skinnable automatically.
local SkinningEligibility = {}

-- Only explicitly approved, animal-like creature identities belong here.
-- These are future creature identities, not currently spawned enemies.
local SKINNABLE_SPECIES = table.freeze({
    forest_wolf = true,
    wild_boar = true,
    cave_bear = true,
})

-- Args:
--   creature_id: any; server-known creature identity, not a display name.
--   creature_family: any; server-owned creature family.
-- Returns:
--   boolean: true only for a specifically registered animal-like creature.
function SkinningEligibility.is_species_allowed(
    creature_id: any,
    creature_family: any
): boolean
    return type(creature_id) == "string"
        and creature_family == "Beast"
        and SKINNABLE_SPECIES[creature_id] == true
end

-- Args:
--   creature_id: any; server-known identity from the enemy factory.
--   creature_family: any; family assigned by the server enemy factory.
--   defeated: any; whether the server confirmed the creature's death.
--   loot_complete: any; whether the corpse has been looted.
--   already_skinned: any; whether this corpse was previously harvested.
-- Returns:
--   boolean: true only when the animal corpse is ready to skin once.
function SkinningEligibility.can_skin(
    creature_id: any,
    creature_family: any,
    defeated: any,
    loot_complete: any,
    already_skinned: any
): boolean
    return SkinningEligibility.is_species_allowed(
        creature_id,
        creature_family
    )
        and defeated == true
        and loot_complete == true
        and already_skinned == false
end

return table.freeze(SkinningEligibility)
