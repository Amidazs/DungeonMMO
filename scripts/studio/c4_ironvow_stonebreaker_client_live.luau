--!strict
-- Disposable true-client hotbar to server blunt shock and real NPC HP.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Warrior stun Play requires an unpublished Dungeon composition")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "TEMP_WarriorStonebreakerInput"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "TEMP_WarriorStonebreakerClient"
client.Source = [==[
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local channel = RS:WaitForChild("TEMP_WarriorStonebreakerInput")
local scripts = Players.LocalPlayer:WaitForChild("PlayerScripts")
local state = require(scripts:WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local input = require(scripts:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))
local SKILL_ID = "IronvowStonebreaker"

channel.OnClientEvent:Connect(function(action)
    if action == "LOAD" then
        state.apply_snapshot({
            Skills = {[SKILL_ID] = {Known = true, Rank = 9}},
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
driver.Name = "TEMP_WarriorStonebreakerServer"
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
local Stagger = require(SSS.Combat.StaggerService)
local channel = RS.TEMP_WarriorStonebreakerInput
local SKILL_ID = "IronvowStonebreaker"
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
    error("[Warrior Stonebreaker] No client action: " .. action)
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
    error("[Warrior Stonebreaker] No real client/avatar/training NPC")
end

--[[
Builds an internally valid, explicitly disposable earned Warrior.

Args:
    user_id (number): Current authenticated client user.
    weapon_id (string): Server-authoritative equipped item ID.

Returns:
    any: Source-receipted rank-nine owner, not a persisted quest claim.
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
    advancement.OriginalFirstTransferReceiptId = "TEMP_StonebreakerPlay"
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
        Known = true, PurchasedRank = 9, Proficiency = 0,
    }
    owner.Progression.Loadout[1] = SKILL_ID
    assert(Careers.awarded(owner) ~= nil,
        "Forged class receipt cannot seed disposable Warrior acceptance")
    return owner
end

--[[
Sends the real client's slot-one request and checks exact NPC impact.

Args:
    player (Player): Actual authenticated user.
    npc (Model): The live NPC in front of the player.
    humanoid (Humanoid): Authoritative enemy health.

Returns:
    nil: Verifies real MP spending, one damaging stun and cooldown.
]]
local function verify_cast(player, npc, humanoid)
    local owner = warrior_fixture(
        player.UserId, "stonewatch_training_mace"
    )
    Runtime.set_character(player.UserId, owner)
    local usable, reason = Runtime.is_skill_usable(
        player.UserId, SKILL_ID
    )
    assert(usable, "Earned blunt skill unusable: " .. tostring(reason))
    player:SetAttribute("DungeonCombatAllowed", true)
    local root = assert(player.Character:FindFirstChild(
        "HumanoidRootPart"
    ))
    local target_root = assert(npc:FindFirstChild(
        "HumanoidRootPart"
    ))
    root.CFrame = CFrame.lookAt(
        target_root.Position + Vector3.new(0, 0, 3.8),
        target_root.Position
    )
    root.AssemblyLinearVelocity = Vector3.zero
    Mana.reset_player(player)
    humanoid.MaxHealth = 1000
    humanoid.Health = 500
    Stagger.clear(npc)
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD")
    assert(await_receipt(player, "LOADED").accepted,
        "Real client's hotbar did not load purchased blunt skill")
    local starting_mana = Mana.get(player)
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Real client refused to send source Warrior skill request")
    local deadline = os.clock() + 7
    repeat
        if humanoid.Health < 499 and Stagger.is_staggered(npc) then
            break
        end
        task.wait(0.03)
    until os.clock() >= deadline
    assert(humanoid.Health < 499 and Stagger.is_staggered(npc),
        "Real client cast did not damage and shock an actual NPC")
    local remaining = Stagger.get_remaining(npc)
    local spent = starting_mana - Mana.get(player)
    assert(spent >= 29 and spent <= 30.5,
        "Real client cast did not spend source rank-nine 30 MP")
    print("[Warrior Stonebreaker] REAL_CLIENT_NPC_HP_STUN_MP_PASS "
        .. tostring(500 - humanoid.Health) .. "HP "
        .. tostring(spent) .. "MP " .. tostring(remaining) .. "s")
    local after_hit = humanoid.Health
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Actual client could not submit cooldown-rejected follow-up")
    task.wait(0.22)
    assert(math.abs(humanoid.Health - after_hit) < 0.001,
        "Premature second blunt cast bypassed skill cooldown")
    owner.Equipment.Weapon = "marauder_sword"
    Runtime.set_character(player.UserId, owner)
    assert(not Runtime.is_skill_usable(player.UserId, SKILL_ID),
        "Real sword equipment falsely qualified for blunt-only control")
    owner.Identity.ClassId = "Fighter"
    owner.Equipment.Weapon = "stonewatch_training_mace"
    Runtime.set_character(player.UserId, owner)
    assert(not Runtime.is_skill_usable(player.UserId, SKILL_ID),
        "Unawarded Fighter inherited bought Warrior blunt control")
    Runtime.clear_character(player.UserId)
    print("[Warrior Stonebreaker] ALL_REAL_CLIENT_AUTHORITY_PASS")
end

--[[
Runs this disposable true-client and NPC attack proof without publishing.

Args:
    None.

Returns:
    nil: Ends Studio play only after actual MP, HP, stun and gates pass.
]]
local function main()
    local player, npc, humanoid = live_target()
    task.wait(2)
    verify_cast(player, npc, humanoid)
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[Warrior Stonebreaker] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(70, function()
    STS:EndTest("FAIL Stonebreaker client Play global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_WarriorStonebreakerPlay")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Real Warrior blunt client Play failed: " .. tostring(result))
print("[Warrior Stonebreaker] VERIFIED_PLAY_MODE_PASS")
