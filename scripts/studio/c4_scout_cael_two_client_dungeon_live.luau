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
channel.OnClientEvent:Connect(function(command, part)
    if command == "ATTACK" then
        local accepted = input.request_attack()
        channel:FireServer("ATTACK_RESULT", accepted)
    elseif command == "TALK_CAEL" then
        local prompt = part:WaitForChild("ScoutCaelQuestPrompt", 10)
        if not prompt then
            channel:FireServer("PROMPT_ERROR", "Missing Cael prompt")
            return
        end
        local ok, reason = pcall(function()
            prompt:InputHoldBegin()
            task.wait(0.55)
            prompt:InputHoldEnd()
        end)
        channel:FireServer(
            if ok then "PROMPT_HELD" else "PROMPT_ERROR",
            if ok then true else tostring(reason)
        )
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

--[[
Moves the test-only Elf profile directly to its next original rescue stage.

Args:
    profiles (any): Existing real Dungeon authoritative profile writer.
    elf (Player): Actual connected member with the selected Elf branch.

Returns:
    nil: Test-only starting state, not a gameplay quest-stage skip.
]]
local function seed_rescue_stage(profiles, elf)
    local ok, reason = profiles:mutate(elf.UserId, function(profile)
        local owner = profile.Characters.Slot1
        local state = owner.ClassAdvancement.OriginalFirstTransferQuest
        assert(state.Step == 3 and state.BranchId == "ElvenScout")
        state.Step = 5
        state.Count = 0
        for index = 1, 4 do
            state.Proofs["PriasLetter" .. tostring(index)] = true
        end
    end)
    assert(ok, "Test-only Scout rescue stage was rejected: "
        .. tostring(reason))
end

--[[
Requests a real client-held physical prompt with an isolated avatar.

Args:
    player (Player): Real selected Elf or unrelated Human member.
    part (BasePart): Real server-spawned physical Scout Cael placeholder.
    label (string): Expected prompt result for the current stage.

Returns:
    nil: Verifies a real client held the NPC ProximityPrompt.
]]
local function hold_cael(player, part, label)
    local root = assert(player.Character:FindFirstChild("HumanoidRootPart"))
    root.Anchored = true
    root.CFrame = part.CFrame * CFrame.new(0, 0, 4)
    local response_key = tostring(player.UserId) .. ":PROMPT_HELD"
    local failure_key = tostring(player.UserId) .. ":PROMPT_ERROR"
    responses[response_key] = nil
    responses[failure_key] = nil
    channel:FireClient(player, "TALK_CAEL", part)
    wait_for(function()
        assert(not responses[failure_key],
            "Client rescue prompt failed: " .. tostring(
                responses[failure_key]
            ))
        return responses[response_key]
    end, label, 14)
    task.wait(0.65)
end

--[[
Executes actual two-client Scout discovery, Warden combat and rescue.

Args:
    None.

Returns:
    nil: Asserts physical actor ownership, one ward sigil and consumption.
]]
local function run()
    local members = wait_for(function()
        local users = Players:GetPlayers()
        return if #users == 2 then users else nil
    end, "two real clients", 45)
    table.sort(members, function(first, second)
        return first.UserId < second.UserId
    end)
    local human, elf = members[1], members[2]
    local runtime = wait_for(function()
        return context.runtime
    end, "real Dungeon runtime", 35)
    local profiles = runtime.ProfileService
    local sessions = runtime.SessionService
    local session = wait_for(function()
        local current = sessions:get_for_user(human.UserId)
        if not current or current.State ~= "Active" then return nil end
        for _, player in ipairs(members) do
            local member = current.Members[tostring(player.UserId)]
            if not member or member.Mode ~= "Active"
                or not profiles:get_character(player.UserId)
                or not player.Character
                or not player.Character:FindFirstChild("HumanoidRootPart")
                or not responses[tostring(player.UserId) .. ":READY"]
            then
                return nil
            end
        end
        return current
    end, "both active physical dungeon members", 75)

    seed(profiles, human.UserId, "Human", "HumanRogue")
    seed(profiles, elf.UserId, "Elf", "ElvenScout")
    seed_rescue_stage(profiles, elf)
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
    local folder = WS.DungeonGameplayRuntime.DungeonEnemies
    local warden = wait_for(function()
        for _, enemy in ipairs(folder:GetChildren()) do
            if enemy:GetAttribute("SourceQuestMonsterId")
                == "BrackenWarden"
                and enemy:FindFirstChildOfClass("Humanoid")
                and enemy:FindFirstChildOfClass("Humanoid").Health > 0
            then return enemy end
        end
    end, "registered stage-six physical Bracken Warden", 18)
    local cael = wait_for(function()
        return WS.DungeonGameplayRuntime:FindFirstChild("ScoutCael")
    end, "genuine live dungeon Scout Cael actor", 12)
    print("[Scout Cael Live] PHYSICAL_RESCUE_ACTOR_AND_WARDEN_PASS")
    hold_cael(human, cael, "other branch's real prompt hold")
    assert(profiles:get_character(elf.UserId)
        .ClassAdvancement.OriginalFirstTransferQuest.Step == 5
        and profiles:get_character(human.UserId)
            .ClassAdvancement.OriginalFirstTransferQuest.Step == 3,
        "Rogue prompt bypassed Elf's rescue quest or advanced wrong branch")
    hold_cael(elf, cael, "owner stage-five physical prompt")
    wait_for(function()
        local owner = profiles:get_character(elf.UserId)
        local state = owner and owner.ClassAdvancement
            .OriginalFirstTransferQuest
        return state and state.Step == 6
    end, "authenticated Scout Cael discovery", 12)
    local elf_root = elf.Character.HumanoidRootPart
    warden.PrimaryPart.Anchored = true
    elf_root.CFrame = CFrame.lookAt(
        warden.PrimaryPart.Position + Vector3.new(0, 0, 4),
        warden.PrimaryPart.Position
    )
    local before = warden:FindFirstChildOfClass("Humanoid").Health
    channel:FireClient(elf, "ATTACK")
    wait_for(function()
        return responses[tostring(elf.UserId) .. ":ATTACK_RESULT"]
    end, "real Scout client normal attack", 12)
    wait_for(function()
        return warden:FindFirstChildOfClass("Humanoid").Health < before
    end, "real Scout client hit on Bracken Warden", 18)
    assert(genuine_damage(elf, warden, 1000) > 0,
        "Actual Elf participant could not finish authentic Warden combat")
    local owner = wait_for(function()
        local character = profiles:get_character(elf.UserId)
        local state = character and character.ClassAdvancement
            .OriginalFirstTransferQuest
        return if state and state.Step == 7 then character else nil
    end, "personally earned sigil after real Warden defeat", 12)
    assert(inventory.count_item(owner, "bracken_ward_sigil") == 1
        and inventory.count_item(
            profiles:get_character(human.UserId), "bracken_ward_sigil"
        ) == 0 and owner.ClassAdvancement
            .OriginalFirstTransferQuest.Proofs.RustedKey == true,
        "Warden reward must be exactly one owner-bound genuine sigil")
    print("[Scout Cael Live] REAL_WARDEN_OWNER_BOUND_SIGIL_PASS")
    assert(profiles:mutate(elf.UserId, function(profile)
        assert(inventory.apply_remove_from_character(
            profile.Characters.Slot1, "bracken_ward_sigil", 1
        ).ok)
    end), "Prepare missing-sigil refusal in disposable live fixture")
    hold_cael(elf, cael, "missing owner ward sigil prompt")
    assert(profiles:get_character(elf.UserId)
        .ClassAdvancement.OriginalFirstTransferQuest.Step == 7,
        "Scout Cael must refuse to free a player with no personal sigil")
    assert(profiles:mutate(elf.UserId, function(profile)
        assert(inventory.apply_item_to_character(
            profile.Characters.Slot1, "bracken_ward_sigil", 1
        ).ok)
    end), "Restore genuine previously earned test-owner ward sigil")
    hold_cael(elf, cael, "real owner rescue prompt")
    local rescued = wait_for(function()
        local character = profiles:get_character(elf.UserId)
        local state = character and character.ClassAdvancement
            .OriginalFirstTransferQuest
        return if state and state.Step == 8 then character else nil
    end, "genuine physical Scout Cael rescue", 12)
    assert(inventory.count_item(rescued, "bracken_ward_sigil") == 0
        and rescued.Identity.ClassId == "Fighter"
        and rescued.ClassAdvancement.ActiveClassId == nil
        and profiles:get_character(human.UserId)
            .ClassAdvancement.OriginalFirstTransferQuest.Step == 3,
        "Rescue must consume exactly the owner's key without class leakage")
    hold_cael(elf, cael, "replayed physical rescue prompt")
    assert(profiles:get_character(elf.UserId)
        .ClassAdvancement.OriginalFirstTransferQuest.Step == 8,
        "Repeated Scout Cael prompt must not skip hub reports")
    print("[Scout Cael Live] VERIFIED_TWO_CLIENT_PHYSICAL_RESCUE_PASS")
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
        2, "C4ScoutCaelRealDungeonTwoClients_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
context:Destroy()
assert(ok and result == "PASS",
    "Real two-client quest combat failed: " .. tostring(result))
print("[Scout Cael Live] VERIFIED_TWO_CLIENT_SCOUT_RESCUE_PASS")
