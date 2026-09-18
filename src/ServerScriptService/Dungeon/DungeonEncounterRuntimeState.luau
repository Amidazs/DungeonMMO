--!strict
local DungeonEncounterRuntimeState = {}

local CHECKPOINT_PREFIX = "EncounterStart:"

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

-- Returns the stable checkpoint ID for one encounter start.
function DungeonEncounterRuntimeState.checkpoint_id(
    encounter_id: string
): string
    assert(
        type(encounter_id) == "string"
            and encounter_id ~= "",
        "Encounter checkpoint requires encounter ID."
    )
    return CHECKPOINT_PREFIX .. encounter_id
end

-- Returns the monotonic checkpoint sequence in a materialized encounter plan.
function DungeonEncounterRuntimeState.checkpoint_sequence(
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

-- Persists the immutable materialized encounter plan exactly once.
function DungeonEncounterRuntimeState.persist_plan(
    session_service: any,
    session_id: string,
    encounters: {any}
): any
    if type(encounters) ~= "table" or #encounters == 0 then
        return {
            ok = false,
            reason = "InvalidEncounterPlan",
        }
    end

    return session_service:update_instance_state(
        session_id,
        function(instance_state: any): (any, any?)
            local updated = if type(instance_state) == "table"
                then instance_state
                else {}

            if type(updated.EncounterPlan) == "table" then
                return updated, "EncounterPlanAlreadySet"
            end

            updated.EncounterPlan = clone_table(encounters)
            return updated, nil
        end
    )
end

-- Returns a detached immutable materialized encounter plan when present.
function DungeonEncounterRuntimeState.plan_from_session(
    session: any
): {any}?
    if type(session) ~= "table"
        or type(session.InstanceState) ~= "table"
        or type(session.InstanceState.EncounterPlan) ~= "table"
    then
        return nil
    end

    return clone_table(session.InstanceState.EncounterPlan)
end

-- Persists encounter runtime state without replacing authored instance state.
function DungeonEncounterRuntimeState.persist(
    session_service: any,
    session_id: string,
    snapshot: any
): any
    if type(snapshot) ~= "table" then
        return {
            ok = false,
            reason = "InvalidEncounterRuntimeSnapshot",
        }
    end

    return session_service:update_instance_state(
        session_id,
        function(instance_state: any): (any, any?)
            local updated = if type(instance_state) == "table"
                then instance_state
                else {}
            updated.EncounterRuntime = clone_table(snapshot)
            return updated, nil
        end
    )
end

-- Returns a detached persisted encounter-runtime snapshot for one session.
function DungeonEncounterRuntimeState.from_session(
    session: any
): any?
    if type(session) ~= "table"
        or type(session.InstanceState) ~= "table"
        or type(session.InstanceState.EncounterRuntime) ~= "table"
    then
        return nil
    end

    return clone_table(
        session.InstanceState.EncounterRuntime
    )
end

return table.freeze(DungeonEncounterRuntimeState)
