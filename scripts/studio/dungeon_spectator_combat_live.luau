--!strict
-- Real two-client Studio proof: returning spectators cannot fight.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Spectator combat test requires an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local runtime_script = SSS.Dungeon.DungeonRuntime

-- Args:
--   target: LuaSourceContainer; disposable Studio runtime script.
--   original: string; unique source anchor to replace.
--   replacement: string; local-only fixture source.
-- Returns:
--   nil: changes one anchor or raises if the source has drifted.
local function replace_once(target, original, replacement)
    local source = target.Source
    local position = assert(string.find(source, original, 1, true),
        "Spectator fixture source anchor missing")
    assert(not string.find(
        source, original, position + #original, true
    ), "Spectator fixture source anchor ambiguous")
    target.Source = string.sub(source, 1, position - 1)
        .. replacement .. string.sub(source, position + #original)
end

local context = Instance.new("ModuleScript")
context.Name = "DungeonSpectatorContext_TEMP"
context.Source = "return {}"
context.Parent = SSS.Dungeon
replace_once(
    runtime_script,
    'local runtime = RuntimeServices.new("Dungeon")',
    'local runtime = RuntimeServices.new("Dungeon")\n'
        .. 'require(script.Parent.DungeonSpectatorContext_TEMP)'
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
channel.Name = "DungeonSpectatorCombatChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "DungeonSpectatorCombatClient_TEMP"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("DungeonSpectatorCombatChannel_TEMP")
local combat = RS.Combat
local config = require(combat.Shared.CombatConfig)
local remotes = combat.Remotes
local validation = remotes:WaitForChild(
    config.REMOTES.VALIDATION_EVENT
)
local attack = remotes:WaitForChild(config.REMOTES.ATTACK_REQUEST)
local skill = remotes:WaitForChild(config.REMOTES.SKILL_REQUEST)
local defense = remotes:WaitForChild(config.REMOTES.DEFENSE_REQUEST)
local seen = {}

-- Args:
--   payload: any; actual server-authored combat validation result.
-- Returns:
--   nil: acknowledges each distinct rejected spectator action.
local function on_validation(payload)
    if type(payload) ~= "table"
        or payload.outcome ~= "REJECT"
        or payload.detail ~= "DungeonMemberNotActive"
    then
        return
    end
    seen[payload.event] = true
    if seen.ATTACK and seen.SKILL and seen.DEFENSE then
        channel:FireServer("DENIED")
    end
end

validation.OnClientEvent:Connect(on_validation)
channel.OnClientEvent:Connect(function(command)
    if command ~= "ATTEMPT" then
        return
    end
    local player = Players.LocalPlayer
    assert(player:GetAttribute(
        config.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
    ) == false, "Spectator must not have combat permission")
    attack:FireServer("Basic")
    skill:FireServer("Taunt")
    defense:FireServer("BlockStart")
end)
channel:FireServer("READY")
]==]
client.Parent = game:GetService("StarterPlayer").StarterPlayerScripts

local driver = Instance.new("Script")
driver.Name = "DungeonSpectatorCombatDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local channel = RS:WaitForChild("DungeonSpectatorCombatChannel_TEMP")
local context = require(
    script.Parent.Dungeon.DungeonSpectatorContext_TEMP
)
local config = require(RS.Combat.Shared.CombatConfig)
local damage = require(SSS.Combat.DamageService)
local responses = {}

channel.OnServerEvent:Connect(function(player, command)
    responses[tostring(player.UserId) .. ":" .. command] = true
end)

-- Args:
--   predicate: () -> any; authoritative server-owned state.
--   label: string; diagnostic for a failed transition.
--   seconds: number; maximum time before a useful failure.
-- Returns:
--   any: first truthy observation.
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Spectator Combat Live] TIMEOUT " .. label)
end

-- Args:
--   player: Player; admitted real Studio participant.
-- Returns:
--   Model?: current living character model.
local function living_character(player)
    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    return if humanoid and humanoid.Health > 0
        and character:FindFirstChild("HumanoidRootPart")
        then character else nil
end

-- Args:
--   player: Player; actual participant whose character dies.
-- Returns:
--   nil: causes a genuine server-side character death.
local function kill_character(player)
    local character = assert(living_character(player))
    character:FindFirstChildOfClass("Humanoid").Health = 0
