--!strict
-- True owner Humanoid Play: genuine paid passive cannot heal forged/dead.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Warrior passive HP recovery requires unpublished local Studio")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")

local driver = Instance.new("Script")
driver.Name = "TEMP_WarriorRecoveryPlay"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Schema = require(RS.Core.Shared.ProfileSchema)
local Stages = require(RS.Core.Shared.C4OriginalFirstTransferQuestStages)
local Careers = require(RS.Core.Shared.OriginalFirstTransferDefinitions)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Recovery = require(SSS.Combat.IronvowHealthRecoveryService)
local SKILL_ID = "IronvowFieldRecovery"

--[[
Builds an internally valid, explicitly disposable earned Warrior.

Args:
    user_id (number): Current authenticated client user.
    weapon_id (string): Server-authoritative equipped item ID.

Returns:
    any: Source-receipted rank-one owner, not a persisted quest claim.
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
    advancement.OriginalFirstTransferReceiptId = "TEMP_CriticalStancePlay"
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
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    owner.Progression.Loadout[1] = SKILL_ID
    assert(Careers.awarded(owner) ~= nil,
        "Forged class receipt cannot seed disposable Warrior acceptance")
    return owner
end


--[[
Runs actual owner Humanoid HP, cap, dead and forged-profile checks.

Args:
    None.

Returns:
    nil: Requires owner-only paid bonus and safe expiry after rank loss.
]]
local function main()
    local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local owner = warrior_fixture(
        player.UserId, "stonewatch_training_mace"
    )
    Runtime.set_character(player.UserId, owner)
    player:SetAttribute("DungeonCombatAllowed", true)
    humanoid.MaxHealth = 2000
    humanoid.Health = 1100
    assert(math.abs(
        Runtime.get_health_recovery_per_second(player.UserId) - 1.1
    ) < 0.001, "Genuine bought passive did not enable HP regeneration")
    local before = humanoid.Health
    local received = Recovery.apply_tick(player, 1)
    assert(math.abs(received - 1.1) < 0.02
        and math.abs(humanoid.Health - before - received) < 0.02,
        "Paid Warrior passive did not restore 1.1 actual owner HP")
    humanoid.Health = humanoid.MaxHealth - 0.5
    local capped = Recovery.apply_tick(player, 1)
    assert(math.abs(capped - 0.5) < 0.02
        and humanoid.Health <= humanoid.MaxHealth,
        "Warrior HP recovery overhealed above actual owner maximum")
    humanoid.Health = 1100
    owner.Progression.Skills[SKILL_ID].PurchasedRank = 0
    Runtime.set_character(player.UserId, owner)
    assert(Recovery.apply_tick(player, 1) == 0,
        "Revoked source recovery still healed player for free")
    owner.Progression.Skills[SKILL_ID].PurchasedRank = 1
    owner.Identity.ClassId = "Fighter"
    Runtime.set_character(player.UserId, owner)
    assert(Recovery.apply_tick(player, 1) == 0,
        "Forged unawarded Fighter gained Warrior passive regeneration")
    owner.Identity.ClassId = "Ironvow"
    Runtime.set_character(player.UserId, owner)
    humanoid.Health = 0
    assert(Recovery.apply_tick(player, 1) == 0
        and humanoid.Health == 0,
        "Passive recovery resurrected a genuinely dead Humanoid")
    Runtime.clear_character(player.UserId)
    print("[Warrior Recovery] OWNER_HP_CAP_REVOKED_DEAD_PASS")
end

task.spawn(function()
    local ok, reason = pcall(main)
    if not ok then warn("[Warrior Recovery] FAIL " .. tostring(reason)) end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(35, function()
    STS:EndTest("FAIL Warrior recovery global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_WarriorHealthRecovery")
end)
driver:Destroy()
assert(ok and result == "PASS",
    "Real Warrior passive recovery Play failed: " .. tostring(result))
print("[Warrior Recovery] VERIFIED_PLAY_MODE_PASS")
