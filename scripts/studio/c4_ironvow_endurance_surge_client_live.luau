--!strict
-- Unpublished genuine client to server Warrior max-HP surge acceptance.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Warrior surge Play requires a disposable unpublished Dungeon")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "TEMP_WarriorSurgeInput"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "TEMP_WarriorSurgeClient"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local channel = RS:WaitForChild("TEMP_WarriorSurgeInput")
local scripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
local state = require(scripts:WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local input = require(scripts:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))
local SKILL_ID = "IronvowEnduranceSurge"

channel.OnClientEvent:Connect(function(action)
    if action == "LOAD" then
        state.apply_snapshot({
            Skills = {[SKILL_ID] = {Known = true, Rank = 1}},
            Loadout = {[1] = SKILL_ID},
        })
        channel:FireServer(
            "LOADED", state.get_skill_for_slot(1) == SKILL_ID
        )
    elseif action == "CAST" then
        channel:FireServer("CAST", input.request_skill_slot(1))
    end
end)
channel:FireServer("READY", true)
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "TEMP_WarriorSurgeServer"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Schema = require(RS.Core.Shared.ProfileSchema)
local Stages = require(RS.Core.Shared.C4OriginalFirstTransferQuestStages)
local Careers = require(RS.Core.Shared.OriginalFirstTransferDefinitions)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Mana = require(SSS.Combat.ManaService)
local Damage = require(SSS.Combat.DamageService)
local Surge = require(SSS.Combat.IronvowEnduranceSurgeService)
local channel = RS.TEMP_WarriorSurgeInput
local SKILL_ID = "IronvowEnduranceSurge"
local receipts = {}

channel.OnServerEvent:Connect(function(player, action, accepted)
    receipts[player.UserId] = {action = action, accepted = accepted}
end)

--[[
Waits for the actual player's client action; never fabricates success.

Args:
    player (Player): Authenticated live user who sent the input.
    action (string): Action receipt expected from the real client.

Returns:
    any: Latest matching receipt or a strict timeout.
]]
local function await_receipt(player, action)
    local deadline = os.clock() + 12
    repeat
        local receipt = receipts[player.UserId]
        if receipt and receipt.action == action then return receipt end
        task.wait(0.06)
    until os.clock() >= deadline
    error("[Warrior Surge] Missing client receipt: " .. action)
end

local function warrior_fixture(user_id, weapon_id)
    local owner = Schema.create_default(user_id).Characters.Slot1
    local source = assert(Stages.get("HumanWarrior"))
    owner.Level = 28
    owner.Identity = {
        Version = 1, RaceId = "Human", BaseClassId = "Fighter",
        ClassId = "Ironvow", CreationStage = "Complete",
    }
    local advancement = owner.ClassAdvancement
    advancement.ActiveClassId = nil
    advancement.OriginalFirstTransferChoiceId = "HumanWarrior"
    advancement.OriginalFirstTransferClassId = "Ironvow"
    advancement.OriginalFirstTransferReceiptId = "TEMP_EnduranceSurgePlay"
    local proofs = {}
    for _, proof_id in ipairs(source.RequiredProofIds) do
        proofs[proof_id] = true
    end
    advancement.OriginalFirstTransferQuest = {
        QuestId = source.Id, BranchId = "HumanWarrior",
        Step = #source.Steps + 1, Ready = true,
        Count = 0, Proofs = proofs, AppliedEvents = {},
    }
    owner.Equipment.Weapon = weapon_id
    owner.Progression.Skills.IronvowBladeTraining = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    owner.Progression.Skills[SKILL_ID] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    owner.Progression.Loadout[1] = SKILL_ID
    assert(Careers.awarded(owner) ~= nil,
        "Forged class receipt cannot seed disposable Warrior acceptance")
    return owner
end


--[[
Ensures that the actual Player.Character is alive and in the world.

Args:
    None.

Returns:
    (Player, Model, Humanoid): Genuine connected, spawned Play avatar.
]]
local function live_owner()
    local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    await_receipt(player, "READY")
    local character = player.Character or player.CharacterAdded:Wait()
    if not character.Parent then
        player:LoadCharacter()
        character = player.Character or player.CharacterAdded:Wait()
    end
    local deadline = os.clock() + 15
    while not character.Parent and os.clock() < deadline do
        task.wait(0.08)
    end
    assert(character.Parent == workspace,
        "Surge must use a real world-parented player character")
    local humanoid = character:WaitForChild("Humanoid")
    assert(humanoid.Health > 0, "Surge requires a living player")
    return player, character, humanoid
end

