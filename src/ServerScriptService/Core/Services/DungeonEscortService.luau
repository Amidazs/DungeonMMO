--!strict
-- Server-owned dungeon escort lifecycle and quest completion authority.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Definitions = require(
    Shared:WaitForChild("DungeonEscortDefinitions")
)
local QuestDefinitions = require(
    Shared:WaitForChild("QuestDefinitions")
)

local Service = {}
Service.__index = Service

local VALID_PHASES = table.freeze({
    ToRoom2 = true,
    WaitingForRoom2 = true,
    ToFinish = true,
    Completed = true,
})

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

local function active_member(
    session: any,
    user_id: number
): boolean
    local member = session
        and session.Members
        and session.Members[tostring(user_id)]

    return type(member) == "table"
        and member.Connected == true
        and member.Mode == "Active"
        and member.Abandoned ~= true
end

local function session_matches(
    session: any,
    definition: any
): boolean
    local difficulty_id = session
        and session.Difficulty
        and session.Difficulty.Id

    return type(session) == "table"
        and session.State == "Active"
        and session.DungeonId == definition.DungeonId
        and difficulty_id == definition.DifficultyId
end

local function encounter_cleared(
    session: any,
    encounter_id: string
): boolean
    local runtime = session
        and session.InstanceState
        and session.InstanceState.EncounterRuntime
    local states = runtime and runtime.EncounterStates

    return type(states) == "table"
        and states[encounter_id] == "Cleared"
end

local function escort_state(
    session: any,
    escort_id: string
): any?
    local states = session
        and session.InstanceState
        and session.InstanceState.EscortStates

    return type(states) == "table"
        and states[escort_id]
        or nil
end

local function objective_active(
    quests: any,
    user_id: number,
    target_id: string
): boolean
    local snapshot = quests:build_snapshot(user_id)
    if not snapshot or snapshot.ok ~= true
        or type(snapshot.Active) ~= "table"
    then
        return false
    end

    for quest_id in pairs(snapshot.Active) do
        local definition = QuestDefinitions.get(quest_id)
        if definition then
            for _, objective in ipairs(definition.Objectives or {}) do
                if objective.Type == "EscortCompleted"
                    and objective.TargetId == target_id
                then
                    return true
                end
            end
        end
    end

    return false
end

local function objective_recipients(
    quests: any,
    session: any,
    target_id: string
): {number}
    local recipients = {}

    for _, user_id in ipairs(session.MemberUserIds or {}) do
        if active_member(session, user_id)
            and objective_active(quests, user_id, target_id)
        then
            table.insert(recipients, user_id)
        end
    end

    return recipients
end

local function record_completion(
    quests: any,
    recipients: {number},
    event_id: string,
    target_id: string
): any
    for _, user_id in ipairs(recipients) do
        local recorded = quests:record_event(user_id, {
            EventId = event_id,
            Type = "EscortCompleted",
            TargetId = target_id,
            Amount = 1,
        })
        if not recorded or recorded.ok ~= true then
            return result(
                false,
                recorded and recorded.reason
                    or "EscortQuestProgressFailed"
            )
        end
    end

    return result(true)
end

--[[
Creates server-owned escort authority.

Args:
    sessions (any): Authoritative DungeonSessionService.
    quests (any): Authoritative QuestService.

Returns:
    any: Escort lifecycle service.
]]
function Service.new(
    sessions: any,
    quests: any
): any
    assert(sessions and quests)
    return setmetatable({
        _sessions = sessions,
        _quests = quests,
    }, Service)
end

--[[
Starts one escort from a genuine in-dungeon prompt.

Args:
    session_id (string): Active dungeon session.
    user_id (number): Server-resolved interacting party member.
    escort_id (string): Known escort definition.
    distance (number): Server-computed distance to the escort NPC.

Returns:
    any: Start state and whether the escort was already running.
]]
function Service:start(
    session_id: string,
    user_id: number,
    escort_id: string,
    distance: number
): any
    local definition = Definitions.get(escort_id)
    if not definition then
        return result(false, "UnknownEscort")
    end

    if type(distance) ~= "number"
        or distance < 0
        or distance > definition.MaxStartDistance
    then
        return result(false, "EscortStartOutOfRange")
    end

    local session = self._sessions:get(session_id)
    if not session_matches(session, definition)
        or not active_member(session, user_id)
    then
        return result(false, "EscortUnavailable")
    end

    if not encounter_cleared(
        session,
        definition.StartAfterEncounterId
    ) then
        return result(false, "EscortStartEncounterIncomplete")
    end

    local recipients = objective_recipients(
        self._quests,
        session,
        definition.EventTargetId
    )
    if #recipients == 0 then
        return result(false, "EscortObjectiveNotActive")
    end

    local update = self._sessions:update_instance_state(
        session_id,
        function(state: any): (any, any?)
            state.EscortStates = state.EscortStates or {}
            local existing = state.EscortStates[escort_id]
            local already_started = type(existing) == "table"
                and existing.Started == true

            if not already_started then
                state.EscortStates[escort_id] = {
                    Started = true,
                    Completed = false,
                    Phase = "ToRoom2",
                    StartedByUserId = user_id,
                }
            end

            return state, {
                ok = true,
                already_started = already_started,
            }
        end
    )

    if not update.ok or type(update.value) ~= "table" then
        return result(false, "EscortStateSaveFailed")
    end

    return result(true, nil, {
        already_started = update.value.already_started == true,
        recipient_count = #recipients,
    })
