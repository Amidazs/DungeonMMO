--!strict
-- TEMP local Base only. Two real simulated Studio clients: one leaves, one joins.
-- Never claims same-UserId reconnect or cross-server persistence.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Run only against an unpublished temporary Base place.")

local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer"):WaitForChild("StarterPlayerScripts")
local STS = game:GetService("StudioTestService")

local client = Instance.new("LocalScript")
client.Name = "Phase4JoinLeaveClient_TEMP"
client.Source = [=[
local Players = game:GetService("Players")
local STS = game:GetService("StudioTestService")
local me = Players.LocalPlayer
local function handle()
    if me:GetAttribute("Phase4TempLeave") ~= true then return end
    print("[Phase4 MultiClient] CLIENT_LEAVE_REQUEST UserId=" .. tostring(me.UserId))
    assert(STS:CanLeaveTest(), "Studio client cannot leave current test")
    STS:LeaveTest()
end
me:GetAttributeChangedSignal("Phase4TempLeave"):Connect(handle)
handle()
]=]
client.Parent = SPS

local server = Instance.new("Script")
server.Name = "Phase4JoinLeaveServer_TEMP"
server.Source = [=[
local Players = game:GetService("Players")
local STS = game:GetService("StudioTestService")
local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then return value end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Phase4 MultiClient] TIMEOUT " .. label)
end
local arrivals = {}
local departures = {}
Players.PlayerAdded:Connect(function(p)
    arrivals[p.UserId] = true
    print("[Phase4 MultiClient] ADDED " .. tostring(p.UserId))
end)
Players.PlayerRemoving:Connect(function(p)
    departures[p.UserId] = true
    print("[Phase4 MultiClient] REMOVED " .. tostring(p.UserId))
end)
local function run()
    assert(game.PlaceId == 0 and game.GameId == 0,
        "Multiplayer test must not run against published place.")
    local defs = require(RS.Core.Shared.DungeonDefinitions)
    for _, dungeon_id in ipairs({"TestDungeon", "AbandonedMine"}) do
        assert(defs.get(dungeon_id).OptionalBossRuntimeEnabled == false,
            dungeon_id .. " optional boss rollout must stay off")
    end
    local initial = wait_for(function()
        local members = Players:GetPlayers()
        if #members >= 2 then return members end
        return nil
    end, "two real test clients", 30)
    local leaving = initial[1]
    local staying = initial[2]
    local leaving_id, staying_id = leaving.UserId, staying.UserId
    assert(leaving_id ~= staying_id, "simulated clients need distinct IDs")
    leaving:SetAttribute("Phase4TempLeave", true)
    wait_for(function() return departures[leaving_id] end,
        "real client PlayerRemoving", 25)
    assert(Players:GetPlayerByUserId(leaving_id) == nil,
        "departed client remains registered")
    assert(Players:GetPlayerByUserId(staying_id) == staying,
        "remaining client was lost when peer left")
    print("[Phase4 MultiClient] REAL_LEAVE_PASS")
    STS:AddPlayers(1)
    local joined = wait_for(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.UserId ~= staying_id and p.UserId ~= leaving_id then
                return p
            end
        end
        return nil
    end, "replacement client joined", 30)
    assert(joined.UserId ~= leaving_id,
        "replacing a client is not same-user reconnect")
    assert(Players:GetPlayerByUserId(staying_id) == staying,
        "peer must stay connected after replacement joins")
    print("[Phase4 MultiClient] REPLACEMENT_JOIN_PASS Old="
        .. leaving_id .. " New=" .. joined.UserId)
    print("[Phase4 MultiClient] SAME_USER_RECONNECT_NOT_TESTED")
end
task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then warn("[Phase4 MultiClient] FAIL " .. tostring(reason)) end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(100, function() STS:EndTest("FAIL global timeout") end)
]=]
server.Parent = SSS

print("[Phase4 MultiClient] START_TWO_CLIENTS")
local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(2, "Phase4JoinLeave_TEMP")
end)
server:Destroy()
client:Destroy()
assert(ok, "Could not start Studio multiplayer test: " .. tostring(result))
assert(result == "PASS", "Multiplayer test failed: " .. tostring(result))
print("[Phase4 MultiClient] MULTIPLAYER_REAL_LEAVE_JOIN_PASS")
