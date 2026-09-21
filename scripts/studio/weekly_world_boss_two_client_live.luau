--!strict
-- Genuine two-client combat against one isolated guardian. All attacks
-- pass through the normal client CombatService attack RemoteEvent.
-- Only the disposable fixture issues the in-memory encounter directly.
assert(game.GameId == 0 and game.PlaceId == 0,
    "World-boss party Play requires an unpublished Studio place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "WorldBossPartyLiveChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "WorldBossPartyLiveClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local config = require(RS.Combat.Shared.CombatConfig)
local request = RS.Combat.Remotes:WaitForChild(
    config.REMOTES.ATTACK_REQUEST)
local skill_request = RS.Combat.Remotes:WaitForChild(
    config.REMOTES.SKILL_REQUEST)
local channel = RS:WaitForChild("WorldBossPartyLiveChannel_TEMP")

channel.OnClientEvent:Connect(function(kind)
    if kind == "Strike" then
        for _ = 1, 4 do
            request:FireServer()
            task.wait(0.7)
        end
    elseif kind == "Finish" then
        for _ = 1, 25 do
            request:FireServer()
            task.wait(0.65)
        end
    elseif kind == "PeerHeal" then
        skill_request:FireServer("MageHeal")
    elseif kind == "Die" then
        local player = game:GetService("Players").LocalPlayer
        local character = player.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0
        end
    elseif kind == "Leave" then
        game:GetService("StudioTestService"):LeaveTest()
    end
end)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "WorldBossPartyLiveDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local channel = RS:WaitForChild("WorldBossPartyLiveChannel_TEMP")
local RuntimeServices = require(SSS.Core.Services.RuntimeServices)
local Factory = require(SSS.Dungeon.DungeonWeeklyWorldBossFactory)
local DamageBridge = require(SSS.Dungeon.DungeonContributionBridge)
local Authority = require(SSS.WorldBoss.WorldBossCombatAuthority)
local Arena = require(SSS.WorldBoss.WorldBossArenaLayout)
local Lifecycle = require(SSS.WorldBoss.WorldBossMemberLifecycle)
local ProgressionRuntimeState = require(
    SSS.Core.Services.ProgressionRuntimeState
)
local ProfileSchema = require(
    RS.Core.Shared.ProfileSchema
)
local MageHealService = require(SSS.Combat.MageHealService)

local ready = {}
local departed = {}
Players.PlayerRemoving:Connect(function(player)
    departed[player.UserId] = true
end)
channel.OnServerEvent:Connect(function(player, kind)
    if kind == "Ready" then
        ready[player.UserId] = true
    end
end)

-- Args:
--   predicate: () -> any; condition to watch in real Studio play.
--   label: string; actionable timeout error context.
--   duration: number; maximum time to await the condition.
-- Returns:
--   any: first truthy observation of the expected condition.
local function wait_for(predicate, label, duration)
    local deadline = os.clock() + duration
    repeat
        local found = predicate()
        if found then
            return found
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[World Boss Party Live] TIMEOUT " .. label)
end

-- Args:
--   players: {Player}; real authenticated Studio test accounts.
--   runtime: any; authoritative shared in-memory service group.
-- Returns:
--   (string, Model): server-issued session ID and shared guardian.
local function prepare_party(players, runtime)
    local users = {}
    for _, player in ipairs(players) do
        assert(runtime.ProfileService:load(player.UserId))
        table.insert(users, player.UserId)
    end
    -- A detached test-only Mage identity equips an existing legitimate
    -- starter skill. The actual client must still pass combat checks.
    local caster = players[1]
    local mage = ProfileSchema.create_default(
        caster.UserId).Characters.Slot1
    mage.Identity.RaceId = "Human"
    mage.Identity.BaseClassId = "Mage"
    mage.Identity.ClassId = "Mage"
    mage.Identity.CreationStage = "Complete"
    mage.Equipment.Weapon = "apprentice_arcane_wand"
    mage.Progression.Skills.MageHeal = {
        Known = true, PurchasedRank = 1,
    }
    mage.Progression.Loadout[3] = "MageHeal"
    ProgressionRuntimeState.set_character(caster.UserId, mage)
    assert(ProgressionRuntimeState.is_skill_usable(
        caster.UserId, "MageHeal"),
        "existing authorized Mage Heal must be available")
    local session = assert(runtime.SessionService:create(
        "TestDungeon", users, 0, "WorldBossParty_TEMP", "Depth1"))
    local id = session.SessionId
    assert(runtime.SessionService:set_instance_state(id, {}).ok)
    for _, player in ipairs(players) do
        assert(runtime.SessionService:mark_connected(id, player.UserId).ok)
    end
    local now = os.time()
    assert(runtime.WeeklyWorldBossSessionBridge:issue(
        id, now - 10, now + 250).ok)
    local spawn = Arena.create(
        Workspace, "WorldBossPartyArena_TEMP")
    local boss = Factory.create({
        Parent = Workspace,
        SpawnCFrame = spawn.CFrame * CFrame.new(0, 5, -22),
        InstanceId = id,
        HealthMultiplier = 0.7,
    })
    local members = {}
    for _, player in ipairs(players) do
        members[player.UserId] = true
    end
    local authority = Authority.new(
        runtime.ContributionService,
        function()
            return {
                Boss = boss, SessionId = id,
                Admitted = members, Sessions = runtime.SessionService,
            }
        end)
    DamageBridge.bind_service(authority)
    DamageBridge.bind_damage_target_validator(function(context)
        return context.target == boss and context.attacker
            and members[context.attacker.UserId] == true
    end)
    return id, boss
end

-- Args:
--   players: {Player}; two real test clients with loaded profiles.
--   session_id: string; server-authorized shared boss encounter ID.
-- Returns:
--   nil: prepares normal combat on both independent player characters.
local function position_party(players, session_id)
    for index, player in ipairs(players) do
        local character = wait_for(function()
            return player.Character
                and player.Character:FindFirstChild("HumanoidRootPart")
                and player.Character
        end, "real character", 30)
        local humanoid = assert(
            character:FindFirstChildOfClass("Humanoid"))
        humanoid.MaxHealth = 10000
        humanoid.Health = 10000
        character:SetAttribute("DungeonRunParticipant", true)
        character:SetAttribute(
            "DungeonEncounterId", "WeeklyBoss:" .. session_id)
        character.HumanoidRootPart.CFrame = CFrame.lookAt(
            Vector3.new(0.5, 5, if index == 1 then 3 else -3),
            Vector3.new(0, 5, 0))
    end
end

-- Args:
--   players: {Player}; real caster and recipient for Mage Heal.
--   runtime: any; authoritative contribution and profile services.
--   session_id: string; shared frozen world-boss party session.
-- Returns:
--   nil: verifies effective peer healing via the actual skill RemoteEvent.
local function verify_peer_support(players, runtime, session_id)
    local caster = players[1]
    local recipient = players[2]
    local caster_character = assert(caster.Character)
    local recipient_character = assert(recipient.Character)
    local caster_humanoid = assert(
        caster_character:FindFirstChildOfClass("Humanoid"))
    local recipient_humanoid = assert(
        recipient_character:FindFirstChildOfClass("Humanoid"))
    local before = runtime.ContributionService
        :get_player_snapshot(session_id, caster.UserId)
    local previous_support = before.Support or 0

    caster_character.HumanoidRootPart.CFrame = CFrame.lookAt(
        Vector3.new(0, 5, 16), Vector3.new(0, 5, 14))
    recipient_character.HumanoidRootPart.CFrame = CFrame.lookAt(
        Vector3.new(0, 5, 13), Vector3.new(0, 5, 0))
    caster_humanoid.Health = caster_humanoid.MaxHealth
    recipient_humanoid.Health = recipient_humanoid.MaxHealth - 45
    task.wait(0.35)
    local selected = MageHealService.find_target(caster, 22)
    print("[World Boss Party Live] PEER_HEAL_TARGET "
        .. tostring(selected and selected.UserId)
        .. " expected " .. tostring(recipient.UserId)
        .. " casterHP " .. tostring(caster_humanoid.Health)
        .. " recipientHP " .. tostring(recipient_humanoid.Health)
        .. " positions "
        .. tostring(caster_character.HumanoidRootPart.Position)
        .. " " .. tostring(recipient_character.HumanoidRootPart.Position))
    channel:FireClient(caster, "PeerHeal")
    wait_for(function()
        local updated = runtime.ContributionService
            :get_player_snapshot(session_id, caster.UserId)
        return updated.ok and updated.Support > previous_support
            and recipient_humanoid.Health
                > recipient_humanoid.MaxHealth - 45
            and updated
    end, "real peer Mage Heal and server support contribution", 12)
    print("[World Boss Party Live] PEER_HEAL_SUPPORT_PASS")
    -- Restore the fixture's original melee combat identity. Equipping
    -- a Mage Wand for healing changes basic-attack behavior; the later
    -- shared-boss test intentionally proves the accepted melee path.
    ProgressionRuntimeState.set_character(
        caster.UserId,
        ProfileSchema.create_default(caster.UserId).Characters.Slot1
    )
    position_party(players, session_id)
    task.wait(1.5)
end

-- Args:
--   players: {Player}; authenticated users running CombatService.
--   runtime: any; server contribution and profile service group.
--   session_id: string; real frozen party session.
--   boss: Model; single shared guardian to defeat.
-- Returns:
--   nil: checks independent contribution and independent weekly pay.
local function verify_shared_completion(players, runtime, session_id, boss)
    for _, player in ipairs(players) do
        channel:FireClient(player, "Strike")
    end
    for _, player in ipairs(players) do
        wait_for(function()
            local result = runtime.ContributionService
                :get_player_snapshot(session_id, player.UserId)
            return result.ok and result.Damage > 0
        end, "independent real client damage " .. player.UserId, 15)
    end
    print("[World Boss Party Live] TWO_CLIENT_DAMAGE_PASS")
    for _, player in ipairs(players) do
        channel:FireClient(player, "Finish")
    end
    wait_for(function()
        return boss.Humanoid.Health <= 0
    end, "two real clients defeat one guardian", 35)
    local bridge = runtime.WeeklyWorldBossSessionBridge
    assert(bridge:record_defeat(session_id, boss).ok)
    for _, player in ipairs(players) do
        assert(runtime.SessionService:set_member_completion_eligibility(
            session_id, player.UserId, true).ok)
        local reward = bridge:grant_reward(
            session_id, player.UserId)
        assert(reward.ok and reward.gold_granted == 100,
            "every real contributor must receive their own reward")
        local duplicate = bridge:grant_reward(
            session_id, player.UserId)
        assert(duplicate.ok and duplicate.gold_granted == 0
            and duplicate.already_applied,
            "one character must never be paid twice this week")
    end
    print("[World Boss Party Live] SHARED_BOSS_DEFEAT_PASS")
    print("[World Boss Party Live] TWO_INDEPENDENT_REWARDS_PASS")
end

-- Args:
--   players: {Player}; real two-client party after boss defeat.
--   runtime: any; authoritative session/profiles for that party.
--   session_id: string; saved, already-defeated encounter identity.
-- Returns:
--   nil: verifies a real Humanoid death and automatic same-run respawn.
local function verify_death_and_respawn(players, runtime, session_id)
    local victim = players[1]
    local survivor = players[2]
    local lifecycle = Lifecycle.new(runtime.SessionService)
    local connection = lifecycle:bind_player(
        victim, session_id, CFrame.new(0, 5, 19), 1)
    local original = wait_for(function()
        local character = victim.Character
        return character and character:GetAttribute(
            "WorldBossSessionId") == session_id
            and character:FindFirstChildOfClass("Humanoid")
            and character
    end, "member lifecycle character", 15)
    local humanoid = assert(
        original:FindFirstChildOfClass("Humanoid"))
    assert(original:IsDescendantOf(Workspace),
        "the real Studio character must exist in Workspace")
    assert(humanoid.Health > 0,
        "fresh member character must start alive")
    humanoid.Died:Connect(function()
        print("[World Boss Party Live] HUMANOID_DIED_SIGNAL")
    end)
    -- Ask the real owning Studio client to die. This exercises the
    -- replicated Humanoid.Died signal rather than mutating session mode.
    channel:FireClient(victim, "Die")
    wait_for(function()
        return humanoid.Health <= 0
    end, "client-replicated Humanoid death", 8)
    print("[World Boss Party Live] CLIENT_DEATH_REPLICATED")
    wait_for(function()
        local record = runtime.SessionService:get(session_id)
        return record and record.Members[tostring(victim.UserId)]
            .Mode == "Dead"
    end, "authoritative dead session mode", 8)
    assert(Players:GetPlayerByUserId(survivor.UserId) == survivor,
        "one member's death must not evict their surviving peer")
    local recovered = wait_for(function()
        local character = victim.Character
        local record = runtime.SessionService:get(session_id)
        if character and character ~= original and record
            and character:GetAttribute("WorldBossSessionId")
                == session_id
            and record.Members[tostring(victim.UserId)]
                .Mode == "Active"
        then
            return character
        end
        return nil
    end, "fresh character in same active boss session", 15)
    assert(recovered ~= original
        and runtime.SessionService:get_for_user(victim.UserId)
            .SessionId == session_id,
        "respawn must retain original session identity")
    local replay = runtime.WeeklyWorldBossSessionBridge
        :grant_reward(session_id, victim.UserId)
    assert(replay.ok and replay.already_applied
        and replay.gold_granted == 0,
        "dying and respawning after victory cannot grant again")
    connection:Disconnect()
    print("[World Boss Party Live] MEMBER_DEATH_RESPAWN_PASS")
end

-- Args:
--   players: {Player}; two real clients after the shared defeat.
--   runtime: any; server-owned profiles and session authority.
--   session_id: string; already defeated weekly encounter.
-- Returns:
--   nil: disconnects one client and proves other remains unaffected.
local function verify_peer_departure(players, runtime, session_id)
    local leaving = players[1]
    local staying = players[2]
    channel:FireClient(leaving, "Leave")
    wait_for(function()
        return departed[leaving.UserId]
    end, "actual first-client network departure", 20)
    assert(Players:GetPlayerByUserId(staying.UserId) == staying,
        "one client departure cannot evict the surviving party member")
    local snapshot = runtime.ContributionService
        :get_player_snapshot(session_id, leaving.UserId)
    assert(snapshot.ok and snapshot.Damage > 0,
        "departed contributor's completed damage remains persisted")
    local reward = runtime.WeeklyWorldBossSessionBridge
        :grant_reward(session_id, staying.UserId)
    assert(reward.ok and reward.already_applied
        and reward.gold_granted == 0,
        "survivor cannot reclaim the same weekly reward")
    print("[World Boss Party Live] PEER_DISCONNECT_PASS")
    print("[World Boss Party Live] SAME_ACCOUNT_NETWORK_REJOIN_NOT_TESTED")
end

-- Args: None.
-- Returns:
--   nil: completes a two-client combat/party/reward/recovery fixture.
local function run()
    local players = wait_for(function()
        local current = Players:GetPlayers()
        return if #current == 2 then current else nil
    end, "two real Studio clients", 35)
    for _, player in ipairs(players) do
        wait_for(function()
            return ready[player.UserId]
        end, "ready combat client " .. player.UserId, 20)
    end
    local runtime = RuntimeServices.new("Dungeon")
    local session_id, boss = prepare_party(players, runtime)
    position_party(players, session_id)
    task.wait(2)
    verify_peer_support(players, runtime, session_id)
    verify_shared_completion(players, runtime, session_id, boss)
    verify_death_and_respawn(players, runtime, session_id)
    verify_peer_departure(players, runtime, session_id)
    boss:Destroy()
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[World Boss Party Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(130, function()
    STS:EndTest("FAIL party fixture global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        2, "WorldBossTwoClientCombat_TEMP")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Two-client world boss Play failed: " .. tostring(result))
print("[World Boss Party Live] VERIFIED_MULTIPLAYER_PASS")
