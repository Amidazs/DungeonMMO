--!strict
-- Server-owned defend/survive lifecycle for dungeon Adventure objectives.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local DefenseDefinitions = require(
    Shared:WaitForChild("DungeonDefenseDefinitions")
)
local QuestDefinitions = require(
    Shared:WaitForChild("QuestDefinitions")
)

local Service = {}
Service.__index = Service

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

local function encounter_state(
    session: any,
    encounter_id: string
): string?
    local runtime = session
        and session.InstanceState
        and session.InstanceState.EncounterRuntime
    local states = runtime and runtime.EncounterStates
    local value = type(states) == "table"
        and states[encounter_id]
        or nil

    return if type(value) == "string" then value else nil
end

local function encounter_cleared(
    session: any,
    encounter_id: string
): boolean
    return encounter_state(session, encounter_id) == "Cleared"
end

local function valid_distance(
    distance: number,
    maximum: number
): boolean
    return type(distance) == "number"
        and distance == distance
        and distance >= 0
        and distance <= maximum
end

local function valid_delta(
    delta_seconds: number,
    maximum: number
): boolean
    return type(delta_seconds) == "number"
        and delta_seconds == delta_seconds
        and delta_seconds > 0
        and delta_seconds <= maximum
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
                if objective.Type == "DefenseCompleted"
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

local function defense_state(
    session: any,
    defense_id: string
): any?
    local states = session
        and session.InstanceState
        and session.InstanceState.DefenseStates

    return type(states) == "table"
        and states[defense_id]
        or nil
end

local function holder_count(
    session: any,
    holder_user_ids: {number}
): number
    local unique = {}
    local count = 0

    for _, user_id in ipairs(holder_user_ids) do
        if type(user_id) == "number"
            and unique[user_id] ~= true
            and active_member(session, user_id)
        then
            unique[user_id] = true
            count += 1
        end
    end

    return count
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
            Type = "DefenseCompleted",
            TargetId = target_id,
            Amount = 1,
        })
        if not recorded or recorded.ok ~= true then
            return result(
                false,
                recorded and recorded.reason
                    or "DefenseQuestProgressFailed"
            )
        end
    end

    return result(true)
end

--[[
Creates server-owned defense authority.

Args:
    sessions (any): Authoritative DungeonSessionService.
    quests (any): Authoritative QuestService.

Returns:
    any: Defense lifecycle service.
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
Returns persisted defense state for runtime recovery.

Args:
    session_id (string): Active dungeon session.
    defense_id (string): Known defense identifier.

Returns:
    any: Safe defense snapshot.
]]
function Service:status(
    session_id: string,
    defense_id: string
): any
    local definition = DefenseDefinitions.get(defense_id)
    local session = self._sessions:get(session_id)

    if not definition or not session_matches(session, definition) then
        return result(false, "DefenseUnavailable")
    end

    local state = defense_state(session, defense_id)
    return result(true, nil, {
        started = type(state) == "table"
            and state.Started == true,
        completed = type(state) == "table"
            and state.Completed == true,
        unheld_seconds = type(state) == "table"
            and state.UnheldSeconds or 0,
        held_seconds = type(state) == "table"
            and state.HeldSeconds or 0,
        failure_count = type(state) == "table"
            and state.FailureCount or 0,
    })
end

--[[
Starts or restarts one defense from a trusted physical prompt.

Args:
    session_id (string): Active dungeon session.
    user_id (number): Server-resolved interacting member.
    defense_id (string): Known defense identifier.
    distance (number): Server-computed prompt distance.

Returns:
    any: Start/restart result.
]]
function Service:start(
    session_id: string,
    user_id: number,
    defense_id: string,
    distance: number
): any
    local definition = DefenseDefinitions.get(defense_id)
    if not definition then
        return result(false, "UnknownDefense")
    end
    if not valid_distance(distance, definition.MaxStartDistance) then
        return result(false, "DefenseStartOutOfRange")
    end

    local session = self._sessions:get(session_id)
    if not session_matches(session, definition)
        or not active_member(session, user_id)
    then
        return result(false, "DefenseUnavailable")
    end
    if not encounter_cleared(
        session,
        definition.StartAfterEncounterId
    ) then
        return result(false, "DefenseStartEncounterIncomplete")
    end
    if encounter_cleared(
        session,
        definition.FinishEncounterId
    ) then
        return result(false, "DefenseEncounterAlreadyCleared")
    end
    if not objective_active(
        self._quests,
        user_id,
        definition.EventTargetId
    ) then
        return result(false, "DefenseObjectiveNotActive")
    end

    local update = self._sessions:update_instance_state(
        session_id,
        function(state: any): (any, any?)
            state.DefenseStates = state.DefenseStates or {}
            local saved = state.DefenseStates[defense_id]
            if type(saved) == "table"
                and saved.Completed == true
            then
                return state, {
                    ok = true,
                    already_completed = true,
                }
            end

            local failures = type(saved) == "table"
                and tonumber(saved.FailureCount)
                or 0
            state.DefenseStates[defense_id] = {
                Started = true,
                Completed = false,
                UnheldSeconds = 0,
                HeldSeconds = 0,
                FailureCount = failures or 0,
                StartedByUserId = user_id,
            }

            return state, {
                ok = true,
                already_completed = false,
            }
        end
    )

    if not update.ok
        or type(update.value) ~= "table"
        or update.value.ok ~= true
    then
        return result(false, "DefenseStateSaveFailed")
    end

    return result(true, nil, {
        already_completed =
            update.value.already_completed == true,
    })
