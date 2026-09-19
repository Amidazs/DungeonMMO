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

local client = Instance.new("LocalScript")
client.Name = "Phase4NormalCombatInput_TEMP"
client.Source = [=[
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local actions = require(script.Parent:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))
while player:GetAttribute("Phase4AttackEventBoss") ~= true do
    player:GetAttributeChangedSignal("Phase4AttackEventBoss"):Wait()
end
print("[Phase4 Combat Input] STARTED")
local duration = os.clock() + 90
local sent = 0
local dodges = 0
local last_dodge_at_attack = 0
while os.clock() < duration and player:GetAttribute("Phase4AttackEventBoss") == true do
    local humanoid = player.Character
        and player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then break end
    if actions.request_attack() then sent += 1 end
    if sent >= last_dodge_at_attack + 3 then
        last_dodge_at_attack = sent
        if actions.request_dodge() then dodges += 1 end
        task.wait(0.34)
    else
        task.wait(0.43)
    end
end
print("[Phase4 Combat Input] CLIENT_ATTACK_REQUESTS " .. sent
    .. " DODGE_REQUESTS " .. dodges)
]=]
client.Parent = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")

local driver = Instance.new("Script")
driver.Name = "Phase4NormalCombatDriver_TEMP"
driver.Source = [=[
local Players = game:GetService("Players")
local STS = game:GetService("StudioTestService")
local RS = game:GetService("ReplicatedStorage")
local W = game:GetService("Workspace")
local CS = game:GetService("CollectionService")
local SSS = game:GetService("ServerScriptService")
local function wait_for(predicate, label, sec)
    local deadline = os.clock() + sec
    repeat
        local x = predicate()
        if x then return x end
        task.wait(0.12)
    until os.clock() >= deadline
    error("[Phase4 Normal Combat] TIMEOUT " .. label)
end
local function anchor(id)
    return wait_for(function()
        for _, part in ipairs(CS:GetTagged("DungeonMMOEnvironmentAnchor")) do
            if part:GetAttribute("AnchorId") == id then return part end
        end
    end,id,15)
end
local function run()
    local player = wait_for(function() return Players:GetPlayers()[1] end,"player",20)
    local runtime = wait_for(function()
        return _G.DungeonMMOTempFixtureRuntime
    end,"runtime",20)
    local session = wait_for(function()
        local s=runtime.SessionService:get_for_user(player.UserId)
        return s and s.InstanceState and s.InstanceState.EncounterPlan and s
    end,"session",25)
    assert(session.InstanceState.OptionalBossEventActive == true,
        "TEMP event must be eligible")
    local char=wait_for(function()
        return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            and player.Character
    end,"character",18)
    local root=char.HumanoidRootPart
    local player_health=char:FindFirstChildOfClass("Humanoid")
    assert(player_health and player_health.Health>0,"normal player must be alive")
    local initial_player_health=player_health.Health
    local enemies=W:WaitForChild("DungeonGameplayRuntime"):WaitForChild("DungeonEnemies")
    local room1=anchor("Mine.Room1.Trigger")
    root.CFrame=room1.CFrame * CFrame.new(0,0,9)
    task.wait(0.2)
    player_health:MoveTo(room1.Position+Vector3.new(0,0,-2))
    local function encounter_state(id)
        local s=runtime.SessionService:get(session.SessionId)
        return s and s.InstanceState and s.InstanceState.EncounterRuntime
            and s.InstanceState.EncounterRuntime.EncounterStates[id]
    end
    wait_for(function() return encounter_state("CombatRoom1")=="Active" end,"Room1 trigger",10)
    local ordinary = wait_for(function()
        local result={}
        for _, model in ipairs(enemies:GetChildren()) do
            local h=model:FindFirstChildOfClass("Humanoid")
            if h and h.Health>0 then table.insert(result,model) end
        end
        return #result>0 and result or nil
    end,"Room1 enemies",10)
    -- Only the prerequisite combat pack uses debug defeat; the Event boss
    -- and player health are NEVER directly modified by this combat test.
    for _,model in ipairs(ordinary) do
        model:FindFirstChildOfClass("Humanoid").Health=0
    end
    wait_for(function() return encounter_state("CombatRoom1")=="Cleared" end,"Room1 cleared",10)
    local trigger=anchor("Mine.Event.Trigger")
    root.CFrame=trigger.CFrame * CFrame.new(0,0,9)
    task.wait(0.2)
    player_health:MoveTo(trigger.Position+Vector3.new(0,0,-2))
    wait_for(function()
        return encounter_state("AbandonedMineEventBossEncounter")=="Active"
    end,"Event encounter active",10)
    local boss=wait_for(function()
        for _,model in ipairs(enemies:GetChildren()) do
            if model:GetAttribute("BossId")=="AbandonedMineEventBoss" then
                local h=model:FindFirstChildOfClass("Humanoid")
                if h and h.Health>0 then return model end
            end
        end
    end,"Event boss spawned",10)
    local boss_humanoid=boss:FindFirstChildOfClass("Humanoid")
    local boss_root=boss:FindFirstChild("HumanoidRootPart")
    assert(boss_humanoid and boss_root,"Boss must have humanoid and root")
    local max_boss=boss_humanoid.Health
    -- Stage in melee range; after this only normal client attack requests
    -- via CombatInputActions are sent. Do not modify boss/player HP.
    root.CFrame=CFrame.lookAt(boss_root.Position+Vector3.new(0,0,4.8),
        boss_root.Position)
    player:SetAttribute("Phase4AttackEventBoss",true)
    print("[Phase4 Full Boss Combat] START normal player HP=" .. initial_player_health
        .. " boss HP=" .. max_boss)
    local low_boss_hp=max_boss
    local low_player_hp=initial_player_health
    local end_at=os.clock()+80
    repeat
        low_boss_hp=math.min(low_boss_hp,boss_humanoid.Health)
        low_player_hp=math.min(low_player_hp,player_health.Health)
        if player_health.Health <= 0 then
            break
        end
        if boss_humanoid.Health <= 0 then
            break
        end
        task.wait(0.16)
    until os.clock() >= end_at
    player:SetAttribute("Phase4AttackEventBoss",false)
    print("[Phase4 Full Boss Combat] HP boss=" .. boss_humanoid.Health
        .. "/" .. max_boss .. " minPlayer=" .. low_player_hp
        .. " currentPlayer=" .. player_health.Health .. "/" .. initial_player_health)
    assert(initial_player_health < 100000 and max_boss > 0,
        "Fight may not use artificial player health or invalid boss")
    assert(low_boss_hp < max_boss,
        "Normal client attack did not hit Event boss")
    if player_health.Health <= 0 then
        print("[Phase4 Full Boss Combat] PLAYER_DEFEATED_BOSS_REMAINS "
            .. boss_humanoid.Health)
        error("Normal-health solo player died before defeating Event boss")
    end
    assert(boss_humanoid.Health <= 0,
        "Normal-health solo player did not defeat Event boss within 80 seconds")
    wait_for(function()
        return encounter_state("AbandonedMineEventBossEncounter")=="Cleared"
    end, "real combat boss victory saved",12)
    print("[Phase4 Full Boss Combat] REAL_CLIENT_BOSS_CLEAR_PASS")
end
task.spawn(function()
    local ok,err=pcall(run)
    if not ok then warn("[Phase4 Normal Combat] FAIL " .. tostring(err)) end
    STS:EndTest(if ok then "PASS" else "FAIL "..tostring(err))
end)
task.delay(70,function() STS:EndTest("FAIL global timeout") end)
]=]
driver.Parent = SSS
print("[Phase4 Normal Combat] START_TEMP_PLAY")
local ok,result=pcall(function()
    return STS:ExecutePlayModeAsync("Phase4NormalEventCombat_TEMP")
end)
driver:Destroy()
client:Destroy()
assert(ok and result=="PASS","Normal combat live test failed: "..tostring(result))
print("[Phase4 Full Boss Combat] MINE_ATTACK_DODGE_VICTORY_PLAY_PASS")
