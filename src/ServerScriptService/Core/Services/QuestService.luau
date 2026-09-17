--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local QuestDefinitions = require(Shared:WaitForChild("QuestDefinitions"))
local CharacterIdentityRules = require(
    Shared:WaitForChild("CharacterIdentityRules")
)

local QuestService = {}
QuestService.__index = QuestService

local function result(ok: boolean, reason: string?, extra: any?): any
    local out = extra or {}
    out.ok = ok
    out.reason = reason
    return out
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

local function ensure_state(character: any): any
    if type(character.Quests) ~= "table" then
        character.Quests = {}
    end

    local quests = character.Quests
    quests.Version = 1

    if type(quests.Active) ~= "table" then
        quests.Active = {}
    end

    if type(quests.Completed) ~= "table" then
        quests.Completed = {}
    end

    return quests
end

local function initial_state(definition: any): any
    local objectives = {}

    for _, objective in ipairs(definition.Objectives or {}) do
        objectives[objective.Id] = 0
    end

    return {
        Objectives = objectives,
        AppliedEvents = {},
        Ready = false,
    }
end

local function state_is_ready(definition: any, state: any): boolean
    if type(state) ~= "table" or type(state.Objectives) ~= "table" then
        return false
    end

    for _, objective in ipairs(definition.Objectives or {}) do
        local required = math.max(1, math.floor(tonumber(objective.Required) or 1))
        local current = math.max(
            0,
            math.floor(tonumber(state.Objectives[objective.Id]) or 0)
        )

        if current < required then
            return false
        end
    end

    return true
end

local function valid_event(event: any): boolean
    if type(event) ~= "table"
        or type(event.EventId) ~= "string"
        or event.EventId == ""
        or type(event.Type) ~= "string"
        or event.Type == ""
        or type(event.TargetId) ~= "string"
        or event.TargetId == ""
    then
        return false
    end

    local amount = tonumber(event.Amount)
    return amount ~= nil
        and amount == amount
        and amount > 0
        and amount < math.huge
end

function QuestService.new(profile_service: any): any
    assert(profile_service ~= nil, "QuestService requires ProfileService.")

    local self = setmetatable({}, QuestService)
    self._profiles = profile_service
    return self
end

function QuestService:start(user_id: number, quest_id: string): any
    local definition = QuestDefinitions.get(quest_id)
    if not definition then
        return result(false, "UnknownQuest")
    end

    local character = self._profiles:get_character(user_id)
    if not character then
        return result(false, "ProfileNotLoaded")
    end

    if not CharacterIdentityRules.is_complete(character) then
        return result(false, "IdentityIncomplete")
    end

    local quests = ensure_state(character)

    if quests.Completed[quest_id] == true then
        return result(false, "QuestAlreadyCompleted")
    end

    if type(quests.Active[quest_id]) == "table" then
        return result(false, "QuestAlreadyActive")
    end

    if not QuestDefinitions.is_character_eligible(character, definition) then
        return result(false, "QuestUnavailable")
    end

    local mutation_ok, mutation_error = self._profiles:mutate(
        user_id,
        function(profile: any)
            local live_character = selected_character(profile)
            if not live_character then
                error("CharacterUnavailable")
            end

            if not CharacterIdentityRules.is_complete(live_character)
                or not QuestDefinitions.is_character_eligible(
                    live_character,
                    definition
                )
            then
                error("QuestEligibilityChanged")
            end

            local live_quests = ensure_state(live_character)

            if live_quests.Completed[quest_id] == true
                or type(live_quests.Active[quest_id]) == "table"
            then
                error("QuestStateChanged")
            end

            live_quests.Active[quest_id] = initial_state(definition)
        end
    )

    if not mutation_ok then
        if mutation_error == "ProfileNotLoaded" then
            return result(false, "ProfileNotLoaded")
        end
        return result(false, "QuestMutationFailed")
    end

    return result(true, nil, {
        quest_id = quest_id,
    })
end

