--!strict
-- Snapshots optional boss availability when a server creates a dungeon run.
local DungeonOptionalBossRunState = {}
local Rules = require(script.Parent:WaitForChild("DungeonOptionalBossRules"))

local DUNGEONS = table.freeze({
    TestDungeon = {
        EventId = "TempleEclipse",
        SecretId = "TempleHiddenSanctum",
    },
    AbandonedMine = {
        EventId = "MineEchoSurge",
        SecretId = "MineSealedGallery",
    },
})

-- Rejects NaN and infinite timestamp, seed, or configuration values.
-- Args: value (any): Number to validate.
-- Returns: boolean: True only for a finite numeric value.
local function finite_number(value: any): boolean
    return type(value) == "number"
        and value == value
        and math.abs(value) < math.huge
end

-- Returns a disabled snapshot for unsupported or locked content.
-- Args: None.
-- Returns: any: Inactive optional boss fields for a new run.
local function disabled_snapshot(): any
    return {
        OptionalBossEnabled = false,
        OptionalBossEventActive = false,
        OptionalBossEventId = nil,
        OptionalBossEventWindows = {},
        OptionalBossSecretUnlocked = false,
        OptionalBossSecretUnlocks = {},
    }
end

-- Evaluates an explicitly configured server-owned entry window.
-- Args: event_id (string): Dungeon-specific optional event ID.
--       entered_at (number): Server run-creation timestamp.
--       options (any): Trusted server schedule configuration.
-- Returns: any?: Window snapshot only if entry occurs in the window.
local function eligible_event(
    event_id: string,
    entered_at: number,
    options: any
): any?
    local start_at = options.optional_boss_event_start
    local end_at = options.optional_boss_event_end
    if not finite_number(start_at)
        or not finite_number(end_at)
        or start_at < 1
        or end_at <= start_at
        or entered_at < start_at
        or entered_at >= end_at
    then
        return nil
    end
    return {StartUnix = start_at, EndUnix = end_at}
end

-- Selects a hidden route using a server-owned configured probability.
-- Args: session_seed (number): Deterministic server session hash.
--       options (any): Trusted server hidden-route configuration.
-- Returns: boolean: Whether this run is eligible for the hidden route.
local function hidden_route_selected(
    session_seed: number,
    options: any
): boolean
    local chance = options.optional_boss_secret_chance_basis_points
    return finite_number(chance)
        and chance >= 1
        and chance <= 10000
        and chance % 1 == 0
        and session_seed % 10000 < chance
end

-- Issues a run-frozen optional-boss eligibility snapshot.
-- Args: dungeon_id (string): Registered dungeon identity.
--       entered_at (number): Server run-creation time.
--       session_seed (number): Server-computed deterministic session seed.
--       options (any): Server-owned schedule/route settings.
--       release_enabled (boolean): Explicit dungeon rollout switch.
-- Returns: any: Frozen-in-session optional event and route fields.
function DungeonOptionalBossRunState.issue(
    dungeon_id: string,
    entered_at: number,
    session_seed: number,
    options: any?,
    release_enabled: boolean
): any
    local state = disabled_snapshot()
    local dungeon = DUNGEONS[dungeon_id]
    if not dungeon or release_enabled ~= true
        or not finite_number(entered_at)
        or not finite_number(session_seed)
    then
        return state
    end

    local settings = Rules.resolve(dungeon_id, entered_at, options)
    local window = eligible_event(
        dungeon.EventId, entered_at, settings
    )
    local secret = hidden_route_selected(
        session_seed, settings
    )
    state.OptionalBossEventActive = window ~= nil
    state.OptionalBossEventId = if window
        then dungeon.EventId else nil
    if window then
        state.OptionalBossEventWindows[dungeon.EventId] = window
    end
    state.OptionalBossSecretUnlocked = secret
    if secret then
        state.OptionalBossSecretUnlocks[dungeon.SecretId] = true
    end
    state.OptionalBossEnabled = window ~= nil or secret
    return state
end

return table.freeze(DungeonOptionalBossRunState)
