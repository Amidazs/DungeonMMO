--!strict
-- Unpublished four-client physical Room1 wipe and checkpoint retry.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Four-client room wipe requires unpublished Studio")

local SSS = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local runtime_script = SSS.Dungeon.DungeonRuntime

-- Args:
--   target: LuaSourceContainer; disposable place script to adapt.
--   original: string; unique source anchor to replace.
--   replacement: string; local-only source replacement.
-- Returns:
--   nil: verifies a single anchor and changes only the test DataModel.
local function replace_once(target, original, replacement)
    local source = target.Source
    local position = assert(string.find(source, original, 1, true),
        "Missing fixture source anchor")
    assert(not string.find(
        source, original, position + #original, true
    ), "Duplicated fixture source anchor")
    target.Source = string.sub(source, 1, position - 1)
        .. replacement .. string.sub(source, position + #original)
end

-- Share the real runtime session with the TEMP server driver.
replace_once(
    runtime_script,
    'local runtime = RuntimeServices.new("Dungeon")',
    'local runtime = RuntimeServices.new("Dungeon")\n'
        .. '_G.DungeonFourClientWipeRuntime_TEMP = runtime'
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
driver.Name = "DungeonFourClientWipeDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local Tags = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")

-- Args:
--   predicate: () -> any; server-owned state expected to become true.
--   label: string; meaningful failure explanation.
--   seconds: number; upper bound in seconds.
-- Returns:
--   any: the first truthy observation.
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Four Client Room Wipe] TIMEOUT " .. label)
end

-- Args:
--   identifier: string; physical room trigger identifier.
-- Returns:
--   BasePart: matching authored environment anchor.
local function anchor(identifier)
    return wait_for(function()
        for _, part in ipairs(Tags:GetTagged(
            "DungeonMMOEnvironmentAnchor"
        )) do
            if part:GetAttribute("AnchorId") == identifier then
                return part
            end
        end
    end, identifier, 25)
end

-- Args: None.
-- Returns:
--   {Model}: living enemies in the actual dungeon runtime folder.
local function living_enemies()
    local root = Workspace:FindFirstChild("DungeonGameplayRuntime")
    local folder = root and root:FindFirstChild("DungeonEnemies")
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
--   player: Player; client who enters the encounter.
--   trigger: BasePart; room entrance.
-- Returns:
--   nil: physically moves the live client through the trigger.
local function approach(player, trigger)
    local root = assert(player.Character
        and player.Character:FindFirstChild("HumanoidRootPart"))
    root.CFrame = trigger.CFrame * CFrame.new(0, 0, 9)
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.15)
    assert(player.Character)
    player.Character:FindFirstChildOfClass("Humanoid"):MoveTo(
        trigger.Position + Vector3.new(0, 0, -2)
    )
end

-- Args:
--   player: Player; one admitted real Studio participant.
-- Returns:
--   Model?: currently living character, if loaded and healthy.
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
--   enemy: Model; real encountered monster with authored reward identity.
--   session_id: string; active dungeon session ID.
-- Returns:
--   string: idempotent reward transaction across room resets.
local function reward_transaction(enemy, session_id)
    return string.format(
        "%s:%s:Life%d",
        session_id,
        tostring(enemy:GetAttribute("DungeonEnemyId")),
        tonumber(enemy:GetAttribute("DungeonLifeIndex")) or 1
    )
end

-- Args:
--   runtime: any; real runtime service container.
--   players: {Player}; connected members eligible for monster rewards.
--   transaction_id: string; stable transaction to validate.
-- Returns:
--   {[number]: any}: each member's actual paid reward and statistics.
local function reward_snapshots(runtime, players, transaction_id)
    local snapshots = {}
    for _, player in ipairs(players) do
        local character = runtime.ProfileService:get_character(
            player.UserId, 1
        )
        local history = character
            and character.RewardHistory
            and character.RewardHistory.Monster
        local receipt = history and history[transaction_id]
        if not receipt then
            return nil
        end
        snapshots[player.UserId] = {
            gold = character.Gold,
            level = character.Level,
            xp = character.XP,
            kill_count = receipt.BestiaryKillCount,
        }
    end
    return snapshots
end

