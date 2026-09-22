--!strict
-- Authentic C4 poison/cleanse client hotbar integration in unpublished Play.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 poison live tests require an unpublished Studio place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "TEMP_C4PoisonInput"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "TEMP_C4PoisonClient"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local channel = RS:WaitForChild("TEMP_C4PoisonInput")
local scripts = player:WaitForChild("PlayerScripts")
local state = require(scripts:WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local actions = require(scripts:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))

channel.OnClientEvent:Connect(function(action, skill_id)
    if action == "LOAD" then
        state.apply_snapshot({
            Skills = {
                [skill_id] = {Known = true, Rank = 1},
            },
            Loadout = {[1] = skill_id},
        })
        assert(state.get_skill_for_slot(1) == skill_id,
            "Client rejected authoritative skill loadout")
        channel:FireServer("LOADED", skill_id, true)
    elseif action == "CAST" then
        assert(state.get_skill_for_slot(1) == skill_id,
            "Client lost requested hotbar skill")
        channel:FireServer(
            "CAST", skill_id, actions.request_skill_slot(1)
        )
    end
end)
channel:FireServer("READY")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "TEMP_C4PoisonServer"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local channel = RS:WaitForChild("TEMP_C4PoisonInput")
local Schema = require(RS.Core.Shared.ProfileSchema)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Poison = require(SSS.Combat.PoisonStatusService)
local Mana = require(SSS.Combat.ManaService)
local Stamina = require(SSS.Combat.StaminaService)
local receipts = {}

channel.OnServerEvent:Connect(function(player, action, skill_id, sent)
    receipts[player.UserId] = {
        action = action,
        skill_id = skill_id,
        sent = sent,
    }
end)

--[[
Polls an actual server/player state with a bounded deadline.

Args:
    predicate (function): Condition producing a truthy observation.
    label (string): Failure diagnostic.
    seconds (number): Maximum wait in seconds.

Returns:
    any: First truthy value from a real test state.
]]
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.05)
    until os.clock() >= deadline
    error("[C4 Poison Live] TIMEOUT " .. label)
end

--[[
Waits for the disposable client's acknowledgement of real hotbar input.

Args:
    player (Player): Authenticated Studio player.
    action (string): Expected client action.
    skill_id (string?): Expected skill, or nil for initial readiness.

Returns:
    any: The matching client receipt.
]]
local function receipt_for(player, action, skill_id)
    return wait_for(function()
        local receipt = receipts[player.UserId]
        if receipt and receipt.action == action
            and (skill_id == nil or receipt.skill_id == skill_id)
        then
            return receipt
        end
    end, action .. " " .. tostring(skill_id), 15)
end

--[[
Seeds only a disposable server runtime, never a persisted user profile.

Args:
    player (Player): Actual Play client.
    race_id (string): Human Mystic or Elf Scout source race.
    class_id (string): Registered DungeonMMO starting class.
    skill_id (string): Owned rank-one skill to cast.

Returns:
    nil: Applies a legal selected class, purchase and active loadout.
]]
local function seed_skill(player, race_id, class_id, skill_id)
    local character = Schema.create_default(player.UserId).Characters.Slot1
    character.Identity.RaceId = race_id
    character.Identity.BaseClassId = class_id
    character.Identity.ClassId = class_id
    character.Identity.CreationStage = "Complete"
    character.Level = if class_id == "Mage" then 7 else 24
    character.Equipment.Weapon = if class_id == "Mage"
        then "apprentice_arcane_wand" else "scout_dagger"
    character.Progression.Skills.MageHeal = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    character.Progression.Skills.MysticWindBolt = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    character.Progression.Skills[skill_id] = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    character.Progression.Loadout[1] = skill_id
    Runtime.set_character(player.UserId, character)
    local usable, reason = Runtime.is_skill_usable(
        player.UserId, skill_id
    )
    assert(usable, skill_id .. " blocked: " .. tostring(reason))
    Mana.reset_player(player)
    Stamina.reset_player(player)
end

--[[
Loads and triggers an actual client hotbar action, not a direct server
function invocation.

Args:
    player (Player): Real Studio client.
    skill_id (string): Purchased skill in server loadout.

Returns:
    nil: Confirms genuine input was sent.
]]
local function cast_from_client(player, skill_id)
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD", skill_id)
    receipt_for(player, "LOADED", skill_id)
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST", skill_id)
    local cast = receipt_for(player, "CAST", skill_id)
    assert(cast.sent == true, skill_id .. " hotbar request rejected")
