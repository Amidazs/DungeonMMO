--!strict
-- Two real clients use the actual PlayAgain remote and party vote logic.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Replay request Play requires an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local dungeon = SSS.Dungeon
local runtime_script = dungeon.DungeonRuntime

-- Args:
--   script_instance: LuaSourceContainer; disposable runtime in this test.
--   old_value: string; exact unique source anchor.
--   new_value: string; temporary isolated replacement.
-- Returns:
--   nil: applies the change only to the Studio DataModel.
local function replace_once(script_instance, old_value, new_value)
    local source = script_instance.Source
    local index = assert(string.find(source, old_value, 1, true),
        "Missing replay test runtime hook")
    assert(not string.find(
        source, old_value, index + #old_value, true
    ), "Ambiguous replay test runtime hook")
    script_instance.Source = string.sub(source, 1, index - 1)
        .. new_value .. string.sub(source, index + #old_value)
end

local context = Instance.new("ModuleScript")
context.Name = "DungeonReplayClientContext_TEMP"
context.Source = "return {}"
context.Parent = dungeon
replace_once(
    runtime_script,
    'local runtime = RuntimeServices.new("Dungeon")',
    'local runtime = RuntimeServices.new("Dungeon")\n'
        .. 'require(script.Parent.DungeonReplayClientContext_TEMP)'
        .. '.runtime = runtime'
)
replace_once(
    runtime_script,
    '    if RunService:IsStudio() then\n'
        .. '        local studio = StudioSessionFactory.create_for_players(\n'
        .. '            {player},',
    '    if RunService:IsStudio() then\n'
        .. '        while #Players:GetPlayers() < 2 do task.wait(0.1) end\n'
        .. '        local studio = StudioSessionFactory.create_for_players(\n'
        .. '            Players:GetPlayers(),'
)
Workspace:SetAttribute("DungeonMMOStudioDungeonId", "TestDungeon")
Workspace:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
Workspace:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
Workspace:SetAttribute("DungeonMMOPlaceholderPlayableEnabled", true)

local channel = Instance.new("RemoteEvent")
channel.Name = "DungeonReplayClientAck_TEMP"
channel.Parent = RS
local client = Instance.new("LocalScript")
client.Name = "DungeonReplayClient_TEMP"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("DungeonReplayClientAck_TEMP")
local remotes = RS.Core.Remotes
local return_request = remotes:WaitForChild("ReturnRequest")
local state_changed = remotes:WaitForChild("DungeonStateChanged")
state_changed.OnClientEvent:Connect(function(payload)
    if type(payload) == "table" and payload.state == "ReplayError" then
        warn(
            "[Dungeon Replay Client] REPLAY_ERROR "
            .. tostring(payload.replay_error)
            .. " member=" .. tostring(payload.MemberUserId)
            .. " depth=" .. tostring(payload.DifficultyId)
        )
    end
end)

-- Args:
--   predicate: () -> any; observable client UI state.
--   label: string; actionable timeout diagnostic.
-- Returns:
--   any: first truthy UI state.
local function wait_for(predicate, label)
    local deadline = os.clock() + 45
    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Dungeon Replay Client] TIMEOUT " .. label)
end

local panel = wait_for(function()
    local gui = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local dungeon = gui and gui:FindFirstChild("DungeonUi")
    return dungeon and dungeon:FindFirstChild("CompletePanel")
end, "real Dungeon completion panel")
local replay = assert(panel:FindFirstChild("PlayAgainButton"))
channel.OnClientEvent:Connect(function(command)
    if command == "Vote" then
        channel:FireServer("VOTE_RECEIVED")
        wait_for(function()
            return panel.Visible and replay.Text == "Play again"
        end, "failed run offers Play again")
        -- This is the same authenticated client remote sent by the button;
        -- no server-side replay service method is invoked by the fixture.
        return_request:FireServer("PlayAgain")
        channel:FireServer("VOTE_SENT")
    end
end)
channel:FireServer("READY")

task.spawn(function()
    wait_for(function()
        return panel.Visible and replay.Text == "Waiting for party"
    end, "server-owned pending party vote")
    channel:FireServer("WAITING")
end)
task.spawn(function()
    wait_for(function()
        return panel.Visible and replay.Text == "Replay simulated"
    end, "server-owned successful party replay")
    channel:FireServer("SIMULATED")
end)
]==]
client.Parent = game:GetService("StarterPlayer").StarterPlayerScripts

