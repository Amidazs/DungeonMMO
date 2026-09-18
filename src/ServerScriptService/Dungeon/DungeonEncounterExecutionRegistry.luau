--!strict
local DungeonEncounterExecutionRegistry = {}
DungeonEncounterExecutionRegistry.__index =
    DungeonEncounterExecutionRegistry

local LEGACY_KIND_EXECUTORS = table.freeze({
    Combat = "CombatPack",
    MiniBoss = "Boss",
    Boss = "Boss",
    FinalBoss = "Boss",
    EventBoss = "Boss",
    SecretBoss = "Boss",
})

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

-- Creates an empty server-owned encounter executor registry.
function DungeonEncounterExecutionRegistry.new(): any
    return setmetatable({
        _executors = {},
    }, DungeonEncounterExecutionRegistry)
end

-- Registers one stable executor ID exactly once.
function DungeonEncounterExecutionRegistry:register(
    executor_id: string,
    executor: any
): any
    if type(executor_id) ~= "string"
        or executor_id == ""
        or type(executor) ~= "table"
        or type(executor.execute) ~= "function"
    then
        return result(false, "InvalidExecutor")
    end

    if self._executors[executor_id] ~= nil then
        return result(false, "ExecutorAlreadyRegistered")
    end

    self._executors[executor_id] = executor
    return result(true, nil)
end

-- Returns whether one stable executor ID is actually registered.
function DungeonEncounterExecutionRegistry:is_registered(
    executor_id: string
): boolean
    return self._executors[executor_id] ~= nil
end

-- Resolves an explicit executor ID or a legacy kind fallback.
function DungeonEncounterExecutionRegistry:resolve_id(
    encounter: any
): string?
    if type(encounter) ~= "table" then
        return nil
    end

    if type(encounter.ExecutorId) == "string"
        and encounter.ExecutorId ~= ""
    then
        return encounter.ExecutorId
    end

    if type(encounter.Kind) ~= "string" then
        return nil
    end

    return LEGACY_KIND_EXECUTORS[encounter.Kind]
end

-- Validates that the selected executor can execute one encounter.
function DungeonEncounterExecutionRegistry:validate(
    encounter: any,
    binding: any,
    context: any
): any
    local executor_id = self:resolve_id(encounter)
    if not executor_id then
        return result(false, "UnknownEncounterExecutor")
    end

    local executor = self._executors[executor_id]
    if not executor then
        return result(false, "EncounterExecutorMissing", {
            ExecutorId = executor_id,
        })
    end

    if type(executor.validate) ~= "function" then
        return result(true, nil, {
            ExecutorId = executor_id,
        })
    end

    local validated = executor:validate(
        encounter,
        binding,
        context
    )
    if type(validated) ~= "table" then
        return result(false, "InvalidExecutorValidationResult")
    end

    validated.ExecutorId = executor_id
    return validated
end

-- Dispatches one encounter to its selected server-owned executor.
function DungeonEncounterExecutionRegistry:execute(
    encounter: any,
    binding: any,
    context: any
): any
    local executor_id = self:resolve_id(encounter)
    if not executor_id then
        return result(false, "UnknownEncounterExecutor")
    end

    local executor = self._executors[executor_id]
    if not executor then
        return result(false, "EncounterExecutorMissing", {
            ExecutorId = executor_id,
        })
    end

    local executed = executor:execute(
        encounter,
        binding,
        context
    )
    if type(executed) ~= "table" then
        return result(false, "InvalidExecutorResult", {
            ExecutorId = executor_id,
        })
    end

    executed.ExecutorId = executor_id
    return executed
end

-- Cleans up a successful execution when downstream startup is rejected.
function DungeonEncounterExecutionRegistry:cleanup(
    encounter: any,
    binding: any,
    execution: any,
    context: any
): any
    local executor_id = self:resolve_id(encounter)
    if not executor_id then
        return result(false, "UnknownEncounterExecutor")
    end

    local executor = self._executors[executor_id]
    if not executor then
        return result(false, "EncounterExecutorMissing", {
            ExecutorId = executor_id,
        })
    end

    if type(executor.cleanup) == "function" then
        local cleaned = executor:cleanup(
            encounter,
            binding,
            execution,
            context
        )
        if type(cleaned) ~= "table" then
            return result(false, "InvalidExecutorCleanupResult", {
                ExecutorId = executor_id,
            })
        end
        cleaned.ExecutorId = executor_id
        return cleaned
    end

    for _, enemy in ipairs(
        type(execution) == "table"
            and execution.Enemies
            or {}
    ) do
        if typeof(enemy) == "Instance" then
            enemy:Destroy()
        end
    end

    return result(true, nil, {
        ExecutorId = executor_id,
    })
end

return table.freeze(DungeonEncounterExecutionRegistry)
