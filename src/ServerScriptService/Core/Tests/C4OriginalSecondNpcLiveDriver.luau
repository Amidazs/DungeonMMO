--!strict
-- Two real clients: physical original C4 Vela/Thorne stage two,
-- atomic owner-bound trial weapon award and stage-three combat fail-closed.
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
expose('    original_transfer_mentors\n)',
    '_G.C4OriginalTransferMentors_TEMP = original_transfer_mentors')
original_runtime.Source = source

local channel = Instance.new("RemoteEvent")
channel.Name = "C4OriginalSecondNpcTestChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "C4OriginalSecondNpcRealClient_TEMP"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local PromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer
local channel = RS:WaitForChild("C4OriginalSecondNpcTestChannel_TEMP")
local requests = RS.Core.Remotes:WaitForChild("ClassAdvancementRequest")
local snapshots = RS.Core.Remotes:WaitForChild("ClassAdvancementSnapshot")
local trainer_snapshots = RS.Core.Remotes:WaitForChild("TrainerSnapshot")
local skill_learn = RS.Core.Remotes:WaitForChild("SkillLearnRequest")
local progression_results = RS.Core.Remotes:WaitForChild(
    "ProgressionActionResult"
)
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
trainer_snapshots.OnClientEvent:Connect(function(payload)
    if payload then
        channel:FireServer("TrainerSnapshotObserved", {
            ok = payload.ok,
            TrainerId = payload.TrainerId,
            reason = payload.reason,
            Skills = payload.Skills,
        })
    end
end)
progression_results.OnClientEvent:Connect(function(payload)
    if payload and payload.action == "SkillLearn" then
        channel:FireServer("SkillPurchaseObserved", payload)
    end
end)
channel.OnClientEvent:Connect(function(action, part)
    if action == "LearnAdvanced" then
        skill_learn:FireServer(part.TrainerId, part.SkillId)
        return
    end
    if action == "InspectTrainerUi" then
        local deadline = os.clock() + 6
        local seen_row = false
        repeat
            local gui = player.PlayerGui:FindFirstChild("ProgressionTrainerUi")
            local panel = gui and gui:FindFirstChildOfClass("Frame")
            if panel and panel.Visible then
                for _, node in ipairs(panel:GetDescendants()) do
                    if node:IsA("TextLabel")
                        and string.find(node.Text, part, 1, true)
                    then
                        seen_row = true
                        break
                    end
                end
            end
            if not seen_row then task.wait(0.1) end
        until seen_row or os.clock() >= deadline
        channel:FireServer("TrainerUiObserved", seen_row)
        return
    end
    if action ~= "Talk" and action ~= "Transfer"
        and action ~= "Train" then return end
    local prompt_name = if action == "Transfer"
        then "FirstTransferMentorPrompt"
        elseif action == "Train"
        then "ProgressionTrainerPrompt" else "C4SourceQuestPrompt"
    local prompt = part:WaitForChild(prompt_name, 12)
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
driver.Name = "C4OriginalSecondNpcActualServerDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local STS = game:GetService("StudioTestService")
local channel = RS:WaitForChild("C4OriginalSecondNpcTestChannel_TEMP")
local ready = {}
local held = {}
local seen = {}
local actual_ui = {}
local trainer_snapshots = {}
local trainer_ui = {}
local skill_purchases = {}
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
    elseif action == "TrainerSnapshotObserved" then
        trainer_snapshots[player.UserId] = data
    elseif action == "TrainerUiObserved" then
        trainer_ui[player.UserId] = data
    elseif action == "SkillPurchaseObserved" then
        skill_purchases[player.UserId] = data
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
    local is_transfer =
        part:FindFirstChild("FirstTransferMentorPrompt") ~= nil
    local is_training =
        part:FindFirstChild("ProgressionTrainerPrompt") ~= nil
    local prompt_name = if is_transfer
        then "FirstTransferMentorPrompt"
        elseif is_training
        then "ProgressionTrainerPrompt" else "C4SourceQuestPrompt"
    local prompt = assert(part:FindFirstChild(prompt_name))
    local triggered = false
    local listener = prompt.Triggered:Connect(function(actor)
        if actor == player then triggered = true end
    end)
    for attempt = 1, 3 do
        local old = held[player.UserId] or 0
        task.wait(1.2)
        channel:FireClient(
            player,
            if is_transfer then "Transfer"
                elseif is_training then "Train" else "Talk",
            part
        )
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
        .. tostring(part.Name) .. "/" .. tostring(prompt.Name)
        .. " enabled=" .. tostring(prompt.Enabled)
        .. " shown=" .. tostring(state.Visible)
        .. " distance=" .. tostring(state.Distance))
end

--[[
Moves one real avatar to the authenticated original quest actor.

Args:
    player (Player): Actual connected and admitted Base player.
    part (BasePart): Server-owned original C4 physical NPC part.

Returns:
    nil: Positions only the disposable test avatar in prompt range.
]]
local function approach(player, part)
    local root = assert(player.Character:FindFirstChild("HumanoidRootPart"))
    root.Anchored = true
    root.CFrame = part.CFrame * CFrame.new(0, 0, 4)
end

--[[
Seeds two genuine original Fighter identities without awarding any class.

Args:
    profiles (any): Authenticated Base ProfileService.
    player (Player): Real client owner.
    race_id (string): Human or Elf original source race.

Returns:
    nil: Test-only original race and level-18 creation.
]]
local function seed(profiles, player, race_id)
    assert(profiles:mutate(player.UserId, function(profile)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1, RaceId = race_id,
            BaseClassId = "Fighter", ClassId = "Fighter",
            CreationStage = "Complete",
        }
        character.Level = 18
    end), "Test-only level-18 Fighter character setup failed")
end

