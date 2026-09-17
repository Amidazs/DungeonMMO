--!strict
local RateLimitService = {}
RateLimitService.__index = RateLimitService

local function finite(value: any): boolean
    return type(value) == "number"
        and value == value
        and value > -math.huge
        and value < math.huge
end

function RateLimitService.new(clock: (() -> number)?): any
    return setmetatable({
        _clock = clock or os.clock,
        _windows = {},
    }, RateLimitService)
end

function RateLimitService:allow(
    user_id: number,
    action: string,
    limit: number,
    window_seconds: number
): boolean
    if not finite(user_id) or user_id < 1
        or type(action) ~= "string" or action == "" or #action > 128
        or not finite(limit) or limit < 1 or limit % 1 ~= 0
        or not finite(window_seconds) or window_seconds <= 0
    then
        return false
    end

    local now = self._clock()
    if not finite(now) then return false end
    local per_user = self._windows[user_id]
    if not per_user then
        per_user = {}
        self._windows[user_id] = per_user
    end
    local window = per_user[action]
    if not window or now - window.Start >= window_seconds then
        per_user[action] = {Start = now, Count = 1}
        return true
    end

    if window.Count >= limit then
        return false
    end

    window.Count += 1
    return true
end

function RateLimitService:clear_user(user_id: number)
    self._windows[user_id] = nil
end

return table.freeze(RateLimitService)
