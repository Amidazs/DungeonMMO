--!strict
-- Actual client Knight bow defence rank-one/two and non-bow HP tests.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Knight guard stance Play must use an unpublished Dungeon place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "TEMP_KnightBowWardInput"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "TEMP_KnightBowWardClient"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local channel = RS:WaitForChild("TEMP_KnightBowWardInput")
local scripts = player:WaitForChild("PlayerScripts")
local state = require(scripts:WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local input = require(scripts:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))
local SKILL_ID = "OathguardArrowWard"

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
driver.Name = "TEMP_KnightBowWardServer"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Schema = require(RS.Core.Shared.ProfileSchema)
local Stages = require(RS.Core.Shared.C4OriginalFirstTransferQuestStages)
local Careers = require(
    RS.Core.Shared.OriginalFirstTransferDefinitions
)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Damage = require(SSS.Combat.DamageService)
local Mana = require(SSS.Combat.ManaService)
local Status = require(SSS.Combat.CombatStatusService)
local channel = RS:WaitForChild("TEMP_KnightBowWardInput")
local SKILL_ID = "OathguardArrowWard"
local EPSILON = 0.002
local receipts = {}

channel.OnServerEvent:Connect(function(player, action, accepted)
    receipts[player.UserId] = {action = action, accepted = accepted}
end)

--[[
Waits for the real client's acknowledgement of a requested hotbar action.

Args:
    player (Player): Actual current Studio Play user.
    action (string): Ready, loaded or cast acknowledgement.

Returns:
    any: Matching receipt from the true local client.
]]
local function await_receipt(player, action)
    local deadline = os.clock() + 13
    repeat
        local record = receipts[player.UserId]
        if record and record.action == action then return record end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Knight Bow Ward] No authentic client " .. action)
end

--[[
Obtains the real spawned Play avatar before touching any combat state.

Args:
    None.

Returns:
    (Player, Model, Humanoid): Live client and actual server HP target.
]]
local function live_player()
    local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    await_receipt(player, "READY")
    local deadline = os.clock() + 35
    repeat
        local model = player.Character
        local humanoid = model
            and model:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0
            and model:FindFirstChild("HumanoidRootPart")
        then return player, model, humanoid end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Knight Bow Ward] Real Play avatar never spawned")
end

--[[
Builds a disposable internally consistent earned Knight server snapshot.

This fixture does not simulate a naturally completed persistent quest,
trainer, or equipment UI; those have their own independent tests.

Args:
    user_id (number): Authenticated actual current Play user.
    rank (number): Unused shield training rank zero in this test.
    offhand (string?): Nil; stance protection does not need a shield.

Returns:
    any: Test-owned advanced Knight runtime character.
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
    advancement.OriginalFirstTransferReceiptId = "TEMP_KnightBowWardPlay"
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
Seeds the real player's personally earned Knight bow-defence rank.

Args:
    player (Player): Actual client owning the server runtime profile.
    rank (number): Individually purchased C4 source rank one or two.

Returns:
    nil: Verified own-class rank and hotbar in disposable Play.
]]
local function seed_bow_ward(player, rank)
    local owner = knight_fixture(player.UserId, 0, nil)
    owner.Level = if rank == 1 then 24 else 28
    owner.Progression.Skills[SKILL_ID] = {
        Known = true, PurchasedRank = rank, Proficiency = 0,
    }
    owner.Progression.Loadout[1] = SKILL_ID
    Runtime.set_character(player.UserId, owner)
    local usable, reason = Runtime.is_skill_usable(
        player.UserId, SKILL_ID
    )
    assert(usable, "Knight bow ward rejected: " .. tostring(reason))
    Mana.reset_player(player)
end

