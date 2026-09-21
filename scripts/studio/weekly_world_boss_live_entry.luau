--!strict
-- Disposable unpublished Dungeon Play test for a physically entered,
-- server-scheduled guardian prototype and once-per-week reward.
assert(game.PlaceId == 0 and game.GameId == 0,
    "World-boss Play test requires an unpublished local place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")
local W = game:GetService("Workspace")

local runtime_probe = Instance.new("ModuleScript")
runtime_probe.Name = "WeeklyWorldBossRuntimeProbe_TEMP"
runtime_probe.Source = "return {Runtime = nil}"
runtime_probe.Parent = SSS

local runtime_script = SSS.Dungeon.DungeonRuntime
local anchor = 'local runtime = RuntimeServices.new("Dungeon")'
local source = runtime_script.Source
local position = assert(string.find(source, anchor, 1, true),
    "Dungeon weekly boss runtime anchor missing")
assert(not string.find(source, anchor, position + #anchor, true),
    "Dungeon weekly boss runtime anchor is not unique")
runtime_script.Source = string.sub(source, 1, position - 1)
    .. anchor .. '\nrequire(game:GetService("ServerScriptService")'
    .. ':WaitForChild("WeeklyWorldBossRuntimeProbe_TEMP"))'
    .. '.Runtime = runtime'
    .. string.sub(source, position + #anchor)

W:SetAttribute("DungeonMMOStudioDungeonId", "TestDungeon")
W:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
W:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
W:SetAttribute("DungeonMMOPlaceholderPlayableEnabled", true)

local channel = Instance.new("RemoteEvent")
channel.Name = "WeeklyWorldBossLiveChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "WeeklyWorldBossLiveClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("WeeklyWorldBossLiveChannel_TEMP")
local prompt_service = game:GetService("ProximityPromptService")
local shown_prompts = {}

prompt_service.PromptShown:Connect(function(prompt)
    shown_prompts[prompt] = true
end)

-- Args: command (string), requested server-authorized test interaction.
-- Returns: nil; activates the real replicated entry prompt.
local function handle(command)
    if command ~= "Enter" then
        return
    end
    local gateway = workspace:WaitForChild("WeeklyBossGateway_TEMP")
    local prompt = gateway:WaitForChild("WeeklyWorldBossEntryPrompt")
    local camera = workspace.CurrentCamera
    if camera then
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = CFrame.lookAt(
            gateway.Position + Vector3.new(0, 5, 10),
            gateway.Position
        )
    end
    local deadline = os.clock() + 4
    while not shown_prompts[prompt] and os.clock() < deadline do
        task.wait(0.1)
    end
    channel:FireServer("PromptShown", shown_prompts[prompt] == true)
    prompt:InputHoldBegin()
    task.wait(0.6)
    prompt:InputHoldEnd()
end

channel.OnClientEvent:Connect(handle)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "WeeklyWorldBossLiveDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local HttpService = game:GetService("HttpService")
local W = game:GetService("Workspace")
local channel = RS:WaitForChild("WeeklyWorldBossLiveChannel_TEMP")
local Factory = require(
    SSS.Dungeon:WaitForChild("DungeonWeeklyWorldBossFactory")
)

local ready_id = nil
local prompt_shown = false
local entries = {}
local rewards = {}
local weekly = nil
local start_at = 0
local end_at = 0
local arena = nil

channel.OnServerEvent:Connect(function(player, kind, payload)
    if kind == "Ready" then
        ready_id = player.UserId
    elseif kind == "PromptShown" and player.UserId == ready_id then
        prompt_shown = payload == true
    end
end)

-- Args:
--   predicate: () -> any; returns truthy when expected condition holds.
--   name: string; error label for the expected condition.
--   seconds: number; maximum wait before failure.
-- Returns:
--   any: the observed truthy result.
local function wait_for(predicate, name, seconds)
    local deadline = os.clock() + seconds
    repeat
        local found = predicate()
        if found then
            return found
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Weekly Boss Live] TIMEOUT " .. name)
end

-- Args:
--   player: Player; real client admitted to the scheduled event.
--   instance_id: string; server-generated encounter identity.
--   model: Model; defeated guardian created by the shared factory.
-- Returns:
--   nil: applies the actual once-per-week profile reward.
local function complete_instance(player, instance_id, model)
    local defeat = weekly:record_defeat(instance_id, model)
    assert(defeat.ok, "live boss defeat was rejected: "
        .. tostring(defeat.reason))
    local result = weekly:grant_reward(instance_id, player.UserId)
    assert(result.ok, "live weekly reward was rejected: "
        .. tostring(result.reason))
    table.insert(rewards, result)
end

-- Args:
--   player: Player; real client that activated the server gateway.
-- Returns:
--   nil: freezes a trusted entry window and spawns an isolated boss.
local function enter_instance(player)
    if player.UserId ~= ready_id then
        return
    end
    local instance_id = HttpService:GenerateGUID(false)
    local entry = weekly:begin_instance(
        instance_id, {player.UserId}, start_at, end_at)
    assert(entry.ok, "server event entry failed: "
        .. tostring(entry.reason))
    local position = arena:GetPivot().Position
        + Vector3.new(#entries * 20, 6, 18)
    local boss = Factory.create({
        Parent = arena,
        SpawnCFrame = CFrame.new(position),
        InstanceId = instance_id,
    })
    local humanoid = assert(boss:FindFirstChildOfClass("Humanoid"))
    humanoid.Died:Connect(function()
        complete_instance(player, instance_id, boss)
    end)
    table.insert(entries, {
        Id = instance_id,
        Boss = boss,
        WeekStart = entry.week_start,
    })
end

-- Args:
--   character: Model; player's actual server-owned character.
-- Returns:
--   ProximityPrompt: the enabled temporary physical world-boss gate.
local function create_gateway(character)
    local root = assert(character:FindFirstChild("HumanoidRootPart"))
    root.Anchored = true
    local gateway = Instance.new("Part")
    gateway.Name = "WeeklyBossGateway_TEMP"
    gateway.Size = Vector3.new(5, 1, 5)
    gateway.Anchored = true
    gateway.CanCollide = false
    gateway.CFrame = root.CFrame * CFrame.new(0, -3, -8)
    gateway.Parent = W

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "WeeklyWorldBossEntryPrompt"
    prompt.ActionText = "Enter weekly boss"
    prompt.ObjectText = "Ancient Guardian"
    prompt.MaxActivationDistance = 15
    prompt.HoldDuration = 0.2
    prompt.RequiresLineOfSight = false
    prompt.Parent = gateway
    prompt.Triggered:Connect(enter_instance)

    root.CFrame = gateway.CFrame * CFrame.new(0, 3, 4)
    return prompt
end

-- Args: None.
-- Returns: nil; runs two real client entries and one weekly gold reward.
local function run()
    local player = wait_for(function()
        return Players:GetPlayers()[1]
    end, "real Studio player", 30)
    wait_for(function()
        return ready_id == player.UserId
    end, "client entry listener", 30)
    local runtime = wait_for(function()
        return require(SSS.WeeklyWorldBossRuntimeProbe_TEMP).Runtime
    end, "production Dungeon service composition", 30)
    wait_for(function()
        return runtime.ProfileService:get_character(player.UserId, 1)
    end, "player's loaded Dungeon profile", 35)
    local character = wait_for(function()
        return player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
            and player.Character
    end, "player's spawned character", 35)
    local root = character.HumanoidRootPart
    local humanoid = assert(character:FindFirstChildOfClass("Humanoid"))
    humanoid.MaxHealth = 100000
    humanoid.Health = 100000
    task.wait(5)

    weekly = runtime.WeeklyWorldBossService
    start_at = os.time() - 5
    end_at = start_at + 300
    arena = Instance.new("Folder")
    arena.Name = "WeeklyWorldBossArena_TEMP"
    arena.Parent = W
    local prompt = create_gateway(character)
    local initial_gold = assert(runtime.ProfileService:get_character(
        player.UserId, 1)).Gold
    channel:FireClient(player, "Enter")
    wait_for(function()
        return entries[1]
    end, "real client entry through active event gate", 12)
    assert(prompt_shown and entries[1].Boss.Humanoid.Health > 0,
        "client did not enter and spawn an authorized living guardian")
    print("[Weekly Boss Live] CLIENT_WINDOW_ENTRY_PASS")

    entries[1].Boss.Humanoid.Health = 0
    local first = wait_for(function()
        return rewards[1]
    end, "first guardian defeat and saved weekly reward", 15)
    assert(first.gold_granted == 100 and not first.already_applied,
        "initial guardian kill did not award weekly gold exactly once")
    local after_first = assert(runtime.ProfileService:get_character(
        player.UserId, 1))
    assert(after_first.Gold == initial_gold + 100,
        "weekly reward did not reach the real Dungeon profile")
    print("[Weekly Boss Live] FIRST_WEEKLY_REWARD_PASS")

    root.CFrame = prompt.Parent.CFrame * CFrame.new(0, 3, 4)
    task.wait(0.3)
    channel:FireClient(player, "Enter")
    wait_for(function()
        return entries[2]
    end, "second real client event entry", 12)
    entries[2].Boss.Humanoid.Health = 0
    local second = wait_for(function()
        return rewards[2]
    end, "second guardian completion result", 15)
    assert(second.already_applied and second.gold_granted == 0,
        "second event instance incorrectly awarded weekly gold")
    local after_second = assert(runtime.ProfileService:get_character(
        player.UserId, 1))
    assert(after_second.Gold == initial_gold + 100,
        "repeat world boss must not double-pay the current week")
    print("[Weekly Boss Live] NO_WEEKLY_REWARD_FARM_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Weekly Boss Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(120, function()
    STS:EndTest("FAIL weekly boss fixture global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("WeeklyWorldBossLiveFixture_TEMP")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
runtime_probe:Destroy()
assert(ok and result == "PASS",
    "Weekly boss Play test failed: " .. tostring(result))
print("[Weekly Boss Live] VERIFIED_PLAY_MODE_PASS")
