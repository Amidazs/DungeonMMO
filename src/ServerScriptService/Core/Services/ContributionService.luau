--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local DefaultConfig = require(Shared:WaitForChild("ContributionConfig"))

local ContributionService = {}
ContributionService.__index = ContributionService


local BREAKDOWN_KEYS = {
    "DamageDealt",
    "DamageMitigated",
    "AggroHeld",
    "EffectiveHealing",
    "EffectiveWard",
    "UtilitySupport",
}

local function result(ok: boolean, reason: string?, extra: any?): any
    local out = extra or {}
    out.ok = ok
    out.reason = reason
    return out
end

local function deep_clone(value: any): any
    if type(value) ~= "table" then
        return value
    end

    local cloned = {}

    for key, child in pairs(value) do
        cloned[deep_clone(key)] = deep_clone(child)
    end

    return cloned
end

local function unwrap_session(value: any): any?
    if type(value) ~= "table" then
        return nil
    end

    if type(value.session) == "table" then
        return value.session
    end

    if type(value.SessionId) == "string" then
        return value
    end

    return nil
end

local function member_exists(session: any, user_id: number): boolean
    if type(session) ~= "table" then
        return false
    end

    if type(session.Members) == "table"
        and session.Members[tostring(user_id)] ~= nil
    then
        return true
    end

    if type(session.MemberUserIds) == "table" then
        for _, candidate in ipairs(session.MemberUserIds) do
            if candidate == user_id then
                return true
            end
        end
    end

    return false
end

local function valid_positive_finite(value: any): boolean
    if type(value) ~= "number"
        or value ~= value
        or value <= 0
        or math.abs(value) == math.huge
    then
        return false
    end

    return true
end

local function validate_event_shape(event: any): boolean
    return type(event) == "table"
        and type(event.EventId) == "string"
        and event.EventId ~= ""
        and type(event.SessionId) == "string"
        and event.SessionId ~= ""
        and type(event.UserId) == "number"
        and event.UserId > 0
        and event.UserId % 1 == 0
        and type(event.Type) == "string"
        and event.Type ~= ""
        and valid_positive_finite(event.Amount)
end

local function empty_player_state(): any
    local breakdown = {}

    for _, key in ipairs(BREAKDOWN_KEYS) do
        breakdown[key] = 0
    end

    return {
        Damage = 0,
        Tank = 0,
        Support = 0,
        Events = {},
        Breakdown = breakdown,
    }
end

local function normalize_contribution(instance_state: any): any
    if type(instance_state.Contribution) ~= "table" then
        instance_state.Contribution = {}
    end

    local contribution = instance_state.Contribution
    contribution.Version = 1

    if type(contribution.Players) ~= "table" then
        contribution.Players = {}
    end

    return contribution
end

local function normalize_player(contribution: any, user_id: number): any
    local key = tostring(user_id)

    if type(contribution.Players[key]) ~= "table" then
        contribution.Players[key] = empty_player_state()
    end

    local player_state = contribution.Players[key]

    player_state.Damage = tonumber(player_state.Damage) or 0
    player_state.Tank = tonumber(player_state.Tank) or 0
    player_state.Support = tonumber(player_state.Support) or 0

    if type(player_state.Events) ~= "table" then
        player_state.Events = {}
    end

    if type(player_state.Breakdown) ~= "table" then
        player_state.Breakdown = {}
    end

    for _, breakdown_key in ipairs(BREAKDOWN_KEYS) do
        player_state.Breakdown[breakdown_key] =
            tonumber(player_state.Breakdown[breakdown_key]) or 0
    end

    return player_state
end

local function public_player_snapshot(player_state: any): any
    return {
        Damage = tonumber(player_state.Damage) or 0,
        Tank = tonumber(player_state.Tank) or 0,
        Support = tonumber(player_state.Support) or 0,
        Breakdown = deep_clone(player_state.Breakdown or {}),
    }
end

function ContributionService.new(
    session_service: any,
    config: any?
): any
    assert(session_service ~= nil, "ContributionService requires DungeonSessionService.")

    local self = setmetatable({}, ContributionService)
    self._sessions = session_service
    self._config = config or DefaultConfig
    return self
end

