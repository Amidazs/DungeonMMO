--!strict
-- Real unpublished Dungeon client exercises paid C4 Accuracy hit/miss.
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
local Stamina = require(SSS.Combat.StaminaService)
local Toggle = require(SSS.Combat.ScoutAccuracyToggleService)
local Damage = require(SSS.Combat.DamageService)
local CollectionService = game:GetService("CollectionService")
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
        character.Level = 24
        character.Equipment.Weapon = "apprentice_longbow"
        character.Progression.Skills.ScoutAccuracyToggle = {
            Known = true, PurchasedRank = 1, Proficiency = 0,
        }
        character.Progression.Loadout[1] = "ScoutAccuracyToggle"
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
Creates a tagged NPC with a server-authored 12% physical evasion.

Args:
    None.

Returns:
    Model: Disposable, living server-owned physical attack target.
]]
local function make_target()
    local target = Instance.new("Model")
    target.Name = "C4AccuracyEvasiveNPC_TEMP"
    target:SetAttribute("CombatEvasionChance", 0.12)
    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 300
    humanoid.Health = 300
    humanoid.Parent = target
    target.Parent = workspace
    CollectionService:AddTag(
        target, CombatConfig.TARGETS.NPC_TAG
    )
    return target
end

--[[
Runs the same deterministic server-owned physical attack roll.

Args:
    player (Player): Real authorized attacker from the Dungeon client.
    target (Model): Living tagged evasive NPC.
    kind (string): Existing physical melee or ranged damage path.

Returns:
    number: Health damage actually applied by the combat damage service.
]]
local function attempt_hit(player, target, kind)
    return Damage.apply_damage({
        attacker = player,
        attacker_character = assert(player.Character),
        target = target,
        source_kind = kind,
        source_id = "C4AccuracyLiveVerification",
        base_damage = 10,
        multiplier = 1,
        accuracy_roll = 0.9,
    })
end

--[[
Verifies an actual client activation changes real melee and bow hits.

Args:
    runtime (any): Authentic Dungeon profile and skill authorities.
    player (Player): Admitted real Elf Ranger Studio participant.
    character (Model): Original spawned player character.

Returns:
    nil: Validates miss, hit, upkeep, off and automatic exhaustion.
]]
local function verify_accuracy_toggle(runtime, player, character)
    equip_skill(runtime, player, "ScoutAccuracyToggle")
    Stamina.reset_player(player)
    local target = make_target()
    assert(Toggle.get_bonus(player) == 0,
        "Buying Accuracy incorrectly granted a permanent hit bonus")
    assert(attempt_hit(player, target, "Melee") == 0,
        "Unactivated Accuracy bypassed actual NPC evasion")
    assert(attempt_hit(player, target, "RangedPhysical") == 0,
        "Unactivated Accuracy bypassed real bow damage resolution")
    print("[C4 Scout Accuracy Live] REAL_UNACTIVATED_MISSES_PASS")

    request_cast(player, "ScoutAccuracyToggle")
    wait_for(function()
        return character:GetAttribute("C4ScoutAccuracyActive")
            == true and Toggle.get_bonus(player) > 0.119
    end, "real client activated paid Accuracy", 12)
    assert(attempt_hit(player, target, "Melee") >= 9.9,
        "Paid Accuracy failed to convert a real melee miss to a hit")
    assert(attempt_hit(player, target, "RangedPhysical") >= 9.9,
        "Paid Accuracy failed to convert the same bow miss to a hit")
    local after_cast = Stamina.get(player)
    task.wait(1.4)
    assert(Stamina.get(player) <= after_cast - 2.9,
        "Active Accuracy did not consume actual continuous stamina")
    print("[C4 Scout Accuracy Live] REAL_MELEE_BOW_HITS_UPKEEP_PASS")

    request_cast(player, "ScoutAccuracyToggle")
    wait_for(function()
        return character:GetAttribute("C4ScoutAccuracyActive")
            == false and Toggle.get_bonus(player) == 0
    end, "real client turned Accuracy off", 12)
    assert(attempt_hit(player, target, "Melee") == 0,
        "Turning Accuracy off failed to restore actual missed attacks")
    print("[C4 Scout Accuracy Live] CLIENT_OFF_HIT_REVOCATION_PASS")

    Stamina.reset_player(player)
    task.wait(0.35)
    request_cast(player, "ScoutAccuracyToggle")
    wait_for(function()
        return Toggle.get_bonus(player) > 0
    end, "client reactivated Accuracy", 12)
    local available = Stamina.get(player)
    assert(Stamina.try_spend(player, available - 1),
        "Disposable client could not spend its remaining stamina")
    wait_for(function()
        return Toggle.get_bonus(player) == 0
            and character:GetAttribute("C4ScoutAccuracyActive") == false
    end, "Accuracy must switch off on real resource exhaustion", 4)
    assert(attempt_hit(player, target, "RangedPhysical") == 0,
        "Exhaustion left an unauthorized ranged accuracy bonus")
    print("[C4 Scout Accuracy Live] RESOURCE_EXHAUSTION_PASS")
    target:Destroy()
end

--[[
Runs real Dungeon admission and paid critical-power client toggling.

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
    local root = assert(character:FindFirstChild("HumanoidRootPart"))
    root.Anchored = true
    root.CFrame = CFrame.new(0, 100, 0)
    prepare_character(runtime, player)
    print("[C4 Elf Scout Live] REAL_DUNGEON_ADMISSION_PASS")
    verify_accuracy_toggle(runtime, player, character)
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
        1, "C4ScoutAccuracyAuthenticClient_TEMP"
    )
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Authentic Elf Scout client playtest failed: " .. tostring(result))
print("[C4 Scout Accuracy Live] VERIFIED_REAL_CLIENT_ACCURACY_PASS")
