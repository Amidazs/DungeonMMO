--!strict
-- Unpublished client proof that failed runs expose the Base return panel.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Failed-run UI probe requires unpublished Studio")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "FailedReturnUiChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "FailedReturnUiClient_TEMP"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("FailedReturnUiChannel_TEMP")

-- Args:
--   predicate: () -> any; UI property or object to observe.
--   label: string; meaningful timeout explanation.
-- Returns:
--   any: first positive observation.
local function wait_for(predicate, label)
    local deadline = os.clock() + 30
    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Failed Return UI] TIMEOUT " .. label)
end

local gui = wait_for(function()
    local player_gui = Players.LocalPlayer:FindFirstChildOfClass(
        "PlayerGui")
    return player_gui and player_gui:FindFirstChild("DungeonUi")
end, "real client DungeonUi")
local panel = wait_for(function()
    for _, descendant in ipairs(gui:GetDescendants()) do
        if descendant.Name == "ReturnButton"
            and descendant:IsA("TextButton")
        then
            return descendant.Parent
        end
    end
    return nil
end, "return panel")
local button = assert(panel:FindFirstChild("ReturnButton"))
local caption = assert(panel:FindFirstChild("Caption"))
local title = assert(panel:FindFirstChild("Title"))
channel:FireServer("READY")

wait_for(function()
    return panel.Visible
        and caption.Text == "EXPEDITION FAILED"
        and title.Text == "PARTY DEFEATED"
        and button.Text == "Return to Base"
end, "failed-run Base return button")
print("[Failed Return UI] FAILED_RETURN_BUTTON_PASS")
channel:FireServer("FAILED_PASS")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "FailedReturnUiDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local STS = game:GetService("StudioTestService")
local channel = RS:WaitForChild("FailedReturnUiChannel_TEMP")
local state = RS.Core.Remotes:WaitForChild("DungeonStateChanged")
local ready = {}
channel.OnServerEvent:Connect(function(player, command)
    ready[command] = player
end)

-- Args:
--   command: string; client progress stage to verify.
--   player: Player; authenticated testing client.
-- Returns:
--   nil: fails on a missing acknowledgement.
local function wait_for(command, player)
    local deadline = os.clock() + 35
    repeat
        if ready[command] == player then
            return
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Failed Return UI] missing " .. command)
end

-- Args: None.
-- Returns:
--   nil: sends terminal state through the ordinary presentation remote.
local function run()
    local player = Players:GetPlayers()[1]
        or Players.PlayerAdded:Wait()
    wait_for("READY", player)
    state:FireClient(player, {
        state = "Failed",
        objective = "Dungeon failed: revive window expired.",
    })
    wait_for("FAILED_PASS", player)
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Failed Return UI] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(85, function()
    STS:EndTest("FAIL global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("FailedReturnUi_TEMP")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()

assert(ok and result == "PASS",
    "Failed-run UI Play failed: " .. tostring(result))
print("[Failed Return UI] VERIFIED_PLAY_MODE_PASS")
