--!strict
-- Two real Studio clients prove the same threat policy on a normal
-- Training Marauder: nearest before threat, then highest threat.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Normal enemy aggro Play requires an unpublished Studio place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local channel = Instance.new("RemoteEvent")
channel.Name = "NormalTauntChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "NormalTauntClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local config = require(RS.Combat.Shared.CombatConfig)
local attack = RS.Combat.Remotes:WaitForChild(
    config.REMOTES.ATTACK_REQUEST)
local skill_request = RS.Combat.Remotes:WaitForChild(
    config.REMOTES.SKILL_REQUEST)
local channel = RS:WaitForChild("NormalTauntChannel_TEMP")

channel.OnClientEvent:Connect(function(command)
    if command == "StrikeOnce" then
        attack:FireServer()
    elseif command == "CastTaunt" then
        skill_request:FireServer("Taunt")
    elseif command == "StrikeThree" then
        for _ = 1, 3 do
            attack:FireServer()
            task.wait(0.72)
        end
    end
end)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "NormalTauntDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local config = require(RS.Combat.Shared.CombatConfig)
local ThreatService = require(SSS.Combat.ThreatService)
local RuntimeState = require(SSS.Core.Services.ProgressionRuntimeState)
local ProfileSchema = require(RS.Core.Shared.ProfileSchema)
local channel = RS:WaitForChild("NormalTauntChannel_TEMP")
local marauder_config = config.TRAINING_MARAUDER
local ready = {}

channel.OnServerEvent:Connect(function(player, kind)
    if kind == "Ready" then
        ready[player.UserId] = true
    end
end)

-- Args:
--   predicate: () -> any; authoritative condition to observe.
--   label: string; timeout failure context.
--   timeout: number; maximum seconds.
-- Returns:
--   any: first truthy observation.
local function wait_for(predicate, label, timeout)
    local deadline = os.clock() + timeout
    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Normal Taunt Live] TIMEOUT " .. label)
end

-- Args:
--   player: Player; real Studio client.
-- Returns:
--   Model: living combat character excluded from dungeon routing.
local function get_character(player)
    if not player.Character then
        player:LoadCharacter()
    end
    local character = wait_for(function()
        return player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
            and player.Character
    end, "character " .. tostring(player.UserId), 30)
    character:SetAttribute("DungeonRunParticipant", false)
    character:SetAttribute("DungeonEncounterId", nil)
    local humanoid = assert(character:FindFirstChildOfClass("Humanoid"))
    humanoid.MaxHealth = 10000
    humanoid.Health = 10000
    return character
end

-- Args:
--   character: Model; player to position.
--   enemy_root: BasePart; current Marauder root.
--   offset_z: number; signed distance from the enemy.
-- Returns:
--   nil: puts the client inside or outside melee reach facing the enemy.
local function place(character, enemy_root, offset_z)
    local position = enemy_root.Position + Vector3.new(0, 0, offset_z)
    character.HumanoidRootPart.CFrame = CFrame.lookAt(
        position,
        Vector3.new(
            enemy_root.Position.X,
            position.Y,
            enemy_root.Position.Z
        )
    )
end

-- Args: None.
-- Returns:
--   nil: completes normal-enemy aggro acceptance.
local function run()
    local players = wait_for(function()
        local current = Players:GetPlayers()
        return if #current == 2 then current else nil
    end, "two real clients", 35)
    table.sort(players, function(a, b)
        return a.UserId < b.UserId
    end)
    for _, player in ipairs(players) do
        wait_for(function()
            return ready[player.UserId]
        end, "ready client " .. tostring(player.UserId), 20)
    end

    local enemy = wait_for(function()
        return Workspace:FindFirstChild(marauder_config.MODEL_NAME)
    end, "training Marauder", 15)
    local enemy_root = assert(enemy:FindFirstChild("HumanoidRootPart"))
    local near_player = players[1]
    local far_player = players[2]
    local fighter = ProfileSchema.create_default(
        near_player.UserId).Characters.Slot1
    fighter.Identity.RaceId = "Human"
    fighter.Identity.BaseClassId = "Fighter"
    fighter.Identity.ClassId = "Fighter"
    fighter.Identity.CreationStage = "Complete"
    fighter.Progression.Skills.Taunt = {
        Known = true, PurchasedRank = 1,
    }
    fighter.Progression.Loadout[3] = "Taunt"
    RuntimeState.set_character(near_player.UserId, fighter)
    assert(RuntimeState.is_skill_usable(near_player.UserId, "Taunt"))
    local near_character = get_character(near_player)
    local far_character = get_character(far_player)

    ThreatService.clear(enemy)
    place(near_character, enemy_root, 1.8)
    place(far_character, enemy_root, -2.8)
    wait_for(function()
        return enemy:GetAttribute("MarauderAggroTargetUserId")
            == near_player.UserId
            and enemy:GetAttribute("MarauderAggroMode") == "Nearest"
    end, "nearest fallback", 12)
    print("[Normal Taunt Live] NEAREST_FALLBACK_PASS")

    channel:FireClient(far_player, "StrikeOnce")
    wait_for(function()
        return ThreatService.get_threat(enemy, far_player.UserId) > 0
            and enemy:GetAttribute("MarauderAggroTargetUserId")
                == far_player.UserId
            and enemy:GetAttribute("MarauderAggroMode") == "Threat"
    end, "first damage threat", 15)
    print("[Normal Taunt Live] FIRST_DAMAGE_THREAT_PASS")

    enemy_root = assert(enemy:FindFirstChild("HumanoidRootPart"))
    place(near_character, enemy_root, 2.2)
    local health_before = enemy.Humanoid.Health
    local threat_before = ThreatService.get_threat(
        enemy, near_player.UserId)
    assert(threat_before == 0,
        "Taunt caster must not have generated any damage threat")

    channel:FireClient(near_player, "CastTaunt")
    wait_for(function()
        return enemy:GetAttribute("MarauderAggroTargetUserId")
            == near_player.UserId
            and enemy:GetAttribute("MarauderAggroMode") == "Threat"
            and ThreatService.get_threat(enemy, near_player.UserId)
                > ThreatService.get_threat(enemy, far_player.UserId)
    end, "real Fighter Taunt on a normal Marauder", 12)
    assert(enemy.Humanoid.Health == health_before,
        "Taunt must not deal damage to a normal enemy")
    print("[Normal Taunt Live] ZERO_DAMAGE_SKILL_TAUNT_PASS")

    channel:FireClient(near_player, "CastTaunt")
    task.wait(0.25)
    assert(enemy.Humanoid.Health == health_before,
        "repeated Taunt cannot damage the normal enemy")
    print("[Normal Taunt Live] REPEATED_INPUT_SAFE_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Normal Taunt Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(120, function()
    STS:EndTest("FAIL normal aggro fixture global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        2, "NormalTauntTwoClient_TEMP")
end)

driver:Destroy()
client:Destroy()
channel:Destroy()

assert(ok and result == "PASS",
    "Two-client normal aggro test failed: " .. tostring(result))
print("[Normal Taunt Live] VERIFIED_MULTIPLAYER_PASS")
