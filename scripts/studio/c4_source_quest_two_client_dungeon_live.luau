--!strict
-- Two real unpublished clients and the unchanged Dungeon combat runtime.
-- All source injections and fake level-18 profiles live in a temp Studio place.
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
context.Name = "C4SourceLiveContext_TEMP"
context.Source = "return {}"
context.Parent = SSS.Dungeon

replace_once(
    'local runtime = RuntimeServices.new("Dungeon")',
    'local runtime = RuntimeServices.new("Dungeon")\n'
        .. 'require(script.Parent.C4SourceLiveContext_TEMP)'
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
channel.Name = "C4SourceLiveChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "C4SourceLiveClient_TEMP"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local input = require(
    script.Parent:WaitForChild("Combat"):WaitForChild(
        "CombatInputActions"
    )
)
local channel = RS:WaitForChild("C4SourceLiveChannel_TEMP")
channel.OnClientEvent:Connect(function(command)
    if command == "ATTACK" then
        local accepted = input.request_attack()
        channel:FireServer("ATTACK_RESULT", accepted)
    end
end)
channel:FireServer("READY")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "C4SourceLiveServer_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local CS = game:GetService("CollectionService")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local channel = RS.C4SourceLiveChannel_TEMP
local context = require(SSS.Dungeon.C4SourceLiveContext_TEMP)
local stages = require(RS.Core.Shared.C4OriginalFirstTransferQuestStages)
local inventory = require(SSS.Core.Services.InventoryService)
local damage = require(SSS.Combat.DamageService)
local responses = {}

channel.OnServerEvent:Connect(function(player, command, value)
    responses[tostring(player.UserId) .. ":" .. command] = value or true
end)

-- Args: predicate (() -> any), label (string), seconds (number).
-- Returns: any; observed actual authoritative server state.
local function wait_for(predicate, label, seconds)
    local until_time = os.clock() + seconds
    repeat
        local value = predicate()
        if value then return value end
        task.wait(0.12)
    until os.clock() >= until_time
    error("[C4 Source Two Client] TIMEOUT " .. label)
end

-- Args: user_id (number), profiles (any), race (string), branch (string).
-- Returns: nil; makes an unpublished original level-18 stage-three avatar.
local function seed(profiles, user_id, race, branch)
    local source = assert(stages.get(branch))
    local ok, why = profiles:mutate(user_id, function(profile)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1, RaceId = race, BaseClassId = "Fighter",
            ClassId = "Fighter", CreationStage = "Complete",
        }
        character.Level = 18
        character.ClassAdvancement.OriginalFirstTransferChoiceId = branch
        character.ClassAdvancement.OriginalFirstTransferQuest = {
            QuestId = source.Id, BranchId = branch,
            Step = 3, Count = 0, Ready = false,
            AppliedEvents = {}, Proofs = {},
        }
        if branch == "HumanRogue" then
            for _, item_id in ipairs({
                "neti_trial_dagger", "neti_trial_bow",
            }) do
                assert(inventory.apply_item_to_character(
                    character, item_id, 1
                ).ok)
            end
            character.Equipment.Weapon = "neti_trial_dagger"
        end
    end)
    assert(ok, "Temp quest stage seed failed: " .. tostring(why))
    local owned = assert(profiles:get_character(user_id))
    assert(owned.ClassAdvancement.OriginalFirstTransferQuest.Step == 3,
        "Profile migration unexpectedly rejected stage-three test state")
end

-- Args: id (string); real environment anchor ID.
-- Returns: BasePart; physically present dungeon trigger.
local function anchor(id)
    return wait_for(function()
        for _, part in ipairs(
            CS:GetTagged("DungeonMMOEnvironmentAnchor")
        ) do
            if part:GetAttribute("AnchorId") == id then return part end
        end
    end, id, 22)
end

-- Args: player (Player), enemy (Model), amount (number).
-- Returns: number; damage applied by unchanged server DamageService.
local function genuine_damage(player, enemy, amount)
    return damage.apply_damage({
        attacker = player,
        attacker_character = player.Character,
        target = enemy,
        source_kind = "Melee",
        source_id = "QuestLiveCombatTest",
        attack_id = "Slash1",
        base_damage = amount,
        multiplier = 1,
    })
end

-- Args: profiles (any), player (Player), branch (string), item_id (string).
-- Returns: nil; checks exactly one earned quest item and correct owner.
local function assert_one_drop(profiles, player, branch, item_id)
    local owned = profiles:get_character(player.UserId)
    local quest = owned.ClassAdvancement.OriginalFirstTransferQuest
    assert(quest.BranchId == branch and quest.Step == 3
        and quest.Count == 1
        and inventory.count_item(owned, item_id) == 1
        and owned.Identity.ClassId == "Fighter",
        "Genuine registered death did not atomically grant rightful loot")
end

