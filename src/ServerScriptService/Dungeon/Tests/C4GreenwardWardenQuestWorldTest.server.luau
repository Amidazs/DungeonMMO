--!strict
-- Stage-specific physical Elven Knight encounter integration audit.
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Spawns = require(SSS.Dungeon.C4QuestEncounterSpawns)
local Ledger = require(SSS.Dungeon.C4QuestMonsterCombatLedger)
local Source = require(RS.Core.Shared.C4OriginalFirstTransferQuestStages)

local USER_ID = 837943
local ENCOUNTER_ID = "VerdantQuestRoom"
local checks = 0

--[[
Records one actual source-quest world registration or denial.

Args:
    valid (boolean): Expected physical enemy or stage contract.
    label (string): Diagnostic for the first failed assertion.

Returns:
    nil: Counts a passing check or raises on failure.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[Greenward Warden World] " .. label)
end

--[[
Creates an actual disposable Workspace enemy with a living Humanoid.

Args:
    options (any): Trusted spawn contract from the quest pack factory.

Returns:
    Model: Test-only physical monster with unique encounter identity.
]]
local function mock_enemy(options: any): Model
    local enemy = Instance.new("Model")
    enemy.Name = options.Name
    enemy:SetAttribute("DungeonEncounterId", options.EncounterId)
    enemy:SetAttribute("DungeonEnemyId", options.EnemyId)
    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Anchored = true
    root.CFrame = options.SpawnCFrame
    root.Parent = enemy
    enemy.PrimaryPart = root
    Instance.new("Humanoid").Parent = enemy
    enemy.Parent = options.Parent
    return enemy
end

--[[
Prepares one selected Elf Fighter with its exact quest kill stage.

Args:
    step (number): Ordered Elven Knight stage three, five or other.

Returns:
    any: Isolated owner data, without a class award or client receipt.
]]
local function selected_owner(step: number): any
    return {
        Level = 18,
        Identity = {
            ClassId = "Fighter", BaseClassId = "Fighter",
            RaceId = "Elf",
        },
        ClassAdvancement = {
            OriginalFirstTransferChoiceId = "ElvenKnight",
            OriginalFirstTransferQuest = {
                BranchId = "ElvenKnight", Step = step, Ready = false,
            },
        },
    }
end

--[[
Checks stage-specific physical registrations inside the existing pack.

Args:
    profiles (any): Isolated live selected Elf Fighter query.
    ledger (any): Actual encounter-scoped quest kill ledger.
    folder (Folder): Disposable Workspace encounter location.
    step (number): Owner's current quest monster stage.
    source_id (string): Exact original class monster identifier.
    expected_count (number): Two normal monsters or one stage-five boss.

Returns:
    nil: Rejects mismatched monster, branch, stage and duplicate life.
]]
local function check_stage(
    profiles: any, ledger: any, folder: Folder,
    step: number, source_id: string, expected_count: number
)
    local seed = mock_enemy({
        Name = "VerdantEncounterSeed",
        Parent = folder, EncounterId = ENCOUNTER_ID,
        EnemyId = "VerdantSeed",
        SpawnCFrame = CFrame.new(0, 20, 0),
    })
    local execution = {Enemies = {seed}}
    local spawned = Spawns.augment({
        profiles = profiles, user_ids = {USER_ID},
        encounter_id = ENCOUNTER_ID, folder = folder,
        execution = execution,
    }, {create = mock_enemy})
    check(spawned.ok and #spawned.registrations == expected_count,
        "Only current earned quest stage creates its physical enemies")
    for _, registration in ipairs(spawned.registrations) do
        local enemy = registration.enemy
        check(registration.branch_id == "ElvenKnight"
            and registration.step_index == step
            and enemy:GetAttribute("SourceQuestMonsterId")
                == source_id,
            "Model has unique Elven Knight branch/stage/target evidence")
        check(ledger:register_enemy(
            enemy, registration.branch_id,
            ENCOUNTER_ID, registration.step_index
        ), "Actual enemy life registers in existing combat ledger")
        check(not ledger:register_enemy(
            enemy, registration.branch_id,
            ENCOUNTER_ID, registration.step_index
        ), "One monster life cannot mint two quest registrations")
    end
    local quest = assert(Source.get("ElvenKnight"))
    check(ledger:available(quest, step),
        "Only current live quest stage is available to owner")
    for _, enemy in ipairs(execution.Enemies) do
        enemy:Destroy()
    end
    ledger:clear()
end

--[[
Tests independent Elven Knight physical stage-three and stage-five packs.

Args:
    None.

Returns:
    nil: Prints a pass count after both physical registrations and denials.
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
    folder.Name = "GreenwardQuestWorld_TEMP"
    folder.Parent = workspace
    local ledger = Ledger.new({
        profiles = profiles, session_id = ENCOUNTER_ID,
        is_member_active = function(): boolean
            return false
        end,
    })
    check_stage(
        profiles, ledger, folder, 3, "RootboundMarauder", 2
    )
    owner.Identity.RaceId = "Human"
    check(#Spawns.eligible_branches(profiles, {USER_ID}) == 0,
        "A Human with a copied Elven quest cannot spawn Warden loot")
    owner.Identity.RaceId = "Elf"
    owner.Identity.BaseClassId = "Mage"
    check(#Spawns.eligible_branches(profiles, {USER_ID}) == 0,
        "A Mage with copied Fighter quest cannot spawn Warden loot")
    owner.Identity.BaseClassId = "Fighter"
    owner.ClassAdvancement.OriginalFirstTransferQuest.Step = 5
    check_stage(
        profiles, ledger, folder, 5, "ThornboundColossus", 1
    )
    owner.ClassAdvancement.OriginalFirstTransferQuest.Step = 6
    local seed = mock_enemy({
        Name = "InvalidVerdantSeed",
        Parent = folder, EncounterId = ENCOUNTER_ID,
        EnemyId = "InvalidVerdantSeed",
        SpawnCFrame = CFrame.new(0, 20, 0),
    })
    local none = Spawns.augment({
        profiles = profiles, user_ids = {USER_ID},
        encounter_id = ENCOUNTER_ID, folder = folder,
        execution = {Enemies = {seed}},
    }, {create = mock_enemy})
    check(none.ok and #none.registrations == 0,
        "A completed combat stage cannot spawn repeated quest enemies")
    folder:Destroy()
    print(("[Greenward Warden World] PASS: %d assertions")
        :format(checks))
end

main()
