--!strict
-- Unpublished two-client proof of MageHeal and ArcaneWard threat.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Support threat Play requires an unpublished Studio place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "SupportThreatChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "SupportThreatClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local config = require(RS.Combat.Shared.CombatConfig)
local skill = RS.Combat.Remotes:WaitForChild(
    config.REMOTES.SKILL_REQUEST)
local channel = RS:WaitForChild("SupportThreatChannel_TEMP")

channel.OnClientEvent:Connect(function(skill_id)
    skill:FireServer(skill_id)
end)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "SupportThreatDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local channel = RS:WaitForChild("SupportThreatChannel_TEMP")
local config = require(RS.Combat.Shared.CombatConfig)
local ProfileSchema = require(RS.Core.Shared.ProfileSchema)
local Progression = require(
    SSS.Core.Services.ProgressionRuntimeState)
local Threat = require(SSS.Combat.ThreatService)
local Ward = require(SSS.Combat.WardService)
local ready = {}

channel.OnServerEvent:Connect(function(player, command)
    if command == "Ready" then
        ready[player.UserId] = true
    end
end)

-- Args:
--   predicate: () -> any; condition expected from authoritative state.
--   label: string; diagnostic name for a failure.
--   timeout: number; maximum waiting time in seconds.
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
    error("[Support Threat Live] TIMEOUT " .. label)
end

-- Args:
--   player: Player; genuine Studio participant.
--   class_id: string; server-authorized class.
--   skill_ids: {string}; skills needed for the fixture.
-- Returns:
--   nil: installs the local test character profile.
local function set_class(player, class_id, skill_ids)
    local character = ProfileSchema.create_default(
        player.UserId).Characters.Slot1
    character.Identity.RaceId = "Human"
    character.Identity.BaseClassId = class_id
    character.Identity.ClassId = class_id
    character.Identity.CreationStage = "Complete"
    if class_id == "Mage" then
        character.Equipment.Weapon = "apprentice_arcane_wand"
    end
    for index, skill_id in ipairs(skill_ids) do
        character.Progression.Skills[skill_id] = {
            Known = true,
            PurchasedRank = 1,
        }
        character.Progression.Loadout[index] = skill_id
    end
    Progression.set_character(player.UserId, character)
    for _, skill_id in ipairs(skill_ids) do
        assert(Progression.is_skill_usable(player.UserId, skill_id),
            "Fixture class must authorize " .. skill_id)
    end
end

-- Args:
--   player: Player; genuine client to initialize.
-- Returns:
--   Model: a living character with ample test health.
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
    local humanoid = assert(
        character:FindFirstChildOfClass("Humanoid"))
    humanoid.MaxHealth = 10000
    humanoid.Health = 10000
    return character
end

-- Args:
--   character: Model; genuine player combat character.
--   root: BasePart; enemy root used as positional reference.
--   distance: number; distance to the enemy on the Z axis.
-- Returns:
--   nil: places the character within melee or support reach.
local function place(character, root, distance)
    local position = root.Position + Vector3.new(0, 0, distance)
    character.HumanoidRootPart.CFrame = CFrame.lookAt(
        position, root.Position)
end

