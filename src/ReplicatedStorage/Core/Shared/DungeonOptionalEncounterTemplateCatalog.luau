--!strict
-- Server-issued optional encounter placements. A template is eligible only
-- where the selected physical layout explicitly supplies its own room slot.
-- The late route is backend-ready, not a registered/authorised live room.
local Catalog = {}

local ANCHORS = table.freeze({
    Depth1 = table.freeze({
        First = "CombatRoom1", Final = "Depth1Boss",
    }),
    Depth2 = table.freeze({
        First = "Depth2Combat1", Second = "Depth2Combat2",
        Final = "Depth2Boss",
    }),
    Depth3 = table.freeze({
        First = "Depth3Combat1", Second = "Depth3Combat2",
        Final = "Depth3Boss",
    }),
    Depth4 = table.freeze({
        First = "Depth4Combat1", Second = "Depth4MiniBoss1",
        Final = "Depth4FinalBoss",
    }),
})

local SUPPORTED = table.freeze({
    TestDungeon = true,
    AbandonedMine = true,
})

-- Returns a fresh server-owned placement descriptor for one known template.
-- Args: dungeon_id (string): Authoritative session dungeon.
--       depth_id (string): Authoritative selected difficulty.
--       kind (string): Event or Secret.
--       template_id (string): Immutable issued template identity.
-- Returns: any?: Placement, or nil for unsupported dungeon/depth/choice.
function Catalog.get(
    dungeon_id: string, depth_id: string,
    kind: string, template_id: string
): any?
    if not SUPPORTED[dungeon_id] then return nil end
    local anchors = ANCHORS[depth_id]
    if not anchors then return nil end
    if kind == "Event" and template_id == "EventAfterRoom1" then
        return {
            Id = template_id,
            RoomSlotId = "EventArena",
            InsertAfterId = anchors.First,
            EncounterSuffix = "Encounter",
            RequiresPlacementContract = false,
        }
    end
    if kind == "Event" and template_id == "EventAfterRoom2"
        and anchors.Second
    then
        return {
            Id = template_id,
            RoomSlotId = "EventArenaLate",
            InsertAfterId = anchors.Second,
            EncounterSuffix = "LateEncounter",
            RequiresPlacementContract = true,
        }
    end
    if kind == "Secret" and template_id == "SecretBeforeFinal" then
        return {
            Id = template_id,
            RoomSlotId = "SecretArena",
            InsertBeforeId = anchors.Final,
            EncounterSuffix = "Encounter",
            RequiresPlacementContract = false,
        }
    end
    return nil
end

return table.freeze(Catalog)
