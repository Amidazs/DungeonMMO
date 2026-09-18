--!strict
local DungeonEncounterFlow = {}
DungeonEncounterFlow.__index = DungeonEncounterFlow

local function operation(
    ok: boolean,
    reason: string?,
    extra: any?
): any
    local result = extra or {}
    result.ok = ok
    result.reason = reason
    return result
end

function DungeonEncounterFlow.new(
    controller: any,
    binding_result: any
): any
    assert(
        controller ~= nil,
        "DungeonEncounterFlow requires an encounter controller."
    )
    assert(
        type(binding_result) == "table"
            and binding_result.ok == true
            and type(binding_result.by_slot) == "table"
            and type(binding_result.by_encounter) == "table"
            and type(binding_result.by_runtime) == "table"
            and type(binding_result.ordered) == "table",
        "DungeonEncounterFlow requires resolved bindings."
    )

    return setmetatable({
        _controller = controller,
        _bindings = binding_result,
    }, DungeonEncounterFlow)
end

function DungeonEncounterFlow:start_slot(
    room_slot_id: string
): any
    local binding = self._bindings.by_slot[room_slot_id]
    if not binding then
        return operation(false, "UnknownRoomSlot")
    end

    local started = self._controller:start(
        binding.PlanEncounterId
    )
    if started.ok ~= true then
        return started
    end

    started.binding = binding
    return started
end

function DungeonEncounterFlow:clear_runtime(
    runtime_encounter_id: string
): any
    local binding =
        self._bindings.by_runtime[runtime_encounter_id]
    if not binding then
        return operation(false, "UnknownRuntimeEncounter")
    end

    local cleared = self._controller:clear(
        binding.PlanEncounterId
    )
    if cleared.ok ~= true then
        return cleared
    end

    cleared.binding = binding
    cleared.next_binding = if type(
        cleared.next_encounter_id
    ) == "string"
        then self._bindings.by_encounter[
            cleared.next_encounter_id
        ]
        else nil
    return cleared
end

function DungeonEncounterFlow:cancel_slot(
    room_slot_id: string
): any
    local binding = self._bindings.by_slot[room_slot_id]
    if not binding then
        return operation(false, "UnknownRoomSlot")
    end

    return self._controller:cancel_active(
        binding.PlanEncounterId
    )
end

function DungeonEncounterFlow:state_for_slot(
    room_slot_id: string
): string?
    local binding = self._bindings.by_slot[room_slot_id]
    if not binding then
        return nil
    end
    return self._controller:state_of(
        binding.PlanEncounterId
    )
end

function DungeonEncounterFlow:binding_for_slot(
    room_slot_id: string
): any?
    return self._bindings.by_slot[room_slot_id]
end

function DungeonEncounterFlow:binding_for_runtime(
    runtime_encounter_id: string
): any?
    return self._bindings.by_runtime[runtime_encounter_id]
end

function DungeonEncounterFlow:binding_for_encounter(
    encounter_id: string
): any?
    return self._bindings.by_encounter[encounter_id]
end

function DungeonEncounterFlow:first_binding(): any?
    return self._bindings.ordered[1]
end

function DungeonEncounterFlow:next_binding(): any?
    local next_id = self._controller:next_id()
    if type(next_id) ~= "string" then
        return nil
    end
    return self._bindings.by_encounter[next_id]
end

function DungeonEncounterFlow:is_complete(): boolean
    return self._controller:is_complete()
end

return table.freeze(DungeonEncounterFlow)
