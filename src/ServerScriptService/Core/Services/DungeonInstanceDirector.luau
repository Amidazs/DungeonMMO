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
    return {
        force_rare = optional_boolean(Workspace:GetAttribute("DungeonMMOStudioForceRareState")),
        force_event = optional_boolean(Workspace:GetAttribute("DungeonMMOStudioForceEvent")),
        event_start = ServerScriptService:GetAttribute("DungeonMMOEventStartUnix"),
        event_end = ServerScriptService:GetAttribute("DungeonMMOEventEndUnix"),
    }
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

    if dungeon_id ~= DungeonDefinitions.ABANDONED_MINE.Id then
        return {
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
        }
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

    return {
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
    }
end

return table.freeze(DungeonInstanceDirector)
