--!strict
-- Four live Studio clients test boss recovery after a real peer leaves.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Boss wipe Play must use an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local dungeon = SSS.Dungeon
local runtime_script = dungeon.DungeonRuntime

-- Args:
--   source: LuaSourceContainer; test-only runtime script.
--   original: string; unique source code anchor.
--   replacement: string; disposable Studio substitution.
-- Returns:
--   nil: replaces exactly one fixture hook.
local function replace_once(source, original, replacement)
    local content = source.Source
    local index = assert(string.find(content, original, 1, true),
        "Missing Studio-only runtime hook")
    assert(not string.find(
        content, original, index + #original, true
    ), "Ambiguous Studio-only runtime hook")
    source.Source = string.sub(content, 1, index - 1)
        .. replacement .. string.sub(content, index + #original)
end

-- A disposable test module shares the real runtime without _G state.
local context = Instance.new("ModuleScript")
context.Name = "DungeonBossDisconnectContext_TEMP"
context.Source = "return {}"
context.Parent = dungeon
replace_once(
    runtime_script,
    'local runtime = RuntimeServices.new("Dungeon")',
    'local runtime = RuntimeServices.new("Dungeon")\n'
        .. 'require(script.Parent.DungeonBossDisconnectContext_TEMP).runtime = runtime'
)
replace_once(
    runtime_script,
    '    if RunService:IsStudio() then\n'
        .. '        local studio = StudioSessionFactory.create_for_players(\n'
        .. '            {player},',
    '    if RunService:IsStudio() then\n'
        .. '        while #Players:GetPlayers() < 4 do task.wait(0.1) end\n'
        .. '        local studio = StudioSessionFactory.create_for_players(\n'
        .. '            Players:GetPlayers(),'
)
Workspace:SetAttribute("DungeonMMOStudioDungeonId", "TestDungeon")
Workspace:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
Workspace:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
Workspace:SetAttribute("DungeonMMOPlaceholderPlayableEnabled", true)

local driver = Instance.new("Script")
driver.Name = "DungeonFourClientBossDisconnectDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local Tags = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local context = require(
    script.Parent.Dungeon.DungeonBossDisconnectContext_TEMP
)

-- Args:
--   predicate: () -> any; server-owned state expected to become true.
--   label: string; a specific explanation when a transition stalls.
--   duration: number; maximum wait in seconds.
-- Returns:
--   any: first truthy result.
local function wait_for(predicate, label, duration)
    local deadline = os.clock() + duration
    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Four Client Boss Disconnect] TIMEOUT " .. label)
end

-- Args:
--   name: string; authored environment anchor ID.
-- Returns:
--   BasePart: corresponding physical dungeon trigger.
local function anchor(name)
    return wait_for(function()
        for _, part in ipairs(Tags:GetTagged(
            "DungeonMMOEnvironmentAnchor"
        )) do
            if part:GetAttribute("AnchorId") == name then
                return part
            end
        end
    end, name, 25)
end

-- Args: None.
-- Returns:
--   {Model}: living monsters in the real dungeon runtime.
local function living_enemies()
    local runtime = Workspace:FindFirstChild("DungeonGameplayRuntime")
    local folder = runtime and runtime:FindFirstChild("DungeonEnemies")
    local enemies = {}
    if folder then
        for _, model in ipairs(folder:GetChildren()) do
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(enemies, model)
            end
        end
    end
    return enemies
end

-- Args:
--   player: Player; client entering a physical room.
--   trigger: BasePart; room's authored entrance.
-- Returns:
--   nil: moves the real participant through the trigger.
local function approach(player, trigger)
    local character = assert(player.Character)
    local root = assert(character:FindFirstChild("HumanoidRootPart"))
    local humanoid = assert(character:FindFirstChildOfClass("Humanoid"))
    root.CFrame = trigger.CFrame * CFrame.new(0, 0, 9)
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.15)
    humanoid:MoveTo(trigger.Position + Vector3.new(0, 0, -2))
end

-- Args:
--   player: Player; admitted Studio participant.
-- Returns:
--   Model?: live character, or nil if not yet ready.
local function living_character(player)
    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0
        and character:FindFirstChild("HumanoidRootPart")
    then
        return character
    end
    return nil
end

-- Args:
--   player: Player; participant who opens the required room.
--   trigger_name: string; physical room entrance.
--   minimum: number; expected number of live monsters.
-- Returns:
--   {Model}: spawned enemy handles from the real encounter.
local function enter_room(player, trigger_name, minimum)
    approach(player, anchor(trigger_name))
    return wait_for(function()
        local enemies = living_enemies()
        return if #enemies >= minimum then enemies else nil
    end, "spawn " .. trigger_name, 25)
end

-- Args:
--   enemies: {Model}; currently active prerequisite room pack.
--   label: string; room name for diagnostics.
-- Returns:
--   nil: defeats the prerequisite enemies without asserting normal combat.
local function clear_prerequisite(enemies, label)
    for _, enemy in ipairs(enemies) do
        enemy:FindFirstChildOfClass("Humanoid").Health = 0
    end
    wait_for(function()
        return #living_enemies() == 0
    end, "clear prerequisite " .. label, 15)
end

-- Args:
--   sessions: any; real server dungeon session service.
--   session_id: string; shared dungeon run.
--   encounter_id: string; frozen encounter runtime identifier.
-- Returns:
--   string?: currently persisted state of the named encounter.
local function encounter_state(sessions, session_id, encounter_id)
    local session = sessions:get(session_id)
    local state = session and session.InstanceState
    local runtime = state and state.EncounterRuntime
    return runtime and runtime.EncounterStates[encounter_id]
