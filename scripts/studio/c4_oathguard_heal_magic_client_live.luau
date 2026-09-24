--!strict
-- Unpublished Play: genuine client hotbar self-heal and actual enemy magic HP.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Knight recovery Play validation requires unpublished Dungeon")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "TEMP_KnightRecoveryInput"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "TEMP_KnightRecoveryClient"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local channel = RS:WaitForChild("TEMP_KnightRecoveryInput")
local scripts = player:WaitForChild("PlayerScripts")
local state = require(scripts:WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local input = require(scripts:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))

channel.OnClientEvent:Connect(function(action, rank)
    if action == "LOAD" then
        state.apply_snapshot({
            Skills = {
                OathguardMendingOath = {Known = true, Rank = rank},
            },
            Loadout = {[1] = "OathguardMendingOath"},
        })
        channel:FireServer(
            "LOADED", state.get_skill_for_slot(1)
                == "OathguardMendingOath"
        )
    elseif action == "CAST" then
        channel:FireServer("CAST", input.request_skill_slot(1))
    end
end)
channel:FireServer("READY", true)
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "TEMP_KnightRecoveryServer"
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
local channel = RS:WaitForChild("TEMP_KnightRecoveryInput")
local SKILL_ID = "OathguardMendingOath"
local EPSILON = 0.002
local receipts = {}

channel.OnServerEvent:Connect(function(player, action, accepted)
    receipts[player.UserId] = {action = action, accepted = accepted}
end)

--[[
Returns the first authenticated client receipt matching an actual action.

Args:
    player (Player): Live Play client requesting or loading a skill.
    action (string): Expected acknowledgement name.

Returns:
    any: Received acknowledgement or an explicit bounded timeout.
]]
local function await_receipt(player, action)
    local deadline = os.clock() + 13
    repeat
        local record = receipts[player.UserId]
        if record and record.action == action then return record end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Knight Recovery] Client did not acknowledge " .. action)
end

