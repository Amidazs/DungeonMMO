--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local ProfileSchema = require(Shared:WaitForChild("ProfileSchema"))
local QuestDefinitions = require(Shared:WaitForChild("QuestDefinitions"))
local InventoryService = require(script.Parent:WaitForChild("InventoryService"))
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

    if quests.TrackedQuestId ~= nil
        and type(quests.TrackedQuestId) ~= "string"
    then
        quests.TrackedQuestId = nil
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

--[[
Normalizes legacy and multi-item Adventure reward definitions.

Args:
    reward (any): Server-owned quest reward definition.

Returns:
    {any}: New dense array of item grants.
]]
local function reward_items(reward: any): {any}
    local items = {}

    if type(reward) ~= "table" then
        return items
    end

    if type(reward.Items) == "table" then
        for _, item in ipairs(reward.Items) do
            if type(item) == "table" then
                table.insert(items, {
                    ItemId = item.ItemId,
                    Quantity = item.Quantity,
                })
            end
        end
        return items
    end

    if type(reward.ItemId) == "string" then
        table.insert(items, {
            ItemId = reward.ItemId,
            Quantity = reward.Quantity,
        })
    end

    return items
end

--[[
Applies every quest item inside the caller's existing profile mutation.

Args:
    character (any): Selected live character being mutated.
    items ({any}): Normalized server-owned item grants.

Returns:
    nil: Raises when any grant is invalid so the mutation rolls back.
]]
local function apply_reward_items(
    character: any,
    items: {any}
)
    for _, item in ipairs(items) do
        local applied = InventoryService.apply_item_to_character(
            character,
            item.ItemId,
            item.Quantity
        )
        if not applied.ok then
            error(applied.reason or "QuestItemGrantFailed")
        end
    end
end

--[[
Returns normalized quest turn-in items.

Args:
    definition (any): Server-owned quest definition.

Returns:
    {any}: Dense turn-in item collection.
]]
local function turn_in_items(definition: any): {any}
    local items = {}
    if type(definition) ~= "table"
        or type(definition.TurnInItems) ~= "table"
    then
        return items
    end

    for _, item in ipairs(definition.TurnInItems) do
        if type(item) == "table"
            and type(item.ItemId) == "string"
        then
            table.insert(items, {
                ItemId = item.ItemId,
                Quantity = math.max(
                    1,
                    math.floor(tonumber(item.Quantity) or 1)
                ),
            })
        end
    end

    return items
end

--[[
Checks whether all required turn-in items are still owned.

Args:
    character (any): Selected character inventory owner.
    items ({any}): Normalized required turn-in items.

Returns:
    boolean: True only when every required quantity is present.
]]
local function has_turn_in_items(
    character: any,
    items: {any}
): boolean
    for _, item in ipairs(items) do
        if InventoryService.count_item(
            character,
            item.ItemId
        ) < item.Quantity then
            return false
        end
    end

    return true
end

--[[
Consumes every required turn-in item inside an existing profile mutation.

Args:
    character (any): Selected live character.
    items ({any}): Normalized required turn-in items.

Returns:
    nil: Raises if any required item cannot be consumed.
]]
local function consume_turn_in_items(
    character: any,
    items: {any}
)
    for _, item in ipairs(items) do
        local removed = InventoryService.apply_remove_from_character(
            character,
            item.ItemId,
            item.Quantity
        )
        if not removed.ok then
            error(removed.reason or "QuestTurnInItemMissing")
        end
    end
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
            live_quests.TrackedQuestId = quest_id
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

--[[
Sets the single Adventure quest selected for HUD tracking.

Args:
    user_id (number): Authenticated loaded character owner.
    quest_id (string): Active Adventure quest to track.

Returns:
    any: Success result with tracked quest id, or a fail-closed reason.
]]
function QuestService:set_tracked(
    user_id: number,
    quest_id: string
): any
    local definition = QuestDefinitions.get(quest_id)
    if not definition or definition.Kind ~= "Adventure" then
        return result(false, "QuestNotTrackable")
    end

    local character = self._profiles:get_character(user_id)
    if not character then
        return result(false, "ProfileNotLoaded")
    end

    local quests = ensure_state(character)
    if type(quests.Active[quest_id]) ~= "table" then
        return result(false, "QuestNotActive")
    end

    local mutation_ok, mutation_error = self._profiles:mutate(
        user_id,
        function(profile: any)
            local live_character = selected_character(profile)
            if not live_character then
                error("CharacterUnavailable")
            end

            local live_quests = ensure_state(live_character)
            if type(live_quests.Active[quest_id]) ~= "table" then
                error("QuestNotActive")
            end

            live_quests.TrackedQuestId = quest_id
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
        tracked_quest_id = quest_id,
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

-- Claims one story quest's server-defined reward as an atomic character
-- mutation. Class advancement quests remain owned by their class service.
--
-- Args:
--   user_id (number): Authenticated, loaded character owner.
--   quest_id (string): Known story quest identifier.
-- Returns:
--   any: Success and granted items/gold, or a fail-closed reason.
function QuestService:claim_reward(
    user_id: number,
    quest_id: string
): any
    local definition = QuestDefinitions.get(quest_id)
    if not definition or definition.Kind ~= "Adventure" then
        return result(false, "QuestRewardUnavailable")
    end

    local character = self._profiles:get_character(user_id)
    if not character then
        return result(false, "ProfileNotLoaded")
    end

    local quests = ensure_state(character)
    if quests.Completed[quest_id] == true then
        return result(false, "QuestAlreadyCompleted")
    end

    local state = quests.Active[quest_id]
    if not state then
        return result(false, "QuestNotActive")
    end
    if state.Ready ~= true or not state_is_ready(definition, state) then
        return result(false, "QuestNotReady")
    end

    local reward = definition.Reward
    local items = reward_items(reward)
    local required_items = turn_in_items(definition)
    local raw_gold = type(reward) == "table"
        and reward.Gold
        or nil
    local gold = tonumber(raw_gold) or 0

    if not has_turn_in_items(character, required_items) then
        return result(false, "QuestTurnInItemsMissing")
    end

    if gold ~= gold
        or gold < 0
        or gold >= math.huge
        or (
            raw_gold ~= nil
            and tonumber(raw_gold) == nil
        )
        or (
            gold <= 0
            and #items == 0
        )
    then
        return result(false, "QuestRewardUnavailable")
    end

    local mutated = self._profiles:mutate(user_id, function(profile: any)
        local live_character = selected_character(profile)
        if not live_character then
            error("CharacterUnavailable")
        end

        -- A second request cannot spend or complete the same quest twice.
        if not has_turn_in_items(
            live_character,
            required_items
        ) then
            error("QuestTurnInItemsMissing")
        end

        local completed, reason =
            QuestService.complete_ready_character_quest(
                live_character, quest_id
            )
        if not completed then
            error(reason or "QuestNotReady")
        end

        consume_turn_in_items(
            live_character,
            required_items
        )
        apply_reward_items(live_character, items)
        live_character.Gold += gold
    end)

    if not mutated then
        return result(false, "QuestRewardFailed")
    end
    local first_item = items[1]
    return result(true, nil, {
        quest_id = quest_id,
        gold_granted = gold,
        item_id = first_item and first_item.ItemId or nil,
        quantity = first_item and first_item.Quantity or nil,
        items_granted = ProfileSchema.deep_clone(items),
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
        TrackedQuestId = quests.TrackedQuestId,
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

    if quests.TrackedQuestId == quest_id then
        quests.TrackedQuestId = nil
    end

    return true, nil
end

return table.freeze(QuestService)
