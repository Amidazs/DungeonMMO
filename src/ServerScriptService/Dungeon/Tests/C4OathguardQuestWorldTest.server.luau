--!strict
-- The Warrior's independent quest enemies must exist only at owned stages.
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Spawns = require(SSS.Dungeon.C4QuestEncounterSpawns)
local Ledger = require(SSS.Dungeon.C4QuestMonsterCombatLedger)
local Source = require(RS.Core.Shared.C4OriginalFirstTransferQuestStages)

local USER_ID = 837933
local CHECKS = 0

--[[
Checks physical enemy registration and correct branch/stage authority.

Args:
    condition (boolean): Actual physical world or ledger observation.
    message (string): Failure explanation.

Returns:
    nil: Counts verified stage-specific tests.
]]
local function check(condition: boolean, message: string)
    CHECKS += 1
    assert(condition, "[Oathguard World] " .. message)
end

--[[
Creates real disposable Roblox models through the injected enemy factory.

Args:
    options (any): Server-authored canonical dungeon enemy properties.

Returns:
    Model: Workspace-owned unique source quest enemy life.
]]
local function mock_enemy(options: any): Model
    local model = Instance.new("Model")
    model.Name = options.Name
    model:SetAttribute("DungeonEncounterId", options.EncounterId)
    model:SetAttribute("DungeonEnemyId", options.EnemyId)
    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.CFrame = options.SpawnCFrame
    root.Anchored = true
    root.Parent = model
    model.PrimaryPart = root
    Instance.new("Humanoid").Parent = model
    model.Parent = options.Parent
    return model
end

--[[
Sets up exactly one authentic selected Human Warrior quest stage.

Args:
    stage (number): Three for striker, five for boss.

Returns:
    any: Mutable test-only character for the real branch selector.
]]
local function selected_owner(stage: number): any
    return {
        Level = 18,
        Identity = {
            ClassId = "Fighter", BaseClassId = "Fighter",
            RaceId = "Human",
        },
        ClassAdvancement = {
            OriginalFirstTransferChoiceId = "HumanKnight",
            OriginalFirstTransferQuest = {
                BranchId = "HumanKnight",
                Step = stage, Ready = false,
            },
        },
    }
end

--[[
Spawns a real unique Warrior challenge and checks the exact ledger stage.

Args:
    profiles (any): Selected owner test profile with current stage.
    ledger (any): Current encounter's genuine quest combat authority.
    folder (Folder): Physical workspace test encounter container.
    stage (number): Current stage of the original source quest.
    expected_id (string): Exactly allowed original monster identifier.
    expected_count (number): Two ordinary strikers or one unique boss.

Returns:
    nil: Verifies challenge is attached only to the current quest step.
]]
local function check_stage(
    profiles: any, ledger: any, folder: Folder,
    stage: number, expected_id: string, expected_count: number
)
    local seed = mock_enemy({
        Name = "EncounterSeed",
        Parent = folder, EncounterId = "StonewatchRoom",
        EnemyId = "EncounterSeed", SpawnCFrame = CFrame.new(0, 20, 0),
    })
    local execution = {Enemies = {seed}}
    local spawned = Spawns.augment({
        profiles = profiles, user_ids = {USER_ID},
        encounter_id = "StonewatchRoom",
        execution = execution, folder = folder,
    }, {create = mock_enemy})
    check(spawned.ok and #spawned.registrations == expected_count,
        "Only required personally eligible branch/stage monsters appear")
    for _, registration in ipairs(spawned.registrations) do
        local enemy = registration.enemy
        check(registration.branch_id == "HumanKnight"
            and registration.step_index == stage
            and enemy:GetAttribute("SourceQuestMonsterId")
                == expected_id,
            "Original monster name, branch and stage are server-owned")
        check(ledger:register_enemy(
            enemy, registration.branch_id,
            "StonewatchRoom", registration.step_index
        ), "Actual physical enemy has a unique registered combat life")
    end
    local quest = assert(Source.get("HumanKnight"))
    check(ledger:available(quest, stage),
        "The exact owned stage is available through the correct ledger")
    for _, model in ipairs(execution.Enemies) do
        model:Destroy()
    end
    ledger:clear()
end

--[[
Tests actual physical striker and boss spawn/ledger stage restrictions.

Args:
    None.

Returns:
    nil: Passes only with unique source enemy and boss world bindings.
]]
local function main()
    local owner = selected_owner(3)
    local profiles = {
        get_character = function(
            _self: any, user_id: number
        ): any
            return if user_id == USER_ID then owner else nil
        end,
    }
    local folder = Instance.new("Folder")
    folder.Name = "OathguardQuestWorld_TEMP"
    folder.Parent = workspace
    local ledger = Ledger.new({
        profiles = profiles, session_id = "StonewatchWorldTest",
        is_member_active = function(): boolean
            return false
        end,
    })
    check_stage(profiles, ledger, folder, 3, "GloamStriker", 2)
    owner.ClassAdvancement.OriginalFirstTransferQuest.Step = 5
    ledger:attach_scout_actor({
        verify = function(): boolean return false end,
        available = function(): boolean return false end,
        clear = function() end,
    })
    check_stage(profiles, ledger, folder, 5, "GloamBulwark", 1)
    owner.ClassAdvancement.OriginalFirstTransferQuest.Step = 6
    local none = Spawns.augment({
        profiles = profiles, user_ids = {USER_ID},
        encounter_id = "StonewatchRoom", folder = folder,
        execution = {Enemies = {mock_enemy({
            Name = "Seed", Parent = folder,
            EncounterId = "StonewatchRoom", EnemyId = "Seed",
            SpawnCFrame = CFrame.new(0, 20, 0),
        })}},
    }, {create = mock_enemy})
    check(none.ok and #none.registrations == 0,
        "Completed Warrior combat stages spawn no repeatable quest enemy")
    folder:Destroy()
    print(("[Oathguard World] PASS: %d assertions"):format(CHECKS))
end

main()
