--!strict
-- Disposable client hotbar and actual HP acceptance for Knight guard stance.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Knight guard stance Play must use an unpublished Dungeon place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "TEMP_KnightStanceInput"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "TEMP_KnightStanceClient"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local channel = RS:WaitForChild("TEMP_KnightStanceInput")
local scripts = player:WaitForChild("PlayerScripts")
local state = require(scripts:WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local input = require(scripts:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))
local SKILL_ID = "OathguardSteadfastStance"

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
driver.Name = "TEMP_KnightStanceServer"
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
local channel = RS:WaitForChild("TEMP_KnightStanceInput")
local SKILL_ID = "OathguardSteadfastStance"
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
    error("[Knight Stance] No authentic client " .. action)
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
    error("[Knight Stance] Real Play avatar never spawned")
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
    advancement.OriginalFirstTransferReceiptId = "TEMP_KnightStancePlay"
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
Prepares an earned level-twenty Knight and its paid C4 physical stance.

Args:
    player (Player): Actual authenticated local client.

Returns:
    nil: Server-owned class, level, combat hotbar and fresh mana state.
]]
local function seed_stance(player)
    local owner = knight_fixture(player.UserId, 0, nil)
    owner.Level = 20
    owner.Progression.Skills[SKILL_ID] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    owner.Progression.Loadout[1] = SKILL_ID
    Runtime.set_character(player.UserId, owner)
    local usable, reason = Runtime.is_skill_usable(
        player.UserId, SKILL_ID
    )
    assert(usable, "Knight stance not learnable: " .. tostring(reason))
    Mana.reset_player(player)
end

--[[
Measures real incoming damage while a timed self-buff is or is not active.

Args:
    model (Model): Actual player's world character.
    humanoid (Humanoid): Its server-owned Humanoid.
    kind (string): EnemyMelee, EnemyArea, EnemyMagic or ordinary melee.
    expected (number): Damage expected out of 100 base.

Returns:
    nil: Verifies real Humanoid health loss and returned damage.
]]
local function verify_hit(model, humanoid, kind, expected)
    humanoid.MaxHealth = 1000
    humanoid.Health = 700
    local actual = Damage.apply_damage({
        attacker = nil, attacker_character = nil, target = model,
        source_kind = kind, source_id = "TEMP_KnightTimedGuard",
        base_damage = 100, multiplier = 1,
    })
    assert(math.abs(actual - expected) < EPSILON
        and math.abs(humanoid.Health - (700 - expected)) < EPSILON,
        kind .. " shieldless stance damage mismatch " .. tostring(actual))
    print("[Knight Stance] REAL_" .. kind .. "_"
        .. tostring(expected) .. "_PASS")
end

--[[
Casts a real paid class ability and verifies actual timed combat protection.

Args:
    player (Player): Live caster whose client sends the action.
    model (Model): Real player character receiving server-only buff.
    humanoid (Humanoid): Server-side actual damage target.

Returns:
    nil: Verifies mana, 7% physical guard, stat penalty, no spell/PvP
        protection, rejected recast and unearned class denial.
]]
local function verify_stance(player, model, humanoid)
    seed_stance(player)
    player:SetAttribute("DungeonCombatAllowed", true)
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD")
    assert(await_receipt(player, "LOADED").accepted,
        "Real client refused purchased stance skill")
    local starting_mana = Mana.get(player)
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted == true,
        "Real client could not send Knight stance hotbar action")
    local deadline = os.clock() + 8
    repeat
        if Status.get(model, "PhysicalGuard") >= 0.07 then break end
        task.wait(0.1)
    until os.clock() >= deadline
    assert(Status.get(model, "PhysicalGuard") >= 0.07,
        "Real client cast did not apply earned Knight physical guard")
    assert(starting_mana - Mana.get(player) >= 9.5,
        "Real Knight source stance did not spend 10 MP")
    assert(math.abs(
        Status.get_evasion_penalty_chance(model) - 0.02
    ) < EPSILON, "Source two-point evasion cost did not activate")
    verify_hit(model, humanoid, "EnemyMelee", 93)
    verify_hit(model, humanoid, "EnemyArea", 93)
    verify_hit(model, humanoid, "EnemyMagic", 100)
    verify_hit(model, humanoid, "Melee", 100)
    local expires_at = model:GetAttribute("C4PhysicalGuardExpiresAt")
    assert(type(expires_at) == "number"
        and expires_at - os.clock() > 295
        and expires_at - os.clock() <= 300,
        "C4 Knight guard did not receive its five-minute expiry")
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted == true,
        "Real client did not submit second cast for cooldown rejection")
    task.wait(0.4)
    assert(model:GetAttribute("C4PhysicalGuardExpiresAt") == expires_at,
        "Premature second stance cast bypassed server cooldown")
    -- Simulate expiry only in this disposable Play fixture: the
    -- separate real five-minute wall-clock expiry is not claimed.
    model:SetAttribute("C4PhysicalGuardExpiresAt", os.clock() - 1)
    model:SetAttribute(
        "C4MajestyEvasionPenaltyExpiresAt", os.clock() - 1
    )
    assert(Status.get(model, "PhysicalGuard") == 0
        and Status.get_evasion_penalty_chance(model) == 0,
        "Expired Knight stance retained protection or evasion penalty")
    verify_hit(model, humanoid, "EnemyMelee", 100)
    local unawarded = knight_fixture(player.UserId, 0, nil)
    unawarded.Identity.ClassId = "Fighter"
    unawarded.Progression.Skills[SKILL_ID] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    unawarded.Progression.Loadout[1] = SKILL_ID
    Runtime.set_character(player.UserId, unawarded)
    assert(not Runtime.is_skill_usable(player.UserId, SKILL_ID),
        "Forged Fighter inherited an unearned Knight defensive stance")
    Runtime.clear_character(player.UserId)
    print("[Knight Stance] ALL_REAL_CLIENT_TIMED_GUARD_PASS")
end

--[[
Runs the focused real client stance test in isolated unpublished Play.

Args:
    None.

Returns:
    nil: Ends only when real HP, expiry, class, stamina and cast checks pass.
]]
local function main()
    local player, model, humanoid = live_player()
    task.wait(2)
    verify_stance(player, model, humanoid)
end

task.spawn(function()
    local ok, failure = pcall(main)
    if not ok then
        warn("[Knight Stance] FAIL " .. tostring(failure))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(failure))
end)
task.delay(75, function()
    STS:EndTest("FAIL Knight stance Play global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_KnightTimedGuardPlay")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Real Knight stance Play failed: " .. tostring(result))
print("[Knight Stance] VERIFIED_PLAY_MODE_PASS")
