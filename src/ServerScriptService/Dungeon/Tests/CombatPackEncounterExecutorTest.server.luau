--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local module = Dungeon:FindFirstChild("CombatPackEncounterExecutor")
if not module then
    error(
        "[Combat Pack Encounter Executor Tests] RED: "
            .. "CombatPackEncounterExecutor is missing."
    )
end

local Executor = require(module)
local assertion_count = 0

-- Verifies one generic combat-pack executor expectation.
local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Combat Pack Encounter Executor Tests] " .. message,
            2
        )
    end
end

local factory_calls = {}
local marauder_factory = {}
function marauder_factory.create(options: any): Model
    local model = Instance.new("Model")
    model.Name = options.Name
    model.Parent = options.Parent

    table.insert(factory_calls, {
        FactoryId = "Marauder",
        Options = options,
    })
    return model
end

local elite_factory = {}
function elite_factory.create(options: any): Model
    local model = Instance.new("Model")
    model.Name = options.Name
    model.Parent = options.Parent
    table.insert(factory_calls, {
        FactoryId = "Elite",
        Options = options,
    })
    return model
end

local fake_registry = {}
function fake_registry:get(factory_id: string): any?
    if factory_id == "Marauder" then
        return marauder_factory
    end
    if factory_id == "Elite" then
        return elite_factory
    end
    return nil
end

local pack = {
    Entries = {
        {
            EntryId = "Marauders",
            EnemyArchetypeId = "Marauder",
            BaseCount = 2,
            EnemyNamePrefix = "Mixed_Marauder_",
            SpawnIndexBase = 100,
        },
        {
            EntryId = "Elite",
            EnemyArchetypeId = "Elite",
            BaseCount = 1,
            EnemyNamePrefix = "Mixed_Elite_",
            SpawnIndexBase = 200,
        },
    },
    BonusRules = {},
}

local archetypes = {
    Marauder = {
        FactoryId = "Marauder",
        RewardKey = "MarauderReward",
        MaxHealthKey = "MarauderMaxHealth",
    },
    Elite = {
        FactoryId = "Elite",
        RewardKey = "EliteReward",
        MaxHealthKey = "EliteMaxHealth",
    },
}

local fake_catalog = {}
function fake_catalog.get_pack(
    dungeon_id: string,
    pack_id: string
): any?
    if dungeon_id == "TestDungeon"
        and pack_id == "SyntheticMixed"
    then
        return pack
    end
    return nil
end

function fake_catalog.get_enemy_archetype(
    archetype_id: string
): any?
    return archetypes[archetype_id]
end

function fake_catalog.resolve_pack_entries(
    selected_pack: any,
    _instance_state: any?
): {any}
    return {
        {
            Entry = selected_pack.Entries[1],
            Count = 2,
        },
        {
            Entry = selected_pack.Entries[2],
            Count = 1,
        },
    }
end

local environment = {}
function environment:enemy_spawn_cframes(
    room_id: string
): {CFrame}
    check(room_id == "Room1", "Environment room ID mismatch.")
    return {
        CFrame.new(1, 0, 0),
        CFrame.new(2, 0, 0),
        CFrame.new(3, 0, 0),
    }
end

local parent = Instance.new("Folder")
local context = {
    DungeonDefinition = {
        Id = "TestDungeon",
        MarauderReward = {
            XP = 10,
            GoldMin = 2,
            GoldMax = 4,
            BestiaryCreatureId = "marauder",
        },
        EliteReward = {
            XP = 20,
            GoldMin = 5,
            GoldMax = 8,
            BestiaryCreatureId = "elite",
        },
        MarauderMaxHealth = 40,
        EliteMaxHealth = 80,
    },

    Tuning = {
        EnemyHealthMultiplier = 1.5,
        EnemyDamageMultiplier = 1.2,
        MonsterRewardMultiplier = 1.5,
    },
    InstanceState = {},
    Environment = environment,
    EnemiesFolder = parent,
}

local executor = Executor.new({
    enemy_factory_registry = fake_registry,
    spawn_catalog = fake_catalog,
})

local encounter = {
    Id = "MixedPackEncounter",
    Kind = "Combat",
    PackId = "SyntheticMixed",
}
local binding = {
    RuntimeEncounterId = "MixedPackEncounter",
    EnvironmentRoomId = "Room1",
}

check(
    executor:validate(encounter, binding, context).ok == true,
    "Synthetic heterogeneous pack must validate."
)

local executed = executor:execute(
    encounter,
    binding,
    context
)
check(executed.ok == true, "Heterogeneous pack must execute.")
check(#executed.Enemies == 3, "Pack must return all three enemies.")
check(#factory_calls == 3, "All entry factories must be called.")
check(
    factory_calls[1].FactoryId == "Marauder"
        and factory_calls[2].FactoryId == "Marauder"
        and factory_calls[3].FactoryId == "Elite",
    "Pack entry order must remain deterministic."
)
check(
    factory_calls[1].Options.Name == "Mixed_Marauder_1"
        and factory_calls[3].Options.Name == "Mixed_Elite_1",
    "Each entry must own its enemy naming."
)
check(
    factory_calls[1].Options.SpawnIndex == 101
        and factory_calls[3].Options.SpawnIndex == 201,
    "Each entry must own its spawn-index range."
)
check(
    factory_calls[1].Options.RewardXP == 15
        and factory_calls[3].Options.RewardXP == 30,
    "Each archetype reward must use difficulty scaling."
)

check(
    factory_calls[1].Options.HealthMultiplier == 1.5
        and factory_calls[3].Options.DamageMultiplier == 1.2,
    "Combat scaling must apply across archetypes."
)

local failing_parent = Instance.new("Folder")
local failing_elite = {}
function failing_elite.create(_options: any): Model
    error("synthetic elite factory failure")
end

local failing_registry = {}
function failing_registry:get(factory_id: string): any?
    if factory_id == "Marauder" then
        return marauder_factory
    end
    if factory_id == "Elite" then
        return failing_elite
    end
    return nil
end

local failing_executor = Executor.new({
    enemy_factory_registry = failing_registry,
    spawn_catalog = fake_catalog,
})
local failing_context = table.clone(context)
failing_context.EnemiesFolder = failing_parent

local failed = failing_executor:execute(
    encounter,
    binding,
    failing_context
)
check(
    failed.reason == "EnemyFactoryExecutionFailed",
    "One entry factory failure must fail the whole pack."
)
check(
    #failing_parent:GetChildren() == 0,
    "Partial heterogeneous pack failure must clean prior spawns."
)

local missing_registry = {}
function missing_registry:get(factory_id: string): any?
    if factory_id == "Marauder" then
        return marauder_factory
    end
    return nil
end

local missing_executor = Executor.new({
    enemy_factory_registry = missing_registry,
    spawn_catalog = fake_catalog,
})
check(
    missing_executor:validate(
        encounter,
        binding,
        context
    ).reason == "EnemyFactoryNotRegistered",
    "Missing entry factories must fail validation."
)

check(
    executor:validate(
        {
            Id = "MissingPack",
            Kind = "Combat",
            PackId = "UnknownPack",
        },
        binding,
        context
    ).reason == "EncounterPackMissing",
    "Unknown combat packs must fail closed."
)

failing_parent:Destroy()
parent:Destroy()

print(string.format(
    "[Combat Pack Encounter Executor Tests] PASS: %d assertions.",
    assertion_count
))
