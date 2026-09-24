--!strict
-- Unpublished Studio Play: client-cast Knight life drain heals on actual hit.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Knight life-drain acceptance requires an unpublished Dungeon")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "TEMP_KnightDrainInput"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "TEMP_KnightDrainClient"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local channel = RS:WaitForChild("TEMP_KnightDrainInput")
local scripts = player:WaitForChild("PlayerScripts")
local state = require(scripts:WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local input = require(scripts:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))
local SKILL_ID = "OathguardUmbralSiphon"

channel.OnClientEvent:Connect(function(action, rank)
    if action == "LOAD" then
        state.apply_snapshot({
            Skills = {[SKILL_ID] = {Known = true, Rank = rank}},
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
driver.Name = "TEMP_KnightDrainServer"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local Schema = require(RS.Core.Shared.ProfileSchema)
local Stages = require(RS.Core.Shared.C4OriginalFirstTransferQuestStages)
local Careers = require(
    RS.Core.Shared.OriginalFirstTransferDefinitions
)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Mana = require(SSS.Combat.ManaService)
local channel = RS:WaitForChild("TEMP_KnightDrainInput")
local SKILL_ID = "OathguardUmbralSiphon"
local EPSILON = 0.05
local receipts = {}

channel.OnServerEvent:Connect(function(player, action, accepted)
    receipts[player.UserId] = {action = action, accepted = accepted}
end)

--[[
Waits for an actual client-issued receipt with a bounded timeout.

Args:
    player (Player): Authenticated live player.
    action (string): Expected client acknowledgement.

Returns:
    any: The true client's matching response.
]]
local function await_receipt(player, action)
    local deadline = os.clock() + 14
    repeat
        local result = receipts[player.UserId]
        if result and result.action == action then return result end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Knight Drain] Client did not acknowledge " .. action)
end

--[[
Waits for the real local player and a server-owned training target.

Args:
    None.

Returns:
    (Player, Model, Humanoid, Model, Humanoid): Actual players and HP.
]]
local function live_targets()
    local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    await_receipt(player, "READY")
    local deadline = os.clock() + 35
    repeat
        local model = player.Character
        local humanoid = model
            and model:FindFirstChildOfClass("Humanoid")
        local target = Workspace:FindFirstChild("TrainingDummy")
        local npc = target and target:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 and npc
            and npc.Health > 0 and model:FindFirstChild("HumanoidRootPart")
            and target:FindFirstChild("HumanoidRootPart")
        then
            return player, model, humanoid, target, npc
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Knight Drain] Real player or combat dummy never spawned")
end

--[[
Creates a disposable, internally valid Knight with owned source receipts.

The profile is a test fixture: natural physical class award and real
trainer purchase are verified by their separate dedicated test suites.

Args:
    user_id (number): Authenticated local Play user.
    rank (number): Unused shield mastery rank.
    offhand (string?): Unused shield item.

Returns:
    any: Isolated, personally awarded first-transfer owner snapshot.
]]
local function knight_fixture(user_id, rank, offhand)
    local character = Schema.create_default(user_id).Characters.Slot1
    local source = assert(Stages.get("HumanKnight"))
    character.Level = 28
    character.Identity = {
        Version = 1, RaceId = "Human", BaseClassId = "Fighter",
        ClassId = "Oathguard", CreationStage = "Complete",
    }
    local advancement = character.ClassAdvancement
    advancement.ActiveClassId = nil
    advancement.OriginalFirstTransferChoiceId = "HumanKnight"
    advancement.OriginalFirstTransferClassId = "Oathguard"
    advancement.OriginalFirstTransferReceiptId = "TEMP_KnightDrainPlay"
    local proofs = {}
    for _, proof_id in ipairs(source.RequiredProofIds) do
        proofs[proof_id] = true
    end
    advancement.OriginalFirstTransferQuest = {
        QuestId = source.Id, BranchId = "HumanKnight",
        Step = #source.Steps + 1, Ready = true,
        Count = 0, Proofs = proofs, AppliedEvents = {},
    }
    character.Progression.Skills.OathguardShieldMastery = {
        Known = true, PurchasedRank = rank, Proficiency = 0,
    }
    character.Equipment.OffHand = offhand
    assert(Careers.awarded(character) ~= nil,
        "Synthetic source receipts must pass real class validation")
    return character
end


--[[
Seeds server-authoritative purchased rank without any client-supplied stats.

Args:
    player (Player): Genuine local player.
    rank (number): Source level-20 rank one or level-28 rank seven.

Returns:
    nil: Updates real server progression, mana and hotbar ownership.
]]
local function seed_rank(player, rank)
    local owner = knight_fixture(player.UserId, 0, nil)
    owner.Level = if rank == 1 then 20 else 28
    owner.Equipment.Weapon = "marauder_sword"
    owner.Progression.Skills[SKILL_ID] = {
        Known = true, PurchasedRank = rank, Proficiency = 0,
    }
    owner.Progression.Loadout[1] = SKILL_ID
    Runtime.set_character(player.UserId, owner)
    local usable, reason = Runtime.is_skill_usable(
        player.UserId, SKILL_ID
    )
    assert(usable, "Knight rank rejected: " .. tostring(reason))
    Mana.reset_player(player)
end

--[[
Faces the real training dummy from within genuine projectile range.

Args:
    player (Player): Caster character to move for this test.
    target (Model): Server-owned training NPC.

Returns:
    nil: Gives the skill an unobstructed real raycast target.
]]
local function face_target(player, target)
    local root = assert(player.Character:FindFirstChild(
        "HumanoidRootPart"
    ))
    local npc_root = assert(target:FindFirstChild(
        "HumanoidRootPart"
    ))
    root.CFrame = CFrame.lookAt(
        npc_root.Position + Vector3.new(0, 0, -9),
        npc_root.Position
    )
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.4)
end