end

--[[
Persists one server-controlled escort movement phase.

Args:
    session_id (string): Active dungeon session.
    escort_id (string): Known escort definition.
    phase (string): Approved server movement phase.

Returns:
    any: Updated phase or reasoned rejection.
]]
function Service:set_phase(
    session_id: string,
    escort_id: string,
    phase: string
): any
    if VALID_PHASES[phase] ~= true or phase == "Completed" then
        return result(false, "InvalidEscortPhase")
    end

    local definition = Definitions.get(escort_id)
    local session = self._sessions:get(session_id)
    if not definition or not session_matches(session, definition) then
        return result(false, "EscortUnavailable")
    end

    local current = escort_state(session, escort_id)
    if type(current) ~= "table"
        or current.Started ~= true
        or current.Completed == true
    then
        return result(false, "EscortNotRunning")
    end

    local update = self._sessions:update_instance_state(
        session_id,
        function(state: any): (any, any?)
            local saved = state.EscortStates
                and state.EscortStates[escort_id]
            if type(saved) ~= "table"
                or saved.Started ~= true
                or saved.Completed == true
            then
                return state, {
                    ok = false,
                    reason = "EscortNotRunning",
                }
            end

            saved.Phase = phase
            return state, {
                ok = true,
                phase = phase,
            }
        end
    )

    if not update.ok
        or type(update.value) ~= "table"
        or update.value.ok ~= true
    then
        return result(
            false,
            update.value and update.value.reason
                or "EscortStateSaveFailed"
        )
    end

    return result(true, nil, {
        phase = phase,
    })
end

--[[
Returns the persisted escort lifecycle for reconnect recovery.

Args:
    session_id (string): Active dungeon session.
    escort_id (string): Known escort definition.

Returns:
    any: Detached current state or an unavailable reason.
]]
function Service:status(
    session_id: string,
    escort_id: string
): any
    local definition = Definitions.get(escort_id)
    local session = self._sessions:get(session_id)
    if not definition or not session_matches(session, definition) then
        return result(false, "EscortUnavailable")
    end

    local current = escort_state(session, escort_id)
    return result(true, nil, {
        started = type(current) == "table"
            and current.Started == true,
        completed = type(current) == "table"
            and current.Completed == true,
        phase = type(current) == "table"
            and current.Phase or nil,
    })
end

--[[
Completes one escort only after its destination encounter is safe.

Args:
    session_id (string): Active dungeon session.
    escort_id (string): Known escort definition.

Returns:
    any: Completion and replay state.
]]
function Service:complete(
    session_id: string,
    escort_id: string
): any
    local definition = Definitions.get(escort_id)
    local session = self._sessions:get(session_id)

    if not definition or not session_matches(session, definition) then
        return result(false, "EscortUnavailable")
    end

    local current = escort_state(session, escort_id)
    if type(current) ~= "table" or current.Started ~= true then
        return result(false, "EscortNotStarted")
    end

    if not encounter_cleared(
        session,
        definition.FinishAfterEncounterId
    ) then
        return result(false, "EscortFinishEncounterIncomplete")
    end

    local recipients = objective_recipients(
        self._quests,
        session,
        definition.EventTargetId
    )

    local update = self._sessions:update_instance_state(
        session_id,
        function(state: any): (any, any?)
            local saved = state.EscortStates
                and state.EscortStates[escort_id]
            if type(saved) ~= "table"
                or saved.Started ~= true
            then
                return state, {
                    ok = false,
                    reason = "EscortNotStarted",
                }
            end

            local already_completed = saved.Completed == true
            saved.Completed = true
            saved.Phase = "Completed"

            return state, {
                ok = true,
                already_completed = already_completed,
            }
        end
    )

    if not update.ok
        or type(update.value) ~= "table"
        or update.value.ok ~= true
    then
        return result(
            false,
            update.value and update.value.reason
                or "EscortStateSaveFailed"
        )
    end

    local recorded = record_completion(
        self._quests,
        recipients,
        session_id .. ":EscortCompleted:" .. escort_id,
        definition.EventTargetId
    )
    if not recorded.ok then
        return recorded
    end

    return result(true, nil, {
        already_completed = update.value.already_completed == true,
        recipient_count = #recipients,
    })
end

return table.freeze(Service)
