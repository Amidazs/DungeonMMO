--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DungeonDefinitions = require(
    ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared"):WaitForChild("DungeonDefinitions")
)
local DungeonDifficultyDefinitions = require(
    ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared"):WaitForChild(
        "DungeonDifficultyDefinitions"
    )
)
local TestRelease = require(
    ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
        :WaitForChild("DungeonTestPlaceholderRelease")
)

local DungeonOptionalBossRunState = require(
    script.Parent:WaitForChild("DungeonOptionalBossRunState")
)

local DungeonInstanceDirector = {}

local function stable_hash(text: string): number
    local value = 2166136261
    for index = 1, #text do
        value = bit32.bxor(value, string.byte(text, index))
        value = (value * 16777619) % 4294967296
    end
    return value
end

local function optional_boolean(value: any): boolean?
    return if type(value) == "boolean" then value else nil
end

local function copy_encounters(encounters: {any}): {any}
    local result = {}
    for _, encounter in ipairs(encounters) do
        local copy = {}
        for key, value in pairs(encounter) do
            copy[key] = value
        end
        table.insert(result, copy)
    end
    return result
end

function DungeonInstanceDirector.runtime_options(): any
    -- TeleportCoordinator freezes the run in the Base before teleporting.
    -- The exact TEST lobby must issue the same server-owned Event/Secret
    -- practice eligibility as a direct TEST Dungeon Studio session.
    -- Other universes/places never receive this override.
    local test_temple = TestRelease.is_test_temple_context()
    local now = os.time()
    return {
        force_rare = optional_boolean(Workspace:GetAttribute("DungeonMMOStudioForceRareState")),
        force_event = optional_boolean(Workspace:GetAttribute("DungeonMMOStudioForceEvent")),
        event_start = ServerScriptService:GetAttribute("DungeonMMOEventStartUnix"),
        event_end = ServerScriptService:GetAttribute("DungeonMMOEventEndUnix"),
        optional_boss_schedule_enabled = ServerScriptService:GetAttribute(
            "DungeonMMOOptionalBossScheduleEnabled"
        ) == true,
        optional_boss_secret_routes_enabled = ServerScriptService:GetAttribute(
            "DungeonMMOOptionalBossSecretRoutesEnabled"
        ) == true,
        optional_boss_event_start = if test_temple
            then now - 60
            else ServerScriptService:GetAttribute(
                "DungeonMMOOptionalBossEventStartUnix"
            ),
        optional_boss_event_end = if test_temple
            then now + 1800
            else ServerScriptService:GetAttribute(
                "DungeonMMOOptionalBossEventEndUnix"
            ),
        optional_boss_secret_chance_basis_points = if test_temple
            then 10000
            else ServerScriptService:GetAttribute(
                "DungeonMMOOptionalBossSecretChanceBasisPoints"
            ),
        -- Independent opt-in. Never unlocks optional bosses or depths.
        optional_boss_variants_enabled = ServerScriptService:GetAttribute(
            "DungeonMMOOptionalBossVariantsEnabled"
        ) == true,
        -- Independent opt-in, disabled unless the server explicitly asks.
        -- Missing physical late-event bindings still fail closed at entry.
        optional_boss_templates_enabled = ServerScriptService:GetAttribute(
            "DungeonMMOOptionalBossTemplatesEnabled"
        ) == true,
    }
end

-- Adds only server-issued optional eligibility to the new run snapshot.
-- Args: state (any): Existing authoritative dungeon run state.
--       dungeon_id (string): Selected dungeon.
--       seed (number): Server-computed session hash.
--       now (number): Server timestamp at run creation.
--       options (any): Server runtime scheduling options.
--       enabled (boolean): Dungeon optional-boss release switch.
-- Returns: any: Same run state with separate optional-boss fields.
local function attach_optional_state(
    state: any,
    dungeon_id: string,
    seed: number,
    now: number,
    options: any,
    enabled: boolean,
    difficulty_id: string
): any
    local issued = DungeonOptionalBossRunState.issue(
        dungeon_id, now, seed, options, enabled, difficulty_id
    )
    for key, value in pairs(issued) do
        state[key] = value
    end
    return state
end

function DungeonInstanceDirector.resolve(
    dungeon_id: string,
    session_id: string,
    now: number,
    options: any?,
    difficulty_id: string?
): any
    local definition = DungeonDefinitions.get(dungeon_id)
    assert(definition ~= nil, "Unknown dungeon " .. tostring(dungeon_id))

    local difficulty = DungeonDifficultyDefinitions.resolve(
        dungeon_id,
        difficulty_id
    )
    assert(
        difficulty ~= nil,
        "Unknown dungeon difficulty " .. tostring(difficulty_id)
    )
    local opts = options or {}
    -- TEST Event/Secret rooms are registered for Depth1 only.
    -- Higher-depth encounters must not inherit optional eligibility.
    local allow_optional = definition.OptionalBossRuntimeEnabled == true
        and (not TestRelease.is_test_dungeon()
            or difficulty.Id == "Depth1")

    if dungeon_id ~= DungeonDefinitions.ABANDONED_MINE.Id then
        return attach_optional_state({
            DungeonId = dungeon_id,
            DifficultyId = difficulty.Id,
            DifficultyOrder = difficulty.Order,
            EncounterSequence = copy_encounters(
                difficulty.EncounterSequence
            ),
            Module1Id = "TempleRoom1",
            Module2Id = "TempleRoom2",
            RareStateId = nil,
            EventId = nil,
            EventActive = false,
            CreatedAt = now,
        }, dungeon_id, stable_hash(session_id), now, opts,
            allow_optional, difficulty.Id)
    end

    local seed = stable_hash(session_id)
    local module1_pool = definition.ModulePool.Room1
    local module2_pool = definition.ModulePool.Room2
    local module1_index = (seed % #module1_pool) + 1
    local module2_index = (math.floor(seed / 17) % #module2_pool) + 1

    local forced_rare = optional_boolean(opts.force_rare)
    local rare_active: boolean
    if forced_rare ~= nil then
        rare_active = forced_rare
    else
        rare_active = (math.floor(seed / 101) % 10000) < (definition.RareStateChanceBasisPoints or 0)
    end

    local forced_event = optional_boolean(opts.force_event)
    local event_active: boolean
    if forced_event ~= nil then
        event_active = forced_event
    else
        local start_at = tonumber(opts.event_start)
        local end_at = tonumber(opts.event_end)
        event_active = start_at ~= nil
            and end_at ~= nil
            and end_at > start_at
            and now >= start_at
            and now < end_at
    end

    return attach_optional_state({
        DungeonId = dungeon_id,
        DifficultyId = difficulty.Id,
        DifficultyOrder = difficulty.Order,
        EncounterSequence = copy_encounters(
            difficulty.EncounterSequence
        ),
        Module1Id = module1_pool[module1_index],
        Module2Id = module2_pool[module2_index],
        RareStateId = if rare_active then "CrystalBloom" else nil,
        EventId = if event_active then "DeepEchoes" else nil,
        EventActive = event_active,
        CreatedAt = now,
    }, dungeon_id, seed, now, opts,
        allow_optional, difficulty.Id)
end

return table.freeze(DungeonInstanceDirector)