end

local function update_tick_state(
    state: any,
    definition: any,
    defense_id: string,
    delta_seconds: number,
    holders: number
): any
    local saved = state.DefenseStates
        and state.DefenseStates[defense_id]

    if type(saved) ~= "table"
        or saved.Started ~= true
    then
        return {
            ok = false,
            reason = "DefenseNotRunning",
        }
    end
    if saved.Completed == true then
        return {
            ok = true,
            completed = true,
            already_completed = true,
        }
    end

    if holders > 0 then
        saved.UnheldSeconds = 0
        saved.HeldSeconds =
            (tonumber(saved.HeldSeconds) or 0)
            + delta_seconds
        return {
            ok = true,
            occupied = true,
        }
    end

    saved.UnheldSeconds =
        (tonumber(saved.UnheldSeconds) or 0)
        + delta_seconds

    if saved.UnheldSeconds > definition.GraceSeconds then
        saved.Started = false
        saved.UnheldSeconds = 0
        saved.HeldSeconds = 0
        saved.FailureCount =
            (tonumber(saved.FailureCount) or 0) + 1
        return {
            ok = true,
            reset = true,
        }
    end

    return {
        ok = true,
        occupied = false,
        grace_remaining = math.max(
            0,
            definition.GraceSeconds - saved.UnheldSeconds
        ),
    }
end

local function complete_if_ready(
    self: any,
    session_id: string,
    defense_id: string,
    definition: any
): any
    local session = self._sessions:get(session_id)
    if not encounter_cleared(
        session,
        definition.FinishEncounterId
    ) then
        return nil
    end

    local current = defense_state(session, defense_id)
    if type(current) ~= "table"
        or current.Started ~= true
        or current.Completed == true
    then
        return nil
    end

    local update = self._sessions:update_instance_state(
        session_id,
        function(state: any): (any, any?)
            local saved = state.DefenseStates
                and state.DefenseStates[defense_id]
            if type(saved) ~= "table"
                or saved.Started ~= true
            then
                return state, {
                    ok = false,
                    reason = "DefenseNotRunning",
                }
            end

            saved.Completed = true
            return state, {ok = true}
        end
    )
    if not update.ok
        or type(update.value) ~= "table"
        or update.value.ok ~= true
    then
        return result(false, "DefenseStateSaveFailed")
    end

    local latest = self._sessions:get(session_id)
    local recipients = objective_recipients(
        self._quests,
        latest,
        definition.EventTargetId
    )
    local recorded = record_completion(
        self._quests,
        recipients,
        session_id .. ":DefenseCompleted:" .. defense_id,
        definition.EventTargetId
    )
    if not recorded.ok then
        return recorded
    end

    return result(true, nil, {
        completed = true,
        recipient_count = #recipients,
    })
end

--[[
Advances one server-measured defense heartbeat.

Args:
    session_id (string): Active dungeon session.
    defense_id (string): Known defense identifier.
    delta_seconds (number): Bounded server heartbeat duration.
    holder_user_ids ({number}): Server-measured party members in the zone.

Returns:
    any: Occupancy, grace, reset or completion state.
]]
function Service:tick(
    session_id: string,
    defense_id: string,
    delta_seconds: number,
    holder_user_ids: {number}
): any
    local definition = DefenseDefinitions.get(defense_id)
    if not definition then
        return result(false, "UnknownDefense")
    end
    if not valid_delta(
        delta_seconds,
        definition.TickMaxSeconds
    ) then
        return result(false, "InvalidDefenseTick")
    end

    local session = self._sessions:get(session_id)
    if not session_matches(session, definition) then
        return result(false, "DefenseUnavailable")
    end

    local holders = holder_count(
        session,
        holder_user_ids or {}
    )
    local update = self._sessions:update_instance_state(
        session_id,
        function(state: any): (any, any?)
            local tick_result = update_tick_state(
                state,
                definition,
                defense_id,
                delta_seconds,
                holders
            )
            return state, tick_result
        end
    )
    if not update.ok or type(update.value) ~= "table" then
        return result(false, "DefenseStateSaveFailed")
    end
    if update.value.ok ~= true then
        return result(
            false,
            update.value.reason or "DefenseTickRejected"
        )
    end
    if update.value.reset == true then
        return result(true, nil, {
            reset = true,
        })
    end

    local completed = complete_if_ready(
        self,
        session_id,
        defense_id,
        definition
    )
    if completed then
        return completed
    end

    return result(true, nil, update.value)
end

return table.freeze(Service)
