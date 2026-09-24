--!strict
-- Two real unpublished clients and the unchanged Dungeon combat runtime.
-- All source injections and prepared level-18 profiles are disposable.
-- The two genuine clients land first hits; only the final damaging
-- strike is a server-owned test shortcut, not a fully client kill.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Source quest live test must use a local, unpublished Studio place.")

local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local runtime_source = SSS.Dungeon.DungeonRuntime

--[[
Replaces one exact source anchor inside the disposable Studio instance.

Args:
    original (string): Unique audited DungeonRuntime source statement.
    replacement (string): Test-only in-memory source replacement.

Returns:
    nil: Fails if the source has changed or contains repeated anchors.
]]
local function replace_once(original: string, replacement: string)
    local source = runtime_source.Source
    local start = assert(string.find(source, original, 1, true))
    assert(not string.find(
        source, original, start + #original, true
    ), "Dungeon source injection anchor is ambiguous.")
    runtime_source.Source = source:sub(1, start - 1)
        .. replacement .. source:sub(start + #original)
end

local context = Instance.new("ModuleScript")
context.Name = "GreenwardCombatContext_TEMP"
context.Source = "return {}"
context.Parent = SSS.Dungeon

replace_once(
    'local runtime = RuntimeServices.new("Dungeon")',
    'local runtime = RuntimeServices.new("Dungeon")\n'
        .. 'require(script.Parent.GreenwardCombatContext_TEMP)'
        .. '.runtime = runtime'
)
replace_once(
    '    if RunService:IsStudio() then\n'
        .. '        local studio = StudioSessionFactory.create_for_players(\n'
        .. '            {player},',
    '    if RunService:IsStudio() then\n'
        .. '        while #Players:GetPlayers() < 2 do task.wait(0.1) end\n'
        .. '        local studio = StudioSessionFactory.create_for_players(\n'
        .. '            Players:GetPlayers(),'
)

WS:SetAttribute("DungeonMMOStudioDungeonId", "TestDungeon")
WS:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
WS:SetAttribute("DungeonMMOStudioBaseClass", "Fighter")
WS:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
WS:SetAttribute("DungeonMMOPlaceholderPlayableEnabled", true)

local channel = Instance.new("RemoteEvent")
channel.Name = "GreenwardCombatChannel_TEMP"
channel.Parent = RS


local client = Instance.new("LocalScript")
client.Name = "GreenwardCombatClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local input = require(
    script.Parent:WaitForChild("Combat")
        :WaitForChild("CombatInputActions")
)
local channel = RS:WaitForChild("GreenwardCombatChannel_TEMP")
channel.OnClientEvent:Connect(function(command)
    if command == "ATTACK" then
        local accepted = input.request_attack()
        channel:FireServer("ATTACK_SENT", accepted)
    end
end)
channel:FireServer("READY")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "GreenwardCombatServer_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local CS = game:GetService("CollectionService")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local channel = RS.GreenwardCombatChannel_TEMP
local context = require(SSS.Dungeon.GreenwardCombatContext_TEMP)
local sources = require(RS.Core.Shared.C4OriginalFirstTransferQuestStages)
local inventory = require(SSS.Core.Services.InventoryService)
local damage = require(SSS.Combat.DamageService)
local responses = {}

--[[
Receives acknowledgement only, never client-authored quest proof.

Args:
    player (Player): Authenticated client giving attack transport receipt.
    action (string): Ready or normal attack sent.
    accepted (any): Client UI input request return for diagnostics.

Returns:
    nil: Saves a test-only transport receipt, not server damage or loot.
]]
local function on_response(player, action, accepted)
    responses[tostring(player.UserId) .. ":" .. action] =
        accepted or true
end
channel.OnServerEvent:Connect(on_response)

--[[
Waits for an authoritative live room, avatar or personal quest drop.

Args:
    predicate (() -> any): Real world or loaded owner profile observation.
    label (string): Missing acceptance condition.
    seconds (number): Maximum wall-clock wait.

Returns:
    any: First observed actual server result or explicit test failure.
]]
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local observed = predicate()
        if observed then return observed end
        task.wait(0.12)
    until os.clock() >= deadline
    error("[Greenward Live] TIMEOUT " .. label)
end

