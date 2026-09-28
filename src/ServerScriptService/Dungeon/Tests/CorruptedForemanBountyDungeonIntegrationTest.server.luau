--!strict
-- Real Mine Foreman executor -> EncounterService -> QuestService bounty flow.

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
local MineForemanFactory = require(Dungeon.MineForemanFactory)

local USER_ID = 968401
local checks = 0

--[[
Counts one Foreman bounty integration assertion.

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
        "[Corrupted Foreman Bounty Dungeon Integration] "
            .. label
    )
end

--[[
Installs one launch-valid level-ten Dark Elf with Mine Echoes completed.

Args:
    profiles (any): Loaded authoritative profile service.

Returns:
    nil: Mutates only the disposable in-memory character.
]]
local function install_character(profiles: any)
    check(
        profiles:mutate(USER_ID, function(profile: any)
            local character = profile.Characters.Slot1
            character.Level = 10
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
        "level-ten Dark Elf Mine prerequisite state persists"
    )
end

--[[
Creates the real released Foreman through the boss executor.

Args:
    parent (Instance): Disposable enemy parent.
    spawn (BasePart): Reviewed Mine boss spawn anchor.

Returns:
    Model: Real Corrupted Foreman model with executor-owned identity.
]]
local function create_foreman(
    parent: Instance,
    spawn: BasePart
): Model
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
            RuntimeEncounterId = "CorruptedForeman",
            BossSpawnAnchor = "Mine.Room3.ForemanSpawn",
        },
        {
            Environment = environment,
            EnemiesFolder = parent,
            RuntimeRoot = runtime_root,
            SessionId = "foreman-bounty-executor",
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
Runs the released Mine boss bounty through real quest and encounter services.

Args:
    None.

Returns:
    nil: Prints a stable marker after reward and replay checks pass.
]]
local function main()
    local profiles = Profiles.new(Adapter.new())
    check(profiles:load(USER_ID), "profile loads")
    install_character(profiles)

    local quests = Quests.new(profiles)
    check(
        quests:start(
            USER_ID,
            "CorruptedForemanBounty"
        ).ok,
        "level-ten player starts Foreman bounty"
    )

    local rewards = {}
    local reward_calls = 0

    function rewards:grant_monster_reward(
        member_user_ids: {number},
        _reward: any,
        _transaction_id: string
    ): any
        reward_calls += 1
        check(
            #member_user_ids == 1
                and member_user_ids[1] == USER_ID,
            "Foreman reward and quest credit share active member"
        )
        return {
            ok = true,
            member_results = {},
        }
    end

    local holder = Instance.new("Folder")
    holder.Name = "TEMP_CorruptedForemanBounty"
    holder.Parent = workspace

    local spawn = Instance.new("Part")
    spawn.Name = "ForemanSpawn"
    spawn.Anchored = true
    spawn.CFrame = CFrame.new(0, 2200, 0)
    spawn.Parent = holder

    local foreman = create_foreman(holder, spawn)

    check(
        foreman:GetAttribute("BossId") == "CorruptedForeman"
            and foreman:GetAttribute("BestiaryCreatureId")
                == "corrupted_foreman",
        "released executor exposes exact Foreman quest identity"
    )

    local encounters = EncounterService.new(
        rewards,
        "foreman-bounty-integration",
        nil,
        quests
    )
    check(
        encounters:start(
            "CorruptedForemanBounty",
            {USER_ID},
            {foreman}
        ).ok,
        "real Foreman encounter starts"
    )

    local defeated = encounters:on_enemy_died(foreman)
    check(
        defeated.ok == true
            and defeated.cleared == true,
        "rewarded Foreman death clears encounter and progresses quest"
    )

    local claim = quests:claim_reward(
        USER_ID,
        "CorruptedForemanBounty"
    )
    check(
        claim.ok == true
            and claim.gold_granted == 80
            and #claim.items_granted == 0,
        "real Foreman death unlocks exact Gold-only bounty reward"
    )
    check(
        profiles:get_character(USER_ID, 1).Gold == 80,
        "Foreman bounty Gold commits to authoritative character"
    )
    check(
        reward_calls == 1,
        "Foreman life receives exactly one monster reward transaction"
    )

    local duplicate = encounters:on_enemy_died(foreman)
    check(
        duplicate.ok == true
            and duplicate.already_processed == true
            and reward_calls == 1,
        "duplicate Foreman death cannot duplicate reward or quest credit"
    )
    check(
        quests:claim_reward(
            USER_ID,
            "CorruptedForemanBounty"
        ).reason == "QuestAlreadyCompleted",
        "completed Foreman bounty cannot pay twice"
    )

    check(
        quests:start(
            USER_ID,
            "ExpeditionProvisioning"
        ).ok,
        "optional Foreman bounty does not block Provisioning"
    )

    holder:Destroy()

    print(
        ("[Corrupted Foreman Bounty Dungeon Integration] PASS: %d assertions")
            :format(checks)
    )
end

main()
