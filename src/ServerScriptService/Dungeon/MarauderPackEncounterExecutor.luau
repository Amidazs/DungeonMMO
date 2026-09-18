--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Core = ServerScriptService:WaitForChild("Core")
local Services = Core:WaitForChild("Services")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local DungeonDifficultyTuning = require(
    Services:WaitForChild("DungeonDifficultyTuning")
)
local DungeonEncounterSpawnCatalog = require(
    Dungeon:WaitForChild("DungeonEncounterSpawnCatalog")
)
local DungeonMarauderFactory = require(
    Dungeon:WaitForChild("DungeonMarauderFactory")
)

local MarauderPackEncounterExecutor = {}
MarauderPackEncounterExecutor.__index =
    MarauderPackEncounterExecutor

local function result(
    ok: boolean,
    reason: string?,
    extra: any?
): any
    local response = extra or {}
    response.ok = ok
    response.reason = reason
    return response
end

-- Creates a combat-pack executor with an injectable enemy factory for tests.
function MarauderPackEncounterExecutor.new(
    options: any?
): any
    local config = options or {}
    return setmetatable({
        _marauder_factory = config.marauder_factory
            or DungeonMarauderFactory,
    }, MarauderPackEncounterExecutor)
end

local function resolve_pack(
    encounter: any,
    context: any
): any?
    if type(encounter.PackId) ~= "string"
        or encounter.PackId == ""
        or type(context.DungeonDefinition) ~= "table"
        or type(context.DungeonDefinition.Id) ~= "string"
    then
        return nil
    end

    return DungeonEncounterSpawnCatalog.get_pack(
        context.DungeonDefinition.Id,
        encounter.PackId
    )
end

-- Validates that the selected pack has registered content and a room binding.
function MarauderPackEncounterExecutor:validate(
    encounter: any,
    binding: any,
    context: any
): any
    local pack = resolve_pack(encounter, context)
    if not pack then
        return result(false, "EncounterPackMissing")
    end

    if type(binding) ~= "table"
        or type(binding.EnvironmentRoomId) ~= "string"
        or binding.EnvironmentRoomId == ""
    then
        return result(false, "EncounterRoomBindingMissing")
    end

    if type(context.Environment) ~= "table"
        or type(context.Environment.enemy_spawn_cframes)
            ~= "function"
        or typeof(context.EnemiesFolder) ~= "Instance"
    then
        return result(false, "EncounterExecutionContextInvalid")
    end

    return result(true, nil, {
        Pack = pack,
    })
end

local function scaled_reward(
    pack: any,
    context: any
): any?
    local definition = context.DungeonDefinition
    local reward = definition[pack.RewardKey]
    if type(reward) ~= "table"
        or type(context.Tuning) ~= "table"
    then
        return nil
    end

    return DungeonDifficultyTuning.scale_monster_reward(
        reward,
        context.Tuning
    )
end

-- Spawns the registered pack and returns its live enemy models.
function MarauderPackEncounterExecutor:execute(
    encounter: any,
    binding: any,
    context: any
): any
    local validated = self:validate(
        encounter,
        binding,
        context
    )
    if validated.ok ~= true then
        return validated
    end

    local pack = validated.Pack
    local reward = scaled_reward(pack, context)
    if not reward then
        return result(false, "EncounterRewardDefinitionMissing")
    end

    local base_health =
        context.DungeonDefinition[pack.MaxHealthKey]
    if type(base_health) ~= "number" then
        return result(false, "EncounterHealthDefinitionMissing")
    end

    local count = DungeonEncounterSpawnCatalog.resolve_pack_count(
        pack,
        context.InstanceState
    )
    local positions = context.Environment:enemy_spawn_cframes(
        binding.EnvironmentRoomId
    )
    if type(positions) ~= "table"
        or #positions < count
    then
        return result(false, "InsufficientEnemySpawnPoints")
    end

    local enemies = {}
    for index = 1, count do
        local enemy = self._marauder_factory.create({
            Parent = context.EnemiesFolder,
            Name = pack.EnemyNamePrefix .. tostring(index),
            SpawnCFrame = positions[index],
            SpawnIndex = pack.SpawnIndexBase + index,
            RespawnEnabled = false,
            ControllerEnabled = true,
            EncounterId = binding.RuntimeEncounterId,
            EnemyId = pack.EnemyNamePrefix .. tostring(index),
            LifeIndex = 1,
            RewardXP = reward.XP,
            RewardGoldMin = reward.GoldMin,
            RewardGoldMax = reward.GoldMax,
            BaseMaxHealth = base_health,
            HealthMultiplier =
                context.Tuning.EnemyHealthMultiplier,
            DamageMultiplier =
                context.Tuning.EnemyDamageMultiplier,
            BestiaryCreatureId = reward.BestiaryCreatureId,
        })
        table.insert(enemies, enemy)
    end

    return result(true, nil, {
        Enemies = enemies,
        Objective = string.format(
            "Defeat %d enemies.",
            count
        ),
    })
end

return table.freeze(MarauderPackEncounterExecutor)