--[[
Checks genuine Humanoid damage for separately labelled enemy bow attacks.

Args:
    model (Model): Actual server-owned player avatar.
    humanoid (Humanoid): Real player HP target.
    source_kind (string): EnemyBow, EnemyMelee or EnemyMagic.
    expected (number): Actual HP damage expected for 100 base.
    blocked (boolean?): Whether actual server defense blocked the hit.

Returns:
    nil: Confirms both damage service result and real player health loss.
]]
local function verify_hit(model, humanoid, source_kind, expected, blocked)
    humanoid.MaxHealth = 1000
    humanoid.Health = 700
    local actual = Damage.apply_damage({
        attacker = nil, attacker_character = nil, target = model,
        source_kind = source_kind, source_id = "TEMP_BowWardHit",
        blocked = blocked == true,
        base_damage = 100, multiplier = 1,
    })
    assert(math.abs(actual - expected) < EPSILON
        and math.abs(humanoid.Health - (700 - expected)) < EPSILON,
        source_kind .. " HP mismatch " .. tostring(actual))
    print("[Knight Bow Ward] REAL_" .. source_kind .. "_"
        .. tostring(expected) .. "_PASS")
end

--[[
Submits actual client hotbar cast of one paid C4 bow defence rank.

Args:
    player (Player): Authenticated live client.
    model (Model): Current avatar with authoritative bow status.
    humanoid (Humanoid): Player HP tested after skill activation.
    rank (number): Paid C4 rank one or two.
    cost (number): Source MP22 or MP28.
    value (number): Provisional Roblox 16/19 percent bow mitigation.

Returns:
    nil: Verifies actual client cast, mana spend and bow-only HP effects.
]]
local function verify_rank(
    player, model, humanoid, rank, cost, value
)
    seed_bow_ward(player, rank)
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD", rank)
    assert(await_receipt(player, "LOADED").accepted,
        "Client did not load authentic purchased bow ward")
    local mana_before = Mana.get(player)
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Client did not submit rank-specific bow ward")
    local deadline = os.clock() + 8
    repeat
        if Status.get(model, "BowGuard") >= value then break end
        task.wait(0.1)
    until os.clock() >= deadline
    assert(Status.get(model, "BowGuard") >= value
        and mana_before - Mana.get(player) >= cost - 0.5,
        "Rank did not apply actual bow protection and MP cost")
    verify_hit(model, humanoid, "EnemyBow", 100 - value * 100)
    verify_hit(model, humanoid, "EnemyMelee", 100)
    verify_hit(model, humanoid, "EnemyMagic", 100)
    local actual = math.max((100 - value * 100) * 0.45, 20)
    verify_hit(model, humanoid, "EnemyBow", actual, true)
    print("[Knight Bow Ward] REAL_CLIENT_RANK_" .. tostring(rank)
        .. "_PASS")
end

--[[
Checks a forged Fighter cannot activate source Knight bow protection.

Args:
    player (Player): Authenticated current client.

Returns:
    nil: Server runtime rejects copied but unawarded ability rank.
]]
local function verify_wrong_class(player)
    local owner = knight_fixture(player.UserId, 0, nil)
    owner.Identity.ClassId = "Fighter"
    owner.Progression.Skills[SKILL_ID] = {
        Known = true, PurchasedRank = 2, Proficiency = 0,
    }
    owner.Progression.Loadout[1] = SKILL_ID
    Runtime.set_character(player.UserId, owner)
    assert(not Runtime.is_skill_usable(player.UserId, SKILL_ID),
        "Forged Fighter activated source Knight bow protection")
    Runtime.clear_character(player.UserId)
end

--[[
Checks both independently paid source ranks against actual player HP.

Args:
    None.

Returns:
    nil: Source bow defence and wrong-class denial emit explicit PASS.
]]
local function main()
    local player, model, humanoid = live_player()
    player:SetAttribute("DungeonCombatAllowed", true)
    task.wait(1)
    verify_rank(player, model, humanoid, 1, 22, 0.16)
    task.wait(4)
    verify_rank(player, model, humanoid, 2, 28, 0.19)
    verify_wrong_class(player)
    print("[Knight Bow Ward] ALL_REAL_CLIENT_BOW_CHECKS_PASS")
end

task.spawn(function()
    local ok, failure = pcall(main)
    if not ok then
        warn("[Knight Bow Ward] FAIL " .. tostring(failure))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(failure))
end)
task.delay(100, function()
    STS:EndTest("FAIL Knight bow ward Play global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_KnightBowWardPlay")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Real Knight bow ward Play failed: " .. tostring(result))
print("[Knight Bow Ward] VERIFIED_PLAY_MODE_PASS")
