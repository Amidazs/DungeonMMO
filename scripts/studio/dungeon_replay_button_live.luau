--!strict
-- Unpublished client proof of Play again after completion and wipe.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Replay UI test must run in an unpublished Studio place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "DungeonReplayUiAck_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "DungeonReplayUiClient_TEMP"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("DungeonReplayUiAck_TEMP")

-- Args:
--   predicate: () -> any; client-observable UI state.
--   label: string; helpful timeout diagnostic.
-- Returns:
--   any: the first positive observation.
local function wait_for(predicate, label)
    local deadline = os.clock() + 30
    repeat
        local observed = predicate()
        if observed then
            return observed
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Dungeon Replay UI] TIMEOUT " .. label)
end

local gui = wait_for(function()
    local root = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
    return root and root:FindFirstChild("DungeonUi")
end, "client DungeonUi")
local panel = assert(gui:FindFirstChild("CompletePanel"))
local replay = assert(panel:FindFirstChild("PlayAgainButton"))
local returning = assert(panel:FindFirstChild("ReturnButton"))
local title = assert(panel:FindFirstChild("Title"))
channel:FireServer("READY")

wait_for(function()
    return panel.Visible
        and title.Text == "VICTORY"
        and replay.Text == "Play again"
        and replay.Active
        and returning.Active
end, "completed run has both choices")
print("[Dungeon Replay UI] COMPLETION_BUTTON_PASS")
channel:FireServer("COMPLETE_PASS")

wait_for(function()
    return panel.Visible
        and title.Text == "PARTY DEFEATED"
        and replay.Text == "Play again"
        and replay.Active
        and returning.Active
end, "fully wiped run has both choices")
print("[Dungeon Replay UI] WIPE_BUTTON_PASS")
channel:FireServer("FAILED_PASS")

wait_for(function()
    return panel.Visible and replay.Text == "Replay simulated"
end, "the first replay state keeps its terminal panel")
channel:FireServer("SIMULATED_PASS")

channel.OnClientEvent:Connect(function(command)
    if command ~= "CHECK_LATE_REVIVE" then
        return
    end
    task.wait(0.3)
    assert(panel.Visible and replay.Text == "Replay simulated",
        "A late revive snapshot must not hide Play again")
    print("[Dungeon Replay UI] LATE_REVIVE_PANEL_PASS")
    channel:FireServer("LATE_REVIVE_PASS")
end)
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "DungeonReplayUiDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local STS = game:GetService("StudioTestService")
local channel = RS:WaitForChild("DungeonReplayUiAck_TEMP")
local state = RS.Core.Remotes:WaitForChild("DungeonStateChanged")
local responses = {}

channel.OnServerEvent:Connect(function(player, command)
    responses[command] = player
end)

-- Args:
--   player: Player; sole genuine Studio testing client.
--   label: string; expected client acknowledgement.
-- Returns:
--   nil: raises if the client has not reached the required stage.
local function wait_for(player, label)
    local deadline = os.clock() + 35
    repeat
        if responses[label] == player then
            return
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Dungeon Replay UI] missing " .. label)
end

-- Args: None.
-- Returns:
--   nil: exercises both end states through actual client presentation.
local function run()
    local player = Players:GetPlayers()[1]
        or Players.PlayerAdded:Wait()
    wait_for(player, "READY")
    state:FireClient(player, {
        state = "Complete",
        objective = "Dungeon complete.",
        completion_eligible = true,
        completion = {},
    })
    wait_for(player, "COMPLETE_PASS")
    state:FireClient(player, {
        state = "Failed",
        objective = "Dungeon failed: revive window expired.",
    })
    wait_for(player, "FAILED_PASS")
    state:FireClient(player, {
        state = "ReplaySimulated",
        objective = "Studio replay simulated.",
    })
    wait_for(player, "SIMULATED_PASS")
    RS.Core.Remotes:WaitForChild("ReviveStateChanged")
        :FireClient(player, {
            session_state = "Failed",
            member_mode = "Spectating",
            free_available = false,
        })
    channel:FireClient(player, "CHECK_LATE_REVIVE")
    wait_for(player, "LATE_REVIVE_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Dungeon Replay UI] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(90, function()
    STS:EndTest("FAIL global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("DungeonReplayEndStates_TEMP")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Dungeon replay UI failed: " .. tostring(result))
print("[Dungeon Replay UI] VERIFIED_PLAY_MODE_PASS")
