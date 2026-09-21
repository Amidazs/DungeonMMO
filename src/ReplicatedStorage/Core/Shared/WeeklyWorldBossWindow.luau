--!strict
-- Trusted server-only weekly world-boss calendar. No live event is
-- scheduled by default: Base must supply explicit, authorized timestamps.
local WeeklyWorldBossWindow = {}

local WEEK_SECONDS = 7 * 24 * 60 * 60
local MONDAY_UNIX_OFFSET = 4 * 24 * 60 * 60
local MAX_WINDOW_SECONDS = 2 * 60 * 60

-- Args:
--   value: any; candidate server-owned Unix timestamp.
-- Returns:
--   boolean: whether the timestamp is a finite whole number.
local function valid_time(value: any): boolean
    return type(value) == "number"
        and value == value
        and value >= 0
        and value < math.huge
        and value % 1 == 0
end

-- Args:
--   timestamp: number; trusted Unix UTC timestamp.
-- Returns:
--   number?: Monday 00:00 UTC beginning the timestamp's calendar week.
function WeeklyWorldBossWindow.week_start(timestamp: number): number?
    if not valid_time(timestamp) then
        return nil
    end
    return math.floor(
        (timestamp - MONDAY_UNIX_OFFSET) / WEEK_SECONDS
    ) * WEEK_SECONDS + MONDAY_UNIX_OFFSET
end

-- Args:
--   now: number; authoritative current Unix time.
--   start_at: number; explicitly authorized entry-window start.
--   end_at: number; explicitly authorized exclusive entry-window end.
-- Returns:
--   any: validated event snapshot or a reasoned rejection.
function WeeklyWorldBossWindow.resolve(
    now: number,
    start_at: number,
    end_at: number
): any
    if not valid_time(now) or not valid_time(start_at)
        or not valid_time(end_at) or end_at <= start_at
        or end_at - start_at > MAX_WINDOW_SECONDS
    then
        return {ok = false, reason = "InvalidWorldBossWindow"}
    end

    local week_start = WeeklyWorldBossWindow.week_start(start_at)
    if week_start == nil or end_at > week_start + WEEK_SECONDS then
        return {ok = false, reason = "CrossesWeeklyReset"}
    end
    if now < start_at or now >= end_at then
        return {ok = false, reason = "WorldBossEntryClosed"}
    end

    return {
        ok = true,
        reason = nil,
        WeekStart = week_start,
        WindowStart = start_at,
        WindowEnd = end_at,
    }
end

return table.freeze(WeeklyWorldBossWindow)
