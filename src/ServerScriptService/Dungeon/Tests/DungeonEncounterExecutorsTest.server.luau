--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")

local pack_module = Dungeon:FindFirstChild(
    "MarauderPackEncounterExecutor"
)
local boss_module = Dungeon:FindFirstChild(
    "BossEncounterExecutor"
)
if not pack_module or not boss_module then
    error(
        "[Dungeon Encounter Executors Tests] RED: "
            .. "encounter executor modules are missing."
    )
end

local PackExecutor = require(pack_module)
local BossExecutor = require(boss_module)

local assertion_count = 0

local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Encounter Executors Tests] " .. message,
            2
        )
    end
end

local parent = Instance.new("Folder")
local pack_calls = {}
local fake_marauder_factory = {}

function fake_marauder_factory.create(options: any): Model
    local model = Instance.new("Model")
    model.Name = options.Name
    model:SetAttribute("SpawnIndex", options.SpawnIndex)
    model:SetAttribute("RewardXP", options.RewardXP)
    model.Parent = options.Parent
    table.insert(pack_calls, options)
    return model
end

local fake_environment = {}

function fake_environment:enemy_spawn_cframes(
    room_id: string
): {CFrame}
    check(room_id == "Room1", "Pack room ID mismatch.")
    return {
        CFrame.new(1, 0, 0),
        CFrame.new(2, 0, 0),
        CFrame.new(3, 0, 0),
    }
end

function fake_environment:captain_spawn_cframe(): CFrame
    return CFrame.new(9, 0, 0)
end

local context = {
    DungeonDefinition = {
        Id = "TestDungeon",
        StandardMarauderReward = {
            XP = 10,
            GoldMin = 3,
            GoldMax = 6,
            BestiaryCreatureId = "marauder",
        },
        MarauderCaptainReward = {
            XP = 40,
            GoldMin = 15,
            GoldMax = 25,
            BestiaryCreatureId = "marauder_captain",
        },
        StandardMarauderMaxHealth = 40,
    },
    Tuning = {
        EnemyHealthMultiplier = 1.5,
        EnemyDamageMultiplier = 1.2,
        MonsterRewardMultiplier = 1.5,
    },
    InstanceState = {},
    Environment = fake_environment,
    EnemiesFolder = parent,
}

local pack_executor = PackExecutor.new({
    marauder_factory = fake_marauder_factory,
})

local pack_encounter = {
    Id = "CombatRoom1",
    Kind = "Combat",
    PackId = "StandardRoom1",
}
local pack_binding = {
    RuntimeEncounterId = "CombatRoom1",
    EnvironmentRoomId = "Room1",
}

check(
    pack_executor:validate(
        pack_encounter,
        pack_binding,
        context
    ).ok == true,
    "Known pack must validate."
)

local pack_result = pack_executor:execute(
    pack_encounter,
    pack_binding,
    context
)
check(pack_result.ok == true, "Known pack must execute.")
check(#pack_result.Enemies == 2, "Pack must spawn two enemies.")
check(#pack_calls == 2, "Factory must be called twice.")
check(
    pack_calls[1].RewardXP == 15,
    "Pack reward must use difficulty scaling."
)
check(
    pack_calls[1].HealthMultiplier == 1.5
        and pack_calls[1].DamageMultiplier == 1.2,
    "Pack must forward difficulty combat scaling."
)

check(
    pack_executor:validate(
        {
            Id = "MissingPack",
            Kind = "Combat",
            PackId = "NoSuchPack",
        },
        pack_binding,
        context
    ).reason == "EncounterPackMissing",
    "Unknown packs must fail closed."
)

local boss_calls = {}
local fake_boss_factory = {}

function fake_boss_factory.create(options: any): Model
    local model = Instance.new("Model")
    model.Name = "BossModel"
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = model
    model.Parent = options.Parent
    table.insert(boss_calls, options)
    return model
end

local fake_registry = {}

function fake_registry:get(boss_id: string): any?
    if boss_id == "MarauderCaptain" then
        return fake_boss_factory
    end
    return nil
end

local boss_executor = BossExecutor.new({
    boss_factory_registry = fake_registry,
})

local boss_encounter = {
    Id = "Depth1Boss",
    Kind = "Boss",
    BossId = "MarauderCaptain",
}
local boss_binding = {
    RuntimeEncounterId = "MarauderCaptain",
}

check(
    boss_executor:validate(
        boss_encounter,
        boss_binding,
        context
    ).ok == true,
    "Registered boss must validate."
)

local boss_result = boss_executor:execute(
    boss_encounter,
    boss_binding,
    context
)
check(boss_result.ok == true, "Registered boss must execute.")
check(#boss_result.Enemies == 1, "Boss execution must return one enemy.")
check(
    boss_result.BossModel ~= nil
        and boss_result.BossHumanoid ~= nil,
    "Boss execution must expose boss presentation handles."
)
check(
    boss_calls[1].BossRole == "Boss",
    "Boss role must come from encounter Kind."
)
check(
    boss_calls[1].RewardXP == 60,
    "Boss reward must use difficulty scaling."
)

check(
    boss_executor:validate(
        {
            Id = "FutureBoss",
            Kind = "FinalBoss",
            BossId = "TempleDepth4Boss",
        },
        boss_binding,
        context
    ).reason == "BossContentNotRegistered",
    "Unimplemented future boss must fail closed."
)

parent:Destroy()

print(string.format(
    "[Dungeon Encounter Executors Tests] PASS: %d assertions.",
    assertion_count
))
