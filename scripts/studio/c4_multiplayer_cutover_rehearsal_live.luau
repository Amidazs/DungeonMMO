--!strict
-- Bounded unpublished two-client rehearsal for the final C4 cutover gate.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "C4 multiplayer cutover rehearsal requires an unpublished Dungeon place"
)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local StarterPlayer = game:GetService("StarterPlayer")
local StudioTestService = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local runtime_source = ServerScriptService.Dungeon.DungeonRuntime
local starter_scripts = StarterPlayer.StarterPlayerScripts

--[[
Replaces one audited DungeonRuntime source span in the disposable Studio copy.

Args:
    original (string): Exact source text expected once.
    replacement (string): Test-only replacement.

Returns:
    nil: Mutates only the in-memory unpublished test place.
]]
local function replace_once(
    original: string,
    replacement: string
)
    local source = runtime_source.Source
    local first = assert(
        string.find(source, original, 1, true),
        "C4 multiplayer rehearsal source anchor missing"
    )

    assert(
        not string.find(
            source,
            original,
            first + #original,
            true
        ),
        "C4 multiplayer rehearsal source anchor ambiguous"
    )

    runtime_source.Source = source:sub(1, first - 1)
        .. replacement
        .. source:sub(first + #original)
end

replace_once(
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
Workspace:SetAttribute("DungeonMMOStudioBaseClass", "Mage")
Workspace:SetAttribute(
    "DungeonMMOPlaceholderPhysicalContentEnabled",
    true
)
Workspace:SetAttribute(
    "DungeonMMOPlaceholderPlayableEnabled",
    true
)

local channel = Instance.new("RemoteEvent")
channel.Name = "C4MultiplayerCutoverChannel_TEMP"
channel.Parent = ReplicatedStorage

local client = Instance.new("LocalScript")
client.Name = "C4MultiplayerCutoverClient_TEMP"
client.Source = [==[
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local input = require(
    script.Parent:WaitForChild("Combat"):WaitForChild(
        "CombatInputActions"
    )
)
local channel = ReplicatedStorage:WaitForChild(
    "C4MultiplayerCutoverChannel_TEMP"
)

channel.OnClientEvent:Connect(function(command)
    if command == "ATTACK" then
        local accepted = input.begin_attack()
        channel:FireServer("ATTACK_RESULT", accepted)
    end
end)

channel:FireServer("READY")
]==]
client.Parent = starter_scripts

local driver = Instance.new("Script")
driver.Name = "C4MultiplayerCutoverServer_TEMP"
driver.Source = [==[
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local StudioTestService = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local ThreatService = require(
    ServerScriptService.Combat.ThreatService
)

local channel = ReplicatedStorage:WaitForChild(
    "C4MultiplayerCutoverChannel_TEMP"
)
local bridge = ServerStorage:WaitForChild(
    "C4CombatCutoverRehearsalBridge"
)

local TEST_TIMEOUT = 145
local responses = {}

channel.OnServerEvent:Connect(function(player, command, value)
    responses[tostring(player.UserId) .. ":" .. command] =
        if value == nil then true else value
end)

--[[
Waits for one live authoritative condition with a bounded timeout.

Args:
    callback (() -> any): Predicate returning a truthy ready value.
    label (string): Diagnostic label used on timeout.
    seconds (number): Maximum wall-clock wait.

Returns:
    any: First truthy predicate value.
]]
local function wait_for(
    callback,
    label,
    seconds
)
    local deadline = os.clock() + seconds

    repeat
        local result = callback()
        if result then
            return result
        end
        task.wait(0.1)
    until os.clock() >= deadline

    error("[C4 Multiplayer Cutover] TIMEOUT " .. label)
end

--[[
Returns one physical environment anchor by stable AnchorId.

Args:
    anchor_id (string): Expected Dungeon environment anchor ID.

Returns:
    BasePart: Matching live physical anchor.
]]
local function environment_anchor(anchor_id)
    return wait_for(function()
        for _, part in ipairs(
            CollectionService:GetTagged(
                "DungeonMMOEnvironmentAnchor"
            )
        ) do
            if part:GetAttribute("AnchorId") == anchor_id
                and part:IsA("BasePart")
            then
                return part
            end
        end
        return nil
    end, anchor_id, 25)
end

--[[
Returns two fully admitted connected Studio players.

Args:
    None.

Returns:
    {Player}: Two players ordered by UserId for deterministic evidence.
]]
local function admitted_players()
    local players = wait_for(function()
        local current = Players:GetPlayers()
        if #current ~= 2 then
            return nil
        end

        for _, player in ipairs(current) do
            local ready_key =
                tostring(player.UserId) .. ":READY"
            local character = player.Character
            local humanoid = character
                and character:FindFirstChildOfClass("Humanoid")
            local root = character
                and character:FindFirstChild("HumanoidRootPart")

            if player:GetAttribute("DungeonCombatAllowed") ~= true
                or not responses[ready_key]
                or not humanoid
                or humanoid.Health <= 0
                or not root
            then
                return nil
            end
        end

        return current
    end, "two admitted real clients", 75)

    table.sort(players, function(left, right)
        return left.UserId < right.UserId
    end)

    return players
end

--[[
Prevents unrelated NPC retaliation from ending this bounded cutover rehearsal.

The ForceField affects only disposable Studio player characters. Player attacks
against the reviewed NPC still travel through the real combat input and damage
pipeline.

Args:
    players ({Player}): Two admitted Studio participants.

Returns:
    nil: Adds invisible temporary ForceFields to current characters.
]]
local function protect_players(players)
    for _, player in ipairs(players) do
        local character = assert(player.Character)
        local protection = Instance.new("ForceField")
        protection.Name = "C4MultiplayerCutoverProtection_TEMP"
        protection.Visible = false
        protection.Parent = character
    end
end

--[[
Starts the first physical room and returns one living reviewed NPC.

Args:
    players ({Player}): Two admitted Dungeon participants.

Returns:
    Model: One living room-one NPC with a real Humanoid.
]]
local function enter_room_one(players)
    local trigger = environment_anchor("Temple.Room1.Trigger")

    for index, player in ipairs(players) do
        local root = player.Character.HumanoidRootPart
        root.CFrame = trigger.CFrame
            * CFrame.new((index - 1.5) * 3, 0, 8)
        task.wait(0.15)
        player.Character:FindFirstChildOfClass("Humanoid"):MoveTo(
            trigger.Position + Vector3.new(0, 0, -2)
        )
    end

    local enemy_folder = wait_for(function()
        local runtime = Workspace:FindFirstChild(
            "DungeonGameplayRuntime"
        )
        return runtime
            and runtime:FindFirstChild("DungeonEnemies")
    end, "Dungeon enemy folder", 20)

    local enemy = wait_for(function()
        for _, candidate in ipairs(enemy_folder:GetChildren()) do
            local humanoid =
                candidate:FindFirstChildOfClass("Humanoid")
            if candidate:IsA("Model")
                and humanoid
                and humanoid.Health > 0
                and candidate.PrimaryPart
            then
                return candidate
            end
        end
        return nil
    end, "living room-one NPC", 20)

    enemy.PrimaryPart.Anchored = true
    return enemy
end

--[[
Places one player in legal melee range facing the rehearsal NPC.

Args:
    player (Player): Connected client whose real input will be used.
    enemy (Model): Living physical NPC.

Returns:
    nil: Repositions only the disposable Studio character.
]]
local function face_enemy(player, enemy)
    local root = player.Character.HumanoidRootPart
    local target_position = enemy.PrimaryPart.Position
    root.CFrame = CFrame.lookAt(
        target_position + Vector3.new(0, 0, 4),
        target_position
    )
end

--[[
Sends one real existing client basic attack and waits for NPC HP to fall.

Args:
    player (Player): Client that must issue CombatInputActions.begin_attack().
    enemy (Model): Physical target receiving authoritative damage.
    label (string): Diagnostic label for this strike.

Returns:
    number: Positive real NPC health damage from the strike.
]]
local function client_attack(player, enemy, label)
    face_enemy(player, enemy)

    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    local before = humanoid.Health
    local key = tostring(player.UserId) .. ":ATTACK_RESULT"
    responses[key] = nil

    channel:FireClient(player, "ATTACK")

    local accepted = wait_for(function()
        return responses[key]
    end, label .. " client request", 12)
    assert(
        accepted == true,
        label .. " was rejected by existing client combat input"
    )

    wait_for(function()
        return humanoid.Health < before
    end, label .. " NPC damage", 15)

    local applied = before - humanoid.Health
    assert(
        applied > 0,
        label .. " did not apply positive authoritative damage"
    )

    task.wait(1.2)
    return applied
end

--[[
Asserts a bridge snapshot has the expected global and participant state.

Args:
    snapshot (any): Coordinator snapshot returned by the Studio bridge.
    enabled (boolean): Expected global cutover state.
    participant_count (number): Expected active participant count.

Returns:
    nil: Raises on any gate inconsistency.
]]
local function assert_snapshot(
    snapshot,
    enabled,
    participant_count
)
    assert(
        snapshot.Enabled == enabled
            and snapshot.ActivePlayerCount == participant_count,
        "unexpected coordinator participant state"
    )

    if enabled then
        assert(
            snapshot.ResourceGate
                and snapshot.CombatCalculationGate
                and snapshot.ExecutorGate
                and snapshot.DispatchGate,
            "enabled coordinator left one source gate off"
        )
    else
        assert(
            not snapshot.ResourceGate
                and not snapshot.CombatCalculationGate
                and not snapshot.ExecutorGate
                and not snapshot.DispatchGate,
            "disabled coordinator stranded one source gate"
        )
    end
end

--[[
Runs the final bounded two-player source-cutover rehearsal.

Args:
    None.

Returns:
    nil: Raises on any participant, threat, cleanup or rollback regression.
]]
local function run()
    local players = admitted_players()
    local first = players[1]
    local second = players[2]
    local user_ids = {
        first.UserId,
        second.UserId,
    }

    local diagnosed = bridge:Invoke("diagnose", {
        UserIds = user_ids,
    })
    assert(
        diagnosed.ok and #diagnosed.players == 2,
        "source-boundary diagnostics did not return both players"
    )

    for _, summary in ipairs(diagnosed.players) do
        assert(
            summary.CutoverPrerequisitesReady == true
                and summary.SourceStatCandidateReady == true
                and type(summary.ActivationBlockers) == "table"
                and #summary.ActivationBlockers == 0,
            "one multiplayer source boundary is not activation-ready"
        )
    end

    local enabled = bridge:Invoke("enable", {
        UserIds = user_ids,
        SourceUnitsPerStud = 1,
        IsNight = false,
    })
    assert(enabled.ok, "two-player atomic cutover enable failed")
    assert_snapshot(enabled.snapshot, true, 2)

    for _, player in ipairs(players) do
        assert(
            player:GetAttribute("C4ResourceCutoverActive") == true,
            "selected player did not receive source resource authority"
        )
    end

    local enemy = enter_room_one(players)
    protect_players(players)
    enemy:SetAttribute("C4RehearsalTarget", true)

    local first_damage =
        client_attack(first, enemy, "first source strike")
    local second_damage =
        client_attack(second, enemy, "second source strike")

    local first_threat =
        ThreatService.get_threat(enemy, first.UserId)
    local second_threat =
        ThreatService.get_threat(enemy, second.UserId)

    assert(
        first_threat >= first_damage
            and second_threat >= second_damage,
        "source strikes did not preserve separate per-player threat"
    )

    if second_threat <= first_threat then
        second_threat = ThreatService.taunt(
            enemy,
            second,
            1
        )
    end

    assert(
        second_threat > first_threat,
        "second player could not establish the higher threat total"
    )

    local selected, reason = ThreatService.select_target(
        enemy,
        {
            {
                player = first,
                distance = 4,
            },
            {
                player = second,
                distance = 4,
            },
        }
    )
    assert(
        selected == second and reason == "Threat",
        "highest-threat targeting did not select the correct player"
    )

    print(
        "[C4 Multiplayer Cutover] TWO_SOURCE_PLAYERS_THREAT_PASS"
    )

    local removed = bridge:Invoke("remove", {
        UserIds = {first.UserId},
    })
    assert(removed.ok, "first participant removal failed")
    assert_snapshot(removed.snapshot, true, 1)
    assert(
        first:GetAttribute("C4ResourceCutoverActive") == false
            and second:GetAttribute("C4ResourceCutoverActive") == true,
        "participant removal leaked or removed the wrong resource state"
    )

    local legacy_damage =
        client_attack(first, enemy, "removed-player existing-model strike")
    assert(
        legacy_damage > 0,
        "removed player did not fall back to existing combat"
    )

    local remaining_source_damage =
        client_attack(second, enemy, "remaining source-player strike")
    assert(
        remaining_source_damage > 0
            and second:GetAttribute(
                "C4ResourceCutoverActive"
            ) == true,
        "remaining source participant lost live combat authority"
    )

    print(
        "[C4 Multiplayer Cutover] PARTIAL_REMOVE_FALLBACK_PASS"
    )

    local last_removed = bridge:Invoke("remove", {
        UserIds = {second.UserId},
    })
    assert(last_removed.ok, "final participant removal failed")
    assert_snapshot(last_removed.snapshot, false, 0)
    assert(
        second:GetAttribute("C4ResourceCutoverActive") == false,
        "final participant kept source resource authority"
    )

    local reenabled = bridge:Invoke("enable", {
        UserIds = user_ids,
        SourceUnitsPerStud = 1,
        IsNight = false,
    })
    assert(reenabled.ok, "re-enable after cleanup failed")
    assert_snapshot(reenabled.snapshot, true, 2)

    local disabled = bridge:Invoke("disable")
    assert(disabled.ok, "coordinator-wide rollback failed")
    assert_snapshot(disabled.snapshot, false, 0)

    for _, player in ipairs(players) do
        assert(
            player:GetAttribute("C4ResourceCutoverActive") == false,
            "coordinator-wide rollback left participant source state active"
        )
    end

    print(
        "[C4 Multiplayer Cutover] FULL_ROLLBACK_PASS"
    )
end

task.spawn(function()
    local ok, reason = pcall(run)

    pcall(function()
        bridge:Invoke("disable")
    end)

    if not ok then
        warn("[C4 Multiplayer Cutover] FAIL " .. tostring(reason))
    end

    StudioTestService:EndTest(
        if ok then "PASS" else "FAIL " .. tostring(reason)
    )
end)

task.delay(TEST_TIMEOUT, function()
    StudioTestService:EndTest(
        "FAIL C4 multiplayer cutover global timeout"
    )
end)
]==]
driver.Parent = ServerScriptService

local ok, result = pcall(function()
    return StudioTestService:ExecuteMultiplayerTestAsync(
        2,
        "TEMP_C4MultiplayerCutoverRehearsal"
    )
end)

driver:Destroy()
client:Destroy()
channel:Destroy()

assert(
    ok and result == "PASS",
    "C4 multiplayer cutover rehearsal failed: "
        .. tostring(result)
)

print(
    "[C4 Multiplayer Cutover] VERIFIED_TWO_CLIENT_REHEARSAL_PASS"
)
