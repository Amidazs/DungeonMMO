--!strict
-- Disposable true-client hotbar to server blunt shock and real NPC HP.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Warrior critical Play requires an unpublished Dungeon composition")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "TEMP_WarriorAccuracyInput"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "TEMP_WarriorAccuracyClient"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local channel = RS:WaitForChild("TEMP_WarriorAccuracyInput")
local scripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
local state = require(scripts:WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local input = require(scripts:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))
local SKILL_ID = "IronvowAccuracyStance"

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
driver.Name = "TEMP_WarriorAccuracyServer"
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
local Accuracy = require(SSS.Combat.IronvowAccuracyToggleService)
local channel = RS.TEMP_WarriorAccuracyInput
local SKILL_ID = "IronvowAccuracyStance"
local receipts = {}

channel.OnServerEvent:Connect(function(player, action, accepted)
    receipts[player.UserId] = {action = action, accepted = accepted}
end)

--[[
Waits for a genuine client hotbar action's server acknowledgement.

Args:
    player (Player): Authenticated actual test player.
    action (string): Required action from the client.

Returns:
    any: Matching real client receipt or an explicit timeout.
]]
local function await_receipt(player, action)
    local deadline = os.clock() + 14
    repeat
        local receipt = receipts[player.UserId]
        if receipt and receipt.action == action then return receipt end
        task.wait(0.07)
    until os.clock() >= deadline
    error("[Warrior Accuracy] No client action: " .. action)
end

--[[
Waits for the live player and a physically spawned training NPC.

Args:
    None.

Returns:
    (Player, Model, Humanoid): Real client, world NPC and NPC HP.
]]
local function live_target()
    local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    await_receipt(player, "READY")
    local deadline = os.clock() + 35
    repeat
        local npc = workspace:FindFirstChild("TrainingDummy")
        local humanoid = npc and npc:FindFirstChildOfClass("Humanoid")
        if player.Character and player.Character:FindFirstChild(
            "HumanoidRootPart"
        ) and humanoid and humanoid.Health > 0
        then return player, npc, humanoid end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Warrior Accuracy] No real client/avatar/training NPC")
end

--[[
Builds an internally valid, explicitly disposable earned Warrior.

Args:
    user_id (number): Current authenticated client user.
    weapon_id (string): Server-authoritative equipped item ID.

Returns:
    any: Source-receipted rank-one owner, not a persisted quest claim.
]]
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
    advancement.OriginalFirstTransferReceiptId = "TEMP_CriticalStancePlay"
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
Applies a physically real server NPC hit using a deterministic evasion roll.

Args:
    player (Player): Real authenticated local client.
    npc (Model): Actual tagged training NPC with server-owned HP.

Returns:
    number: Actual NPC HP loss; zero if its server-owned evasion wins.
]]
local function test_hit(player, npc)
    local humanoid = assert(npc:FindFirstChildOfClass("Humanoid"))
    local before = humanoid.Health
    local applied = Damage.apply_damage({
        attacker = player,
        attacker_character = player.Character,
        target = npc,
        source_kind = "Melee",
        source_id = "TEMP_WarriorAccuracyImpact",
        base_damage = 50,
        multiplier = 1,
        accuracy_roll = 0.815,
    })
    assert(math.abs(before - humanoid.Health - applied) < 0.05,
        "NPC physical hit result does not match actual lost health")
    return applied
end

--[[
Proves real client toggle and real NPC evasion with 1-MP activation.

Args:
    player (Player): Actual authenticated local client.
    npc (Model): Actual registered training NPC.

Returns:
    nil: Verifies an otherwise evaded attack hits only while paid MP.
]]
local function verify_cast(player, npc)
    local owner = warrior_fixture(
        player.UserId, "stonewatch_training_mace"
    )
    Runtime.set_character(player.UserId, owner)
    local usable, reason = Runtime.is_skill_usable(
        player.UserId, SKILL_ID
    )
    assert(usable, "Earned Accuracy unusable: " .. tostring(reason))
    player:SetAttribute("DungeonCombatAllowed", true)
    Mana.reset_player(player)
    local humanoid = assert(npc:FindFirstChildOfClass("Humanoid"))
    humanoid.MaxHealth = 2000
    humanoid.Health = 1800
    local CollectionService = game:GetService("CollectionService")
    local CombatConfig = require(RS.Combat.Shared.CombatConfig)
    CollectionService:AddTag(npc, CombatConfig.TARGETS.NPC_TAG)
    npc:SetAttribute("CombatEvasionChance", 0.20)
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD")
    assert(await_receipt(player, "LOADED").accepted,
        "Real hotbar did not load paid rank-one Warrior accuracy")
    assert(test_hit(player, npc) == 0,
        "Unbuffed guaranteed missed attack unexpectedly hit NPC")
    local before_mp = Mana.get(player)
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Actual client cannot activate paid accuracy stance")
    local deadline = os.clock() + 5
    repeat
        if Accuracy.get_bonus(player) > 0 then break end
        task.wait(0.05)
    until os.clock() >= deadline
    assert(math.abs(Accuracy.get_bonus(player) - 0.03) < 0.0001,
        "Source +3 Accuracy does not apply true server-owned hit chance")
    local active_mp = Mana.get(player)
    assert(before_mp - active_mp >= 0.9,
        "Source one-MP accuracy activation did not spend real mana")
    assert(math.abs(test_hit(player, npc) - 50) < 0.05,
        "Source Accuracy failed real previously-evasive NPC health")
    task.wait(1.2)
    assert(active_mp - Mana.get(player) >= 1.9,
        "Active Accuracy did not spend continuously owned MP")
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Real client could not turn off accuracy stance")
    task.wait(0.14)
    assert(Accuracy.get_bonus(player) == 0
        and test_hit(player, npc) == 0,
        "Disabled stance grants unpaid NPC hit chance")
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Client could not reactivate earned accuracy stance")
    task.wait(0.15)
    assert(Accuracy.get_bonus(player) > 0,
        "Reactivated Accuracy did not belong to the genuine player")
    owner.Progression.Skills[SKILL_ID].PurchasedRank = 0
    Runtime.set_character(player.UserId, owner)
    assert(Accuracy.get_bonus(player) == 0,
        "Revoked paid rank leaves live Accuracy effect active")
    owner.Progression.Skills[SKILL_ID].PurchasedRank = 1
    owner.Identity.ClassId = "Fighter"
    Runtime.set_character(player.UserId, owner)
    assert(not Runtime.is_skill_usable(player.UserId, SKILL_ID),
        "Unawarded Fighter inherited paid Warrior Accuracy")
    Runtime.clear_character(player.UserId)
    print("[Warrior Accuracy] REAL_CLIENT_MP_NPC_HIT_REVOKE_PASS")
end

--[[
Runs one disposable unpublished real-client Accuracy acceptance play.

Args:
    None.

Returns:
    nil: Ends only after genuine MP, actual enemy HP and rank denial.
]]
local function main()
    local player, npc = live_target()
    task.wait(2)
    verify_cast(player, npc)
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then warn("[Warrior Accuracy] FAIL " .. tostring(reason)) end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(75, function()
    STS:EndTest("FAIL Warrior accuracy Play global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_WarriorAccuracyPlay")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Real Warrior accuracy client Play failed: " .. tostring(result))
print("[Warrior Accuracy] VERIFIED_PLAY_MODE_PASS")
