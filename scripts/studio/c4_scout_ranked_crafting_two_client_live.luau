--!strict
-- Real two-client unpublished Base playtest for three Scout crafting ranks.
-- Only a disposable local Studio DataModel is temporarily instrumented.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Two-client profession playtest requires an unpublished local Base.")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
assert(SSS:FindFirstChild("Base") and not SSS:FindFirstChild("Dungeon"),
    "Profession playtest requires the local Base composition.")

--[[
Instruments a disposable Base instance, never a checked-in source file.

Args:
    owner (LuaSourceContainer): Local BaseRuntime script instance.
    needle (string): Unique source anchor to instrument.
    replacement (string): Test-only source with a debug service handle.

Returns:
    nil: Raises if a source anchor changed or occurs more than once.
]]
local function replace_once(owner: any, needle: string, replacement: string)
    local source = owner.Source
    local first = assert(string.find(source, needle, 1, true),
        "Profession playtest Base anchor missing")
    assert(not string.find(source, needle, first + #needle, true),
        "Profession playtest Base anchor ambiguous")
    owner.Source = string.sub(source, 1, first - 1)
        .. replacement .. string.sub(source, first + #needle)
end

local base = SSS.Base.BaseRuntime
local services_anchor = 'local runtime = RuntimeServices.new("Base")'
replace_once(base, services_anchor, services_anchor
    .. '\n_G.C4ProfessionLiveServices_TEMP = runtime')
local environment_anchor =
    'local progression_controller = BaseProgressionController.new({'
replace_once(base, environment_anchor,
    '_G.C4ProfessionLiveServices_TEMP.LiveEnvironment = base_environment\n'
    .. environment_anchor)

local channel = Instance.new("RemoteEvent")
channel.Name = "C4ProfessionLiveChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "C4ProfessionLiveClient_TEMP"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local channel = RS:WaitForChild("C4ProfessionLiveChannel_TEMP")
local remotes = RS.Core:WaitForChild("Remotes")
local snapshot = remotes:WaitForChild("ProfessionSnapshot")
local results = remotes:WaitForChild("ProfessionActionResult")
local craft = remotes:WaitForChild("ProfessionCraftRequest")
local ui = player:WaitForChild("PlayerGui")
    :WaitForChild("ProfessionUi", 35)
assert(ui, "[C4 Client] Missing actual profession UI.")
local panel = assert(ui:FindFirstChildOfClass("Frame"))
local initial = false
local selected = 0
local wanted = nil
local choice_complete = false

results.OnClientEvent:Connect(function(payload)
    if type(payload) ~= "table" then
        return
    end
    if payload.action == "Craft" then
        channel:FireServer("CraftResult", payload)
    elseif payload.action == "ChooseProfession" then
        if payload.ok ~= true then
            channel:FireServer("ChoiceFailed", payload.reason)
            return
        end
        selected += 1
        if selected == 1 then
            snapshot:FireServer({
                Action = "ChooseProfession",
                ProfessionId = wanted.Creation,
            })
        end
    end
end)

snapshot.OnClientEvent:Connect(function(payload)
    if type(payload) ~= "table" or payload.ok ~= true then
        return
    end
    local slots = payload.ProfessionSlots or {}
    if not initial and slots.Gathering == "" and slots.Creation == "" then
        initial = true
        task.delay(0.3, function()
            channel:FireServer("UIReady", panel.Visible)
        end)
    end
    if selected == 2 and not choice_complete
        and wanted and slots.Gathering == wanted.Gathering
        and slots.Creation == wanted.Creation then
        choice_complete = true
        task.delay(0.3, function()
            channel:FireServer("ChoiceComplete", {
                Gathering = slots.Gathering,
                Creation = slots.Creation,
                PanelClosed = not panel.Visible,
            })
        end)
    end
end)

channel.OnClientEvent:Connect(function(action, payload)
    if action == "Select" then
        wanted = payload
        snapshot:FireServer({
            Action = "ChooseProfession",
            ProfessionId = wanted.Gathering,
        })
    elseif action == "Craft" then
        craft:FireServer(payload)
    end
end)
snapshot:FireServer("Request")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "C4ProfessionLiveDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Inventory = require(SSS.Core.Services.InventoryService)
local channel = RS:WaitForChild("C4ProfessionLiveChannel_TEMP")

local ui_ready = {}
local choices = {}
local outcomes = {}
local failures = {}

channel.OnServerEvent:Connect(function(player, action, payload)
    if action == "UIReady" then
        ui_ready[player.UserId] = payload
    elseif action == "ChoiceComplete" then
        choices[player.UserId] = payload
    elseif action == "CraftResult" then
        outcomes[player.UserId] = payload
    elseif action == "ChoiceFailed" then
        failures[player.UserId] = payload
    end
end)

--[[
Waits a bounded time for genuine client readiness or remote outcomes.

Args:
    predicate (() -> any): Condition checked in actual Studio play mode.
    label (string): Stage for an actionable timeout error.
    seconds (number): Maximum permitted wall-clock seconds.

Returns:
    any: First truthy condition result.
]]
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then return value end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[C4 Profession Playtest] TIMEOUT " .. label)
end

--[[
Puts a real client beside the existing Blacksmithing station.

Args:
    player (Player): Connected player with its actual spawned character.
    position (CFrame): Valid authoritative station anchor position.

Returns:
    nil: Positions the client within the server's crafting range.
]]
local function move_to_station(player, position)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = assert(character:WaitForChild("HumanoidRootPart", 20))
    root.Anchored = true
    root.CFrame = position * CFrame.new(0, 3, 4)
end

--[[
Prepares one actual client with a purchased rank-one Scout crafting career.

Args:
    runtime (any): Real Base profile, profession and skill services.
    player (Player): Connected client with its one selected career.
    race_id (string): Original C4 Human or Elf race.
    class_id (string): Rogue or Ranger class trainer.

Returns:
    nil: Gives the test character real skills, XP budget and material.
]]
local function prepare_client(runtime, player, race_id, class_id)
    assert(runtime.ProfileService:mutate(player.UserId,
        function(profile)
            local character = profile.Characters.Slot1
            character.Identity = {
                Version = 1, RaceId = race_id,
                BaseClassId = class_id, ClassId = class_id,
                CreationStage = "Complete",
            }
            character.Level = 20
            character.Gold = 1500
            character.Progression.SkillPointEntitlement = 250
        end), "Authenticated source class setup failed")
    assert(runtime.SkillProgressionService:learn_trainer_skill(
        player.UserId, "C4RecipeReading"
    ).ok, "Real client could not train Recipe Reading")
    assert(runtime.SkillProgressionService:learn_trainer_skill(
        player.UserId, "ScoutCommonItemCreation"
    ).ok, "Real client could not train purchased source rank one")
end

--[[
Requests one real client station craft and waits for its genuine reply.

Args:
    player (Player): Actual connected Studio client.
    recipe_id (string): Authored currently requested recipe.

Returns:
    any: Real client result returned from the standard server action.
]]
local function client_craft(player, recipe_id)
    outcomes[player.UserId] = nil
    channel:FireClient(player, "Craft", recipe_id)
    return wait_for(function()
        return outcomes[player.UserId]
    end, "real client craft " .. recipe_id, 25)
end

--[[
Verifies genuine two-client selection and first-transfer skill purchase.

Args:
    runtime (any): Actual Base profile and profession authorities.

Returns:
    Player: Authenticated Rogue smith with its one crafting profession.
    Player: Authenticated Elf Ranger Alchemist with its other career.
]]
local function select_players(runtime)
    local players = wait_for(function()
        local current = Players:GetPlayers()
        return if #current == 2 then current else nil
    end, "two actual Studio clients", 50)
    for _, player in ipairs(players) do
        wait_for(function()
            return runtime.ProfileService:get_character(player.UserId, 1)
                and ui_ready[player.UserId] ~= nil
                and player.Character
                and player.Character:FindFirstChild("HumanoidRootPart")
        end, "real profile and profession UI", 45)
        assert(ui_ready[player.UserId] == true,
            "Real profession selection panel was not visible")
    end
    local smith = players[1]
    local alchemist = players[2]
    channel:FireClient(smith, "Select", {
        Gathering = "Mining", Creation = "Blacksmithing",
    })
    channel:FireClient(alchemist, "Select", {
        Gathering = "Herbalism", Creation = "Alchemy",
    })
    for _, player in ipairs(players) do
        local choice = wait_for(function()
            assert(failures[player.UserId] == nil,
                "Client profession choice rejected")
            return choices[player.UserId]
        end, "two genuine client profession choices", 35)
        assert(choice.PanelClosed, "Client profession panel never closed")
    end
    prepare_client(runtime, smith, "Human", "Rogue")
    prepare_client(runtime, alchemist, "Elf", "Ranger")
    print("[C4 Scout Craft Live] TWO_CLIENT_SELECTION_AND_RANK_ONE_PASS")
    return smith, alchemist
end

--[[
Makes an authentic smith craft, then rejects an alchemist smith request.

Args:
    runtime (any): Actual Base station and authoritative inventory.
    smith (Player): Rank-one Human Rogue/Blacksmith.
    alchemist (Player): Rank-one Elf Ranger/Alchemist.

Returns:
    nil: Confirms no client can bypass its one selected creation slot.
]]
local function craft_and_deny(runtime, smith, alchemist)
    local station = assert(runtime.LiveEnvironment:get(
        "Base.Profession.BlacksmithingPlaceholder"))
    for _, player in {smith, alchemist} do
        move_to_station(player, station.CFrame)
    end
    assert(runtime.InventoryService:add_item(
        smith.UserId, "iron_ore", 2
    ).ok, "Real smith ore grant failed")
    task.wait(0.4)
    local crafted = client_craft(smith, "scout_forge_bars_rank_1")
    assert(crafted.ok and crafted.item_id == "iron_bar",
        "Purchased source rank-one client craft failed")
    local denied = client_craft(
        alchemist, "scout_forge_bars_rank_1"
    )
    assert(not denied.ok and denied.reason == "ProfessionNotSelected",
        "Elf Alchemist forged the Rogue's selected Smithing goods")
    local character = assert(runtime.ProfileService:get_character(
        smith.UserId, 1
    ))
    assert(Inventory.count_item(character, "iron_bar") == 2,
        "Actual rank-one smith recipe did not produce two bars")
    print("[C4 Scout Craft Live] REAL_CLIENT_RANK_ONE_AND_DENIAL_PASS")
end

--[[
Buys the smith's actual material, then consumes it at rank two.

Args:
    runtime (any): Authentic market, profile, station and skills services.
    smith (Player): Character who manufactured the listed iron bar.
    alchemist (Player): Independent crafting career purchasing the bar.

Returns:
    nil: Verifies real client craft uses purchased other-profession goods.
]]
local function trade_and_upgrade(runtime, smith, alchemist)
    local listing = runtime.MarketService:create_listing(
        smith.UserId, "iron_bar", 1, 100,
        "c4-scout-live-smith-bar-list"
    )
    assert(listing.ok, "Actual smith escrow listing failed")
    assert(runtime.MarketService:buy(
        alchemist.UserId, listing.listing.ListingId,
        "c4-scout-live-alchemist-bar-buy"
    ).ok, "Another career could not buy the real smith-made bar")
    local before = assert(runtime.ProfileService:get_character(
        alchemist.UserId, 1
    ))
    assert(Inventory.count_item(before, "iron_bar") == 1,
        "Alchemist did not receive the marketplace's real iron bar")
    assert(not runtime.ProfessionService:prepare_craft(
        alchemist.UserId, "scout_distill_oil_rank_2"
    ).ok, "Rank-two craft bypassed its missing purchased source rank")
    assert(runtime.ProfileService:mutate(
        alchemist.UserId, function(profile)
            local character = profile.Characters.Slot1
            character.Level = 28
            character.Professions.Alchemy.XP = 30
        end
    ), "Disposable profession XP and level setup failed")
    assert(runtime.SkillProgressionService:purchase_rank(
        alchemist.UserId, "ScoutCommonItemCreation"
    ).ok, "Genuine Scout class rank-two training failed")
    assert(runtime.InventoryService:add_item(
        alchemist.UserId, "silverleaf", 2
    ).ok, "Rank-two Alchemy needs actual ingredient inventory")
    local station = assert(runtime.LiveEnvironment:get(
        "Base.Profession.AlchemyPlaceholder"))
    move_to_station(alchemist, station.CFrame)
    task.wait(0.4)
    local result = client_craft(
        alchemist, "scout_distill_oil_rank_2"
    )
    assert(result.ok and result.item_id == "tempering_oil",
        "Other career's client could not craft purchased-rank-two oil")
    local character = assert(runtime.ProfileService:get_character(
        alchemist.UserId, 1
    ))
    assert(Inventory.count_item(character, "iron_bar") == 0
        and Inventory.count_item(character, "tempering_oil") == 3,
        "Rank-two alchemy did not consume the genuinely traded iron bar")
    print("[C4 Scout Craft Live] REAL_MARKET_TO_CLIENT_RANK_TWO_PASS")
end

--[[
Runs real two-client station crafts without modifying the original place.

Args:
    None.

Returns:
    nil: Confirms independent careers, paid rank progression and trade.
]]
local function main()
    local runtime = wait_for(function()
        return _G.C4ProfessionLiveServices_TEMP
    end, "real Base service composition", 40)
    local smith, alchemist = select_players(runtime)
    craft_and_deny(runtime, smith, alchemist)
    trade_and_upgrade(runtime, smith, alchemist)
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[C4 Profession Playtest] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(170, function()
    STS:EndTest("FAIL global fixture timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        2, "C4ScoutRankedCraftTwoClients_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Two-client profession playtest failed: " .. tostring(result))
print("[C4 Scout Craft Live] VERIFIED_TWO_CLIENT_RANKED_TRADE_PASS")