-- Args: None.
-- Returns:
--   nil: verifies genuine four-client wipe and physical room re-entry.
local function run()
    local players = wait_for(function()
        local current = Players:GetPlayers()
        return if #current == 4 then current else nil
    end, "four real clients", 50)
    Players.RespawnTime = 90
    local runtime = wait_for(function()
        return _G.DungeonFourClientWipeRuntime_TEMP
    end, "production runtime", 30)
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
    end, "all four members admitted in one run", 60)
    local session_id = session.SessionId
    local original_characters = {}
    for _, player in ipairs(players) do
        original_characters[player.UserId] = living_character(player)
    end
    print("[Four Client Room Wipe] SHARED_SESSION_PASS")

    local trigger = anchor("Temple.Room1.Trigger")
    approach(players[1], trigger)
    local original = wait_for(function()
        local enemies = living_enemies()
        return if #enemies >= 2 then enemies else nil
    end, "first real enemy pack", 25)
    local rewarded_enemy = original[2]
    local transaction_id = reward_transaction(
        rewarded_enemy, session_id
    )
    rewarded_enemy:FindFirstChildOfClass("Humanoid").Health = 0
    local before_retry = wait_for(function()
        return reward_snapshots(runtime, players, transaction_id)
    end, "four authoritative reward receipts on first enemy kill", 12)
    print("[Four Client Room Wipe] FIRST_KILL_REWARDS_PASS")

    local injured = assert(original[1]:FindFirstChildOfClass("Humanoid"))
    injured.Health = injured.MaxHealth * 0.5
    assert(injured.Health > 0 and injured.Health < injured.MaxHealth,
        "Wipe fixture must begin with a living injured enemy")

    -- Real characters die in the actual server while every member
    -- still owns an unused automatic free revive.
    for _, player in ipairs(players) do
        local character = assert(original_characters[player.UserId])
        character:FindFirstChildOfClass("Humanoid").Health = 0
    end
    wait_for(function()
        local current = sessions:get(session_id)
        for _, player in ipairs(players) do
            local member = current.Members[tostring(player.UserId)]
            if not member or member.FreeReviveUsed ~= true then
                return false
            end
        end
        return true
    end, "all four actual deaths consumed free revives", 10)
    wait_for(function()
        for _, enemy in ipairs(original) do
            if enemy.Parent ~= nil then
                return false
            end
        end
        return #living_enemies() == 0
    end, "old combat pack retired", 12)
    print("[Four Client Room Wipe] FOUR_DEATH_CLEANUP_PASS")

    wait_for(function()
        local current = sessions:get(session_id)
        if current.State ~= "Active" then
            return false
        end
        for _, player in ipairs(players) do
            local member = current.Members[tostring(player.UserId)]
            local character = living_character(player)
            if member.Mode ~= "Active" or not character
                or character == original_characters[player.UserId]
            then
                return false
            end
        end
        return true
    end, "four fresh checkpoint characters", 25)
    local recovered = sessions:get(session_id)
    assert(recovered.State == "Active",
        "Recoverable wipe must preserve the active session")
    print("[Four Client Room Wipe] FOUR_CHECKPOINT_REVIVES_PASS")

    approach(players[1], trigger)
    local fresh = wait_for(function()
        local enemies = living_enemies()
        return if #enemies == #original then enemies else nil
    end, "physically respawned room pack", 20)
    for _, enemy in ipairs(fresh) do
        local humanoid = assert(enemy:FindFirstChildOfClass("Humanoid"))
        assert(humanoid.Health == humanoid.MaxHealth,
            "Re-entered room must have full-health enemies")
        for _, old in ipairs(original) do
            assert(enemy ~= old, "Old enemy handle cannot be reused")
        end
    end
    assert(sessions:get(session_id).Checkpoint.Sequence >= 1,
        "Room checkpoint must remain active after recoverable wipe")
    print("[Four Client Room Wipe] FULL_HEALTH_ROOM_REENTRY_PASS")

    local repeated_enemy
    for _, enemy in ipairs(fresh) do
        if reward_transaction(enemy, session_id) == transaction_id then
            repeated_enemy = enemy
            break
        end
    end
    assert(repeated_enemy,
        "Retried room must restore the same stable monster reward ID")
    repeated_enemy:FindFirstChildOfClass("Humanoid").Health = 0
    wait_for(function()
        return repeated_enemy.Parent == nil
    end, "retired repeated monster after idempotent reward", 12)
    local after_retry = assert(reward_snapshots(
        runtime, players, transaction_id
    ))
    for _, player in ipairs(players) do
        local before = before_retry[player.UserId]
        local after = after_retry[player.UserId]
        assert(
            after.gold == before.gold
                and after.level == before.level
                and after.xp == before.xp
                and after.kill_count == before.kill_count,
            "A retried monster cannot pay a party member twice"
        )
    end
    print("[Four Client Room Wipe] NO_DUPLICATE_REWARDS_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Four Client Room Wipe] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(150, function()
    STS:EndTest("FAIL fixture global timeout")
end)
]==]
driver.Parent = SSS
local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        4, "DungeonFourClientRoomWipe_TEMP"
    )
end)
driver:Destroy()
assert(ok and result == "PASS",
    "Four-client room wipe Play failed: " .. tostring(result))
print("[Four Client Room Wipe] VERIFIED_MULTIPLAYER_PASS")