--[[
Runs real original C4 stage-one and stage-two NPC interactions.

Args:
    player (Player): Actual connected Human Fighter or Elven Fighter.
    profiles (any): Real profile and item authority.
    npc_runtime (any): Existing Base world-backed NPC quest service.
    branch_id (string): Exact original C4 chosen first-transfer class.
    first_id (string): Genuine first source actor's physical part name.
    second_id (string): Genuine second source actor's physical part name.

Returns:
    nil: Verifies only the selected branch advances to real step three.
]]
local function advance_two_stages(
    player, profiles, npc_runtime, branch_id, first_id, second_id
)
    local npcs = workspace:WaitForChild("C4OriginalSourceQuestNPCs")
    local first = assert(npcs:FindFirstChild(first_id))
    local second = assert(npcs:FindFirstChild(second_id))
    local selection = require(game:GetService("ServerScriptService")
        .Core.Services.C4FirstTransferSelectionService)
    assert(selection.new(profiles, "Base"):choose(
        player.UserId, branch_id
    ).ok, "Authentic first-transfer class choice was not saved")
    approach(player, first)
    talk(player, first)
    local stage_two = wait_for(function()
        local snapshot = npc_runtime:quest_service()
            :build_snapshot(player.UserId)
        return if snapshot.ok and snapshot.Step == 2
            then snapshot else nil
    end, "genuine first NPC reached stage two", 15)
    assert(stage_two.WorldReady
        and not stage_two.FullWorldReady
        and not stage_two.Ready
        and stage_two.BranchId == branch_id,
        "Second NPC must be physically live without claiming full quest")
    local before_second = profiles:get_character(player.UserId)
    assert(before_second.Identity.ClassId == "Fighter"
        and before_second.ClassAdvancement.ActiveClassId == nil,
        "Original first NPC granted a forbidden advanced class")

    local forged = npc_runtime:quest_service():record_world_event(
        player.UserId, {
            EventId = "client-forged-second-" .. tostring(player.UserId),
            Kind = "NpcTalk", TargetId = second_id,
            TrialWeaponsGranted = true, ActorUserId = player.UserId,
        }
    )
    assert(not forged.ok
        and forged.reason == "OriginalQuestWorldEvidenceUnverified",
        "Forged Vela/Thorne event bypassed authenticated NPC receipt")
    approach(player, second)
    talk(player, second)
    local stage_three = wait_for(function()
        local snapshot = npc_runtime:quest_service()
            :build_snapshot(player.UserId)
        return if snapshot.ok and snapshot.Step == 3
            then snapshot else nil
    end, "actual second C4 NPC persisted stage three", 15)
    assert(not stage_three.WorldReady
        and not stage_three.FullWorldReady
        and not stage_three.Ready
        and not stage_three.ClassAwarded,
        "Physical second NPC must not bypass missing quest battles")
    local after = profiles:get_character(player.UserId)
    assert(after.Identity.ClassId == "Fighter"
        and after.ClassAdvancement.ActiveClassId == nil,
        "Original Vela/Thorne meeting awarded an unearned C4 class")
    local step = stage_three.Step
    task.wait(0.8)
    talk(player, second)
    assert(npc_runtime:quest_service():build_snapshot(
        player.UserId
    ).Step == step, "Replayed second NPC skipped sealed combat stage")
    return stage_three
end

--[[
Stages a completed source-monster inventory only inside disposable Studio.

Args:
    profiles (any): Actual loaded Base profile service.
    user_id (number): The independent owner's UserId.
    branch_id (string): Selected source advancement branch.
    add_proofs (boolean): Whether to add genuinely owned test-only loot.

Returns:
    nil: Source quest remains stage four until a physical mentor turn-in.
]]
local function prepare_return(
    profiles, user_id, branch_id, add_proofs
)
    local items = require(game:GetService("ServerScriptService")
        .Core.Services.InventoryService)
    local ok, reason = profiles:mutate(user_id, function(profile)
        local character = profile.Characters.Slot1
        local state = character.ClassAdvancement.OriginalFirstTransferQuest
        assert(state and state.BranchId == branch_id and state.Step >= 3)
        state.Step = 4
        state.Count = 0
        if not add_proofs then return end
        if branch_id == "HumanRogue" then
            for _ = 1, 10 do
                assert(items.apply_item_to_character(
                    character, "spartoi_bone", 1
                ).ok)
            end
            state.Proofs.SpartoiBone10 = true
        else
            for index = 1, 4 do
                assert(items.apply_item_to_character(
                    character, "prias_letter_" .. tostring(index), 1
                ).ok)
                state.Proofs["PriasLetter" .. tostring(index)] = true
            end
        end
    end)
    assert(ok, "Test-only return preparation rejected: "
        .. tostring(reason))
end

--[[
Checks that an existing physically prompted mentor accepts only complete
personal stage-four items and never grants an unfinished advanced class.

Args:
    player (Player): Real Human or Elf Studio client.
    profiles (any): Real Base profile service with personally owned items.
    npc_runtime (any): Existing physically authenticated world binder.
    branch_id (string): Owner's selected original source class.
    mentor_id (string): Same genuine mentor from stage two.

Returns:
    nil: Verifies missing-loot denial then genuine prompt-driven return.
]]
local function verify_return(
    player, profiles, npc_runtime, branch_id, mentor_id
)
    local mentor = assert(workspace.C4OriginalSourceQuestNPCs
        :FindFirstChild(mentor_id))
    prepare_return(profiles, player.UserId, branch_id, false)
    approach(player, mentor)
    talk(player, mentor)
    assert(npc_runtime:quest_service():build_snapshot(
        player.UserId
    ).Step == 4, "Mentor accepted stage-four return without owner loot")
    prepare_return(profiles, player.UserId, branch_id, true)
    local available = npc_runtime:quest_service():build_snapshot(
        player.UserId
    )
    assert(available.Step == 4 and available.WorldReady,
        "Earned source proof must expose the real return mentor")
    local items = require(game:GetService("ServerScriptService")
        .Core.Services.InventoryService)
    local missing_id = if branch_id == "HumanRogue"
        then "spartoi_bone" else "prias_letter_4"
    assert(profiles:mutate(player.UserId, function(profile)
        assert(items.apply_remove_from_character(
            profile.Characters.Slot1, missing_id, 1
        ).ok)
    end), "Unable to prepare missing-owner-item rejection")
    talk(player, mentor)
    assert(npc_runtime:quest_service():build_snapshot(
        player.UserId
    ).Step == 4, "NPC advanced from a claimed proof with missing owned loot")
    assert(profiles:mutate(player.UserId, function(profile)
        assert(items.apply_item_to_character(
            profile.Characters.Slot1, missing_id, 1
        ).ok)
    end), "Unable to restore owner-owned return material")
    talk(player, mentor)
    local returned = wait_for(function()
        local snapshot = npc_runtime:quest_service()
            :build_snapshot(player.UserId)
        return if snapshot.ok and snapshot.Step == 5
            then snapshot else nil
    end, "real authenticated stage-four return", 12)
    local owner = profiles:get_character(player.UserId)
    if branch_id == "HumanRogue" then
        assert(items.count_item(owner, "spartoi_bone") == 0,
            "Actual mentor did not consume all ten owned crypt fragments")
    else
        for index = 1, 4 do
            assert(items.count_item(
                owner, "prias_letter_" .. tostring(index)
            ) == 0, "Actual warden did not consume the personal field report")
        end
    end
    assert(not returned.ClassAwarded
        and owner.Identity.ClassId == "Fighter"
        and owner.ClassAdvancement.ActiveClassId == nil,
        "Physical stage-four return awarded an unfinished advanced class")
    talk(player, mentor)
    assert(npc_runtime:quest_service():build_snapshot(
        player.UserId
    ).Step == 5, "Repeated stage-four mentor cannot bypass future stages")
