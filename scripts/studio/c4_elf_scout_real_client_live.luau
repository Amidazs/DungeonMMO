--!strict
-- Real unpublished Dungeon client casts three new Elf-only Scout skills.
-- The temporary instrumentation changes only this disposable Studio place.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Real Scout client playtest requires an unpublished Dungeon.")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts

--[[
Exposes a disposable Dungeon runtime for authoritative test profile setup.

Args:
    owner (LuaSourceContainer): Local DungeonRuntime script instance.
    anchor (string): One unique approved runtime source span.
    replacement (string): Temporary test-only source replacement.

Returns:
    nil: Rejects changed or ambiguous runtime instrumentation anchors.
]]
local function replace_once(owner: any, anchor: string, replacement: string)
    local source = owner.Source
    local first = assert(string.find(source, anchor, 1, true),
        "Real Scout playtest Dungeon source anchor missing")
    assert(not string.find(source, anchor, first + #anchor, true),
        "Real Scout playtest Dungeon source anchor ambiguous")
    owner.Source = source:sub(1, first - 1) .. replacement
        .. source:sub(first + #anchor)
end

local runtime_script = SSS.Dungeon.DungeonRuntime
local anchor = 'local runtime = RuntimeServices.new("Dungeon")'
replace_once(runtime_script, anchor, anchor
    .. '\n_G.C4ElfScoutLiveRuntime_TEMP = runtime')

local channel = Instance.new("RemoteEvent")
channel.Name = "C4ElfScoutLiveChannel_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "C4ElfScoutRealClient_TEMP"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local channel = RS:WaitForChild("C4ElfScoutLiveChannel_TEMP")
local skill_request = RS.Combat.Remotes:WaitForChild("SkillRequest")
channel.OnClientEvent:Connect(function(skill_id)
    skill_request:FireServer(skill_id)
    channel:FireServer("Sent", skill_id)
end)
channel:FireServer("Ready")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "C4ElfScoutRealClientDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Shared = RS.Core.Shared
local RuntimeState = require(SSS.Core.Services.ProgressionRuntimeState)
local Status = require(SSS.Combat.CombatStatusService)
local Cooldowns = require(SSS.Combat.SkillCooldownService)
local CombatConfig = require(RS.Combat.Shared.CombatConfig)
local channel = RS:WaitForChild("C4ElfScoutLiveChannel_TEMP")

local ready = {}
local sent = {}
channel.OnServerEvent:Connect(function(player, action, payload)
    if action == "Ready" then
        ready[player.UserId] = true
    elseif action == "Sent" then
        sent[player.UserId] = payload
    end
end)

--[[
Waits for an authentic server/client state with a bounded timeout.

Args:
    condition (() -> any): Live gameplay predicate.
    label (string): Failure diagnostic when the state is not reached.
    seconds (number): Maximum wall-clock wait before failing.

Returns:
    any: First truthy live result.
]]
local function wait_for(condition, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local result = condition()
        if result then return result end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[C4 Elf Scout Live] TIMEOUT " .. label)
end

--[[
Installs source-ranked Elf Ranger skills on a disposable admitted profile.

Args:
    runtime (any): Actual Dungeon profile and session authorities.
    player (Player): Connected authenticated Studio combat participant.

Returns:
    nil: Authoritatively updates the isolated character progression.
]]
local function prepare_character(runtime, player)
    assert(runtime.ProfileService:mutate(player.UserId, function(profile)
        local character = profile.Characters.Slot1
        character.Identity = {
            Version = 1,
            RaceId = "Elf", BaseClassId = "Ranger",
            ClassId = "Ranger", CreationStage = "Complete",
        }
        character.Level = 36
        character.Equipment.Weapon = "apprentice_longbow"
        for _, id in {
            "ElvenScoutCureWounds", "ElvenScoutBattleFocus",
            "ElvenScoutWindRun", "ElvenScoutSnaringShot",
        } do
            character.Progression.Skills[id] = {
                Known = true, PurchasedRank = 1, Proficiency = 0,
            }
        end
        character.Progression.Loadout[1] = "ElvenScoutCureWounds"
    end), "Could not prepare a server-authenticated Elf Ranger")
    RuntimeState.set_character(player.UserId,
        assert(runtime.ProfileService:get_character(player.UserId, 1)))
end

--[[
Changes only the existing combat loadout and authentic server snapshot.

Args:
    runtime (any): Real Dungeon profile authority.
    player (Player): Character owning the purchased Scout rank.
    skill_id (string): Owned source-ranked skill to equip.

Returns:
    nil: Updates the real server combat validation snapshot.
]]
local function equip_skill(runtime, player, skill_id)
    assert(runtime.ProfileService:mutate(player.UserId, function(profile)
        profile.Characters.Slot1.Progression.Loadout[1] = skill_id
    end), "Could not equip purchased Elf Scout rank")
    RuntimeState.set_character(player.UserId,
        assert(runtime.ProfileService:get_character(player.UserId, 1)))
    assert(RuntimeState.is_skill_usable(player.UserId, skill_id),
        "Actual Elf Ranger cannot use " .. skill_id)
end

--[[
Uses the normal real-client skill remote, never a direct service cast.

Args:
    player (Player): Admitted actual Studio client.
    skill_id (string): Current real equipped skill.

Returns:
    nil: Confirms that client actually submitted the requested skill.
]]
local function request_cast(player, skill_id)
    sent[player.UserId] = nil
    channel:FireClient(player, skill_id)
    wait_for(function()
        return sent[player.UserId] == skill_id
    end, "client requested " .. skill_id, 12)
end

--[[
Checks actual client-cast healing and paid cooldown against passive regen.

Args:
    runtime (any): Real profile authority.
    player (Player): Authentic injured Elf Ranger.
    humanoid (Humanoid): Actual spawned player health.

Returns:
    nil: Verifies effective self healing from the real combat request.
]]
local function verify_wounds(runtime, player, humanoid)
    equip_skill(runtime, player, "ElvenScoutCureWounds")
    humanoid.Health = math.max(1, humanoid.MaxHealth - 75)
    local before = humanoid.Health
    request_cast(player, "ElvenScoutCureWounds")
    wait_for(function()
        return humanoid.Health - before >= 38
    end, "genuine client wound-recovery HP", 12)
    assert(Cooldowns.get_remaining(
        player, "ElvenScoutCureWounds"
    ) > 6, "Wound recovery did not start its server cooldown")
    print("[C4 Elf Scout Live] REAL_CLIENT_SELF_HEAL_PASS")
    task.wait(0.8)
end

--[[
Checks actual melee AND bow attack scaling from the real cast.

Args:
    runtime (any): Real Ranger profile authority.
    player (Player): Authentic caster with purchased Battle Focus.
    character (Model): Actual spawned player character.

Returns:
    nil: Confirms status, spent stamina and combat scaling.
]]
local function verify_battle_focus(runtime, player, character)
    equip_skill(runtime, player, "ElvenScoutBattleFocus")
    local melee = RuntimeState.get_physical_multiplier(player.UserId)
    local ranged = RuntimeState.get_ranged_physical_multiplier(
        player.UserId
    )
    request_cast(player, "ElvenScoutBattleFocus")
    wait_for(function()
        return Status.get(character, "PhysicalPower") >= 0.079
    end, "actual client Battle Focus buff", 12)
    assert(RuntimeState.get_physical_multiplier(player.UserId)
        > melee + 0.07, "Battle Focus did not strengthen melee")
    assert(RuntimeState.get_ranged_physical_multiplier(player.UserId)
        > ranged + 0.07, "Battle Focus did not strengthen real bow damage")
    assert(Cooldowns.get_remaining(
        player, "ElvenScoutBattleFocus"
    ) > 17, "Battle Focus did not start its real server cooldown")
    print("[C4 Elf Scout Live] REAL_CLIENT_BOW_AND_MELEE_FOCUS_PASS")
    task.wait(0.8)
end

--[[
Checks server-controlled walking speed during and after a real buff.

Args:
    runtime (any): Actual profile and combat services.
    player (Player): Authentic Ranger with the purchased Wind Run rank.
    humanoid (Humanoid): Actual locomotion controller.

Returns:
    nil: Asserts real speed increases and expires without bypassing locks.
]]
local function verify_wind_run(runtime, player, humanoid)
    equip_skill(runtime, player, "ElvenScoutWindRun")
    local baseline = humanoid.WalkSpeed
    request_cast(player, "ElvenScoutWindRun")
    wait_for(function()
        return Status.get(player.Character, "Movement") >= 0.099
    end, "real client Wind Run status", 12)
    wait_for(function()
        return humanoid.WalkSpeed > baseline * 1.08
    end, "real WalkSpeed increase after skill recovery", 8)
    assert(Cooldowns.get_remaining(
        player, "ElvenScoutWindRun"
    ) > 17, "Wind Run did not start server cooldown")
    wait_for(function()
        return Status.get(player.Character, "Movement") == 0
            and humanoid.WalkSpeed <= baseline * 1.01
    end, "real movement bonus expiry", 15)
    print("[C4 Elf Scout Live] REAL_CLIENT_MOVEMENT_AND_EXPIRY_PASS")
end

--[[
Runs real Dungeon admission and three genuine client-to-server casts.

Args:
    None.

Returns:
    nil: Validates real play on a disposable unpublished session.
]]
local function main()
    local player = wait_for(function()
        local connected = Players:GetPlayers()
        return if #connected == 1 then connected[1] else nil
    end, "one real Studio client", 45)
    local runtime = wait_for(function()
        return _G.C4ElfScoutLiveRuntime_TEMP
    end, "real Dungeon composition", 35)
    wait_for(function()
        return ready[player.UserId]
            and runtime.ProfileService:get_character(player.UserId, 1)
            and player:GetAttribute(
                CombatConfig.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
            ) == true
            and player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
    end, "real admitted Dungeon participant", 60)
    local character = assert(player.Character)
    local humanoid = assert(character:FindFirstChildOfClass("Humanoid"))
    local root = assert(character:FindFirstChild("HumanoidRootPart"))
    root.Anchored = true
    root.CFrame = CFrame.new(0, 100, 0)
    prepare_character(runtime, player)
    print("[C4 Elf Scout Live] REAL_DUNGEON_ADMISSION_PASS")
    verify_wounds(runtime, player, humanoid)
    verify_battle_focus(runtime, player, character)
    verify_wind_run(runtime, player, humanoid)
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[C4 Elf Scout Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(145, function()
    STS:EndTest("FAIL global Elf Scout playtest timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecuteMultiplayerTestAsync(
        1, "C4ElfScoutAuthenticCombat_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Authentic Elf Scout client playtest failed: " .. tostring(result))
print("[C4 Elf Scout Live] VERIFIED_REAL_CLIENT_PASS")
