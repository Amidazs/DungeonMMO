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
print("[C4 Original Second NPC Live] VERIFIED_TWO_CLIENT_STAGE_TWO_PASS")
print("[C4 Original Second NPC Live] VERIFIED_STAGE_FOUR_TURNIN_PASS")
print("[C4 Original Second NPC Live] VERIFIED_STAGE_FIVE_CAPTAIN_PASS")
print("[C4 Original Second NPC Live] VERIFIED_ROGUE_FINAL_SOURCE_PASS")
print("[C4 Original Second NPC Live] VERIFIED_SCOUT_SOURCE_COMPLETE_PASS")