end

--[[
Verifies that the original captain accepts only the ordered fifth stage.

Args:
    player (Player): Real authenticated Human Rogue source owner.
    npc_runtime (any): Existing physical source NPC binder and quest service.

Returns:
    nil: Confirms real report to Captain Ashford unlocks stage six only.
]]
local function verify_captain_report(player, npc_runtime)
    local captain = assert(workspace.C4OriginalSourceQuestNPCs
        :FindFirstChild("CaptainAshford"))
    local before = npc_runtime:quest_service():build_snapshot(
        player.UserId
    )
    assert(before.Step == 5 and before.WorldReady,
        "Stage-five captain must be a real physical quest return target")
    approach(player, captain)
    talk(player, captain)
    local accepted = wait_for(function()
        local snapshot = npc_runtime:quest_service()
            :build_snapshot(player.UserId)
        return if snapshot.ok and snapshot.Step == 6
            then snapshot else nil
    end, "genuine fifth-stage captain report", 12)
    assert(not accepted.ClassAwarded and not accepted.Ready,
        "Captain report must not skip the later challenge or class transfer")
    talk(player, captain)
    assert(npc_runtime:quest_service():build_snapshot(
        player.UserId
    ).Step == 6, "Replaying captain must not skip the next monster challenge")
end

--[[
Seeds one completed stage-six cache in disposable Base test profiles only.

Args:
    profiles (any): Actual two-client Base character authority.
    user_id (number): Genuine Rogue player's loaded profile owner.

Returns:
    nil: Isolates a future Dungeon reward for physical captain turn-in.
]]
local function seed_final_cinder_cache(profiles, user_id)
    local inventory = require(game:GetService("ServerScriptService")
        .Core.Services.InventoryService)
    local ok, why = profiles:mutate(user_id, function(profile)
        local owner = profile.Characters.Slot1
        local state = owner.ClassAdvancement.OriginalFirstTransferQuest
        assert(state.Step == 6 and state.BranchId == "HumanRogue")
        state.Step = 7
        state.Count = 0
        for proof_id, item_id in pairs({
            StolenJewelry = "cinder_cipher",
            StolenTomes = "cinder_route_map",
            StolenRing = "cinder_ward_seal",
            StolenNecklace = "cinder_tideglass_lens",
        }) do
            state.Proofs[proof_id] = true
            assert(inventory.apply_item_to_character(
                owner, item_id, 1
            ).ok)
        end
    end)
    assert(ok, "Disposable complete Cinder cache setup failed: "
        .. tostring(why))
end

--[[
Verifies the real captain refuses missing ownership and consumes the full
individually owned supply records without granting an unfinished class.

Args:
    player (Player): Genuine authenticated Human Rogue Base avatar.
    profiles (any): Real Base profile writer and inventory owner.
    npc_runtime (any): Existing physical single-use source NPC binder.

Returns:
    nil: Real stage-seven prompt completes source quest, but not class award.
]]
local function verify_captain_final(player, profiles, npc_runtime)
    local captain = assert(workspace.C4OriginalSourceQuestNPCs
        :FindFirstChild("CaptainAshford"))
    local inventory = require(game:GetService("ServerScriptService")
        .Core.Services.InventoryService)
    seed_final_cinder_cache(profiles, player.UserId)
    local cache_items = {
        "cinder_cipher", "cinder_route_map",
        "cinder_ward_seal", "cinder_tideglass_lens",
    }
    assert(profiles:mutate(player.UserId, function(profile)
        assert(inventory.apply_remove_from_character(
            profile.Characters.Slot1, cache_items[4], 1
        ).ok)
    end), "Unable to prepare missing cache-material refusal")
    approach(player, captain)
    talk(player, captain)
    assert(npc_runtime:quest_service():build_snapshot(
        player.UserId
    ).Step == 7, "Captain must deny a proof claim with missing owner item")
    assert(profiles:mutate(player.UserId, function(profile)
        assert(inventory.apply_item_to_character(
            profile.Characters.Slot1, cache_items[4], 1
        ).ok)
    end), "Unable to restore exact owner cache material")
    talk(player, captain)
    local returned = wait_for(function()
        local snapshot = npc_runtime:quest_service()
            :build_snapshot(player.UserId)
        return if snapshot.ok and snapshot.Ready
            then snapshot else nil
    end, "genuine final captain supply-record handoff", 12)
    local owner = profiles:get_character(player.UserId)
    assert(returned.Step == 8 and not returned.ClassAwarded
        and owner.Identity.ClassId == "Fighter"
        and owner.ClassAdvancement.ActiveClassId == nil,
        "Source quest completion cannot grant missing level-20 class")
    for _, item_id in ipairs(cache_items) do
        assert(inventory.count_item(owner, item_id) == 0,
            "Real captain failed to consume one bound supply item")
    end
    talk(player, captain)
    assert(npc_runtime:quest_service():build_snapshot(
        player.UserId
    ).Step == 8, "Captain replay cannot repeat final loot handoff")
end

