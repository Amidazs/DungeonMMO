--!strict
-- Server-owned ordered puzzle authority for dungeon Adventure objectives.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local PuzzleDefinitions = require(
    Shared:WaitForChild("DungeonPuzzleDefinitions")
)
local QuestDefinitions = require(
    Shared:WaitForChild("QuestDefinitions")
)
local InventoryService = require(
    script.Parent:WaitForChild("InventoryService")
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

local function selected_character(profile: any): any?
    if type(profile) ~= "table"
        or type(profile.Account) ~= "table"
        or type(profile.Characters) ~= "table"
    then
        return nil
    end

    local slot = profile.Account.SelectedCharacterSlot
    if type(slot) ~= "number" then
        return nil
    end

    return profile.Characters["Slot" .. tostring(slot)]
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

local function valid_distance(
    distance: number,
    maximum: number
): boolean
    return type(distance) == "number"
        and distance == distance
        and distance >= 0
        and distance <= maximum
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
                if objective.Type == "PuzzleCompleted"
                    and objective.TargetId == target_id
                then
                    return true
                end
            end
        end
    end

    return false
end

local function completion_recipients(
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

local function owns_required_item(
    profiles: any,
    user_id: number,
    item_id: string
): boolean
    local character = profiles:get_character(user_id)
    return character ~= nil
        and InventoryService.count_item(
            character,
            item_id
        ) >= 1
end

local function current_state(
    session: any,
    puzzle_id: string
): any?
    local states = session
        and session.InstanceState
        and session.InstanceState.PuzzleStates

    return type(states) == "table"
        and states[puzzle_id]
        or nil
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
            Type = "PuzzleCompleted",
            TargetId = target_id,
            Amount = 1,
        })
        if not recorded or recorded.ok ~= true then
            return result(
                false,
                recorded and recorded.reason
                    or "PuzzleQuestProgressFailed"
            )
        end
    end

    return result(true)
end

--[[
Creates server-owned ordered puzzle authority.

Args:
    sessions (any): Authoritative DungeonSessionService.
    profiles (any): Authoritative ProfileService.
    quests (any): Authoritative QuestService.

Returns:
    any: Ordered puzzle service.
]]
function Service.new(
    sessions: any,
    profiles: any,
    quests: any
): any
    assert(sessions and profiles and quests)

    return setmetatable({
        _sessions = sessions,
        _profiles = profiles,
        _quests = quests,
    }, Service)
end

--[[
Returns the persisted state for one puzzle.

Args:
    session_id (string): Active dungeon session.
    puzzle_id (string): Known ordered puzzle identifier.

Returns:
    any: Safe puzzle progress snapshot.
]]
function Service:status(
    session_id: string,
    puzzle_id: string
): any
    local definition = PuzzleDefinitions.get(puzzle_id)
    local session = self._sessions:get(session_id)

    if not definition or not session_matches(session, definition) then
        return result(false, "PuzzleUnavailable")
    end

    local state = current_state(session, puzzle_id)
    return result(true, nil, {
        completed = type(state) == "table"
            and state.Completed == true,
        next_index = type(state) == "table"
            and state.NextIndex or 1,
        reset_count = type(state) == "table"
            and state.ResetCount or 0,
    })
end

--[[
Validates a rune press against trusted session, quest and item state.

Args:
    session (any): Current authoritative dungeon session.
    user_id (number): Server-resolved interacting party member.
    definition (any): Server-owned puzzle definition.
    distance (number): Server-computed rune distance.

Returns:
    any: Validation result.
]]
local function validate_press(
    self: any,
    session: any,
    user_id: number,
    definition: any,
    distance: number
): any
    if not valid_distance(distance, definition.MaxDistance) then
        return result(false, "PuzzleRuneOutOfRange")
    end

    if not session_matches(session, definition)
        or not active_member(session, user_id)
    then
        return result(false, "PuzzleUnavailable")
    end

    if not encounter_cleared(
        session,
        definition.PrerequisiteEncounterId
    ) then
        return result(false, "PuzzlePrerequisiteIncomplete")
    end

    if not objective_active(
        self._quests,
        user_id,
        definition.EventTargetId
    ) then
        return result(false, "PuzzleObjectiveNotActive")
    end

    if not owns_required_item(
        self._profiles,
        user_id,
        definition.RequiredItemId
    ) then
        return result(false, "PuzzleQuestItemRequired")
    end

    return result(true)
end

--[[
Persists one ordered rune press.

Args:
    self (any): Puzzle service.
    session_id (string): Active dungeon session.
    definition (any): Server-owned puzzle definition.
    rune_id (string): Pressed stable rune identifier.

Returns:
    any: Updated puzzle state.
]]
local function persist_press(
    self: any,
    session_id: string,
    definition: any,
    rune_id: string
): any
    return self._sessions:update_instance_state(
        session_id,
        function(state: any): (any, any?)
            state.PuzzleStates = state.PuzzleStates or {}
            local saved = state.PuzzleStates[definition.Id]

            if type(saved) ~= "table" then
                saved = {
                    NextIndex = 1,
                    ResetCount = 0,
                    Completed = false,
                }
                state.PuzzleStates[definition.Id] = saved
            end

            if saved.Completed == true then
                return state, {
                    ok = true,
                    completed = true,
                    already_completed = true,
                }
            end

            local expected = definition.Sequence[saved.NextIndex]
            if rune_id ~= expected then
                saved.NextIndex = 1
                saved.ResetCount += 1
                return state, {
                    ok = true,
                    reset = true,
                    expected_rune_id = definition.Sequence[1],
                }
            end

            saved.NextIndex += 1
            if saved.NextIndex > #definition.Sequence then
                saved.Completed = true
                return state, {
                    ok = true,
                    completed = true,
                    already_completed = false,
                }
            end

            return state, {
                ok = true,
                completed = false,
                next_index = saved.NextIndex,
                expected_rune_id =
                    definition.Sequence[saved.NextIndex],
            }
        end
    )
end

--[[
Applies one server-verified ordered rune press.

Args:
    session_id (string): Active dungeon session.
    user_id (number): Server-resolved interacting party member.
    puzzle_id (string): Known ordered puzzle identifier.
    rune_id (string): Server-bound physical rune identifier.
    distance (number): Server-computed distance to the rune.

Returns:
    any: Progress, reset or completion result.
]]
function Service:press(
    session_id: string,
    user_id: number,
    puzzle_id: string,
    rune_id: string,
    distance: number
): any
    local definition = PuzzleDefinitions.get(puzzle_id)
    if not definition then
        return result(false, "UnknownPuzzle")
    end

    local session = self._sessions:get(session_id)
    local validated = validate_press(
        self,
        session,
        user_id,
        definition,
        distance
    )
    if not validated.ok then
        return validated
    end

    local updated = persist_press(
        self,
        session_id,
        definition,
        rune_id
    )
    if not updated.ok
        or type(updated.value) ~= "table"
        or updated.value.ok ~= true
    then
        return result(false, "PuzzleStateSaveFailed")
    end

    local value = updated.value
    if value.completed ~= true then
        return result(true, nil, value)
    end

    local latest = self._sessions:get(session_id)
    local recipients = completion_recipients(
        self._quests,
        latest,
        definition.EventTargetId
    )
    local recorded = record_completion(
        self._quests,
        recipients,
        session_id .. ":PuzzleCompleted:" .. puzzle_id,
        definition.EventTargetId
    )
    if not recorded.ok then
        return recorded
    end

    return result(true, nil, {
        completed = true,
        already_completed = value.already_completed == true,
        recipient_count = #recipients,
    })
end

return table.freeze(Service)
