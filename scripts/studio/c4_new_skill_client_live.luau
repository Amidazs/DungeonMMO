--!strict
-- Focused real-client skills test in a disposable unpublished Dungeon build.
-- Character identities and UI snapshots are temporary test fixtures only.
assert(game.PlaceId == 0 and game.GameId == 0,
    "C4 client validation requires an unpublished Studio place")

local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local SPS = game:GetService("StarterPlayer").StarterPlayerScripts
local STS = game:GetService("StudioTestService")

local channel = Instance.new("RemoteEvent")
channel.Name = "C4ClientSkillProbe_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "C4ClientSkillInput_TEMP"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local channel = RS:WaitForChild("C4ClientSkillProbe_TEMP")
local scripts = player:WaitForChild("PlayerScripts")
local state = require(scripts:WaitForChild("Core")
    :WaitForChild("ProgressionClientState"))
local actions = require(scripts:WaitForChild("Combat")
    :WaitForChild("CombatInputActions"))

-- Args: predicate (function): Observation to poll.
--       label (string): Timeout diagnostic.
--       seconds (number): Maximum wait.
-- Returns: any: First truthy observation.
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local value = predicate()
        if value then return value end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[C4 Client] TIMEOUT " .. label)
end

local gui = wait_for(function()
    local player_gui = player:FindFirstChild("PlayerGui")
    return player_gui
        and player_gui:FindFirstChild("CharacterSkillsMenu")
end, "real SkillsMenu", 35)
local list = wait_for(function()
    return gui:FindFirstChild("SkillList", true)
end, "real skill rows", 15)

channel.OnClientEvent:Connect(function(action, skill_id)
    if action == "LOAD" then
        state.apply_snapshot({
            Skills = {
                [skill_id] = {Known = true, Rank = 1},
            },
            Loadout = {[1] = skill_id},
        })
        local row = wait_for(function()
            local button = list:FindFirstChild(skill_id)
            return button and button.Visible and button
        end, "visible " .. skill_id, 12)
        assert(string.find(row.Text, "Rank 1", 1, true),
            "Known skill row did not show trained rank")
        local foreign = if skill_id == "CinderBolt"
            then "ArcherDraw" else "CinderBolt"
        local hidden = list:FindFirstChild(foreign)
        assert(hidden and not hidden.Visible,
            "Unowned foreign-class skill is shown")
        assert(state.get_skill_for_slot(1) == skill_id,
            "Client slot does not match the selected skill")
        channel:FireServer("LOADED", skill_id)
    elseif action == "CAST" then
        assert(state.get_skill_for_slot(1) == skill_id,
            "Client lost its skill loadout")
        local sent = actions.request_skill_slot(1)
        channel:FireServer("CAST", skill_id, sent)
    end
end)
channel:FireServer("READY")
]==]
client.Parent = SPS

local driver = Instance.new("Script")
driver.Name = "C4SkillServerDriver_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local channel = RS:WaitForChild("C4ClientSkillProbe_TEMP")
local Schema = require(RS.Core.Shared.ProfileSchema)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Mana = require(SSS.Combat.ManaService)
local cases = {
    {class = "Mage", skill = "DawnWard",
        weapon = "apprentice_arcane_wand", kind = "Ward"},
    {class = "Mage", skill = "CinderBolt",
        weapon = "apprentice_arcane_wand", kind = "Damage"},
    {class = "Ranger", skill = "ArcherDraw",
        weapon = "apprentice_longbow", kind = "Damage"},
    {class = "Rogue", skill = "RogueVitalBlow",
        weapon = "marauder_sword", kind = "Damage"},
}
local receipts = {}
channel.OnServerEvent:Connect(function(player, action, skill, sent)
    receipts[player.UserId] = {
        action = action,
        skill = skill,
        sent = sent,
    }
end)

-- Args: predicate (function): Server-side observation.
--       label (string): Diagnostic name.
--       seconds (number): Maximum wait.
-- Returns: any: First truthy observation.
local function wait_for(predicate, label, seconds)
    local deadline = os.clock() + seconds
    repeat
        local result = predicate()
        if result then return result end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[C4 Client] TIMEOUT " .. label)
end

