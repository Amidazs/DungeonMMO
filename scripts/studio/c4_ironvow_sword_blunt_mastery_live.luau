--!strict
-- Unpublished real HP checks: four C4 Warrior sword AND blunt ranks.
assert(game.PlaceId == 0 and game.GameId == 0,
    "Warrior weapon acceptance requires unpublished full Dungeon")

local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")

local driver = Instance.new("Script")
driver.Name = "TEMP_WarriorWeaponServer"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local STS = game:GetService("StudioTestService")
local Schema = require(RS.Core.Shared.ProfileSchema)
local Stages = require(RS.Core.Shared.C4OriginalFirstTransferQuestStages)
local Careers = require(
    RS.Core.Shared.OriginalFirstTransferDefinitions
)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local Damage = require(SSS.Combat.DamageService)
local Passives = require(RS.Core.Shared.PassiveSkillEffects)
local ITEMS = require(RS.Core.Shared.ItemDefinitions)
local SKILL_ID = "IronvowBladeTraining"
local EPSILON = 0.03

--[[
Obtains genuine Play owner and actual existing tagged training target.

Args:
    None.

Returns:
    (Player, Model, Humanoid): Real Play user and actual target HP.
]]
local function live_target()
    local player = Players:GetPlayers()[1] or Players.PlayerAdded:Wait()
    local deadline = os.clock() + 35
    repeat
        local target = Workspace:FindFirstChild("TrainingDummy")
        local npc = target and target:FindFirstChildOfClass("Humanoid")
        if player.Character and npc and npc.Health > 0
            and player.Character:FindFirstChild("HumanoidRootPart")
        then return player, target, npc end
        task.wait(0.1)
    until os.clock() >= deadline
    error("[Warrior Weapon] Real player or NPC dummy failed to spawn")
end

--[[
Creates a test-only personally awarded Warrior class receipt and owner.

Args:
    user_id (number): Authenticated Play player whose server profile is used.
    rank (number): Independent purchased passive source rank.
    offhand (string?): Not required for physical weapon mastery.

Returns:
    any: Detached earned Warrior profile for real server damage execution.
]]
local function warrior_fixture(user_id, rank, offhand)
    local character = Schema.create_default(user_id).Characters.Slot1
    local source = assert(Stages.get("HumanWarrior"))
    character.Level = 28
    character.Identity = {
        Version = 1, RaceId = "Human", BaseClassId = "Fighter",
        ClassId = "Ironvow", CreationStage = "Complete",
    }
    local advancement = character.ClassAdvancement
    advancement.ActiveClassId = nil
    advancement.OriginalFirstTransferChoiceId = "HumanWarrior"
    advancement.OriginalFirstTransferClassId = "Ironvow"
    advancement.OriginalFirstTransferReceiptId = "TEMP_WarriorWeaponPlay"
    local proofs = {}
    for _, proof_id in ipairs(source.RequiredProofIds) do
        proofs[proof_id] = true
    end
    advancement.OriginalFirstTransferQuest = {
        QuestId = source.Id, BranchId = "HumanWarrior",
        Step = #source.Steps + 1, Ready = true,
        Count = 0, Proofs = proofs, AppliedEvents = {},
    }
    character.Equipment.OffHand = offhand
    assert(Careers.awarded(character) ~= nil,
        "Synthetic source receipts must pass real class validation")
    return character
end



--[[
Returns server-authoritative physical-multiplier bonus for current gear.

Args:
    player (Player): Authenticated owner of isolated saved equipment state.
    rank (number): Bought Warrior mastery rank 0, 1 or 4.
    weapon_id (string?): Server-registered Sword, Blunt, Dagger or nil.
    expected_bonus (number): Expected total passive bonus, not full stat.

Returns:
    number: Actual runtime physical multiplier after valid owned equipment.
]]
local function set_weapon(player, rank, weapon_id, expected_bonus)
    local owner = warrior_fixture(player.UserId, 0, nil)
    owner.Level = 28
    owner.Equipment.Weapon = weapon_id
    owner.Progression.Skills[SKILL_ID] = {
        Known = rank > 0,
        PurchasedRank = rank,
        Proficiency = 0,
    }
    Runtime.set_character(player.UserId, owner)
    local bonus = Passives.damage_bonus(owner, SKILL_ID)
    assert(math.abs(bonus - expected_bonus) < EPSILON,
        "Warrior weapon category or purchased passive bonus was wrong "
            .. tostring(weapon_id) .. "=" .. tostring(bonus))
    return Runtime.get_physical_multiplier(player.UserId)
end

