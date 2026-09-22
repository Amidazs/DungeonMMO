--!strict
-- Chronicle 4 first-transfer classes: raw rank-entry counts, not a
-- DungeonMMO Ranger/Rogue quota. Both C4 class lists teach bow AND dagger.
-- Includes listed automatic expertise/common-item grants in source totals.
local C4ScoutReferenceTargets = {}

local TARGETS = table.freeze({
    Human = table.freeze({
        SourceClass = "Rogue",
        SourceUrl = "https://l2hub.info/c4/classes/rogue",
        PreviousClass = "Human Fighter",
        NextClasses = table.freeze({"Hawkeye", "Treasure Hunter"}),
        Levels = table.freeze({
            [20] = 20, [24] = 19, [28] = 20,
            [32] = 19, [36] = 21,
        }),
    }),
    Elf = table.freeze({
        SourceClass = "Elven Scout",
        SourceUrl = "https://l2hub.info/c4/classes/elven_scout",
        PreviousClass = "Elven Fighter",
        NextClasses = table.freeze({"Silver Ranger", "Plainswalker"}),
        Levels = table.freeze({
            [20] = 26, [24] = 25, [28] = 26,
            [32] = 25, [36] = 27,
        }),
    }),
})

--[[
Returns the exact C4 first-transfer class source and bracket totals.

Args:
    race_id (string): Human or Elf first-transfer class race.

Returns:
    any?: Frozen raw class reference or nil for an unmapped race.
]]
function C4ScoutReferenceTargets.get(race_id: string): any?
    return TARGETS[race_id]
end

--[[
Returns all verified C4 Rogue/Scout reference brackets.

Args:
    None.

Returns:
    any: Human and Elf class sources with per-level raw rank totals.
]]
function C4ScoutReferenceTargets.all(): any
    return TARGETS
end

return table.freeze(C4ScoutReferenceTargets)
