--!strict
-- Actual unpublished Dungeon avatar, terrain-water and humanoid HP test.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Environmental world test requires unpublished local Studio")

local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local runtime_script = SSS.Dungeon.DungeonRuntime

--[[
Temporarily exposes a single local Dungeon runtime expression to the test.

Args:
    owner (LuaSourceContainer): Disposable Rojo-built runtime source.
    anchor (string): Unique server-owned runtime initialization expression.
    addition (string): Test-only access to already created real services.

Returns:
    nil: Refuses changed or ambiguous source instrumentation.
]]
local function expose(owner: any, anchor: string, addition: string)
    local source = owner.Source
    local start = assert(string.find(source, anchor, 1, true),
        "Dungeon environment runtime source anchor missing")
    assert(not string.find(source, anchor, start + #anchor, true),
        "Dungeon environment runtime source anchor duplicated")
    owner.Source = source:sub(1, start + #anchor - 1)
        .. "\n" .. addition .. source:sub(start + #anchor)
end

expose(runtime_script, 'local runtime = RuntimeServices.new("Dungeon")',
    '_G.C4EnvironmentWorldRuntime_TEMP = runtime')
expose(runtime_script,
    'local scout_environment = ScoutEnvironmentService.new(profiles)',
    '_G.C4EnvironmentWorldService_TEMP = scout_environment')

local driver = Instance.new("Script")
driver.Name = "C4EnvironmentWorldActualDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local STS = game:GetService("StudioTestService")
local Rules = require(game:GetService("ReplicatedStorage")
    .Core.Shared.ScoutEnvironmentalRules)

--[[
Awaits the actual admitted world avatar and real server profile.

Args:
    predicate (() -> any): Real live session readiness condition.
    label (string): Specific gameplay stage being waited on.
    seconds (number): Maximum time before test failure.

Returns:
    any: First true observed runtime state.
]]
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then return value end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[C4 Scout Environment Live] TIMEOUT " .. label)
end

--[[
Creates the real original source class and actually purchases both passives.

Args:
    runtime (any): Authenticated Dungeon progression and profile services.
    player (Player): Admitted human Rogue in disposable Studio.

Returns:
    nil: Persists genuine trainer purchases rather than forged HUD ranks.
]]
local function prepare_character(runtime, player)
    assert(runtime.ProfileService:mutate(player.UserId, function(profile)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1, RaceId = "Human",
            BaseClassId = "Rogue", ClassId = "Rogue",
            CreationStage = "Complete",
        }
        character.Level = 20
        character.Gold = 1500
        character.Progression.SkillPointEntitlement = 250
        character.Equipment.Weapon = "scout_dagger"
    end), "Source Rogue profile initialization failed")
    for _, id in ipairs({
        "ScoutLungCapacity", "ScoutFallResistance",
    }) do
        assert(runtime.SkillProgressionService:learn_trainer_skill(
            player.UserId, id
        ).ok, "Original source environmental purchase failed: " .. id)
    end
end

--[[
Verifies real physical terrain immersion drains and refills the live avatar.

Args:
    runtime (any): Genuine profile containing purchased Lung Capacity.
    record (any): Live Dungeon environmental Heartbeat tracking record.

Returns:
    nil: Observes real terrain water, oxygen HUD stat and drowning HP loss.
]]
local function verify_terrain_water(runtime, record)
    local root = record.Root
    root.Anchored = true
    root.CFrame = CFrame.new(0, 150, 0)
    local terrain = workspace.Terrain
    local centre = CFrame.new(0, 150, 0)
    local dimensions = Vector3.new(40, 40, 40)
    terrain:FillBlock(centre, dimensions, Enum.Material.Air)
    wait_for(function()
        return record.Oxygen == 27
    end, "earned full air reserve outside water", 6)
    local before = record.Oxygen
    terrain:FillBlock(centre, dimensions, Enum.Material.Water)
    wait_for(function()
        return record.Oxygen <= before - 0.5
    end, "actual avatar head submerged in real Terrain water", 8)
    assert(record.Character:GetAttribute(
        "DungeonMMOOxygenSeconds"
    ) < before, "Water did not update live oxygen attribute")
    print("[C4 Scout Environment Live] REAL_TERRAIN_WATER_AIR_PASS")

    record.Oxygen = 0.5
    local health_before = record.Humanoid.Health
    wait_for(function()
        return record.Humanoid.Health < health_before
    end, "genuine zero-oxygen drowning damaged the original avatar", 5)
    print("[C4 Scout Environment Live] REAL_DROWNING_HP_PASS")

    terrain:FillBlock(centre, dimensions, Enum.Material.Air)
    wait_for(function()
        return record.Oxygen == 27
    end, "surfacing replenished purchased Lung Capacity air reserve", 6)
    print("[C4 Scout Environment Live] REAL_SURFACING_PASS")
end

--[[
Applies a controlled server-recorded landing speed to actual humanoid HP.

Args:
    runtime (any): Real Dungeon service with the learned Scout rank.
    player (Player): Original authenticated living avatar.
    service (any): Actual bound per-character environmental runtime.
    record (any): Server-bound original avatar and physical speed record.

Returns:
    nil: Verifies fall-only trained/untrained HP deltas and no double hit.
]]
local function verify_actual_fall_health(runtime, player, service, record)
    local original = record.Humanoid.Health
    record.InFreefall = true
    record.FallStartedAt = os.clock() - 1
    record.MaxDownwardSpeed = 100
    service:_landed(record)
    local trained_injury = original - record.Humanoid.Health
    assert(math.abs(trained_injury - 10.8) < 0.05,
        "Real avatar failed to receive paid-resistance fall HP damage")
    service:_landed(record)
    assert(math.abs(
        original - record.Humanoid.Health - trained_injury
    ) < 0.05, "One hard landing damaged the same avatar twice")
    print("[C4 Scout Environment Live] REAL_TRAINED_LANDING_HP_PASS")

    assert(runtime.ProfileService:mutate(player.UserId, function(profile)
        profile.Characters.Slot1.Progression.Skills
            .ScoutFallResistance = nil
    end), "Test-only revocation of the actual purchased fall rank failed")
    local before = record.Humanoid.Health
    record.InFreefall = true
    record.FallStartedAt = os.clock() - 1
    record.MaxDownwardSpeed = 100
    service:_landed(record)
    assert(math.abs(
        before - record.Humanoid.Health - 18
    ) < 0.05, "Actual HP remained mitigated after paid rank revocation")
    print("[C4 Scout Environment Live] REAL_REVOKED_LANDING_HP_PASS")
end

--[[
Executes actual Dungeon admission, terrain immersion and damage service.

Args:
    None.

Returns:
    nil: Validates earned source benefits on a real Studio avatar.
]]
local function main()
    local player = wait_for(function()
        local players = Players:GetPlayers()
        return if #players == 1 then players[1] else nil
    end, "one real Dungeon test player", 45)
    local runtime = wait_for(function()
        return _G.C4EnvironmentWorldRuntime_TEMP
    end, "actual selected Dungeon runtime", 35)
    local environment = wait_for(function()
        return _G.C4EnvironmentWorldService_TEMP
    end, "actual world environmental service", 35)
    local record = wait_for(function()
        return runtime.ProfileService:get_character(player.UserId, 1)
            and environment._characters[player]
    end, "admitted original avatar environment binding", 60)
    prepare_character(runtime, player)
    verify_terrain_water(runtime, record)
    verify_actual_fall_health(runtime, player, environment, record)
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[C4 Scout Environment Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(95, function()
    STS:EndTest("FAIL global world environment timeout")
end)
]==]
driver.Parent = SSS

local ok, value = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        1, "C4ScoutActualWaterAndFall_HP_TEMP"
    )
end)
driver:Destroy()
assert(ok and value == "PASS",
    "Actual world environment client test failed: " .. tostring(value))
print("[C4 Scout Environment Live] VERIFIED_WATER_AND_HP_PASS")
