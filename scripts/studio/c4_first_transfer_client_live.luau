--!strict
-- Genuine unpublished Base client-to-server original C4 class choice test.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Class choice live test requires an unpublished local Base place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local base = SSS.Base.BaseRuntime
local anchor = 'local runtime = RuntimeServices.new("Base")'
local first = assert(string.find(base.Source, anchor, 1, true),
    "Base runtime instrumentation anchor missing")
assert(not string.find(base.Source, anchor, first + #anchor, true),
    "Base runtime instrumentation anchor duplicated")
base.Source = base.Source:sub(1, first - 1)
    .. anchor .. '\n_G.C4FirstTransferClientRuntime_TEMP = runtime'
    .. base.Source:sub(first + #anchor)

local channel = Instance.new("RemoteEvent")
channel.Name = "C4FirstTransferClientChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "C4FirstTransferActualClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local player = game:GetService("Players").LocalPlayer
local remotes = RS.Core:WaitForChild("Remotes")
local choice = remotes:WaitForChild("ClassAdvancementRequest")
local snapshot = remotes:WaitForChild("ClassAdvancementSnapshot")
local result = remotes:WaitForChild("ClassAdvancementResult")
local channel = RS:WaitForChild("C4FirstTransferClientChannel_TEMP")
local gui = player:WaitForChild("PlayerGui")
    :WaitForChild("C4FirstTransferChoiceUi", 40)
assert(gui, "Real C4 class-choice GUI was not created")
local panel = assert(gui:WaitForChild("ClassPathPanel"))
local options = assert(panel:WaitForChild("SourceClassOptions"))
local latest = nil
local selected = false

--[[
Inspects actual class-choice GUI after its own snapshot render.

Args:
    state (any): Real server-authored original C4 choice snapshot.

Returns:
    nil: Reports the rendered options and active panel to the game driver.
]]
local function report(state)
    task.wait(0.25)
    local names = {}
    for _, button in ipairs(options:GetChildren()) do
        if button:IsA("TextButton") then
            table.insert(names, button.Name)
        end
    end
    channel:FireServer("UiState", {
        CanChoose = state.CanChoose,
        SelectedClassId = state.SelectedClassId,
        PanelVisible = panel.Visible,
        ToggleVisible = gui.ClassPathButton.Visible,
        Options = names,
        StatusText = panel.ClassPathStatus.Text,
    })
end

snapshot.OnClientEvent:Connect(function(payload)
    local state = payload and payload.OriginalFirstTransfer
    if state and state.ok then
        latest = state
        task.spawn(report, state)
    end
end)
result.OnClientEvent:Connect(function(payload)
    if selected then
        channel:FireServer("SelectResult", payload)
    end
end)
channel.OnClientEvent:Connect(function(action)
    if action == "Refresh" then
        choice:FireServer("Snapshot")
    elseif action == "ChooseHumanRogue" then
        assert(latest and latest.CanChoose,
            "Client cannot select an ineligible original C4 path")
        selected = true
        choice:FireServer("SelectFirstTransfer", "HumanRogue")
    elseif action == "TryWrongRace" then
        selected = true
        choice:FireServer("SelectFirstTransfer", "ElvenScout")
    end
end)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "C4FirstTransferActualDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local STS = game:GetService("StudioTestService")
local channel = RS:WaitForChild("C4FirstTransferClientChannel_TEMP")
local ready = {}
local ui = {}
local outcomes = {}
channel.OnServerEvent:Connect(function(player, action, value)
    if action == "Ready" then
        ready[player.UserId] = true
    elseif action == "UiState" then
        ui[player.UserId] = value
    elseif action == "SelectResult" then
        outcomes[player.UserId] = value
    end
end)

--[[
Waits for a genuinely connected client and its authoritative server state.

Args:
    predicate (() -> any): Real Studio runtime readiness/response.
    label (string): Test stage for failure diagnostics.
    seconds (number): Maximum waiting time.

Returns:
    any: First truthy authoritative state.
]]
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then return value end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[C4 First Transfer Live] TIMEOUT " .. label)
end

--[[
Prepares a disposable real original Human Fighter profile at quest level.

Args:
    runtime (any): Actual Base profile writer and existing game services.
    player (Player): Genuine local Studio client.

Returns:
    nil: Saves race, starter identity and level but no free advanced class.
]]
local function prepare(runtime, player)
    assert(runtime.ProfileService:mutate(player.UserId, function(profile)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1, RaceId = "Human",
            BaseClassId = "Fighter", ClassId = "Fighter",
            CreationStage = "Complete",
        }
        character.Level = 18
        character.Gold = 249
    end), "Original Human Fighter test profile did not persist")
end

--[[
Verifies the actual GUI, forged cross-race denial and saved valid branch.

Args:
    runtime (any): Original live Base profile and selection authorities.
    player (Player): Actual connected local player/client.

Returns:
    nil: Proves real client remote submission and UI persistent snapshot.
]]
local function main()
    local player = wait_for(function()
        local current = Players:GetPlayers()
        return if #current == 1 then current[1] else nil
    end, "one real Studio client", 40)
    local runtime = wait_for(function()
        return _G.C4FirstTransferClientRuntime_TEMP
    end, "real Base runtime", 40)
    wait_for(function()
        return runtime.ProfileService:get_character(player.UserId, 1)
            and ready[player.UserId]
    end, "authenticated original profile and client UI", 55)
    prepare(runtime, player)
    ui[player.UserId] = nil
    channel:FireClient(player, "Refresh")
    local first_ui = wait_for(function()
        local state = ui[player.UserId]
        return if state and state.CanChoose then state else nil
    end, "real source GUI rendered level-18 options", 25)
    local found = {}
    for _, name in ipairs(first_ui.Options) do
        found[name] = true
    end
    assert(first_ui.PanelVisible and first_ui.ToggleVisible
        and #first_ui.Options == 3
        and found.HumanWarriorChoice
        and found.HumanKnightChoice
        and found.HumanRogueChoice
        and not found.ElvenScoutChoice,
        "Genuine Human Fighter GUI did not show exact C4 choices")
    print("[C4 First Transfer Live] REAL_GUI_SOURCE_CHOICES_PASS")

    outcomes[player.UserId] = nil
    channel:FireClient(player, "TryWrongRace")
    local denied = wait_for(function()
        return outcomes[player.UserId]
    end, "real client cross-race refusal", 12)
    assert(not denied.ok
        and denied.reason == "OriginalClassChoiceUnavailable",
        "Client forged cross-race first transfer was accepted")
    assert(runtime.ProfileService:get_character(player.UserId, 1)
        .ClassAdvancement.OriginalFirstTransferChoiceId == nil,
        "Rejected forged path modified the character")
    print("[C4 First Transfer Live] REAL_CLIENT_WRONG_RACE_DENIED_PASS")

    outcomes[player.UserId] = nil
    ui[player.UserId] = nil
    channel:FireClient(player, "ChooseHumanRogue")
    local selected = wait_for(function()
        return outcomes[player.UserId]
    end, "real client original class selection result", 12)
    assert(selected.ok and selected.class_id == "HumanRogue",
        "Real client original Human Rogue class-choice request failed")
    local character = assert(runtime.ProfileService:get_character(
        player.UserId, 1
    ))
    assert(character.ClassAdvancement.OriginalFirstTransferChoiceId
            == "HumanRogue"
        and character.Identity.ClassId == "Fighter"
        and character.ClassAdvancement.ActiveClassId == nil
        and character.Gold == 249,
        "Class choice granted an unearned first-transfer or changed gold")
    local visible = wait_for(function()
        local state = ui[player.UserId]
        return if state and state.SelectedClassId == "HumanRogue"
            then state else nil
    end, "real client UI displays the persisted original class choice", 15)
    assert(not visible.CanChoose
        and string.find(visible.StatusText, "quest is still", 1, true),
        "Actual client GUI falsely offered an unimplemented class quest")
    print("[C4 First Transfer Live] REAL_CLIENT_CHOICE_AND_UI_PASS")
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[C4 First Transfer Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(120, function()
    STS:EndTest("FAIL global C4 original choice client test timeout")
end)
]==]
driver.Parent = SSS

local ok, value = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        1, "C4OriginalFirstTransferClient_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and value == "PASS",
    "Original C4 client class-choice playtest failed: "
        .. tostring(value))
print("[C4 First Transfer Live] VERIFIED_REAL_CLIENT_CHOICE_PASS")
