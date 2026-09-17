--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileSchema = require(
    ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared"):WaitForChild("ProfileSchema")
)

local EconomyAuditService = {}
EconomyAuditService.__index = EconomyAuditService

local function finite(value: any): boolean
    return type(value) == "number"
        and value == value
        and value > -math.huge
        and value < math.huge
end

local function valid_id(value: any): boolean
    return type(value) == "string" and value ~= "" and #value <= 256
end

local function validate(event: any): string?
    if type(event) ~= "table" then return "InvalidAuditEvent" end
    if not valid_id(event.TransactionId) then return "InvalidTransactionId" end
    if not valid_id(event.Kind) then return "InvalidAuditKind" end
    if type(event.Reason) ~= "string" or event.Reason == "" then return "InvalidAuditReason" end
    for _, key in ipairs({"UserId", "GoldDelta", "GuildGoldDelta", "Timestamp"}) do
        local value = event[key]
        if value ~= nil and not finite(value) then return "InvalidAuditNumber" end
    end
    return nil
end

function EconomyAuditService.new(sink: ((any) -> ())?, clock: (() -> number)?): any
    return setmetatable({
        _sink = sink,
        _clock = clock or os.time,
        _seen = {},
        _events = {},
    }, EconomyAuditService)
end
function EconomyAuditService:record(event: any): any
    local invalid = validate(event)
    if invalid then return {ok = false, reason = invalid} end

    local key = event.TransactionId .. "|" .. event.Kind
    if self._seen[key] then
        return {ok = true, already_recorded = true}
    end

    local stored = ProfileSchema.deep_clone(event)
    stored.Timestamp = if finite(stored.Timestamp) then stored.Timestamp else self._clock()
    table.insert(self._events, stored)
    self._seen[key] = true

    if type(self._sink) == "function" then
        local ok, sink_error = pcall(self._sink, ProfileSchema.deep_clone(stored))
        if not ok then
            return {
                ok = false,
                reason = "AuditSinkFailed",
                detail = tostring(sink_error),
                recorded = true,
            }
        end
    end

    return {ok = true, already_recorded = false}
end

function EconomyAuditService:snapshot(): {any}
    return ProfileSchema.deep_clone(self._events)
end

function EconomyAuditService:count(): number
    return #self._events
end

return table.freeze(EconomyAuditService)