-- Args: None.
-- Returns:
--   nil: verifies real support skills against an active ordinary enemy.
local function run()
    local players = wait_for(function()
        local all = Players:GetPlayers()
        return if #all == 2 then all else nil
    end, "two real Studio clients", 35)
    table.sort(players, function(a, b)
        return a.UserId < b.UserId
    end)
    local mage = players[1]
    local fighter = players[2]
    for _, player in ipairs(players) do
        wait_for(function()
            return ready[player.UserId]
        end, "ready client " .. tostring(player.UserId), 20)
    end

    set_class(mage, "Mage", {"MageHeal", "ArcaneWard"})
    set_class(fighter, "Fighter", {"Taunt", "Mend"})
    local mage_character = get_character(mage)
    local fighter_character = get_character(fighter)

    local enemy = wait_for(function()
        return Workspace:FindFirstChild(
            config.TRAINING_MARAUDER.MODEL_NAME)
    end, "Training Marauder", 15)
    local root = assert(enemy:FindFirstChild("HumanoidRootPart"))
    for index = 2, 4 do
        local other = Workspace:FindFirstChild(
            config.TRAINING_MARAUDER.MODEL_NAME .. "_" .. index)
        if other and other:IsA("Model") then
            other:PivotTo(CFrame.new(500 + index * 20, 5, 500))
        end
    end
    Threat.clear(enemy)
    place(fighter_character, root, 2.5)
    place(mage_character, root, 7)
    wait_for(function()
        return enemy:GetAttribute("MarauderAggroTargetUserId")
            == fighter.UserId
    end, "nearest fighter", 12)

    -- The mobile Marauder may have chased the initial spawn point.
    -- Reacquire its live root before the real client melee hit window.
    place(fighter_character, root, 2.5)
    channel:FireClient(fighter, "Taunt")
    wait_for(function()
        return Threat.get_threat(enemy, fighter.UserId) >= 15
            and enemy:GetAttribute("MarauderAggroMode") == "Threat"
    end, "genuine client Taunt establishes engagement", 10)
    print("[Support Threat Live] REAL_TAUNT_ENGAGEMENT_PASS")

    local target_humanoid = assert(
        fighter_character:FindFirstChildOfClass("Humanoid"))
    target_humanoid:TakeDamage(120)
    wait_for(function()
        return target_humanoid.Health > 0
            and target_humanoid.Health < target_humanoid.MaxHealth
    end, "injured fighter health on server", 5)
    place(mage_character, root, 7)
    local healing_before = Threat.get_threat(enemy, mage.UserId)
    channel:FireClient(mage, "MageHeal")
    wait_for(function()
        return (fighter_character:GetAttribute(
            "MageHealLastAmount") or 0) > 0
            and Threat.get_threat(enemy, mage.UserId)
                > healing_before
    end, "real peer MageHeal applies and creates threat", 12)
    assert(Threat.get_threat(enemy, mage.UserId) >= 16,
        "effective MageHeal must create server-owned support threat")
    print("[Support Threat Live] REAL_PEER_HEAL_THREAT_PASS")

    -- Do not fire a second skill during MageHeal's Recovery state.
    -- Fill the recipient's health so delayed HoT ticks cannot masquerade
    -- as extra Ward-generated threat in the next assertion.
    wait_for(function()
        return mage_character:GetAttribute("CombatState")
            == "Locomotion"
    end, "MageHeal recovery completed", 5)
    target_humanoid.Health = target_humanoid.MaxHealth
    place(mage_character, root, 7)
    channel:FireClient(mage, "ArcaneWard")
    wait_for(function()
        return fighter_character:GetAttribute(
            "ArcaneWardSourceUserId") == mage.UserId
            and Ward.get_remaining(fighter_character) > 0
    end, "real peer ArcaneWard applied", 10)
    local ward_before = Ward.get_remaining(fighter_character)
    local threat_before = Threat.get_threat(enemy, mage.UserId)

    -- The fixture only forces the Fighter's server threat priority.
    -- The subsequent hit must come from the genuine attacking NPC.
    place(fighter_character, root, 2.5)
    Threat.taunt(enemy, fighter, 70)
    wait_for(function()
        return enemy:GetAttribute("MarauderAggroTargetUserId")
            == fighter.UserId
    end, "NPC turns toward Ward-protected Fighter", 5)
    wait_for(function()
        return Ward.get_remaining(fighter_character) < ward_before
            and Threat.get_threat(enemy, mage.UserId) > threat_before
    end, "genuine NPC attack is absorbed by client-cast Ward", 6)
    print("[Support Threat Live] REAL_NPC_WARD_ABSORB_THREAT_PASS")

    -- The Fighter's own client now channels real Mend pulses while
    -- the hostile enemy continues to track this encounter.
    wait_for(function()
        return fighter_character:GetAttribute("CombatState")
            == "Locomotion"
    end, "Fighter ready to channel Mend", 5)
    place(fighter_character, root, 3)
    target_humanoid:TakeDamage(120)
    assert(target_humanoid.Health > 0
        and target_humanoid.Health < target_humanoid.MaxHealth,
        "Mend requires a genuinely injured Fighter")
    local fighter_threat_before = Threat.get_threat(
        enemy, fighter.UserId)
    channel:FireClient(fighter, "Mend")
    wait_for(function()
        return Threat.get_threat(enemy, fighter.UserId)
            > fighter_threat_before
    end, "real Fighter Mend pulse generates support threat", 8)
    print("[Support Threat Live] REAL_FIGHTER_MEND_THREAT_PASS")

    Threat.clear(enemy)
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Support Threat Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(110, function()
    STS:EndTest("FAIL support threat global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        2, "SupportThreatTwoClient_TEMP")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()

assert(ok and result == "PASS",
    "Two-client support threat failed: " .. tostring(result))
print("[Support Threat Live] VERIFIED_MULTIPLAYER_PASS")
