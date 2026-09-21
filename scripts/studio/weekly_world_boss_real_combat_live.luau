--!strict
-- Actual unpublished Studio client combat into the isolated guardian.
-- The real CombatService handles client attack intent and damage; no
-- test script sets the guardian's health or records fake damage.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Live guardian combat test requires an unpublished Studio place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")
local W = game:GetService("Workspace")

local channel = Instance.new("RemoteEvent")
channel.Name = "WorldBossCombatLiveChannel_TEMP"
channel.Parent = RS

local floor = Instance.new("Part")
floor.Name = "WorldBossCombatFloor_TEMP"
floor.Anchored = true
floor.Size = Vector3.new(100, 2, 100)
floor.Position = Vector3.new(0, -1, 0)
floor.Parent = W

local client = Instance.new("LocalScript")
client.Name = "WorldBossCombatLiveClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("WorldBossCombatLiveChannel_TEMP")
local config = require(RS.Combat.Shared.CombatConfig)
local attack = RS.Combat.Remotes:WaitForChild(
    config.REMOTES.ATTACK_REQUEST)

channel.OnClientEvent:Connect(function(command)
    if command ~= "Attack" then
        return
    end
    for _ = 1, 8 do
        attack:FireServer()
        task.wait(0.75)
    end
end)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "WorldBossCombatLiveDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local W = game:GetService("Workspace")
local channel = RS:WaitForChild("WorldBossCombatLiveChannel_TEMP")
local RuntimeServices = require(SSS.Core.Services.RuntimeServices)
local Factory = require(SSS.Dungeon.DungeonWeeklyWorldBossFactory)
local Bridge = require(SSS.Dungeon.DungeonContributionBridge)
local Authority = require(SSS.WorldBoss.WorldBossCombatAuthority)

local ready_id = nil
channel.OnServerEvent:Connect(function(player, kind)
    if kind == "Ready" then
        ready_id = player.UserId
    end
end)

-- Args:
--   condition: () -> any; returns a truthy observed combat state.
--   name: string; actionable timeout label.
--   limit: number; seconds to wait for real Studio replication.
-- Returns:
--   any: the observed result.
local function wait_for(condition, name, limit)
    local deadline = os.clock() + limit
    repeat
        local result = condition()
        if result then
            return result
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[World Boss Combat Live] TIMEOUT " .. name)
end

-- Args: None.
-- Returns: nil; asserts the actual client attack changes authoritative
-- guardian health and creates persistent scoped contribution.
local function run()
    local player = wait_for(function()
        return Players:GetPlayers()[1]
    end, "client player", 30)
    wait_for(function()
        return ready_id == player.UserId
    end, "client attack channel", 30)

    local runtime = RuntimeServices.new("Dungeon")
    local profiles = runtime.ProfileService
    assert(profiles:load(player.UserId),
        "the actual client's Studio profile did not load")
    local sessions = runtime.SessionService
    local session = assert(sessions:create(
        "TestDungeon", {player.UserId}, 0,
        "WorldBossCombatLiveReserved_TEMP", "Depth1"))
    local id = session.SessionId
    assert(sessions:set_instance_state(id, {}).ok)
    assert(sessions:mark_connected(id, player.UserId).ok)
    local now = os.time()
    local issued = runtime.WeeklyWorldBossSessionBridge:issue(
        id, now - 5, now + 300)
    assert(issued.ok, "trusted boss session issue failed: "
        .. tostring(issued.reason))

    local boss = Factory.create({
        Parent = W,
        SpawnCFrame = CFrame.new(0, 5, 0),
        InstanceId = id,
        -- Shorten ONLY the disposable Play fixture's guardian health
        -- so an unassisted client defeat completes in a short test.
        HealthMultiplier = 0.1,
    })
    local guardian_health = assert(
        boss:FindFirstChildOfClass("Humanoid")).Health
    local initial_gold = assert(profiles:get_character(
        player.UserId, 1)).Gold
    local admitted = {[player.UserId] = true}
    local authority = Authority.new(
        runtime.ContributionService,
        function()
            return {
                SessionId = id, Boss = boss,
                Admitted = admitted, Sessions = sessions,
            }
        end
    )
    Bridge.bind_service(authority)
    Bridge.bind_damage_target_validator(function(context)
        return context.target == boss
            and context.attacker == player
    end)

    local character = wait_for(function()
        return player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
            and player.Character
    end, "player's replicated character", 30)
    local root = character.HumanoidRootPart
    local humanoid = assert(character:FindFirstChildOfClass(
        "Humanoid"))
    humanoid.MaxHealth = 10000
    humanoid.Health = 10000
    character:SetAttribute("DungeonRunParticipant", true)
    character:SetAttribute("DungeonEncounterId", "WeeklyBoss:" .. id)
    root.CFrame = CFrame.lookAt(
        Vector3.new(0, 5, 5), Vector3.new(0, 5, 0))
    task.wait(2)
    channel:FireClient(player, "Attack")

    wait_for(function()
        local health = boss.Humanoid.Health
        local snapshot = runtime.ContributionService
            :get_player_snapshot(id, player.UserId)
        if health < guardian_health and snapshot.Damage > 0 then
            return snapshot
        end
        return nil
    end, "real client hit and persisted server damage", 20)
    print("[World Boss Combat Live] REAL_CLIENT_HIT_PASS")
    print("[World Boss Combat Live] SERVER_CONTRIBUTION_PASS")

    wait_for(function()
        return boss.Humanoid.Health <= 0
    end, "real client defeats the guardian without health injection", 20)
    local bridge = runtime.WeeklyWorldBossSessionBridge
    local defeated = bridge:record_defeat(id, boss)
    assert(defeated.ok,
        "real combat death did not persist through session bridge")
    print("[World Boss Combat Live] REAL_CLIENT_BOSS_DEFEAT_PASS")

    local contribution = runtime.ContributionService
        :get_player_snapshot(id, player.UserId)
    assert(contribution.ok and contribution.Damage > 0,
        "weekly reward must require the server's actual damage")
    assert(sessions:set_member_completion_eligibility(
        id, player.UserId, true).ok,
        "server-confirmed contributing member eligibility failed")
    local reward = bridge:grant_reward(id, player.UserId)
    assert(reward.ok and reward.gold_granted == 100
        and not reward.already_applied,
        "verified guardian defeat must grant one weekly reward")
    local duplicate = bridge:grant_reward(id, player.UserId)
    assert(duplicate.ok and duplicate.already_applied
        and duplicate.gold_granted == 0
        and assert(profiles:get_character(player.UserId, 1)).Gold
            == initial_gold + 100,
        "the same encounter must not grant the weekly reward twice")
    print("[World Boss Combat Live] WEEKLY_REWARD_ONCE_PASS")
    boss:Destroy()
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[World Boss Combat Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(110, function()
    STS:EndTest("FAIL combat fixture overall timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("WorldBossCombatLive_TEMP")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
floor:Destroy()
assert(ok and result == "PASS",
    "Real-client guardian combat test failed: " .. tostring(result))
print("[World Boss Combat Live] VERIFIED_PLAY_MODE_PASS")
