--!strict
local DungeonEncounterSequencer = {}
DungeonEncounterSequencer.__index = DungeonEncounterSequencer

local VALID_STATES = table.freeze({
    Pending = true,
    Active = true,
    Cleared = true,
    Skipped = true,
})

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

local function copy_encounters(
    encounters: {any}
): ({any}, {[string]: number})
    local result = {}
    local index_by_id = {}

    for index, encounter in ipairs(encounters) do
        assert(
            type(encounter) == "table"
                and type(encounter.Id) == "string"
                and encounter.Id ~= "",
            "Sequencer requires stable encounter IDs."
        )
        assert(
            index_by_id[encounter.Id] == nil,
            "Sequencer encounter IDs must be unique."
        )

        local copy = {}
        for key, value in pairs(encounter) do
            copy[key] = value
        end
        copy.CompletionRequired =
            encounter.CompletionRequired ~= false

        result[index] = copy
        index_by_id[copy.Id] = index
    end

    return result, index_by_id
end
local function default_states(
    encounters: {any}
): {[string]: string}
    local states = {}
    for _, encounter in ipairs(encounters) do
        states[encounter.Id] = "Pending"
    end
    return states
end

local function restore_states(
    encounters: {any},
    snapshot: any?
): {[string]: string}
    local states = default_states(encounters)
    if type(snapshot) ~= "table"
        or type(snapshot.EncounterStates) ~= "table"
    then
        return states
    end

    for _, encounter in ipairs(encounters) do
        local state =
            snapshot.EncounterStates[encounter.Id]
        if state == "Cleared" or state == "Skipped" then
            states[encounter.Id] = state
        end
    end

    return states
end

-- Creates a sequencer over a materialized encounter plan.
function DungeonEncounterSequencer.new(
    encounters: {any},
    snapshot: any?
): any
    assert(
        type(encounters) == "table" and #encounters > 0,
        "DungeonEncounterSequencer requires encounters."
    )

    local encounter_copy, index_by_id =
        copy_encounters(encounters)

    return setmetatable({
        _encounters = encounter_copy,
        _index_by_id = index_by_id,
        _states = restore_states(
            encounter_copy,
            snapshot
        ),
        _active_id = nil,
    }, DungeonEncounterSequencer)
end
local function resolved_state(state: string?): boolean
    return state == "Cleared" or state == "Skipped"
end

-- Returns the first unresolved encounter ID.
function DungeonEncounterSequencer:next_id(): string?
    for _, encounter in ipairs(self._encounters) do
        if not resolved_state(self._states[encounter.Id]) then
            return encounter.Id
        end
    end
    return nil
end

-- Returns the lifecycle state for one encounter.
function DungeonEncounterSequencer:state_of(
    encounter_id: string
): string?
    return self._states[encounter_id]
end

-- Starts exactly the next unresolved encounter.
function DungeonEncounterSequencer:start(
    encounter_id: string
): any
    if self._index_by_id[encounter_id] == nil then
        return operation(false, "UnknownEncounter")
    end

    if self._active_id ~= nil then
        if self._active_id == encounter_id then
            return operation(false, "EncounterAlreadyActive")
        end
        return operation(false, "AnotherEncounterActive")
    end

    local current_state = self._states[encounter_id]
    if current_state == "Cleared" then
        return operation(false, "EncounterAlreadyCleared")
    end
    if current_state == "Skipped" then
        return operation(false, "EncounterAlreadySkipped")
    end

    if self:next_id() ~= encounter_id then
        return operation(false, "EncounterOutOfOrder")
    end

    self._states[encounter_id] = "Active"
    self._active_id = encounter_id
    return operation(true, nil, {
        encounter_id = encounter_id,
    })
end
-- Clears the active encounter exactly once.
function DungeonEncounterSequencer:clear(
    encounter_id: string
): any
    local state = self._states[encounter_id]
    if state == nil then
        return operation(false, "UnknownEncounter")
    end

    if state == "Cleared" then
        return operation(true, nil, {
            already_cleared = true,
        })
    end

    if self._active_id ~= encounter_id
        or state ~= "Active"
    then
        return operation(false, "EncounterNotActive")
    end

    self._states[encounter_id] = "Cleared"
    self._active_id = nil

    return operation(true, nil, {
        already_cleared = false,
        next_encounter_id = self:next_id(),
        complete = self:is_complete(),
    })
end

-- Skips the next unresolved optional encounter.
function DungeonEncounterSequencer:skip(
    encounter_id: string
): any
    local index = self._index_by_id[encounter_id]
    if not index then
        return operation(false, "UnknownEncounter")
    end

    local encounter = self._encounters[index]
    if encounter.CompletionRequired == true then
        return operation(false, "EncounterRequired")
    end

    if self._active_id ~= nil then
        return operation(false, "AnotherEncounterActive")
    end

    if self:next_id() ~= encounter_id then
        return operation(false, "EncounterOutOfOrder")
    end

    if self._states[encounter_id] == "Skipped" then
        return operation(true, nil, {
            already_skipped = true,
        })
    end

    self._states[encounter_id] = "Skipped"
    return operation(true, nil, {
        already_skipped = false,
        next_encounter_id = self:next_id(),
    })
end
-- Returns true only after every required encounter is cleared.
function DungeonEncounterSequencer:is_complete(): boolean
    for _, encounter in ipairs(self._encounters) do
        if encounter.CompletionRequired == true
            and self._states[encounter.Id] ~= "Cleared"
        then
            return false
        end
    end
    return true
end

-- Returns a detached reconnect-safe lifecycle snapshot.
function DungeonEncounterSequencer:snapshot(): any
    local encounter_states = {}
    for _, encounter in ipairs(self._encounters) do
        local state = self._states[encounter.Id]
        if VALID_STATES[state] then
            encounter_states[encounter.Id] = state
        end
    end

    return {
        Version = 1,
        EncounterStates = encounter_states,
        ActiveEncounterId = self._active_id,
        NextEncounterId = self:next_id(),
    }
end

-- Returns a detached descriptor for one encounter.
function DungeonEncounterSequencer:get(
    encounter_id: string
): any?
    local index = self._index_by_id[encounter_id]
    if not index then
        return nil
    end

    local source = self._encounters[index]
    local result = {}
    for key, value in pairs(source) do
        result[key] = value
    end
    return result
end

return table.freeze(DungeonEncounterSequencer)
