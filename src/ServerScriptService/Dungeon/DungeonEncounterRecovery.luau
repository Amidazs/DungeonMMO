--!strict
local DungeonEncounterRecovery = {}

local function checkpoint_slot(
    binding_result: any,
    checkpoint_id: string,
    legacy_slot_by_checkpoint: any?
): string?
    local legacy = if type(legacy_slot_by_checkpoint)
        == "table"
        then legacy_slot_by_checkpoint[checkpoint_id]
        else nil
    if type(legacy) == "string" then
        return legacy
    end

    for room_slot_id, binding in pairs(
        binding_result.by_slot
    ) do
        if binding.CheckpointId == checkpoint_id then
            return room_slot_id
        end
    end

    return nil
end

local function pending_states(
    binding_result: any
): {[string]: string}
    local states = {}
    for _, binding in ipairs(binding_result.ordered) do
        states[binding.PlanEncounterId] = "Pending"
    end
    return states
end

function DungeonEncounterRecovery.snapshot_from_checkpoint(
    binding_result: any,
    checkpoint_id: string,
    legacy_slot_by_checkpoint: any?
): any?
    if type(binding_result) ~= "table"
        or binding_result.ok ~= true
        or type(binding_result.by_slot) ~= "table"
        or type(binding_result.ordered) ~= "table"
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
        checkpoint_id,
        legacy_slot_by_checkpoint
    )
    if not target_slot then
        return nil
    end

    local target = binding_result.by_slot[target_slot]
    if not target then
        return nil
    end

    for _, binding in ipairs(binding_result.ordered) do
        if binding.CheckpointSequence
            < target.CheckpointSequence
        then
            states[binding.PlanEncounterId] = "Cleared"
        end
    end

    return {
        Version = 1,
        EncounterStates = states,
        ActiveEncounterId = nil,
        NextEncounterId = target.PlanEncounterId,
    }
end

return table.freeze(DungeonEncounterRecovery)
