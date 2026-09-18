--!strict
local ServerScriptService = game:GetService("ServerScriptService")

local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local Bootstrap = require(
    Dungeon:WaitForChild("DungeonEncounterExecutionBootstrap")
)

local assertion_count = 0
local function check(condition: boolean, message: string)
    assertion_count += 1
    if not condition then
        error(
            "[Dungeon Encounter Execution Bootstrap Tests] "
                .. message,
            2
        )
    end
end

local registry = Bootstrap.create()
local enemies = Instance.new("Folder")
local runtime_root = Instance.new("Folder")

local environment: any = {}
function environment:enemy_spawn_cframes(_room_id: string): {CFrame}
    return {
        CFrame.new(),
        CFrame.new(2, 0, 0),
        CFrame.new(4, 0, 0),
    }
end
local boss_spawn_anchor = Instance.new("Part")
boss_spawn_anchor.CFrame = CFrame.new()

function environment:get(anchor_id: string): BasePart?
    if anchor_id == "Synthetic.BossSpawn" then
        return boss_spawn_anchor
    end
    return nil
end

local context = {
    DungeonDefinition = {
        Id = "TestDungeon",
        StandardMarauderReward = {
            XP = 10,
            GoldMin = 2,
            GoldMax = 3,
            BestiaryCreatureId = "marauder",
        },
        MarauderCaptainReward = {
            XP = 30,
            GoldMin = 10,
            GoldMax = 15,
            BestiaryCreatureId = "marauder_captain",
        },
        StandardMarauderMaxHealth = 40,
    },
    Tuning = {
        EnemyHealthMultiplier = 1,
        EnemyDamageMultiplier = 1,
        MonsterRewardMultiplier = 1,
    },
    InstanceState = {},
    Environment = environment,
    EnemiesFolder = enemies,
    RuntimeRoot = runtime_root,
    SessionId = "bootstrap-test",
}

check(
    registry:validate(
        {
            Id = "CombatRoom1",
            Kind = "Combat",
            ExecutorId = "CombatPack",
            PackId = "StandardRoom1",
        },
        {
            RuntimeEncounterId = "CombatRoom1",
            EnvironmentRoomId = "Room1",
        },
        context
    ).ok == true,
    "Built-in CombatPack executor must validate."
)

check(
    registry:validate(
        {
            Id = "Depth1Boss",
            Kind = "Boss",
            ExecutorId = "Boss",
            BossId = "MarauderCaptain",
        },
        {
            RuntimeEncounterId = "MarauderCaptain",
            BossSpawnAnchor = "Synthetic.BossSpawn",
        },
        context
    ).ok == true,
    "Built-in MarauderCaptain boss content must validate."
)

check(
    registry:validate(
        {
            Id = "MineBoss",
            Kind = "Boss",
            ExecutorId = "Boss",
            BossId = "CorruptedForeman",
        },
        {
            RuntimeEncounterId = "MarauderCaptain",
            BossSpawnAnchor = "Synthetic.BossSpawn",
        },
        context
    ).ok == true,
    "Built-in CorruptedForeman boss content must validate."
)

check(
    registry:validate(
        {
            Id = "FutureEventBoss",
            Kind = "EventBoss",
            ExecutorId = "Boss",
            BossId = "FestivalChampion",
        },
        {
            RuntimeEncounterId = "FestivalChampion",
        },
        context
    ).reason == "BossContentNotRegistered",
    "Unimplemented Event Boss content must fail closed."
)

boss_spawn_anchor:Destroy()
runtime_root:Destroy()
enemies:Destroy()

print(string.format(
    "[Dungeon Encounter Execution Bootstrap Tests] PASS: %d assertions.",
    assertion_count
))