end

-- Args: None.
-- Returns:
--   nil: proves a full four-client physical boss wipe and retry.
local function run()
    local players = wait_for(function()
        local current = Players:GetPlayers()
        return if #current == 4 then current else nil
    end, "four real clients", 50)
    Players.RespawnTime = 90
    local runtime = wait_for(function()
        return context.runtime
    end, "authoritative Dungeon runtime", 30)
    local sessions = runtime.SessionService
    local session = wait_for(function()
        local first = sessions:get_for_user(players[1].UserId)
        if not first or first.State ~= "Active" then
            return nil
        end
        for _, player in ipairs(players) do
            local member = first.Members[tostring(player.UserId)]
            if not member or member.Connected ~= true
                or member.Mode ~= "Active"
                or not living_character(player)
            then
                return nil
            end
        end
        return first
    end, "four admitted party members", 60)
    local session_id = session.SessionId

    local first = enter_room(
        players[1], "Temple.Room1.Trigger", 2
    )
    clear_prerequisite(first, "Room1")
    local second = enter_room(
        players[1], "Temple.Room2.Trigger", 3
    )
    clear_prerequisite(second, "Room2")
    wait_for(function()
        return encounter_state(sessions, session_id, "CombatRoom1")
                == "Cleared"
            and encounter_state(sessions, session_id, "CombatRoom2")
                == "Cleared"
    end, "two cleared prerequisite rooms", 12)
    print("[Four Client Boss Disconnect] CLEARED_ROOMS_PRESERVED_PASS")

    local bosses = enter_room(
        players[1], "Temple.Room3.Trigger", 1
    )
    assert(#bosses == 1, "Room3 must have exactly one active boss")
    local original_boss = bosses[1]
    local original_health = assert(
        original_boss:FindFirstChildOfClass("Humanoid")
    )
    original_health.Health = original_health.MaxHealth * 0.5
    assert(original_health.Health > 0,
        "The boss must remain alive for recoverable wipe")
    local checkpoint_id = sessions:get(session_id).Checkpoint.Id
    local old_characters = {}
    for _, player in ipairs(players) do
        old_characters[player.UserId] = assert(
            living_character(player)
        )
    end
    print("[Four Client Boss Disconnect] INJURED_BOSS_PASS")

    -- Remove one genuine Studio client while the boss remains Active.
    -- Their absent, still-Active roster mode must not prevent the
    -- three connected members from recovering after a later wipe.
    local departing = players[4]
    departing:Kick("TEMP boss disconnect while fighting")
    wait_for(function()
        local current = sessions:get(session_id)
        local member = current.Members[tostring(departing.UserId)]
        return not Players:GetPlayerByUserId(departing.UserId)
            and member and member.Connected == false
    end, "real player disconnection persisted in active boss", 25)
    assert(original_boss.Parent ~= nil
        and sessions:get(session_id).State == "Active",
        "One leaving player must not reset a live boss for peers")
    print("[Four Client Boss Disconnect] PEER_BOSS_CONTINUES_PASS")

    -- Three remaining actual players die in the same active encounter.
    for index = 1, 3 do
        local player = players[index]
        old_characters[player.UserId]
            :FindFirstChildOfClass("Humanoid").Health = 0
    end
    wait_for(function()
        return original_boss.Parent == nil
            and #living_enemies() == 0
    end, "old boss and spawn claim released", 12)
    print("[Four Client Boss Disconnect] OLD_BOSS_CLEANUP_PASS")

    wait_for(function()
        local current = sessions:get(session_id)
        if current.State ~= "Active" then
            return false
        end
        for index = 1, 3 do
            local player = players[index]
            local member = current.Members[tostring(player.UserId)]
            local character = living_character(player)
            if not member or member.Mode ~= "Active"
                or not member.FreeReviveUsed or not character
                or character == old_characters[player.UserId]
            then
                return false
            end
        end
        return true
    end, "three connected checkpoint revives", 25)
    local departed_member = sessions:get(session_id)
        .Members[tostring(departing.UserId)]
    assert(departed_member.Connected == false
        and departed_member.FreeReviveUsed == false,
        "Absent player must never receive an automatic revive")
    assert(sessions:get(session_id).Checkpoint.Id == checkpoint_id,
        "Boss wipe must preserve the same active checkpoint")
    assert(encounter_state(sessions, session_id, "CombatRoom1")
            == "Cleared"
        and encounter_state(sessions, session_id, "CombatRoom2")
            == "Cleared"
        and encounter_state(sessions, session_id, "Depth1Boss")
            == "Pending",
        "Only the interrupted boss may be reset")
    print("[Four Client Boss Disconnect] FOUR_BOSS_CHECKPOINT_REVIVES_PASS")

    local fresh = enter_room(
        players[1], "Temple.Room3.Trigger", 1
    )
    assert(#fresh == 1 and fresh[1] ~= original_boss,
        "Boss retry must spawn exactly one different boss")
    local fresh_health = assert(
        fresh[1]:FindFirstChildOfClass("Humanoid")
    )
    assert(fresh_health.Health == fresh_health.MaxHealth,
        "Retried boss must spawn at full health")
    print("[Four Client Boss Disconnect] FRESH_FULL_HEALTH_BOSS_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Four Client Boss Disconnect] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(160, function()
    STS:EndTest("FAIL boss fixture global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        4, "DungeonFourClientBossDisconnect_TEMP"
    )
end)
driver:Destroy()
context:Destroy()
assert(ok and result == "PASS",
    "Four-client boss wipe Play failed: " .. tostring(result))
print("[Four Client Boss Disconnect] VERIFIED_MULTIPLAYER_PASS")
