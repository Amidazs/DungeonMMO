--!strict
-- Snapshots optional boss availability when a server creates a dungeon run.
local DungeonOptionalBossRunState = {}
local Rules = require(script.Parent:WaitForChild("DungeonOptionalBossRules"))
local Catalog = require(game:GetService("ReplicatedStorage")
    :WaitForChild("Core"):WaitForChild("Shared")
    :WaitForChild("DungeonOptionalBossVariantCatalog"))
local Templates = require(game:GetService("ReplicatedStorage")
    :WaitForChild("Core"):WaitForChild("Shared")
    :WaitForChild("DungeonOptionalEncounterTemplateCatalog"))

-- Legacy default identities are catalog index 1; the opt-in path only
-- changes a newly issued run, never an existing saved snapshot.
local function selected_variant(
    dungeon_id: string, kind: string, seed: number, enabled: boolean
): any?
    local index = 1
    if enabled then
        local offset = if kind == "Event"
            then seed else math.floor(seed / 7)
        index = (offset % Catalog.count(dungeon_id, kind)) + 1
    end
    return Catalog.get(dungeon_id, kind, index)
end

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
        OptionalBossEventTemplateId = nil,
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
    release_enabled: boolean,
    difficulty_id: string?
): any
    local state = disabled_snapshot()
    if Catalog.count(dungeon_id, "Event") == 0
        or release_enabled ~= true
        or not finite_number(entered_at)
        or not finite_number(session_seed)
    then
        return state
    end

    local settings = Rules.resolve(dungeon_id, entered_at, options)
    local variants_enabled = type(options) == "table"
        and options.optional_boss_variants_enabled == true
    local event_variant = assert(selected_variant(
        dungeon_id, "Event", session_seed, variants_enabled))
    local secret_variant = assert(selected_variant(
        dungeon_id, "Secret", session_seed, variants_enabled))
    local window = eligible_event(
        event_variant.Id, entered_at, settings
    )
    local secret = hidden_route_selected(
        session_seed, settings
    )
    state.OptionalBossEventActive = window ~= nil
    state.OptionalBossEventId = if window
        then event_variant.Id else nil
    if window then
        -- Choose a late placement only for a depth that has a registered
        -- template. A physical late arena is separately required by policy.
        -- Default and legacy saved runs retain the original Event room.
        local template_id = "EventAfterRoom1"
        local template_opt_in = type(options) == "table"
            and options.optional_boss_templates_enabled == true
        if template_opt_in and session_seed % 2 == 1
            and Templates.get(dungeon_id, difficulty_id or "",
                "Event", "EventAfterRoom2")
        then
            template_id = "EventAfterRoom2"
        end
        if template_opt_in then
            state.OptionalBossEventTemplateId = template_id
        end
        state.OptionalBossEventWindows[event_variant.Id] = window
    end
    state.OptionalBossSecretUnlocked = secret
    if secret then
        state.OptionalBossSecretUnlocks[secret_variant.Id] = true
    end
    state.OptionalBossEnabled = window ~= nil or secret
    return state
end

return table.freeze(DungeonOptionalBossRunState)
