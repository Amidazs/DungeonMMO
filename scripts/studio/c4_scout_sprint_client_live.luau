--!strict
-- Actual unpublished Human Rogue Sprint via genuine client skill remote.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Scout Sprint live acceptance is for unpublished Studio only")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local runtime_script = SSS.Dungeon.DungeonRuntime
local anchor = 'local runtime = RuntimeServices.new("Dungeon")'
local old = runtime_script.Source
local start = assert(string.find(old, anchor, 1, true),
    "Unpublished Dungeon runtime source anchor missing")
assert(not string.find(old, anchor, start + #anchor, true),
    "Unpublished Dungeon runtime source anchor not unique")
runtime_script.Source = old:sub(1, start - 1) .. anchor
    .. '\n_G.C4ScoutSprintRuntime_TEMP = runtime'
    .. old:sub(start + #anchor)

local channel = Instance.new("RemoteEvent")
channel.Name = "C4ScoutSprintChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "C4ScoutSprintActualClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("C4ScoutSprintChannel_TEMP")
local request = RS.Combat.Remotes:WaitForChild("SkillRequest")
channel.OnClientEvent:Connect(function(action, skill_id)
    if action == "Cast" then
        request:FireServer(skill_id)
        channel:FireServer("Sent", skill_id)
    end
end)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "C4ScoutSprintActualDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local RuntimeState = require(SSS.Core.Services.ProgressionRuntimeState)
local Stamina = require(SSS.Combat.StaminaService)
local Status = require(SSS.Combat.CombatStatusService)
local Cooldowns = require(SSS.Combat.SkillCooldownService)
local CombatConfig = require(RS.Combat.Shared.CombatConfig)
local channel = RS:WaitForChild("C4ScoutSprintChannel_TEMP")
local ready = {}
local sent = {}
channel.OnServerEvent:Connect(function(player, action, skill)
    if action == "Ready" then
        ready[player.UserId] = true
    elseif action == "Sent" then
        sent[player.UserId] = skill
    end
end)

--[[
Waits for a genuine authenticated player or real server combat state.

Args:
    predicate (() -> any): Expected real Studio playtest state.
    label (string): Precise failure diagnostic.
    seconds (number): Maximum elapsed time for this stage.

Returns:
    any: First truthy test observation.
]]
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then return value end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[C4 Rogue Sprint Live] TIMEOUT " .. label)
end

--[[
Purchases and equips the real Human Rogue level-20 active Sprint skill.

Args:
    runtime (any): Actual selected Dungeon profile and training services.
    player (Player): Authenticated admitted Studio combat participant.

Returns:
    nil: Updates server-owned combat rank and original avatar stats.
]]
local function prepare(runtime, player)
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
    end), "Human Rogue source setup not persisted")
    local bought = runtime.SkillProgressionService:learn_trainer_skill(
        player.UserId, "HumanScoutSprint"
    )
    assert(bought.ok and bought.rank == 1,
        "Original level-20 Sprint was not actually trained")
    assert(runtime.ProfileService:mutate(player.UserId, function(profile)
        profile.Characters.Slot1.Progression.Loadout[1] =
            "HumanScoutSprint"
    end), "Real Sprint loadout failed")
    RuntimeState.set_character(player.UserId, assert(
        runtime.ProfileService:get_character(player.UserId, 1)
    ))
    RuntimeState.apply_runtime_stats(player)
    Stamina.reset_player(player)
end

--[[
Verifies paid skill cast changes actual Humanoid locomotion and expires.

Args:
    player (Player): Genuine local Studio client who requests Sprint.

Returns:
    nil: Proves server stamina spend, speed, cooldown and expiration.
]]
local function verify_sprint(player)
    local avatar = assert(player.Character)
    local humanoid = assert(avatar:FindFirstChildOfClass("Humanoid"))
    local baseline = humanoid.WalkSpeed
    local stamina_before = Stamina.get(player)
    assert(Status.get(avatar, "Movement") == 0,
        "Human Scout Sprint was active without being purchased/cast")
    sent[player.UserId] = nil
    channel:FireClient(player, "Cast", "HumanScoutSprint")
    wait_for(function()
        return sent[player.UserId] == "HumanScoutSprint"
    end, "client sent original Human Rogue Sprint", 10)
    wait_for(function()
        return Status.get(avatar, "Movement") >= 0.17
            and humanoid.WalkSpeed > baseline * 1.15
    end, "server applied actual paid Humanoid movement bonus", 10)
    assert(Stamina.get(player) <= stamina_before - 19.9,
        "Sprint did not consume twenty actual stamina")
    assert(Cooldowns.get_remaining(
        player, "HumanScoutSprint"
    ) > 20, "Real Sprint server cooldown was never started")
    print("[C4 Rogue Sprint Live] REAL_CLIENT_PAID_SPEED_PASS")

    wait_for(function()
        return Status.get(avatar, "Movement") == 0
            and humanoid.WalkSpeed <= baseline * 1.01
    end, "server expired and restored original Humanoid speed", 12)
    print("[C4 Rogue Sprint Live] REAL_SPEED_EXPIRY_PASS")
end

--[[
Executes one authentic admitted dungeon client, no production DataStores.

Args:
    None.

Returns:
    nil: Verifies the paid, cooldown-controlled C4 Sprint combat path.
]]
local function main()
    local player = wait_for(function()
        local users = Players:GetPlayers()
        return if #users == 1 then users[1] else nil
    end, "one actual Studio Dungeon player", 45)
    local runtime = wait_for(function()
        return _G.C4ScoutSprintRuntime_TEMP
    end, "actual Dungeon runtime composition", 35)
    wait_for(function()
        return ready[player.UserId]
            and runtime.ProfileService:get_character(player.UserId, 1)
            and player:GetAttribute(
                CombatConfig.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
            ) == true
            and player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
    end, "real Dungeon admission and authentic client", 60)
    local root = assert(player.Character:FindFirstChild("HumanoidRootPart"))
    root.Anchored = true
    root.CFrame = CFrame.new(0, 100, 0)
    prepare(runtime, player)
    verify_sprint(player)
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[C4 Rogue Sprint Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(115, function()
    STS:EndTest("FAIL global Human Scout Sprint playtest timeout")
end)
]==]
driver.Parent = SSS

local ok, value = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        1, "C4ScoutHumanRogueSprint_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and value == "PASS",
    "Actual Rogue Sprint client playtest failed: " .. tostring(value))
print("[C4 Rogue Sprint Live] VERIFIED_REAL_CLIENT_SPRINT_PASS")