--[[
Seeds a completed dungeon rescue only within the disposable Base fixture.

Args:
    profiles (any): Real Base loaded character profile authority.
    user_id (number): Real Elf client's unique Roblox UserId.
    has_proof (boolean): Whether the earlier real Warden proof is supplied.

Returns:
    nil: Leaves the original Elf Fighter at the ordered hub report stage.
]]
local function seed_scout_report(profiles, user_id, has_proof)
    local ok, reason = profiles:mutate(user_id, function(profile)
        local character = profile.Characters.Slot1
        local state = character.ClassAdvancement.OriginalFirstTransferQuest
        assert(state.BranchId == "ElvenScout" and state.Step == 5)
        state.Step = 8
        state.Count = 0
        if has_proof then
            state.Proofs.RustedKey = true
        else
            state.Proofs.RustedKey = nil
        end
    end)
    assert(ok, "Disposable Scout hub report seed refused: "
        .. tostring(reason))
end

--[[
Verifies the actual two physical hub mentors and later Scout proof gating.

Args:
    elf (Player): Real authenticated Elf client avatar.
    profiles (any): Existing authoritative Base profile service.
    npcs (any): Already connected physical source quest NPC runtime.

Returns:
    nil: Completes the Scout source sequence without granting class skills.
]]
local function verify_scout_hub_reports(elf, profiles, npcs)
    local parts = workspace:WaitForChild("C4OriginalSourceQuestNPCs")
    local thorne = assert(parts:FindFirstChild("WardenThorne"))
    local elyra = assert(parts:FindFirstChild("PathfinderElyra"))
    seed_scout_report(profiles, elf.UserId, false)
    approach(elf, thorne)
    talk(elf, thorne)
    assert(npcs:quest_service():build_snapshot(
        elf.UserId
    ).Step == 8, "Thorne must refuse rescue report without earned proof")
    assert(profiles:mutate(elf.UserId, function(profile)
        local state = profile.Characters.Slot1
            .ClassAdvancement.OriginalFirstTransferQuest
        state.Proofs.RustedKey = true
    end), "Cannot restore test-owned authentic Warden receipt proof")
    talk(elf, thorne)
    local reported = wait_for(function()
        local snapshot = npcs:quest_service():build_snapshot(elf.UserId)
        return if snapshot.ok and snapshot.Step == 9
            then snapshot else nil
    end, "real stage-eight Warden Thorne report", 12)
    assert(not reported.ClassAwarded and reported.WorldReady,
        "Thorne report must not grant a class or bypass real Elyra prompt")
    approach(elf, elyra)
    talk(elf, elyra)
    local completed = wait_for(function()
        local snapshot = npcs:quest_service():build_snapshot(elf.UserId)
        return if snapshot.ok and snapshot.Ready
            then snapshot else nil
    end, "real final Pathfinder Elyra report", 12)
    local owner = profiles:get_character(elf.UserId)
    assert(completed.Step == 10 and not completed.ClassAwarded
        and owner.Identity.ClassId == "Fighter"
        and owner.ClassAdvancement.ActiveClassId == nil,
        "Finishing Scout source quest must not grant level-20 class early")
    talk(elf, elyra)
    assert(npcs:quest_service():build_snapshot(
        elf.UserId
    ).Step == 10, "Repeated final scout prompt cannot skip advanced class")
end

--[[
Moves only a disposable, source-quest-complete test character to level 20.

Args:
    profiles (any): Real live Base exclusive profile writer.
    player (Player): Authenticated Human or Elf test client.

Returns:
    nil: Updates level/temporary SP only, not the class or quest proof.
]]
local function reach_transfer_level(profiles, player)
    assert(profiles:mutate(player.UserId, function(profile)
        local character = profile.Characters.Slot1
        character.Level = 20
        character.Progression.SkillPointEntitlement = math.max(
            character.Progression.SkillPointEntitlement or 0, 1000
        )
    end), "Disposable test character could not reach level 20")
end

--[[
Verifies an actual physical mentor's player-owned first-class award.

Args:
    player (Player): Real Base client with the selected source quest.
    profiles (any): Real server-side selected character profile writer.
    mentors (any): Production physical first-transfer mentor runtime.
    definition (any): Exact expected first-transfer class and trainer.
    wrong_mentor (BasePart): Other branch's real physical NPC.

Returns:
    nil: Checks level, other-race, receipt, replay and trainer gates.
]]
local function verify_physical_transfer(
    player, profiles, mentors, definition, wrong_mentor
)
    local RS = game:GetService("ReplicatedStorage")
    local Shared = RS.Core.Shared
    local SkillRules = require(Shared.SkillUnlockRules)
    local SkillDefinitions = require(Shared.SkillProgressionDefinitions)
    local TrainerCatalogues = require(Shared.TrainerCatalogues)
    local FirstTransfers = require(
        Shared.OriginalFirstTransferDefinitions
    )
    local actor = assert(
        workspace.OriginalFirstTransferMentors
            :FindFirstChild(definition.MentorId)
    )
    local prompt = assert(actor:FindFirstChild(
        "FirstTransferMentorPrompt"
    ))
    local training_station = assert(
        workspace.OriginalFirstTransferMentors
            :FindFirstChild(definition.TrainerId)
    )
    assert(prompt.ObjectText == definition.MentorName
        and training_station:GetAttribute("TrainerId")
            == definition.TrainerId
        and training_station:FindFirstChild("ProgressionTrainerPrompt")
        and training_station ~= actor,
        "Original advancement mentor and skill trainer must be separate")
    local before = profiles:get_character(player.UserId)
    assert(before.ClassAdvancement.OriginalFirstTransferQuest.Ready
        and before.Identity.ClassId == "Fighter",
        "Transfer trial must be complete but class still unearned")
    approach(player, actor)
    talk(player, actor)
    assert(profiles:get_character(player.UserId)
        .Identity.ClassId == "Fighter",
        "Real mentor prompt at level 18 must not award a class")
    reach_transfer_level(profiles, player)
    approach(player, wrong_mentor)
    talk(player, wrong_mentor)
    assert(profiles:get_character(player.UserId)
        .Identity.ClassId == "Fighter",
        "Other race's physical mentor cannot mint a wrong class")
    approach(player, actor)
    talk(player, actor)
    local awarded = wait_for(function()
        local owner = profiles:get_character(player.UserId)
        return if owner and owner.Identity.ClassId == definition.Id
            then owner else nil
    end, "genuine physical level-20 mentor class award", 12)
    assert(FirstTransfers.awarded(awarded) == definition
        and awarded.ClassAdvancement.ActiveClassId == nil
        and awarded.Identity.BaseClassId == "Fighter",
        "Transfer awarded wrong career or replaced legacy class identity")
    local transfer = mentors:build_snapshot(player.UserId)
    assert(transfer.ClassAwarded and not transfer.Eligible,
        "Mentor must record a one-time persistent original class award")
    talk(player, actor)
    assert(profiles:get_character(player.UserId)
        .ClassAdvancement.OriginalFirstTransferReceiptId
            == awarded.ClassAdvancement.OriginalFirstTransferReceiptId,
        "Repeated mentor prompt may not generate a second award")
    local skill = assert(SkillDefinitions.get(definition.SkillId))
    assert(SkillRules.can_train(awarded, skill, 1)
        and TrainerCatalogues.can_offer(
            definition.TrainerId, awarded, definition.SkillId
        ).ok, "Awarded class must unlock only its registered skill")
    approach(player, training_station)
    assert(mentors:nearby_trainer(player, definition.TrainerId),
        "Only the real corresponding nearby trainer may teach this skill")
    local runtime = assert(_G.C4OriginalNpcLiveRuntime_TEMP)
    local learned = runtime.SkillProgressionService:learn_trainer_skill(
        player.UserId, definition.SkillId
    )
    assert(learned.ok, "Actual level-20 skill purchase was rejected: "
        .. tostring(learned.reason))
    local skill_state = profiles:get_character(player.UserId)
        .Progression.Skills[definition.SkillId]
    assert(skill_state and skill_state.Known == true
        and skill_state.PurchasedRank == 1,
        "Original transfer trainer must grant a purchased rank, not free XP")
    print("[C4 Original Second NPC Live] REAL_FIRST_TRANSFER_"
        .. definition.Id .. "_PASS")
