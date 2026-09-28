--!strict
-- Server-owned dungeon quest interactions and collectible definitions.

local Definitions = {}

local BY_INTERACTION_ID = table.freeze({
    TempleHiddenPanel = table.freeze({
        Id = "TempleHiddenPanel",
        DungeonId = "TestDungeon",
        DifficultyId = "Depth1",
        EventTargetId = "TestDungeon:HiddenPanel:Room2",
        PrerequisiteEncounterId = "CombatRoom1",
        MaxDistance = 12,
        CollectibleId = "TempleHiddenWardFragment",
    }),
})

local BY_COLLECTIBLE_ID = table.freeze({
    TempleHiddenWardFragment = table.freeze({
        Id = "TempleHiddenWardFragment",
        DungeonId = "TestDungeon",
        DifficultyId = "Depth1",
        InteractionId = "TempleHiddenPanel",
        ItemId = "hidden_ward_fragment",
        EventTargetId = "hidden_ward_fragment",
        MaxDistance = 10,
    }),
})

--[[
Returns one trusted dungeon interaction definition.

Args:
    interaction_id (string): Stable server-owned interaction identifier.

Returns:
    any?: Frozen interaction definition when known.
]]
function Definitions.interaction(interaction_id: string): any?
    return BY_INTERACTION_ID[interaction_id]
end

--[[
Returns one trusted dungeon collectible definition.

Args:
    collectible_id (string): Stable server-owned collectible identifier.

Returns:
    any?: Frozen collectible definition when known.
]]
function Definitions.collectible(collectible_id: string): any?
    return BY_COLLECTIBLE_ID[collectible_id]
end

return table.freeze(Definitions)
