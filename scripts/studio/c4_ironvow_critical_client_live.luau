--!strict
-- Disposable true-client hotbar to server blunt shock and real NPC HP.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Warrior critical Play requires an unpublished Dungeon composition")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "TEMP_WarriorCriticalInput"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "TEMP_WarriorCriticalClient"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local channel = RS:WaitForChild("TEMP_WarriorCriticalInput")
local scripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
local state = require(scripts:WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local input = require(scripts:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))
local SKILL_ID = "IronvowCriticalStance"

channel.OnClientEvent:Connect(function(action)
    if action == "LOAD" then
        state.apply_snapshot({
            Skills = {[SKILL_ID] = {Known = true, Rank = 3}},
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
driver.Name = "TEMP_WarriorCriticalServer"
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
local Critical = require(SSS.Combat.IronvowCriticalToggleService)
local ActiveSource = require(SSS.Core.Services.C4ActiveSourceEffectState)
local channel = RS.TEMP_WarriorCriticalInput
local SKILL_ID = "IronvowCriticalStance"
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
    error("[Warrior Critical] No client action: " .. action)
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
    error("[Warrior Critical] No real client/avatar/training NPC")
end

--[[
Builds an internally valid, explicitly disposable earned Warrior.

Args:
    user_id (number): Current authenticated client user.
    weapon_id (string): Server-authoritative equipped item ID.

Returns:
    any: Source-receipted rank-three owner, not a persisted quest claim.
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
        Known = true, PurchasedRank = 3, Proficiency = 0,
    }
    owner.Progression.Loadout[1] = SKILL_ID
    assert(Careers.awarded(owner) ~= nil,
        "Forged class receipt cannot seed disposable Warrior acceptance")
    return owner
end

--[[
Applies a server-known guaranteed-critical melee impact against a real NPC.

Args:
    player (Player): Authenticated genuine local client.
    npc (Model): Real spawned training NPC with actual Humanoid HP.

Returns:
    number: Actual health lost to one real server-owned melee impact.
]]
local function critical_hit(player, npc)
    local humanoid = assert(npc:FindFirstChildOfClass("Humanoid"))
    local before = humanoid.Health
    local applied = Damage.apply_damage({
        attacker = player,
        attacker_character = player.Character,
        target = npc,
        source_kind = "Melee",
        source_id = "TEMP_CriticalImpact",
        base_damage = 50,
        multiplier = 1,
        critical_chance = 1,
        critical_roll = 0,
        critical_damage_multiplier =
            Runtime.get_critical_damage_multiplier(player.UserId),
    })
    assert(applied > 0, "Guaranteed critical did not hit real NPC HP")
    assert(math.abs(before - humanoid.Health - applied) < 0.01,
        "Reported critical must equal actual NPC health removed")
    return applied
end

--[[
Verifies real hotbar toggle, continuous MP, increased NPC critical
damage and authorization cancellation after source ownership is revoked.

Args:
    player (Player): Real local user, not a forged client identity.
    npc (Model): Real combat-training NPC with a living Humanoid.

Returns:
    nil: Requires actual owner MP spend, HP change and status cleanup.
]]
local function verify_cast(player, npc)
    local owner = warrior_fixture(
        player.UserId, "stonewatch_training_mace"
    )
    Runtime.set_character(player.UserId, owner)
    local usable, reason = Runtime.is_skill_usable(
        player.UserId, SKILL_ID
    )
    assert(usable, "Earned Warrior toggle unusable: " .. tostring(reason))
    player:SetAttribute("DungeonCombatAllowed", true)
    Mana.reset_player(player)
    local humanoid = assert(npc:FindFirstChildOfClass("Humanoid"))
    humanoid.MaxHealth = 2500
    humanoid.Health = 2200
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD")
    assert(await_receipt(player, "LOADED").accepted,
        "Client cannot select its paid critical stance")
    local unbuffed = critical_hit(player, npc)
    local starting_mana = Mana.get(player)
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Actual client cannot request purchased MP critical stance")
    local deadline = os.clock() + 5
    repeat
        if Critical.get_bonus(player) > 0 then break end
        task.wait(0.04)
    until os.clock() > deadline
    assert(math.abs(Critical.get_bonus(player) - 0.064) < 0.0001,
        "Paid source rank-three bonus was not activated by client")
    local source_active = ActiveSource.snapshot(player)
    assert(source_active.ActiveCount == 1
        and source_active.SourceRanks[1].SkillId == 312
        and source_active.SourceRanks[1].Rank == 3,
        "Live critical toggle did not register C4 source 312 rank 3")
    local active_mana = Mana.get(player)
    assert(starting_mana - active_mana >= 4.9,
        "Rank-three stance activation did not spend five actual MP")
    local buffed = critical_hit(player, npc)
    assert(math.abs(buffed - unbuffed - 3.2) < 0.05,
        "C4 critical toggle failed real server critical NPC damage")
    task.wait(1.2)
    local after_upkeep = Mana.get(player)
    assert(active_mana - after_upkeep >= 1.9,
        "Active stance did not drain two genuine MP during upkeep")
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Real client cannot deactivate its own critical toggle")
    task.wait(0.13)
    assert(Critical.get_bonus(player) == 0,
        "Critical stance did not turn off on second client request")
    assert(ActiveSource.snapshot(player).ActiveCount == 0,
        "Deactivated critical stance remained in C4 source state")
    local after_off = critical_hit(player, npc)
    assert(math.abs(after_off - unbuffed) < 0.05,
        "Deactivated stance still deals extra real NPC critical damage")
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Client cannot reactivate purchased stance")
    task.wait(0.16)
    assert(Critical.get_bonus(player) > 0,
        "Reactivated stance was not owned by real caster")
    -- Removing the server-owned purchase must revoke the active effect
    -- without ever trusting a replicated attribute from the client.
    owner.Progression.Skills[SKILL_ID].PurchasedRank = 0
    Runtime.set_character(player.UserId, owner)
    assert(Critical.get_bonus(player) == 0,
        "Revoking actual paid rank leaves critical bonus active")
    assert(ActiveSource.snapshot(player).ActiveCount == 0,
        "Revoked critical ownership left stale C4 source state")
    owner.Progression.Skills[SKILL_ID].PurchasedRank = 3
    owner.Identity.ClassId = "Fighter"
    Runtime.set_character(player.UserId, owner)
    assert(not Runtime.is_skill_usable(player.UserId, SKILL_ID),
        "Copied unawarded Fighter can inherit Warrior critical bonus")
    Runtime.clear_character(player.UserId)
    print("[Warrior Critical] REAL_CLIENT_MP_NPC_CRIT_REVOKE_PASS "
        .. tostring(unbuffed) .. "->" .. tostring(buffed))
end

--[[
Runs local unpublished client Play without changing production saves.

Args:
    None.

Returns:
    nil: Ends only when the genuine client/HP/mana tests pass.
]]
local function main()
    local player, npc = live_target()
    task.wait(2)
    verify_cast(player, npc)
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then warn("[Warrior Critical] FAIL " .. tostring(reason)) end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(75, function()
    STS:EndTest("FAIL Warrior critical Play global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_WarriorCriticalPlay")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Real Warrior critical client Play failed: " .. tostring(result))
print("[Warrior Critical] VERIFIED_PLAY_MODE_PASS")