end

--[[
Sends a real client skill-learn remote and reads the actual server result.

Args:
    player (Player): Live test client issuing the request.
    definition (any): Immutable matching original advanced class.
    skill_id (string): Skill to request through the production remote.

Returns:
    any: Observed actual ProgressionActionResult for this request.
]]
local function request_client_training(player, definition, skill_id)
    skill_purchases[player.UserId] = nil
    channel:FireClient(player, "LearnAdvanced", {
        TrainerId = definition.TrainerId,
        SkillId = skill_id,
    })
    return wait_for(function()
        return skill_purchases[player.UserId]
    end, "real client SkillLearnRequest response", 12)
end

--[[
Uses the physical advanced trainer and tests the live UI and remote gates.

Args:
    player (Player): Authentic client already transferred at level twenty.
    profiles (any): Real Base ProfileService authority.
    definition (any): The single earned first-transfer career.
    mentors (any): Registered physical transfer mentor/trainer actors.

Returns:
    nil: Confirms out-of-range remote refusal and in-range UI-backed buy.
]]
local function verify_client_training(
    player, profiles, definition, mentors
)
    local skill_id = if definition.RaceId == "Human"
        then "AshenbladeOpening" else "GreenwardRenewal"
    local prerequisite = if definition.RaceId == "Human"
        then "FighterDaggerStrike" else "ElvenFighterRenewal"
    local required_rank = if definition.RaceId == "Human" then 3 else 1
    local required_proficiency = if definition.RaceId == "Human"
        then 80 else 30
    assert(profiles:mutate(player.UserId, function(profile)
        local owner = profile.Characters.Slot1
        owner.Level = 24
        owner.Progression.SkillPointEntitlement = 1000
        owner.Progression.Skills[prerequisite] = {
            Known = true, PurchasedRank = required_rank,
            Proficiency = required_proficiency,
        }
    end), "Disposable level-24 original class mastery preparation failed")
    local station = assert(workspace.OriginalFirstTransferMentors
        :FindFirstChild(definition.TrainerId))
    assert(not profiles:get_character(player.UserId)
        .Progression.Skills[skill_id],
        "Real client must buy its advanced skill, not receive it for free")
    local root = assert(player.Character.HumanoidRootPart)
    root.CFrame = station.CFrame * CFrame.new(0, 0, 50)
    task.wait(0.4)
    assert(not mentors:nearby_trainer(player, definition.TrainerId),
        "Trainer must reject clients beyond the actual ten-stud range")
    local denied = request_client_training(player, definition, skill_id)
    assert(not denied.ok
        and denied.reason == "InvalidTrainerSkillRequest",
        "Actual remote must reject out-of-range class skill purchases")
    assert(not profiles:get_character(player.UserId)
        .Progression.Skills[skill_id],
        "Rejected remote cannot learn skill or spend any skill points")
    approach(player, station)
    trainer_snapshots[player.UserId] = nil
    trainer_ui[player.UserId] = nil
    talk(player, station)
    local catalogue = wait_for(function()
        return trainer_snapshots[player.UserId]
    end, "actual trainer ProximityPrompt to catalogue remote", 12)
    assert(catalogue.ok and catalogue.TrainerId
        == definition.TrainerId,
        "Physical station must open only the correct server trainer")
    channel:FireClient(player, "InspectTrainerUi", skill_id)
    assert(wait_for(function()
        return trainer_ui[player.UserId] == true
    end, "real client trainer UI showing its advanced skill", 12),
        "Physical trainer UI omitted the available advanced skill")

    local foreign = if definition.RaceId == "Human"
        then {TrainerId = "GreenwardScoutTrainer",
            SkillId = "GreenwardRenewal"}
        else {TrainerId = "AshenbladeTrainer",
            SkillId = "AshenbladeOpening"}
    skill_purchases[player.UserId] = nil
    channel:FireClient(player, "LearnAdvanced", foreign)
    local foreign_result = wait_for(function()
        return skill_purchases[player.UserId]
    end, "real wrong-class trainer remote response", 12)
    assert(not foreign_result.ok
        and foreign_result.reason == "InvalidTrainerSkillRequest",
        "Client cannot substitute an unrelated mentor's trainer ID")

    assert(profiles:mutate(player.UserId, function(profile)
        local progression = profile.Characters.Slot1.Progression
        -- Profile migration restores the earned level-24 entitlement.
        -- An actual zero-SP character must already have spent those
        -- points on permitted pre-transfer Fighter skill ranks.
        for _, base_skill in ipairs({
            "IronCleave", "FighterBowShot", "PursuitStep",
        }) do
            progression.Skills[base_skill] = {
                Known = true, PurchasedRank = 9, Proficiency = 350,
            }
        end
        progression.SkillPointEntitlement = 0
    end), "Disposable test-only low-SP trainer setup failed")
    local no_sp = request_client_training(player, definition, skill_id)
    assert(not no_sp.ok and no_sp.reason == "InsufficientSP"
        and not profiles:get_character(player.UserId)
            .Progression.Skills[skill_id],
        "In-range trainer must charge real remaining skill points: "
            .. tostring(no_sp.reason))
    assert(profiles:mutate(player.UserId, function(profile)
        profile.Characters.Slot1.Progression
            .SkillPointEntitlement = 1000
    end), "Disposable owner skill-point balance restoration failed")
    local learned = request_client_training(player, definition, skill_id)
    assert(learned.ok, "Real client could not buy its advanced skill: "
        .. tostring(learned.reason))
    local state = profiles:get_character(player.UserId)
        .Progression.Skills[skill_id]
    assert(state and state.Known and state.PurchasedRank == 1,
        "Actual client-purchased skill must persist in owner profile")
    print("[C4 Original Second NPC Live] REAL_CLIENT_TRAINER_"
        .. definition.Id .. "_PASS")
