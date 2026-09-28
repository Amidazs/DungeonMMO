--!strict
-- Server-owned escort definitions for released dungeon quest content.

local Definitions = {}

local ESCORTS = table.freeze({
    MineSurveyor = table.freeze({
        Id = "MineSurveyor",
        DungeonId = "AbandonedMine",
        DifficultyId = "Depth1",
        EventTargetId = "AbandonedMine:MineSurveyor",
        StartAfterEncounterId = "CombatRoom1",
        FinishAfterEncounterId = "CombatRoom2",
        MaxStartDistance = 12,
        RunSpeed = 18,
        PartyResumeDistance = 45,
    }),
})

--[[
Returns one trusted dungeon escort definition.

Args:
    escort_id (string): Stable server-owned escort identifier.

Returns:
    any?: Frozen escort definition when known.
]]
function Definitions.get(escort_id: string): any?
    return ESCORTS[escort_id]
end

return table.freeze(Definitions)