end

-- Args:
--   attacker: Player; server-owned participant in test.
--   target: Model; disposable test target.
-- Returns:
--   number: actual authoritative damage application.
local function apply_test_damage(attacker, target)
    return damage.apply_damage({
        attacker = attacker,
        attacker_character = attacker.Character,
        target = target,
        source_kind = "Melee",
        source_id = "SpectatorContract_TEMP",
        attack_id = "Slash1",
        base_damage = 10,
        multiplier = 1,
    })
end

-- Args: None.
-- Returns:
--   nil: exercises real client commands after a server-owned death.
local function run()
    local players = wait_for(function()
        local current = Players:GetPlayers()
        return if #current == 2 then current else nil
    end, "two real clients", 45)
    table.sort(players, function(a, b)
        return a.UserId < b.UserId
    end)
    Players.RespawnTime = 90
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
                or not living_character(player)
                or not responses[tostring(player.UserId) .. ":READY"]
            then
                return nil
            end
        end
        return current
    end, "two admitted and UI-ready dungeon members", 70)

    local spectator = players[1]
    local active_peer = players[2]
    local initial = assert(living_character(spectator))
    kill_character(spectator)
    wait_for(function()
        local member = sessions:get(session.SessionId)
            .Members[tostring(spectator.UserId)]
        return member.FreeReviveUsed == true
            and member.Mode == "Active"
            and living_character(spectator) ~= initial
    end, "automatic free revive restores one character", 25)

    kill_character(spectator)
    wait_for(function()
        local member = sessions:get(session.SessionId)
            .Members[tostring(spectator.UserId)]
        return member.Mode == "Spectating"
            and member.FreeReviveUsed == true
            and spectator:GetAttribute(
                config.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
            ) == false
    end, "exhausted member becomes combat-ineligible", 12)

    -- This manual LoadCharacter simulates a freshly created character
    -- on readmission. It is not a genuine network reconnect.
    local dead_character = spectator.Character
    spectator:LoadCharacter()
    local new_character = wait_for(function()
        local character = living_character(spectator)
        return if character and character ~= dead_character
            and character:GetAttribute(
                config.TRAINING_MARAUDER.RUN_PARTICIPANT_ATTRIBUTE
            ) == false then character else nil
    end, "spectator character must remain combat-ineligible", 18)
    assert(new_character ~= dead_character,
        "A newly created character cannot reset the member's death mode")
    assert(
        sessions:get(session.SessionId)
            .Members[tostring(spectator.UserId)].Mode
                == "Spectating",
        "New character cannot switch the server-owned spectator to Active"
    )
    print("[Spectator Combat Live] RECREATED_SPECTATOR_PASS")

    local target = Instance.new("Model")
    target.Name = "SpectatorDamageProbe_TEMP"
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 100
    humanoid.Health = 100
    humanoid.Parent = target
    target.Parent = workspace

    local forbidden_damage = apply_test_damage(spectator, target)
    assert(forbidden_damage == 0 and humanoid.Health == 100,
        "Spectator damage callback must apply zero damage")
    assert(active_peer:GetAttribute(
        config.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
    ) == true, "An active peer must remain combat-eligible")
    assert(apply_test_damage(active_peer, target) > 0,
        "Spectator gate must not disable active party damage")
    target:Destroy()
    print("[Spectator Combat Live] DAMAGE_GATE_PASS")

    channel:FireClient(spectator, "ATTEMPT")
    wait_for(function()
        return responses[tostring(spectator.UserId) .. ":DENIED"]
    end, "all real spectator attack/skill/defense remotes rejected", 12)
    assert(sessions:get(session.SessionId).State == "Active",
        "One exhausted spectator must not fail the active peer's run")
    print("[Spectator Combat Live] CLIENT_ACTIONS_REJECTED_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Spectator Combat Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(125, function()
    STS:EndTest("FAIL spectator fixture global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        2, "DungeonSpectatorCombat_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
context:Destroy()
assert(ok and result == "PASS",
    "Two-client spectator combat Play failed: " .. tostring(result))
print("[Spectator Combat Live] VERIFIED_MULTIPLAYER_PASS")
