--!strict
local Depth1EncounterRecovery = {}

local LEGACY_SLOT_BY_CHECKPOINT = table.freeze({
    Room1Start = "Room1",
    Room2Start = "Room2",
    BossRoomStart = "Room3",
})

local function checkpoint_slot(
    binding_result: any,
    checkpoint_id: string
): string?
    local legacy_slot = LEGACY_SLOT_BY_CHECKPOINT[checkpoint_id]
    if legacy_slot then
        return legacy_slot
    end

    for room_slot_id, binding in pairs(binding_result.by_slot) do
        if binding.CheckpointId == checkpoint_id then
            return room_slot_id
        end
    end

    return nil
end

local function pending_states(binding_result: any): {[string]: string}
    local states = {}

    for _, binding in ipairs(binding_result.ordered) do
        states[binding.PlanEncounterId] = "Pending"
    end

    return states
end

-- Converts one legacy or stable Depth1 checkpoint into a generic sequencer
-- snapshot. The current encounter always restarts as Pending.
function Depth1EncounterRecovery.snapshot_from_checkpoint(
    binding_result: any,
    checkpoint_id: string
): any?
    if type(binding_result) ~= "table"
        or binding_result.ok ~= true
        or type(checkpoint_id) ~= "string"
    then
        return nil
    end

    local states = pending_states(binding_result)

    if checkpoint_id == "Entrance" then
        local first = binding_result.ordered[1]
        return {
            Version = 1,
            EncounterStates = states,
            ActiveEncounterId = nil,
            NextEncounterId = first
                and first.PlanEncounterId
                or nil,
        }
    end

    local target_slot = checkpoint_slot(
        binding_result,
        checkpoint_id
    )
    if not target_slot then
        return nil
    end

    local target_binding = binding_result.by_slot[target_slot]
    if not target_binding then
        return nil
    end

    local target_sequence = target_binding.CheckpointSequence
    local target_id = target_binding.PlanEncounterId

    for _, binding in ipairs(binding_result.ordered) do
        if binding.CheckpointSequence < target_sequence then
            states[binding.PlanEncounterId] = "Cleared"
        end
    end

    return {
        Version = 1,
        EncounterStates = states,
        ActiveEncounterId = nil,
        NextEncounterId = target_id,
    }
end

return table.freeze(Depth1EncounterRecovery)
