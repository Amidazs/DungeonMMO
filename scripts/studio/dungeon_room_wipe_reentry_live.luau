--!strict
-- Unpublished physical room-reset proof with one genuine Studio player.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Room wipe test requires an unpublished Studio place")

local SSS = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
Workspace:SetAttribute("DungeonMMOStudioDungeonId", "TestDungeon")
Workspace:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
Workspace:SetAttribute("DungeonMMOPlaceholderPhysicalContentEnabled", true)
Workspace:SetAttribute("DungeonMMOPlaceholderPlayableEnabled", true)

local driver = Instance.new("Script")
driver.Name = "DungeonRoomWipeDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")

-- Args:
--   predicate: () -> any; authoritative game state to observe.
--   label: string; diagnostic identifying a missing transition.
--   seconds: number; maximum time allowed for the observation.
-- Returns:
--   any: the first truthy observed state.
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Dungeon Room Wipe Live] TIMEOUT " .. label)
end

-- Args:
--   identifier: string; physical encounter entrance anchor ID.
-- Returns:
--   BasePart: actual environment trigger in the running dungeon.
local function anchor(identifier)
    return wait_for(function()
        for _, part in ipairs(CollectionService:GetTagged(
            "DungeonMMOEnvironmentAnchor"
        )) do
            if part:GetAttribute("AnchorId") == identifier then
                return part
            end
        end
    end, identifier, 25)
end

-- Args:
--   player: Player; real Studio client entering an authored room.
--   trigger: BasePart; server-authored physical encounter entrance.
-- Returns:
--   nil: moves the live player through the trigger in the game world.
local function approach(player, trigger)
    local character = assert(player.Character)
    local root = wait_for(function()
        return character:FindFirstChild("HumanoidRootPart")
    end, "player root", 15)
    local humanoid = assert(character:FindFirstChildOfClass("Humanoid"))
    root.CFrame = trigger.CFrame * CFrame.new(0, 0, 9)
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.15)
    humanoid:MoveTo(trigger.Position + Vector3.new(0, 0, -2))
end

-- Args: None.
-- Returns:
--   {Model}: currently alive physical dungeon enemies.
local function living_enemies()
    local gameplay = Workspace:FindFirstChild("DungeonGameplayRuntime")
    local folder = gameplay and gameplay:FindFirstChild("DungeonEnemies")
    local living = {}
    if not folder then
        return living
    end
    for _, enemy in ipairs(folder:GetChildren()) do
        if enemy:IsA("Model") then
            local humanoid = enemy:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                table.insert(living, enemy)
            end
        end
    end
    return living
end

-- Args: None.
-- Returns:
--   nil: validates physical cleanup and re-entry after free revive.
local function run()
    local player = Players:GetPlayers()[1]
        or Players.PlayerAdded:Wait()
    local trigger = anchor("Temple.Room1.Trigger")
    local first_character = wait_for(function()
        local character = player.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")
        return if humanoid and humanoid.Health > 0
            and character:FindFirstChild("HumanoidRootPart")
            then character else nil
    end, "first live character", 40)

    approach(player, trigger)
    local original = wait_for(function()
        local enemies = living_enemies()
        return if #enemies >= 2 then enemies else nil
    end, "first Room1 enemy pack", 25)
    local first_enemy = original[1]
    local health = assert(first_enemy:FindFirstChildOfClass("Humanoid"))
    local max_health = health.MaxHealth
    assert(max_health > 1, "Room enemy must have positive max health")

    -- Injury is test-injected, but neither enemy is defeated or paid.
    health.Health = max_health * 0.5
    assert(health.Health < max_health and health.Health > 0,
        "Initial enemy must be partially damaged before wipe")
    print("[Dungeon Room Wipe Live] INJURED_ENEMY_PASS")

    local player_health = assert(
        first_character:FindFirstChildOfClass("Humanoid"))
    player_health.Health = 0
    wait_for(function()
        return first_enemy.Parent == nil
            and #living_enemies() == 0
    end, "old encounter enemies retired on full wipe", 12)
    print("[Dungeon Room Wipe Live] OLD_ENCOUNTER_CLEANUP_PASS")

    local revived = wait_for(function()
        local character = player.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")
        return if character ~= first_character
            and humanoid and humanoid.Health > 0
            then character else nil
    end, "real client automatic checkpoint respawn", 20)
    local root = assert(revived:FindFirstChild("HumanoidRootPart"))
    assert((root.Position - trigger.Position).Magnitude < 80,
        "Free revive must return near the current room checkpoint")
    print("[Dungeon Room Wipe Live] CHECKPOINT_REVIVE_PASS")

    approach(player, trigger)
    local fresh = wait_for(function()
        local enemies = living_enemies()
        return if #enemies == #original then enemies else nil
    end, "new enemy pack on physical room re-entry", 20)
    for _, enemy in ipairs(fresh) do
        local humanoid = assert(enemy:FindFirstChildOfClass("Humanoid"))
        assert(humanoid.Health == humanoid.MaxHealth,
            "Re-entered enemies must have full health")
        for _, old in ipairs(original) do
            assert(enemy ~= old, "Old enemy handle was reused after wipe")
        end
    end
    print("[Dungeon Room Wipe Live] FRESH_FULL_HEALTH_PACK_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[Dungeon Room Wipe Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(110, function()
    STS:EndTest("FAIL global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("DungeonRoomWipeReentry_TEMP")
end)
driver:Destroy()
assert(ok and result == "PASS",
    "Physical room wipe/re-entry test failed: " .. tostring(result))
print("[Dungeon Room Wipe Live] VERIFIED_PLAY_MODE_PASS")