function QuestService:record_event(user_id: number, event: any): any
    if not valid_event(event) then
        return result(false, "InvalidQuestEvent")
    end

    local character = self._profiles:get_character(user_id)
    if not character then
        return result(false, "ProfileNotLoaded")
    end

    if not CharacterIdentityRules.is_complete(character) then
        return result(false, "IdentityIncomplete")
    end

    local progressed_quests = {}
    local ready_quests = {}
    local amount = math.max(1, math.floor(tonumber(event.Amount) or 1))

    local mutation_ok, mutation_error = self._profiles:mutate(
        user_id,
        function(profile: any)
            local live_character = selected_character(profile)
            if not live_character
                or not CharacterIdentityRules.is_complete(live_character)
            then
                error("IdentityChanged")
            end

            local quests = ensure_state(live_character)

            for quest_id, state in pairs(quests.Active) do
                local definition = QuestDefinitions.get(quest_id)

                if definition and type(state) == "table" then
                    if type(state.Objectives) ~= "table" then
                        state.Objectives = {}
                    end

                    if type(state.AppliedEvents) ~= "table" then
                        state.AppliedEvents = {}
                    end

                    if state.AppliedEvents[event.EventId] ~= true then
                        local matched = false

                        for _, objective in ipairs(definition.Objectives or {}) do
                            if QuestDefinitions.objective_matches(
                                objective,
                                event
                            ) then
                                local required = math.max(
                                    1,
                                    math.floor(
                                        tonumber(objective.Required) or 1
                                    )
                                )
                                local current = math.max(
                                    0,
                                    math.floor(
                                        tonumber(
                                            state.Objectives[objective.Id]
                                        ) or 0
                                    )
                                )

                                state.Objectives[objective.Id] = math.min(
                                    required,
                                    current + amount
                                )
                                matched = true
                            end
                        end

                        if matched then
                            state.AppliedEvents[event.EventId] = true
                            table.insert(progressed_quests, quest_id)

                            if state_is_ready(definition, state) then
                                state.Ready = true
                                table.insert(ready_quests, quest_id)
                            end
                        end
                    end
                end
            end
        end
    )

    if not mutation_ok then
        if mutation_error == "ProfileNotLoaded" then
            return result(false, "ProfileNotLoaded")
        end
        return result(false, "QuestMutationFailed")
    end

    return result(true, nil, {
        progressed_quests = progressed_quests,
        ready_quests = ready_quests,
    })
end

function QuestService:build_snapshot(user_id: number): any
    local character = self._profiles:get_character(user_id)
    if not character then
        return result(false, "ProfileNotLoaded", {
            Version = 1,
            Active = {},
            Completed = {},
        })
    end

    local quests = ensure_state(character)

    return result(true, nil, {
        Version = quests.Version,
        Active = ProfileSchema.deep_clone(quests.Active),
        Completed = ProfileSchema.deep_clone(quests.Completed),
    })
end

function QuestService.character_state(
    character: any,
    quest_id: string
): any?
    if type(character) ~= "table"
        or type(character.Quests) ~= "table"
        or type(character.Quests.Active) ~= "table"
    then
        return nil
    end

    return character.Quests.Active[quest_id]
end

function QuestService.complete_ready_character_quest(
    character: any,
    quest_id: string
): (boolean, string?)
    if type(character) ~= "table" then
        return false, "QuestNotActive"
    end

    local quests = ensure_state(character)

    if quests.Completed[quest_id] == true then
        return false, "QuestAlreadyCompleted"
    end

    local state = quests.Active[quest_id]
    if type(state) ~= "table" then
        return false, "QuestNotActive"
    end

    local definition = QuestDefinitions.get(quest_id)
    if not definition or state.Ready ~= true
        or not state_is_ready(definition, state)
    then
        return false, "QuestNotReady"
    end

    quests.Active[quest_id] = nil
    quests.Completed[quest_id] = true

    return true, nil
end

return table.freeze(QuestService)
