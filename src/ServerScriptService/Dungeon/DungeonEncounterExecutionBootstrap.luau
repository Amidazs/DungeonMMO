--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local DungeonEncounterExecutionRegistry = require(
    Dungeon:WaitForChild("DungeonEncounterExecutionRegistry")
)
local DungeonBossFactoryRegistry = require(
    Dungeon:WaitForChild("DungeonBossFactoryRegistry")
)
local MarauderPackEncounterExecutor = require(
    Dungeon:WaitForChild("MarauderPackEncounterExecutor")
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

local DungeonEncounterExecutionBootstrap = {}

local function require_registration(result: any, label: string)
    assert(
        result.ok == true,
        label .. " registration failed: " .. tostring(result.reason)
    )
end

-- Builds the server-owned execution registry for currently implemented content.
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

    local registry = DungeonEncounterExecutionRegistry.new()
    require_registration(
        registry:register(
            "CombatPack",
            MarauderPackEncounterExecutor.new()
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

    return registry
end

return table.freeze(DungeonEncounterExecutionBootstrap)
