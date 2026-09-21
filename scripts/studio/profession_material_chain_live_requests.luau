--!strict
-- Disposable local Studio-only material-backed cross-profession Play test.
-- Only the in-memory Base runtime on this TEMP place is instrumented.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Run profession fixture only on unpublished local Base build")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

assert(SSS:FindFirstChild("Base")
    and not SSS:FindFirstChild("Dungeon"),
    "Profession fixture requires the Base composition")

local runtime_source = SSS.Base.BaseRuntime
local original = 'local runtime = RuntimeServices.new("Base")'
local source = runtime_source.Source
local position = assert(string.find(source, original, 1, true),
    "Base runtime composition anchor not found")
assert(not string.find(source, original, position + #original, true),
    "Base runtime composition anchor must be unique")
runtime_source.Source = string.sub(source, 1, position - 1)
    .. original .. "\n_G.TempProfessionLiveRuntime = runtime"
    .. string.sub(source, position + #original)

-- Expose the same already-validated Base environment used by the
-- original station runtime, only in this disposable Studio fixture.
local environment_anchor =
    'local progression_controller = BaseProgressionController.new({'
local environment_source = runtime_source.Source
local environment_position = assert(string.find(
    environment_source, environment_anchor, 1, true),
    "Base environment instrumentation anchor not found")
assert(not string.find(environment_source, environment_anchor,
    environment_position + #environment_anchor, true),
    "Base environment instrumentation anchor is ambiguous")
runtime_source.Source = string.sub(
    environment_source, 1, environment_position - 1)
    .. '_G.TempProfessionLiveRuntime.TestEnvironment = '
    .. 'base_environment\\n'
    .. string.sub(environment_source, environment_position)

local channel = Instance.new("RemoteEvent")
channel.Name = "ProfessionMaterialLiveChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "ProfessionMaterialLiveClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("ProfessionMaterialLiveChannel_TEMP")
local remotes = RS.Core.Remotes
local craft = remotes:WaitForChild("ProfessionCraftRequest")
local result = remotes:WaitForChild("ProfessionActionResult")

result.OnClientEvent:Connect(function(payload)
    if type(payload) == "table" and payload.action == "Craft" then
        channel:FireServer("CraftResult", payload)
    end
end)

channel.OnClientEvent:Connect(function(command, recipe_id)
    if command == "Craft" then
        -- Extra client-provided 'success' must never be trusted.
        craft:FireServer(recipe_id, {
            MinigameId = "ForgedClientSuccess", Succeeded = true,
        })
    end
end)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local server = Instance.new("Script")
server.Name = "ProfessionMaterialLiveDriver_TEMP"
server.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local STS = game:GetService("StudioTestService")
local channel = RS:WaitForChild("ProfessionMaterialLiveChannel_TEMP")
local Inventory = require(game:GetService("ServerScriptService")
    .Core.Services.InventoryService)

local ready_user_id = nil
local results = {}

channel.OnServerEvent:Connect(function(player, action, payload)
    if action == "Ready" then
        ready_user_id = player.UserId
    elseif action == "CraftResult"
        and player.UserId == ready_user_id then
        table.insert(results, payload)
    end
end)

-- Args:
--   predicate: () -> any; condition that returns a truthy value.
--   description: string; describes the missing outcome.
--   seconds: number; timeout in seconds.
-- Returns:
--   any: the first truthy result before the deadline.
local function wait_for(predicate, description, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Profession Material Live] TIMEOUT " .. description)
end

-- Args:
--   player: Player; the actual Studio client.
--   anchor: BasePart; authoritative station part.
-- Returns:
--   nil: moves the server player inside the station range.
local function position_at(player, anchor)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart", 20)
    assert(root, "Player root missing")
    root.Anchored = true
    root.CFrame = anchor.CFrame * CFrame.new(0, 3, 4)
    task.wait(0.2)
end

-- Args:
--   player: Player; the actual Studio client.
--   recipe_id: string; the server-catalogued recipe to craft.
--   runtime: any; authoritative Base service composition.
-- Returns:
--   any: successful server result from the real client RemoteEvent.
local function craft(player, recipe_id, runtime)
    local recipe = require(RS.Core.Shared.ProfessionRecipes).get(
        recipe_id)
    local stations = workspace:WaitForChild("ProfessionRuntime")
    local station = if recipe.StationId == "Leatherworking"
        then stations:WaitForChild("LeatherworkingStationPlaceholder")
        elseif recipe.StationId == "Enchanting"
        then stations:WaitForChild("EnchantingStationPlaceholder")
        else runtime.TestEnvironment:get(
            "Base.Profession." .. recipe.StationId .. "Placeholder")
    assert(station and station:IsA("BasePart"),
        "No server station for " .. recipe_id)
    position_at(player, station)
    table.clear(results)
    channel:FireClient(player, "Craft", recipe_id)
    local result = wait_for(function()
        return table.remove(results, 1)
    end, recipe_id, 12)
    assert(result.ok and result.item_id == recipe.Output.ItemId
        and result.quantity == recipe.Output.Quantity,
        "real craft rejected " .. recipe_id .. ": "
            .. tostring(result.reason))
    print("[Profession Material Live] CRAFT_PASS " .. recipe_id)
    return result
end

-- Args: None.
-- Returns: nil; checks actual material-backed client and server crafting.
local function run()
    local player = wait_for(function()
        return Players:GetPlayers()[1]
    end, "test player", 30)
    wait_for(function()
        return ready_user_id == player.UserId
    end, "client ready", 30)
    local runtime = wait_for(function()
        return _G.TempProfessionLiveRuntime
    end, "Base service composition", 30)
    local profile = wait_for(function()
        return runtime.ProfileService:get_character(player.UserId, 1)
    end, "loaded in-memory Base profile", 30)
    assert(profile and runtime.ProfessionService,
        "Base profile and profession service required")

    -- The test seeds *only* a local in-memory account. Real crafting
    -- below goes through the original client RemoteEvent and services.
    local seeding = {
        {item_id = "iron_ore", quantity = 8},
        {item_id = "silverleaf", quantity = 9},
        {item_id = "raw_hide", quantity = 3},
    }
    for _, item in ipairs(seeding) do
        local granted = runtime.InventoryService:add_item(
            player.UserId, item.item_id, item.quantity)
        assert(granted.ok, "Failed to seed " .. item.item_id)
    end

    for _ = 1, 4 do
        craft(player, "smelt_iron_bar", runtime)
    end
    for _, recipe_id in ipairs({
        "distill_tempering_oil",
        "cure_raw_hide",
        "stitch_leatherbound_gloves",
        "distill_forging_flux",
        "distill_warding_essence",
        "inscribe_warding_rune",
        "distill_forging_flux",
        "enchant_leatherbound_gloves",
    }) do
        craft(player, recipe_id, runtime)
    end

    local updated = assert(runtime.ProfileService:get_character(
        player.UserId, 1))
    assert(Inventory.count_item(
        updated, "warded_leatherbound_gloves") == 1,
        "real client crafting must produce exactly one enchanted item")
    assert(Inventory.count_item(updated, "raw_hide") == 0
        and Inventory.count_item(updated, "leatherbound_gloves") == 0
        and Inventory.count_item(updated, "warding_rune") == 0,
        "real client crafting must consume required intermediate inputs")

    -- A forged additional argument cannot produce another output
    -- without inputs; the server returns a normal material rejection.
    local enchant_station = workspace.ProfessionRuntime
        :WaitForChild("EnchantingStationPlaceholder")
    position_at(player, enchant_station)
    table.clear(results)
    channel:FireClient(player, "Craft", "enchant_leatherbound_gloves")
    local duplicate = wait_for(function()
        return table.remove(results, 1)
    end, "repeat enchant rejection", 12)
    assert(duplicate.ok == false
        and duplicate.reason == "MissingMaterials",
        "crafted output must not duplicate on repeated client requests")
    print("[Profession Material Live] DUPLICATE_DENIED_PASS")

    local saved = runtime.ProfileService:save(
        player.UserId, "ProfessionMaterialLiveFixture")
    assert(saved, "actual in-memory Base profile must save")
    print("[Profession Material Live] MATERIAL_CHAIN_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Profession Material Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
]==]
server.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("ProfessionMaterialLiveFixture_TEMP")
end)
server:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Profession material Play test failed: " .. tostring(result))
print("[Profession Material Live] VERIFIED_PLAY_MODE_PASS")
