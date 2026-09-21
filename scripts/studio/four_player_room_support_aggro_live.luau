--!strict
-- Four real unpublished clients exercise two independent Marauder ledgers.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Four-player aggro Play requires an unpublished Studio place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "FourPlayerAggroChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "FourPlayerAggroClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local config = require(RS.Combat.Shared.CombatConfig)
local attack = RS.Combat.Remotes:WaitForChild(
    config.REMOTES.ATTACK_REQUEST)
local skill = RS.Combat.Remotes:WaitForChild(
    config.REMOTES.SKILL_REQUEST)
local channel = RS:WaitForChild("FourPlayerAggroChannel_TEMP")

channel.OnClientEvent:Connect(function(command)
    if command == "StrikeOnce" then
        attack:FireServer()
    elseif command == "Taunt" or command == "MageHeal" then
        skill:FireServer(command)
    elseif command == "Die" then
        local character = Players.LocalPlayer.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    end
end)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "FourPlayerAggroDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local channel = RS:WaitForChild("FourPlayerAggroChannel_TEMP")
local config = require(RS.Combat.Shared.CombatConfig)
local schema = require(RS.Core.Shared.ProfileSchema)
local progression = require(
    SSS.Core.Services.ProgressionRuntimeState)
local threat = require(SSS.Combat.ThreatService)
local ready = {}

channel.OnServerEvent:Connect(function(player, message)
    if message == "Ready" then
        ready[player.UserId] = true
    end
end)

-- Args:
--   condition: () -> any; server-observed combat condition.
--   label: string; context for a failed assertion.
--   seconds: number; maximum time permitted.
-- Returns:
--   any: first truthy observed value.
local function wait_for(condition, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local result = condition()
        if result then
            return result
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Four Player Aggro] TIMEOUT " .. label)
end

-- Args:
--   player: Player; real local Studio participant.
--   class_id: string; server-authorized class.
--   skills: {string}; learnable skills for this test class.
-- Returns:
--   nil: installs one disposable progression profile.
local function set_class(player, class_id, skills)
    local record = schema.create_default(player.UserId).Characters.Slot1
    record.Identity.RaceId = "Human"
    record.Identity.BaseClassId = class_id
    record.Identity.ClassId = class_id
    record.Identity.CreationStage = "Complete"
    if class_id == "Mage" then
        record.Equipment.Weapon = "apprentice_arcane_wand"
    end
    for index, skill_id in ipairs(skills) do
        record.Progression.Skills[skill_id] = {
            Known = true,
            PurchasedRank = 1,
        }
        record.Progression.Loadout[index] = skill_id
    end
    progression.set_character(player.UserId, record)
    for _, skill_id in ipairs(skills) do
        assert(progression.is_skill_usable(player.UserId, skill_id),
            "Real participant must be able to use " .. skill_id)
    end
end

-- Args:
--   player: Player; genuine Studio client.
-- Returns:
--   Model: living client character with safe disposable test health.
local function get_character(player)
    if not player.Character then
        player:LoadCharacter()
    end
    local character = wait_for(function()
        return player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
            and player.Character
    end, "client character", 30)
    character:SetAttribute("DungeonRunParticipant", false)
    character:SetAttribute("DungeonEncounterId", nil)
    local humanoid = assert(character:FindFirstChildOfClass("Humanoid"))
    humanoid.MaxHealth = 10000
    humanoid.Health = 10000
    return character
end

-- Args:
--   character: Model; living participant.
--   root: BasePart; live root of the chosen enemy.
--   z_offset: number; signed offset from the enemy.
-- Returns:
--   nil: positions one real client facing the enemy.
local function place(character, root, z_offset)
    local position = root.Position + Vector3.new(0, 0, z_offset)
    character.HumanoidRootPart.CFrame = CFrame.lookAt(
        position, root.Position)
end

-- Args:
--   player: Player; genuine client attacking the enemy.
--   character: Model; currently alive attacking character.
--   enemy: Model; authoritative enemy target.
-- Returns:
--   nil: confirms a real client hit, never test-injected damage.
local function strike_enemy(player, character, enemy)
    local root = assert(enemy:FindFirstChild("HumanoidRootPart"))
    place(character, root, -2.2)
    local previous = threat.get_threat(enemy, player.UserId)
    channel:FireClient(player, "StrikeOnce")
    wait_for(function()
        return threat.get_threat(enemy, player.UserId) > previous
    end, "genuine client strike " .. enemy.Name, 9)
