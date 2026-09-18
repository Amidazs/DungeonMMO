--!strict
-- Dungeon-only wrapper that keeps temporary test HP out of Phase 1 combat.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Combat = ServerScriptService:WaitForChild("Combat")
local MarauderFactory = require(Combat:WaitForChild("MarauderFactory"))
local DungeonDefinitions = require(
    ReplicatedStorage:WaitForChild("Core")
        :WaitForChild("Shared")
        :WaitForChild("DungeonDefinitions")
)

local DungeonMarauderFactory = {}

function DungeonMarauderFactory.create(options: any): Model
    local marauder = MarauderFactory.create(options)
    local humanoid = marauder:FindFirstChildOfClass("Humanoid")
    assert(humanoid ~= nil, "Dungeon Marauder requires a Humanoid")

    local base_health = tonumber(options.BaseMaxHealth)
        or DungeonDefinitions.TEST_DUNGEON.StandardMarauderMaxHealth
    local multiplier = math.max(0.01, tonumber(options.HealthMultiplier) or 1)
    local max_health = base_health * multiplier
    humanoid.MaxHealth = max_health
    humanoid.Health = max_health

    local damage_multiplier = math.max(
        0,
        tonumber(options.DamageMultiplier) or 1
    )
    marauder:SetAttribute(
        "DungeonDamageMultiplier",
        damage_multiplier
    )

    return marauder
end

return table.freeze(DungeonMarauderFactory)
