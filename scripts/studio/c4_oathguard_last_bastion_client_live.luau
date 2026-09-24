--!strict
-- Real client: distinct Knight Ultimate Defence dual HP and immobility.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Knight Bastion Play must use an unpublished Dungeon place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "TEMP_KnightBastionInput"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "TEMP_KnightBastionClient"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local channel = RS:WaitForChild("TEMP_KnightBastionInput")
local scripts = player:WaitForChild("PlayerScripts")
local state = require(scripts:WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local input = require(scripts:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))
local SKILL_ID = "OathguardLastBastion"

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
    elseif action == "DODGE" then
        channel:FireServer("DODGE", input.request_dodge())
    end
end)
channel:FireServer("READY", true)
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "TEMP_KnightBastionServer"
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
local Combat = require(RS.Combat.Shared.SkillDefinitions)
local channel = RS:WaitForChild("TEMP_KnightBastionInput")
local SKILL_ID = "OathguardLastBastion"
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
    error("[Knight Bastion] No authentic client " .. action)
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
    error("[Knight Bastion] Real Play avatar never spawned")
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
    advancement.OriginalFirstTransferReceiptId = "TEMP_KnightBastionPlay"
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
Creates an earned Knight with a real shield and paid ultimate defence.

Args:
    player (Player): Authenticated Play user receiving this test profile.

Returns:
    nil: Seeds source class rank, shield, and fresh server mana.
]]
local function seed_bastion(player)
    local owner = knight_fixture(player.UserId, 2, "marauder_shield")
    owner.Level = 28
    owner.Progression.Skills[SKILL_ID] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    owner.Progression.Skills.OathguardSteadfastStance = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    owner.Progression.Loadout[1] = SKILL_ID
    Runtime.set_character(player.UserId, owner)
    local usable, reason = Runtime.is_skill_usable(
        player.UserId, SKILL_ID
    )
    assert(usable, "Knight's purchased bastion was denied "
        .. tostring(reason))
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
local function verify_hit(model, humanoid, kind, expected, blocked)
    humanoid.MaxHealth = 1000
    humanoid.Health = 700
    local actual = Damage.apply_damage({
        attacker = nil, attacker_character = nil, target = model,
        source_kind = kind, source_id = "TEMP_KnightBastionHit",
        blocked = blocked == true, base_damage = 100, multiplier = 1,
    })
    assert(math.abs(actual - expected) < EPSILON
        and math.abs(humanoid.Health - (700 - expected)) < EPSILON,
        kind .. " shieldless stance damage mismatch " .. tostring(actual))
    print("[Knight Bastion] REAL_" .. kind .. "_"
        .. tostring(expected) .. "_PASS")
end

--[[
Activates the purchased Bastion via real client, checks resource and root.

Args:
    player (Player): True server-owned caster.
    model (Model): Current live avatar.

Returns:
    number: Server-issued Bastion expiration timestamp.
]]
local function activate_bastion(player, model)
    seed_bastion(player)
    player:SetAttribute("DungeonCombatAllowed", true)
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD")
    assert(await_receipt(player, "LOADED").accepted,
        "Client did not load purchased Bastion")
    local previous_mana = Mana.get(player)
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Client could not cast true earned Bastion")
    local deadline = os.clock() + 10
    repeat
        if Status.get(model, "Fortress") >= 0.35 then break end
        task.wait(0.1)
    until os.clock() >= deadline
    local root = assert(model:FindFirstChild("HumanoidRootPart"))
    local expires_at = model:GetAttribute(
        "C4FortressDualDefenseExpiresAt"
    )
    assert(Status.get(model, "Fortress") >= 0.35
        and root.Anchored
        and previous_mana - Mana.get(player) >= 18.5,
        "Server Bastion must cost 19 MP and genuinely immobilize caster")
    assert(model:GetAttribute("C4FortressSourcePhysicalDefence") == 1800
        and model:GetAttribute("C4FortressSourceMagicDefence") == 1350,
        "Source C4 defence values missing from server-only guard")
    assert(type(expires_at) == "number"
        and expires_at - os.clock() > 27
        and expires_at - os.clock() <= 30,
        "C4 Bastion did not start a real thirty-second expiry")
    print("[Knight Bastion] REAL_CLIENT_CAST_MP_ROOT_PASS")
    return expires_at
end