--[[
Seeds only prior source NPC progress in isolated unpublished profiles.

Args:
    profiles (any): Actual exclusive Dungeon profile writer.
    player (Player): One genuine already admitted Studio client.
    stage (number): Three for marauder or five for the distinct boss.

Returns:
    nil: Fighter remains unadvanced and no quest loot is pre-granted.
]]
local function prepare(profiles, player, stage)
    local source = assert(sources.get("ElvenKnight"))
    local prepared, reason = profiles:mutate(
        player.UserId, function(profile)
            local owner = profile.Characters.Slot1
            owner.Identity = {
                Version = 1, RaceId = "Elf",
                BaseClassId = "Fighter", ClassId = "Fighter",
                CreationStage = "Complete",
            }
            owner.Level = 18
            owner.Equipment.Weapon = "marauder_sword"
            owner.ClassAdvancement.OriginalFirstTransferChoiceId =
                "ElvenKnight"
            owner.ClassAdvancement.OriginalFirstTransferQuest = {
                QuestId = source.Id, BranchId = "ElvenKnight",
                Step = stage, Count = 0, Ready = false,
                AppliedEvents = {},
                Proofs = if stage == 5
                    then {VerdantPatrolReports3 = true} else {},
            }
        end
    )
    assert(prepared, "Disposable Warden source fixture rejected: "
        .. tostring(reason))
end

--[[
Uses the unchanged server combat damage path after a real client hit.

Args:
    player (Player): Original real owner whose attack already hit target.
    enemy (Model): Current-room registered physical source enemy.
    amount (number): Server-only lethal hit for test time reduction.

Returns:
    number: Actual authenticated server damage after defence.
]]
local function finish_enemy(player, enemy, amount)
    return damage.apply_damage({
        attacker = player,
        attacker_character = player.Character,
        target = enemy,
        source_kind = "Melee",
        source_id = "GreenwardWorldLiveTest",
        attack_id = "Slash1",
        base_damage = amount,
        multiplier = 1,
    })
end

--[[
Makes a genuine client normal attack hit its registered personal quest enemy.

Args:
    player (Player): Live admitted source quest owner and combat client.
    enemy (Model): Server-owned living marauder or ridgebreaker.

Returns:
    nil: Confirms a physical client hit before server test finishing blow.
]]
local function strike_and_finish(player, enemy)
    local humanoid = assert(enemy:FindFirstChildOfClass("Humanoid"))
    local root = assert(enemy.PrimaryPart)
    root.Anchored = true
    local player_root = assert(player.Character.HumanoidRootPart)
    player_root.CFrame = CFrame.lookAt(
        root.Position + Vector3.new(0, 0, 4),
        root.Position
    )
    player_root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.3)
    local initial_health = humanoid.Health
    responses[tostring(player.UserId) .. ":ATTACK_SENT"] = nil
    channel:FireClient(player, "ATTACK")
    wait_for(function()
        return responses[tostring(player.UserId) .. ":ATTACK_SENT"]
    end, "genuine owner client attack sent", 12)
    wait_for(function()
        return humanoid.Health < initial_health
    end, "real first-hit damage to original quest physical enemy", 15)
    assert(finish_enemy(player, enemy, 1000) > 0,
        "Authenticated player contributor could not finish quest enemy")
end

--[[
Checks separate real player-owned marauder marker and unique boss seal.

Args:
    profiles (any): Exclusive live instanced Dungeon profile authority.
    marauder_owner (Player): Actual client at Warden source step three.
    boss_owner (Player): Actual client at Warden source step five.
    enemies (Folder): Current real Dungeon encounter enemy models.

Returns:
    nil: Verifies personal drops, stage changes and zero cross-owner loot.
]]
local function verify_warden_drops(
    profiles, marauder_owner, boss_owner, enemies
)
    local marauder = nil
    local boss = nil
    for _, enemy in ipairs(enemies:GetChildren()) do
        local source_id = enemy:GetAttribute("SourceQuestMonsterId")
        if source_id == "RootboundMarauder" and not marauder then
            marauder = enemy
        elseif source_id == "ThornboundColossus" then
            boss = enemy
        end
    end
    assert(marauder and boss, "Original Warden marauder/boss spawn missing")
    assert(marauder:IsDescendantOf(workspace)
        and boss:IsDescendantOf(workspace),
        "Quest kills must be real registered physical enemy instances")
    strike_and_finish(marauder_owner, marauder)
    wait_for(function()
        return inventory.count_item(
            profiles:get_character(marauder_owner.UserId),
            "verdant_patrol_report"
        ) == 1
    end, "first genuinely earned personal Greenward marker", 12)
    assert(inventory.count_item(
        profiles:get_character(boss_owner.UserId),
        "verdant_patrol_report"
    ) == 0, "Other player's independent boss stage received marauder loot")
    print("[Greenward Live] REAL_STRIKER_CLIENT_HIT_OWNER_MARKER_PASS")

    strike_and_finish(boss_owner, boss)
    wait_for(function()
        local owner = profiles:get_character(boss_owner.UserId)
        local quest = owner.ClassAdvancement.OriginalFirstTransferQuest
        return quest.Step == 6 and inventory.count_item(
            owner, "verdant_guardian_seal"
        ) == 1
    end, "real boss life grants exactly one personal guardian seal", 12)
    assert(inventory.count_item(
        profiles:get_character(marauder_owner.UserId),
        "verdant_guardian_seal"
    ) == 0, "Marauder-stage player cannot collect unrelated boss seal")
    print("[Greenward Live] REAL_BOSS_CLIENT_HIT_OWNER_SEAL_PASS")
