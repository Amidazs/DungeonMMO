--!strict
local DungeonEncounterPlan = {}

local VALID_KINDS = table.freeze({
    Combat = true,
    MiniBoss = true,
    Boss = true,
    FinalBoss = true,
    EventBoss = true,
    EventCombat = true,
    SecretBoss = true,
})

local function response(
    ok: boolean,
    reason: string?,
    encounters: {any}?
): any
    return {
        ok = ok,
        reason = reason,
        encounters = encounters or {},
    }
end

local function clone_table(source: any): any
    local result = {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            result[key] = clone_table(value)
        else
            result[key] = value
        end
    end
    return result
end
local function validate_descriptor(
    encounter: any,
    seen_ids: {[string]: boolean}
): string?
    if type(encounter) ~= "table"
        or type(encounter.Id) ~= "string"
        or encounter.Id == ""
    then
        return "InvalidEncounter"
    end

    if seen_ids[encounter.Id] then
        return "DuplicateEncounterId"
    end

    if type(encounter.Kind) ~= "string"
        or VALID_KINDS[encounter.Kind] ~= true
    then
        return "UnknownEncounterKind"
    end

    if type(encounter.RoomSlotId) ~= "string"
        or encounter.RoomSlotId == ""
    then
        return "InvalidRoomSlotId"
    end

    seen_ids[encounter.Id] = true
    return nil
end

local function activation_matches(
    activation: any?,
    instance_state: any
): boolean
    if activation == nil then
        return true
    end
    if type(activation) ~= "table"
        or type(activation.Type) ~= "string"
    then
        return false
    end
    if activation.Type == "InstanceFlag" then
        if type(activation.Key) ~= "string"
            or activation.Key == ""
        then
            return false
        end
        return instance_state[activation.Key]
            == activation.Value
    end

    if activation.Type == "RareState" then
        return type(activation.Id) == "string"
            and instance_state.RareStateId == activation.Id
    end

    return false
end

local function find_index(
    encounters: {any},
    encounter_id: string
): number?
    for index, encounter in ipairs(encounters) do
        if encounter.Id == encounter_id then
            return index
        end
    end
    return nil
end

local function prepare_optional(
    optional: any,
    seen_ids: {[string]: boolean}
): (any?, string?)
    if type(optional) ~= "table"
        or type(optional.Encounter) ~= "table"
    then
        return nil, "InvalidOptionalEncounter"
    end

    local has_before = type(optional.InsertBeforeId) == "string"
    local has_after = type(optional.InsertAfterId) == "string"
    if has_before == has_after then
        return nil, "InvalidInsertionAnchor"
    end

    local copy = clone_table(optional.Encounter)
    local descriptor_error =
        validate_descriptor(copy, seen_ids)
    if descriptor_error then
        return nil, descriptor_error
    end

    copy.CompletionRequired =
        optional.CompletionRequired == true
    return copy, nil
end
-- Materializes one authoritative encounter plan from base and optional data.
function DungeonEncounterPlan.materialize(
    base_sequence: {any},
    optional_encounters: {any}?,
    instance_state: any?
): any
    if type(base_sequence) ~= "table" then
        return response(false, "InvalidBaseSequence")
    end

    local state = if type(instance_state) == "table"
        then instance_state
        else {}
    local result = {}
    local seen_ids: {[string]: boolean} = {}

    for _, encounter in ipairs(base_sequence) do
        local copy = clone_table(encounter)
        local descriptor_error =
            validate_descriptor(copy, seen_ids)
        if descriptor_error then
            return response(false, descriptor_error)
        end

        if copy.CompletionRequired == nil then
            copy.CompletionRequired = true
        else
            copy.CompletionRequired =
                copy.CompletionRequired == true
        end
        table.insert(result, copy)
    end

    for _, optional in ipairs(optional_encounters or {}) do
        local copy, optional_error =
            prepare_optional(optional, seen_ids)
        if optional_error then
            return response(false, optional_error)
        end

        local anchor_id = optional.InsertBeforeId
            or optional.InsertAfterId
        local anchor_index = find_index(
            result,
            anchor_id
        )
        if not anchor_index then
            return response(false, "UnknownInsertionAnchor")
        end

        if activation_matches(optional.Activation, state) then
            local insert_index = if optional.InsertBeforeId
                then anchor_index
                else anchor_index + 1
            table.insert(result, insert_index, copy)
        end
    end

    return response(true, nil, result)
end

-- Returns whether a kind is accepted by the generic runtime contract.
function DungeonEncounterPlan.is_supported_kind(
    kind: string
): boolean
    return VALID_KINDS[kind] == true
end

return table.freeze(DungeonEncounterPlan)
