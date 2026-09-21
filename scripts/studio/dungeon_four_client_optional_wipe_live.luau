--!strict
-- Four real Studio clients retry a TEMP-enabled optional event boss.
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
context.Name = "DungeonEventWipeContext_TEMP"
context.Source = "return {}"
context.Parent = dungeon
replace_once(
    runtime_script,
    'local runtime = RuntimeServices.new("Dungeon")',
    'local runtime = RuntimeServices.new("Dungeon")\n'
        .. 'require(script.Parent.DungeonEventWipeContext_TEMP).runtime = runtime'
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
-- Enable only this Temple event inside the disposable Studio DataModel.
-- The original project and Mine release gates remain unchanged.
local definitions = game:GetService("ReplicatedStorage")
    .Core.Shared.DungeonDefinitions
local definition_source = definitions.Source
local release_flag = "OptionalBossRuntimeEnabled = false,"
local first_flag = assert(
    string.find(definition_source, release_flag, 1, true),
    "Temple optional release gate missing"
)
assert(string.find(
    definition_source, release_flag, first_flag + #release_flag, true
), "Separate Mine optional release gate must remain unchanged")
definitions.Source = string.sub(definition_source, 1, first_flag - 1)
    .. "OptionalBossRuntimeEnabled = true, -- TEMP Temple only"
    .. string.sub(definition_source, first_flag + #release_flag)
SSS:SetAttribute("DungeonMMOOptionalBossEventStartUnix", os.time() - 60)
SSS:SetAttribute("DungeonMMOOptionalBossEventEndUnix", os.time() + 900)
SSS:SetAttribute("DungeonMMOOptionalBossSecretChanceBasisPoints", 0)
Workspace:SetAttribute("DungeonMMOStudioDungeonId", "TestDungeon")
Workspace:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
Workspace:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
Workspace:SetAttribute("DungeonMMOPlaceholderPlayableEnabled", true)
Workspace:SetAttribute("DungeonMMOPlaceholderOptionalPlayEnabled", true)

local driver = Instance.new("Script")
driver.Name = "DungeonFourClientEventWipeDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local Tags = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local context = require(
    script.Parent.Dungeon.DungeonEventWipeContext_TEMP
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
    error("[Four Client Optional Wipe] TIMEOUT " .. label)
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
    assert(session.InstanceState.OptionalBossEventActive == true,
        "TEMP event fixture must select an eligible event boss")

    local first = enter_room(
        players[1], "Temple.Room1.Trigger", 2
    )
    clear_prerequisite(first, "Room1")
    wait_for(function()
        return encounter_state(sessions, session_id, "CombatRoom1")
                == "Cleared"
    end, "cleared prerequisite room", 12)
    print("[Four Client Optional Wipe] CLEARED_ROOMS_PRESERVED_PASS")

    local bosses = enter_room(
        players[1], "Temple.Event.Trigger", 1
    )
    assert(#bosses == 1, "EventArena must have exactly one boss")
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
    print("[Four Client Optional Wipe] INJURED_BOSS_PASS")

    -- Genuine server character deaths; no boss damage/reward injection.
    for _, player in ipairs(players) do
        old_characters[player.UserId]
            :FindFirstChildOfClass("Humanoid").Health = 0
    end
    wait_for(function()
        return original_boss.Parent == nil
            and #living_enemies() == 0
    end, "old boss and spawn claim released", 12)
    print("[Four Client Optional Wipe] OLD_BOSS_CLEANUP_PASS")

    wait_for(function()
        local current = sessions:get(session_id)
        if current.State ~= "Active" then
            return false
        end
        for _, player in ipairs(players) do
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
    end, "all four automatic checkpoint revives", 25)
    assert(sessions:get(session_id).Checkpoint.Id == checkpoint_id,
        "Boss wipe must preserve the same active checkpoint")
    assert(encounter_state(sessions, session_id, "CombatRoom1")
            == "Cleared"
        and encounter_state(sessions, session_id, "CombatRoom2")
            == "Pending"
        and encounter_state(
            sessions, session_id, "TempleEventBossEncounter"
        ) == "Pending",
        "Only the interrupted boss may be reset")
    print("[Four Client Optional Wipe] FOUR_BOSS_CHECKPOINT_REVIVES_PASS")

    local fresh = enter_room(
        players[1], "Temple.Event.Trigger", 1
    )
    assert(#fresh == 1 and fresh[1] ~= original_boss,
        "Boss retry must spawn exactly one different boss")
    local fresh_health = assert(
        fresh[1]:FindFirstChildOfClass("Humanoid")
    )
    assert(fresh_health.Health == fresh_health.MaxHealth,
        "Retried boss must spawn at full health")
    print("[Four Client Optional Wipe] FRESH_FULL_HEALTH_BOSS_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Four Client Optional Wipe] FAIL " .. tostring(reason))
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
        4, "DungeonFourClientEventWipe_TEMP"
    )
end)
driver:Destroy()
context:Destroy()
assert(ok and result == "PASS",
    "Four-client boss wipe Play failed: " .. tostring(result))
print("[Four Client Optional Wipe] VERIFIED_MULTIPLAYER_PASS")
