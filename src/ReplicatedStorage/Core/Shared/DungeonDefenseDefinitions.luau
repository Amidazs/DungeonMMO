--!strict
-- Server-owned defend/survive objective definitions.

local Definitions = {}

local DEFENSES = table.freeze({
    TempleResonanceWard = table.freeze({
        Id = "TempleResonanceWard",
        DungeonId = "TestDungeon",
        DifficultyId = "Depth1",
        EventTargetId = "TestDungeon:ResonanceWard:Room2",
        StartAfterEncounterId = "CombatRoom1",
        FinishEncounterId = "CombatRoom2",
        MaxStartDistance = 10,
        ZoneRadius = 18,
        GraceSeconds = 3,
        TickMaxSeconds = 1,
    }),
})

--[[
Returns one trusted dungeon defense definition.

Args:
    defense_id (string): Stable server-owned defense identifier.

Returns:
    any?: Frozen defense definition when known.
]]
function Definitions.get(defense_id: string): any?
    return DEFENSES[defense_id]
end

return table.freeze(Definitions)
