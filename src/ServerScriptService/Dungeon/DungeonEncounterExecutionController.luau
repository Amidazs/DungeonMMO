--!strict
local DungeonEncounterExecutionController = {}
DungeonEncounterExecutionController.__index =
    DungeonEncounterExecutionController

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

-- Creates the coordinator between encounter flow and execution registry.
function DungeonEncounterExecutionController.new(
    flow: any,
    registry: any
): any
    assert(
        flow ~= nil,
        "DungeonEncounterExecutionController requires flow."
    )
    assert(
        registry ~= nil,
        "DungeonEncounterExecutionController requires registry."
    )

    return setmetatable({
        _flow = flow,
        _registry = registry,
    }, DungeonEncounterExecutionController)
end

-- Validates content, starts sequence state, then executes the encounter.
function DungeonEncounterExecutionController:start_slot(
    room_slot_id: string,
    context: any
): any
    local binding =
        self._flow:binding_for_slot(room_slot_id)
    if not binding then
        return result(false, "UnknownRoomSlot")
    end

    local encounter = binding.Encounter
    if type(encounter) ~= "table" then
        return result(false, "EncounterDescriptorMissing")
    end

    local validated = self._registry:validate(
        encounter,
        binding,
        context
    )
    if validated.ok ~= true then
        return validated
    end

    local started = self._flow:start_slot(room_slot_id)
    if started.ok ~= true then
        return started
    end

    local execution = self._registry:execute(
        encounter,
        binding,
        context
    )
    if execution.ok ~= true then
        local rollback = self._flow:cancel_slot(
            room_slot_id
        )
        return result(false, execution.reason, {
            Binding = binding,
            Execution = execution,
            SequenceStarted = true,
            Rollback = rollback,
        })
    end

    return result(true, nil, {
        Binding = binding,
        Execution = execution,
        SequenceStarted = true,
    })
end

-- Aborts a successfully spawned encounter after downstream startup rejection.
function DungeonEncounterExecutionController:abort_slot(
    room_slot_id: string,
    execution: any,
    context: any
): any
    local binding = self._flow:binding_for_slot(room_slot_id)
    if not binding then
        return result(false, "UnknownRoomSlot")
    end

    local encounter = binding.Encounter
    if type(encounter) ~= "table" then
        return result(false, "EncounterDescriptorMissing")
    end

    local cleanup = self._registry:cleanup(
        encounter,
        binding,
        execution,
        context
    )
    local rollback = self._flow:cancel_slot(room_slot_id)

    return result(
        cleanup.ok == true and rollback.ok == true,
        if cleanup.ok ~= true
            then cleanup.reason
            elseif rollback.ok ~= true
                then rollback.reason
                else nil,
        {
            Cleanup = cleanup,
            Rollback = rollback,
        }
    )
end

return table.freeze(DungeonEncounterExecutionController)
