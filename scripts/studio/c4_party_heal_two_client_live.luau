--!strict
-- Actual unpublished two-client Dungeon Party Heal combat playtest.
-- Test-only edits touch a disposable DataModel, never the repository.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Party Heal multiplayer test requires an unpublished local Dungeon.")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")
assert(SSS:FindFirstChild("Dungeon") and SSS:FindFirstChild("Combat"),
    "Party Heal multiplayer test requires real Dungeon combat.")

--[[
Instruments an exact source anchor only in the disposable test place.

Args:
    owner (LuaSourceContainer): Test DataModel's runtime script.
    original (string): Unique existing source span to replace.
    replacement (string): Test-only session setup or service exposure.

Returns:
    nil: Raises if the approved one-time test anchor changed.
]]
local function replace_once(
    owner: any, original: string, replacement: string
)
    local source = owner.Source
    local first = assert(string.find(source, original, 1, true),
        "Missing Dungeon playtest instrumentation anchor")
    assert(not string.find(source, original, first + #original, true),
        "Ambiguous Dungeon playtest instrumentation anchor")
    owner.Source = string.sub(source, 1, first - 1)
        .. replacement .. string.sub(source, first + #original)
end

local dungeon = SSS.Dungeon.DungeonRuntime
local runtime_anchor = 'local runtime = RuntimeServices.new("Dungeon")'
replace_once(dungeon, runtime_anchor, runtime_anchor
    .. '\n_G.C4PartyLiveRuntime_TEMP = runtime')
local roster_anchor = [[local function current_session(): any?
    return if active_session_id then sessions:get(active_session_id) else nil
end]]
replace_once(dungeon, roster_anchor, roster_anchor
    .. '\n_G.C4PartyLiveSession_TEMP = current_session')
local studio_anchor = [[local studio = StudioSessionFactory.create_for_players(
            {player},]]
replace_once(dungeon, studio_anchor,
    [[repeat task.wait(0.1) until #Players:GetPlayers() == 2
        local studio = StudioSessionFactory.create_for_players(
            Players:GetPlayers(),]])

local channel = Instance.new("RemoteEvent")
channel.Name = "C4PartyHealLiveChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "C4PartyHealLiveClient_TEMP"
client.Source = [==[
local channel = game:GetService("ReplicatedStorage")
    :WaitForChild("C4PartyHealLiveChannel_TEMP")
local skill = game:GetService("ReplicatedStorage")
    .Combat.Remotes:WaitForChild("SkillRequest")
channel.OnClientEvent:Connect(function(action)
    if action == "Cast" then
        skill:FireServer("MysticPartyHeal")
        channel:FireServer("CastSent")
    end
end)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "C4PartyHealLiveDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Combat = SSS.Combat
local Shared = RS.Core.Shared
local CombatShared = RS.Combat.Shared

local PartyHeal = require(Combat.PartyHealService)
local Threat = require(Combat.ThreatService)
local RuntimeState = require(SSS.Core.Services.ProgressionRuntimeState)
local CombatConfig = require(CombatShared.CombatConfig)
local channel = RS:WaitForChild("C4PartyHealLiveChannel_TEMP")
local ready = {}
local cast_sent = {}

channel.OnServerEvent:Connect(function(player, action)
    if action == "Ready" then
        ready[player.UserId] = true
    elseif action == "CastSent" then
        cast_sent[player.UserId] = true
    end
end)

--[[
Waits for a bounded real-client or server-owned Dungeon condition.

Args:
    condition (() -> any): Current real gameplay state to check.
    label (string): Stage used for actionable failure.
    seconds (number): Bounded real-play wait.

Returns:
    any: First truthy result or an explicit timeout.
]]
local function wait_for(condition, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local result = condition()
        if result then return result end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[C4 Party Heal Live] TIMEOUT " .. label)
end

--[[
Makes one admitted Studio Mystic eligible for an authentic ranked cast.

Args:
    runtime (any): Live Dungeon profile authority.
    player (Player): Connected original Dungeon session member.

Returns:
    nil: Seeds only disposable Studio session progression.
]]
local function seed_mystic(runtime, player)
    assert(runtime.ProfileService:mutate(player.UserId, function(profile)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1, RaceId = "Human",
            BaseClassId = "Mage", ClassId = "Mage",
            CreationStage = "Complete",
        }
        character.Level = 14
        character.Equipment.Weapon = "apprentice_arcane_wand"
        character.Equipment.Body = "apprentice_mystic_robe"
        character.Progression.Skills.MageHeal = {
            Known = true, PurchasedRank = 1, Proficiency = 0,
        }
        character.Progression.Skills.MysticHealingPrayer = {
            Known = true, PurchasedRank = 3, Proficiency = 260,
        }
        character.Progression.Skills.MysticPartyHeal = {
            Known = true, PurchasedRank = 3, Proficiency = 140,
        }
        character.Progression.Loadout[1] = "MysticPartyHeal"
    end), "Failed to seed test Mystic progression")
    RuntimeState.set_character(player.UserId,
        assert(runtime.ProfileService:get_character(player.UserId, 1)))
end

--[[
Positions two real Dungeon clients without interrupting their lifecycle.

Args:
    player (Player): Actual spawned and admitted Dungeon member.
    location (CFrame): Safe common test-room position.
    health_missing (number): Damage to apply before group heal.

Returns:
    Humanoid: Living injured target ready for the genuine client cast.
]]
local function position_injured(player, location, health_missing)
    local character = player.Character or player.CharacterAdded:Wait()
    local root = assert(character:WaitForChild("HumanoidRootPart", 25))
    local humanoid = assert(character:WaitForChild("Humanoid", 25))
    root.Anchored = true
    root.CFrame = location
    humanoid.Health = math.max(1, humanoid.MaxHealth - health_missing)
    return humanoid
end

--[[
Proves party eligibility, two real HP grants and healing-generated threat.

Args:
    players ({Player}): Two admitted authentic Dungeon members.
    runtime (any): Live session and player profile authority.
    session (any): The actual shared active Dungeon session.

Returns:
    nil: Rejects stranger/solo use and checks client remote group healing.
]]
local function verify_party_heal(players, runtime, session)
    local caster = players[1]
    local ally = players[2]
    seed_mystic(runtime, caster)
    local usable, reason = RuntimeState.is_skill_usable(
        caster.UserId, "MysticPartyHeal"
    )
    assert(usable, "Actual ranked party heal unusable: " .. tostring(reason))

    local base_position = CFrame.new(0, 100, 0)
    local first = position_injured(caster, base_position, 70)
    local second = position_injured(
        ally, base_position * CFrame.new(5, 0, 0), 70
    )
    local first_before = first.Health
    local second_before = second.Health
    assert(PartyHeal.has_injured_member(caster, 24),
        "Real authoritative shared party lacks eligible injured members")

    local enemy = Instance.new("Model")
    enemy.Name = "C4PartyHealThreatEnemy_TEMP"
    enemy.Parent = workspace
    Threat.select_target(enemy, {
        {player = caster, distance = 5},
        {player = ally, distance = 5},
    })
    Threat.record_damage(enemy, ally, 1)

    channel:FireClient(caster, "Cast")
    wait_for(function() return cast_sent[caster.UserId] end,
        "real Mystic client sent party-heal request", 25)
    -- Roblox's ordinary passive regeneration may add 1 HP before
    -- the skill's wind-up ends. Wait for the actual rank-three heal,
    -- rather than mistaking background regeneration for successful
    -- two-target casting.
    wait_for(function()
        return first.Health - first_before >= 50
            and second.Health - second_before >= 50
    end, "both live party members received rank-three HP", 15)
    local first_gain = first.Health - first_before
    local second_gain = second.Health - second_before
    print(("[C4 Party Heal Live] HEAL_DIAGNOSTIC "
        .. "caster=%.2f/%.2f ally=%.2f/%.2f "
        .. "rank=%d multiplier=%.3f")
        :format(first_gain, first.MaxHealth, second_gain,
            second.MaxHealth, RuntimeState.get_skill_rank(
                caster.UserId, "MysticPartyHeal"
            ), RuntimeState.get_heal_multiplier(caster.UserId)))
    assert(first_gain >= 50 and second_gain >= 50,
        "Rank-three party healing did not restore both members")
    assert(Threat.get_threat(enemy, caster.UserId) > 0,
        "Effective multi-target HP restoration produced no NPC threat")
    print("[C4 Party Heal Live] TWO_CLIENT_HEAL_AND_THREAT_PASS")

    -- The same remote cannot immediately recast through its cooldown.
    channel:FireClient(caster, "Cast")
    task.wait(0.5)
    assert(first.Health - first_before <= 56.1
        and second.Health - second_before <= 56.1,
        "Repeat client request bypassed party-heal cooldown")
    print("[C4 Party Heal Live] COOLDOWN_PASS")

    local muted = runtime.SessionService:set_member_mode(
        session.SessionId, ally.UserId, "Spectating"
    )
    assert(muted.ok, "Could not isolate a spectator test member")
    assert(not PartyHeal.has_injured_member(caster, 24),
        "Solo active member incorrectly qualifies as a party")
    assert(not select(1, PartyHeal.cast(
        caster, 56, 24, "MysticPartyHeal"
    )), "Spectating party member received forbidden healing")
    print("[C4 Party Heal Live] SPECTATOR_AND_SOLO_DENIAL_PASS")
    Threat.clear(enemy)
    enemy:Destroy()
end

--[[
Runs the real two-client Dungeon session end-to-end healer playtest.

Args:
    None.

Returns:
    nil: Ends the unpublished multiplayer session on success or failure.
]]
local function main()
    local players = wait_for(function()
        local current = Players:GetPlayers()
        return if #current == 2 then current else nil
    end, "two actual Studio clients", 45)
    local runtime = wait_for(function()
        return _G.C4PartyLiveRuntime_TEMP
    end, "live Dungeon service composition", 35)
    local session = wait_for(function()
        local fetch = _G.C4PartyLiveSession_TEMP
        local current = fetch and fetch()
        return if current and current.State == "Active"
            then current else nil
    end, "shared active authoritative Dungeon session", 60)
    for _, player in ipairs(players) do
        wait_for(function()
            local latest = _G.C4PartyLiveSession_TEMP()
            local member = latest and latest.Members[tostring(player.UserId)]
            return ready[player.UserId]
                and runtime.ProfileService:get_character(player.UserId, 1)
                and member and member.Mode == "Active"
                and member.Connected == true
                and player:GetAttribute(
                    CombatConfig.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
                ) == true
                and player.Character
                and player.Character:FindFirstChild("HumanoidRootPart")
        end, "both server-admitted party members", 60)
    end
    print("[C4 Party Heal Live] REAL_TWO_MEMBER_SESSION_PASS")
    verify_party_heal(players, runtime,
        assert(_G.C4PartyLiveSession_TEMP()))
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[C4 Party Heal Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(180, function()
    STS:EndTest("FAIL C4 party heal global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        2, "C4PartyHealRealDungeon_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Real two-client party-heal test failed: " .. tostring(result))
print("[C4 Party Heal Live] VERIFIED_TWO_CLIENT_PARTY_HEAL_PASS")
