--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local DungeonRuntimeContentCatalog = require(
    Shared:WaitForChild("DungeonRuntimeContentCatalog")
)

local DungeonEncounterExecutionRegistry = require(
    Dungeon:WaitForChild("DungeonEncounterExecutionRegistry")
)
local DungeonBossFactoryRegistry = require(
    Dungeon:WaitForChild("DungeonBossFactoryRegistry")
)
local DungeonEnemyFactoryRegistry = require(
    Dungeon:WaitForChild("DungeonEnemyFactoryRegistry")
)
local CombatPackEncounterExecutor = require(
    Dungeon:WaitForChild("CombatPackEncounterExecutor")
)
local BossEncounterExecutor = require(
    Dungeon:WaitForChild("BossEncounterExecutor")
)
local MarauderCaptainFactory = require(
    Dungeon:WaitForChild("MarauderCaptainFactory")
)
local MineForemanFactory = require(
    Dungeon:WaitForChild("MineForemanFactory")
)
local TempleDepth2BossFactory = require(
    Dungeon:WaitForChild("TempleDepth2BossFactory")
)
local AbandonedMineDepth2BossFactory = require(
    Dungeon:WaitForChild("AbandonedMineDepth2BossFactory")
)
local DungeonMarauderFactory = require(
    Dungeon:WaitForChild("DungeonMarauderFactory")
)

local DungeonEncounterExecutionBootstrap = {}

local function require_registration(result: any, label: string)
    assert(
        result.ok == true,
        label .. " registration failed: " .. tostring(result.reason)
    )
end

-- Builds the server-owned execution registry.
-- Registers only currently implemented content.
function DungeonEncounterExecutionBootstrap.create(): any
    local boss_factories = DungeonBossFactoryRegistry.new()

    require_registration(
        boss_factories:register(
            "MarauderCaptain",
            MarauderCaptainFactory
        ),
        "MarauderCaptain"
    )
    require_registration(
        boss_factories:register(
            "CorruptedForeman",
            MineForemanFactory
        ),
        "CorruptedForeman"
    )
    require_registration(
        boss_factories:register(
            "TempleDepth2Boss",
            TempleDepth2BossFactory
        ),
        "TempleDepth2Boss"
    )
    require_registration(
        boss_factories:register(
            "AbandonedMineDepth2Boss",
            AbandonedMineDepth2BossFactory
        ),
        "AbandonedMineDepth2Boss"
    )

    for _, factory_id in ipairs(
        DungeonRuntimeContentCatalog.boss_factory_ids()
    ) do
        assert(
            boss_factories:get(factory_id) ~= nil,
            "Declared boss factory is not registered: "
                .. factory_id
        )
    end

    local enemy_factories = DungeonEnemyFactoryRegistry.new()
    require_registration(
        enemy_factories:register(
            "Marauder",
            DungeonMarauderFactory
        ),
        "Marauder enemy factory"
    )

    for _, factory_id in ipairs(
        DungeonRuntimeContentCatalog.enemy_factory_ids()
    ) do
        assert(
            enemy_factories:is_registered(factory_id),
            "Declared enemy factory is not registered: "
                .. factory_id
        )
    end

    local registry = DungeonEncounterExecutionRegistry.new()
    require_registration(
        registry:register(
            "CombatPack",
            CombatPackEncounterExecutor.new({
                enemy_factory_registry = enemy_factories,
            })
        ),
        "CombatPack executor"
    )
    require_registration(
        registry:register(
            "Boss",
            BossEncounterExecutor.new({
                boss_factory_registry = boss_factories,
            })
        ),
        "Boss executor"
    )

    for _, executor_id in ipairs(
        DungeonRuntimeContentCatalog.executor_ids()
    ) do
        assert(
            registry:is_registered(executor_id),
            "Declared encounter executor is not registered: "
                .. executor_id
        )
    end

    return registry
end

return table.freeze(DungeonEncounterExecutionBootstrap)
