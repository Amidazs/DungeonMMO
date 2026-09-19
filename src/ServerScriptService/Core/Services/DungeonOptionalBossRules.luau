--!strict
-- Resolves server-owned optional boss windows at entry, never on reconnect.
local DungeonOptionalBossRules = {}

local WINDOW_SECONDS = 1200
local HOUR_SECONDS = 3600
local ROUTE_CHANCE = 500

-- Checks a finite numeric timestamp or configuration value.
-- Args: value (any): Number to validate.
-- Returns: boolean: Whether the number is finite.
local function finite_number(value: any): boolean
    return type(value) == "number"
        and value == value
        and math.abs(value) < math.huge
end

-- Resolves one explicit or scheduled window without unsafe fallbacks.
-- Args: dungeon_id (string): Registered dungeon identity.
--       entered_at (number): Server-issued UTC timestamp.
--       settings (any): Server-only run options.
-- Returns: any: Event window fields, or empty when unavailable.
local function event_options(
    dungeon_id: string, entered_at: number, settings: any
): any
    local start_at = settings.optional_boss_event_start
    local end_at = settings.optional_boss_event_end
    if start_at ~= nil or end_at ~= nil then
        if finite_number(start_at) and finite_number(end_at)
            and start_at >= 1 and end_at > start_at
        then
            return {optional_boss_event_start = start_at,
                optional_boss_event_end = end_at}
        end
        return {}
    end
    if settings.optional_boss_schedule_enabled ~= true then
        return {}
    end
    local offset = if dungeon_id == "AbandonedMine" then 1800 else 0
    local start = math.floor((entered_at - offset) / HOUR_SECONDS)
        * HOUR_SECONDS + offset
    if entered_at < start or entered_at >= start + WINDOW_SECONDS
        or start < 1
    then
        return {}
    end
    return {optional_boss_event_start = start,
        optional_boss_event_end = start + WINDOW_SECONDS}
end

-- Resolves opt-in scheduling and a deterministic hidden-route chance.
-- Args: dungeon_id (string): Registered dungeon identity.
--       entered_at (number): Server-issued run creation time.
--       options (any?): Trusted server-owned configuration.
-- Returns: any: Eligible event window and secret chance configuration.
function DungeonOptionalBossRules.resolve(
    dungeon_id: string, entered_at: number, options: any?
): any
    if dungeon_id ~= "TestDungeon" and dungeon_id ~= "AbandonedMine"
        or not finite_number(entered_at) or entered_at < 1
    then
        return {}
    end
    local settings = if type(options) == "table" then options else {}
    local resolved = event_options(dungeon_id, entered_at, settings)
    local chance = settings.optional_boss_secret_chance_basis_points
    if chance == nil and settings.optional_boss_secret_routes_enabled == true then
        chance = ROUTE_CHANCE
    end
    if finite_number(chance) and chance >= 0 and chance <= 10000
        and chance % 1 == 0
    then
        resolved.optional_boss_secret_chance_basis_points = chance
    end
    return resolved
end

return table.freeze(DungeonOptionalBossRules)