end

--[[
Seeds only completed original quests for a fast dedicated physical mentor
regression; the separate earlier two-client source NPC tests are unchanged.

Args:
    profiles (any): Real disposable Base exclusive profile writer.
    player (Player): Live client assigned its own test-only source branch.
    branch_id (string): Human Rogue or Elven Scout source quest.

Returns:
    nil: Completes the source stage without granting any class or skill.
]]
local function seed_completed_source(profiles, player, branch_id)
    local sources = require(game:GetService("ReplicatedStorage")
        .Core.Shared.C4OriginalFirstTransferQuestStages)
    local source = assert(sources.get(branch_id))
    local selection = require(game:GetService("ServerScriptService")
        .Core.Services.C4FirstTransferSelectionService)
    assert(selection.new(profiles, "Base"):choose(
        player.UserId, branch_id
    ).ok, "Test-only selected first-transfer branch must be saved")
    assert(profiles:mutate(player.UserId, function(profile)
        local owner = profile.Characters.Slot1
        local proofs = {}
        for _, key in ipairs(source.RequiredProofIds) do
            proofs[key] = true
        end
        owner.ClassAdvancement.OriginalFirstTransferQuest = {
            QuestId = source.Id,
            BranchId = branch_id,
            Step = #source.Steps + 1,
            Count = 0,
            Ready = true,
            AppliedEvents = {},
            Proofs = proofs,
        }
    end), "Test-only completed source quest could not be seeded")
end

--[[
Executes only the genuine physical original level-20 transfer mentors.

Args:
    human (Player): Real Human Fighter test avatar.
    elf (Player): Real Elf Fighter test avatar.
    profiles (any): Actual server-owned live Base profile service.

Returns:
    nil: Tests genuine two-client transfer and purchased skill isolation.
]]
local function run_transfer_only(human, elf, profiles)
    seed(profiles, human, "Human")
    seed(profiles, elf, "Elf")
    seed_completed_source(profiles, human, "HumanRogue")
    seed_completed_source(profiles, elf, "ElvenScout")
    local mentors = wait_for(function()
        return _G.C4OriginalTransferMentors_TEMP
    end, "actual live first-transfer mentor runtime", 12)
    local definitions = require(game:GetService("ReplicatedStorage")
        .Core.Shared.OriginalFirstTransferDefinitions)
    local rogue = assert(definitions.for_branch("HumanRogue"))
    local scout = assert(definitions.for_branch("ElvenScout"))
    local actors = workspace.OriginalFirstTransferMentors
    verify_physical_transfer(
        human, profiles, mentors, rogue,
        assert(actors:FindFirstChild(scout.MentorId))
    )
    verify_client_training(human, profiles, rogue, mentors)
    assert(profiles:get_character(elf.UserId)
        .Identity.ClassId == "Fighter",
        "Human-only first transfer must not advance an unrelated Elf")
    verify_physical_transfer(
        elf, profiles, mentors, scout,
        assert(actors:FindFirstChild(rogue.MentorId))
    )
    verify_client_training(elf, profiles, scout, mentors)
    assert(profiles:get_character(human.UserId)
        .Identity.ClassId == "Ashenblade",
        "Elven transfer must not change Human's previously earned class")
    print("[C4 Original Second NPC Live] TWO_CLIENT_FIRST_TRANSFER_PASS")
end

--[[
Uses a genuine client's physical Ironvow training prompt and authenticated
skill purchase remote, with out-of-range and wrong-class denials.

Args:
    human (Player): Actual owner with completed Ironroot source/mentor.
    elf (Player): Different real party member with no Warrior award.
    profiles (any): Actual loaded exclusive Base profile writer.
    mentors (any): Real physical mentor and trainer runtime.
    definition (any): The independently earned Ironvow career.

Returns:
    nil: Verifies UI-visible mastery rank and server-owned SP purchase.
]]
local function verify_ironvow_client_training(
    human, elf, profiles, mentors, definition
)
    local skill_id = "IronvowBladeTraining"
    local station = assert(workspace.OriginalFirstTransferMentors
        :FindFirstChild(definition.TrainerId))
    local root = assert(human.Character.HumanoidRootPart)
    root.CFrame = station.CFrame * CFrame.new(0, 0, 50)
    task.wait(0.4)
    assert(not mentors:nearby_trainer(human, definition.TrainerId),
        "A distant Ironvow client must fail actual trainer proximity")
    local denied = request_client_training(human, definition, skill_id)
    assert(not denied.ok
        and denied.reason == "InvalidTrainerSkillRequest",
        "Actual remote bought Warrior mastery without nearby mentor")
    assert(not profiles:get_character(human.UserId)
        .Progression.Skills[skill_id],
        "Out-of-range skill request spent points or awarded mastery")
    approach(elf, station)
    assert(mentors:nearby_trainer(elf, definition.TrainerId),
        "Other client must be within real physical trainer range")
    local other_result = request_client_training(elf, definition, skill_id)
    assert(not other_result.ok
        and not profiles:get_character(elf.UserId)
            .Progression.Skills[skill_id],
        "Another unadvanced class learned Human Warrior mastery")
    approach(human, station)
    trainer_snapshots[human.UserId] = nil
    trainer_ui[human.UserId] = nil
    talk(human, station)
    local snapshot = wait_for(function()
        return trainer_snapshots[human.UserId]
    end, "real Ironvow trainer prompt opens the correct catalogue", 12)
    assert(snapshot.ok and snapshot.TrainerId == definition.TrainerId,
        "Physical trainer opened wrong/unauthorized class catalogue")
    channel:FireClient(human, "InspectTrainerUi", skill_id)
    assert(wait_for(function()
        return trainer_ui[human.UserId] == true
    end, "new Warrior skill appears in real trainer window", 12),
        "Client's Ironvow skill UI did not show sword mastery")
    local learned = request_client_training(human, definition, skill_id)
    assert(learned.ok, "Genuine client could not purchase Ironvow mastery: "
        .. tostring(learned.reason))
    assert(profiles:get_character(human.UserId)
        .Progression.Skills[skill_id].PurchasedRank == 1,
        "Client-bought Ironvow mastery was not saved to owner's state")
    print("[Ironvow Physical Live] REAL_CLIENT_IRONVOW_TRAINER_PASS")