local driver = Instance.new("Script")
driver.Name = "DungeonReplayRequestDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local STS = game:GetService("StudioTestService")
local channel = RS:WaitForChild("DungeonReplayClientAck_TEMP")
local context = require(
    script.Parent.Dungeon.DungeonReplayClientContext_TEMP
)
local acknowledgements = {}

channel.OnServerEvent:Connect(function(player, message)
    acknowledgements[tostring(player.UserId) .. ":" .. message] = true
end)

-- Args:
--   predicate: () -> any; expected authenticated server state.
--   label: string; meaningful timeout explanation.
--   duration: number; maximum waiting time in seconds.
-- Returns:
--   any: first truthy observation.
local function wait_for(predicate, label, duration)
    local deadline = os.clock() + duration
    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Dungeon Replay Request] TIMEOUT " .. label)
end

-- Args:
--   player: Player; one real Studio participant.
--   state: string; acknowledged client-side replay stage.
-- Returns:
--   boolean: true if that participant reported the stage.
local function acknowledged(player, state)
    return acknowledgements[tostring(player.UserId) .. ":" .. state]
        == true
end

-- Args: None.
-- Returns:
--   nil: proves the real server's party-wide replay request behavior.
local function run()
    local players = wait_for(function()
        local all = Players:GetPlayers()
        return if #all == 2 then all else nil
    end, "two actual clients", 45)
    table.sort(players, function(a, b)
        return a.UserId < b.UserId
    end)
    local runtime = wait_for(function()
        return context.runtime
    end, "authoritative dungeon runtime", 30)
    local sessions = runtime.SessionService
    local session = wait_for(function()
        local current = sessions:get_for_user(players[1].UserId)
        if not current or current.State ~= "Active" then
            return nil
        end
        for _, player in ipairs(players) do
            local member = current.Members[tostring(player.UserId)]
            if not member or member.Connected ~= true
                or member.Mode ~= "Active"
                or not acknowledged(player, "READY")
            then
                return nil
            end
        end
        return current
    end, "both real clients admitted and UI ready", 65)

    -- Terminal failure is scoped to this disposable test session;
    -- the transport/UI flow after that point uses production remotes.
    assert(sessions:mark_failed(
        session.SessionId, "TEMP_ReplayRequestTerminalTest"
    ).ok, "Fixture failed to seed a terminal session")
    local state = RS.Core.Remotes:WaitForChild(
        "DungeonStateChanged"
    )
    for _, player in ipairs(players) do
        state:FireClient(player, {
            state = "Failed",
            objective = "Fixture terminal run; choose Play again.",
        })
    end
    channel:FireClient(players[1], "Vote")
    wait_for(function()
        return acknowledged(players[1], "WAITING")
    end, "first client receives actual party wait state", 15)
    print("[Dungeon Replay Request] FIRST_CLIENT_WAITING_PASS")

    channel:FireClient(players[2], "Vote")
    wait_for(function()
        return acknowledged(players[2], "VOTE_RECEIVED")
    end, "second client received replay instruction", 8)
    wait_for(function()
        return acknowledged(players[2], "VOTE_SENT")
    end, "second client sent its authenticated replay request", 8)
    print("[Dungeon Replay Request] SECOND_CLIENT_VOTED_PASS")
    wait_for(function()
        return acknowledged(players[1], "SIMULATED")
            and acknowledged(players[2], "SIMULATED")
    end, "both clients receive new-run simulation", 18)
    assert(sessions:get(session.SessionId).State == "Failed",
        "Replay must never re-activate the predecessor session")
    print("[Dungeon Replay Request] TWO_CLIENT_REPLAY_CONSENT_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Dungeon Replay Request] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(145, function()
    STS:EndTest("FAIL replay request fixture global timeout")
end)
]==]
driver.Parent = SSS
local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        2, "DungeonTwoClientReplayRequest_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
context:Destroy()
assert(ok and result == "PASS",
    "Two-client replay request failed: " .. tostring(result))
print("[Dungeon Replay Request] VERIFIED_MULTIPLAYER_PASS")
