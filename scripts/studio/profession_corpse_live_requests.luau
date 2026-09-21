--!strict
-- Disposable unpublished Base Play test for a temporary, server-created
-- animal corpse. Neither the authored place nor any DataStore is modified.
assert(game.GameId == 0 and game.PlaceId == 0,
    "Corpse test requires an unpublished local Studio place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

assert(SSS:FindFirstChild("Base") and not SSS:FindFirstChild("Dungeon"),
    "Corpse test requires the Base composition")

local channel = Instance.new("RemoteEvent")
channel.Name = "BeastSkinningLiveChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "BeastSkinningLiveClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("BeastSkinningLiveChannel_TEMP")
local action_result = RS.Core.Remotes:WaitForChild("ProfessionActionResult")
local prompt_service = game:GetService("ProximityPromptService")
local visible_prompts = {}

prompt_service.PromptShown:Connect(function(prompt)
    visible_prompts[prompt] = true
end)

action_result.OnClientEvent:Connect(function(payload)
    if type(payload) == "table" and payload.action == "Gather" then
        channel:FireServer("Result", payload)
    end
end)

-- Args:
--   command: string; requests one physical prompt interaction.
-- Returns:
--   nil: sends a diagnostic and performs a genuine client hold.
local function handle_command(command)
    if command ~= "Skin" then
        return
    end
    local model = workspace:WaitForChild("BeastSkinningFixture_TEMP")
    local prompt = model:WaitForChild("HumanoidRootPart")
        :WaitForChild("BeastSkinningPrompt", 12)
    assert(prompt, "eligible corpse prompt was not replicated")
    if not prompt.Enabled then
        channel:FireServer("Depleted")
        return
    end

    local camera = workspace.CurrentCamera
    if camera then
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = CFrame.lookAt(
            prompt.Parent.Position + Vector3.new(0, 3, 8),
            prompt.Parent.Position
        )
    end
    local deadline = os.clock() + 5
    while not visible_prompts[prompt] and os.clock() < deadline do
        task.wait(0.1)
    end
    channel:FireServer("Prompt", {
        visible = visible_prompts[prompt] == true,
        enabled = prompt.Enabled,
    })
    prompt:InputHoldBegin()
    task.wait(0.85)
    prompt:InputHoldEnd()
end

channel.OnClientEvent:Connect(handle_command)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local server = Instance.new("Script")
server.Name = "BeastSkinningLiveDriver_TEMP"
server.Source = [==[
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local STS = game:GetService("StudioTestService")
local channel = RS:WaitForChild("BeastSkinningLiveChannel_TEMP")

local ready_user_id = nil
local results = {}
local prompt_visible = false
local client_depleted = false

channel.OnServerEvent:Connect(function(player, kind, value)
    if kind == "Ready" then
        ready_user_id = player.UserId
    elseif player.UserId == ready_user_id and kind == "Result" then
        table.insert(results, value)
    elseif player.UserId == ready_user_id and kind == "Prompt" then
        prompt_visible = value.visible and value.enabled
    elseif player.UserId == ready_user_id and kind == "Depleted" then
        client_depleted = true
    end
end)

-- Args:
--   predicate: () -> any; returns a truthy value when ready.
--   label: string; description included in a timeout error.
--   seconds: number; timeout duration.
-- Returns:
--   any: the first truthy value observed.
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Beast Skinning Live] TIMEOUT " .. label)
end

-- Args:
--   species: string; server-assigned, stable creature species ID.
--   family: string; server-assigned creature family.
--   origin: Vector3; test player location.
-- Returns:
--   Model: a temporary, combat-neutral server-authored test creature.
local function create_creature(species, family, origin)
    local model = Instance.new("Model")
    model.Name = "BeastSkinningFixture_TEMP"
    model:SetAttribute("CreatureSpeciesId", species)
    model:SetAttribute("CreatureFamily", family)
    model:SetAttribute("LootComplete", false)
    model:SetAttribute("SkinningClaimed", false)

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Size = Vector3.new(2, 2, 2)
    root.CFrame = CFrame.new(origin + Vector3.new(0, 0, 5))
    root.Anchored = true
    root.CanCollide = false
    root.Parent = model
    model.PrimaryPart = root

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.BreakJointsOnDeath = false
    humanoid.Parent = model
    model.Parent = workspace
    CollectionService:AddTag(model, "DungeonMMOSkinnableBeast")
    return model
end

-- Args:
--   player: Player; the actual simulated Studio test client.
-- Returns:
--   nil: validates the server-owned corpse's real client interaction.
local function verify_corpse(player)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart", 25)
    assert(root, "test player did not spawn")
    root.Anchored = true
    task.wait(7)

    local model = create_creature(
        "forest_wolf", "Beast", root.Position)
    local humanoid = assert(model:FindFirstChildOfClass("Humanoid"))
    assert(model.PrimaryPart:FindFirstChild("BeastSkinningPrompt") == nil,
        "living beast already exposes Skinning")

    humanoid.Health = 0
    task.wait(0.15)
    assert(model.PrimaryPart:FindFirstChild("BeastSkinningPrompt") == nil,
        "unlooted beast already exposes Skinning")
    model:SetAttribute("LootComplete", true)
    local prompt = wait_for(function()
        return model.PrimaryPart:FindFirstChild("BeastSkinningPrompt")
    end, "eligible animal corpse prompt", 10)
    assert(prompt.Enabled, "eligible animal corpse prompt is disabled")

    channel:FireClient(player, "Skin")
    local result = wait_for(function()
        return table.remove(results, 1)
    end, "real client hide grant", 16)
    assert(prompt_visible and result.ok == true
        and result.action == "Gather"
        and result.item_id == "raw_hide"
        and result.quantity == 1,
        "real client did not receive exactly one raw hide")
    print("[Beast Skinning Live] CLIENT_HIDE_GRANT_PASS")

    assert(model:GetAttribute("SkinningClaimed") == true
        and prompt.Enabled == false,
        "the server did not mark this corpse permanently skinned")
    channel:FireClient(player, "Skin")
    wait_for(function()
        return client_depleted
    end, "second client action must be disabled", 8)
    assert(#results == 0, "a disabled corpse granted another hide")
    print("[Beast Skinning Live] ONCE_ONLY_CORPSE_PASS")
    model:Destroy()
end

-- Args: None.
-- Returns: nil; finishes the disposable server/client Play test.
local function run()
    local player = wait_for(function()
        return Players:GetPlayers()[1]
    end, "Studio test player", 30)
    wait_for(function()
        return ready_user_id == player.UserId
    end, "client listener", 30)
    wait_for(function()
        return workspace:FindFirstChild("ProfessionRuntime")
    end, "authoritative profession runtime", 30)

    verify_corpse(player)
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Beast Skinning Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
]==]
server.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("BeastSkinningLiveFixture_TEMP")
end)
server:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Beast Skinning Play test failed: " .. tostring(result))
print("[Beast Skinning Live] VERIFIED_PLAY_MODE_PASS")
