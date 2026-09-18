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

local CombatPackEncounterExecutor = {}
CombatPackEncounterExecutor.__index =
    CombatPackEncounterExecutor

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

-- Creates a generic combat-pack executor.
function CombatPackEncounterExecutor.new(
    options: any
): any
    assert(
        type(options) == "table"
            and options.enemy_factory_registry ~= nil,
        "CombatPackEncounterExecutor requires enemy_factory_registry."
    )

    return setmetatable({
        _enemy_factories = options.enemy_factory_registry,
        _spawn_catalog =
            options.spawn_catalog or DungeonEncounterSpawnCatalog,
    }, CombatPackEncounterExecutor)
end

local function resolve_pack(
    self: any,
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

    return self._spawn_catalog.get_pack(
        context.DungeonDefinition.Id,
        encounter.PackId
    )
end

local function validate_entry(
    self: any,
    entry: any
): any
    if type(entry) ~= "table"
        or type(entry.EntryId) ~= "string"
        or entry.EntryId == ""
        or type(entry.EnemyArchetypeId) ~= "string"
        or entry.EnemyArchetypeId == ""
        or type(entry.EnemyNamePrefix) ~= "string"
        or entry.EnemyNamePrefix == ""
        or type(entry.SpawnIndexBase) ~= "number"
        or type(entry.BaseCount) ~= "number"
        or entry.BaseCount < 0
    then
        return result(false, "InvalidCombatPackEntry")
    end

    local archetype =
        self._spawn_catalog.get_enemy_archetype(
            entry.EnemyArchetypeId
        )
    if not archetype then
        return result(false, "EnemyArchetypeNotRegistered")
    end

    local factory_id = archetype.FactoryId
    if type(factory_id) ~= "string"
        or factory_id == ""
        or self._enemy_factories:get(factory_id) == nil
    then
        return result(false, "EnemyFactoryNotRegistered")
    end

    return result(true, nil, {
        Archetype = archetype,
        FactoryId = factory_id,
    })
end

-- Validates pack content and room execution dependencies without spawning.
function CombatPackEncounterExecutor:validate(
    encounter: any,
    binding: any,
    context: any
): any
    local pack = resolve_pack(self, encounter, context)
    if not pack then
        return result(false, "EncounterPackMissing")
    end

    if type(pack.Entries) ~= "table"
        or #pack.Entries == 0
    then
        return result(false, "InvalidCombatPack")
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

    for _, entry in ipairs(pack.Entries) do
        local validated = validate_entry(self, entry)
        if validated.ok ~= true then
            return validated
        end
    end

    return result(true, nil, {
        Pack = pack,
    })
end

local function scaled_reward(
    archetype: any,
    context: any
): any?
    local definition = context.DungeonDefinition
    local reward = definition[archetype.RewardKey]
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

local function destroy_enemies(enemies: {Model})
    for _, enemy in ipairs(enemies) do
        enemy:Destroy()
    end
end

local function create_enemy(
    factory: any,
    options: any
): Model?
    local created_ok, enemy_or_error = pcall(function()
        return factory.create(options)
    end)
    if not created_ok
        or typeof(enemy_or_error) ~= "Instance"
        or not enemy_or_error:IsA("Model")
    then
        return nil
    end
    return enemy_or_error
end

local function total_enemy_count(
    resolved_entries: {any}
): number
    local count = 0
    for _, resolved in ipairs(resolved_entries) do
        count += math.max(
            0,
            math.floor(tonumber(resolved.Count) or 0)
        )
    end
    return count
end

local function resolve_entry_execution(
    self: any,
    resolved: any,
    context: any
): any
    local entry = resolved.Entry
    local validated = validate_entry(self, entry)
    if validated.ok ~= true then
        return validated
    end

    local archetype = validated.Archetype
    local reward = scaled_reward(archetype, context)
    local base_health =
        context.DungeonDefinition[archetype.MaxHealthKey]
    if not reward or type(base_health) ~= "number" then
        return result(false, "EncounterEnemyDefinitionMissing")
    end

    return result(true, nil, {
        Entry = entry,
        Factory = self._enemy_factories:get(
            validated.FactoryId
        ),
        Reward = reward,
        BaseHealth = base_health,
        Count = math.max(
            0,
            math.floor(tonumber(resolved.Count) or 0)
        ),
    })
end

local function enemy_create_options(
    entry_execution: any,
    binding: any,
    context: any,
    spawn_cframe: CFrame,
    entry_index: number
): any
    local entry = entry_execution.Entry
    local reward = entry_execution.Reward
    local enemy_name =
        entry.EnemyNamePrefix .. tostring(entry_index)

    return {
        Parent = context.EnemiesFolder,
        Name = enemy_name,
        SpawnCFrame = spawn_cframe,
        SpawnIndex = entry.SpawnIndexBase + entry_index,
        RespawnEnabled = false,
        ControllerEnabled = true,
        EncounterId = binding.RuntimeEncounterId,
        EnemyId = enemy_name,
        LifeIndex = 1,
        RewardXP = reward.XP,
        RewardGoldMin = reward.GoldMin,
        RewardGoldMax = reward.GoldMax,
        BaseMaxHealth = entry_execution.BaseHealth,
        HealthMultiplier =
            context.Tuning.EnemyHealthMultiplier,
        DamageMultiplier =
            context.Tuning.EnemyDamageMultiplier,
        BestiaryCreatureId = reward.BestiaryCreatureId,
    }
end

local function spawn_entry(
    entry_execution: any,
    binding: any,
    context: any,
    positions: {CFrame},
    position_index: number,
    enemies: {Model}
): any
    for entry_index = 1, entry_execution.Count do
        position_index += 1
        local enemy = create_enemy(
            entry_execution.Factory,
            enemy_create_options(
                entry_execution,
                binding,
                context,
                positions[position_index],
                entry_index
            )
        )
        if not enemy then
            return result(false, "EnemyFactoryExecutionFailed", {
                PositionIndex = position_index,
            })
        end
        table.insert(enemies, enemy)
    end

    return result(true, nil, {
        PositionIndex = position_index,
    })
end

-- Spawns all ordered entries in one heterogeneous combat pack.
function CombatPackEncounterExecutor:execute(
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

    local resolved_entries =
        self._spawn_catalog.resolve_pack_entries(
            validated.Pack,
            context.InstanceState
        )
    if type(resolved_entries) ~= "table" then
        return result(false, "InvalidCombatPackResolution")
    end

    local total_count = total_enemy_count(resolved_entries)
    local positions =
        context.Environment:enemy_spawn_cframes(
            binding.EnvironmentRoomId
        )
    if type(positions) ~= "table"
        or #positions < total_count
    then
        return result(false, "InsufficientEnemySpawnPoints")
    end

    local enemies = {}
    local position_index = 0

    for _, resolved in ipairs(resolved_entries) do
        local entry_execution = resolve_entry_execution(
            self,
            resolved,
            context
        )
        if entry_execution.ok ~= true then
            destroy_enemies(enemies)
            return entry_execution
        end

        local spawned = spawn_entry(
            entry_execution,
            binding,
            context,
            positions,
            position_index,
            enemies
        )
        if spawned.ok ~= true then
            destroy_enemies(enemies)
            return spawned
        end
        position_index = spawned.PositionIndex
    end

    return result(true, nil, {
        Enemies = enemies,
        Objective = string.format(
            "Defeat %d enemies.",
            total_count
        ),
    })
end

-- Removes all enemies spawned for a combat-pack execution.
function CombatPackEncounterExecutor:cleanup(
    _encounter: any,
    _binding: any,
    execution: any,
    _context: any
): any
    for _, enemy in ipairs(
        type(execution) == "table"
            and execution.Enemies
            or {}
    ) do
        if typeof(enemy) == "Instance" then
            enemy:Destroy()
        end
    end
    return result(true, nil)
end

return table.freeze(CombatPackEncounterExecutor)
