--!strict
-- Local Studio-only consecutive optional combat with real skill and dodge inputs.
-- Source edits below affect only this disposable loaded DataModel.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Use an unpublished local Dungeon build for this test.")

local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local W = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local dungeon = SSS:WaitForChild("Dungeon")

-- Replace one exact runtime source anchor in this local Studio test only.
-- Args: source (LuaSourceContainer): Temporary source to adapt.
--       original (string): Unique text to replace.
--       replacement (string): Text used in the disposable test.
-- Returns: nil: Raises if the anchor is absent or duplicated.
local function replace_once(
    source: LuaSourceContainer, original: string, replacement: string
)
    local value = source.Source
    local position = assert(string.find(value, original, 1, true),
        "Missing TEMP source anchor: " .. source.Name)
    assert(not string.find(value, original, position + #original, true),
        "Duplicate TEMP source anchor: " .. source.Name)
    source.Source = string.sub(value, 1, position - 1)
        .. replacement .. string.sub(value, position + #original)
end

-- Disable the ordinary release-lock tests only in this temporary place.
for _, group in ipairs({SSS.Core.Tests, dungeon.Tests}) do
    for _, child in ipairs(group:GetDescendants()) do
        if child:IsA("Script") then
            child.Enabled = false
        end
    end
end

local definitions = RS.Core.Shared.DungeonDefinitions
local definition_source = definitions.Source
local first_lock = assert(string.find(definition_source,
    "OptionalBossRuntimeEnabled = false,", 1, true))
assert(string.find(definition_source,
    "OptionalBossRuntimeEnabled = false,", first_lock + 1, true),
    "Mine optional release lock must remain unchanged")
definitions.Source = string.sub(definition_source, 1, first_lock - 1)
    .. "OptionalBossRuntimeEnabled = true, -- TEMP Temple fixture only"
    .. string.sub(definition_source,
        first_lock + #"OptionalBossRuntimeEnabled = false,")
replace_once(dungeon.DungeonRuntime,
    'local runtime = RuntimeServices.new("Dungeon")',
    'local runtime = RuntimeServices.new("Dungeon")\n'
        .. '_G.Phase4OptionalPartyRuntime = runtime')
replace_once(dungeon.DungeonRuntime,
    '    if RunService:IsStudio() then\n'
        .. '        local studio = StudioSessionFactory.create_for_players(\n'
        .. '            {player},',
    '    if RunService:IsStudio() then\n'
        .. '        while #Players:GetPlayers() < 2 do task.wait(0.1) end\n'
        .. '        local studio = StudioSessionFactory.create_for_players(\n'
        .. '            Players:GetPlayers(),')

SSS:SetAttribute("DungeonMMOOptionalBossEventStartUnix", os.time() - 60)
SSS:SetAttribute("DungeonMMOOptionalBossEventEndUnix", os.time() + 900)
SSS:SetAttribute("DungeonMMOOptionalBossSecretChanceBasisPoints", 10000)
W:SetAttribute("DungeonMMOStudioDungeonId", "TestDungeon")
W:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
W:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderPlayableEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderOptionalPlayEnabled", true)

-- Client inputs follow the existing CombatInputActions path. No attack
-- remote is forged and the optional bosses receive no debug damage.
local input_driver = Instance.new("LocalScript")
input_driver.Name = "Phase4OptionalNormalCombatInput_TEMP"
input_driver.Source = [=[
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local actions = require(script.Parent:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))
local state = require(script.Parent:WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local requests = 0
local heal_requested = false
local dodge_requested = false
while true do
    if player:GetAttribute("Phase4OptionalDodgeNow") == true
        and not dodge_requested then
        dodge_requested = true
        print("[Two Client Defense] DODGE_REQUEST "
            .. tostring(actions.request_dodge()))
    elseif player:GetAttribute("Phase4OptionalHealNow") == true
        and not heal_requested then
        heal_requested = true
        local slot = nil
        for index = 1, 8 do
            local skill = state.get_skill_for_slot(index)
            if skill == "MageHeal" or skill == "Mend" then
                slot = index
                break
            end
        end
        if slot then
            print("[Two Client Defense] HEAL_REQUEST slot=" .. slot
                .. " sent=" .. tostring(actions.request_skill_slot(slot)))
        else
            warn("[Two Client Defense] NO_HEAL_IN_LOADOUT")
        end
    elseif player:GetAttribute("Phase4NormalOptionalFight") == true then
        local humanoid = player.Character
            and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            if actions.request_attack() then
                requests += 1
            end
        end
        task.wait(0.43)
    else
        task.wait(0.1)
    end
end
]=]
input_driver.Parent = game:GetService("StarterPlayer")
    :WaitForChild("StarterPlayerScripts")

local driver = Instance.new("Script")
driver.Name = "Phase4TwoClientOptionalBoss_TEMP"
driver.Source = [=[
local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")
local W = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local Tags = game:GetService("CollectionService")

local function check(condition, message)
    assert(condition, "[Two Client Optional] " .. message)
end

local function until_value(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then return value end
        task.wait(0.1)
    until os.clock() > deadline
    error("[Two Client Optional] TIMEOUT " .. label)
end

local function anchor(identifier)
    return until_value(function()
        for _, part in ipairs(Tags:GetTagged(
            "DungeonMMOEnvironmentAnchor"
        )) do
            if part:GetAttribute("AnchorId") == identifier then
                return part
            end
        end
    end, identifier, 18)
end

local function encounter_state(sessions, session_id, encounter_id)
    local session = sessions:get(session_id)
    local state = session and session.InstanceState
    local progress = state and state.EncounterRuntime
    return progress and progress.EncounterStates[encounter_id]
end

local function approach(player, identifier)
    local trigger = anchor(identifier)
    local character = until_value(function()
        local model = player.Character
        return model and model:FindFirstChild("HumanoidRootPart")
            and model:FindFirstChildOfClass("Humanoid") and model
    end, player.Name .. " character", 20)
    local root = character.HumanoidRootPart
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    root.CFrame = trigger.CFrame * CFrame.new(0, 0, 9)
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.2)
    humanoid:MoveTo(trigger.Position + Vector3.new(0, 0, -2))
end

local function living_enemies()
    local gameplay = W:FindFirstChild("DungeonGameplayRuntime")
    local folder = gameplay and gameplay:FindFirstChild("DungeonEnemies")
    if not folder then return {} end
    local living = {}
    for _, model in ipairs(folder:GetChildren()) do
        if model:IsA("Model") then
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(living, model)
            end
        end
    end
    return living
end

local function current_reward_history(runtime, user_id)
    local profile = runtime.ProfileService:get_character(user_id, 1)
    return profile and profile.RewardHistory
        and profile.RewardHistory.Monster or {}
end

local function transaction_for(history, fragment)
    local count = 0
    local matching = nil
    for transaction in pairs(history) do
        count += 1
        if string.find(transaction, fragment, 1, true) then
            matching = transaction
        end
    end
    return matching, count
end

local function fight_room(runtime, session_id, player, room)
    check(encounter_state(runtime.SessionService, session_id, room.id)
        == "Pending", room.slot .. " must be pending")
    approach(player, room.trigger)
    until_value(function()
        return encounter_state(runtime.SessionService, session_id,
            room.id) == "Active"
    end, room.slot .. " trigger", 12)
    local models = until_value(function()
        local current = living_enemies()
        return #current > 0 and current
    end, room.slot .. " enemies", 12)
    if room.boss then
        check(#models == 1, room.slot .. " spawned duplicate bosses")
    end
    return models
end

local function clear_room(runtime, session_id, room, models, player, ally)
    if room.slot == "EventArena" or room.slot == "SecretArena" then
        check(player ~= nil, "normal boss combat needs a real player")
        check(#models == 1, "normal boss combat requires one live boss")
        local boss = models[1]
        local boss_health = boss:FindFirstChildOfClass("Humanoid")
        local boss_root = boss:FindFirstChild("HumanoidRootPart")
        check(boss_health and boss_root, "boss has no combat rig")
        local starting_health = boss_health.Health
        local character = player.Character
        local health = character
            and character:FindFirstChildOfClass("Humanoid")
        local root = character
            and character:FindFirstChild("HumanoidRootPart")
        check(health and root and health.Health > 0,
            "surviving client is not combat-ready")
        check(health.MaxHealth < 100000,
            "normal optional combat must not use inflated player health")
        root.CFrame = CFrame.lookAt(
            boss_root.Position + Vector3.new(0, 0, 4.8),
            boss_root.Position
        )
        if ally then
            local ally_root = ally.Character
                and ally.Character:FindFirstChild("HumanoidRootPart")
            local ally_health = ally.Character
                and ally.Character:FindFirstChildOfClass("Humanoid")
            check(ally_root and ally_health and ally_health.Health > 0
                and ally_health.MaxHealth < 100000,
                "second client needs normal combat health")
            ally_root.CFrame = CFrame.lookAt(
                boss_root.Position + Vector3.new(4.8, 0, 0),
                boss_root.Position
            )
            ally:SetAttribute("Phase4NormalOptionalFight", true)
        end
        player:SetAttribute("Phase4NormalOptionalFight", true)
        local deadline = os.clock() + 72
        local min_health = starting_health
        repeat
            min_health = math.min(min_health, boss_health.Health)
            if boss_health.Health <= 0 or health.Health <= 0 then
                break
            end
            task.wait(0.16)
        until os.clock() > deadline
        player:SetAttribute("Phase4NormalOptionalFight", false)
        if ally then
            ally:SetAttribute("Phase4NormalOptionalFight", false)
        end
        print("[Two Client Normal] " .. room.slot
            .. " boss=" .. boss_health.Health
            .. "/" .. starting_health
            .. " player=" .. health.Health .. "/" .. health.MaxHealth)
        check(min_health < starting_health,
            room.slot .. " received no normal client combat damage")
        check(boss_health.Health <= 0,
            room.slot .. " was not beaten using normal client combat")
        print("[Two Client Normal] " .. room.slot
            .. " NORMAL_CLIENT_BOSS_DEFEATED")
    else
        -- Prerequisite combat packs and the final boss are assisted here.
        -- Only optional bosses are claimed as normal-combat victories.
        for _, model in ipairs(models) do
            model:FindFirstChildOfClass("Humanoid").Health = 0
        end
    end
    until_value(function()
        return encounter_state(runtime.SessionService, session_id,
            room.id) == "Cleared"
    end, room.slot .. " cleared", 15)
    print("[Two Client Optional] CLEARED " .. room.slot)
end

local function test()
    check(game.PlaceId == 0 and game.GameId == 0,
        "cannot execute multiplayer fixture in a published place")
    local players = until_value(function()
        local current = Players:GetPlayers()
        return #current == 2 and current
    end, "two real Studio clients", 35)
    local departing, remaining = players[1], players[2]
    check(departing.UserId ~= remaining.UserId,
        "two distinct clients are required")
    local runtime = until_value(function()
        return _G.Phase4OptionalPartyRuntime
    end, "Dungeon runtime", 30)
    local session = until_value(function()
        local current = runtime.SessionService:get_for_user(departing.UserId)
        if current and current.State == "Active"
            and current.Members[tostring(departing.UserId)]
            and current.Members[tostring(departing.UserId)].Connected
            and current.Members[tostring(remaining.UserId)]
            and current.Members[tostring(remaining.UserId)].Connected
            and current.InstanceState
            and current.InstanceState.EncounterPlan
        then return current end
    end, "shared admitted optional run", 40)
    local id = session.SessionId
    check(session.InstanceState.OptionalBossEventActive
        and session.InstanceState.OptionalBossSecretUnlocked,
        "both optional bosses must be eligible in TEMP run")
    local ordered = {}
    for _, encounter in ipairs(session.InstanceState.EncounterPlan) do
        table.insert(ordered, encounter.RoomSlotId)
    end
    check(table.concat(ordered, ",")
        == "Room1,EventArena,Room2,SecretArena,Room3",
        "both optional bosses must be in one frozen party plan")
    print("[Two Client Optional] TWO_CLIENT_PLAN_PASS")

    local rooms = {
        {slot = "Room1", trigger = "Temple.Room1.Trigger",
            id = "CombatRoom1"},
        {slot = "EventArena", trigger = "Temple.Event.Trigger",
            id = "TempleEventBossEncounter", boss = true},
        {slot = "Room2", trigger = "Temple.Room2.Trigger",
            id = "CombatRoom2"},
        {slot = "SecretArena", trigger = "Temple.Secret.Trigger",
            id = "TempleSecretBossEncounter", boss = true},
        {slot = "Room3", trigger = "Temple.Room3.Trigger",
            id = "Depth1Boss", boss = true},
    }

    local first = fight_room(runtime, id, departing, rooms[1])
    clear_room(runtime, id, rooms[1], first)
    local event = fight_room(runtime, id, departing, rooms[2])
    approach(remaining, rooms[2].trigger)
    task.wait(0.3)
    check(#living_enemies() == 1
        and encounter_state(runtime.SessionService, id, rooms[2].id)
            == "Active",
        "two players entering Event must not spawn a second boss")
    print("[Two Client Optional] EVENT_ONE_BOSS_TWO_CLIENTS_PASS")

    -- Both party members use normal client attacks against Event.
    local event_root = event[1]:FindFirstChild("HumanoidRootPart")
    local ally_root = departing.Character
        and departing.Character:FindFirstChild("HumanoidRootPart")
    check(event_root and ally_root, "Event co-op combat rig missing")
    ally_root.CFrame = CFrame.lookAt(
        event_root.Position + Vector3.new(4.8, 0, 0),
        event_root.Position
    )
    clear_room(runtime, id, rooms[2], event, remaining, departing)
    local remaining_health = remaining.Character
        and remaining.Character:FindFirstChildOfClass("Humanoid")
    local ally_health = departing.Character
        and departing.Character:FindFirstChildOfClass("Humanoid")
    check(remaining_health and ally_health
        and remaining_health.Health > 0 and ally_health.Health > 0,
        "both players must survive Event for consecutive co-op test")
    print("[Two Client Consecutive] EVENT_COOP_PASS "
        .. remaining_health.Health .. "/" .. remaining_health.MaxHealth
        .. " ally=" .. ally_health.Health .. "/" .. ally_health.MaxHealth)
    remaining:SetAttribute("Phase4OptionalDodgeNow", true)
    until_value(function()
        local character = remaining.Character
        return character
            and character:GetAttribute("CombatState") == "Dodging"
    end, "server-authoritative dodge state", 3)
    remaining:SetAttribute("Phase4OptionalDodgeNow", false)
    print("[Two Client Defense] SERVER_DODGE_ACCEPTED")
    until_value(function()
        return remaining.Character
            and remaining.Character:GetAttribute("CombatState")
                == "Locomotion"
    end, "dodge movement finished", 4)
    local remaining_root = remaining.Character.HumanoidRootPart
    local ally_root_after = departing.Character.HumanoidRootPart
    ally_root_after.CFrame = remaining_root.CFrame
        * CFrame.new(4, 0, 0)
    local health_before = remaining_health.Health
        + ally_health.Health
    remaining:SetAttribute("Phase4OptionalHealNow", true)
    until_value(function()
        local total = remaining_health.Health + ally_health.Health
        return total > health_before + 0.5 and total
    end, "health restored by server-authoritative equipped skill", 9)
    remaining:SetAttribute("Phase4OptionalHealNow", false)
    print("[Two Client Defense] REAL_SKILL_HEAL_PASS "
        .. remaining_health.Health .. "/" .. remaining_health.MaxHealth
        .. " ally=" .. ally_health.Health .. "/" .. ally_health.MaxHealth)
    local history = current_reward_history(runtime, remaining.UserId)
    local event_tx, before = transaction_for(
        history, "TempleEventBoss:TempleEventBossEncounter")
    check(event_tx ~= nil, "remaining player did not receive Event reward")
    local replay = runtime.RewardService:grant_monster_reward(
        {remaining.UserId}, {XP = 40, GoldMin = 0, GoldMax = 0,
            BossId = "TempleEventBoss"}, event_tx)
    local _, after = transaction_for(
        current_reward_history(runtime, remaining.UserId),
        "TempleEventBoss:TempleEventBossEncounter")
    check(replay.ok and replay.already_applied and before == after,
        "repeat Event reward transaction must be idempotent")
    print("[Two Client Optional] EVENT_REWARD_REPLAY_BLOCKED")

    for _, room in ipairs({rooms[3], rooms[4], rooms[5]}) do
        local enemies = fight_room(runtime, id, remaining, room)
        if room.slot == "SecretArena" then
            approach(departing, room.trigger)
            task.wait(0.25)
            check(#living_enemies() == 1,
                "second client entering Secret spawned duplicate boss")
            check(#enemies == 1, "Secret should spawn exactly one boss")
            print("[Two Client Optional] SECRET_PEER_ONE_BOSS_PASS")
        end
        clear_room(runtime, id, room, enemies, remaining, departing)
    end
    local completed = runtime.SessionService:get(id)
    check(completed.State == "Complete",
        "surviving player must complete the same dungeon session")
    local secret_tx = transaction_for(
        current_reward_history(runtime, remaining.UserId),
        "TempleSecretBoss:TempleSecretBossEncounter")
    check(secret_tx ~= nil, "surviving player Secret reward missing")
    print("[Two Client Optional] PEER_FINAL_COMPLETION_PASS")
    print("[Two Client Optional] SAME_USER_REJOIN_NOT_TESTED")
end

task.spawn(function()
    local ok, reason = pcall(test)
    if not ok then
        warn("[Two Client Optional] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(245, function()
    STS:EndTest("FAIL global timeout")
end)
]=]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(2, "OptionalBossTwoClient_TEMP")
end)
driver:Destroy()
input_driver:Destroy()
assert(ok and result == "PASS",
    "Two-client optional encounter proof failed: " .. tostring(result))
print("[Two Client Defense] DODGE_HEAL_EVENT_SECRET_PASS")
