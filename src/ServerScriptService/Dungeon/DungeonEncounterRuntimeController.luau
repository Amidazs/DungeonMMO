--!strict
local Dungeon = script.Parent

local DungeonEncounterPlan = require(
    Dungeon:WaitForChild("DungeonEncounterPlan")
)
local DungeonEncounterSequencer = require(
    Dungeon:WaitForChild("DungeonEncounterSequencer")
)
local DungeonEncounterRuntimeState = require(
    Dungeon:WaitForChild("DungeonEncounterRuntimeState")
)

local DungeonEncounterRuntimeController = {}
DungeonEncounterRuntimeController.__index =
    DungeonEncounterRuntimeController

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
local function resolve_plan(
    session_service: any,
    session: any,
    base_sequence: {any},
    optional_encounters: {any}?
): ({any}?, string?)
    local persisted =
        DungeonEncounterRuntimeState.plan_from_session(session)
    if persisted then
        return persisted, nil
    end

    local instance_state = if type(session.InstanceState) == "table"
        then session.InstanceState
        else {}
    local materialized = DungeonEncounterPlan.materialize(
        base_sequence,
        optional_encounters,
        instance_state
    )
    if materialized.ok ~= true then
        return nil, materialized.reason or "EncounterPlanFailed"
    end

    local persisted_result =
        DungeonEncounterRuntimeState.persist_plan(
            session_service,
            session.SessionId,
            materialized.encounters
        )
    if persisted_result.ok ~= true then
        return nil, persisted_result.reason
            or "EncounterPlanPersistenceFailed"
    end

    return materialized.encounters, nil
end

-- Creates the authoritative encounter runtime for one Dungeon session.
function DungeonEncounterRuntimeController.new(
    options: any
): (any?, string?)
    assert(
        type(options) == "table",
        "DungeonEncounterRuntimeController options are required."
    )
    assert(
        options.session_service ~= nil,
        "DungeonEncounterRuntimeController requires session_service."
    )
    assert(
        type(options.session_id) == "string"
            and options.session_id ~= "",
        "DungeonEncounterRuntimeController requires session_id."
    )
    local session =
        options.session_service:get(options.session_id)
    if not session then
        return nil, "SessionNotFound"
    end

    local encounters, plan_error = resolve_plan(
        options.session_service,
        session,
        options.base_sequence,
        options.optional_encounters
    )
    if not encounters then
        return nil, plan_error
    end

    local refreshed =
        options.session_service:get(options.session_id)
    local snapshot =
        DungeonEncounterRuntimeState.from_session(
            refreshed or session
        )

    local self = setmetatable({
        _sessions = options.session_service,
        _session_id = options.session_id,
        _encounters = clone_table(encounters),
        _sequencer = DungeonEncounterSequencer.new(
            encounters,
            snapshot
        ),
    }, DungeonEncounterRuntimeController)

    return self, nil
end

function DungeonEncounterRuntimeController:_persist(): any
    local persisted = DungeonEncounterRuntimeState.persist(
        self._sessions,
        self._session_id,
        self._sequencer:snapshot()
    )
    if persisted.ok ~= true then
        return operation(
            false,
            persisted.reason or "EncounterRuntimePersistenceFailed"
        )
    end
    return operation(true, nil)
end
-- Returns a detached copy of the immutable materialized run plan.
function DungeonEncounterRuntimeController:encounters(): {any}
    return clone_table(self._encounters)
end

-- Finds one materialized encounter by stable room-slot ID.
function DungeonEncounterRuntimeController:find_by_room_slot(
    room_slot_id: string
): any?
    for _, encounter in ipairs(self._encounters) do
        if encounter.RoomSlotId == room_slot_id then
            return clone_table(encounter)
        end
    end
    return nil
end

-- Returns one encounter descriptor by stable encounter ID.
function DungeonEncounterRuntimeController:get(
    encounter_id: string
): any?
    return self._sequencer:get(encounter_id)
end

-- Returns one encounter lifecycle state.
function DungeonEncounterRuntimeController:state_of(
    encounter_id: string
): string?
    return self._sequencer:state_of(encounter_id)
end

-- Returns the next unresolved encounter ID.
function DungeonEncounterRuntimeController:next_id(): string?
    return self._sequencer:next_id()
end

-- Returns whether every required encounter has cleared.
function DungeonEncounterRuntimeController:is_complete(): boolean
    return self._sequencer:is_complete()
end
-- Starts the next encounter and persists its active identity.
function DungeonEncounterRuntimeController:start(
    encounter_id: string
): any
    local started = self._sequencer:start(encounter_id)
    if started.ok ~= true then
        return started
    end

    local persisted = self:_persist()
    if persisted.ok ~= true then
        return persisted
    end
    return started
end

-- Clears one active encounter and persists progression.
function DungeonEncounterRuntimeController:clear(
    encounter_id: string
): any
    local cleared = self._sequencer:clear(encounter_id)
    if cleared.ok ~= true then
        return cleared
    end

    local persisted = self:_persist()
    if persisted.ok ~= true then
        return persisted
    end
    return cleared
end

-- Skips one optional encounter and persists progression.
function DungeonEncounterRuntimeController:skip(
    encounter_id: string
): any
    local skipped = self._sequencer:skip(encounter_id)
    if skipped.ok ~= true then
        return skipped
    end

    local persisted = self:_persist()
    if persisted.ok ~= true then
        return persisted
    end
    return skipped
end

-- Returns the reconnect-safe lifecycle snapshot.
function DungeonEncounterRuntimeController:snapshot(): any
    return self._sequencer:snapshot()
end

return table.freeze(DungeonEncounterRuntimeController)
