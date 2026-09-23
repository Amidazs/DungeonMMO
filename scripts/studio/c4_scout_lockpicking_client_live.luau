--!strict
-- Unpublished genuine client ProximityPrompt -> authorized Dungeon loot.
-- Only disposable Studio DataModel scripts are instrumented.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Lock playtest needs an unpublished local Dungeon place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts

--[[
Exposes one exact disposable runtime-owned authority to the test driver.

Args:
    owner (LuaSourceContainer): Disposable local DungeonRuntime script.
    anchor (string): Exact single source line to instrument.
    replacement (string): Only temporary Studio runtime expression.

Returns:
    nil: Raises when any instrumentation anchor changed or duplicated.
]]
local function replace_once(owner: any, anchor: string, replacement: string)
    local source = owner.Source
    local first = assert(string.find(source, anchor, 1, true),
        "Local lock runtime instrumentation anchor missing")
    assert(not string.find(source, anchor, first + #anchor, true),
        "Local lock runtime instrumentation anchor ambiguous")
    owner.Source = source:sub(1, first - 1) .. replacement
        .. source:sub(first + #anchor)
end

local runtime_script = SSS.Dungeon.DungeonRuntime
local runtime_anchor = 'local runtime = RuntimeServices.new("Dungeon")'
replace_once(runtime_script, runtime_anchor, runtime_anchor
    .. '\n_G.C4ScoutLockLiveRuntime_TEMP = runtime')
local service_anchor = '    register_scout_lock_caches(session)'
replace_once(runtime_script, service_anchor, service_anchor
    .. '\n    _G.C4ScoutLockLiveService_TEMP = lockpick_service')

local channel = Instance.new("RemoteEvent")
channel.Name = "C4ScoutLockLiveChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "C4ScoutLockGenuineClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("C4ScoutLockLiveChannel_TEMP")
channel.OnClientEvent:Connect(function(action, lock_part)
    if action ~= "HoldPrompt" then
        return
    end
    local prompt = lock_part:WaitForChild("ScoutLockpickPrompt", 12)
    if not prompt then
        channel:FireServer("PromptError", "Missing actual lock prompt")
        return
    end
    local ok, reason = pcall(function()
        prompt:InputHoldBegin()
        task.wait(0.65)
        prompt:InputHoldEnd()
    end)
    if not ok then
        channel:FireServer("PromptError", tostring(reason))
        return
    end
    channel:FireServer("Held")
end)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "C4ScoutLockGenuineDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Inventory = require(SSS.Core.Services.InventoryService)
local channel = RS:WaitForChild("C4ScoutLockLiveChannel_TEMP")
local connected = {}
local errors = {}
local held = {}
channel.OnServerEvent:Connect(function(player, action, data)
    if action == "Ready" then
        connected[player.UserId] = true
    elseif action == "PromptError" then
        errors[player.UserId] = tostring(data)
    elseif action == "Held" then
        held[player.UserId] = (held[player.UserId] or 0) + 1
    end
end)

--[[
Waits for a bounded real client/server result and reports test diagnostics.

Args:
    predicate (() -> any): Genuine Studio game state predicate.
    label (string): Stage to report if no real result arrives.
    seconds (number): Maximum seconds to wait.

Returns:
    any: First truthy real state or a test failure.
]]
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local result = predicate()
        if result then return result end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[C4 Scout Lock Live] TIMEOUT " .. label)
end

--[[
Moves an actual living player into server-authored prompt range.

Args:
    player (Player): Authenticated Studio dungeon participant.
    lock (any): Server-registered actual physical world cache.

Returns:
    nil: Places the player beside the source-ranked physical lock.
]]
local function approach(player, lock)
    local root = assert(player.Character:FindFirstChild("HumanoidRootPart"))
    root.Anchored = true
    root.CFrame = lock.Part.CFrame * CFrame.new(0, 3, 4)
end

--[[
Issues a genuine local client prompt hold, without a test-only loot API.

Args:
    player (Player): Authenticated actual local Studio client.
    lock (any): Exact previously registered world lock.

Returns:
    nil: Confirms client performed the real prompt input method.
]]
local function press_prompt(player, lock)
    local before = held[player.UserId] or 0
    channel:FireClient(player, "HoldPrompt", lock.Part)
    wait_for(function()
        assert(not errors[player.UserId],
            "Real client prompt input error: "
                .. tostring(errors[player.UserId]))
        return (held[player.UserId] or 0) > before
    end, "real client held world-lock prompt", 12)
end

--[[
Reads the real server profile's one-time awarded lock material count.

Args:
    runtime (any): Actual Dungeon profile service.
    player (Player): Character owning the private reward.

Returns:
    number: Current captain-emblem inventory quantity.
]]
local function reward_count(runtime, player)
    local character = assert(runtime.ProfileService:get_character(
        player.UserId, 1
    ))
    return Inventory.count_item(character, "captain_emblem")
end

--[[
Sets up the disposable authenticated Rogue's actual trainer/progression.

Args:
    runtime (any): Real Dungeon skill and profile services.
    player (Player): Live admitted Studio participant.

Returns:
    nil: Establishes earned class/level without a fake client rank.
]]
local function prepare_rogue(runtime, player)
    assert(runtime.ProfileService:mutate(player.UserId, function(profile)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1, RaceId = "Human",
            BaseClassId = "Rogue", ClassId = "Rogue",
            CreationStage = "Complete",
        }
        character.Equipment.Weapon = "scout_dagger"
        character.Progression.SkillPointEntitlement = 250
        character.Level = 20
    end), "Disposable Rogue class could not be saved")
end

--[[
Buys one actual next class-trainer source rank at its authentic level.

Args:
    runtime (any): Real skill, profile and trainer authorities.
    player (Player): Admitted Rogue who has earned earlier ranks.
    rank (number): Requested source rank from one to five.

Returns:
    nil: Verifies a real server-purchased, sequential rank.
]]
local function purchase(runtime, player, rank)
    assert(runtime.ProfileService:mutate(player.UserId, function(profile)
        profile.Characters.Slot1.Level =
            ({20, 24, 28, 32, 36})[rank]
    end), "Disposable source level setup failed")
    local purchased = if rank == 1
        then runtime.SkillProgressionService:learn_trainer_skill(
            player.UserId, "ScoutLockpicking"
        ) else runtime.SkillProgressionService:purchase_rank(
            player.UserId, "ScoutLockpicking"
        )
    assert(purchased.ok and purchased.rank == rank,
        "Real skill service rejected source lock rank " .. tostring(rank))
end

--[[
Proves real prompt denial, one-time loot, room gating and level-two reward.

Args:
    runtime (any): Actual authenticated Dungeon composition.
    player (Player): One real connected Studio player.
    service (any): Actual world-registered Dungeon lock authority.

Returns:
    nil: Verifies the real physical prompt to profile/party flow.
]]
local function verify_actual_prompts(runtime, player, service)
    local lock_one = nil
    local lock_two = nil
    for _, lock in pairs(service._locks) do
        if lock.Rank == 1 then lock_one = lock end
        if lock.Rank == 2 then lock_two = lock end
    end
    assert(lock_one and lock_two,
        "Live Dungeon has no ranked real physical world lock caches")
    approach(player, lock_one)
    press_prompt(player, lock_one)
    task.wait(0.5)
    assert(reward_count(runtime, player) == 0,
        "A genuine prompt granted loot without any purchased lock rank")
    purchase(runtime, player, 1)
    press_prompt(player, lock_one)
    wait_for(function()
        return reward_count(runtime, player) == 1
    end, "actual purchased rank-one client prompt awarded personal loot", 12)
    print("[C4 Scout Lock Live] REAL_CLIENT_PROMPT_RANK_ONE_PASS")
    press_prompt(player, lock_one)
    task.wait(0.3)
    assert(reward_count(runtime, player) == 1,
        "Replay of an already opened prompt duplicated profile loot")
    print("[C4 Scout Lock Live] REAL_CLIENT_REPLAY_REJECTED_PASS")

    approach(player, lock_two)
    local session = assert(runtime.SessionService:get_for_user(
        player.UserId
    ))
    local denied = service:try_open(player, lock_two.Id)
    assert(not denied.ok and denied.reason == "LockRoomNotReached",
        "Forged room transition bypassed server checkpoint progression")
    assert(runtime.SessionService:activate_checkpoint(
        session.SessionId, "TEMP_ScoutLockRoom2", lock_two.CheckpointSequence
    ).ok, "Disposable second-room checkpoint could not be activated")
    denied = service:try_open(player, lock_two.Id)
    assert(not denied.ok and denied.reason == "LockpickingRankRequired",
        "First rank opened an authored level-two room lock")
    purchase(runtime, player, 2)
    press_prompt(player, lock_two)
    wait_for(function()
        return reward_count(runtime, player) == 3
    end, "actual rank-two client prompt granted two new loot items", 12)
    print("[C4 Scout Lock Live] REAL_CLIENT_ROOM_AND_RANK_TWO_PASS")
end

--[[
Checks session mode, invalid lock names and physical range from the server.

Args:
    runtime (any): Actual session service with one Studio member.
    player (Player): Original physical lockpicker.
    service (any): Whitelisted lock registry for that session.

Returns:
    nil: Proves client input cannot target an arbitrary loot container.
]]
local function verify_rejections(runtime, player, service)
    local session = assert(runtime.SessionService:get_for_user(
        player.UserId
    ))
    local lock = nil
    for _, entry in pairs(service._locks) do
        if entry.Rank == 1 then lock = entry break end
    end
    assert(lock, "Registered source world lock missing")
    assert(service:try_open(player, "AnotherPlayersBank").reason
        == "UnknownWorldLock", "Private bank was treated as dungeon loot")
    approach(player, lock)
    assert(runtime.SessionService:set_member_mode(
        session.SessionId, player.UserId, "Spectating"
    ).ok, "Disposable spectator mode setup failed")
    assert(service:try_open(player, lock.Id).reason
        == "DungeonMemberUnavailable",
        "Spectating party member gained live loot")
    assert(runtime.SessionService:set_member_mode(
        session.SessionId, player.UserId, "Active"
    ).ok, "Original active session state could not be restored")
    local root = assert(player.Character:FindFirstChild("HumanoidRootPart"))
    root.CFrame = lock.Part.CFrame * CFrame.new(0, 50, 0)
    assert(service:try_open(player, lock.Id).reason == "LockOutOfReach",
        "Remote or out-of-range client bypassed world proximity")
    print("[C4 Scout Lock Live] PARTY_AND_DISTANCE_SECURITY_PASS")
end

--[[
Runs a real unpublished Dungeon client and physical lock interaction.

Args:
    None.

Returns:
    nil: Verifies purchased-ranked prompts, secured loot and replay.
]]
local function main()
    local player = wait_for(function()
        local current = Players:GetPlayers()
        return if #current == 1 then current[1] else nil
    end, "one real Studio client", 45)
    local runtime = wait_for(function()
        return _G.C4ScoutLockLiveRuntime_TEMP
    end, "actual Dungeon runtime composition", 35)
    local service = wait_for(function()
        return _G.C4ScoutLockLiveService_TEMP
    end, "actual world lock registration", 40)
    wait_for(function()
        local session = runtime.SessionService:get_for_user(player.UserId)
        return connected[player.UserId]
            and runtime.ProfileService:get_character(player.UserId, 1)
            and session and session.State == "Active"
            and session.Members[tostring(player.UserId)]
            and session.Members[tostring(player.UserId)].Mode == "Active"
            and player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
    end, "authenticated active Dungeon party member", 60)
    prepare_rogue(runtime, player)
    verify_actual_prompts(runtime, player, service)
    verify_rejections(runtime, player, service)
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[C4 Scout Lock Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(155, function()
    STS:EndTest("FAIL global Scout lock client-playtest timeout")
end)
]==]
driver.Parent = SSS

local ok, value = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        1, "C4ScoutRealLockPrompt_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and value == "PASS",
    "Actual Scout lock client playtest failed: " .. tostring(value))
print("[C4 Scout Lock Live] VERIFIED_REAL_CLIENT_LOCKPICKING_PASS")
