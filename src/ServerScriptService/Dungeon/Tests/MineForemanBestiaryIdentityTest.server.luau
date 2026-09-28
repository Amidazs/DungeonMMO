--!strict
-- Corrupted Foreman boss-spec Bestiary override through BossEncounterExecutor.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local Dungeon = ServerScriptService.Dungeon

local DungeonDefinitions = require(Shared.DungeonDefinitions)
local BossEncounterExecutor = require(
    Dungeon.BossEncounterExecutor
)

local checks = 0

--[[
Counts one Mine boss identity assertion.

Args:
    condition (boolean): Expected executor or identity result.
    label (string): Diagnostic failure context.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[Mine Foreman Bestiary Identity] " .. label
    )
end

--[[
Runs the real boss executor around a disposable Foreman factory.

Args:
    None.

Returns:
    nil: Prints a stable marker after the identity override succeeds.
]]
local function main()
    check(
        DungeonDefinitions.ABANDONED_MINE
            .MarauderCaptainReward.BestiaryCreatureId
            == "marauder_captain",
        "legacy shared reward bucket remains unchanged"
    )

    local captured_options = nil
    local factory = {}

    function factory.create(options: any): Model
        captured_options = options

        local model = Instance.new("Model")
        model.Name = "TEMP_CorruptedForemanIdentity"
        model.Parent = options.Parent

        local humanoid = Instance.new("Humanoid")
        humanoid.Parent = model
        return model
    end

    local registry = {}

    function registry:get(factory_id: string): any?
        if factory_id == "CorruptedForeman" then
            return factory
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

    local holder = Instance.new("Folder")
    holder.Name = "TEMP_MineForemanBestiaryIdentity"
    holder.Parent = workspace

    local enemies = Instance.new("Folder")
    enemies.Name = "Enemies"
    enemies.Parent = holder

    local runtime_root = Instance.new("Folder")
    runtime_root.Name = "Runtime"
    runtime_root.Parent = holder

    local spawn = Instance.new("Part")
    spawn.Name = "ForemanSpawn"
    spawn.Anchored = true
    spawn.CFrame = CFrame.new(0, 1200, 0)
    spawn.Parent = holder

    local environment = {}

    function environment:get(anchor_id: string): BasePart?
        if anchor_id == "Mine.Room3.ForemanSpawn" then
            return spawn
        end
        return nil
    end

    local executor = BossEncounterExecutor.new({
        boss_factory_registry = registry,
        boss_spawn_guard = guard,
    })

    local result = executor:execute(
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
            EnemiesFolder = enemies,
            RuntimeRoot = runtime_root,
            SessionId = "mine-identity-test",
            DungeonDefinition =
                DungeonDefinitions.ABANDONED_MINE,
            Tuning = {
                MonsterRewardMultiplier = 1,
                EnemyHealthMultiplier = 1,
                EnemyDamageMultiplier = 1,
            },
        }
    )

    check(result.ok == true, "registered Mine boss executes")
    check(
        captured_options ~= nil
            and captured_options.BestiaryCreatureId
                == "corrupted_foreman",
        "boss spec overrides the generic reward bestiary identity"
    )
    check(
        captured_options.RewardXP == 45
            and captured_options.RewardGoldMin == 16
            and captured_options.RewardGoldMax == 27,
        "identity override preserves Mine reward tuning"
    )
    check(
        captured_options.BossRole == "Boss",
        "normal Mine boss role remains unchanged"
    )

    holder:Destroy()

    print(
        ("[Mine Foreman Bestiary Identity] PASS: %d assertions")
            :format(checks)
    )
end

main()
