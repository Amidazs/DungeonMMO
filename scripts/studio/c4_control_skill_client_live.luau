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
channel.Name = "C4ControlClientProbe_TEMP"
channel.Parent = RS

local client = Instance.new("LocalScript")
client.Name = "C4ControlClientInput_TEMP"
client.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local channel = RS:WaitForChild("C4ControlClientProbe_TEMP")
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
    error("[C4 Control Client] TIMEOUT " .. label)
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
        wait_for(function()
            local button = list:FindFirstChild(skill_id)
            return button and button.Visible
                and string.find(button.Text, "Rank 1", 1, true)
                and button
        end, "visible learned rank " .. skill_id, 12)
        local foreign = if skill_id == "BriarVolley"
            then "DisruptingCut" else "BriarVolley"
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
driver.Name = "C4ControlClientServer_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local STS = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local channel = RS:WaitForChild("C4ControlClientProbe_TEMP")
local Schema = require(RS.Core.Shared.ProfileSchema)
local Runtime = require(SSS.Core.Services.ProgressionRuntimeState)
local DamageService = require(SSS.Combat.DamageService)
local ThreatService = require(SSS.Combat.ThreatService)
local cases = {
    {class = "Ranger", skill = "BriarVolley",
        weapon = "apprentice_longbow", kind = "Slow"},
    {class = "Rogue", skill = "DisruptingCut",
        weapon = "marauder_sword", kind = "Stagger"},
    {class = "Ranger", skill = "ThunderShot",
        weapon = "apprentice_longbow", kind = "Stagger",
        level = 36},
    {class = "Rogue", skill = "LaceratingCut",
        weapon = "scout_dagger", kind = "Bleed",
        level = 24},
    {class = "Mage", skill = "MysticWindBolt",
        weapon = "apprentice_arcane_wand", kind = "Damage",
        level = 7},
    {class = "Mage", skill = "MysticFrostBolt",
        weapon = "apprentice_arcane_wand", kind = "Frost",
        level = 7},
    {class = "Mage", skill = "MysticLifeDrain",
        weapon = "apprentice_arcane_wand", kind = "Drain",
        level = 14},
    {class = "Mage", skill = "MysticBattleHeal",
        weapon = "apprentice_arcane_wand", kind = "Heal",
        level = 14},
    {class = "Mage", skill = "MysticHealingPrayer",
        weapon = "apprentice_arcane_wand", kind = "Heal",
        level = 7},
    {class = "Fighter", race = "Elf",
        skill = "ElvenFighterRenewal",
        weapon = "marauder_sword", kind = "Heal",
        level = 15},
    {class = "Fighter", skill = "FighterBowShot",
        weapon = "apprentice_longbow", kind = "Damage",
        level = 5},
    {class = "Fighter", skill = "FighterDaggerStrike",
        weapon = "scout_dagger", kind = "Damage",
        level = 5},
    {class = "Ranger", skill = "ScoutFocusedShot",
        weapon = "apprentice_longbow", kind = "Damage",
        level = 20},
    {class = "Rogue", skill = "RogueFinishingCut",
        weapon = "scout_dagger", kind = "Damage",
        level = 20},
    {class = "Ranger", race = "Elf",
        skill = "ElvenCalmingShot",
        weapon = "apprentice_longbow", kind = "Charm",
        level = 20},
    {class = "Rogue", race = "Elf",
        skill = "ElvenRenewal",
        weapon = "marauder_sword", kind = "Heal",
        level = 20},
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
    error("[C4 Control Client] TIMEOUT " .. label)
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
    character.Identity.RaceId = case.race or "Human"
    character.Identity.BaseClassId = case.class
    character.Identity.ClassId = case.class
    character.Identity.CreationStage = "Complete"
    character.Level = case.level or 5
    local progression = require(
        RS.Core.Shared.SkillProgressionDefinitions
    ).get(case.skill)
    if progression and progression.Prerequisites then
        for _, required in ipairs(progression.Prerequisites) do
            character.Progression.Skills[required.SkillId] = {
                Known = true,
                PurchasedRank = required.Rank,
                Proficiency = required.Proficiency,
            }
        end
    end
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
    local offset = if case.class == "Rogue"
        or case.weapon == "scout_dagger" then 3.5 else -9
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
    -- The client still uses the actual project SkillsMenu and hotbar.
    -- Only the selected character/loadout are synthetic Studio fixtures.
    seed_class(player, case)
    position(player, target, case)
    local humanoid = assert(target:FindFirstChildOfClass("Humanoid"))
    humanoid.MaxHealth = 1000
    humanoid.Health = 1000
    local secondary = nil
    if case.kind == "Slow" then
        secondary = assert(Workspace:FindFirstChild(
            "TrainingDummyCleave"
        ), "Second physical target is missing")
        local second_humanoid = assert(
            secondary:FindFirstChildOfClass("Humanoid")
        )
        second_humanoid.MaxHealth = 1000
        second_humanoid.Health = 1000
        local target_root = assert(target:FindFirstChild(
            "HumanoidRootPart"
        ))
        -- Put the second dummy directly behind the first on the arrow
        -- path; the server must hit/slow both rather than just accept
        -- MAX_TARGETS metadata in an offline definition test.
        secondary:PivotTo(CFrame.new(
            target_root.Position + Vector3.new(0, 0, 4)
        ))
    end
    local initial_health = humanoid.Health
    local health_before_heal = 0
    local threat_before = 0
    if case.kind == "Heal" or case.kind == "Drain" then
        local player_humanoid = assert(
            player.Character:FindFirstChildOfClass("Humanoid")
        )
        player_humanoid.Health = math.max(
            1, player_humanoid.MaxHealth - 70
        )
        health_before_heal = player_humanoid.Health
    elseif case.kind == "Charm" then
        ThreatService.add_threat(target, player.UserId, 120)
        threat_before = ThreatService.get_threat(
            target, player.UserId
        )
    end
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD", case.skill)
    await_receipt(player, "LOADED", case.skill)
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST", case.skill)
    local sent = await_receipt(player, "CAST", case.skill)
    assert(sent.sent == true,
        case.skill .. " was not sent from CombatInputActions")
    if case.kind ~= "Heal" then
        wait_for(function()
            return humanoid.Health < initial_health
        end, case.skill .. " real target damage", 9)
    end
    if case.kind == "Heal" then
        local player_humanoid = assert(
            player.Character:FindFirstChildOfClass("Humanoid")
        )
        wait_for(function()
            return player_humanoid.Health > health_before_heal
        end, "Elf Renewal real owner healing", 8)
        local initial_recovery = player_humanoid.Health
        wait_for(function()
            return player_humanoid.Health > initial_recovery + 1
        end, "Elf Renewal real regeneration tick", 5)
        assert(target.Humanoid.Health == initial_health,
            "Elf self-heal incorrectly damaged the training NPC")
        print("[C4 Control Client] ELF_SELF_RENEWAL_PASS")
    elseif case.kind == "Drain" then
        local caster = assert(player.Character)
        local caster_humanoid = assert(
            caster:FindFirstChildOfClass("Humanoid")
        )
        wait_for(function()
            return caster_humanoid.Health > health_before_heal
                and (caster:GetAttribute("MageHealLastAmount") or 0) > 0
        end, "Life Drain must heal the real living caster on impact", 7)
        local damage = initial_health - humanoid.Health
        local last_heal = caster:GetAttribute("MageHealLastAmount")
        assert(math.abs(last_heal - damage * 0.20) < 0.1,
            "Life Drain heal must equal a fraction of actual NPC damage")
        assert(target:GetAttribute("LastMagicSkillId") == case.skill,
            "Life Drain healed without a matching real projectile hit")
        print("[C4 Control Client] LIFE_DRAIN_REAL_DAMAGE_HEAL_PASS")
    elseif case.kind == "Charm" then
        local applied = initial_health - humanoid.Health
        wait_for(function()
            return ThreatService.get_threat(target, player.UserId)
                <= (threat_before + applied) * 0.91
        end, "Elf arrow must reduce actual post-impact enemy threat", 6)
        print("[C4 Control Client] ELF_CALMING_THREAT_PASS")
    elseif case.kind == "Slow" then
        wait_for(function()
            return (target:GetAttribute("RangerSlowMultiplier") or 1)
                < 0.99
        end, "Briar Volley real target slow", 6)
        assert((target:GetAttribute("RangerSlowEndsAt") or 0)
            > os.clock(), "Briar Volley slow did not persist")
        local second_humanoid = assert(
            secondary:FindFirstChildOfClass("Humanoid")
        )
        wait_for(function()
            return second_humanoid.Health < 1000
                and (secondary:GetAttribute("RangerSlowMultiplier")
                    or 1) < 0.99
        end, "Briar Volley second real target slow", 7)
        print("[C4 Control Client] TWO_TARGET_SLOW_PASS")
        secondary:PivotTo(CFrame.new(
            target:GetPivot().Position + Vector3.new(25, 0, 0)
        ))
        print("[C4 Control Client] SERVER_SLOW_PASS")
    elseif case.kind == "Frost" then
        wait_for(function()
            return (target:GetAttribute("RangerSlowMultiplier") or 1)
                < 0.99
        end, "Mystic Frost real server-owned NPC movement slow", 6)
        assert((target:GetAttribute("RangerSlowEndsAt") or 0)
            > os.clock(), "Mystic Frost slow did not persist")
        print("[C4 Control Client] MYSTIC_FROST_REAL_SLOW_PASS")
    elseif case.kind == "Stagger" then
        wait_for(function()
            return (target:GetAttribute("CombatStaggeredUntil") or 0)
                > os.clock()
        end, case.skill .. " real target stagger", 6)
        print("[C4 Control Client] SERVER_STAGGER_PASS")
    elseif case.kind == "Bleed" then
        wait_for(function()
            return (target:GetAttribute("RogueBleedRemainingTicks")
                or 0) == 3
        end, "Lacerating Cut server bleed applied", 6)
        local direct_hit_health = humanoid.Health
        wait_for(function()
            return humanoid.Health < direct_hit_health
                and (target:GetAttribute("RogueBleedRemainingTicks")
                    or 0) < 3
        end, "Lacerating Cut real delayed damage tick", 5)
        assert(target:GetAttribute("RogueBleedSourceUserId")
            == player.UserId, "Bleed damage lost attacker attribution")
        print("[C4 Control Client] SERVER_BLEED_TICK_PASS")
        wait_for(function()
            return (target:GetAttribute("RogueBleedRemainingTicks")
                or 0) == 0
        end, "Lacerating Cut all three server ticks complete", 5)
        assert(humanoid.Health <= direct_hit_health - 8.5,
            "Three scheduled rank-one bleed ticks did not deal damage")
        local health_after_bleed = humanoid.Health
        task.wait(0.8)
        assert(math.abs(humanoid.Health - health_after_bleed) < 0.01,
            "Expired bleed continued dealing damage")
        print("[C4 Control Client] THREE_TICKS_AND_EXPIRY_PASS")
    end
    print("[C4 Control Client] " .. case.skill .. " REAL_CLIENT_EFFECT_PASS")
    task.wait(0.6)
end

--[[
Deals a test-only physical or magical enemy hit to the live player.

Args:
    player (Player): Disposable Studio player receiving the test hit.
    source_kind (string): Server-owned damage classification.

Returns:
    number: Actual damage applied by the production damage service.
]]
local function hit_player(player, source_kind)
    local target = assert(player.Character)
    return DamageService.apply_damage({
        attacker = nil,
        attacker_character = Workspace.TrainingDummy,
        target = target,
        source_kind = source_kind,
        source_id = "C4ScoutArmorFocus",
        attack_id = nil,
        base_damage = 20,
        multiplier = 1,
    })
end

--[[
Checks that a purchased light-armour passive actually mitigates physical
enemy damage, not magical damage or damage to an unarmoured player.

Args:
    player (Player): Living disposable Studio player.

Returns:
    nil: Verifies server-owned equipment/rank mitigation end-to-end.
]]
local function check_light_armor(player)
    local humanoid = assert(
        player.Character:FindFirstChildOfClass("Humanoid")
    )
    humanoid.MaxHealth = 1000
    humanoid.Health = 1000
    local character = Schema.create_default(player.UserId)
        .Characters.Slot1
    character.Identity.RaceId = "Human"
    character.Identity.BaseClassId = "Ranger"
    character.Identity.ClassId = "Ranger"
    character.Identity.CreationStage = "Complete"
    character.Level = 36
    character.Equipment.Weapon = "apprentice_longbow"
    character.Equipment.Body = "scout_leather_vest"
    Runtime.set_character(player.UserId, character)
    local baseline = hit_player(player, "EnemyMelee")
    character.Progression.Skills.ScoutLightArmorMastery = {
        Known = true, PurchasedRank = 10, Proficiency = 0,
    }
    Runtime.set_character(player.UserId, character)
    local armoured = hit_player(player, "EnemyMelee")
    local magic = hit_player(player, "MagicSkill")
    character.Equipment.Body = nil
    Runtime.set_character(player.UserId, character)
    local unarmoured = hit_player(player, "EnemyMelee")
    assert(math.abs(baseline - 20) < 0.01,
        "Untrained player must take full physical NPC damage")
    assert(math.abs(armoured - 18.4) < 0.01,
        "Rank ten light armour must prevent 8% physical NPC damage")
    assert(math.abs(magic - 20) < 0.01,
        "Light armour must not incorrectly reduce magical damage")
    assert(math.abs(unarmoured - 20) < 0.01,
        "Unequipped light armour must not mitigate enemy damage")
    print("[C4 Control Client] LIGHT_ARMOR_REAL_DAMAGE_PASS")
end

--[[
Verifies a bought level-28 passive changes actual server Humanoid speed
after a real client-triggered combat-state transition.

Args:
    player (Player): Disposable live Studio client.
    target (Model): Existing server-owned training dummy.

Returns:
    nil: Rejects metadata-only movement and locked-state bypasses.
]]
local function check_scout_movement(player, target)
    local humanoid = assert(
        player.Character:FindFirstChildOfClass("Humanoid")
    )
    local character = Schema.create_default(player.UserId)
        .Characters.Slot1
    character.Identity.RaceId = "Human"
    character.Identity.BaseClassId = "Ranger"
    character.Identity.ClassId = "Ranger"
    character.Identity.CreationStage = "Complete"
    character.Level = 28
    character.Equipment.Weapon = "apprentice_longbow"
    character.Progression.Skills.PiercingShot = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    character.Progression.Loadout[1] = "PiercingShot"
    Runtime.set_character(player.UserId, character)
    position(player, target, {class = "Ranger"})
    local baseline = wait_for(function()
        return humanoid.WalkSpeed >= 15 and humanoid.WalkSpeed
    end, "untrained live player locomotion", 5)
    character.Progression.Skills.ScoutFleetFoot = {
        Known = true, PurchasedRank = 1, Proficiency = 0,
    }
    Runtime.set_character(player.UserId, character)

    local stamina = require(SSS.Combat.StaminaService)
    stamina.reset_player(player)
    receipts[player.UserId] = nil
    channel:FireClient(player, "LOAD", "PiercingShot")
    await_receipt(player, "LOADED", "PiercingShot")
    receipts[player.UserId] = nil
    channel:FireClient(player, "CAST", "PiercingShot")
    local receipt = await_receipt(player, "CAST", "PiercingShot")
    assert(receipt.sent == true,
        "Movement test skill was not issued through live input")
    local boosted = wait_for(function()
        local speed = humanoid.WalkSpeed
        return speed > baseline + 0.5 and speed
    end, "earned speed applied to real Humanoid", 8)
    assert(math.abs(boosted - baseline * 1.06) < 0.15,
        "Scout passive speed is not the authored six-percent increase")
    print("[C4 Control Client] SCOUT_REAL_MOVEMENT_SPEED_PASS")
end

--[[
Deals one guaranteed server-owned critical hit using the live player's
authoritative purchased skill multiplier.

Args:
    player (Player): Disposable player whose saved rank controls damage.
    target (Model): Real tagged NPC receiving the physical hit.

Returns:
    number: Actual health damage dealt to the NPC.
]]
local function apply_scout_critical(player, target)
    return DamageService.apply_damage({
        attacker = nil,
        attacker_character = player.Character,
        target = target,
        source_kind = "Melee",
        source_id = "C4ScoutCriticalFocus",
        base_damage = 20,
        multiplier = 1,
        critical_chance = 1,
        critical_damage_multiplier = Runtime
            .get_critical_damage_multiplier(player.UserId),
        critical_roll = 0,
    })
end

--[[
Checks that bought Human critical-power ranks change real guaranteed-hit
damage on an actual tagged NPC, rather than merely changing UI metadata.

Args:
    player (Player): Disposable server-owned attacker identity.
    target (Model): Living tagged NPC used for hit resolution.

Returns:
    nil: Confirms full rank-two critical damage exceeds untrained damage.
]]
local function check_scout_critical_damage(player, target)
    local character = Schema.create_default(player.UserId)
        .Characters.Slot1
    character.Identity.RaceId = "Human"
    character.Identity.BaseClassId = "Rogue"
    character.Identity.ClassId = "Rogue"
    character.Identity.CreationStage = "Complete"
    character.Level = 32
    character.Equipment.Weapon = "scout_dagger"
    Runtime.set_character(player.UserId, character)
    local humanoid = assert(target:FindFirstChildOfClass("Humanoid"))
    humanoid.MaxHealth = 1000
    humanoid.Health = 1000

    local baseline = apply_scout_critical(player, target)
    character.Progression.Skills.HumanScoutCriticalPower = {
        Known = true, PurchasedRank = 2, Proficiency = 0,
    }
    Runtime.set_character(player.UserId, character)
    local trained = apply_scout_critical(player, target)
    assert(math.abs(trained - baseline - 3.2) < 0.01,
        "Two bought critical-power ranks must add 3.2 hit damage")
    print("[C4 Control Client] HUMAN_CRIT_REAL_DAMAGE_PASS")
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
    check_light_armor(player)
    check_scout_movement(player, dummy)
    check_scout_critical_damage(player, dummy)
    print("[C4 Control Client] ALL_SIXTEEN_C4_SKILL_EFFECTS_PASS")
end

task.spawn(function()
    local ok, reason = pcall(run)
    if not ok then
        warn("[C4 Control Client] FAIL " .. tostring(reason))
    end
    STS:EndTest(if ok then "PASS" else "FAIL " .. tostring(reason))
end)
task.delay(145, function()
    STS:EndTest("FAIL client skill global timeout")
end)
]==]
driver.Parent = SSS

local ok, result = pcall(function()
    return STS:ExecutePlayModeAsync("C4ControlClient_TEMP")
end)
driver:Destroy()
client:Destroy()
channel:Destroy()
assert(ok and result == "PASS",
    "C4 skill client test failed: " .. tostring(result))
print("[C4 Control Client] VERIFIED_PLAY_MODE_PASS")
