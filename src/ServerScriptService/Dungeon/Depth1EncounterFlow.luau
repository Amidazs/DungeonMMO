--!strict
local Depth1EncounterFlow = {}
Depth1EncounterFlow.__index = Depth1EncounterFlow

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

-- Builds a lookup from legacy runtime encounter IDs to physical bindings.
local function build_runtime_lookup(bindings: any): {[string]: any}
    local result = {}

    for _, binding in ipairs(bindings.ordered) do
        result[binding.RuntimeEncounterId] = binding
    end

    return result
end

-- Creates the compatibility adapter between physical Depth1 rooms and the
-- generic logical encounter controller.
function Depth1EncounterFlow.new(
    controller: any,
    binding_result: any
): any
    assert(
        controller ~= nil,
        "Depth1EncounterFlow requires an encounter controller."
    )
    assert(
        type(binding_result) == "table"
            and binding_result.ok == true
            and type(binding_result.by_slot) == "table"
            and type(binding_result.ordered) == "table",
        "Depth1EncounterFlow requires resolved bindings."
    )

    return setmetatable({
        _controller = controller,
        _by_slot = binding_result.by_slot,
        _by_runtime_id = build_runtime_lookup(binding_result),
    }, Depth1EncounterFlow)
end

-- Starts the logical encounter bound to one physical room slot.
function Depth1EncounterFlow:start_slot(room_slot_id: string): any
    local binding = self._by_slot[room_slot_id]
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

-- Clears the logical encounter represented by one legacy runtime ID.
function Depth1EncounterFlow:clear_runtime(
    runtime_encounter_id: string
): any
    local binding = self._by_runtime_id[runtime_encounter_id]
    if not binding then
        return operation(false, "UnknownRuntimeEncounter")
    end

    local cleared = self._controller:clear(
        binding.PlanEncounterId
    )
    if cleared.ok ~= true then
        return cleared
    end

    local next_binding = nil
    if type(cleared.next_encounter_id) == "string" then
        for _, candidate in pairs(self._by_slot) do
            if candidate.PlanEncounterId
                == cleared.next_encounter_id
            then
                next_binding = candidate
                break
            end
        end
    end

    cleared.binding = binding
    cleared.next_binding = next_binding
    return cleared
end

-- Returns lifecycle state for the logical encounter bound to one room slot.
function Depth1EncounterFlow:state_for_slot(
    room_slot_id: string
): string?
    local binding = self._by_slot[room_slot_id]
    if not binding then
        return nil
    end

    return self._controller:state_of(
        binding.PlanEncounterId
    )
end

-- Returns the physical binding for one room slot.
function Depth1EncounterFlow:binding_for_slot(
    room_slot_id: string
): any?
    return self._by_slot[room_slot_id]
end

-- Returns whether the generic controller considers the required run complete.
function Depth1EncounterFlow:is_complete(): boolean
    return self._controller:is_complete()
end

return table.freeze(Depth1EncounterFlow)