function ContributionService:record_for_user(
    user_id: number,
    event: any
): any
    if type(user_id) ~= "number"
        or user_id <= 0
        or user_id % 1 ~= 0
        or type(event) ~= "table"
    then
        return result(false, "InvalidContributionEvent")
    end

    local session_result = self._sessions:get_for_user(user_id)
    local session = unwrap_session(session_result)

    if not session then
        return result(false, "UnknownSession")
    end

    local session_id = session.SessionId
    if type(session_id) ~= "string" or session_id == "" then
        return result(false, "UnknownSession")
    end

    local normalized = deep_clone(event)
    normalized.SessionId = session_id
    normalized.UserId = user_id

    return self:record(normalized)
end

function ContributionService:record(event: any): any
    if not validate_event_shape(event) then
        return result(false, "InvalidContributionEvent")
    end

    local event_definition = self._config.EventTypes[event.Type]
    if type(event_definition) ~= "table" then
        return result(false, "UnknownContributionType")
    end

    local session_result = self._sessions:get(event.SessionId)
    local session = unwrap_session(session_result)

    if not session then
        return result(false, "UnknownSession")
    end

    if session.State ~= "Active" then
        return result(false, "InactiveSession")
    end

    if not member_exists(session, event.UserId) then
        return result(false, "UserNotInSession")
    end

    local instance_state = deep_clone(session.InstanceState or {})
    local contribution = normalize_contribution(instance_state)
    local player_state = normalize_player(contribution, event.UserId)

    if player_state.Events[event.EventId] == true then
        return result(true, nil, {
            already_applied = true,
            snapshot = public_player_snapshot(player_state),
        })
    end

    local channel = event_definition.Channel
    local breakdown = event_definition.Breakdown
    local weight = tonumber(event_definition.Weight) or 1

    if (channel ~= "Damage" and channel ~= "Tank" and channel ~= "Support")
        or type(breakdown) ~= "string"
        or breakdown == ""
        or not valid_positive_finite(weight)
    then
        return result(false, "UnknownContributionType")
    end

    local amount = event.Amount
    player_state.Breakdown[breakdown] =
        (tonumber(player_state.Breakdown[breakdown]) or 0) + amount
    player_state[channel] =
        (tonumber(player_state[channel]) or 0) + (amount * weight)
    player_state.Events[event.EventId] = true

    local persisted = self._sessions:set_instance_state(
        event.SessionId,
        instance_state
    )

    if type(persisted) ~= "table" or persisted.ok ~= true then
        return result(false, "ContributionPersistenceFailed")
    end

    return result(true, nil, {
        already_applied = false,
        snapshot = public_player_snapshot(player_state),
    })
end

function ContributionService:get_player_snapshot(
    session_id: string,
    user_id: number
): any
    local session = unwrap_session(self._sessions:get(session_id))

    if not session then
        return result(false, "UnknownSession")
    end

    if not member_exists(session, user_id) then
        return result(false, "UserNotInSession")
    end

    local instance_state = deep_clone(session.InstanceState or {})
    local contribution = normalize_contribution(instance_state)
    local player_state = normalize_player(contribution, user_id)

    return result(true, nil, public_player_snapshot(player_state))
end

function ContributionService:get_session_snapshot(
    session_id: string
): any
    local session = unwrap_session(self._sessions:get(session_id))

    if not session then
        return result(false, "UnknownSession")
    end

    local instance_state = deep_clone(session.InstanceState or {})
    local contribution = normalize_contribution(instance_state)
    local players = {}
    local ordered_user_ids = {}

    for user_id_text, player_state in pairs(contribution.Players) do
        local user_id = tonumber(user_id_text)

        if user_id
            and user_id > 0
            and type(player_state) == "table"
        then
            players[tostring(user_id)] =
                public_player_snapshot(player_state)
            table.insert(ordered_user_ids, user_id)
        end
    end

    table.sort(ordered_user_ids)

    return result(true, nil, {
        Version = contribution.Version,
        Players = players,
        OrderedUserIds = ordered_user_ids,
    })
end

function ContributionService:reset_for_test(session_id: string): any
    local session = unwrap_session(self._sessions:get(session_id))

    if not session then
        return result(false, "UnknownSession")
    end

    local instance_state = deep_clone(session.InstanceState or {})
    instance_state.Contribution = nil

    local persisted = self._sessions:set_instance_state(
        session_id,
        instance_state
    )

    if type(persisted) ~= "table" or persisted.ok ~= true then
        return result(false, "ContributionPersistenceFailed")
    end

    return result(true, nil)
end

return table.freeze(ContributionService)