-- Args: None.
-- Returns: nil; two real clients fight separate physical challenge targets.
local function run()
    local members = wait_for(function()
        local users = Players:GetPlayers()
        return if #users == 2 then users else nil
    end, "two real clients", 45)
    table.sort(members, function(a, b)
        return a.UserId < b.UserId
    end)
    local human, elf = members[1], members[2]
    local runtime = wait_for(function()
        return context.runtime
    end, "live Dungeon runtime", 35)
    local profiles = runtime.ProfileService
    local sessions = runtime.SessionService
    local session = wait_for(function()
        local existing = sessions:get_for_user(human.UserId)
        if not existing or existing.State ~= "Active" then return nil end
        for _, player in ipairs(members) do
            local member = existing.Members[tostring(player.UserId)]
            if not member or member.Mode ~= "Active"
                or not profiles:get_character(player.UserId)
                or not player.Character
                or not player.Character:FindFirstChild("HumanoidRootPart")
                or not responses[tostring(player.UserId) .. ":READY"]
            then
                return nil
            end
        end
        return existing
    end, "active real two-person instanced party", 75)

    seed(profiles, human.UserId, "Human", "HumanRogue")
    seed(profiles, elf.UserId, "Elf", "ElvenScout")
    for _, player in ipairs(members) do
        local humanoid =
            player.Character:FindFirstChildOfClass("Humanoid")
        humanoid.MaxHealth = 2500
        humanoid.Health = 2500
    end

    local trigger = anchor("Temple.Room1.Trigger")
    for _, player in ipairs(members) do
        local root = player.Character.HumanoidRootPart
        root.CFrame = trigger.CFrame * CFrame.new(0, 0, 9)
        task.wait(0.15)
        player.Character:FindFirstChildOfClass("Humanoid"):MoveTo(
            trigger.Position + Vector3.new(0, 0, -2)
        )
    end
    wait_for(function()
        local current = sessions:get(session.SessionId)
        local state = current and current.InstanceState
        local progress = state and state.EncounterRuntime
        return progress and progress.EncounterStates
            and progress.EncounterStates.CombatRoom1 == "Active"
    end, "real room-one combat encounter", 16)

    local folder = WS.DungeonGameplayRuntime.DungeonEnemies
    local enemies = wait_for(function()
        local targets = {CryptSentinel = {}, BrackenRaider = {}}
        for _, enemy in ipairs(folder:GetChildren()) do
            local source_id = enemy:GetAttribute(
                "SourceQuestMonsterId"
            )
            local group = targets[source_id]
            if group then table.insert(group, enemy) end
        end
        if #targets.CryptSentinel == 2
            and #targets.BrackenRaider == 2
        then return targets end
    end, "both genuinely registered quest-monster groups", 15)
    print("[C4 Source Two Client] PHYSICAL_MIXED_PARTY_QUEST_SPAWN_PASS")

    local rogue_enemy = enemies.CryptSentinel[1]
    local elf_enemy = enemies.BrackenRaider[1]
    local wrong = genuine_damage(human, elf_enemy, 1000)
    assert(wrong > 0
        and inventory.count_item(
            profiles:get_character(human.UserId), "prias_letter_1"
        ) == 0
        and profiles:get_character(elf.UserId)
            .ClassAdvancement.OriginalFirstTransferQuest.Count == 0,
        "Other branch or noncontributing owner gained quest drops")
    local rogue_humanoid =
        rogue_enemy:FindFirstChildOfClass("Humanoid")
    local root = human.Character.HumanoidRootPart
    rogue_enemy.PrimaryPart.Anchored = true
    root.CFrame = CFrame.lookAt(
        rogue_enemy.PrimaryPart.Position + Vector3.new(0, 0, 4),
        rogue_enemy.PrimaryPart.Position
    )
    local before = rogue_humanoid.Health
    channel:FireClient(human, "ATTACK")
    wait_for(function()
        return responses[tostring(human.UserId) .. ":ATTACK_RESULT"]
    end, "genuine client normal-attack request", 12)
    wait_for(function()
        return rogue_humanoid.Health < before
    end, "real client attack hits physical quest enemy", 18)
    print("[C4 Source Two Client] CLIENT_NORMAL_ATTACK_HIT_PASS")
    assert(genuine_damage(human, rogue_enemy, 1000) > 0,
        "Actual participant's server damage did not defeat sentinel")
    wait_for(function()
        local owner = profiles:get_character(human.UserId)
        return owner and inventory.count_item(
            owner, "spartoi_bone"
        ) == 1
    end, "first personal crypt-fragment drop", 12)
    assert_one_drop(profiles, human, "HumanRogue", "spartoi_bone")

    assert(genuine_damage(elf, enemies.BrackenRaider[2], 1000) > 0,
        "Actual Elf contributor did not defeat Bracken Raider")
    wait_for(function()
        local owner = profiles:get_character(elf.UserId)
        return owner and inventory.count_item(
            owner, "prias_letter_1"
        ) == 1
    end, "first personal field-report fragment", 12)
    assert_one_drop(profiles, elf, "ElvenScout", "prias_letter_1")
    assert(inventory.count_item(
        profiles:get_character(human.UserId), "prias_letter_1"
    ) == 0 and inventory.count_item(
        profiles:get_character(elf.UserId), "spartoi_bone"
    ) == 0, "Cross-branch source loot leaked to the other client")
    assert(profiles:get_character(human.UserId)
        .ClassAdvancement.ActiveClassId == nil
        and profiles:get_character(elf.UserId)
            .ClassAdvancement.ActiveClassId == nil,
        "Source combat awarded an unfinished first class transfer")
    print("[C4 Source Two Client] REAL_HIT_AND_OWNER_BOUND_DROPS_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then warn("[C4 Source Two Client] FAIL " .. tostring(reason)) end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(155, function()
    STS:EndTest("FAIL global two-client source-combat timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        2, "C4SourceQuestRealDungeonTwoClients_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
context:Destroy()
assert(ok and result == "PASS",
    "Real two-client quest combat failed: " .. tostring(result))
print("[C4 Source Two Client] VERIFIED_REAL_DUNGEON_COMBAT_PASS")
