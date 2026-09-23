--!strict
-- Real two-client unpublished Base playtest of v1.79/v1.80 careers.
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
        craft:FireServer("smelt_iron_bar")
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
Tests the actual two-client UI, remote selection and station authority.

Args:
    None.

Returns:
    nil: Verifies different careers, forged craft denial and traded goods.
]]
local function main()
    local players = wait_for(function()
        local current = Players:GetPlayers()
        return if #current == 2 then current else nil
    end, "two actual Studio clients", 50)
    local runtime = wait_for(function()
        return _G.C4ProfessionLiveServices_TEMP
    end, "Base service composition", 40)
    for _, player in ipairs(players) do
        wait_for(function()
            return runtime.ProfileService:get_character(player.UserId, 1)
                and ui_ready[player.UserId] ~= nil
                and player.Character
                and player.Character:FindFirstChild("HumanoidRootPart")
        end, "real profile and profession UI", 45)
        assert(ui_ready[player.UserId] == true,
            "Client did not visibly open its profession selection panel")
    end
    print("[C4 Profession Playtest] TWO_CLIENT_UI_OPEN_PASS")

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
                "Client profession choice rejected: "
                    .. tostring(failures[player.UserId]))
            return choices[player.UserId]
        end, "two genuine client profession choices", 35)
        assert(choice.PanelClosed,
            "Profession panel did not close after both selections")
    end
    assert(choices[smith.UserId].Creation == "Blacksmithing"
        and choices[alchemist.UserId].Creation == "Alchemy",
        "Client selections did not remain independent")
    print("[C4 Profession Playtest] TWO_CLIENT_UI_SELECTION_PASS")

    local station = assert(runtime.LiveEnvironment:get(
        "Base.Profession.BlacksmithingPlaceholder"))
    for _, player in ipairs(players) do
        move_to_station(player, station.CFrame)
        assert(runtime.InventoryService:add_item(
            player.UserId, "iron_ore", 2).ok,
            "Test-only ingredient grant failed")
        assert(runtime.ProfileService:mutate(player.UserId,
            function(profile)
                profile.Characters.Slot1.Gold = 500
            end), "Isolated market buyer gold failed")
    end
    task.wait(0.4)
    channel:FireClient(smith, "Craft")
    channel:FireClient(alchemist, "Craft")
    for _, player in ipairs(players) do
        wait_for(function()
            return outcomes[player.UserId]
        end, "real client station craft result", 25)
    end
    assert(outcomes[smith.UserId].ok == true
        and outcomes[smith.UserId].item_id == "iron_bar",
        "Smith did not craft through the real client remote")
    assert(outcomes[alchemist.UserId].ok == false
        and outcomes[alchemist.UserId].reason
            == "ProfessionNotSelected",
        "Alchemist forged a second crafting career")
    local smith_character = assert(runtime.ProfileService:get_character(
        smith.UserId, 1))
    local alchemist_character = assert(runtime.ProfileService:get_character(
        alchemist.UserId, 1))
    assert(Inventory.count_item(smith_character, "iron_bar") == 1
        and Inventory.count_item(alchemist_character, "iron_bar") == 0,
        "One client's crafting leaked to the second character")
    print("[C4 Profession Playtest] REAL_CLIENT_CRAFT_AND_DENIAL_PASS")

    local listing = runtime.MarketService:create_listing(
        smith.UserId, "iron_bar", 1, 100,
        "c4-live-smith-bar-list"
    )
    assert(listing.ok, "Smith market escrow could not list its bar")
    local bought = runtime.MarketService:buy(
        alchemist.UserId, listing.listing.ListingId,
        "c4-live-alchemist-bar-buy"
    )
    assert(bought.ok, "Alchemist could not buy real smith-made bar")
    alchemist_character = assert(runtime.ProfileService:get_character(
        alchemist.UserId, 1))
    assert(Inventory.count_item(alchemist_character, "iron_bar") == 1,
        "Cross-profession marketplace delivery did not reach the buyer")
    print("[C4 Profession Playtest] REAL_CLIENT_MARKET_DELIVERY_PASS")
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
        2, "C4ExclusiveProfessions_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Two-client profession playtest failed: " .. tostring(result))
print("[C4 Profession Playtest] VERIFIED_TWO_CLIENT_PLAY_PASS")
