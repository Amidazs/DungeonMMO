--!strict
-- Central environment namespace selection. Published environments fail closed.
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local TestRelease = require(
    script.Parent:WaitForChild("DungeonTestPlaceholderRelease")
)

local EnvironmentConfig = {}

local PROFILE_STORES: {[string]: string} = table.freeze({
    DEV = "DEV_PlayerProfile_v1",
    TEST = "TEST_PlayerProfile_v1",
    PROD = "PROD_PlayerProfile_v1",
})

local MEMORY_PREFIXES: {[string]: string} = table.freeze({
    DEV = "DEV_DungeonMMO_v1",
    TEST = "TEST_DungeonMMO_v1",
    PROD = "PROD_DungeonMMO_v1",
})

local function validate_environment(environment: string): string
    assert(
        environment == "DEV"
            or environment == "TEST"
            or environment == "PROD",
        "Environment must be DEV, TEST or PROD"
    )
    return environment
end

function EnvironmentConfig.get_environment(): string
    if RunService:IsStudio() then
        return "DEV"
    end

    assert(
        RunService:IsServer(),
        "Published environment may only be resolved on the server"
    )
    local configured = ServerScriptService:GetAttribute(
        "DungeonMMOEnvironment"
    )
    if configured == "TEST" or configured == "PROD" then
        return configured
    end

    if TestRelease.is_test_temple_context() then
        return "TEST"
    end

    error(
        "Set ServerScriptService.DungeonMMOEnvironment to TEST or PROD"
    )
end

function EnvironmentConfig.get_profile_store_name_for(
    environment: string
): string
    local valid_environment = validate_environment(environment)
    return PROFILE_STORES[valid_environment]
end

function EnvironmentConfig.get_memory_prefix_for(
    environment: string
): string
    local valid_environment = validate_environment(environment)
    return MEMORY_PREFIXES[valid_environment]
end

function EnvironmentConfig.get_profile_store_name(): string
    return EnvironmentConfig.get_profile_store_name_for(
        EnvironmentConfig.get_environment()
    )
end

function EnvironmentConfig.get_memory_prefix(): string
    return EnvironmentConfig.get_memory_prefix_for(
        EnvironmentConfig.get_environment()
    )
end

return table.freeze(EnvironmentConfig)