end

--[[
Accepts two genuinely separate Ironroot source NPCs and physical mentor.

Args:
    human (Player): Real authenticated Human Fighter client.
    elf (Player): Other genuine, unadvanced Elf party member.
    profiles (any): Actual current Base profile and progression writer.
    npcs (any): Existing real physical original source NPC binder.

Returns:
    nil: Saves real first-stage prompts and awarded original Warrior class.
]]
local function run_ironvow_only(human, elf, profiles, npcs)
    seed(profiles, human, "Human")
    seed(profiles, elf, "Elf")
    advance_two_stages(
        human, profiles, npcs,
        "HumanWarrior", "MarshalTorren", "SmithOrla"
    )
    print("[Ironvow Physical Live] REAL_IRONROOT_TWO_NPCS_PASS")
    local definition = assert(require(
        game:GetService("ReplicatedStorage").Core.Shared
            .OriginalFirstTransferDefinitions
    ).for_branch("HumanWarrior"))
    local source = assert(require(
        game:GetService("ReplicatedStorage").Core.Shared
            .C4OriginalFirstTransferQuestStages
    ).get("HumanWarrior"))
    assert(profiles:mutate(human.UserId, function(profile)
        local owner = profile.Characters.Slot1
        local state = owner.ClassAdvancement.OriginalFirstTransferQuest
        assert(state and state.BranchId == source.BranchId
            and state.Step == 3)
        -- Monster/loot stages are separately tested in live Dungeon.
        -- Only earlier proofs are prepared for this isolated Base test.
        state.Step = #source.Steps + 1
        state.Count = 0
        state.Ready = true
        state.Proofs = {
            IronrootToken4 = true, RidgebreakerSigil = true,
        }
        owner.Progression.SkillPointEntitlement = 1600
        owner.Progression.Skills.IronCleave = {
            Known = true, PurchasedRank = 9, Proficiency = 350,
        }
    end), "Prior Warrior dungeon stages cannot be prepared in Base test")
    local mentors = wait_for(function()
        return _G.C4OriginalTransferMentors_TEMP
    end, "genuine physical Warrior mentor runtime", 12)
    local parts = workspace.OriginalFirstTransferMentors
    local other_mentor = assert(parts:FindFirstChild(
        "PathwardenSiora"
    ))
    verify_physical_transfer(
        human, profiles, mentors, definition, other_mentor
    )
    assert(profiles:get_character(elf.UserId).Identity.ClassId
        == "Fighter", "Human mentor must not advance unrelated Elf")
    verify_ironvow_client_training(
        human, elf, profiles, mentors, definition
    )
    print("[Ironvow Physical Live] VERIFIED_WARRIOR_BASE_PASS")
end

