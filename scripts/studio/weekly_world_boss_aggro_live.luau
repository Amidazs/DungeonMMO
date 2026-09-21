--!strict
-- Two real Studio clients exercise nearest-player fallback, damage threat,
-- highest-threat switching, and a zero-damage taunt against one guardian.
assert(game.PlaceId == 0 and game.GameId == 0,
    "World-boss aggro Play requires an unpublished Studio place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local channel = Instance.new("RemoteEvent")
channel.Name = "WorldBossAggroChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "WorldBossAggroClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local config = require(RS.Combat.Shared.CombatConfig)
local attack = RS.Combat.Remotes:WaitForChild(
    config.REMOTES.ATTACK_REQUEST)
local skill = RS.Combat.Remotes:WaitForChild(
    config.REMOTES.SKILL_REQUEST)
local channel = RS:WaitForChild("WorldBossAggroChannel_TEMP")

channel.OnClientEvent:Connect(function(command)
    if command == "ProtectTestCharacter" then
        local character = game:GetService("Players").LocalPlayer.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.MaxHealth = 10000
            humanoid.Health = 10000
        end
    elseif command == "StrikeOnce" then
        attack:FireServer()
    elseif command == "StrikeThree" then
        for _ = 1, 3 do
            attack:FireServer()
            task.wait(0.72)
        end
    elseif command == "Taunt" then
        skill:FireServer("Taunt")
    end
end)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "WorldBossAggroDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local channel = RS:WaitForChild("WorldBossAggroChannel_TEMP")
local RuntimeServices = require(SSS.Core.Services.RuntimeServices)
local Factory = require(SSS.Dungeon.DungeonWeeklyWorldBossFactory)
local Bridge = require(SSS.Dungeon.DungeonContributionBridge)
local Authority = require(SSS.WorldBoss.WorldBossCombatAuthority)
local ThreatService = require(SSS.Combat.ThreatService)
local ProgressionRuntimeState = require(
    SSS.Core.Services.ProgressionRuntimeState
)
local ProfileSchema = require(
    RS.Core.Shared.ProfileSchema
)

local ready = {}

channel.OnServerEvent:Connect(function(player, kind)
    if kind == "Ready" then
        ready[player.UserId] = true
    end
end)

-- Args:
--   predicate: () -> any; condition polled from authoritative server state.
--   label: string; timeout description.
--   timeout: number; maximum seconds to wait.
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
    error("[World Boss Aggro Live] TIMEOUT " .. label)
end

-- Args:
--   player: Player; authenticated Studio client.
--   session_id: string; server-issued encounter ID.
-- Returns:
--   Model: ready combat character.
local function prepare_character(player, session_id)
    local character = wait_for(function()
        return player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
            and player.Character
    end, "character " .. tostring(player.UserId), 30)
    character:SetAttribute("DungeonRunParticipant", true)
    character:SetAttribute(
        "DungeonEncounterId", "WeeklyBoss:" .. session_id)
    local humanoid = assert(character:FindFirstChildOfClass("Humanoid"))
    humanoid.MaxHealth = 10000
    humanoid.Health = 10000
    return character
end

-- Args:
--   players: {Player}; two real clients.
-- Returns:
--   (any, string, Model): runtime services, session ID, guardian.
local function create_encounter(players)
    local runtime = RuntimeServices.new("Dungeon")
    local user_ids = {}
    for _, player in ipairs(players) do
        assert(runtime.ProfileService:load(player.UserId))
        table.insert(user_ids, player.UserId)
    end

    local session = assert(runtime.SessionService:create(
        "TestDungeon", user_ids, 0,
        "WorldBossAggroReserved_TEMP", "Depth1"))
    local session_id = session.SessionId
    assert(runtime.SessionService:set_instance_state(session_id, {}).ok)
    for _, player in ipairs(players) do
        assert(runtime.SessionService:mark_connected(
            session_id, player.UserId).ok)
    end
    local now = os.time()
    assert(runtime.WeeklyWorldBossSessionBridge:issue(
        session_id, now - 5, now + 300).ok)

    local boss = Factory.create({
        Parent = Workspace,
        SpawnCFrame = CFrame.new(0, 5, 0),
        InstanceId = session_id,
        HealthMultiplier = 5,
    })
    local admitted = {}
    for _, player in ipairs(players) do
        admitted[player.UserId] = true
    end
    Bridge.bind_service(Authority.new(
        runtime.ContributionService,
        function()
            return {
                SessionId = session_id,
                Boss = boss,
                Admitted = admitted,
                Sessions = runtime.SessionService,
            }
        end
    ))
    Bridge.bind_damage_target_validator(function(context)
        return context.target == boss and context.attacker
            and admitted[context.attacker.UserId] == true
    end)
    return runtime, session_id, boss
end

-- Args:
--   character: Model; player character to position.
--   position: Vector3; trusted test position.
-- Returns:
--   nil: places character facing the guardian origin.
local function place(character, position)
    character.HumanoidRootPart.CFrame = CFrame.lookAt(
        position, Vector3.new(0, position.Y, 0))
end

-- Args: None.
-- Returns:
--   nil: performs the complete local two-client aggro proof.
local function run()
    local players = wait_for(function()
        local current = Players:GetPlayers()
        return if #current == 2 then current else nil
    end, "two clients", 35)

    table.sort(players, function(a, b)
        return a.UserId < b.UserId
    end)
    for _, player in ipairs(players) do
        wait_for(function()
            return ready[player.UserId]
        end, "ready client " .. tostring(player.UserId), 20)
    end

    local runtime, session_id, boss = create_encounter(players)
    local near_player = players[1]
    local far_player = players[2]

    local fighter = ProfileSchema.create_default(
        far_player.UserId).Characters.Slot1
    fighter.Identity.RaceId = "Human"
    fighter.Identity.BaseClassId = "Fighter"
    fighter.Identity.ClassId = "Fighter"
    fighter.Identity.CreationStage = "Complete"
    fighter.Progression.Skills.Taunt = {
        Known = true,
        PurchasedRank = 1,
    }
    fighter.Progression.Loadout[3] = "Taunt"
    ProgressionRuntimeState.set_character(
        far_player.UserId, fighter)
    assert(ProgressionRuntimeState.is_skill_usable(
        far_player.UserId, "Taunt"),
        "real client Taunt must be authorized")

    local near_character = prepare_character(near_player, session_id)
    local far_character = prepare_character(far_player, session_id)

    -- Studio multiplayer clients own their character's Humanoid.
    -- Protect both disposable characters on the owning clients;
    -- otherwise a 100-HP test account may die to normal guardian
    -- attacks before it can retake aggro with zero-damage Taunt.
    for _, player in ipairs(players) do
        channel:FireClient(player, "ProtectTestCharacter")
    end
    wait_for(function()
        local near_health = near_character:FindFirstChildOfClass("Humanoid")
        local far_health = far_character:FindFirstChildOfClass("Humanoid")
        return near_health and far_health
            and near_health.MaxHealth >= 10000
            and far_health.MaxHealth >= 10000
    end, "both real clients acknowledge protected test health", 8)

    place(near_character, Vector3.new(0, 5, 1.8))
    place(far_character, Vector3.new(0, 5, -2.8))

    wait_for(function()
        return boss:GetAttribute("MarauderAggroTargetUserId")
            == near_player.UserId
            and boss:GetAttribute("MarauderAggroMode") == "Nearest"
    end, "nearest fallback before threat", 12)
    print("[World Boss Aggro Live] NEAREST_FALLBACK_PASS")

    -- Reposition for each actual client slash. The guardian may
    -- move/turn while the first Studio client finishes spawning.
    -- No test-only threat or synthetic damage is injected.
    for strike = 1, 3 do
        local root = assert(boss:FindFirstChild("HumanoidRootPart"))
        local position = root.Position + Vector3.new(0, 0, -2.2)
        far_character.HumanoidRootPart.CFrame = CFrame.lookAt(
            position, root.Position
        )
        channel:FireClient(far_player, "StrikeOnce")
        task.wait(0.85)
        if ThreatService.get_threat(boss, far_player.UserId) > 0 then
            break
        end
    end
    wait_for(function()
        return ThreatService.get_threat(
            boss, far_player.UserId) > 0
            and boss:GetAttribute("MarauderAggroTargetUserId")
                == far_player.UserId
            and boss:GetAttribute("MarauderAggroMode") == "Threat"
    end, "far player takes aggro after real client damage", 8)
    print("[World Boss Aggro Live] FIRST_DAMAGE_THREAT_PASS")

    -- The threat holder is deliberately farther away than the near
    -- player, but both remain inside the boss stop radius so movement
    -- cannot make this target-switch proof flaky.
    wait_for(function()
        return boss:GetAttribute("MarauderAggroTargetUserId")
            == far_player.UserId
            and (far_character.HumanoidRootPart.Position
                - boss.HumanoidRootPart.Position).Magnitude
                > (near_character.HumanoidRootPart.Position
                    - boss.HumanoidRootPart.Position).Magnitude
    end, "higher threat beats the nearer player", 8)
    print("[World Boss Aggro Live] THREAT_BEATS_DISTANCE_PASS")

    -- Attack the current enemy position again between real client
    -- swings. The NPC may turn or move after threat switches, and
    -- the basic combo's forward step can move a test character away.
    -- Every threat increase must come from an actual client hit.
    for strike = 1, 3 do
        local target_root = assert(
            boss:FindFirstChild("HumanoidRootPart"))
        local position = target_root.Position + Vector3.new(0, 0, 2.2)
        near_character.HumanoidRootPart.CFrame = CFrame.lookAt(
            position, target_root.Position
        )
        local previous = ThreatService.get_threat(
            boss, near_player.UserId)
        channel:FireClient(near_player, "StrikeOnce")
        wait_for(function()
            return ThreatService.get_threat(
                boss, near_player.UserId) > previous
        end, "real challenger melee hit " .. strike, 8)
        if ThreatService.get_threat(boss, near_player.UserId)
            > ThreatService.get_threat(boss, far_player.UserId)
        then
            break
        end
        task.wait(0.85)
    end
    wait_for(function()
        return ThreatService.get_threat(boss, near_player.UserId)
            > ThreatService.get_threat(boss, far_player.UserId)
            and boss:GetAttribute("MarauderAggroTargetUserId")
                == near_player.UserId
    end, "higher real damage takes aggro", 8)
    print("[World Boss Aggro Live] HIGHER_DAMAGE_SWITCH_PASS")

    local before_damage = runtime.ContributionService
        :get_player_snapshot(session_id, far_player.UserId).Damage
    assert(far_character:FindFirstChildOfClass("Humanoid").Health > 0,
        "taunting party member must be alive and targetable")
    local target_root = assert(
        boss:FindFirstChild("HumanoidRootPart"))
    local taunt_position = target_root.Position
        + Vector3.new(0, 0, -3.5)
    far_character.HumanoidRootPart.CFrame = CFrame.lookAt(
        taunt_position,
        target_root.Position
    )
    channel:FireClient(far_player, "Taunt")
    wait_for(function()
        return boss:GetAttribute("MarauderAggroTargetUserId")
            == far_player.UserId
            and ThreatService.get_threat(boss, far_player.UserId)
                > ThreatService.get_threat(boss, near_player.UserId)
    end, "real zero-damage Taunt skill takes aggro", 10)
    local after_damage = runtime.ContributionService
        :get_player_snapshot(session_id, far_player.UserId).Damage
    assert(before_damage == after_damage,
        "Taunt skill must generate threat without fake damage")
    print("[World Boss Aggro Live] REAL_TAUNT_SKILL_PASS")

    boss:Destroy()
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[World Boss Aggro Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(125, function()
    STS:EndTest("FAIL aggro fixture global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        2, "WorldBossAggroTwoClient_TEMP")
end)

driver:Destroy()
client:Destroy()
channel:Destroy()

assert(ok and result == "PASS",
    "Two-client world-boss aggro test failed: " .. tostring(result))
print("[World Boss Aggro Live] VERIFIED_MULTIPLAYER_PASS")
