--!strict
-- Real two-dungeon boss hunt through trusted EnemyDefeat integration.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local Core = ServerScriptService.Core
local Dungeon = ServerScriptService.Dungeon

local DungeonDefinitions = require(Shared.DungeonDefinitions)
local Adapter = require(Core.Adapters.InMemoryProfileAdapter)
local Profiles = require(Core.Services.ProfileService)
local Quests = require(Core.Services.QuestService)
local EncounterService = require(Dungeon.EncounterService)
local BossEncounterExecutor = require(Dungeon.BossEncounterExecutor)
local MarauderCaptainFactory = require(
    Dungeon.MarauderCaptainFactory
)
local MineForemanFactory = require(
    Dungeon.MineForemanFactory
)

local USER_ID = 968501
local checks = 0

--[[
Counts one dual-boss integration assertion.

Args:
    condition (boolean): Expected authoritative integration result.
    label (string): Diagnostic failure context.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[Dungeon Boss Hunt Integration] " .. label
    )
end

--[[
Installs one launch-valid level-fifteen Dark Elf with Mine Echoes completed.

Args:
    profiles (any): Loaded authoritative profile service.

Returns:
    nil: Mutates only the disposable in-memory character.
]]
local function install_character(profiles: any)
    check(
        profiles:mutate(USER_ID, function(profile: any)
            local character = profile.Characters.Slot1
            character.Level = 15
            character.Identity = {
                Version = 1,
                RaceId = "DarkElf",
                BaseClassId = "Fighter",
                ClassId = "Fighter",
                CreationStage = "Complete",
            }
            character.Quests.Completed.WorldrootRelic = true
            character.Quests.Completed.MineEchoes = true
        end),
        "level-fifteen Dark Elf prerequisite state persists"
    )
end

--[[
Creates one real released Marauder Captain model.

Args:
    parent (Instance): Disposable enemy parent.

Returns:
    Model: Real Captain model with trusted quest identity.
]]
local function create_captain(parent: Instance): Model
    local reward =
        DungeonDefinitions.TEST_DUNGEON.MarauderCaptainReward

    return MarauderCaptainFactory.create({
        Parent = parent,
        SpawnCFrame = CFrame.new(-8, 2400, 0),
        EncounterId = "BossHuntCaptain",
        RewardXP = reward.XP,
        RewardGoldMin = reward.GoldMin,
        RewardGoldMax = reward.GoldMax,
        BestiaryCreatureId = reward.BestiaryCreatureId,
    })
end

--[[
Creates one real released Corrupted Foreman through BossEncounterExecutor.

Args:
    parent (Instance): Disposable enemy parent.

Returns:
    Model: Executor-created Foreman with corrected Bestiary identity.
]]
local function create_foreman(parent: Instance): Model
    local registry = {}

    function registry:get(factory_id: string): any?
        if factory_id == "CorruptedForeman" then
            return MineForemanFactory
        end
        return nil
    end

    local guard = {}

    function guard.claim(
        _runtime_root: Instance,
        _session_id: string,
        _encounter_id: string
    ): boolean
        return true
    end

    function guard.release(
        _runtime_root: Instance,
        _session_id: string,
        _encounter_id: string
    ): boolean
        return true
    end

    local spawn = Instance.new("Part")
    spawn.Name = "ForemanSpawn"
    spawn.Anchored = true
    spawn.CFrame = CFrame.new(8, 2400, 0)
    spawn.Parent = parent

    local environment = {}

    function environment:get(anchor_id: string): BasePart?
        if anchor_id == "Mine.Room3.ForemanSpawn" then
            return spawn
        end
        return nil
    end

    local runtime_root = Instance.new("Folder")
    runtime_root.Name = "Runtime"
    runtime_root.Parent = parent

    local executor = BossEncounterExecutor.new({
        boss_factory_registry = registry,
        boss_spawn_guard = guard,
    })

    local execution = executor:execute(
        {
            Id = "MineDepth1Boss",
            Kind = "Boss",
            BossId = "CorruptedForeman",
        },
        {
            RuntimeEncounterId = "BossHuntForeman",
            BossSpawnAnchor = "Mine.Room3.ForemanSpawn",
        },
        {
            Environment = environment,
            EnemiesFolder = parent,
            RuntimeRoot = runtime_root,
            SessionId = "boss-hunt-foreman",
            DungeonDefinition =
                DungeonDefinitions.ABANDONED_MINE,
            Tuning = {
                MonsterRewardMultiplier = 1,
                EnemyHealthMultiplier = 1,
                EnemyDamageMultiplier = 1,
            },
        }
    )

    check(execution.ok == true, "real Foreman executor path succeeds")
    return assert(execution.BossModel)
end

--[[
Creates the reward adapter shared by both released boss encounters.

Args:
    None.

Returns:
    any: Reward stub that still verifies authoritative member ownership.
    () -> number: Reader for successful monster reward call count.
]]
local function reward_adapter(): (any, () -> number)
    local reward_calls = 0
    local rewards = {}

    function rewards:grant_monster_reward(
        member_user_ids: {number},
        _reward: any,
        _transaction_id: string
    ): any
        reward_calls += 1
        check(
            #member_user_ids == 1
                and member_user_ids[1] == USER_ID,
            "boss reward and quest credit share active member"
        )
        return {
            ok = true,
            member_results = {},
        }
    end

    return rewards, function(): number
        return reward_calls
    end
end

--[[
Runs the level-fifteen dual-boss Adventure across both released dungeons.

Args:
    None.

Returns:
    nil: Prints a stable marker after both trusted boss events and reward pass.
]]
local function main()
    local profiles = Profiles.new(Adapter.new())
    check(profiles:load(USER_ID), "profile loads")
    install_character(profiles)

    local quests = Quests.new(profiles)
    check(
        quests:start(USER_ID, "DungeonBossHunt").ok,
        "level-fifteen player starts dual boss Adventure"
    )

    local holder = Instance.new("Folder")
    holder.Name = "TEMP_DungeonBossHunt"
    holder.Parent = workspace

    local rewards, reward_count = reward_adapter()

    local captain = create_captain(holder)
    check(
        captain:GetAttribute("BestiaryCreatureId")
            == "marauder_captain",
        "real Captain exposes trusted quest identity"
    )

    local captain_encounter = EncounterService.new(
        rewards,
        "boss-hunt-captain",
        nil,
        quests
    )
    check(
        captain_encounter:start(
            "BossHuntCaptain",
            {USER_ID},
            {captain}
        ).ok,
        "Captain encounter starts"
    )
    check(
        captain_encounter:on_enemy_died(captain).ok,
        "Captain defeat progresses first objective"
    )
    check(
        quests:claim_reward(USER_ID, "DungeonBossHunt").reason
            == "QuestNotReady",
        "one boss alone cannot complete dual boss Adventure"
    )

    local foreman = create_foreman(holder)
    check(
        foreman:GetAttribute("BestiaryCreatureId")
            == "corrupted_foreman",
        "real Foreman exposes corrected trusted quest identity"
    )

    local foreman_encounter = EncounterService.new(
        rewards,
        "boss-hunt-foreman",
        nil,
        quests
    )
    check(
        foreman_encounter:start(
            "BossHuntForeman",
            {USER_ID},
            {foreman}
        ).ok,
        "Foreman encounter starts"
    )
    check(
        foreman_encounter:on_enemy_died(foreman).ok,
        "Foreman defeat progresses second objective"
    )

    local claim = quests:claim_reward(
        USER_ID,
        "DungeonBossHunt"
    )
    check(
        claim.ok == true
            and claim.gold_granted == 120
            and #claim.items_granted == 0,
        "both bosses unlock exact 120-Gold reward"
    )
    check(
        profiles:get_character(USER_ID, 1).Gold == 120,
        "dual boss reward commits to authoritative character"
    )
    check(
        reward_count() == 2,
        "exactly one monster reward transaction occurs per boss"
    )

    check(
        quests:start(
            USER_ID,
            "ExpeditionProvisioning"
        ).ok,
        "dual boss Adventure does not block Provisioning"
    )

    holder:Destroy()

    print(
        ("[Dungeon Boss Hunt Integration] PASS: %d assertions")
            :format(checks)
    )
end

main()
