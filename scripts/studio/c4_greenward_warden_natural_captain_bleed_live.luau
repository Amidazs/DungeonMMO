--!strict
-- One genuine client uses Warden Bleed Recovery after the Captain
-- AI naturally attacks with CaptainSlash, not a scripted damage hit.
-- Only disposable unpublished Dungeon Studio Play is permitted.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Warden bleed Play requires a disposable unpublished Dungeon")

local rs = game:GetService("ReplicatedStorage")
local sss = game:GetService("ServerScriptService")
local starter = game:GetService("StarterPlayer").StarterPlayerScripts
local studio = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "TEMP_WardenBleedInput"
channel.Parent = rs

local client = Instance.new("LocalScript")
client.Name = "TEMP_WardenBleedClient"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local channel = RS:WaitForChild("TEMP_WardenBleedInput")
local scripts = player:WaitForChild("PlayerScripts")
local state = require(scripts:WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local input = require(scripts:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))
local SKILL_ID = "GreenwardWardenBleedRecovery"

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
client.Parent = starter

local driver = Instance.new("Script")
driver.Name = "TEMP_WardenBleedServer"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Schema = require(RS.Core.Shared.ProfileSchema)
local Stages = require(RS.Core.Shared.C4OriginalFirstTransferQuestStages)
local Careers = require(RS.Core.Shared.OriginalFirstTransferDefinitions)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Bleed = require(SSS.Combat.PlayerBleedStatusService)
local Poison = require(SSS.Combat.PoisonStatusService)
local Mana = require(SSS.Combat.ManaService)
local Factory = require(SSS.Dungeon.MarauderCaptainFactory)
local CollectionService = game:GetService("CollectionService")

local channel = RS:WaitForChild("TEMP_WardenBleedInput")
local SKILL_ID = "GreenwardWardenBleedRecovery"
local ENCOUNTER_ID = "TEMP_WardenBleedRoom"
local receipts = {}

channel.OnServerEvent:Connect(function(player, action, accepted)
    receipts[player.UserId] = {action = action, accepted = accepted}
end)

--[[
Waits for a genuine Play client acknowledgement, never a forged user ID.

Args:
    player (Player): Live player owning the current character.
    action (string): Required message from the real client.

Returns:
    any: Actual bounded acknowledgement, or raises on timeout.
]]
local function await_receipt(player, action)
    local deadline = os.clock() + 12
    repeat
        local receipt = receipts[player.UserId]
        if receipt and receipt.action == action then
            return receipt
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Warden Bleed] Missing client receipt " .. action)
end

--[[
Obtains a real living Roblox Play avatar rather than a detached model.

Args:
    None.

Returns:
    (Player, Model, Humanoid): Actual owner and server-owned hit target.
]]
local function live_player()
    local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    await_receipt(player, "READY")
    local deadline = os.clock() + 35
    repeat
        local character = player.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0
            and character:FindFirstChild("HumanoidRootPart")
        then
            return player, character, humanoid
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Warden Bleed] No real Play character spawned")
end

--[[
Creates one real-owner but deliberately test-earned Elven Knight profile.

Args:
    user_id (number): Authenticated Studio player UserId.

Returns:
    any: Valid receipt, private class and purchased level-24 cure.
]]
local function earned_warden(user_id)
    local character = Schema.create_default(user_id).Characters.Slot1
    local source = assert(Stages.get("ElvenKnight"))
    character.Level = 24
    character.Identity = {
        Version = 1, RaceId = "Elf",
        BaseClassId = "Fighter", ClassId = "GreenwardWarden",
        CreationStage = "Complete",
    }
    local advance = character.ClassAdvancement
    advance.ActiveClassId = nil
    advance.OriginalFirstTransferChoiceId = "ElvenKnight"
    advance.OriginalFirstTransferClassId = "GreenwardWarden"
    advance.OriginalFirstTransferReceiptId = "TEMP_BleedPlayMentor"
    local proofs = {}
    for _, id in ipairs(source.RequiredProofIds) do
        proofs[id] = true
    end
    advance.OriginalFirstTransferQuest = {
        QuestId = source.Id, BranchId = "ElvenKnight",
        Step = #source.Steps + 1, Count = 0, Ready = true,
        AppliedEvents = {}, Proofs = proofs,
    }
    character.Progression.Skills[SKILL_ID] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    character.Progression.Loadout[1] = SKILL_ID
    assert(Careers.awarded(character) ~= nil,
        "Test class must pass real original advancement receipt gate")
    return character
end

--[[
Mints an actual tagged Captain model far from ordinary Play encounters.

Args:
    character (Model): Real player avatar being tested.

Returns:
    Model: Trusted temporary dungeon enemy model, deleted after test.
]]
local function create_captain(character)
    local enemy = Factory.create({
        Parent = workspace,
        SpawnCFrame = CFrame.new(0, 1000, 0),
        EncounterId = ENCOUNTER_ID,
        RewardXP = 0, RewardGoldMin = 0, RewardGoldMax = 0,
    })
    assert(enemy:GetAttribute("DungeonEncounterId") == ENCOUNTER_ID,
        "Temporary captain must have server-owned encounter identity")
    character:SetAttribute("DungeonRunParticipant", true)
    character:SetAttribute("DungeonEncounterId", ENCOUNTER_ID)
    local root = assert(character:FindFirstChild("HumanoidRootPart"))
    root.Anchored = true
    root.CFrame = CFrame.new(0, 1000, 4)
    root.AssemblyLinearVelocity = Vector3.zero
    return enemy
