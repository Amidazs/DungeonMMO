--!strict
-- Unpublished higher-depth 2/4-player Event/Secret lifecycle Play-mode test.
-- Source edits below affect only this disposable loaded DataModel.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Use an unpublished local Dungeon build for this test.")

local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local W = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local dungeon = SSS:WaitForChild("Dungeon")
local party_size = W:GetAttribute("DungeonMMOTempPartySize") or 2
assert(party_size == 2 or party_size == 4,
    "Multiplayer test requires 2 or 4 actual Studio clients")
local dungeon_id = W:GetAttribute("DungeonMMOPlaceholderPreviewDungeonId")
if dungeon_id ~= "TestDungeon" and dungeon_id ~= "AbandonedMine" then
    dungeon_id = "TestDungeon"
end
local depth_id = W:GetAttribute("DungeonMMOStudioDifficultyId")
if depth_id ~= "Depth2" and depth_id ~= "Depth4" then
    depth_id = "Depth2"
end

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
local lock = "OptionalBossRuntimeEnabled = false,"
local first = assert(string.find(definition_source, lock, 1, true))
local second = assert(string.find(
    definition_source, lock, first + #lock, true))
local selected = if dungeon_id == "TestDungeon" then first else second
definitions.Source = string.sub(definition_source, 1, selected - 1)
    .. "OptionalBossRuntimeEnabled = true, -- TEMP local test only"
    .. string.sub(definition_source, selected + #lock)
replace_once(dungeon.DungeonRuntime,
    'local runtime = RuntimeServices.new("Dungeon")',
    'local runtime = RuntimeServices.new("Dungeon")\n'
        .. '_G.Phase4DepthPartyRuntime = runtime')
replace_once(dungeon.DungeonRuntime,
    '    if RunService:IsStudio() then\n'
        .. '        local studio = StudioSessionFactory.create_for_players(\n'
        .. '            {player},',
    '    if RunService:IsStudio() then\n'
        .. '        while #Players:GetPlayers() < '
        .. tostring(party_size) .. ' do task.wait(0.1) end\n'
        .. '        local studio = StudioSessionFactory.create_for_players(\n'
        .. '            Players:GetPlayers(),')

SSS:SetAttribute("DungeonMMOOptionalBossEventStartUnix", os.time() - 60)
SSS:SetAttribute("DungeonMMOOptionalBossEventEndUnix", os.time() + 900)
SSS:SetAttribute("DungeonMMOOptionalBossSecretChanceBasisPoints", 10000)
W:SetAttribute("DungeonMMOTempPartySize", party_size)
W:SetAttribute("DungeonMMOStudioDungeonId", dungeon_id)
W:SetAttribute("DungeonMMOStudioDifficultyId", depth_id)
W:SetAttribute("DungeonMMOPlaceholderPreviewDungeonId", dungeon_id)
W:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
W:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderPlayableEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderOptionalPlayEnabled", true)

local driver = Instance.new("Script")
driver.Name = "Phase4DepthPartyOptional_TEMP"
driver.Source = [=[
local Players = game:GetService("Players")
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local W = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local Tags = game:GetService("CollectionService")
local Dungeon = SSS:WaitForChild("Dungeon")
local Gates = require(Dungeon.DungeonOptionalEntranceGates)

local function check(value, message)
    assert(value, "[Depth Party Optional] " .. message)
end
local function until_value(predicate, message, seconds)
    local deadline = os.clock() + seconds
    repeat
        local result = predicate()
        if result then return result end
        task.wait(0.1)
    until os.clock() > deadline
    error("[Depth Party Optional] TIMEOUT " .. message)
end
local function anchor(identifier)
    return until_value(function()
        for _, part in ipairs(Tags:GetTagged("DungeonMMOEnvironmentAnchor")) do
            if part:GetAttribute("AnchorId") == identifier then
                return part
            end
        end
    end, "anchor " .. identifier, 16)
end
local function approach(player, identifier)
    local trigger = anchor(identifier)
    local character = until_value(function()
        local char = player.Character
        return char and char:FindFirstChild("HumanoidRootPart")
            and char:FindFirstChildOfClass("Humanoid") and char
    end, "character " .. player.Name, 20)
    local root = character.HumanoidRootPart
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    -- This fixture exercises multiplayer lifecycle, not normal combat.
    humanoid.MaxHealth = 100000
    humanoid.Health = 100000
    root.CFrame = trigger.CFrame * CFrame.new(0, 0, 9)
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.12)
    humanoid:MoveTo(trigger.Position + Vector3.new(0, 0, -2))
end
local function living_enemies()
    local runtime = W:FindFirstChild("DungeonGameplayRuntime")
    local folder = runtime and runtime:FindFirstChild("DungeonEnemies")
    local result = {}
    if not folder then return result end
    for _, model in ipairs(folder:GetChildren()) do
        if model:IsA("Model") then
            local hp = model:FindFirstChildOfClass("Humanoid")
            if hp and hp.Health > 0 then table.insert(result, model) end
        end
    end
    return result
end
local function state_of(runtime, session_id, encounter_id)
    local session = runtime.SessionService:get(session_id)
    local state = session and session.InstanceState
        and session.InstanceState.EncounterRuntime
    return state and state.EncounterStates[encounter_id]
end
local function history(runtime, user_id)
    local character = runtime.ProfileService:get_character(user_id, 1)
    return character and character.RewardHistory
        and character.RewardHistory.Monster or {}
end
local function transaction(history_entries, fragment)
    for key in pairs(history_entries) do
        if string.find(key, fragment, 1, true) then
            return key
        end
    end
end
local function history_count(records)
    local count = 0
    for _ in pairs(records) do count += 1 end
    return count
end
local function run()
    local dungeon_id = W:GetAttribute("DungeonMMOStudioDungeonId")
    local depth_id = W:GetAttribute("DungeonMMOStudioDifficultyId")
    local prefix = if dungeon_id == "TestDungeon" then "Temple" else "Mine"
    local members_expected = W:GetAttribute("DungeonMMOTempPartySize")
    local party = until_value(function()
        local members = Players:GetPlayers()
        return #members == members_expected and members
    end, "real multiplayer Studio clients", 50)
    local seen = {}
    for _, player in ipairs(party) do
        check(not seen[player.UserId], "all clients need distinct UserIds")
        seen[player.UserId] = true
    end
    local runtime = until_value(function()
        return _G.Phase4DepthPartyRuntime
    end, "shared dungeon runtime", 35)
    local party_session = until_value(function()
        local s = runtime.SessionService:get_for_user(party[1].UserId)
        if not s or s.State ~= "Active" or not s.InstanceState
            or not s.InstanceState.EncounterPlan then return nil end
        for _, player in ipairs(party) do
            local member = s.Members[tostring(player.UserId)]
            if not member or member.Connected ~= true then return nil end
        end
        return s
    end, "all party members admitted into the same session", 50)
    local id = party_session.SessionId
    local definition = assert(require(
        RS.Core.Shared.DungeonDifficultyDefinitions
    ).get(dungeon_id, depth_id))
    check(not definition.RuntimeReleaseEnabled
        and party_session.Difficulty.Id == depth_id,
        "only selected unpublished higher depth is used")
    check(party_session.InstanceState.OptionalBossEventActive
        and party_session.InstanceState.OptionalBossSecretUnlocked,
        "both optional bosses must be server-issued in one frozen run")
    local plan = party_session.InstanceState.EncounterPlan
    check(#plan == #definition.EncounterSequence + 2,
        "party's optional plan must preserve every required room")
    local room_order = {}
    for _, entry in ipairs(plan) do
        table.insert(room_order, entry.RoomSlotId)
    end
    check(room_order[1] == "Room1"
        and room_order[2] == "EventArena"
        and room_order[#room_order - 1] == "SecretArena"
        and room_order[#room_order] == "Room"
            .. tostring(#definition.EncounterSequence),
        "optional bosses must use selected higher-depth room order")
    print("[Depth Party Optional] ADMITTED_PARTY size="
        .. members_expected .. " " .. dungeon_id .. " " .. depth_id
        .. " plan=" .. table.concat(room_order, ","))
    local root = assert(W:FindFirstChild(
        "DungeonMMOPlaceholderPhysicalContent"))
    local event_gate = assert(Gates.get(root, "EventArena"))
    local secret_gate = assert(Gates.get(root, "SecretArena"))
    local legacy_event = assert(root.EventBridge.EntranceGate)
    local legacy_secret = assert(root.SecretBridge.EntranceGate)
    check(event_gate.CanCollide and secret_gate.CanCollide
        and legacy_event.CanCollide and legacy_secret.CanCollide,
        "both optional routes begin sealed and Depth1 stays sealed")
    local remaining = {}
    for index = 2, #party do
        table.insert(remaining, party[index])
    end
    local departed = party[1]
    local alive = function() return living_enemies() end

    local function clear(entry, models)
        for _, model in ipairs(models) do
            model:FindFirstChildOfClass("Humanoid").Health = 0
        end
        until_value(function()
            return state_of(runtime, id, entry.Id) == "Cleared"
        end, entry.RoomSlotId .. " completion", 20)
        end
    local function start(entry, users)
        local slot = entry.RoomSlotId
        local kind = if entry.Kind == "EventBoss" then "Event"
            elseif entry.Kind == "SecretBoss" then "Secret" else nil
        local trigger = if kind then prefix .. "." .. depth_id .. "."
            .. kind .. ".Trigger" else prefix .. "." .. depth_id
            .. "." .. slot .. ".Trigger"
        check(state_of(runtime, id, entry.Id) == "Pending",
            slot .. " must be Pending before entering")
        for _, player in ipairs(users) do
            approach(player, trigger)
        end
        until_value(function()
            return state_of(runtime, id, entry.Id) == "Active"
        end, slot .. " real physical trigger", 13)
        local models = until_value(function()
            local list = alive()
            return #list > 0 and list
        end, slot .. " enemy/boss spawn", 15)
        if entry.ExecutorId == "Boss" then
            check(#models == 1 and models[1]:GetAttribute("BossId")
                == entry.BossId, slot .. " must spawn exactly one expected boss")
        end
        return models
    end

    local event = assert(plan[2])
    local first = assert(plan[1])
    clear(first, start(first, {departed}))
    until_value(function() return not event_gate.CanCollide end,
        "Event gate opens after Room1", 8)
    check(secret_gate.CanCollide and legacy_event.CanCollide
        and legacy_secret.CanCollide,
        "Room1 must not open Secret or legacy Depth1 bridges")
    local event_models = start(event, {departed, remaining[1]})
    approach(remaining[1], prefix .. "." .. depth_id .. ".Event.Trigger")
    task.wait(0.3)
    check(#alive() == 1 and state_of(runtime, id, event.Id) == "Active",
        "concurrent Event arrivals must not spawn duplicate bosses")
    print("[Depth Party Optional] EVENT_ONE_BOSS_CONCURRENT_PASS")
    local previous_checkpoint = runtime.SessionService:get(id).Checkpoint.Id
    departed:Kick("TEMP higher-depth party encounter test")
    until_value(function()
        return Players:GetPlayerByUserId(departed.UserId) == nil
    end, "actual Studio client disconnect", 28)
    local after = until_value(function()
        local s = runtime.SessionService:get(id)
        return s and s.Members[tostring(departed.UserId)]
            and not s.Members[tostring(departed.UserId)].Connected and s
    end, "persisted real PlayerRemoving flag", 18)
    check(after.State == "Active"
        and after.Checkpoint.Id == previous_checkpoint
        and state_of(runtime, id, event.Id) == "Active",
        "disconnect must preserve active boss and checkpoint")
    for _, player in ipairs(remaining) do
        check(after.Members[tostring(player.UserId)].Connected,
            "remaining party members must stay connected")
    end
    print("[Depth Party Optional] DISCONNECT_ACTIVE_EVENT_PASS")

    local Sequencer = require(Dungeon.DungeonEncounterSequencer)
    local restored = Sequencer.new(after.InstanceState.EncounterPlan,
        after.InstanceState.EncounterRuntime)
    check(restored:state_of(event.Id) == "Pending"
        and restored:state_of(first.Id) == "Cleared"
        and restored:next_id() == event.Id,
        "detached controller restores interrupted Event without Room1 reset")
    clear(event, event_models)

    local reward_key = nil
    for _, player in ipairs(remaining) do
        local records = history(runtime, player.UserId)
        local key = transaction(records, event.BossId .. ":" .. event.Id)
        check(key ~= nil, "remaining member missing Event boss reward")
        if not reward_key then reward_key = key end
    end
    local before_counts = {}
    local recipients = {}
    for _, player in ipairs(remaining) do
        table.insert(recipients, player.UserId)
        before_counts[player.UserId] = history_count(
            history(runtime, player.UserId))
    end
    local replay = runtime.RewardService:grant_monster_reward(
        recipients,
        {XP = 40, GoldMin = 0, GoldMax = 0,
            BossId = event.BossId},
        reward_key
    )
    check(replay.ok and replay.already_applied,
        "replayed Event transaction must be idempotent for party")
    for _, player in ipairs(remaining) do
        check(history_count(history(runtime, player.UserId))
            == before_counts[player.UserId],
            "replayed Event cannot increase member reward history")
    end
    print("[Depth Party Optional] PARTY_EVENT_REWARD_REPLAY_BLOCKED")

    local secret = nil
    for index = 3, #plan do
        local entry = plan[index]
        if entry.Kind == "SecretBoss" then
            secret = entry
            check(not secret_gate.CanCollide,
                "Secret gate opens after actual penultimate room")
            local models = start(entry, {remaining[1],
                remaining[#remaining]})
            approach(remaining[1],
                prefix .. "." .. depth_id .. ".Secret.Trigger")
            task.wait(0.3)
            check(#alive() == 1
                and state_of(runtime, id, entry.Id) == "Active",
                "concurrent Secret entry must not duplicate boss")
            clear(entry, models)
            for _, player in ipairs(remaining) do
                check(transaction(history(runtime, player.UserId),
                    entry.BossId .. ":" .. entry.Id) ~= nil,
                    "every connected member must receive Secret reward once")
            end
            print("[Depth Party Optional] PARTY_SECRET_ONE_BOSS_PASS")
        else
            clear(entry, start(entry, {remaining[1]}))
        end
    end
    check(secret ~= nil, "run must include a selected Secret boss")
    local completed = until_value(function()
        local s = runtime.SessionService:get(id)
        return s and s.State == "Complete" and s
    end, "surviving party completes higher-depth run", 20)
    check(completed.InstanceState.EncounterRuntime
        .EncounterStates[plan[#plan].Id] == "Cleared",
        "all required rooms and final boss must remain cleared")
    check(#remaining == members_expected - 1,
        "party size must shrink by exactly one Studio disconnection")
    local reward_commit = until_value(function()
        local s = runtime.SessionService:get(id)
        return s and s.State == "Complete"
            and s.CompletionRewardsCommitted == true and s
    end, "party completion rewards persisted", 20)
    local recipient_ids = reward_commit.CompletionRecipients or {}
    check(#recipient_ids == #remaining,
        "completed dungeon must reward only connected surviving members")
    local expected = {}
    for _, player in ipairs(remaining) do
        expected[player.UserId] = true
    end
    local old_gold = {}
    local old_completion_counts = {}
    for _, user_id in ipairs(recipient_ids) do
        check(expected[user_id] == true,
            "completion recipient must be a connected surviving member")
        local member_result = reward_commit.CompletionRewardSummary
            and reward_commit.CompletionRewardSummary[tostring(user_id)]
        check(member_result and member_result.ok,
            "persisted per-member completion reward must succeed")
        local character = assert(
            runtime.ProfileService:get_character(user_id, 1))
        old_gold[user_id] = character.Gold
        old_completion_counts[user_id] = history_count(
            character.RewardHistory.Completion or {})
    end
    check(not expected[departed.UserId],
        "departed player cannot re-enter completion recipient set")
    local CompletionService = require(Dungeon.CompletionService)
    local duplicate = CompletionService.new(
        runtime.SessionService, runtime.RewardService,
        runtime.ProfileService,
        {XP = 1, GoldMin = 0, GoldMax = 0}
    ):commit(id)
    check(duplicate.ok and duplicate.already_applied,
        "replaying party completion cannot grant the dungeon twice")
    for _, user_id in ipairs(recipient_ids) do
        local character = assert(
            runtime.ProfileService:get_character(user_id, 1))
        check(character.Gold == old_gold[user_id]
            and history_count(character.RewardHistory.Completion or {})
                == old_completion_counts[user_id],
            "completion replay must preserve each member's rewards")
    end
    print("[Depth Party Optional] PER_MEMBER_COMPLETION_REPLAY_PASS "
        .. tostring(#recipient_ids))
    print("[Depth Party Optional] MULTIPLAYER_DEPTH_PASS "
        .. dungeon_id .. " " .. depth_id
        .. " initial=" .. members_expected
        .. " remaining=" .. #remaining)
    print("[Depth Party Optional] SAME_ACCOUNT_NETWORK_REJOIN_NOT_TESTED")
end
task.spawn(function()
    local ok, error_message = pcall(run)
    if not ok then
        warn("[Depth Party Optional] FAIL " .. tostring(error_message))
    end
    STS:EndTest(if ok then "PASS" else "FAIL "
        .. tostring(error_message))
end)
task.delay(205, function()
    STS:EndTest("FAIL global timeout")
end)
]=]
driver.Parent = SSS
local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        party_size, "DepthPartyOptional_TEMP_" .. dungeon_id .. "_" .. depth_id
    )
end)
driver:Destroy()
assert(ok and result == "PASS",
    "Higher-depth multiplayer optional fight failed: " .. tostring(result))
print("[Depth Party Optional] VERIFIED_MULTIPLAYER_DEPTH_PASS "
    .. dungeon_id .. " " .. depth_id .. " party=" .. party_size)
