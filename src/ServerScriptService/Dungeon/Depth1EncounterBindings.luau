--!strict
local Dungeon = script.Parent

local DungeonEncounterRuntimeState = require(
    Dungeon:WaitForChild("DungeonEncounterRuntimeState")
)

local Depth1EncounterBindings = {}

local SLOT_BINDINGS = table.freeze({
    Room1 = table.freeze({
        RuntimeEncounterId = "CombatRoom1",
        EnvironmentRoomId = "Room1",
        CheckpointAnchor = "Temple.Room1.Checkpoint",
    }),
    Room2 = table.freeze({
        RuntimeEncounterId = "CombatRoom2",
        EnvironmentRoomId = "Room2",
        CheckpointAnchor = "Temple.Room2.Checkpoint",
    }),
    Room3 = table.freeze({
        RuntimeEncounterId = "MarauderCaptain",
        EnvironmentRoomId = "Room3",
        CheckpointAnchor = "Temple.Room3.Checkpoint",
    }),
})

local function result(
    ok: boolean,
    reason: string?,
    extra: any?
): any
    local response = extra or {}
    response.ok = ok
    response.reason = reason
    return response
end

-- Maps the current three-slot physical Depth1 dungeon onto logical encounters.
function Depth1EncounterBindings.resolve(
    encounters: {any}
): any
    if type(encounters) ~= "table" or #encounters == 0 then
        return result(false, "InvalidEncounterPlan")
    end

    local by_slot = {}
    local ordered = {}

    for sequence, encounter in ipairs(encounters) do
        if type(encounter) ~= "table"
            or type(encounter.Id) ~= "string"
            or type(encounter.RoomSlotId) ~= "string"
        then
            return result(false, "InvalidEncounter")
        end

        local physical = SLOT_BINDINGS[encounter.RoomSlotId]
        if not physical then
            return result(false, "EncounterBindingMissing", {
                EncounterId = encounter.Id,
                RoomSlotId = encounter.RoomSlotId,
            })
        end

        if by_slot[encounter.RoomSlotId] then
            return result(false, "DuplicatePhysicalRoomSlot", {
                EncounterId = encounter.Id,
                RoomSlotId = encounter.RoomSlotId,
            })
        end

        local binding = {
            PlanEncounterId = encounter.Id,
            RuntimeEncounterId = physical.RuntimeEncounterId,
            EnvironmentRoomId = physical.EnvironmentRoomId,
            CheckpointAnchor = physical.CheckpointAnchor,
            CheckpointId =
                DungeonEncounterRuntimeState.checkpoint_id(
                    encounter.Id
                ),
            CheckpointSequence = sequence,
            Kind = encounter.Kind,
            BossId = encounter.BossId,
        }

        by_slot[encounter.RoomSlotId] = binding
        table.insert(ordered, binding)
    end

    for room_slot_id in pairs(SLOT_BINDINGS) do
        if not by_slot[room_slot_id] then
            return result(false, "RequiredPhysicalRoomMissing", {
                RoomSlotId = room_slot_id,
            })
        end
    end

    return result(true, nil, {
        by_slot = by_slot,
        ordered = ordered,
    })
end

return table.freeze(Depth1EncounterBindings)
