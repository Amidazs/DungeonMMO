--!strict
-- Two real Studio clients, shared Base server, separate in-memory profiles.
-- Only the loaded unpublished test DataModel is instrumented.
assert(game.GameId == 0 and game.PlaceId == 0,
    "Run two-client professions only in an unpublished local Base place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

assert(SSS:FindFirstChild("Base") and not SSS:FindFirstChild("Dungeon"),
    "Two-client fixture requires Base")

-- Args:
--   owner: LuaSourceContainer; the disposable Base runtime.
--   previous: string; unique existing code anchor.
--   replacement: string; temporary test-only instrumentation.
-- Returns:
--   nil: changes the local test DataModel, never the GitHub source.
local function replace_once(owner, previous, replacement)
    local source = owner.Source
    local position = assert(string.find(source, previous, 1, true),
        "Two-client Base anchor missing")
    assert(not string.find(source, previous,
        position + #previous, true), "Two-client anchor ambiguous")
    owner.Source = string.sub(source, 1, position - 1)
        .. replacement .. string.sub(source, position + #previous)
end

local runtime_probe = Instance.new("ModuleScript")
runtime_probe.Name = "TwoClientProfessionRuntimeProbe_TEMP"
runtime_probe.Source = "return {Runtime = nil}"
runtime_probe.Parent = SSS

local base = SSS.Base.BaseRuntime
local source_anchor = 'local runtime = RuntimeServices.new("Base")'
replace_once(base, source_anchor, source_anchor
    .. '\nrequire(game:GetService("ServerScriptService")'
    .. ':WaitForChild("TwoClientProfessionRuntimeProbe_TEMP"))'
    .. '.Runtime = runtime')
local environment_anchor =
    'local progression_controller = BaseProgressionController.new({'
replace_once(base, environment_anchor,
    'runtime.TestEnvironment = base_environment\n'
    .. environment_anchor)

-- The delay applies only to a test-selected UserId and recipe. It is
-- injected into the disposable place, never into versioned Base code.
local pause_anchor = 'runtime.TestEnvironment = base_environment\n'
replace_once(base, pause_anchor, pause_anchor .. [==[
local original_profession_prepare =
    runtime.ProfessionService.prepare_craft
runtime.ProfessionService.prepare_craft = function(self, user_id, recipe_id)
    local prepared = original_profession_prepare(self, user_id, recipe_id)
    if prepared.ok and recipe_id == "smelt_iron_bar"
        and user_id == workspace:GetAttribute("TEMP_PauseCraftUserId")
        and workspace:GetAttribute("TEMP_PauseCraftEnabled") == true
    then
        workspace:SetAttribute("TEMP_OldCraftPrepared", true)
        repeat
            task.wait(0.05)
        until workspace:GetAttribute("TEMP_ResumeOldCraft") == true
    end
    return prepared
end

]==])

local channel = Instance.new("RemoteEvent")
channel.Name = "TwoClientCraftDisconnectChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "TwoClientCraftDisconnectClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("TwoClientCraftDisconnectChannel_TEMP")
local remotes = RS.Core.Remotes
local crafting = remotes:WaitForChild("ProfessionCraftRequest")
local result = remotes:WaitForChild("ProfessionActionResult")

result.OnClientEvent:Connect(function(payload)
    if type(payload) ~= "table" then return end
    if payload.action == "Craft" or payload.action == "Gather" then
        channel:FireServer("Result", payload)
    end
end)

-- Args: None.
-- Returns: nil; holds the replicated corpse prompt as a real client.
local function skin()
    local wolf = workspace:WaitForChild("TwoClientWolf_TEMP", 14)
    local prompt = wolf:WaitForChild("HumanoidRootPart")
        :WaitForChild("BeastSkinningPrompt", 14)
    assert(prompt and prompt.Enabled,
        "client received no enabled contested corpse prompt")
    local camera = workspace.CurrentCamera
    if camera then
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = CFrame.lookAt(
            prompt.Parent.Position + Vector3.new(0, 3, 8),
            prompt.Parent.Position)
    end
    task.wait(0.5)
    prompt:InputHoldBegin()
    task.wait(0.8)
    prompt:InputHoldEnd()
    channel:FireServer("SkinFinished")
end

channel.OnClientEvent:Connect(function(action)
    if action == "Craft" then
        crafting:FireServer("smelt_iron_bar")
    elseif action == "Skin" then
        skin()
    elseif action == "Leave" then
        game:GetService("StudioTestService"):LeaveTest()
    end
end)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local server = Instance.new("Script")
server.Name = "TwoClientCraftDisconnectDriver_TEMP"
server.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local STS = game:GetService("StudioTestService")
local Tags = game:GetService("CollectionService")
local Inventory = require(game:GetService("ServerScriptService")
    .Core.Services.InventoryService)
local channel = RS:WaitForChild("TwoClientCraftDisconnectChannel_TEMP")

local ready = {}
local results = {}
local skin_finished = {}
local departures = {}
Players.PlayerRemoving:Connect(function(player)
    departures[player.UserId] = true
end)
channel.OnServerEvent:Connect(function(player, action, payload)
    if action == "Ready" then
        ready[player.UserId] = true
    elseif action == "Result" then
        local entries = results[player.UserId] or {}
        table.insert(entries, payload)
        results[player.UserId] = entries
    elseif action == "SkinFinished" then
        skin_finished[player.UserId] = true
    end
end)

-- Args:
--   condition: () -> any; condition to await.
--   label: string; name of the required outcome.
--   seconds: number; maximum wall-clock wait.
-- Returns:
--   any: first truthy result, or raises a diagnostic timeout.
local function wait_for(condition, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = condition()
        if value then return value end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Two Client Professions] TIMEOUT " .. label)
end

-- Args:
--   player: Player; actual Studio client.
--   location: CFrame; server-owned station/corpse proximity.
-- Returns:
--   nil: positions the client after the normal Base spawn completes.
local function position(player, location)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = assert(character:WaitForChild("HumanoidRootPart", 20))
    root.Anchored = true
    root.CFrame = location * CFrame.new(0, 3, 4)
end

-- Args:
--   profile_service: any; real in-memory Base profile authority.
--   user_id: number; Studio player account identifier.
-- Returns:
--   any: the loaded profile character.
local function character_of(profile_service, user_id)
    return assert(profile_service:get_character(user_id, 1),
        "Client profile missing")
end

-- Args:
--   player: Player; independently loaded Studio account.
--   runtime: any; actual Base service composition.
-- Returns:
--   number: initial iron-bar count used to verify single crafting.
local function seed_single_craft(player, runtime)
    local current = character_of(runtime.ProfileService, player.UserId)
    local existing = Inventory.count_item(current, "iron_ore")
    if existing > 0 then
        assert(runtime.InventoryService:consume_item(
            player.UserId, "iron_ore", existing).ok)
    end
    assert(runtime.InventoryService:add_item(
        player.UserId, "iron_ore", 2).ok)
    return Inventory.count_item(current, "iron_bar")
end

-- Args:
--   players: {Player}; both independently spawned Studio clients.
--   runtime: any; authoritative Base services.
-- Returns:
--   nil: proves per-player craft results and ingredients remain isolated.
local function verify_crafting(players, runtime)
    local station = assert(runtime.TestEnvironment:get(
        "Base.Profession.BlacksmithingPlaceholder"))
    local bars_before = {}
    for _, player in ipairs(players) do
        bars_before[player.UserId] = seed_single_craft(player, runtime)
        position(player, station.CFrame)
        results[player.UserId] = {}
    end
    task.wait(0.25)
    for _, player in ipairs(players) do
        channel:FireClient(player, "Craft")
    end
    for _, player in ipairs(players) do
        local crafted = wait_for(function()
            return results[player.UserId][1]
        end, "client craft result " .. player.UserId, 14)
        assert(crafted.ok and crafted.item_id == "iron_bar",
            "one client's craft was blocked by the other player")
        local current = character_of(runtime.ProfileService,
            player.UserId)
        assert(Inventory.count_item(current, "iron_bar")
            == bars_before[player.UserId] + 1
            and Inventory.count_item(current, "iron_ore") == 0,
            "one client's crafting leaked into the other account")
    end
    print("[Two Client Professions] INDEPENDENT_CRAFT_PASS")
end

-- Args:
--   location: Vector3; safe server-owned corpse location.
-- Returns:
--   Model: an explicit test-only registered, dead and looted wolf.
local function create_wolf(location)
    local wolf = Instance.new("Model")
    wolf.Name = "TwoClientWolf_TEMP"
    wolf:SetAttribute("CreatureSpeciesId", "forest_wolf")
    wolf:SetAttribute("CreatureFamily", "Beast")
    wolf:SetAttribute("SkinningClaimed", false)
    wolf:SetAttribute("LootComplete", false)
    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Anchored = true
    root.CanCollide = false
    root.Position = location
    root.Parent = wolf
    wolf.PrimaryPart = root
    local humanoid = Instance.new("Humanoid")
    humanoid.Parent = wolf
    wolf.Parent = workspace
    Tags:AddTag(wolf, "DungeonMMOSkinnableBeast")
    humanoid.Health = 0
    wolf:SetAttribute("LootComplete", true)
    return wolf
end

-- Args:
--   players: {Player}; two real Studio clients contest one corpse.
--   runtime: any; real server inventory and profile services.
-- Returns:
--   nil: verifies exactly one successful server hide grant.
local function verify_skinning(players, runtime)
    local before = {}
    for _, player in ipairs(players) do
        before[player.UserId] = Inventory.count_item(
            character_of(runtime.ProfileService, player.UserId),
            "raw_hide")
    end
    local station = assert(runtime.TestEnvironment:get(
        "Base.Profession.BlacksmithingPlaceholder"))
    local wolf = create_wolf(station.Position + Vector3.new(0, 1, 12))
    wait_for(function()
        return wolf.HumanoidRootPart:FindFirstChild(
            "BeastSkinningPrompt")
    end, "authoritative shared corpse prompt", 12)
    for _, player in ipairs(players) do
        position(player, wolf.HumanoidRootPart.CFrame)
    end
    task.wait(0.4)
    for _, player in ipairs(players) do
        results[player.UserId] = {}
        channel:FireClient(player, "Skin")
    end
    for _, player in ipairs(players) do
        wait_for(function()
            return skin_finished[player.UserId]
        end, "client completed skin input " .. player.UserId, 15)
    end
    local hide_delta = 0
    local successful_requests = 0
    for _, player in ipairs(players) do
        local current = character_of(runtime.ProfileService,
            player.UserId)
        hide_delta += Inventory.count_item(current, "raw_hide")
            - before[player.UserId]
        for _, event in ipairs(results[player.UserId]) do
            if event.ok == true and event.action == "Gather" then
                successful_requests += 1
            end
        end
    end
    assert(hide_delta == 1 and successful_requests == 1
        and wolf:GetAttribute("SkinningClaimed") == true,
        "contested real-client corpse must grant exactly one hide")
    print("[Two Client Professions] CONTESTED_CORPSE_PASS")
    wolf:Destroy()
end

-- Args:
--   players: {Player}; two actual clients with independent Base profiles.
--   runtime: any; the real server profession and profile composition.
-- Returns:
--   nil: tests a mid-request disconnect, reload, and stale-request veto.
local function verify_interrupted_disconnect(players, runtime)
    local leaving = players[1]
    local staying = players[2]
    local bars_before = seed_single_craft(leaving, runtime)
    local station = assert(runtime.TestEnvironment:get(
        "Base.Profession.BlacksmithingPlaceholder"))
    position(leaving, station.CFrame)
    workspace:SetAttribute("TEMP_PauseCraftUserId", leaving.UserId)
    workspace:SetAttribute("TEMP_PauseCraftEnabled", true)
    workspace:SetAttribute("TEMP_ResumeOldCraft", false)
    workspace:SetAttribute("TEMP_OldCraftPrepared", false)

    channel:FireClient(leaving, "Craft")
    wait_for(function()
        return workspace:GetAttribute("TEMP_OldCraftPrepared") == true
    end, "old client craft preparation paused", 15)
    channel:FireClient(leaving, "Leave")
    wait_for(function()
        return departures[leaving.UserId]
    end, "crafting player's real network departure", 20)
    wait_for(function()
        return runtime.ProfileService:get_character(leaving.UserId, 1)
            == nil
    end, "disconnected player profile released", 20)

    -- Reload the SAME UserId from its saved in-memory Studio adapter,
    -- even though Studio cannot join that same account as a new client.
    local reloaded = runtime.ProfileService:load(leaving.UserId)
    assert(reloaded, "same UserId failed to reload its saved profile")
    local before = character_of(runtime.ProfileService, leaving.UserId)
    assert(Inventory.count_item(before, "iron_ore") == 2
        and Inventory.count_item(before, "iron_bar") == bars_before,
        "interrupted request changed materials before reload")

    workspace:SetAttribute("TEMP_ResumeOldCraft", true)
    task.wait(0.6)
    local after = character_of(runtime.ProfileService, leaving.UserId)
    assert(Inventory.count_item(after, "iron_ore") == 2
        and Inventory.count_item(after, "iron_bar") == bars_before,
        "stale disconnected craft mutated the reloaded same-UserId profile")
    assert(Players:GetPlayerByUserId(staying.UserId) == staying,
        "other client was disconnected by peer's interrupted craft")

    -- Test service may admit a replacement account, not the same account.
    STS:AddPlayers(1)
    local replacement = wait_for(function()
        for _, candidate in ipairs(Players:GetPlayers()) do
            if candidate.UserId ~= leaving.UserId
                and candidate.UserId ~= staying.UserId
            then
                return candidate
            end
        end
    end, "replacement client admitted", 25)
    assert(replacement.UserId ~= leaving.UserId,
        "Studio replacement is not a same-account network reconnect")
    print("[Two Client Professions] INTERRUPTED_DISCONNECT_PASS")
    print("[Two Client Professions] SAME_ACCOUNT_NETWORK_RECONNECT_NOT_TESTED")
end

-- Args: None.
-- Returns: nil; tests actual concurrent clients and departure safety.
local function run()
    local players = wait_for(function()
        local current = Players:GetPlayers()
        return if #current == 2 then current else nil
    end, "two real Studio clients", 35)
    local runtime = wait_for(function()
        local probe = game:GetService("ServerScriptService")
            :FindFirstChild("TwoClientProfessionRuntimeProbe_TEMP")
        if probe then
            return require(probe).Runtime
        end
        return nil
    end, "Base runtime", 25)
    for _, player in ipairs(players) do
        wait_for(function()
            return ready[player.UserId]
                and runtime.ProfileService:get_character(player.UserId, 1)
                and player.Character
                and player.Character:FindFirstChild("HumanoidRootPart")
        end, "client ready/profile/bootstrap", 30)
    end
    task.wait(7)
    verify_crafting(players, runtime)
    verify_skinning(players, runtime)

    verify_interrupted_disconnect(players, runtime)
    print("[Two Client Professions] PEER_DISCONNECT_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Two Client Professions] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(135, function()
    STS:EndTest("FAIL fixture global timeout")
end)
]==]
server.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        2, "TwoClientCraftDisconnect_TEMP")
end)
server:Destroy()
client:Destroy()
channel:Destroy()
runtime_probe:Destroy()
assert(ok and result == "PASS",
    "Two-client profession test failed: " .. tostring(result))
print("[Two Client Professions] VERIFIED_MULTIPLAYER_PASS")
