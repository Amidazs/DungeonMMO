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
local DungeonBossSpawnGuard = require(
    Dungeon:WaitForChild("DungeonBossSpawnGuard")
)

local BossEncounterExecutor = {}
BossEncounterExecutor.__index = BossEncounterExecutor

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

-- Creates a boss executor backed by a stable BossId factory registry.
function BossEncounterExecutor.new(options: any): any
    assert(
        type(options) == "table"
            and options.boss_factory_registry ~= nil,
        "BossEncounterExecutor requires boss_factory_registry."
    )

    return setmetatable({
        _boss_factories = options.boss_factory_registry,
        _boss_spawn_guard =
            options.boss_spawn_guard or DungeonBossSpawnGuard,
    }, BossEncounterExecutor)
end

local function resolve_spec(encounter: any): any?
    if type(encounter.BossId) ~= "string"
        or encounter.BossId == ""
    then
        return nil
    end

    return DungeonEncounterSpawnCatalog.get_boss(
        encounter.BossId
    )
end

-- Validates registered boss content without spawning it.
function BossEncounterExecutor:validate(
    encounter: any,
    binding: any,
    context: any
): any
    local spec = resolve_spec(encounter)
    if not spec then
        return result(false, "BossContentNotRegistered")
    end

    if self._boss_factories:get(spec.FactoryId) == nil then
        return result(false, "BossFactoryNotRegistered")
    end

    if type(binding) ~= "table"
        or type(binding.RuntimeEncounterId) ~= "string"
        or binding.RuntimeEncounterId == ""
        or type(binding.BossSpawnAnchor) ~= "string"
        or binding.BossSpawnAnchor == ""
        or type(context.Environment) ~= "table"
        or type(context.Environment.get) ~= "function"
        or typeof(context.EnemiesFolder) ~= "Instance"
        or typeof(context.RuntimeRoot) ~= "Instance"
        or type(context.SessionId) ~= "string"
        or context.SessionId == ""
    then
        return result(false, "EncounterExecutionContextInvalid")
    end

    local spawn_anchor = context.Environment:get(
        binding.BossSpawnAnchor
    )
    if typeof(spawn_anchor) ~= "Instance"
        or not spawn_anchor:IsA("BasePart")
    then
        return result(false, "BossSpawnAnchorMissing")
    end

    return result(true, nil, {
        BossSpec = spec,
        SpawnCFrame = spawn_anchor.CFrame,
    })
end

local function scaled_reward(
    spec: any,
    context: any
): any?
    local reward =
        context.DungeonDefinition[spec.RewardKey]
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

-- Spawns one registered boss and returns its presentation handles.
function BossEncounterExecutor:execute(
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

    local spec = validated.BossSpec
    local reward = scaled_reward(spec, context)
    if not reward then
        return result(false, "EncounterRewardDefinitionMissing")
    end

    if not self._boss_spawn_guard.claim(
        context.RuntimeRoot,
        context.SessionId,
        encounter.Id
    ) then
        return result(false, "BossSpawnAlreadyClaimed")
    end

    local factory = self._boss_factories:get(spec.FactoryId)
    local created_ok, boss_or_error = pcall(function()
        return factory.create({
            Parent = context.EnemiesFolder,
            SpawnCFrame = validated.SpawnCFrame,
            EncounterId = binding.RuntimeEncounterId,
            RewardXP = reward.XP,
            RewardGoldMin = reward.GoldMin,
            RewardGoldMax = reward.GoldMax,
            BestiaryCreatureId = reward.BestiaryCreatureId,
            HealthMultiplier =
                context.Tuning.EnemyHealthMultiplier,
            DamageMultiplier =
                context.Tuning.EnemyDamageMultiplier,
            BossRole = encounter.Kind or "Boss",
        })
    end)

    if not created_ok
        or typeof(boss_or_error) ~= "Instance"
        or not boss_or_error:IsA("Model")
    then
        self._boss_spawn_guard.release(
            context.RuntimeRoot,
            context.SessionId,
            encounter.Id
        )
        return result(false, "BossFactoryExecutionFailed")
    end

    local boss = boss_or_error :: Model
    local humanoid = boss:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        boss:Destroy()
        self._boss_spawn_guard.release(
            context.RuntimeRoot,
            context.SessionId,
            encounter.Id
        )
        return result(false, "BossHumanoidMissing")
    end

    return result(true, nil, {
        Enemies = {boss},
        BossModel = boss,
        BossHumanoid = humanoid,
        BossDisplayName = spec.DisplayName,
        Objective = "Defeat " .. spec.DisplayName .. ".",
        ObjectiveState = "Boss",
    })
end

-- Removes a spawned boss and releases its encounter-scoped spawn claim.
function BossEncounterExecutor:cleanup(
    encounter: any,
    _binding: any,
    execution: any,
    context: any
): any
    local boss = type(execution) == "table"
        and execution.BossModel
        or nil
    if typeof(boss) == "Instance" then
        boss:Destroy()
    end

    local released = self._boss_spawn_guard.release(
        context.RuntimeRoot,
        context.SessionId,
        encounter.Id
    )

    return result(true, nil, {
        ClaimReleased = released,
    })
end

return table.freeze(BossEncounterExecutor)
