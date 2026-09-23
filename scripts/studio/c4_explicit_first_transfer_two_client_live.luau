--!strict
-- Genuine two-client unpublished Base C4 class selection acceptance.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Class-path playtest requires an unpublished local Studio place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local runtime_script = SSS.Base.BaseRuntime
local needle = 'local runtime = RuntimeServices.new("Base")'
local source = runtime_script.Source
local pos = assert(string.find(source, needle, 1, true),
    "Base runtime composition anchor missing")
assert(not string.find(source, needle, pos + #needle, true),
    "Base runtime composition anchor is ambiguous")
runtime_script.Source = source:sub(1, pos + #needle - 1)
    .. '\n_G.C4ChoiceTwoClientRuntime_TEMP = runtime'
    .. source:sub(pos + #needle)

local channel = Instance.new("RemoteEvent")
channel.Name = "C4ChoiceTwoClientChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "C4ChoiceTwoClientActualClient_TEMP"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remotes = RS.Core.Remotes
local channel = RS:WaitForChild("C4ChoiceTwoClientChannel_TEMP")
local request = remotes:WaitForChild("ClassAdvancementRequest")
local snapshots = remotes:WaitForChild("ClassAdvancementSnapshot")
local results = remotes:WaitForChild("ClassAdvancementResult")
local preferred = nil
local expected_response = nil
snapshots.OnClientEvent:Connect(function(snapshot)
    local state = snapshot and snapshot.OriginalFirstTransfer
    if not preferred or not state or not state.ok then return end
    local has_option = false
    for _, item in ipairs(state.Options or {}) do
        if item.Id == preferred then
            has_option = true
        end
    end
    if not has_option or not state.CanChoose
        or state.SelectedClassId then return end
    local gui = player:WaitForChild("PlayerGui"):FindFirstChild(
        "C4FirstTransferChoiceUi"
    )
    local panel = gui and gui:FindFirstChild("ClassPathPanel")
    local card = panel and panel:FindFirstChild(
        "SourceClassOptions"
    ) and panel.SourceClassOptions:FindFirstChild(preferred .. "Choice")
    if not gui or not panel or not card then
        channel:FireServer("Error", "Actual original class UI or card absent")
        return
    end
    if panel.Visible ~= true then
        channel:FireServer("Error", "Actual level-18 class panel not visible")
        return
    end
    channel:FireServer("UiVisible", preferred)
    request:FireServer("SelectFirstTransfer", preferred)
    preferred = nil
end)
results.OnClientEvent:Connect(function(reply)
    if expected_response and reply then
        channel:FireServer("SelectionResult", {
            class_id = expected_response, ok = reply.ok,
            reason = reply.reason, selected = reply.class_id,
        })
        expected_response = nil
    end
end)
channel.OnClientEvent:Connect(function(action, class_id)
    if action == "Choose" then
        preferred = class_id
        expected_response = class_id
        request:FireServer("Snapshot")
    elseif action == "TrySecond" then
        expected_response = class_id
        request:FireServer("SelectFirstTransfer", class_id)
    elseif action == "TryLegacy" then
        expected_response = "LegacyTrial"
        request:FireServer("StartTrial")
    end
end)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "C4ChoiceTwoClientDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local STS = game:GetService("StudioTestService")
local channel = RS:WaitForChild("C4ChoiceTwoClientChannel_TEMP")
local replies = {}
local ready = {}
local ui = {}
local errors = {}
channel.OnServerEvent:Connect(function(player, action, detail)
    if action == "Ready" then
        ready[player.UserId] = true
    elseif action == "SelectionResult" then
        replies[player.UserId] = detail
    elseif action == "UiVisible" then
        ui[player.UserId] = detail
    elseif action == "Error" then
        errors[player.UserId] = tostring(detail)
    end
end)

--[[
Waits for actual two-client original-class selection and profile state.

Args:
    predicate (() -> any): Genuine Base session/server result.
    label (string): Specific live-test failure diagnostic.
    seconds (number): Maximum allowed Studio test wait.

Returns:
    any: First truthy observed game state.
]]
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then return value end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[C4 Choice Live] TIMEOUT " .. label)
end

--[[
Requests a real client UI selection using normal class-remotes.

Args:
    player (Player): Authenticated local Studio client.
    action (string): Choose, TrySecond or TryLegacy.
    class_id (string): Source choice ID, or old trial marker.

Returns:
    any: Original server action result observed by the actual client.
]]
local function request_client(player, action, class_id)
    replies[player.UserId] = nil
    channel:FireClient(player, action, class_id)
    return wait_for(function()
        assert(not errors[player.UserId],
            "Client class-path UI error: " .. tostring(errors[player.UserId]))
        return replies[player.UserId]
    end, "real client " .. action .. " " .. class_id, 16)
end

--[[
Validates two actual clients independently select their own original path.

Args:
    None.

Returns:
    nil: Proves real UI, server authorizations, no automatic free class.
]]
local function main()
    local runtime = wait_for(function()
        return _G.C4ChoiceTwoClientRuntime_TEMP
    end, "actual Base runtime", 45)
    local players = wait_for(function()
        local list = Players:GetPlayers()
        return if #list == 2 then list else nil
    end, "two actual Studio client players", 55)
    for _, player in ipairs(players) do
        wait_for(function()
            local character = runtime.ProfileService:get_character(
                player.UserId, 1
            )
            return ready[player.UserId] and character
                and character.Identity.CreationStage == "Complete"
                and character.Identity.RaceId == "Human"
                and character.Identity.BaseClassId == "Fighter"
        end, "actual client created original Human Fighter", 60)
        assert(runtime.ProfileService:mutate(
            player.UserId, function(profile)
                profile.Characters.Slot1.Level = 18
            end), "Test-only level-18 source progression failed")
    end
    local rogue, knight = players[1], players[2]
    local first = request_client(rogue, "Choose", "HumanRogue")
    assert(first.ok and first.selected == "HumanRogue"
        and ui[rogue.UserId] == "HumanRogue",
        "Human Fighter's real UI could not select original Rogue")
    local second = request_client(knight, "Choose", "HumanKnight")
    assert(second.ok and second.selected == "HumanKnight"
        and ui[knight.UserId] == "HumanKnight",
        "Same original starter could not independently choose Knight")
    print("[C4 Choice Live] TWO_REAL_CLIENTS_DIFFERENT_SOURCE_PATHS_PASS")

    for _, player in ipairs(players) do
        local selected = if player == rogue
            then "HumanRogue" else "HumanKnight"
        local character = assert(runtime.ProfileService:get_character(
            player.UserId, 1
        ))
        assert(character.ClassAdvancement.OriginalFirstTransferChoiceId
            == selected
            and character.ClassAdvancement.ActiveClassId == nil
            and character.Identity.BaseClassId == "Fighter"
            and character.Identity.ClassId == "Fighter"
            and character.Quests.Completed.FighterAdvancementTrial ~= true,
            "Client C4 selection incorrectly awarded class or old quest")
        local legacy = request_client(
            player, "TryLegacy", "LegacyTrial"
        )
        assert(not legacy.ok
            and legacy.reason == "OriginalC4BranchChoiceRequired",
            "Client could still start the discarded automatic Vanguard path")
    end
    local duplicate = request_client(
        rogue, "TrySecond", "HumanWarrior"
    )
    assert(not duplicate.ok and duplicate.reason
        == "OriginalClassChoiceAlreadyMade",
        "Client silently overwrote its already-chosen source class")
    print("[C4 Choice Live] ORIGINAL_PATH_AUTHORITY_AND_LEGACY_DENIAL_PASS")
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[C4 Choice Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(130, function()
    STS:EndTest("FAIL global two-client original C4 choice timeout")
end)
]==]
driver.Parent = SSS

local ok, value = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        2, "C4ExplicitOriginalFirstTransfer_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and value == "PASS",
    "Two-client original C4 path gameplay failed: " .. tostring(value))
print("[C4 Choice Live] VERIFIED_TWO_CLIENT_ORIGINAL_C4_SELECTION_PASS")
