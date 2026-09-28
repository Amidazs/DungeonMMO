--!strict
-- Physical optional source-pack insertion into one disposable dungeon room.
local SSS = game:GetService("ServerScriptService")
local Spawns = require(SSS.Dungeon.C4QuestEncounterSpawns)
local Ledger = require(SSS.Dungeon.C4QuestMonsterCombatLedger)
local Careers = require(game:GetService("ReplicatedStorage")
    .Core.Shared.OriginalFirstTransferDefinitions)
local Quests = require(game:GetService("ReplicatedStorage")
    .Core.Shared.C4OriginalFirstTransferQuestStages)
local checks = 0

--[[
Checks that one observed source-challenge contract is satisfied.

Args:
    condition (boolean): Asserted fact from the spawned physical models.
    label (string): Description of the rule under test.

Returns:
    nil: Raises on a failed assertion.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Source Pack] " .. label)
end

--[[
Creates a harmless disposable physical model with a real root and humanoid.

Args:
    options (any): Existing dungeon encounter and spawn factory options.

Returns:
    Model: One world-owned model, never a client event or fake table.
]]
local function mock_create(options: any): Model
    local enemy = Instance.new("Model")
    enemy.Name = options.Name
    enemy:SetAttribute("DungeonEncounterId", options.EncounterId)
    enemy:SetAttribute("DungeonEnemyId", options.EnemyId)
    enemy:SetAttribute("DungeonRewardXP", options.RewardXP)
    enemy:SetAttribute("DungeonRewardGoldMin", options.RewardGoldMin)
    enemy:SetAttribute("DungeonRewardGoldMax", options.RewardGoldMax)
    enemy:SetAttribute("BestiaryCreatureId", options.BestiaryCreatureId)
    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.CFrame = options.SpawnCFrame
    root.Anchored = true
    root.Parent = enemy
    enemy.PrimaryPart = root
    local humanoid = Instance.new("Humanoid")
    local max_health = tonumber(options.BaseMaxHealth) or 100
    humanoid.MaxHealth = max_health
    humanoid.Health = max_health
    humanoid.Parent = enemy
    enemy.Parent = options.Parent
    return enemy
end

--[[
Builds the minimum saved stage-three character to test branch selection.

Args:
    branch_id (string): Exact original character's selected branch.

Returns:
    any: Profile character with an uncompleted real stage-three quest.
]]
local function character_for(
    branch_id: string,
    step_index: number?
): any
    local career = assert(Careers.for_branch(branch_id))
    local quest = assert(Quests.get(branch_id))
    return {
        Level = quest.StartLevel,
        Identity = {
            ClassId = "Fighter",
            BaseClassId = career.BaseClassId,
            RaceId = career.RaceId,
        },
        ClassAdvancement = {
            OriginalFirstTransferChoiceId = branch_id,
            OriginalFirstTransferQuest = {
                BranchId = branch_id,
                Step = step_index or 3,
                Ready = false,
            },
        },
    }
end

--[[
Checks one pair of Dwarf quest-combat stages through the real spawn binder.

Args:
    characters (any): Mutable disposable owner profiles by UserId.
    profiles (any): Profile adapter consumed by the spawn module.
    execution (any): Existing room execution owning all spawned enemies.
    folder (Folder): Disposable room enemy folder.
    ledger (any): Physical quest-monster receipt authority.
    artisan_step (number): Current Gearwright ordered quest step.
    scavenger_step (number): Current Deepclaimer ordered quest step.
    expected (any): Expected source IDs with branch, step and count.

Returns:
    nil: Verifies physical spawn, inherited health and exact ledger binding.
]]
local function check_dwarf_stage_pack(
    characters: any,
    profiles: any,
    execution: any,
    folder: Folder,
    ledger: any,
    artisan_step: number,
    scavenger_step: number,
    expected: any
)
    characters[103] = character_for(
        "DwarfArtisan",
        artisan_step
    )
    characters[104] = character_for(
        "DwarfScavenger",
        scavenger_step
    )

    local spawned = Spawns.augment({
        profiles = profiles,
        user_ids = {103, 104},
        execution = execution,
        encounter_id = "QuestRoom1",
        folder = folder,
    }, {create = mock_create})

    local expected_total = 0
    for _, record in pairs(expected) do
        expected_total += record.Count
    end

    check(
        spawned.ok
            and #spawned.registrations == expected_total,
        "Dwarf room pack has only current ordered quest targets"
    )

    local room_humanoid = assert(
        execution.Enemies[1]:FindFirstChildOfClass("Humanoid")
    )
    local seen = {}

    for _, registration in ipairs(spawned.registrations) do
        local enemy = registration.enemy
        local source_id = enemy:GetAttribute(
            "SourceQuestMonsterId"
        )
        local contract = assert(
            expected[source_id],
            "Unexpected Dwarf quest target: " .. tostring(source_id)
        )
        local humanoid = assert(
            enemy:FindFirstChildOfClass("Humanoid")
        )

        check(
            registration.branch_id == contract.BranchId
                and registration.step_index == contract.Step,
            "Dwarf target binds to exact branch and ordered step"
        )
        check(
            humanoid.MaxHealth == room_humanoid.MaxHealth,
            "Dwarf temporary rig inherits reviewed room health"
        )
        check(
            ledger:register_enemy(
                enemy,
                registration.branch_id,
                "QuestRoom1",
                registration.step_index
            ),
            "Dwarf physical quest target registers in server ledger"
        )

        seen[source_id] = (seen[source_id] or 0) + 1
    end

    for source_id, contract in pairs(expected) do
        check(
            seen[source_id] == contract.Count,
            source_id .. " exact room-pack count"
        )
        check(
            ledger:available(
                assert(Quests.get(contract.BranchId)),
                contract.Step
            ),
            source_id .. " becomes world-available only after spawn"
        )
    end
end

--[[
Exercises mixed-party quest spawn isolation and actual model registration.

Args:
    None.

Returns:
    nil: Reports the focused instanced challenge integration result.
]]
local function main()
    local folder = Instance.new("Folder")
    folder.Name = "C4QuestSpawnTest"
    folder.Parent = workspace
    local seed = mock_create({
        Parent = folder, Name = "ExistingMarauder",
        EncounterId = "QuestRoom1", EnemyId = "Marauder1",
        SpawnCFrame = CFrame.new(0, 20, 0),
    })
    local characters = {
        [101] = character_for("HumanRogue"),
        [102] = character_for("ElvenScout"),
    }
    local profiles = {
        get_character = function(
            _self: any, user_id: number
        ): any
            return characters[user_id]
        end,
    }
    local execution = {Enemies = {seed}}
    local options = {
        profiles = profiles,
        user_ids = {101, 102},
        execution = execution,
        encounter_id = "QuestRoom1",
        folder = folder,
    }
    local spawned = Spawns.augment(
        options, {create = mock_create}
    )
    check(spawned.ok and #spawned.registrations == 4,
        "Mixed party gets two source monsters per eligible branch")
    check(#execution.Enemies == 5,
        "All original enemies and challenges share the encounter lifecycle")
    local ledger = Ledger.new({
        profiles = profiles,
        session_id = "QuestSession1",
        is_member_active = function(): boolean
            return false
        end,
    })
    local seen = {}
    for _, registration in ipairs(spawned.registrations) do
        local enemy = registration.enemy
        local source_id = enemy:GetAttribute("SourceQuestMonsterId")
        check(enemy:IsDescendantOf(workspace)
            and enemy:GetAttribute("DungeonEncounterId")
                == "QuestRoom1",
            "Challenge is a physical, session-scoped dungeon enemy")
        check(enemy:GetAttribute("DungeonRewardXP") == 1
            and enemy:GetAttribute("DungeonRewardGoldMin") == 0
            and enemy:GetAttribute("DungeonRewardGoldMax") == 0
            and enemy:GetAttribute("BestiaryCreatureId") == "marauder",
            "Source enemy has a valid minimal normal reward for room clear")
        check(ledger:register_enemy(
            enemy, registration.branch_id, "QuestRoom1"
        ), "One distinct real source enemy can register for combat")
        seen[source_id] = (seen[source_id] or 0) + 1
    end
    check(seen.CryptSentinel == 2 and seen.BrackenRaider == 2,
        "Human and Elf branches receive their own original archetypes")
    characters[101].ClassAdvancement
        .OriginalFirstTransferQuest.Step = 4
    characters[102].ClassAdvancement
        .OriginalFirstTransferQuest.Step = 4
    local later = Spawns.augment(
        options, {create = mock_create}
    )
    check(later.ok and #later.registrations == 0
        and #execution.Enemies == 5,
        "Completed source combat stages cannot spawn repeated rewards")
    characters[101].ClassAdvancement
        .OriginalFirstTransferQuest.Step = 6
    local cinder = Spawns.augment(
        options, {create = mock_create}
    )
    check(cinder.ok and #cinder.registrations == 1
        and #execution.Enemies == 6,
        "Only eligible Rogue stage six spawns its own Cinder challenge")
    for _, registration in ipairs(cinder.registrations) do
        check(registration.branch_id == "HumanRogue"
            and registration.step_index == 6
            and registration.enemy:GetAttribute("SourceQuestMonsterId")
                == "CinderBrigand",
            "Original Cinder monster is bound to exactly Rogue stage six")
        check(registration.enemy:GetAttribute("DungeonRewardXP") == 1
            and registration.enemy:GetAttribute("BestiaryCreatureId")
                == "marauder",
            "Cinder enemy death must preserve ordinary encounter clear")
        check(ledger:register_enemy(
            registration.enemy, registration.branch_id,
            "QuestRoom1", registration.step_index
        ), "Physical Cinder life registers only for exact stage six")
    end
    check(ledger:available(
        require(game:GetService("ReplicatedStorage")
            .Core.Shared.C4OriginalFirstTransferQuestStages
        ).get("HumanRogue"), 6),
        "Ledger exposes stage-six monster only when physically registered")

    check_dwarf_stage_pack(
        characters,
        profiles,
        execution,
        folder,
        ledger,
        2,
        4,
        {
            TunnelGnawer = {
                BranchId = "DwarfArtisan",
                Step = 2,
                Count = 2,
            },
            HoneybackBear = {
                BranchId = "DwarfScavenger",
                Step = 4,
                Count = 2,
            },
        }
    )
    check_dwarf_stage_pack(
        characters,
        profiles,
        execution,
        folder,
        ledger,
        3,
        6,
        {
            TunnelGnawerChief = {
                BranchId = "DwarfArtisan",
                Step = 3,
                Count = 2,
            },
            TunnelTarantula = {
                BranchId = "DwarfScavenger",
                Step = 6,
                Count = 2,
            },
        }
    )
    check_dwarf_stage_pack(
        characters,
        profiles,
        execution,
        folder,
        ledger,
        7,
        5,
        {
            AshclanForgeThief = {
                BranchId = "DwarfArtisan",
                Step = 7,
                Count = 1,
            },
        }
    )

    ledger:clear()
    folder:Destroy()
    print(("[C4 Source Pack] PASS: %d assertions"):format(checks))
end

main()
