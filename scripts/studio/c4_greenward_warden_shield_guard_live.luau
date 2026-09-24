--!strict
-- Real Warden client shield, heavy armour, bought guard and hostile hit.
-- The shield/guard/armour stack must never grant invulnerability.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Guard stack acceptance requires an unpublished Dungeon instance")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "TEMP_WardenStackClientInput"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "TEMP_WardenStackLocal"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local channel = RS:WaitForChild("TEMP_WardenStackClientInput")
local scripts = player:WaitForChild("PlayerScripts")
local state = require(scripts:WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local input = require(scripts:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))
local SKILL_ID = "GreenwardWardenDefenseAura"

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
    elseif action == "BLOCK" then
        channel:FireServer("BLOCK", input.set_block(true))
    elseif action == "REBLOCK" then
        channel:FireServer("REBLOCK", input.set_block(true))
    end
end)
channel:FireServer("READY", true)
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "TEMP_WardenStackServer"
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
local Defense = require(SSS.Combat.DefenseService)
local Stamina = require(SSS.Combat.StaminaService)
local Status = require(SSS.Combat.CombatStatusService)
local channel = RS:WaitForChild("TEMP_WardenStackClientInput")
local receipts = {}
local EPSILON = 0.04

channel.OnServerEvent:Connect(function(player, action, accepted)
    receipts[player.UserId] = {action = action, accepted = accepted}
end)

--[[
Waits for the actual client acknowledgement before each state change.

Args:
    player (Player): Authenticated Studio client.
    action (string): Expected client action response.

Returns:
    any: Matching recent client-issued receipt.
]]
local function await_receipt(player, action)
    local deadline = os.clock() + 12
    repeat
        local record = receipts[player.UserId]
        if record and record.action == action then return record end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Warden Stack] Client did not acknowledge " .. action)
end

