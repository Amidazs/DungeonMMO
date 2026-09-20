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

    local deferred = binding.Kind == "SecretBoss"
        and self._controller:state_of(binding.PlanEncounterId) == "Skipped"
    local started = if deferred
        then self._controller:start_skipped_secret(binding.PlanEncounterId)
        else self._controller:start(binding.PlanEncounterId)
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

-- Skips only an optional Secret boss when its direct successor is entered.
-- Args: room_slot_id (string): Physical slot the player entered.
-- Returns: any: Persisted skip result or a fail-closed rejection.
function DungeonEncounterFlow:skip_secret_before(
    room_slot_id: string
): any
    local current = self:next_binding()
    if not current or current.Kind ~= "SecretBoss" then
        return operation(false, "NoOptionalSecretToSkip")
    end
    local encounter = self._controller:get(current.PlanEncounterId)
    if not encounter or encounter.CompletionRequired ~= false then
        return operation(false, "SecretEncounterRequired")
    end

    local successor = nil
    for index, binding in ipairs(self._bindings.ordered) do
        if binding.PlanEncounterId == current.PlanEncounterId then
            successor = self._bindings.ordered[index + 1]
            break
        end
    end
    if not successor or successor.RoomSlotId ~= room_slot_id then
        return operation(false, "SecretSuccessorMismatch")
    end

    local skipped = self._controller:skip(current.PlanEncounterId)
    if skipped.ok ~= true then
        return skipped
    end
    return operation(true, nil, {
        skipped_binding = current,
        next_binding = successor,
    })
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