--[[
Exercises actual client input, owner HP/MP, nonstacking and buff removal.

Args:
    player (Player): Real local client and authenticated user.
    character (Model): The same live world-spawned player character.
    humanoid (Humanoid): Authoritative player HP and maximum health.

Returns:
    nil: Reports PASS only after owned server combat calculations pass.
]]
local function verify_surge(player, character, humanoid)
    local owner = warrior_fixture(
        player.UserId, "stonewatch_training_mace"
    )
    Runtime.set_character(player.UserId, owner)
    player:SetAttribute("DungeonCombatAllowed", true)
    assert(Runtime.is_skill_usable(player.UserId, SKILL_ID),
        "Earned Warrior does not own the learned HP-surge skill")
    Runtime.apply_max_health(player)
    Mana.reset_player(player)
    local previous_parent = character.Parent
    local before_detach_mp = Mana.get(player)
    character.Parent = game:GetService("ServerStorage")
    assert(not Surge.can_activate(player)
        and Mana.get(player) == before_detach_mp,
        "A stored avatar passed the paid-surge preflight")
    character.Parent = previous_parent
    assert(Surge.can_activate(player),
        "A restored living world character failed surge preflight")
    print("[Warrior Surge] STORED_CHARACTER_PRECHARGE_DENIAL_PASS")
    local base_max = humanoid.MaxHealth
    assert(base_max > 20, "Expected living baseline character health")
    humanoid.Health = base_max * 0.55
    local start_hp = humanoid.Health
    local start_mp = Mana.get(player)
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD")
    assert(await_receipt(player, "LOADED").accepted,
        "Actual client could not select purchased surge")
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Actual client did not send its surge hotbar request")
    local deadline = os.clock() + 5
    repeat
        if Surge.get_bonus(player) > 0 then break end
        task.wait(0.04)
    until os.clock() >= deadline
    assert(math.abs(Surge.get_bonus(player) - 0.10) < 0.001,
        "Real client did not apply server-owned source max HP")
    local increased_max = humanoid.MaxHealth
    local expected_hp = start_hp + increased_max * 0.10
    assert(math.abs(increased_max - base_max * 1.10) < 0.1
        and math.abs(humanoid.Health - expected_hp) < 0.2,
        "Surge must add ten percent max HP and heal only once")
    local spent = start_mp - Mana.get(player)
    assert(spent >= 12.9 and spent < 14,
        "Real cast did not spend precisely its thirteen MP")
    local issued_expiry = character:GetAttribute(
        "IronvowEnduranceExpiresAt"
    )
    assert(type(issued_expiry) == "number"
        and issued_expiry - os.clock() > 590
        and issued_expiry - os.clock() <= 600,
        "Server did not issue source ten-minute expiry")

    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    await_receipt(player, "CAST")
    task.wait(0.17)
    assert(math.abs(humanoid.Health - expected_hp) < 0.25
        and math.abs(humanoid.MaxHealth - increased_max) < 0.1
        and character:GetAttribute(
            "IronvowEnduranceExpiresAt"
        ) == issued_expiry
        and Surge.can_activate(player) == false,
        "Repeat cast duplicated healing, stacked max HP or reset expiry")

    local before_damage = humanoid.Health
    local applied = Damage.apply_damage({
        attacker = nil,
        target = character,
        source_kind = "EnemyMelee",
        source_id = "TEMP_WarriorSurgeHostileHit",
        base_damage = 100, multiplier = 1,
    })
    assert(applied >= 20
        and math.abs(before_damage - humanoid.Health - applied) < 0.1,
        "HP surge must not turn enemy melee into invulnerability")

    owner.Progression.Skills[SKILL_ID].PurchasedRank = 0
    Runtime.set_character(player.UserId, owner)
    assert(Surge.get_bonus(player) == 0
        and math.abs(humanoid.MaxHealth - base_max) < 0.1
        and character:GetAttribute("IronvowEnduranceActive") == false,
        "Revoked rank retained a stale or stacked max-HP buff")
    owner.Progression.Skills[SKILL_ID].PurchasedRank = 1
    owner.Identity.ClassId = "Fighter"
    Runtime.set_character(player.UserId, owner)
    assert(not Runtime.is_skill_usable(player.UserId, SKILL_ID)
        and Surge.get_bonus(player) == 0,
        "Copied Fighter gained earned Warrior max-HP protection")
    Runtime.clear_character(player.UserId)
    Surge.stop(player)
    print("[Warrior Surge] REAL_CLIENT_HP_MP_NONSTACK_REVOKE_PASS "
        .. "baseMax=" .. tostring(base_max)
        .. " buffedMax=" .. tostring(increased_max)
        .. " restored=" .. tostring(expected_hp - start_hp)
        .. " enemyDamage=" .. tostring(applied))
end

--[[
Runs the disposable real-client skill and HP combat acceptance.

Args:
    None.

Returns:
    nil: Ends Play with an explicit failure on any missing proof.
]]
local function main()
    local player, character, humanoid = live_owner()
    task.wait(1)
    verify_surge(player, character, humanoid)
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[Warrior Surge] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(75, function()
    STS:EndTest("FAIL Warrior surge Play global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_WarriorEnduranceSurge")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Warrior HP surge true-client Play failed: " .. tostring(result))
print("[Warrior Surge] VERIFIED_PLAY_MODE_PASS")