--[[
Tests two independent characters and their real physical source quest NPCs.

Args:
    None.

Returns:
    nil: Only genuine prompts may grant the Human's personal trial weapons.
]]
local function main()
    local users = wait_for(function()
        local list = Players:GetPlayers()
        return if #list == 2 then list else nil
    end, "two real unpublished Base clients", 50)
    local runtime = wait_for(function()
        return _G.C4OriginalNpcLiveRuntime_TEMP
    end, "existing production Base profile authority", 40)
    local npcs = wait_for(function()
        return _G.C4OriginalNpcLiveStage_TEMP
    end, "real original C4 world NPC binder", 40)
    for _, player in ipairs(users) do
        wait_for(function()
            return ready[player.UserId]
                and runtime.ProfileService:get_character(player.UserId)
                and player.Character
                and player.Character:FindFirstChild("HumanoidRootPart")
        end, "two actual client profile/avatar readiness", 65)
    end
    local human = users[1]
    local elf = users[2]
    local profiles = runtime.ProfileService
    if workspace:GetAttribute("DungeonMMOStudioIronvowFocus") == true
    then
        run_ironvow_only(human, elf, profiles, npcs)
        return
    end
    if workspace:GetAttribute("DungeonMMOStudioTransferFocus") == true
    then
        run_transfer_only(human, elf, profiles)
        return
    end
    local world_parts = workspace:WaitForChild("C4OriginalSourceQuestNPCs")
    local original_labels = {
        CaptainAshford = "Captain Ashford",
        Vela = "Quartermaster Vela",
        PathfinderElyra = "Pathfinder Elyra",
        WardenThorne = "Warden Thorne",
    }
    for part_id, expected_label in pairs(original_labels) do
        local actor = assert(world_parts:FindFirstChild(part_id))
        local prompt = assert(actor:FindFirstChild("C4SourceQuestPrompt"))
        assert(prompt.ObjectText == expected_label,
            "Physical quest NPC used a non-original displayed name: "
                .. part_id)
    end
    seed(profiles, human, "Human")
    seed(profiles, elf, "Elf")

    -- Neither another race's NPC nor a bare item-grant claim may advance
    -- the unchosen original first-transfer branch.
    local stranger = assert(workspace.C4OriginalSourceQuestNPCs
        :FindFirstChild("WardenThorne"))
    approach(human, stranger)
    talk(human, stranger)
    assert(profiles:get_character(human.UserId)
        .ClassAdvancement.OriginalFirstTransferQuest == nil,
        "Human Fighter started an unselected Elf class quest")

    advance_two_stages(
        human, profiles, npcs, "HumanRogue", "CaptainAshford", "Vela"
    )
    local Inventory = require(game:GetService("ServerScriptService")
        .Core.Services.InventoryService)
    local Trade = require(game:GetService("ReplicatedStorage")
        .Core.Shared.ItemTransferRules)
    local human_owner = profiles:get_character(human.UserId)
    for _, item_id in ipairs({
        "neti_trial_dagger", "neti_trial_bow",
    }) do
        assert(Inventory.count_item(human_owner, item_id) == 1,
            "Human's actual Vela prompt did not grant one owned trial item")
        assert(not Trade.can_trade(item_id)
            and not Trade.can_bank(item_id),
            "Vela trial weapon escaped its personal quest binding")
    end
    -- The trial weapons are real equippable Fighter inventory gear,
    -- not inert quest flags or a client-side icon.
    for _, weapon_id in ipairs({
        "neti_trial_dagger", "neti_trial_bow",
    }) do
        local equipped = runtime.EquipmentService:equip(
            human.UserId, weapon_id, "Weapon"
        )
        assert(equipped.ok, "Owner could not equip real Vela trial weapon "
            .. weapon_id .. ": " .. tostring(equipped.reason))
        local after_equip = profiles:get_character(human.UserId)
        assert(after_equip.Equipment.Weapon == weapon_id,
            "Vela trial weapon did not become actual equipped item")
    end
    print("[C4 Original Second NPC Live] REAL_VELA_ATOMIC_WEAPONS_PASS")

    advance_two_stages(
        elf, profiles, npcs,
        "ElvenScout", "PathfinderElyra", "WardenThorne"
    )
    local elf_owner = profiles:get_character(elf.UserId)
    assert(Inventory.count_item(elf_owner, "neti_trial_dagger") == 0
        and Inventory.count_item(elf_owner, "neti_trial_bow") == 0,
        "Elf Thorne talk duplicated Human Rogue trial weapons")
    assert(Inventory.count_item(
        profiles:get_character(human.UserId), "neti_trial_dagger"
    ) == 1, "The second client's NPC modified the first client's loot")
    print("[C4 Original Second NPC Live] REAL_THORNE_ISOLATED_PASS")
    print("[C4 Original Second NPC Live] TWO_CLIENT_STAGE_TWO_PASS")
    verify_return(human, profiles, npcs, "HumanRogue", "Vela")
    assert(npcs:quest_service():build_snapshot(
        elf.UserId
    ).Step == 3, "Human return modified the independent Elf's quest")
    verify_return(elf, profiles, npcs, "ElvenScout", "WardenThorne")
    print("[C4 Original Second NPC Live] REAL_STAGE_FOUR_TURNIN_PASS")
    verify_captain_report(human, npcs)
    assert(npcs:quest_service():build_snapshot(
        elf.UserId
    ).Step == 5, "Captain report must not advance the other quest branch")
    print("[C4 Original Second NPC Live] REAL_CAPTAIN_REPORT_PASS")
    verify_captain_final(human, profiles, npcs)
    assert(npcs:quest_service():build_snapshot(
        elf.UserId
    ).Step == 5, "Rogue final report cannot complete Elf's separate quest")
    print("[C4 Original Second NPC Live] REAL_FINAL_CAPTAIN_TURNIN_PASS")
    verify_scout_hub_reports(elf, profiles, npcs)
    assert(npcs:quest_service():build_snapshot(
        human.UserId
    ).Ready == true,
        "Elf source-quest completion must not modify Human quest")
    print("[C4 Original Second NPC Live] REAL_SCOUT_HUB_REPORT_PASS")
    local mentors = wait_for(function()
        return _G.C4OriginalTransferMentors_TEMP
    end, "real existing Base first-transfer mentor authority", 12)
    local transfer_definitions = require(
        RS.Core.Shared.OriginalFirstTransferDefinitions
    )
    local rogue = assert(
        transfer_definitions.for_branch("HumanRogue")
    )
    local scout = assert(
        transfer_definitions.for_branch("ElvenScout")
    )
    local mentor_parts = workspace.OriginalFirstTransferMentors
    verify_physical_transfer(
        human, profiles, mentors, rogue,
        assert(mentor_parts:FindFirstChild(scout.MentorId))
    )
    assert(profiles:get_character(elf.UserId)
        .Identity.ClassId == "Fighter",
        "Human transfer changed the independent Elf's first class")
    verify_physical_transfer(
        elf, profiles, mentors, scout,
        assert(mentor_parts:FindFirstChild(rogue.MentorId))
    )
    assert(profiles:get_character(human.UserId)
        .Identity.ClassId == "Ashenblade",
        "Elf transfer changed previously awarded Human class")
    print("[C4 Original Second NPC Live] TWO_CLIENT_FIRST_TRANSFER_PASS")
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[C4 Original Second NPC Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(190, function()
    STS:EndTest("FAIL global original second NPC timeout")
end)
]==]
driver.Parent = SSS

local ok, value = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        2, "C4OriginalPhysicalVelaThorneTwoClients_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and value == "PASS",
    "Original C4 second NPC two-client playtest failed: " .. tostring(value))
if workspace:GetAttribute("DungeonMMOStudioTransferFocus") == true then
    -- This focused test seeds finished source quests; it has NOT rerun
    -- the previously accepted stage-one through nine NPC interactions.
    print("[C4 Original Second NPC Live] VERIFIED_TWO_CLIENT_FIRST_TRANSFER_PASS")
else
    print("[C4 Original Second NPC Live] VERIFIED_TWO_CLIENT_STAGE_TWO_PASS")
    print("[C4 Original Second NPC Live] VERIFIED_STAGE_FOUR_TURNIN_PASS")
    print("[C4 Original Second NPC Live] VERIFIED_STAGE_FIVE_CAPTAIN_PASS")
    print("[C4 Original Second NPC Live] VERIFIED_ROGUE_FINAL_SOURCE_PASS")
    print("[C4 Original Second NPC Live] VERIFIED_SCOUT_SOURCE_COMPLETE_PASS")
    print("[C4 Original Second NPC Live] VERIFIED_TWO_CLIENT_FIRST_TRANSFER_PASS")
end
