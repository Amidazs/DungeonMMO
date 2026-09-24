--!strict
-- Disposable Play-mode check of real player HP and server-owned shield rules.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Knight shield playtest requires an unpublished local Dungeon")

local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")

local driver = Instance.new("Script")
driver.Name = "TEMP_OathguardShieldDamage"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Schema = require(RS.Core.Shared.ProfileSchema)
local Stages = require(
    RS.Core.Shared.C4OriginalFirstTransferQuestStages
)
local Careers = require(
    RS.Core.Shared.OriginalFirstTransferDefinitions
)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Damage = require(SSS.Combat.DamageService)
local EPSILON = 0.001

--[[
Waits for a real player's spawned living Roblox character.

Args:
    None.

Returns:
    (Player, Model, Humanoid): Actual Play user and damage target.
]]
local function live_player()
    local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    local deadline = os.clock() + 35
    repeat
        local model = player.Character
        local humanoid = model
            and model:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0
            and model:FindFirstChild("HumanoidRootPart")
        then
            return player, model, humanoid
        end
        task.wait(0.1)
    until os.clock() >= deadline
    error("Real local Play character did not spawn")
end

--[[
Builds a synthetic but internally consistent earned Knight snapshot.

This disposable fixture does not substitute for the independent physical
quest, mentor, real purchase, equipment UI or profile persistence tests.

Args:
    user_id (number): Real Play client's current server-owned UserId.
    rank (number): First or second paid shield mastery rank.
    offhand (string?): Registered shield, wrong equipment or no item.

Returns:
    any: Isolated level-28 character with complete test-only quest receipt.
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
    advancement.OriginalFirstTransferReceiptId = "TEMP_KnightShieldPlay"
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
Applies genuine combat damage to one living player target.

Args:
    player (Player): Currently spawned actual Play user.
    model (Model): That user's actual Roblox character.
    humanoid (Humanoid): The real authoritative player HP object.
    source_kind (string): Enemy physical/magic or unaffected PvP kind.
    expected (number): Authoritatively calculated expected HP damage.
    label (string): Clear per-case regression diagnostic.

Returns:
    nil: Checks both returned damage and real Humanoid health loss.
]]
local function hit(player, model, humanoid, source_kind, expected, label)
    humanoid.MaxHealth = 1000
    humanoid.Health = 800
    local applied = Damage.apply_damage({
        attacker = nil, attacker_character = nil, target = model,
        source_kind = source_kind, source_id = "TEMP_ShieldDamage",
        base_damage = 100, multiplier = 1,
    })
    assert(math.abs(applied - expected) < EPSILON,
        label .. " wrong applied damage " .. tostring(applied))
    assert(math.abs(humanoid.Health - (800 - expected)) < EPSILON,
        label .. " did not change real player HP as expected")
    print("[Oathguard Shield Live] " .. label .. " PASS")
end

--[[
Proves shield rank and equipment modify real hostile physical player HP.

Args:
    None.

Returns:
    nil: Checks rank 1/2, absent/wrong gear, magic, PvP and forged class.
]]
local function main()
    local player, model, humanoid = live_player()
    player:SetAttribute("DungeonCombatAllowed", true)
    task.wait(1)
    local owner = knight_fixture(
        player.UserId, 1, "marauder_shield"
    )
    Runtime.set_character(player.UserId, owner)
    hit(player, model, humanoid, "EnemyMelee", 99.2,
        "REAL_RANK_ONE_MELEE")
    owner.Progression.Skills.OathguardShieldMastery.PurchasedRank = 2
    Runtime.set_character(player.UserId, owner)
    hit(player, model, humanoid, "EnemyMelee", 98.4,
        "REAL_RANK_TWO_MELEE")
    hit(player, model, humanoid, "EnemyArea", 98.4,
        "REAL_RANK_TWO_AREA")
    hit(player, model, humanoid, "EnemyMagic", 100,
        "REAL_MAGIC_UNAFFECTED")
    hit(player, model, humanoid, "Melee", 100,
        "REAL_PLAYER_DAMAGE_UNAFFECTED")
    owner.Equipment.OffHand = nil
    Runtime.set_character(player.UserId, owner)
    hit(player, model, humanoid, "EnemyMelee", 100,
        "REAL_UNEQUIPPED_SHIELD_DENIAL")
    owner.Equipment.OffHand = "marauder_armor"
    Runtime.set_character(player.UserId, owner)
    hit(player, model, humanoid, "EnemyMelee", 100,
        "REAL_WRONG_SLOT_DENIAL")
    owner.Equipment.OffHand = "marauder_shield"
    owner.Identity.ClassId = "Fighter"
    Runtime.set_character(player.UserId, owner)
    hit(player, model, humanoid, "EnemyMelee", 100,
        "REAL_FORGED_CLASS_DENIAL")
    Runtime.clear_character(player.UserId)
    print("[Oathguard Shield Live] ALL_REAL_PLAYER_HP_CHECKS_PASS")
end

task.spawn(function()
    local ok, failure = pcall(main)
    if not ok then
        warn("[Oathguard Shield Live] FAIL " .. tostring(failure))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(failure))
end)
task.delay(65, function()
    STS:EndTest("FAIL Knight shield damage Play global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_OathguardShieldDamagePlay")
end)
driver:Destroy()
assert(ok and result == "PASS",
    "Knight shield real-player HP test failed: " .. tostring(result))
print("[Oathguard Shield Live] VERIFIED_PLAY_MODE_PASS")