--[[
Returns an actual spawned player and real authoritative HP target.

Args:
    None.

Returns:
    (Player, Model, Humanoid): Live player and actual Humanoid.
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
            and model:FindFirstChild("HumanoidRootPart") then
            return player, model, humanoid
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Warden Stack] Real Play avatar missing")
end

--[[
Creates a test-only earned Warden receipt matching the class validator.

Args:
    user_id (number): Authenticated player owning the profile.
    rank (number): Saved shield-mastery rank.
    offhand (string?): Real registered shield item.

Returns:
    any: Disposable earned Warden profile.
]]
local function warden_fixture(user_id, rank, offhand)
    local character = Schema.create_default(user_id).Characters.Slot1
    local source = assert(Stages.get("ElvenKnight"))
    character.Level = 28
    character.Identity = {
        Version = 1, RaceId = "Elf", BaseClassId = "Fighter",
        ClassId = "GreenwardWarden", CreationStage = "Complete",
    }
    local advancement = character.ClassAdvancement
    advancement.ActiveClassId = nil
    advancement.OriginalFirstTransferChoiceId = "ElvenKnight"
    advancement.OriginalFirstTransferClassId = "GreenwardWarden"
    advancement.OriginalFirstTransferReceiptId = "TEMP_WardenStackPlay"
    local proofs = {}
    for _, proof_id in ipairs(source.RequiredProofIds) do
        proofs[proof_id] = true
    end
    advancement.OriginalFirstTransferQuest = {
        QuestId = source.Id, BranchId = "ElvenKnight",
        Step = #source.Steps + 1, Ready = true,
        Count = 0, Proofs = proofs, AppliedEvents = {},
    }
    character.Progression.Skills.GreenwardWardenShieldMastery = {
        Known = true, PurchasedRank = rank, Proficiency = 0,
    }
    character.Equipment.OffHand = offhand
    character.Equipment.Body = "marauder_armor"
    character.Progression.Skills.GreenwardWardenHeavyArmorTraining = {
        Known = true, PurchasedRank = 9, Proficiency = 0,
    }
    assert(Careers.awarded(character) ~= nil,
        "Synthetic source receipts must pass real class validation")
    return character
end


--[[
Seeds the earned shield and purchased guard in server-owned runtime.

Args:
    player (Player): Actual Play user.

Returns:
    nil: Purchases only the test-owned rank/equipment snapshot.
]]
local function seed_warden(player)
    local owner = warden_fixture(
        player.UserId, 2, "marauder_shield"
    )
    owner.Progression.Skills.GreenwardWardenDefenseAura = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    owner.Progression.Loadout[1] = "GreenwardWardenDefenseAura"
    Runtime.set_character(player.UserId, owner)
    Stamina.reset_player(player)
    local usable, reason = Runtime.is_skill_usable(
        player.UserId, "GreenwardWardenDefenseAura"
    )
    assert(usable, "Earned source stance unavailable "
        .. tostring(reason))
end

--[[
Actually requests the Warden buff then a held Block from the real client.

Args:
    player (Player): Live owner.
    model (Model): Current character receiving both defences.

Returns:
    nil: Waits for server-side buff and authoritative Blocking state.
]]
local function activate_guard(player, model)
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD")
    assert(await_receipt(player, "LOADED").accepted,
        "Actual client did not load purchased Warden guard")
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Actual client did not request purchased Warden guard")
    local deadline = os.clock() + 10
    repeat
        if Status.get(model, "PhysicalGuard") >= 0.07
            and model:GetAttribute("CombatState") == "Locomotion"
        then break end
        task.wait(0.1)
    until os.clock() >= deadline
    assert(Status.get(model, "PhysicalGuard") >= 0.07,
        "Warden stance not authorized on server")
    receipts[player.UserId] = nil
    channel:FireClient(player, "BLOCK")
    assert(await_receipt(player, "BLOCK").accepted,
        "Actual client could not request held Block")
    deadline = os.clock() + 5
    repeat
        if model:GetAttribute("CombatState") == "Blocking" then
            break
        end
        task.wait(0.1)
    until os.clock() >= deadline
    assert(model:GetAttribute("CombatState") == "Blocking",
        "Server did not accept genuine client shield hold")
    task.wait(0.24)
end

--[[
Resolves a true server block against a frontal hostile strike.

Args:
    player (Player): Actual defender, owner of held input.
    model (Model): Current player avatar and root facing.
    humanoid (Humanoid): Actual defender HP.
    expected (string): Blocked or GuardBroken outcome.
    expected_health_loss (number): Required real HP loss.

Returns:
    nil: Asserts server outcome, stamina cost and actual player HP.
]]
local function verify_attack(
    player, model, humanoid, expected, expected_health_loss
)
    local root = assert(model:FindFirstChild("HumanoidRootPart"))
    humanoid.MaxHealth = 1000
    humanoid.Health = 800
    local result = Defense.resolve({
        attacker = nil, target_player = player,
        target_character = model, source_kind = "EnemyMelee",
        source_id = "TEMP_BlockStackStrike",
        attack_position = root.Position + root.CFrame.LookVector * 4,
        stamina_damage = 30, blockable = true, parryable = false,
    })
    assert(result.outcome == expected,
        "Shield exploit case expected " .. expected
            .. ", got " .. result.outcome)
    local actual = Damage.apply_damage({
        attacker = nil, attacker_character = nil, target = model,
        source_kind = "EnemyMelee",
        source_id = "TEMP_BlockStackStrike",
        blocked = result.outcome == "Blocked",
        base_damage = 100, multiplier = 1,
    })
    assert(math.abs(actual - expected_health_loss) < EPSILON
        and math.abs(humanoid.Health
            - (800 - expected_health_loss)) < EPSILON,
        "Block/guard stack returned unexpected actual player HP: "
            .. tostring(actual))
    print("[Warden Stack] " .. expected .. "_REAL_HP_PASS "
        .. tostring(actual))
end

--[[
Rejects a zero-stamina client's attempt to restart free invulnerable Block.

Args:
    player (Player): Actual exhausted guard owner.
    model (Model): Genuine server combat-state avatar.

Returns:
    nil: Verifies the new guard cannot enter Blocking with no stamina.
]]
local function verify_no_free_reblock(player, model)
    local deadline = os.clock() + 5
    repeat
        if model:GetAttribute("CombatState") == "Locomotion" then
            break
        end
        task.wait(0.1)
    until os.clock() >= deadline
    assert(model:GetAttribute("CombatState") == "Locomotion",
        "Guard-break recovery did not end")
    assert(Stamina.get(player) < 20,
        "Exhausted-guard test waited until stamina regenerated")
    receipts[player.UserId] = nil
    channel:FireClient(player, "REBLOCK")
    assert(await_receipt(player, "REBLOCK").accepted,
        "Client did not send attempted exploit input")
    task.wait(0.2)
    assert(model:GetAttribute("CombatState") ~= "Blocking",
        "Zero-stamina client regained a free shield block/parry")
    print("[Warden Stack] ZERO_STAMINA_REBLOCK_DENIED_PASS")
end

--[[
Exercises the real client stance/block and hostile hit pipeline.

Args:
    None.

Returns:
    nil: Rejects near-zero-damage stacking and guard-break immunity.
]]
local function main()
    local player, model, humanoid = live_player()
    player:SetAttribute("DungeonCombatAllowed", true)
    seed_warden(player)
    activate_guard(player, model)
    for _ = 1, 3 do
        verify_attack(player, model, humanoid, "Blocked", 38.7)
    end
    verify_attack(player, model, humanoid, "GuardBroken", 86)
    verify_no_free_reblock(player, model)
    Runtime.clear_character(player.UserId)
    print("[Warden Stack] ALL_REAL_CLIENT_ANTI_EXPLOIT_CHECKS_PASS")
end

task.spawn(function()
    local ok, failure = pcall(main)
    if not ok then
        warn("[Warden Stack] FAIL " .. tostring(failure))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(failure))
end)
task.delay(85, function()
    STS:EndTest("FAIL Warden stack Play global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_WardenBlockStackPlay")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Real Warden block/buff stack check failed: " .. tostring(result))
print("[Warden Stack] VERIFIED_PLAY_MODE_PASS")
