--!strict
-- RunScript against a newly built TEMP local Dungeon place only.
-- This deliberately alters ONLY the loaded temporary Studio DataModel.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Fixture cannot run against a published place.")

local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local W = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local dungeon = SSS:WaitForChild("Dungeon")
local shared = RS.Core.Shared

local function replace_once(source: LuaSourceContainer, old: string, new: string)
    local value = source.Source
    local index = string.find(value, old, 1, true)
    assert(index and not string.find(value, old, index + #old, true),
        "TEMP fixture source anchor missing or duplicated: " .. source.Name)
    source.Source = string.sub(value, 1, index - 1)
        .. new .. string.sub(value, index + #old)
end

-- Do not run the production-lock assertions against the intentionally
-- unlocked temporary fixture; they were exercised in the unchanged build.
for _, group in ipairs({SSS.Core.Tests, dungeon.Tests}) do
    for _, child in ipairs(group:GetDescendants()) do
        if child:IsA("Script") then
            child.Enabled = false
        end
    end
end

local definitions = shared.DungeonDefinitions
local definition_source = definitions.Source
local lock_text = "OptionalBossRuntimeEnabled = false,"
local first_lock = assert(string.find(definition_source, lock_text, 1, true),
    "Temple rollout flag was not found.")
local mine_lock = assert(string.find(definition_source, lock_text,
    first_lock + #lock_text, true), "Mine rollout flag missing.")
assert(not string.find(definition_source, lock_text,
    mine_lock + #lock_text, true), "Expected precisely two rollout locks.")
definitions.Source = string.sub(definition_source, 1, mine_lock - 1)
    .. "OptionalBossRuntimeEnabled = true, -- TEMP Studio Mine fixture only"
    .. string.sub(definition_source, mine_lock + #lock_text)

local catalog = shared.DungeonRuntimeContentCatalog
local marker = "                Room3 = slot("
local value = catalog.Source
local start = assert(string.find(value, "    AbandonedMine = table.freeze({", 1, true))
local where = assert(string.find(value, marker, start, true))
assert(where > start, "TEMP slot insertion must target Mine Depth1.")
local extra_slots = [[
                EventArena = slot(
                    "Mine.Event.Trigger",
                    "Mine.Event.Checkpoint",
                    "EventArena", nil, nil, nil, false, true,
                    nil, nil, "Mine.Event.BossSpawn"
                ),
                SecretArena = slot(
                    "Mine.Secret.Trigger",
                    "Mine.Secret.Checkpoint",
                    "SecretArena", nil, nil, nil, false, true,
                    nil, nil, "Mine.Secret.BossSpawn"
                ),
]]
catalog.Source = string.sub(value, 1, where - 1)
    .. extra_slots .. string.sub(value, where)

local synthetic = dungeon.AbandonedMineSyntheticEnvironment
local original = "    local entries = {"
local changed = [[    local side = parent:FindFirstChild("DungeonMMOSyntheticMine")
    assert(side, "TEMP Mine side-room parent absent.")
    local stone = Color3.fromRGB(68, 64, 59)
    make_part(side, "TEMP_EventFloor", Vector3.new(80, 1, 90),
        CFrame.new(555, 0, -54), Enum.Material.Slate, stone)
    make_part(side, "TEMP_EventBridge", Vector3.new(38, 1, 20),
        CFrame.new(501, 0, -45), Enum.Material.Slate, stone)
    make_part(side, "TEMP_SecretFloor", Vector3.new(80, 1, 100),
        CFrame.new(555, 0, -215), Enum.Material.Slate, stone)
    make_part(side, "TEMP_SecretBridge", Vector3.new(38, 1, 40),
        CFrame.new(501, 0, -165), Enum.Material.Slate, stone)

    local entries = {
        {"Mine.Event.Checkpoint", CFrame.new(555, 1, -30),
            "Checkpoint", Vector3.new(6, 2, 6), false, false},
        {"Mine.Event.Trigger", CFrame.new(555, 3, -38),
            "EncounterTrigger", Vector3.new(60, 6, 5), true, false},
        {"Mine.Event.BossSpawn", CFrame.new(555, 2, -80),
            "BossSpawn", Vector3.new(4, 2, 4), false, false},
        {"Mine.Secret.Checkpoint", CFrame.new(555, 1, -185),
            "Checkpoint", Vector3.new(6, 2, 6), false, false},
        {"Mine.Secret.Trigger", CFrame.new(555, 3, -190),
            "EncounterTrigger", Vector3.new(60, 6, 5), true, false},
        {"Mine.Secret.BossSpawn", CFrame.new(555, 2, -255),
            "BossSpawn", Vector3.new(4, 2, 4), false, false},
]]
replace_once(synthetic, original, changed)

replace_once(dungeon.DungeonRuntime,
    'local runtime = RuntimeServices.new("Dungeon")',
    'local runtime = RuntimeServices.new("Dungeon")\n'
        .. '_G.DungeonMMOTempFixtureRuntime = runtime')

SSS:SetAttribute("DungeonMMOOptionalBossEventStartUnix", os.time() - 60)
SSS:SetAttribute("DungeonMMOOptionalBossEventEndUnix", os.time() + 600)
SSS:SetAttribute("DungeonMMOOptionalBossSecretChanceBasisPoints", 10000)
W:SetAttribute("DungeonMMOStudioDungeonId", "AbandonedMine")
W:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")

local driver = Instance.new("Script")
driver.Name = "OptionalBossLiveFixture_TEMP"
driver.Source = [[
local Players = game:GetService("Players")
local STS = game:GetService("StudioTestService")
local W = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

local function must(condition, message)
    assert(condition, "[Optional Boss TEMP Gameplay] " .. message)
end

local function wait_until(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then return value end
        task.wait(0.15)
    until os.clock() >= deadline
    error("[Optional Boss TEMP Gameplay] Timed out: " .. label)
end

local function anchor(id)
    return wait_until(function()
        for _, part in ipairs(CollectionService:GetTagged(
            "DungeonMMOEnvironmentAnchor"
        )) do
            if part:GetAttribute("AnchorId") == id then
                return part
            end
        end
    end, id, 15)
end

local function run()
    local player = wait_until(function()
        return Players:GetPlayers()[1]
    end, "player", 22)
    local runtime = wait_until(function()
        return _G.DungeonMMOTempFixtureRuntime
    end, "runtime", 20)
    local session = wait_until(function()
        local candidate = runtime.SessionService:get_for_user(player.UserId)
        return candidate and candidate.InstanceState
            and candidate.InstanceState.EncounterPlan and candidate
    end, "admitted session and encounter plan", 25)

    must(session.InstanceState.OptionalBossEventActive == true,
        "event unavailable despite TEMP entry window")
    must(session.InstanceState.OptionalBossSecretUnlocked == true,
        "secret route unavailable despite TEMP eligible seed")
    local plan = session.InstanceState.EncounterPlan
    local sequence = {}
    for _, e in ipairs(plan) do
        table.insert(sequence, e.RoomSlotId)
    end
    print("[Optional Boss TEMP Gameplay] PLAN "
        .. table.concat(sequence, ","))
    must(table.concat(sequence, ",") ==
        "Room1,EventArena,Room2,SecretArena,Room3",
        "unexpected optional encounter order")

    local character = wait_until(function()
        return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            and player.Character
    end, "character", 20)
    local root = character.HumanoidRootPart
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    must(humanoid ~= nil, "player humanoid missing")
    humanoid.MaxHealth = 100000
    humanoid.Health = 100000

    local enemies = wait_until(function()
        local game_root = W:FindFirstChild("DungeonGameplayRuntime")
        return game_root and game_root:FindFirstChild("DungeonEnemies")
    end, "enemy container", 15)

    local skip_secret = W:GetAttribute("DungeonMMOTempSkipSecret") == true
    local targets = {
        {"Room1", "Mine.Room1.Trigger", "CombatRoom1"},
        {"EventArena", "Mine.Event.Trigger", "AbandonedMineEventBossEncounter"},
        {"Room2", "Mine.Room2.Trigger", "CombatRoom2"},
        {"SecretArena", "Mine.Secret.Trigger", "AbandonedMineSecretBossEncounter"},
        {"Room3", "Mine.Room3.Trigger", "Depth1Boss"},
    }
    if skip_secret then
        table.remove(targets, 4)
    end

    for _, item in ipairs(targets) do
        local slot, trigger_id, encounter_id = item[1], item[2], item[3]
        local trigger = anchor(trigger_id)
        local session_id = session.SessionId
        local function state_of()
            local current = runtime.SessionService:get(session_id)
            return current and current.InstanceState
                and current.InstanceState.EncounterRuntime
                and current.InstanceState.EncounterRuntime.EncounterStates
                and current.InstanceState.EncounterRuntime.EncounterStates[encounter_id]
        end

        must(state_of() == "Pending",
            slot .. " must be pending before physical approach")
        root.CFrame = trigger.CFrame * CFrame.new(0, 0, 9)
        root.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.2)
        humanoid:MoveTo(trigger.Position + Vector3.new(0, 0, -2))
        wait_until(function()
            return state_of() == "Active"
        end, slot .. " physical touched trigger", 9)

        local spawned = wait_until(function()
            local models = {}
            for _, model in ipairs(enemies:GetChildren()) do
                if model:IsA("Model") then
                    local h = model:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 then
                        table.insert(models, model)
                    end
                end
            end
            return if #models > 0 then models else nil
        end, slot .. " spawned enemies", 9)

        if slot == "EventArena" or slot == "SecretArena" then
            must(#spawned == 1, slot .. " expected one boss")
            print("[Optional Boss TEMP Gameplay] BOSS " .. slot
                .. " ID=" .. tostring(spawned[1]:GetAttribute("BossId"))
                .. " EnemyId="
                .. tostring(spawned[1]:GetAttribute("DungeonEnemyId")))
        end
        print("[Optional Boss TEMP Gameplay] STARTED " .. slot
            .. " enemies=" .. #spawned)
        -- Debug defeat, not a validation of normal combat or damage balance.
        for _, model in ipairs(spawned) do
            local h = model:FindFirstChildOfClass("Humanoid")
            h.Health = 0
        end
        wait_until(function()
            return state_of() == "Cleared"
        end, slot .. " reward/progression clear", 12)
        print("[Optional Boss TEMP Gameplay] CLEARED " .. slot)
    end

    local final = runtime.SessionService:get(session.SessionId)
    local snapshot = final.InstanceState.EncounterRuntime.EncounterStates
    local discoveries = final.InstanceState.OptionalBossSecretDiscoveries
    if skip_secret then
        must(snapshot.AbandonedMineSecretBossEncounter == "Skipped",
            "entering the direct successor must persist a secret skip")
        must(not discoveries or not discoveries.MineSealedGallery,
            "skipped secret must not be discovered")
        print("[Optional Boss TEMP Gameplay] SECRET_SKIPPED")
    else
        must(discoveries and discoveries.MineSealedGallery,
            "secret discovery did not persist")
        print("[Optional Boss TEMP Gameplay] SECRET_DISCOVERY_PERSISTED")
    end

    local character_data = runtime.ProfileService:get_character(
        player.UserId, 1
    )
    local history = character_data and character_data.RewardHistory
        and character_data.RewardHistory.Monster
    must(type(history) == "table", "player reward history missing")
    local event_paid = false
    local secret_paid = false
    local reward_count = 0
    for transaction_id in pairs(history) do
        reward_count += 1
        if string.find(transaction_id,
            "AbandonedMineEventBoss:AbandonedMineEventBossEncounter", 1, true)
        then
            event_paid = true
        end
        if string.find(transaction_id,
            "AbandonedMineSecretBoss:AbandonedMineSecretBossEncounter", 1, true)
        then
            secret_paid = true
        end
    end
    must(event_paid, "event boss reward was not recorded")
    must(secret_paid ~= skip_secret,
        "secret boss reward must occur only when fought")
    print("[Optional Boss TEMP Gameplay] REWARD_HISTORY "
        .. reward_count .. " event=" .. tostring(event_paid)
        .. " secret=" .. tostring(secret_paid))
    must(final.State == "Complete", "session was not completed")
    print("[Optional Boss TEMP Gameplay] RUN_COMPLETE "
        .. tostring(final.State))
end

local ok, err = pcall(run)
if ok then
    print("[Optional Boss TEMP Gameplay] PASS assisted live progression")
    STS:EndTest("PASS")
else
    warn("[Optional Boss TEMP Gameplay] FAIL " .. tostring(err))
    STS:EndTest("FAIL " .. tostring(err))
end
]]
driver.Parent = SSS

W:SetAttribute("DungeonMMOTempSkipSecret", true)
print("[Optional Boss TEMP Gameplay] START_PLAY skip-secret")
local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("OptionalBoss_TEMP_MineSkipSecret")
end)
assert(ok, "TEMP Mine skip Play failed: " .. tostring(result))
print("[Optional Boss TEMP Gameplay] SKIP_RESULT " .. tostring(result))
assert(result == "PASS", "TEMP Mine skip proof failed: " .. tostring(result))

driver:Destroy()
print("[Optional Boss TEMP Gameplay] MINE_SKIP_PLAY_MODE_PASS")