--[[
Obtains the real spawned player avatar used for all measured effects.

Args:
    None.

Returns:
    (Player, Model, Humanoid): Live Play client and server-owned HP.
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
    error("[Knight Recovery] Real Play character not spawned")
end

--[[
Builds an internally consistent disposable Knight advancement receipt.

It does not substitute for the separate physical quest/trainer persistence
acceptance. All rank/equipment values exist only inside this Studio run.

Args:
    user_id (number): Actual Play client ID for server runtime.
    rank (number): Unused shield rank zero for this recovery probe.
    offhand (string?): Nil; no equipped shield during spell testing.

Returns:
    any: A valid level-28 Knight snapshot for real combat execution.
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
    advancement.OriginalFirstTransferReceiptId = "TEMP_KnightRecoveryPlay"
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
Sets one complete test-owned Knight rank and registered live hotbar slot.

Args:
    player (Player): Real authenticated Play user.
    rank (number): First or third purchased self-heal rank.

Returns:
    nil: Authoritative runtime snapshot with proper Fighter prerequisite.
]]
local function seed_recovery(player, rank)
    local owner = knight_fixture(player.UserId, 0, nil)
    owner.Progression.Skills.FighterRestingRecovery = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    owner.Progression.Skills[SKILL_ID] = {
        Known = true, PurchasedRank = rank, Proficiency = 80,
    }
    owner.Progression.Skills.OathguardRunicResistance = {
        Known = true, PurchasedRank = 8, Proficiency = 0,
    }
    owner.Progression.Loadout[1] = SKILL_ID
    Runtime.set_character(player.UserId, owner)
    local usable, reason = Runtime.is_skill_usable(
        player.UserId, SKILL_ID
    )
    assert(usable, "Earned Knight cannot cast: " .. tostring(reason))
    Mana.reset_player(player)
end

--[[
Requests the genuine client combat hotbar action and verifies a server heal.

Args:
    player (Player): Live caster with test-only owned rank and loadout.
    humanoid (Humanoid): Authenticated current caster's HP object.
    rank (number): Purchased first or third heal rank.

Returns:
    number: Observed positive real HP increase, with server mana cost.
]]
local function check_heal(player, humanoid, rank)
    seed_recovery(player, rank)
    humanoid.MaxHealth = 1000
    humanoid.Health = 400
    task.wait(0.2)
    local starting_hp = humanoid.Health
    local model = assert(player.Character)
    local starting_pulse = model:GetAttribute("MageHealPulse") or 0
    local starting_mana = Mana.get(player)
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD", rank)
    assert(await_receipt(player, "LOADED").accepted,
        "Client hotbar rejected purchased Knight heal")
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted == true,
        "Client could not send the real Knight hotbar action")
    local deadline = os.clock() + 8
    repeat
        if (model:GetAttribute("MageHealPulse") or 0)
            > starting_pulse then break end
        task.wait(0.1)
    until os.clock() >= deadline
    assert((model:GetAttribute("MageHealPulse") or 0)
        > starting_pulse,
        "Client cast did not execute a server-owned self-heal")
    local received = model:GetAttribute("MageHealLastAmount")
    assert(type(received) == "number" and received > 0
        and received <= 120,
        "No positive measured self-heal reached the server")
    assert(humanoid.Health >= starting_hp + received - 0.1,
        "Server heal receipt did not increase the actual owner's HP")
    assert(starting_mana - Mana.get(player) >= 14,
        "Actual Knight self-heal did not consume the mana cost")
    print("[Knight Recovery] REAL_CLIENT_HEAL_RANK_"
        .. tostring(rank) .. "_PASS amount=" .. tostring(received))
    return received
end

--[[
Measures actual live HP loss for an authored server hostile damage context.

Args:
    player (Player): Live defender whose runtime is server-owned.
    model (Model): Defender's real character.
    humanoid (Humanoid): Real server health affected by damage.
    kind (string): EnemyMagic, EnemyMelee or unaffected ordinary damage.
    expected (number): Exact expected HP loss out of 100.

Returns:
    nil: Verifies both returned combat damage and real HP loss.
]]
local function check_damage(player, model, humanoid, kind, expected)
    humanoid.MaxHealth = 1000
    humanoid.Health = 700
    local applied = Damage.apply_damage({
        attacker = nil, attacker_character = nil, target = model,
        source_kind = kind, source_id = "TEMP_KnightSpellDefense",
        base_damage = 100, multiplier = 1,
    })
    assert(math.abs(applied - expected) < EPSILON
        and math.abs(humanoid.Health - (700 - expected)) < EPSILON,
        kind .. " gave unexpected Knight HP protection "
            .. tostring(applied))
    print("[Knight Recovery] REAL_" .. kind .. "_PASS "
        .. tostring(applied))
end

--[[
Runs client-originated self-healing and independent actual magic HP checks.

Args:
    None.

Returns:
    nil: Ends only after real hotbar ranks, mana and magic isolation pass.
]]
local function main()
    local player, model, humanoid = live_player()
    player:SetAttribute("DungeonCombatAllowed", true)
    task.wait(2)
    local first = check_heal(player, humanoid, 1)
    task.wait(19)
    local third = check_heal(player, humanoid, 3)
    assert(third > first + 5,
        "Third bought Knight healing rank did not increase actual HP")
    check_damage(player, model, humanoid, "EnemyMagic", 95.2)
    check_damage(player, model, humanoid, "EnemyMelee", 100)
    local forged = knight_fixture(player.UserId, 0, nil)
    forged.Identity.ClassId = "Fighter"
    forged.Progression.Skills.OathguardRunicResistance = {
        Known = true, PurchasedRank = 8, Proficiency = 0,
    }
    Runtime.set_character(player.UserId, forged)
    check_damage(player, model, humanoid, "EnemyMagic", 100)
    Runtime.clear_character(player.UserId)
    print("[Knight Recovery] ALL_REAL_CLIENT_HEAL_MAGIC_PASS")
end

task.spawn(function()
    local ok, failure = pcall(main)
    if not ok then
        warn("[Knight Recovery] FAIL " .. tostring(failure))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(failure))
end)
task.delay(105, function()
    STS:EndTest("FAIL Knight recovery Play global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_KnightRecoveryMagicPlay")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Knight live heal/magic check failed: " .. tostring(result))
print("[Knight Recovery] VERIFIED_PLAY_MODE_PASS")