end

--[[
Runs two independently staged original Wardens in one real party instance.

Args:
    None.

Returns:
    nil: Only genuinely hit room enemies yield owner-bound quest items.
]]
local function main()
    local members = wait_for(function()
        local online = Players:GetPlayers()
        return if #online == 2 then online else nil
    end, "two authenticated actual Studio clients", 45)
    table.sort(members, function(a, b)
        return a.UserId < b.UserId
    end)
    local marauder_owner, boss_owner = members[1], members[2]
    local runtime = wait_for(function()
        return context.runtime
    end, "real Dungeon runtime", 35)
    local profiles = runtime.ProfileService
    local sessions = runtime.SessionService
    local session = wait_for(function()
        local run = sessions:get_for_user(marauder_owner.UserId)
        if not run or run.State ~= "Active" then return nil end
        for _, player in ipairs(members) do
            local member = run.Members[tostring(player.UserId)]
            if not member or member.Mode ~= "Active"
                or not profiles:get_character(player.UserId)
                or not player.Character
                or not player.Character:FindFirstChild("HumanoidRootPart")
                or not responses[tostring(player.UserId) .. ":READY"]
            then
                return nil
            end
        end
        return run
    end, "active admitted two-member instance", 75)
    prepare(profiles, marauder_owner, 3)
    prepare(profiles, boss_owner, 5)
    for _, player in ipairs(members) do
        local humanoid = player.Character:FindFirstChildOfClass(
            "Humanoid"
        )
        humanoid.MaxHealth = 2500
        humanoid.Health = 2500
    end
    local trigger = wait_for(function()
        for _, part in ipairs(CS:GetTagged(
            "DungeonMMOEnvironmentAnchor"
        )) do
            if part:GetAttribute("AnchorId") == "Temple.Room1.Trigger"
            then return part end
        end
    end, "actual instanced first room trigger", 22)
    for _, player in ipairs(members) do
        player.Character.HumanoidRootPart.CFrame =
            trigger.CFrame * CFrame.new(0, 0, 9)
        task.wait(0.15)
        player.Character:FindFirstChildOfClass("Humanoid"):MoveTo(
            trigger.Position + Vector3.new(0, 0, -2)
        )
    end
    wait_for(function()
        local run = sessions:get(session.SessionId)
        local progress = run and run.InstanceState
            and run.InstanceState.EncounterRuntime
        return progress and progress.EncounterStates
            and progress.EncounterStates.CombatRoom1 == "Active"
    end, "real dungeon enemy room active", 18)
    local enemies = WS.DungeonGameplayRuntime.DungeonEnemies
    wait_for(function()
        local ordinary = 0
        local boss_count = 0
        for _, enemy in ipairs(enemies:GetChildren()) do
            local id = enemy:GetAttribute("SourceQuestMonsterId")
            if id == "RootboundMarauder" then ordinary += 1
            elseif id == "ThornboundColossus" then boss_count += 1 end
        end
        return ordinary == 2 and boss_count == 1
    end, "owned stage-three pack and unique stage-five boss", 15)
    verify_warden_drops(
        profiles, marauder_owner, boss_owner, enemies
    )
    print("[Greenward Live] TWO_CLIENT_ORIGINAL_WORLD_PROOFS_PASS")
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then warn("[Greenward Live] FAIL " .. tostring(reason)) end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(155, function()
    STS:EndTest("FAIL global Greenward source world timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        2, "GreenwardSourceCombatTwoClients_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
context:Destroy()
assert(ok and result == "PASS",
    "Greenward real source combat failed: " .. tostring(result))
print("[Greenward Live] VERIFIED_TWO_CLIENT_WORLD_PROOFS_PASS")
