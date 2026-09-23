--!strict
-- Actual client-held Ironvow Base NPCs, transfer mentor and trainer.
-- Previous monster loot is seeded only in the disposable test instance.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Run only in an unpublished disposable Base Studio place")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local base = SSS.Base.BaseRuntime
local anchor = 'local runtime = RuntimeServices.new("Base")'
local source = base.Source
local index = assert(string.find(source, anchor, 1, true))
assert(not string.find(source, anchor, index + #anchor, true))
base.Source = source:sub(1, index + #anchor - 1)
    .. '\n_G.IronvowPhysicalRuntime_TEMP = runtime\n'
    .. source:sub(index + #anchor)

local signal = Instance.new("RemoteEvent")
signal.Name = "IronvowPhysicalSignal_TEMP"
signal.Parent = RS
local client = Instance.new("LocalScript")
client.Name = "IronvowPhysicalClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local signal = RS:WaitForChild("IronvowPhysicalSignal_TEMP")
local shown = {}
local prompts = game:GetService("ProximityPromptService")
prompts.PromptShown:Connect(function(prompt) shown[prompt] = true end)
prompts.PromptHidden:Connect(function(prompt) shown[prompt] = nil end)
RS.Core.Remotes.ProgressionActionResult.OnClientEvent:Connect(
    function(event)
        if event.action == "SkillLearn" then
            signal:FireServer("SKILL_RESULT", event)
        end
    end
)
signal.OnClientEvent:Connect(function(action, part)
    if action == "LEARN" then
        RS.Core.Remotes.SkillLearnRequest:FireServer(
            "IronvowTrainer", "IronvowDrivingStrike"
        )
        return
    end
    if action ~= "HOLD" then return end
    local prompt = part:FindFirstChildOfClass("ProximityPrompt")
    if not prompt then signal:FireServer("FAIL", "No prompt") return end
    local deadline = os.clock() + 6
    repeat
        if shown[prompt] then break end
        task.wait(0.1)
    until os.clock() >= deadline
    signal:FireServer("PROMPT_VISIBLE", shown[prompt] == true)
    local ok, err = pcall(function()
        prompt:InputHoldBegin()
        task.wait(0.55)
        prompt:InputHoldEnd()
    end)
    signal:FireServer(if ok then "HELD" else "FAIL", err)
end)
signal:FireServer("READY")
]==]
client.Parent = SPS
local driver = Instance.new("Script")
driver.Name = "IronvowPhysicalServer_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local STS = game:GetService("StudioTestService")
local SSS = game:GetService("ServerScriptService")
local signal = RS.IronvowPhysicalSignal_TEMP
local selection = require(
    SSS.Core.Services.C4FirstTransferSelectionService
)
local inv = require(SSS.Core.Services.InventoryService)
local definitions = require(
    RS.Core.Shared.OriginalFirstTransferDefinitions
)
local responses = {}
signal.OnServerEvent:Connect(function(player, action, payload)
    responses[action] = if payload == nil then true else payload
end)

-- Args: predicate (() -> any), label (string), seconds (number).
-- Returns: any; actual observed game result or a bounded failure.
local function await_state(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local result = predicate()
        if result then return result end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Ironvow Physical] TIMEOUT " .. label)
end

-- Args: player (Player), part (BasePart).
-- Returns: nil; authentic client-visible, client-held physical prompt.
local function hold(player, part)
    local root = assert(player.Character.HumanoidRootPart)
    root.CFrame = part.CFrame * CFrame.new(0, 0, 4)
    root.AssemblyLinearVelocity = Vector3.zero
    responses.PROMPT_VISIBLE = nil
    responses.HELD = nil
    task.wait(0.6)
    signal:FireClient(player, "HOLD", part)
    await_state(function()
        return responses.HELD or responses.FAIL
    end, "client held " .. part.Name, 12)
    assert(responses.FAIL == nil
        and responses.PROMPT_VISIBLE == true,
        "Authentic NPC ProximityPrompt was not client-visible/held")
end

-- Args: profiles (any), player (Player).
-- Returns: nil; previous personal monster loot only in disposable test.
local function seed_prior_combat(profiles, player)
    assert(profiles:mutate(player.UserId, function(profile)
        local character = profile.Characters.Slot1
        local quest = character.ClassAdvancement
            .OriginalFirstTransferQuest
        quest.Step = 4
        quest.Count = 0
        quest.Proofs.IronrootToken4 = true
        for _ = 1, 4 do
            assert(inv.apply_item_to_character(
                character, "ironroot_dispatch_marker", 1
            ).ok)
        end
    end), "Cannot prepare previously earned test-only raider materials")
end

-- Args: None.
-- Returns: nil; complete actual player physical source and class prompts.
local function run()
    local player = await_state(function()
        return Players:GetPlayers()[1]
    end, "actual client", 40)
    local runtime = await_state(function()
        return _G.IronvowPhysicalRuntime_TEMP
    end, "actual Base runtime", 30)
    local profiles = runtime.ProfileService
    await_state(function()
        return profiles:get_character(player.UserId)
            and player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
            and responses.READY
    end, "admitted Base player", 60)
    assert(profiles:mutate(player.UserId, function(profile)
        local owner = profile.Characters.Slot1
        owner.Level = 18
        owner.Identity = {
            Version = 1, RaceId = "Human",
            BaseClassId = "Fighter", ClassId = "Fighter",
            CreationStage = "Complete",
        }
    end), "Cannot create disposable level-18 Human Fighter")
    assert(selection.new(profiles, "Base"):choose(
        player.UserId, "HumanWarrior"
    ).ok, "Player could not select Human Warrior")
    local npcs = workspace:WaitForChild("C4OriginalSourceQuestNPCs")
    hold(player, assert(npcs:FindFirstChild("MarshalTorren")))
    await_state(function()
        local owner = profiles:get_character(player.UserId)
        local state = owner.ClassAdvancement.OriginalFirstTransferQuest
        return state and state.Step == 2
    end, "physical first Warrior NPC step", 12)
    hold(player, assert(npcs:FindFirstChild("SmithOrla")))
    await_state(function()
        return profiles:get_character(player.UserId)
            .ClassAdvancement.OriginalFirstTransferQuest.Step == 3
    end, "physical second Warrior NPC step", 12)
    print("[Ironvow Physical] REAL_NPC_START_PASS")
    seed_prior_combat(profiles, player)
    hold(player, assert(npcs:FindFirstChild("SmithOrla")))
    await_state(function()
        local owner = profiles:get_character(player.UserId)
        return owner.ClassAdvancement.OriginalFirstTransferQuest.Step == 5
            and inv.count_item(
                owner, "ironroot_dispatch_marker"
            ) == 0
    end, "genuine four-marker turn-in", 12)
    assert(profiles:mutate(player.UserId, function(profile)
        local owner = profile.Characters.Slot1
        local state = owner.ClassAdvancement.OriginalFirstTransferQuest
        state.Step = 6
        state.Proofs.RidgebreakerSigil = true
        assert(inv.apply_item_to_character(
            owner, "ridgebreaker_oath_seal", 1
        ).ok)
    end), "Cannot prepare previously earned test-only boss seal")
    hold(player, assert(npcs:FindFirstChild("MarshalTorren")))
    await_state(function()
        local owner = profiles:get_character(player.UserId)
        return owner.ClassAdvancement.OriginalFirstTransferQuest.Ready
            and inv.count_item(
                owner, "ridgebreaker_oath_seal"
            ) == 0
    end, "genuine final boss seal turn-in", 12)
    print("[Ironvow Physical] REAL_OWNER_ITEM_TURNINS_PASS")
    local stations = workspace:WaitForChild(
        "OriginalFirstTransferMentors"
    )
    local mentor = assert(stations:FindFirstChild("MarshalTorren"))
    hold(player, mentor)
    assert(profiles:get_character(player.UserId).Identity.ClassId
        == "Fighter", "Physical mentor ignored minimum class level")
    assert(profiles:mutate(player.UserId, function(profile)
        local owner = profile.Characters.Slot1
        owner.Level = 20
        owner.Progression.SkillPointEntitlement = 2000
        owner.Progression.Skills.IronCleave = {
            Known = true, PurchasedRank = 9, Proficiency = 350,
        }
    end), "Cannot prepare real level-20 starter skill prerequisites")
    task.wait(0.75)
    hold(player, mentor)
    await_state(function()
        return definitions.awarded(
            profiles:get_character(player.UserId)
        ) == definitions.for_branch("HumanWarrior")
    end, "authentic level-20 Warrior physical mentor award", 12)
    print("[Ironvow Physical] REAL_MENTOR_CLASS_PASS")
    local trainer = assert(stations:FindFirstChild("IronvowTrainer"))
    hold(player, trainer)
    responses.SKILL_RESULT = nil
    signal:FireClient(player, "LEARN")
    await_state(function()
        return responses.SKILL_RESULT
    end, "real client trainer SkillLearnRequest", 12)
    assert(responses.SKILL_RESULT.ok
        and profiles:get_character(player.UserId).Progression
            .Skills.IronvowDrivingStrike.PurchasedRank == 1,
        "Client could not purchase its original Warrior first rank")
    print("[Ironvow Physical] REAL_CLIENT_TRAINER_PURCHASE_PASS")
end
task.spawn(function()
    local ok, err = pcall(run)
    if not ok then warn("[Ironvow Physical] FAIL " .. tostring(err)) end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(err))
end)
task.delay(125, function()
    STS:EndTest("FAIL Ironvow physical Base global timeout")
end)
]==]
driver.Parent = SSS
local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        1, "IronvowActualPhysicalBase_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
signal:Destroy()
assert(ok and result == "PASS",
    "Ironvow live physical Base acceptance failed: " .. tostring(result))
print("[Ironvow Physical] VERIFIED_LIVE_BASE_PASS")