--[[
Applies the real engine physical damage to a live world NPC Humanoid.

Args:
    player (Player): Genuine combat owner.
    target (Model): Real training NPC.
    npc (Humanoid): Its actual server HP, not a mock damage number.
    multiplier (number): Actual saved owner attribute/equipment/skill.
    label (string): Distinct per-family regression diagnostic.

Returns:
    number: Actual applied damage after verifying the NPC lost that HP.
]]
local function hit(player, target, npc, multiplier, label)
    npc.MaxHealth = 3000
    npc.Health = 2000
    local applied = Damage.apply_damage({
        attacker = player,
        attacker_character = player.Character,
        target = target, source_kind = "Melee",
        source_id = "TEMP_WarriorRealWeaponMastery",
        base_damage = 100, multiplier = multiplier,
    })
    assert(applied > 0
        and math.abs(npc.Health - (2000 - applied)) < EPSILON,
        "Actual Warrior " .. label .. " hit did not damage real NPC HP")
    print("[Warrior Weapon] " .. label .. "_REAL_NPC_HP_PASS "
        .. tostring(applied))
    return applied
end

--[[
Checks identical per-rank gains for real sword and real blunt equipment.

Args:
    player (Player): Authenticated Play client.
    target (Model): Actual NPC model.
    npc (Humanoid): Authoritative NPC health.

Returns:
    nil: Verifies rank 1 and 4 gains, unequipped/dagger/forged denial.
]]
local function main_checks(player, target, npc)
    player:SetAttribute("DungeonCombatAllowed", true)
    local sword = "marauder_sword"
    local blunt = "stonewatch_training_mace"
    assert(ITEMS.get(blunt).Category == "Blunt"
        and ITEMS.get(sword).Category == "Sword",
        "Registered weapon families are not independent items")
    local sword_base = set_weapon(player, 0, sword, 0)
    local blunt_base = set_weapon(player, 0, blunt, 0)
    local rank_one = set_weapon(player, 1, sword, 0.014)
    local rank_four = set_weapon(player, 4, sword, 0.056)
    local blunt_one = set_weapon(player, 1, blunt, 0.014)
    local blunt_four = set_weapon(player, 4, blunt, 0.056)
    assert(math.abs(rank_one - sword_base - 0.014) < EPSILON
        and math.abs(rank_four - sword_base - 0.056) < EPSILON
        and math.abs(blunt_one - blunt_base - 0.014) < EPSILON
        and math.abs(blunt_four - blunt_base - 0.056) < EPSILON,
        "Warrior sword and blunt real server attack multiplier differs")
    local sword_base_hp = hit(player, target, npc, sword_base,
        "SWORD_UNTRAINED")
    local sword_hp = hit(player, target, npc, rank_four,
        "SWORD_MASTERED")
    local blunt_base_hp = hit(player, target, npc, blunt_base,
        "BLUNT_UNTRAINED")
    local blunt_hp = hit(player, target, npc, blunt_four,
        "BLUNT_MASTERED")
    assert(sword_hp - sword_base_hp > 5.5
        and blunt_hp - blunt_base_hp > 5.5,
        "Both real source weapon families must benefit from rank four")
    set_weapon(player, 4, nil, 0)
    set_weapon(player, 4, "neti_trial_dagger", 0)
    local owner = warrior_fixture(player.UserId, 0, nil)
    owner.Identity.ClassId = "Fighter"
    owner.Equipment.Weapon = blunt
    owner.Progression.Skills[SKILL_ID] = {
        Known = true, PurchasedRank = 4, Proficiency = 0,
    }
    Runtime.set_character(player.UserId, owner)
    assert(Passives.damage_bonus(owner, SKILL_ID) == 0
        and not Runtime.is_skill_usable(player.UserId, SKILL_ID),
        "Unawarded Fighter cannot inherit Warrior weapon mastery")
    Runtime.clear_character(player.UserId)
    print("[Warrior Weapon] ALL_REAL_FAMILY_HP_TESTS_PASS")
end

--[[
Runs actual world damage and equipment isolation in unpublished Play.

Args:
    None.

Returns:
    nil: Ends Play only after both authentic skill-family HP gains pass.
]]
local function main()
    local player, target, npc = live_target()
    task.wait(1)
    main_checks(player, target, npc)
end

task.spawn(function()
    local ok, failure = pcall(main)
    if not ok then
        warn("[Warrior Weapon] FAIL " .. tostring(failure))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(failure))
end)
task.delay(65, function()
    STS:EndTest("FAIL Warrior weapon mastery Play global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("TEMP_WarriorWeaponMasteryPlay")
end)
driver:Destroy()
assert(ok and result == "PASS",
    "Warrior real two-weapon mastery HP check failed: "
        .. tostring(result))
print("[Warrior Weapon] VERIFIED_PLAY_MODE_PASS")
