--!strict
-- Reused implemented factories must not reuse the same monster reward
-- transaction when an optional boss returns as a required miniboss.
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Dungeon = SSS.Dungeon
local Core = SSS.Core
local Shared = RS.Core.Shared
local Definitions = require(Shared.DungeonDefinitions)
local Variants = require(Shared.DungeonOptionalBossVariantCatalog)
local BossExecutor = require(Dungeon.BossEncounterExecutor)
local Encounter = require(Dungeon.EncounterService)
local Profiles = require(Core.Services.ProfileService)
local Adapter = require(Core.Adapters.InMemoryProfileAdapter)
local Progression = require(Core.Services.ProgressionService)
local Inventory = require(Core.Services.InventoryService)
local Rewards = require(Core.Services.RewardService)

local count = 0
local function check(ok: boolean, message: string)
    count += 1
    assert(ok, "[Optional Variant Reward Identity] " .. message)
end
local rng = {
    NextNumber = function(_, min) return min end,
    NextInteger = function(_, min) return min end,
}
for _, dungeon_id in ipairs({"TestDungeon", "AbandonedMine"}) do
    local profiles_adapter = Adapter.new()
    local profiles = Profiles.new(profiles_adapter)
    local user_id = if dungeon_id == "TestDungeon" then 98271 else 98272
    check(profiles:load(user_id), "disposable profile must load")
    local rewards = Rewards.new(
        profiles, Progression.new(profiles), Inventory.new(profiles),
        nil, rng, function() return 100 end)
    local registry = {
        get = function(_, factory_id)
            local factory = Dungeon:FindFirstChild(
                factory_id .. "Factory")
            return if factory then require(factory) else nil
        end,
    }
    local executor = BossExecutor.new({
        boss_factory_registry = registry,
    })
    local runtime_root = Instance.new("Folder")
    runtime_root.Name = "OptionalVariantRewardFixture"
    local enemies = Instance.new("Folder")
    enemies.Parent = runtime_root
    local boss_spawn = Instance.new("Part")
    boss_spawn.Parent = runtime_root
    boss_spawn.Anchored = true
    boss_spawn.Position = Vector3.new(0, 5, 0)
    local session_id = "variant-reward-" .. dungeon_id
    local context = {
        DungeonDefinition = assert(Definitions.get(dungeon_id)),
        Tuning = {
            EnemyHealthMultiplier = 1,
            EnemyDamageMultiplier = 1,
            MonsterRewardMultiplier = 1,
        },
        Environment = {get = function() return boss_spawn end},
        EnemiesFolder = enemies,
        RuntimeRoot = runtime_root,
        SessionId = session_id,
    }
    local event = assert(Variants.get(dungeon_id, "Event", 2))
    local secret = assert(Variants.get(dungeon_id, "Secret", 2))
    local scenarios = {
        {Id = event.BossId .. "Encounter", BossId = event.BossId,
            Kind = "EventBoss"},
        {Id = "Depth4MiniBoss2", BossId = event.BossId,
            Kind = "MiniBoss"},
        {Id = secret.BossId .. "Encounter", BossId = secret.BossId,
            Kind = "SecretBoss"},
        {Id = "Depth4MiniBoss3", BossId = secret.BossId,
            Kind = "MiniBoss"},
    }
    local owned = Encounter.new(rewards, session_id)
    local keys = {}
    for _, descriptor in ipairs(scenarios) do
        local binding = {
            RuntimeEncounterId = descriptor.Id,
            BossSpawnAnchor = "Fixture.BossSpawn",
        }
        local spawn = executor:execute(descriptor, binding, context)
        check(spawn.ok and spawn.BossModel ~= nil,
            "registered placeholder boss must spawn")
        local boss = spawn.BossModel
        check(boss:GetAttribute("BossId") == descriptor.BossId,
            "reused factory retains the selected boss identity")
        local enemy_id = boss:GetAttribute("DungeonEnemyId")
        check(enemy_id == descriptor.BossId .. ":" .. descriptor.Id,
            "optional and miniboss rewards need encounter-scoped ID")
        local transaction = session_id .. ":" .. enemy_id .. ":Life1"
        check(not keys[transaction], "no variant reward collision")
        keys[transaction] = true
        check(owned:start(descriptor.Id, {user_id}, {boss}).ok,
            "only registered boss begins reward encounter")
        local granted = owned:on_enemy_died(boss)
        check(granted.ok and granted.cleared,
            "selected boss reward must be issued once")
        check(owned:on_enemy_died(boss).already_processed == true,
            "duplicate death cannot issue a second reward")
        check(profiles:get_character(user_id, 1)
            .RewardHistory.Monster[transaction] ~= nil,
            "each encounter saves its distinct reward receipt")
        executor:cleanup(descriptor, binding, spawn, context)
    end
    local before = profiles:get_character(user_id, 1)
    local old_gold = before.Gold
    check(profiles:save(user_id, "OptionalVariantRewardTest"),
        "per-member monster reward history must persist")
    local loaded = Profiles.new(profiles_adapter)
    check(loaded:load(user_id), "saved profile can be reconstructed")
    local replay = Rewards.new(
        loaded, Progression.new(loaded), Inventory.new(loaded),
        nil, rng, function() return 101 end)
    local replayed = 0
    for transaction in pairs(keys) do
        local retry = replay:grant_monster_reward(
            {user_id}, {XP = 40, GoldMin = 0, GoldMax = 0},
            transaction)
        check(retry.ok and retry.already_applied,
            "persisted reward must reject second application")
        replayed += 1
    end
    local after = loaded:get_character(user_id, 1)
    local receipt_count = 0
    for _ in pairs(after.RewardHistory.Monster) do
        receipt_count += 1
    end
    check(replayed == 4 and receipt_count == 4
        and after.Gold == old_gold,
        "repeated same-factory bosses must earn four distinct, once-only rewards")
    boss_spawn:Destroy()
    runtime_root:Destroy()
end
print(string.format(
    "[Optional Variant Reward Identity Tests] PASS: %d assertions.",
    count
))