end

--[[
Tests confirmed projectile impact, three real poison damage ticks
and automatic expiration against the existing live training NPC.

Args:
    player (Player): Authenticated actual Human Mystic.
    dummy (Model): Existing server-owned training enemy.

Returns:
    nil: Confirms actual health loss and non-stacking status expiry.
]]
local function check_curse(player, dummy)
    local root = assert(player.Character:FindFirstChild(
        "HumanoidRootPart"
    ))
    local target_root = assert(dummy:FindFirstChild("HumanoidRootPart"))
    root.CFrame = CFrame.lookAt(
        target_root.Position + Vector3.new(0, 0, -9),
        target_root.Position
    )
    root.AssemblyLinearVelocity = Vector3.zero
    local humanoid = assert(dummy:FindFirstChildOfClass("Humanoid"))
    humanoid.MaxHealth = 1000
    humanoid.Health = 1000
    seed_skill(player, "Human", "Mage", "MysticPoisonCurse")
    task.wait(0.35)
    cast_from_client(player, "MysticPoisonCurse")
    wait_for(function()
        return Poison.is_poisoned(dummy) and humanoid.Health < 1000
    end, "real Mystic curse projectile impact", 8)
    local first_health = humanoid.Health
    wait_for(function()
        return humanoid.Health <= first_health - 7
    end, "at least two server-owned poison damage ticks", 4)
    wait_for(function()
        return not Poison.is_poisoned(dummy)
    end, "third poison tick and expiry", 4)
    assert(humanoid.Health <= 985,
        "Three poison ticks did not damage the actual training NPC")
    print("[C4 Poison Live] REAL_CURSE_THREE_TICKS_PASS")
end

--[[
Proves both genuinely purchased healing-class cures remove real server
poison while the player has full health, without pretending to heal.

Args:
    player (Player): Authenticated live Studio character.
    race_id (string): Human Mystic or Elf Scout.
    class_id (string): Correct original-game analogue owner.
    skill_id (string): Server-defined friendly cure skill.

Returns:
    nil: Verifies real client cast and absence of any later damage tick.
]]
local function check_cure(player, race_id, class_id, skill_id)
    seed_skill(player, race_id, class_id, skill_id)
    local character = assert(player.Character)
    local humanoid = assert(character:FindFirstChildOfClass("Humanoid"))
    humanoid.Health = humanoid.MaxHealth
    assert(Poison.apply(
        character, nil, 1, 6, 1, 1, "C4TestNpcPoison"
    ), "Trusted server enemy could not apply real poison to player")
    assert(Poison.is_poisoned(character),
        "The server failed to retain applied enemy poison")
    cast_from_client(player, skill_id)
    wait_for(function()
        return not Poison.is_poisoned(character)
    end, skill_id .. " cleansed actual poison", 8)
    local cleaned_health = humanoid.Health
    task.wait(1.2)
    assert(humanoid.Health == cleaned_health,
        "Cleansed poison continued to damage the live player")
    print("[C4 Poison Live] " .. skill_id
        .. " REAL_CLIENT_CLEANSE_PASS")
end

--[[
Executes the isolated spell path after genuine client readiness.

Args:
    None.

Returns:
    nil: Ends only after all three real poison/cure flows succeed.
]]
local function main()
    local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    receipt_for(player, "READY", nil)
    wait_for(function()
        local model = player.Character
        return model and model:FindFirstChild("HumanoidRootPart")
    end, "real Play character", 35)
    local dummy = wait_for(function()
        local model = Workspace:FindFirstChild("TrainingDummy")
        return model and model:FindFirstChildOfClass("Humanoid")
            and model
    end, "real training enemy", 30)
    player:SetAttribute("DungeonCombatAllowed", true)
    task.wait(2)
    check_curse(player, dummy)
    check_cure(player, "Human", "Mage", "MysticCurePoison")
    check_cure(
        player, "Elf", "Rogue", "ElvenScoutPoisonRecovery"
    )
    print("[C4 Poison Live] ALL_THREE_REAL_CLIENT_EFFECTS_PASS")
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then
        warn("[C4 Poison Live] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(100, function()
    STS:EndTest("FAIL poison/cleanse global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_C4PoisonLive")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "C4 poison client integration failed: " .. tostring(result))
print("[C4 Poison Live] VERIFIED_PLAY_MODE_PASS")
