--!strict
-- Server-owned ordered puzzle definitions for dungeon Adventure content.

local Definitions = {}

local PUZZLES = table.freeze({
    TempleResonanceLock = table.freeze({
        Id = "TempleResonanceLock",
        DungeonId = "TestDungeon",
        DifficultyId = "Depth1",
        EventTargetId = "TestDungeon:ResonanceLock:Room2",
        PrerequisiteEncounterId = "CombatRoom2",
        RequiredItemId = "temple_resonance_shard",
        MaxDistance = 10,
        Sequence = table.freeze({
            "MoonRune",
            "RootRune",
            "FlameRune",
        }),
    }),
})

--[[
Returns one trusted ordered dungeon puzzle definition.

Args:
    puzzle_id (string): Stable server-owned puzzle identifier.

Returns:
    any?: Frozen puzzle definition when known.
]]
function Definitions.get(puzzle_id: string): any?
    return PUZZLES[puzzle_id]
end

return table.freeze(Definitions)
