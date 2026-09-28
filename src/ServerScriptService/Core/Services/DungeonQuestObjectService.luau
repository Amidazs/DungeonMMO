--!strict
-- Server-authoritative dungeon interactions for Adventure quest objectives.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local Definitions = require(
    Shared:WaitForChild("DungeonQuestObjectDefinitions")
)
local QuestDefinitions = require(
    Shared:WaitForChild("QuestDefinitions")
)
local InventoryService = require(
    script.Parent:WaitForChild("InventoryService")
)

local Service = {}
Service.__index = Service

local function result(ok: boolean, reason: string?, extra: any?): any
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

local function session_member(session: any, user_id: number): any?
    if type(session) ~= "table"
        or type(session.Members) ~= "table"
    then
        return nil
    end
    return session.Members[tostring(user_id)]
end

local function active_member(session: any, user_id: number): boolean
    local member = session_member(session, user_id)
    return type(member) == "table"
        and member.Connected == true
        and member.Mode == "Active"
        and member.Abandoned ~= true
end

local function session_matches(session: any, definition: any): boolean
    local difficulty_id = session
        and session.Difficulty
        and session.Difficulty.Id

    return type(session) == "table"
        and session.State == "Active"
        and session.DungeonId == definition.DungeonId
        and difficulty_id == definition.DifficultyId
end

local function prerequisite_met(session: any, definition: any): boolean
    local prerequisite = definition.PrerequisiteEncounterId
    if type(prerequisite) ~= "string" or prerequisite == "" then
        return true
    end

    local state = session
        and session.InstanceState
        and session.InstanceState.EncounterRuntime
    local encounter_states = state and state.EncounterStates

    return type(encounter_states) == "table"
        and encounter_states[prerequisite] == "Cleared"
end

local function valid_distance(distance: number, maximum: number): boolean
    return type(distance) == "number"
        and distance == distance
        and distance >= 0
        and distance <= maximum
end