-- Args: player (Player): Client under test.
--       action (string): Required acknowledgement.
--       skill (string): Required skill identifier.
-- Returns: any: Matching client receipt.
local function await_receipt(player, action, skill)
    return wait_for(function()
        local receipt = receipts[player.UserId]
        if receipt and receipt.action == action
            and (not skill or receipt.skill == skill) then
            return receipt
        end
    end, action .. " " .. tostring(skill), 20)
end

-- Args: player (Player): Temporary Studio player.
--       case (table): Valid class, equipped weapon and learned skill.
-- Returns: nil: Seeds only this disposable server's runtime.
local function seed_class(player, case)
    local character = Schema.create_default(player.UserId)
        .Characters.Slot1
    character.Identity.RaceId = "Human"
    character.Identity.BaseClassId = case.class
    character.Identity.ClassId = case.class
    character.Identity.CreationStage = "Complete"
    character.Level = 5
    character.Equipment.Weapon = case.weapon
    character.Progression.Skills[case.skill] = {
        Known = true,
        PurchasedRank = 1,
        Proficiency = 0,
    }
    character.Progression.Loadout[1] = case.skill
    Runtime.set_character(player.UserId, character)
    local usable, reason = Runtime.is_skill_usable(
        player.UserId, case.skill
    )
    assert(usable, case.skill .. " blocked: " .. tostring(reason))
end

-- Args: player (Player): Caster.
--       target (Model): Stationary training target.
--       case (table): Current skill case.
-- Returns: nil: Moves and faces the real character near the target.
local function position(player, target, case)
    local character = assert(player.Character)
    local root = assert(character:FindFirstChild("HumanoidRootPart"))
    local target_root = assert(target:FindFirstChild("HumanoidRootPart"))
    local offset = if case.class == "Rogue" then 3.5 else -9
    local location = target_root.Position + Vector3.new(0, 0, offset)
    root.CFrame = CFrame.lookAt(location, target_root.Position)
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.3)
end

-- Args: player (Player): Live Studio client.
--       target (Model): Real combat target.
--       case (table): Skill effect to verify.
-- Returns: nil: Asserts actual server effect after a client hotbar action.
local function check_skill(player, target, case)
    seed_class(player, case)
    position(player, target, case)
    local humanoid = assert(target:FindFirstChildOfClass("Humanoid"))
    humanoid.MaxHealth = 1000
    humanoid.Health = 1000
    local baseline_mana = Mana.get(player)
    local initial_health = humanoid.Health
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD", case.skill)
    await_receipt(player, "LOADED", case.skill)
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST", case.skill)
    local sent = await_receipt(player, "CAST", case.skill)
    assert(sent.sent == true,
        case.skill .. " was not sent from CombatInputActions")
    if case.kind == "Ward" then
        wait_for(function()
            return player.Character
                and player.Character:GetAttribute("ArcaneWardCurrent")
                    and player.Character:GetAttribute("ArcaneWardCurrent") > 0
        end, "Dawn Ward server absorption", 8)
    else
        wait_for(function()
            return humanoid.Health < initial_health
        end, case.skill .. " real damage", 9)
    end
    if case.class == "Mage" then
        wait_for(function()
            return Mana.get(player) < baseline_mana - 2
        end, case.skill .. " server mana spend", 5)
    end
    print("[C4 Client] " .. case.skill .. " REAL_CLIENT_EFFECT_PASS")
    task.wait(0.6)
end

-- Args: None.
-- Returns: nil: Runs the targeted sequential client combat contract.
local function run()
    local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    await_receipt(player, "READY", nil)
    local character = wait_for(function()
        return player.Character
            and player.Character:FindFirstChild("HumanoidRootPart")
            and player.Character
    end, "real player character", 35)
    assert(character:FindFirstChildOfClass("Humanoid"),
        "Live player has no Humanoid")
    local dummy = wait_for(function()
        local model = Workspace:FindFirstChild("TrainingDummy")
        return model and model:FindFirstChildOfClass("Humanoid")
            and model
    end, "real training dummy", 25)
    player:SetAttribute("DungeonCombatAllowed", true)
    task.wait(2)
    for _, case in ipairs(cases) do
        check_skill(player, dummy, case)
    end
    print("[C4 Client] ALL_FOUR_SKILL_EFFECTS_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[C4 Client] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(145, function()
    STS:EndTest("FAIL client skill global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("C4NewSkillClient_TEMP")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "C4 skill client test failed: " .. tostring(result))
print("[C4 Client] VERIFIED_PLAY_MODE_PASS")