--[[
Verifies real player HP with full Knight shield, Majesty and Bastion stack.

Args:
    player (Player): Authenticated owner of both defence abilities.
    model (Model): Character receiving genuine HP changes.
    humanoid (Humanoid): Server-owned real HP target.

Returns:
    nil: Demonstrates real magic and physical defence plus block-chip floor.
]]
local function verify_defence_stack(player, model, humanoid)
    verify_hit(model, humanoid, "EnemyMelee", 63.4)
    verify_hit(model, humanoid, "EnemyArea", 63.4)
    verify_hit(model, humanoid, "EnemyMagic", 65)
    verify_hit(model, humanoid, "Melee", 100)
    local stance = assert(Combat.get_for_rank(
        "OathguardSteadfastStance", 1
    ))
    assert(Status.apply_self(player, stance),
        "Test-owned earlier earned Majesty did not apply on caster")
    verify_hit(model, humanoid, "EnemyMelee", 56.4)
    verify_hit(model, humanoid, "EnemyMelee", 25.38, true)
    verify_hit(model, humanoid, "EnemyArea", 56.4, true)
    verify_hit(model, humanoid, "EnemyMagic", 65, true)
    print("[Knight Bastion] STACKED_SHIELD_MAJESTY_BLOCK_HP_PASS")
end

--[[
Rejects Dodge while rooted and verifies cooldown and actual 30s expiry.

Args:
    player (Player): True local client attempting a prohibited dash.
    model (Model): Server-anchored character.
    humanoid (Humanoid): Genuine damage target.
    expires_at (number): Authoritatively issued expiration timestamp.

Returns:
    nil: Checks that root/HP unlocks only after real expiry.
]]
local function verify_immobility(player, model, humanoid, expires_at)
    local root = assert(model:FindFirstChild("HumanoidRootPart"))
    local position = root.Position
    receipts[player.UserId] = nil
    channel:FireClient(player, "DODGE")
    assert(await_receipt(player, "DODGE").accepted,
        "Real client did not submit forbidden Dodge intent")
    task.wait(0.4)
    assert(root.Anchored and (root.Position - position).Magnitude < 0.1
        and model:GetAttribute("CombatState") ~= "Dodging",
        "Server Dodge remote bypassed C4 ultimate immobility")
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Client did not submit premature Bastion recast")
    task.wait(0.3)
    assert(model:GetAttribute(
        "C4FortressDualDefenseExpiresAt"
    ) == expires_at, "Recast bypassed twenty-minute+ cooldown")
    local wait_seconds = expires_at - os.clock()
    if wait_seconds > 0 then task.wait(wait_seconds + 0.3) end
    assert(Status.get(model, "Fortress") == 0
        and root.Anchored == false,
        "Real 30-second Bastion expiry did not release the avatar")
    verify_hit(model, humanoid, "EnemyMelee", 91.4)
    verify_hit(model, humanoid, "EnemyMagic", 100)
    print("[Knight Bastion] DODGE_REJECT_AND_REAL_EXPIRY_PASS")
end

--[[
Denies copied Ultimate Defence when the personal Knight quest is absent.

Args:
    player (Player): Authenticated test owner whose profile is replaced.

Returns:
    nil: Prevents forged-class dual-defence activation.
]]
local function verify_forged_class(player)
    local owner = knight_fixture(player.UserId, 0, nil)
    owner.Identity.ClassId = "Fighter"
    owner.Progression.Skills[SKILL_ID] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    owner.Progression.Loadout[1] = SKILL_ID
    Runtime.set_character(player.UserId, owner)
    assert(not Runtime.is_skill_usable(player.UserId, SKILL_ID),
        "Unawarded Fighter may not receive the ultimate defence")
    Runtime.clear_character(player.UserId)
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
    local expires_at = activate_bastion(player, model)
    verify_defence_stack(player, model, humanoid)
    verify_immobility(player, model, humanoid, expires_at)
    verify_forged_class(player)
    print("[Knight Bastion] ALL_REAL_CLIENT_BASTION_CHECKS_PASS")
end

task.spawn(function()
    local ok, failure = pcall(main)
    if not ok then
        warn("[Knight Bastion] FAIL " .. tostring(failure))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(failure))
end)
task.delay(105, function()
    STS:EndTest("FAIL Knight Bastion Play global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_KnightLastBastionPlay")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Real Knight Bastion Play failed: " .. tostring(result))
print("[Knight Bastion] VERIFIED_PLAY_MODE_PASS")
