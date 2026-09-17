--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local CharacterIdentityRules = require(
    Shared:WaitForChild("CharacterIdentityRules")
)
local TravelConfig = require(
    Shared:WaitForChild("TravelConfig")
)
local TravelDestinationDefinitions = require(
    Shared:WaitForChild("TravelDestinationDefinitions")
)

local TravelService = {}
TravelService.__index = TravelService

local function rejected(reason: string): any
    return {
        ok = false,
        reason = reason,
    }
end

local function now_or_clock(value: number?): number
    if type(value) == "number"
        and value == value
        and value > -math.huge
        and value < math.huge
    then
        return value
    end

    return os.clock()
end

local function selected_character(profile: any): any?
    if type(profile) ~= "table"
        or type(profile.Account) ~= "table"
        or type(profile.Characters) ~= "table"
    then
        return nil
    end

    local slot = math.floor(
        tonumber(profile.Account.SelectedCharacterSlot) or 1
    )
    return profile.Characters["Slot" .. tostring(slot)]
end

function TravelService.new(
    profile_service: any,
    context: string,
    options: any?
): any
    assert(
        profile_service ~= nil,
        "TravelService requires ProfileService"
    )

    return setmetatable({
        _profiles = profile_service,
        _context = context,
        _options = options or {},
        _cooldown_until = {},
    }, TravelService)
end

function TravelService:set_guards(options: any)
    self._options = options or {}
end

function TravelService:_profile_and_character(
    user_id: number
): (any?, any?, string?)
    if self._context ~= "Base" then
        return nil, nil, "BaseOnlyAction"
    end

    local profile = self._profiles:get_profile(user_id)
    if not profile then
        return nil, nil, "ProfileNotLoaded"
    end

    local character = selected_character(profile)
    if not character then
        return profile, nil, "ProfileNotLoaded"
    end

    if not CharacterIdentityRules.is_complete(character) then
        return profile, character, "IdentityIncomplete"
    end

    return profile, character, nil
end

function TravelService:_runtime_block_reason(
    user_id: number
): string?
    local pending = self._options.is_teleport_pending
    if type(pending) == "function"
        and pending(user_id) == true
    then
        return "TeleportPending"
    end

    local active = self._options.has_recoverable_session
    if type(active) == "function"
        and active(user_id) == true
    then
        return "ActiveDungeonSession"
    end

    return nil
end

function TravelService:remaining_cooldown(
    user_id: number,
    now: number?
): number
    local current = now_or_clock(now)
    local deadline = self._cooldown_until[user_id]

    if type(deadline) ~= "number" or deadline <= current then
        self._cooldown_until[user_id] = nil
        return 0
    end

    return math.max(0, deadline - current)
end

function TravelService:record_success(
    user_id: number,
    now: number?
)
    local current = now_or_clock(now)
    self._cooldown_until[user_id] =
        current + TravelConfig.COOLDOWN_SECONDS
end

function TravelService:clear_user(user_id: number)
    self._cooldown_until[user_id] = nil
end

function TravelService:validate_special_request(user_id: number, now: number?): any
    local _, _, profile_reason = self:_profile_and_character(user_id)
    if profile_reason then return rejected(profile_reason) end
    local runtime_reason = self:_runtime_block_reason(user_id)
    if runtime_reason then return rejected(runtime_reason) end
    local remaining = self:remaining_cooldown(user_id, now)
    if remaining > 0 then
        return {ok = false, reason = "TravelCooldown", CooldownRemaining = remaining}
    end
    return {ok = true}
end

function TravelService:validate_request(
    user_id: number,
    destination_id: any,
    now: number?
): any
    local _, _, profile_reason =
        self:_profile_and_character(user_id)

    if profile_reason then
        return rejected(profile_reason)
    end

    if type(destination_id) ~= "string" then
        return rejected("UnknownDestination")
    end

    local destination =
        TravelDestinationDefinitions.get(destination_id)

    if not destination then
        return rejected("UnknownDestination")
    end

    local runtime_reason =
        self:_runtime_block_reason(user_id)

    if runtime_reason then
        return rejected(runtime_reason)
    end

    local remaining =
        self:remaining_cooldown(user_id, now)

    if remaining > 0 then
        return {
            ok = false,
            reason = "TravelCooldown",
            CooldownRemaining = remaining,
        }
    end

    return {
        ok = true,
        destination = destination,
    }
end

function TravelService:build_snapshot(
    user_id: number,
    now: number?
): any
    local _, _, profile_reason =
        self:_profile_and_character(user_id)

    if profile_reason then
        return rejected(profile_reason)
    end

    local runtime_reason =
        self:_runtime_block_reason(user_id)
    local remaining =
        self:remaining_cooldown(user_id, now)

    local rows = {}

    for _, destination_id in ipairs(
        TravelDestinationDefinitions.ORDER
    ) do
        local definition = assert(
            TravelDestinationDefinitions.get(destination_id)
        )

        local reason = runtime_reason
        if not reason and remaining > 0 then
            reason = "TravelCooldown"
        end

        table.insert(rows, {
            Id = definition.Id,
            Name = definition.Name,
            Available = reason == nil,
            Reason = reason,
        })
    end

    return {
        ok = true,
        CooldownRemaining = remaining,
        Destinations = rows,
    }
end

return table.freeze(TravelService)