--[[
Measures client-input damage, owned lifesteal and server resource costs.

Args:
    player (Player): Real authenticated caster.
    model (Model): Player's actual current character.
    humanoid (Humanoid): Caster's real HP.
    target (Model): Physical tagged training NPC.
    npc (Humanoid): Target's authoritative HP.
    rank (number): Individually bought source rank one or seven.
    mana_cost (number): C4 source MP cost for this exact rank.

Returns:
    nil: Confirms health transfer only after real positive target damage.
]]
local function verify_rank(
    player, model, humanoid, target, npc, rank, mana_cost
)
    seed_rank(player, rank)
    face_target(player, target)
    humanoid.MaxHealth = 1000
    humanoid.Health = 350
    npc.MaxHealth = 2000
    npc.Health = 1600
    local start_npc_hp = npc.Health
    local start_mana = Mana.get(player)
    local last_pulse = model:GetAttribute("MageHealPulse") or 0
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD", rank)
    assert(await_receipt(player, "LOADED").accepted,
        "Local hotbar cannot select genuine purchased Knight drain")
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Actual client could not submit source drain hotbar action")
    local deadline = os.clock() + 10
    repeat
        if model:GetAttribute("MageHealPulse") ~= last_pulse
            and target:GetAttribute("LastMagicSkillId") == SKILL_ID
        then break end
        task.wait(0.1)
    until os.clock() >= deadline
    assert(model:GetAttribute("MageHealPulse") ~= last_pulse,
        "No actual post-hit server caster healing event")
    local damage = start_npc_hp - npc.Health
    local heal = model:GetAttribute("MageHealLastAmount")
    assert(damage > 0 and type(heal) == "number"
        and math.abs(heal - damage * 0.20) < EPSILON,
        "Drain must heal exactly 20% of confirmed NPC damage")
    assert(start_mana - Mana.get(player) >= mana_cost - 0.5,
        "Knight siphon did not consume its source-rank MP cost")
    print("[Knight Drain] REAL_CLIENT_RANK_" .. tostring(rank)
        .. "_DAMAGE_TO_HEAL_PASS damage=" .. tostring(damage)
        .. " ownerHeal=" .. tostring(heal))
end

--[[
Checks an unearned Fighter cannot activate copied Knight drain ranks.

Args:
    player (Player): Real local user whose server profile changes.

Returns:
    nil: Denies forged first-transfer ability in authoritative runtime.
]]
local function verify_wrong_class(player)
    local owner = knight_fixture(player.UserId, 0, nil)
    owner.Identity.ClassId = "Fighter"
    owner.Progression.Skills[SKILL_ID] = {
        Known = true, PurchasedRank = 7, Proficiency = 0,
    }
    owner.Progression.Loadout[1] = SKILL_ID
    Runtime.set_character(player.UserId, owner)
    assert(not Runtime.is_skill_usable(player.UserId, SKILL_ID),
        "Forged Fighter can cast copied Knight life drain")
    Runtime.clear_character(player.UserId)
    print("[Knight Drain] FORGED_CLASS_DENIED_PASS")
end

--[[
Runs two actual client-cast rank brackets and the wrong-class check.

Args:
    None.

Returns:
    nil: Ends only when genuine damaging projectiles and real HP pass.
]]
local function main()
    local player, model, humanoid, target, npc = live_targets()
    player:SetAttribute("DungeonCombatAllowed", true)
    task.wait(2)
    verify_rank(player, model, humanoid, target, npc, 1, 12)
    task.wait(5)
    verify_rank(player, model, humanoid, target, npc, 7, 17)
    verify_wrong_class(player)
    print("[Knight Drain] ALL_REAL_CLIENT_DRAIN_CHECKS_PASS")
end

task.spawn(function()
    local ok, failure = pcall(main)
    if not ok then
        warn("[Knight Drain] FAIL " .. tostring(failure))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(failure))
end)
task.delay(105, function()
    STS:EndTest("FAIL Knight drain Play global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_KnightLifeDrainPlay")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Real Knight life-drain Play failed: " .. tostring(result))
print("[Knight Drain] VERIFIED_PLAY_MODE_PASS")
