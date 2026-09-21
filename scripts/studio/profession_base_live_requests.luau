--!strict
-- Disposable unpublished Base Play test. Run from Studio Edit mode only.
-- This exercises the live client-to-server profession RemoteEvent path.
-- No authored place, production account or cloud DataStore is changed.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Profession live fixture requires an unpublished local place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer"):WaitForChild(
    "StarterPlayerScripts")
local STS = game:GetService("StudioTestService")

assert(SSS:FindFirstChild("Base") and not SSS:FindFirstChild("Dungeon"),
    "Profession live fixture requires the Base composition")

local channel = Instance.new("RemoteEvent")
channel.Name = "ProfessionBaseLiveFixture_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "ProfessionBaseLiveClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("ProfessionBaseLiveFixture_TEMP")
local remotes = RS:WaitForChild("Core"):WaitForChild("Remotes")
local craft = remotes:WaitForChild("ProfessionCraftRequest")
local results = remotes:WaitForChild("ProfessionActionResult")
local prompt_service = game:GetService("ProximityPromptService")
local visible_prompts = {}

prompt_service.PromptShown:Connect(function(prompt)
    visible_prompts[prompt] = true
end)

results.OnClientEvent:Connect(function(payload)
    if type(payload) == "table"
        and (payload.action == "Craft" or payload.action == "Gather")
    then
        channel:FireServer("Result", payload)
    end
end)

channel.OnClientEvent:Connect(function(command, data)
    if command == "Craft" then
        -- The malicious second argument must not become a success result.
        craft:FireServer(data, {
            MinigameId = "FabricatedWin",
            Success = true,
        })
    elseif command == "Gather" then
        local runtime = workspace:WaitForChild("ProfessionRuntime")
        local node = runtime:WaitForChild("Base.RawHideCache")
        local prompt = node:WaitForChild("PromptRoot")
            :WaitForChild("ProfessionGatherPrompt")
        if not prompt.Enabled then
            channel:FireServer("AlreadyDepleted")
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

        local deadline = os.clock() + 4
        while not visible_prompts[prompt] and os.clock() < deadline do
            task.wait(0.1)
        end
        channel:FireServer("GatherDiagnostic", {
            shown = visible_prompts[prompt] == true,
            enabled = prompt.Enabled,
            parented = prompt:IsDescendantOf(workspace),
            distance = (game.Players.LocalPlayer.Character
                .HumanoidRootPart.Position - prompt.Parent.Position).Magnitude,
        })
        prompt:InputHoldBegin()
        task.wait(0.9)
        prompt:InputHoldEnd()
    end
end)

channel:FireServer("Ready")
]==]
client.Parent = SPS

local server = Instance.new("Script")
server.Name = "ProfessionBaseLiveDriver_TEMP"
server.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local STS = game:GetService("StudioTestService")
local channel = RS:WaitForChild("ProfessionBaseLiveFixture_TEMP")
local ready_user_id = nil
local results = {}
local gather_diagnostic = nil
local already_depleted = false

channel.OnServerEvent:Connect(function(player, kind, payload)
    if kind == "Ready" then
        ready_user_id = player.UserId
    elseif kind == "Result" and player.UserId == ready_user_id then
        print("[Profession Base Live] ACTION_RESULT action="
            .. tostring(payload.action) .. " ok=" .. tostring(payload.ok)
            .. " reason=" .. tostring(payload.reason)
            .. " node=" .. tostring(payload.node_id))
        table.insert(results, payload)
    elseif kind == "AlreadyDepleted" and player.UserId == ready_user_id
    then
        already_depleted = true
        print("[Profession Base Live] CLIENT_NODE_DEPLETED")
    elseif kind == "GatherDiagnostic" and player.UserId == ready_user_id
    then
        gather_diagnostic = payload
        print("[Profession Base Live] GATHER_PROMPT shown="
            .. tostring(payload.shown) .. " enabled="
            .. tostring(payload.enabled) .. " parented="
            .. tostring(payload.parented) .. " distance="
            .. tostring(payload.distance))
    end
end)