local function matching_active_objective(
    quests: any,
    user_id: number,
    event_type: string,
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
                if objective.Type == event_type
                    and objective.TargetId == target_id
                then
                    return true
                end
            end
        end
    end

    return false
end

local function matching_members(
    quests: any,
    session: any,
    event_type: string,
    target_id: string
): {number}
    local recipients = {}

    for _, user_id in ipairs(session.MemberUserIds or {}) do
        if active_member(session, user_id)
            and matching_active_objective(
                quests,
                user_id,
                event_type,
                target_id
            )
        then
            table.insert(recipients, user_id)
        end
    end

    return recipients
end

local function record_for_members(
    quests: any,
    recipients: {number},
    event_id: string,
    event_type: string,
    target_id: string
): any
    for _, user_id in ipairs(recipients) do
        local recorded = quests:record_event(user_id, {
            EventId = event_id,
            Type = event_type,
            TargetId = target_id,
            Amount = 1,
        })
        if not recorded or recorded.ok ~= true then
            return result(
                false,
                recorded and recorded.reason
                    or "QuestProgressFailed"
            )
        end
    end

    return result(true)
end

--[[
Creates trusted dungeon quest-object authority.

Args:
    sessions (any): Authoritative DungeonSessionService.
    profiles (any): Authoritative ProfileService.
    quests (any): Authoritative QuestService.

Returns:
    any: Dungeon quest-object service.
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
Activates one server-defined dungeon mechanism for the whole run.

Args:
    session_id (string): Active server-owned dungeon session.
    user_id (number): Server-resolved interacting player.
    interaction_id (string): Known trusted interaction identifier.
    distance (number): Server-computed distance to mechanism bounds.

Returns:
    any: Activation and replay state.
]]
function Service:activate(
    session_id: string,
    user_id: number,
    interaction_id: string,
    distance: number
): any
    local definition = Definitions.interaction(interaction_id)
    if not definition then
        return result(false, "UnknownQuestInteraction")
    end
    if not valid_distance(distance, definition.MaxDistance) then
        return result(false, "QuestInteractionOutOfRange")
    end

    local session = self._sessions:get(session_id)
    if not session_matches(session, definition)
        or not active_member(session, user_id)
        or not prerequisite_met(session, definition)
    then
        return result(false, "QuestInteractionUnavailable")
    end

    local recipients = matching_members(
        self._quests,
        session,
        "WorldInteraction",
        definition.EventTargetId
    )
    if #recipients == 0 then
        return result(false, "QuestObjectiveNotActive")
    end

    local update = self._sessions:update_instance_state(
        session_id,
        function(state: any): (any, any?)
            state.QuestInteractions = state.QuestInteractions or {}
            local already = state.QuestInteractions[interaction_id] == true
            state.QuestInteractions[interaction_id] = true
            return state, {
                ok = true,
                already_activated = already,
            }
        end
    )
    if update.ok ~= true
        or type(update.value) ~= "table"
        or update.value.ok ~= true
    then
        return result(false, "QuestInteractionSaveFailed")
    end

    local recorded = record_for_members(
        self._quests,
        recipients,
        session_id .. ":WorldInteraction:" .. interaction_id,
        "WorldInteraction",
        definition.EventTargetId
    )
    if not recorded.ok then
        return recorded
    end

    return result(true, nil, {
        already_activated = update.value.already_activated == true,
        recipient_count = #recipients,
    })
end

--[[
Collects one personal quest item from an activated dungeon secret.

Args:
    session_id (string): Active server-owned dungeon session.
    user_id (number): Server-resolved collecting player.
    collectible_id (string): Known trusted collectible identifier.
    distance (number): Server-computed distance to collectible bounds.

Returns:
    any: Personal collection and replay state.
]]
function Service:collect(
    session_id: string,
    user_id: number,
    collectible_id: string,
    distance: number
): any
    local definition = Definitions.collectible(collectible_id)
    if not definition then
        return result(false, "UnknownQuestCollectible")
    end
    if not valid_distance(distance, definition.MaxDistance) then
        return result(false, "QuestCollectibleOutOfRange")
    end

    local session = self._sessions:get(session_id)
    if not session_matches(session, definition)
        or not active_member(session, user_id)
    then
        return result(false, "QuestCollectibleUnavailable")
    end

    local interactions = session.InstanceState
        and session.InstanceState.QuestInteractions
    if type(interactions) ~= "table"
        or interactions[definition.InteractionId] ~= true
    then
        return result(false, "QuestInteractionRequired")
    end

    if not matching_active_objective(
        self._quests,
        user_id,
        "ItemCollected",
        definition.EventTargetId
    ) then
        return result(false, "QuestObjectiveNotActive")
    end

    local already_owned = false
    local mutation_ok, mutation_error = self._profiles:mutate(
        user_id,
        function(profile: any)
            local character = selected_character(profile)
            if not character then
                error("CharacterUnavailable")
            end

            already_owned = InventoryService.count_item(
                character,
                definition.ItemId
            ) >= 1

            if not already_owned then
                local granted = InventoryService.apply_item_to_character(
                    character,
                    definition.ItemId,
                    1
                )
                if not granted.ok then
                    error(granted.reason or "QuestItemGrantFailed")
                end
            end
        end
    )
    if not mutation_ok then
        return result(
            false,
            mutation_error or "QuestItemGrantFailed"
        )
    end

    local update = self._sessions:update_instance_state(
        session_id,
        function(state: any): (any, any?)
            state.QuestCollectibles = state.QuestCollectibles or {}
            local claims = state.QuestCollectibles[collectible_id]
            if type(claims) ~= "table" then
                claims = {}
                state.QuestCollectibles[collectible_id] = claims
            end
            local key = tostring(user_id)
            local already = claims[key] == true
            claims[key] = true
            return state, {
                ok = true,
                already_collected = already,
            }
        end
    )
    if update.ok ~= true
        or type(update.value) ~= "table"
        or update.value.ok ~= true
    then
        return result(false, "QuestCollectibleSaveFailed")
    end

    local recorded = self._quests:record_event(user_id, {
        EventId = session_id
            .. ":ItemCollected:"
            .. collectible_id
            .. ":"
            .. tostring(user_id),
        Type = "ItemCollected",
        TargetId = definition.EventTargetId,
        Amount = 1,
    })
    if not recorded or recorded.ok ~= true then
        return result(
            false,
            recorded and recorded.reason
                or "QuestProgressFailed"
        )
    end

    return result(true, nil, {
        already_collected = update.value.already_collected == true
            or already_owned,
        item_id = definition.ItemId,
    })
end

return table.freeze(Service)