end

--[[
Ensures copied status attributes cannot create a curable bleed.

Args:
    character (Model): Real unpoisoned Play avatar.

Returns:
    nil: Confirms curative authority depends on private server records.
]]
local function reject_forged_status(character)
    character:SetAttribute("C4PlayerBleedTier", 1)
    assert(not Bleed.is_bleeding(character)
        and not Bleed.cure(character, 1),
        "Replicated bleed attribute cannot mint a server status")
    character:SetAttribute("C4PlayerBleedTier", 0)
end

--[[
Waits for the unmodified Captain AI to land its real Slash on the owner.

No test script calls DamageService or PlayerBleedStatusService.apply:
only the production Captain attack controller can mint this status.

Args:
    enemy (Model): Genuine tagged Captain with its running AI.
    character (Model): Real matched, living dungeon Play avatar.
    humanoid (Humanoid): Real HP must fall before server-owned bleed.

Returns:
    nil: Disables further boss attacks after the natural bleed appears.
]]
local function await_natural_captain_bleed(
    enemy, character, humanoid
)
    local initial_health = humanoid.Health
    local deadline = os.clock() + 12
    repeat
        if Bleed.is_bleeding(character) then break end
        task.wait(0.04)
    until os.clock() >= deadline
    assert(Bleed.is_bleeding(character)
        and character:GetAttribute("C4PlayerBleedTier") == 1
        and humanoid.Health < initial_health,
        "Real Captain AI must land unblocked Slash and cause owner bleed")
    -- Preserve the living enemy Model so any old bleed timer could
    -- still deal genuine damage, but disarm further boss AI swings.
    CollectionService:RemoveTag(enemy, "DungeonMarauderCaptain")
    print("[Warden Bleed] NATURAL_CAPTAIN_AI_SLASH_BLEED_PASS")
end

--[[
Casts the purchased self-only cure through actual client combat input.

Args:
    player (Player): Authenticated current Play caster.
    character (Model): Exact avatar with server-tracked bleed.
    humanoid (Humanoid): Actual HP used to reject free healing.

Returns:
    nil: Genuine mana-spending client cast clears only the bleed.
]]
local function cast_and_verify(player, character, humanoid)
    local before_pulse = character:GetAttribute("MageHealPulse")
    local before_mana = Mana.get(player)
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD")
    assert(await_receipt(player, "LOADED").accepted,
        "Actual client could not load earned Warden cure")
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST")
    assert(await_receipt(player, "CAST").accepted,
        "Actual client did not request Warden cure")
    local deadline = os.clock() + 8
    repeat
        if not Bleed.is_bleeding(character) then
            break
        end
        task.wait(0.05)
    until os.clock() >= deadline
    assert(not Bleed.is_bleeding(character),
        "Authentic client cast did not clear owner player bleed")
    assert(Mana.get(player) < before_mana,
        "Bleed cure must spend real owner mana")
    assert(character:GetAttribute("MageHealPulse") == before_pulse,
        "Bleed cure must not trigger the actual healing executor")
    assert(character:GetAttribute("C4PlayerBleedTier") == 0,
        "The actual server bleed must clear its presentation status")
    local prior_health = humanoid.Health
    local late_damage = false
    local health_listener = humanoid.HealthChanged:Connect(
        function(new_health)
            if new_health < prior_health - 0.001 then
                late_damage = true
            end
            prior_health = new_health
        end
    )
    task.wait(3.5)
    health_listener:Disconnect()
    assert(not Bleed.is_bleeding(character)
        and character:GetAttribute("C4PlayerBleedTier") == 0
        and not late_damage,
        "No delayed server bleed tick may harm the cured owner")
    print("[Warden Bleed] REAL_CLIENT_CURE_NO_LATE_TICK_PASS")
end

--[[
Exercises player-only cure and actual per-character server status.

Args:
    None.

Returns:
    nil: Marks true Play client success only after a real paid cleanse.
]]
local function main()
    local player, character, humanoid = live_player()
    player:SetAttribute("DungeonCombatAllowed", true)
    humanoid.MaxHealth = 1000
    humanoid.Health = 800
    Runtime.set_character(player.UserId, earned_warden(player.UserId))
    Mana.reset_player(player)
    reject_forged_status(character)
    local enemy = create_captain(character)
    await_natural_captain_bleed(enemy, character, humanoid)
    cast_and_verify(player, character, humanoid)
    enemy:Destroy()
    Runtime.clear_character(player.UserId)
    print("[Warden Bleed] ALL_REAL_CLIENT_STATUS_CHECKS_PASS")
end

task.spawn(function()
    local ok, failure = pcall(main)
    if not ok then
        warn("[Warden Bleed] FAIL " .. tostring(failure))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(failure))
end)
task.delay(90, function()
    STS:EndTest("FAIL Warden natural Captain bleed Play timeout")
end)
]==]
driver.Parent = sss

local ok, result = pcall(function()
    return studio:ExecutePlayModeAsync("TEMP_WardenBleedPlay")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "Warden real client bleed/cure failed: " .. tostring(result))
print("[Warden Bleed] VERIFIED_NATURAL_CAPTAIN_PLAY_PASS")
