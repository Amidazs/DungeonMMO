--!strict
-- Real unpublished Base client -> physical ProximityPrompt -> original
-- source-quest stage one -> persistent profile; source stage two is next.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Original C4 physical quest NPC test needs an unpublished place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")
local original_runtime = SSS.Base.BaseRuntime
local source = original_runtime.Source

--[[
Temporarily exposes one already-created production service in the
disposable Studio clone, never in committed original game runtime.

Args:
    anchor (string): Exact unique Base startup statement.
    statement (string): Transient test-only service binding.

Returns:
    nil: Raises if the source changed or matched multiple statements.
]]
local function expose(anchor: string, statement: string)
    local index = assert(string.find(source, anchor, 1, true),
        "Original NPC live test runtime anchor missing")
    assert(not string.find(
        source, anchor, index + #anchor, true
    ), "Original NPC live test runtime anchor ambiguous")
    source = source:sub(1, index + #anchor - 1)
        .. "\n" .. statement
        .. source:sub(index + #anchor)
end

expose('local runtime = RuntimeServices.new("Base")',
    '_G.C4OriginalNpcLiveRuntime_TEMP = runtime')
expose('    c4_source_npcs:quest_service()\n)',
    '_G.C4OriginalNpcLiveStage_TEMP = c4_source_npcs')
original_runtime.Source = source

local channel = Instance.new("RemoteEvent")
channel.Name = "C4OriginalNpcTestChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "C4OriginalNpcRealClient_TEMP"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local PromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer
local channel = RS:WaitForChild("C4OriginalNpcTestChannel_TEMP")
local requests = RS.Core.Remotes:WaitForChild("ClassAdvancementRequest")
local snapshots = RS.Core.Remotes:WaitForChild("ClassAdvancementSnapshot")
local shown = {}
PromptService.PromptShown:Connect(function(prompt)
    shown[prompt] = true
end)
PromptService.PromptHidden:Connect(function(prompt)
    shown[prompt] = nil
end)
snapshots.OnClientEvent:Connect(function(snapshot)
    local quest = snapshot and snapshot.OriginalQuest
    if quest and quest.ok and quest.Started then
        local gui = player:FindFirstChild("PlayerGui")
        local choice = gui and gui:FindFirstChild("C4FirstTransferChoiceUi")
        local panel = choice and choice:FindFirstChild("ClassPathPanel")
        channel:FireServer("QuestUi", {
            BranchId = quest.BranchId, Step = quest.Step,
            Ready = quest.Ready,
            Text = panel and panel.ClassPathStatus.Text or "",
        })
    end
end)
channel.OnClientEvent:Connect(function(action, part)
    if action ~= "Talk" then return end
    local prompt = part:WaitForChild("C4SourceQuestPrompt", 12)
    if not prompt then
        channel:FireServer("Error", "Actual original quest NPC prompt absent")
        return
    end
    local deadline = os.clock() + 7
    repeat
        if shown[prompt] then break end
        task.wait(0.1)
    until os.clock() >= deadline
    local avatar = player.Character
    local root = avatar and avatar:FindFirstChild("HumanoidRootPart")
    channel:FireServer("PromptSeen", {
        Visible = shown[prompt] == true,
        Distance = if root
            then (root.Position - part.Position).Magnitude
            else math.huge,
    })
    local ok, reason = pcall(function()
        prompt:InputHoldBegin()
        task.wait(0.55)
        prompt:InputHoldEnd()
    end)
    if not ok then
        channel:FireServer("Error", tostring(reason))
    else
        channel:FireServer("Held")
    end
end)
requests:FireServer("Snapshot")
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "C4OriginalNpcActualServerDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local STS = game:GetService("StudioTestService")
local channel = RS:WaitForChild("C4OriginalNpcTestChannel_TEMP")
local ready = {}
local held = {}
local seen = {}
local actual_ui = {}
local failures = {}
channel.OnServerEvent:Connect(function(player, action, data)
    if action == "Ready" then
        ready[player.UserId] = true
    elseif action == "Held" then
        held[player.UserId] = (held[player.UserId] or 0) + 1
    elseif action == "PromptSeen" then
        seen[player.UserId] = data
    elseif action == "QuestUi" then
        actual_ui[player.UserId] = data
    elseif action == "Error" then
        failures[player.UserId] = tostring(data)
    end
end)

--[[
Waits for a real game state instead of faking an NPC click or quest step.

Args:
    predicate (() -> any): Actual live server/client gameplay evidence.
    label (string): Specific timed-out stage.
    seconds (number): Maximum time for real Studio replication.

Returns:
    any: First observed real value or an explicit failed playtest.
]]
local function wait_for(predicate, label, seconds)
    local end_time = os.clock() + seconds
    repeat
        local value = predicate()
        if value then return value end
        task.wait(0.1)
    until os.clock() >= end_time
    error("[C4 Original NPC Live] TIMEOUT " .. label)
end

--[[
Makes the actual client hold the physically present NPC prompt, never
calling the production quest service directly as a substitute for input.

Args:
    player (Player): Actual connected original-class client.
    part (BasePart): Server-owned Captain Ashford world actor.

Returns:
    nil: A genuine ProximityPrompt.Triggered receipt on the server.
]]
local function talk(player, part)
    local prompt = assert(part:FindFirstChild("C4SourceQuestPrompt"))
    local triggered = false
    local listener = prompt.Triggered:Connect(function(actor)
        if actor == player then triggered = true end
    end)
    for attempt = 1, 3 do
        local old = held[player.UserId] or 0
        task.wait(1.2)
        channel:FireClient(player, "Talk", part)
        wait_for(function()
            assert(not failures[player.UserId],
                "Real client prompt input failure: "
                    .. tostring(failures[player.UserId]))
            return (held[player.UserId] or 0) > old
        end, "real local original C4 NPC prompt hold", 13)
        local deadline = os.clock() + 2
        repeat
            if triggered then
                listener:Disconnect()
                return
            end
            task.wait(0.1)
        until os.clock() >= deadline
    end
    listener:Disconnect()
    local state = seen[player.UserId] or {}
    error("[C4 Original NPC Live] Real NPC prompt did not trigger: "
        .. "shown=" .. tostring(state.Visible)
        .. " distance=" .. tostring(state.Distance))
end

--[[
Runs original Fighter branch choice, genuine NPC talk and durable quest.

Args:
    None.

Returns:
    nil: Confirms one real stage without inventing later monster content.
]]
local function main()
    local player = wait_for(function()
        local users = Players:GetPlayers()
        return if #users == 1 then users[1] else nil
    end, "one genuine unpublished Base client", 40)
    local runtime = wait_for(function()
        return _G.C4OriginalNpcLiveRuntime_TEMP
    end, "production Base profile services", 40)
    local npcs = wait_for(function()
        return _G.C4OriginalNpcLiveStage_TEMP
    end, "actual world-owned quest NPC services", 40)
    wait_for(function()
        local character = runtime.ProfileService:get_character(player.UserId)
        return ready[player.UserId] and character
            and player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
    end, "real Base profile and local-client readiness", 65)
    local profiles = runtime.ProfileService
    local part = assert(workspace.C4OriginalSourceQuestNPCs
        :FindFirstChild("CaptainAshford"))
    local root = assert(player.Character:FindFirstChild("HumanoidRootPart"))
    root.Anchored = true
    root.CFrame = part.CFrame * CFrame.new(0, 0, 4)
    talk(player, part)
    local initial = profiles:get_character(player.UserId)
    assert(initial.ClassAdvancement.OriginalFirstTransferQuest == nil,
        "Real NPC started original quest without a class choice")
    print("[C4 Original NPC Live] UNCHOSEN_QUEST_REFUSED_PASS")

    assert(profiles:mutate(player.UserId, function(profile)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1, RaceId = "Human",
            BaseClassId = "Fighter", ClassId = "Fighter",
            CreationStage = "Complete",
        }
        character.Level = 18
    end), "Disposable source Fighter setup failed")
    local selected = npcs._quest_service._profiles:get_character(
        player.UserId
    )
    assert(selected.Identity.BaseClassId == "Fighter",
        "Wrong authenticated class after seeded level")
    local selection = require(game:GetService("ServerScriptService")
        .Core.Services.C4FirstTransferSelectionService)
    assert(selection.new(profiles, "Base"):choose(
        player.UserId, "HumanRogue"
    ).ok, "Explicit original Rogue choice not saved")
    talk(player, part)
    local quest = wait_for(function()
        local state = npcs:quest_service():build_snapshot(player.UserId)
        return if state.ok and state.Started and state.Step == 2
            then state else nil
    end, "real Captain Ashford talk persisted source quest stage", 15)
    assert(quest.FirstNpcReady and quest.WorldReady
        and not quest.FullWorldReady and not quest.Ready
        and not quest.ClassAwarded
        and quest.BranchId == "HumanRogue",
        "Physical first NPC must leave later unbuilt dungeon stages locked")
    local after = profiles:get_character(player.UserId)
    assert(after.Identity.ClassId == "Fighter"
        and after.ClassAdvancement.ActiveClassId == nil,
        "Real first quest NPC awarded an unearned class")
    print("[C4 Original NPC Live] REAL_CLIENT_FIRST_NPC_QUEST_STAGE_PASS")

    local missing_dungeon = npcs:quest_service():record_world_event(
        player.UserId, {
            EventId = "forged-missing-skeleton-stage",
            Kind = "NpcTalk", TargetId = "Vela",
            ActorUserId = player.UserId,
        }
    )
    assert(not missing_dungeon.ok
        and missing_dungeon.reason == "OriginalQuestWorldEvidenceUnverified",
        "Forged Vela event cannot grant trial weapons through live stage two")
    print("[C4 Original NPC Live] UNBUILT_DUNGEON_STAGE_LOCKED_PASS")

    local original_step = quest.Step
    task.wait(0.8)
    talk(player, part)
    assert(npcs:quest_service():build_snapshot(
        player.UserId
    ).Step == original_step,
        "Repeating the first original NPC must not progress a future stage")
    print("[C4 Original NPC Live] NPC_STAGE_REPLAY_DENIED_PASS")

    local client_ui = wait_for(function()
        local state = actual_ui[player.UserId]
        return if state and state.Step == 2 then state else nil
    end, "real client sees its genuine original C4 quest stage", 13)
    assert(client_ui.BranchId == "HumanRogue"
        and not client_ui.Ready
        and string.find(client_ui.Text, "Vela", 1, true),
        "Actual GUI hid missing later dungeon stages or forged completion")
    print("[C4 Original NPC Live] REAL_CLIENT_QUEST_UI_PASS")
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[C4 Original NPC Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(145, function()
    STS:EndTest("FAIL global original NPC live test timeout")
end)
]==]
driver.Parent = SSS

local ok, value = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        1, "C4OriginalPhysicalNpcFirstStage_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and value == "PASS",
    "Original C4 physical quest client test failed: " .. tostring(value))
print("[C4 Original NPC Live] VERIFIED_REAL_CLIENT_FIRST_STAGE_PASS")