end

-- Args: None.
-- Returns:
--   nil: proves real four-person and two-enemy support/aggro behavior.
local function run()
    local players = wait_for(function()
        local current = Players:GetPlayers()
        return if #current == 4 then current else nil
    end, "four independent Studio clients", 50)
    table.sort(players, function(a, b)
        return a.UserId < b.UserId
    end)
    for _, player in ipairs(players) do
        wait_for(function()
            return ready[player.UserId]
        end, "real client Ready " .. tostring(player.UserId), 25)
    end

    -- Keep the disposable clients dead until the wipe can be checked.
    Players.RespawnTime = 60

    local tank = players[1]
    local healer = players[2]
    local damage = players[3]
    local observer = players[4]
    set_class(tank, "Fighter", {"Taunt"})
    set_class(healer, "Mage", {"MageHeal"})
    set_class(damage, "Fighter", {"ShieldBash"})
    local tank_character = get_character(tank)
    local healer_character = get_character(healer)
    local damage_character = get_character(damage)
    local observer_character = get_character(observer)

    local enemy_a = wait_for(function()
        return Workspace:FindFirstChild(
            config.TRAINING_MARAUDER.MODEL_NAME)
    end, "first Marauder", 20)
    local enemy_b = wait_for(function()
        return Workspace:FindFirstChild("TrainingMarauder_2")
    end, "second Marauder", 20)
    for index = 3, 4 do
        local other = Workspace:FindFirstChild(
            "TrainingMarauder_" .. index)
        if other then
            other:PivotTo(CFrame.new(500 + index * 20, 5, 500))
        end
    end

    enemy_b:PivotTo(CFrame.new(400, 5, 400))
    threat.clear(enemy_a)
    threat.clear(enemy_b)
    local root = assert(enemy_a:FindFirstChild("HumanoidRootPart"))
    place(tank_character, root, 1.8)
    place(healer_character, root, 7)
    place(damage_character, root, -4.5)
    place(observer_character, root, -11)
    wait_for(function()
        return enemy_a:GetAttribute("MarauderAggroTargetUserId")
            == tank.UserId
    end, "nearest tank with four real candidates", 12)
    print("[Four Player Aggro] REAL_FOUR_CLIENT_FALLBACK_PASS")

    -- A moving enemy can leave the first real Taunt hit arc before
    -- its active sample. A legitimate miss consumes the skill cooldown.
    -- Retry from the current enemy root without bypassing that cooldown.
    for attempt = 1, 2 do
        place(tank_character, root, 2.2)
        channel:FireClient(tank, "Taunt")
        local deadline = os.clock() + 3
        repeat
            if threat.get_threat(enemy_a, tank.UserId) >= 15 then
                break
            end
            task.wait(0.1)
        until os.clock() >= deadline
        if threat.get_threat(enemy_a, tank.UserId) >= 15 then
            break
        end
        if attempt < 2 then
            task.wait(8.2)
        end
    end
    assert(threat.get_threat(enemy_a, tank.UserId) >= 15,
        "real fighter Taunt must engage enemy A")

    local tank_humanoid = assert(
        tank_character:FindFirstChildOfClass("Humanoid"))
    tank_humanoid:TakeDamage(120)
    place(healer_character, root, 7)
    channel:FireClient(healer, "MageHeal")
    wait_for(function()
        return threat.get_threat(enemy_a, healer.UserId) > 0
    end, "first real client Mage Heal creates threat", 12)
    assert(threat.get_threat(enemy_b, healer.UserId) == 0,
        "healing engaged enemy A cannot aggro idle enemy B")
    print("[Four Player Aggro] IDLE_ENEMY_ISOLATION_PASS")

    local second_root = assert(
        enemy_b:FindFirstChild("HumanoidRootPart"))
    enemy_b:PivotTo(CFrame.new(
        root.Position + Vector3.new(12, 0, 0)))
    threat.clear(enemy_b)
    strike_enemy(damage, damage_character, enemy_b)
    wait_for(function()
        return enemy_b:GetAttribute("MarauderAggroTargetUserId")
            == damage.UserId
    end, "independent real damage threat on enemy B", 9)
    assert(threat.get_threat(enemy_a, damage.UserId) == 0,
        "damage on enemy B cannot contaminate enemy A")
    print("[Four Player Aggro] REAL_SECOND_ENEMY_DAMAGE_PASS")

    -- The second real heal is cast only after the cooldown expires.
    task.wait(6.5)
    wait_for(function()
        return healer_character:GetAttribute("CombatState")
            == "Locomotion"
    end, "Mage Heal recovery before second client cast", 6)
    place(tank_character, root, 2.5)
    place(healer_character, root, 7)
    tank_humanoid:TakeDamage(120)
    local before_a = threat.get_threat(enemy_a, healer.UserId)
    local before_b = threat.get_threat(enemy_b, healer.UserId)
    channel:FireClient(healer, "MageHeal")
    wait_for(function()
        return threat.get_threat(enemy_a, healer.UserId) > before_a
            and threat.get_threat(enemy_b, healer.UserId) > before_b
    end, "effective real heal creates threat on both engaged mobs", 12)
    print("[Four Player Aggro] REAL_TWO_ENEMY_HEAL_PASS")

    -- The first Fighter Taunt has an eight-second server cooldown.
    -- Wait for it to expire before issuing another real skill request.
    task.wait(1.6)
    wait_for(function()
        return tank_character:GetAttribute("CombatState")
            == "Locomotion"
    end, "Fighter ready to retake aggro", 5)
    place(tank_character, root, 2.5)
    channel:FireClient(tank, "Taunt")
    wait_for(function()
        return threat.get_threat(enemy_a, tank.UserId)
            > threat.get_threat(enemy_a, healer.UserId)
            and enemy_a:GetAttribute("MarauderAggroTargetUserId")
                == tank.UserId
    end, "real tank retakes enemy A from healer", 12)
    print("[Four Player Aggro] REAL_TANK_RETAKE_PASS")

    channel:FireClient(healer, "Die")
    wait_for(function()
        local humanoid = healer_character:FindFirstChildOfClass(
            "Humanoid")
        return humanoid and humanoid.Health <= 0
    end, "healer death", 8)
    wait_for(function()
        return enemy_b:GetAttribute("MarauderAggroTargetUserId")
            == damage.UserId
    end, "dead healer removed from second enemy target candidates", 8)
    print("[Four Player Aggro] DEAD_HEALER_FALLBACK_PASS")

    -- Disconnect the real DPS client rather than calling the threat
    -- service's cleanup API directly. PlayerRemoving owns that path.
    damage:Kick("TEMP four-player threat cleanup acceptance")
    wait_for(function()
        return Players:GetPlayerByUserId(damage.UserId) == nil
    end, "real damage-player disconnect", 25)
    wait_for(function()
        return threat.get_threat(enemy_b, damage.UserId) == 0
            and threat.get_threat(enemy_a, damage.UserId) == 0
            and enemy_b:GetAttribute("MarauderAggroMode")
                == "Nearest"
    end, "departed DPS threat cleared from both real enemies", 10)
    assert(Players:GetPlayerByUserId(tank.UserId) == tank
        and Players:GetPlayerByUserId(observer.UserId) == observer,
        "disconnect cannot evict other living party members")
    print("[Four Player Aggro] REAL_DISCONNECT_CLEANUP_PASS")

    -- Genuine deaths of every remaining participant remove all
    -- target candidates. No direct threat.clear call is permitted
    -- until after the full-wipe state is verified.
    channel:FireClient(tank, "Die")
    channel:FireClient(observer, "Die")
    wait_for(function()
        for _, player in ipairs({tank, healer, observer}) do
            local character = player.Character
            local humanoid = character
                and character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health > 0 then
                return false
            end
        end
        return true
    end, "all connected players genuinely dead", 9)
    wait_for(function()
        return enemy_a:GetAttribute("MarauderAggroTargetUserId") == 0
            and enemy_b:GetAttribute("MarauderAggroTargetUserId") == 0
    end, "no living target survives the full wipe", 9)
    wait_for(function()
        return threat.get_threat(enemy_a, tank.UserId) == 0
            and threat.get_threat(enemy_a, healer.UserId) == 0
            and threat.get_threat(enemy_b, healer.UserId) == 0
    end, "enemy threat ledgers clear after full party wipe", 9)
    print("[Four Player Aggro] REAL_FULL_WIPE_THREAT_RESET_PASS")

    threat.clear(enemy_a)
    threat.clear(enemy_b)
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Four Player Aggro] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(145, function()
    STS:EndTest("FAIL four-player aggro global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        4, "FourPlayerAggroTwoEnemies_TEMP")
end)

driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Four-player aggro fixture failed: " .. tostring(result))
print("[Four Player Aggro] VERIFIED_FOUR_CLIENT_PASS")