-- Args:
--   predicate: () -> any; supplies a truthy value when ready.
--   description: string; names the missing condition.
--   seconds: number; maximum time to wait.
-- Returns:
--   any: the first truthy value returned by the predicate.
local function wait_for(predicate, description, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Profession Base Live] TIMEOUT " .. description)
end

-- Args:
--   player: Player; the test player.
--   anchor: BasePart; the server-owned station or resource part.
--   distance: number; horizontal offset from the anchor.
-- Returns:
--   nil: positions and temporarily anchors the player's root.
local function move_player(player, anchor, distance)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart", 25)
    assert(root and root:IsA("BasePart"), "player root missing")
    root.Anchored = true
    root.CFrame = anchor.CFrame * CFrame.new(0, 3, distance)
    task.wait(0.35)
end

-- Args:
--   player: Player; the client that will send the request.
--   command: string; Craft or Gather.
--   recipe_id: string?; the recipe to request for crafting.
-- Returns:
--   table: observed server ProfessionActionResult payload.
local function request_action(player, command, recipe_id)
    table.clear(results)
    channel:FireClient(player, command, recipe_id)
    return wait_for(function()
        if #results > 0 then
            return table.remove(results, 1)
        end
    end, command .. " result", 15)
end

-- Args:
--   player: Player; the test player.
--   anchor: BasePart; actual server-owned profession station.
--   recipe_id: string; known recipe associated with that station.
-- Returns:
--   nil: asserts real far rejection and near-station request routing.
local function verify_station(player, anchor, recipe_id)
    move_player(player, anchor, 65)
    local far = request_action(player, "Craft", recipe_id)
    assert(far.ok == false and far.reason == "NotAtRequiredStation",
        "far request was not rejected at " .. recipe_id
            .. ": " .. tostring(far.reason))

    move_player(player, anchor, 4)
    local near = request_action(player, "Craft", recipe_id)
    assert(near.reason ~= "NotAtRequiredStation"
        and near.reason ~= "ProfileNotReady",
        "near request did not reach crafting service at "
            .. recipe_id .. ": " .. tostring(near.reason))
    print("[Profession Base Live] STATION_RANGE_PASS " .. recipe_id
        .. " near_reason=" .. tostring(near.reason))
end

-- Args: None.
-- Returns: nil; reports the real multiplayer client/server checks.
local function run()
    local player = wait_for(function()
        return Players:GetPlayers()[1]
    end, "test player", 30)
    wait_for(function()
        return ready_user_id == player.UserId
    end, "client ready", 30)
    local runtime = wait_for(function()
        return workspace:FindFirstChild("ProfessionRuntime")
    end, "Base profession runtime", 30)
    local leather = runtime:WaitForChild("LeatherworkingStationPlaceholder")
    local enchanting = runtime:WaitForChild("EnchantingStationPlaceholder")
    local hide = runtime:WaitForChild("Base.RawHideCache")
        :WaitForChild("PromptRoot")

    -- Give the Base profile lifecycle time to load before live requests.
    task.wait(5)
    verify_station(player, leather, "cure_raw_hide")
    verify_station(player, enchanting, "inscribe_warding_rune")

    move_player(player, hide, 4)
    local first = request_action(player, "Gather")
    assert(gather_diagnostic and gather_diagnostic.shown == true,
        "client prompt did not become visible")
    assert(first.ok == true and first.node_id == "Base.RawHideCache",
        "first hide claim failed: " .. tostring(first.reason))
    -- The authoritative success snapshot hides the personal node on
    -- the client. Repeated physical triggering is therefore unavailable.
    table.clear(results)
    channel:FireClient(player, "Gather")
    wait_for(function()
        return already_depleted
    end, "client prompt was not depleted after the first claim", 10)
    assert(#results == 0,
        "disabled personal node unexpectedly triggered a second grant")
    print("[Profession Base Live] HIDE_CLAIM_ONCE_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Profession Base Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
]==]
server.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("ProfessionBaseLiveFixture_TEMP")
end)
server:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Profession Base live fixture failed: " .. tostring(result))
print("[Profession Base Live] VERIFIED_PLAY_MODE_PASS")
