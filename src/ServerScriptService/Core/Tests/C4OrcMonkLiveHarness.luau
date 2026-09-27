--!strict
-- Unpublished Play rehearsal for Spiritclaw / Orc Monk level-30 combat.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Spiritclaw live rehearsal requires an unpublished local place"
)

print("[Spiritclaw Live] EDIT_START")

local ServerScriptService = game:GetService("ServerScriptService")
local StudioTestService = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local runtime_source = ServerScriptService.Dungeon.DungeonRuntime

--[[
Replaces one exact DungeonRuntime span in the disposable Studio place.

Args:
    original (string): Exact source text expected once.
    replacement (string): Test-only replacement source.

Returns:
    nil: Mutates only the unpublished Studio copy.
]]
local function replace_once(
    original: string,
    replacement: string
)
    local source = runtime_source.Source
    local first = assert(
        string.find(source, original, 1, true),
        "Spiritclaw live runtime anchor missing"
    )

    assert(
        not string.find(source, original, first + #original, true),
        "Spiritclaw live runtime anchor is ambiguous"
    )

    runtime_source.Source = source:sub(1, first - 1)
        .. replacement
        .. source:sub(first + #original)
end

local bridge_anchor = [==[
ProgressionService.bind_default(runtime.ProgressionService)
ProficiencyService.bind_default(runtime.ProficiencyService)
]==]

local bridge_replacement = [==[
ProgressionService.bind_default(runtime.ProgressionService)

if RunService:IsStudio()
    and game.PlaceId == 0
    and game.GameId == 0
then
    local ServerStorage = game:GetService("ServerStorage")
    local name = "C4SpiritclawLiveBridge_TEMP"
    local old = ServerStorage:FindFirstChild(name)

    if old then
        old:Destroy()
    end

    local bridge = Instance.new("BindableFunction")
    bridge.Name = name
    bridge.Parent = ServerStorage

    local function player_from_payload(payload)
        local user_id = type(payload) == "table"
            and payload.UserId or nil

        if type(user_id) ~= "number" then
            return nil
        end

        return Players:GetPlayerByUserId(user_id)
    end

    bridge.OnInvoke = function(action, payload)
        local cast_runtime = runtime.C4SourceCastRuntime

        if not cast_runtime then
            return {
                ok = false,
                reason = "C4SourceCastRuntimeUnavailable",
            }
        end

        if action == "enable_casts" then
            cast_runtime.PhysicalCast:set_enabled(true)
            cast_runtime.SelfEffect:set_enabled(true)
            cast_runtime.SourceToggle:set_enabled(true)
            return {
                ok = true,
                capability = cast_runtime:capability(),
            }
        end

        if action == "disable_casts" then
            cast_runtime.PhysicalCast:set_enabled(false)
            cast_runtime.SelfEffect:set_enabled(false)
            cast_runtime.SourceToggle:set_enabled(false)
            return {ok = true}
        end

        local player = player_from_payload(payload)
        if not player then
            return {
                ok = false,
                reason = "C4SpiritclawPlayerUnavailable",
            }
        end

        if action == "begin_physical" then
            local result, reason =
                cast_runtime.PhysicalCast:begin_cast(
                    player,
                    payload.Target,
                    payload.SkillId,
                    nil
                )
            return {
                ok = result ~= nil,
                reason = reason,
                result = result,
            }
        end

        if action == "launch_physical" then
            local result, reason =
                cast_runtime.PhysicalCast:launch_if_ready(
                    player,
                    payload.CastId,
                    nil,
                    payload.SequenceId
                )
            return {
                ok = result ~= nil,
                reason = reason,
                result = result,
            }
        end

        if action == "begin_self" then
            local result, reason =
                cast_runtime.SelfEffect:begin_cast(
                    player,
                    payload.SkillId,
                    nil
                )
            return {
                ok = result ~= nil,
                reason = reason,
                result = result,
            }
        end

        if action == "launch_self" then
            local result, reason =
                cast_runtime.SelfEffect:launch_if_ready(
                    player,
                    payload.CastId,
                    nil
                )
            return {
                ok = result ~= nil,
                reason = reason,
                result = result,
            }
        end

        if action == "toggle" then
            local result, reason =
                cast_runtime.SourceToggle:toggle(
                    player,
                    payload.SkillId
                )
            return {
                ok = result ~= nil,
                reason = reason,
                result = result,
            }
        end

        if action == "charge" then
            local result, reason =
                cast_runtime.Charges:get(player)
            return {
                ok = result ~= nil,
                reason = reason,
                result = result,
            }
        end

        if action == "clear_owner" then
            cast_runtime:clear_owner(player)
            return {ok = true}
        end

        return {
            ok = false,
            reason = "UnknownC4SpiritclawLiveAction",
        }
    end
end

ProficiencyService.bind_default(runtime.ProficiencyService)
]==]

replace_once(bridge_anchor, bridge_replacement)
print("[Spiritclaw Live] EDIT_PATCHED")

Workspace:SetAttribute("DungeonMMOStudioDungeonId", "TestDungeon")
Workspace:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
Workspace:SetAttribute("DungeonMMOStudioBaseClass", "Fighter")
Workspace:SetAttribute(
    "DungeonMMOPlaceholderPhysicalContentEnabled",
    true
)
Workspace:SetAttribute(
    "DungeonMMOPlaceholderPlayableEnabled",
    true
)

local driver = Instance.new("Script")
driver.Name = "C4SpiritclawLiveServer_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local StudioTestService = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Core.Shared
local ProfileSchema = require(Shared.ProfileSchema)
local QuestStages = require(
    Shared.C4OriginalFirstTransferQuestStages
)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local CUTOVER_BRIDGE = "C4CombatCutoverRehearsalBridge"
local LIVE_BRIDGE = "C4SpiritclawLiveBridge_TEMP"
local TEST_TIMEOUT = 120

--[[
Polls one live server condition with a bounded deadline.

Args:
    predicate (any): Callback returning the desired truthy value.
    label (string): Failure diagnostic.
    seconds (number): Maximum wait in seconds.

Returns:
    any: First truthy value returned by the predicate.
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

    error("[Spiritclaw Live] TIMEOUT " .. label)
end

--[[
Adds one known purchased skill to disposable progression state.

Args:
    character (any): Mutable profile-shaped character.
    skill_id (string): Creative skill identifier.
    rank (number): Purchased creative rank.

Returns:
    nil: Adds server-owned test progression state.
]]
local function own_skill(character, skill_id, rank)
    character.Progression.Skills[skill_id] = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = rank,
        Proficiency = 0,
    }
end

--[[
Adds all inherited Orc Fighter ranks needed by Spiritclaw.

Args:
    character (any): Mutable Spiritclaw character fixture.

Returns:
    nil: Adds exact inherited base skills through level 15.
]]
local function own_orc_fighter_skills(character)
    local skills = {
        {"OrcToughness", 1},
        {"OrcLucky", 1},
        {"OrcPowerStrike", 9},
        {"OrcIronPunch", 9},
        {"OrcWeaponTraining", 3},
        {"OrcArmorTraining", 5},
        {"OrcRelax", 1},
        {"OrcIronBody", 1},
    }

    for _, row in ipairs(skills) do
        own_skill(character, row[1], row[2])
    end
end

--[[
Adds every reviewed Spiritclaw family through level 30.

Args:
    character (any): Mutable Spiritclaw character fixture.

Returns:
    nil: Adds exact class-47 creative ranks used by the rehearsal.
]]
local function own_spiritclaw_skills(character)
    local skills = {
        {"SpiritclawIronFist", 9},
        {"SpiritclawForceFocus", 1},
        {"SpiritclawForceBurst", 6},
        {"SpiritclawBearAspect", 1},
        {"SpiritclawWolfAspect", 1},
        {"SpiritclawCripplingPalm", 3},
        {"SpiritclawStunningFist", 9},
        {"SpiritclawFistMastery", 4},
        {"SpiritclawLightArmorTraining", 6},
        {"SpiritclawAgileMovement", 1},
    }

    for _, row in ipairs(skills) do
        own_skill(character, row[1], row[2])
    end
end

--[[
Builds an authentic level-30 Spiritclaw first-transfer state.

Args:
    user_id (number): Actual connected Studio player ID.

Returns:
    any: Disposable Spiritclaw progression state.
]]
local function spiritclaw_character(user_id)
    local character =
        ProfileSchema.create_default(user_id).Characters.Slot1
    local quest = assert(QuestStages.get("OrcMonk"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "Orc",
        BaseClassId = "Fighter",
        ClassId = "Spiritclaw",
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
        OriginalFirstTransferChoiceId = "OrcMonk",
        OriginalFirstTransferClassId = "Spiritclaw",
        OriginalFirstTransferReceiptId = "TEMP_SpiritclawLive",
        OriginalFirstTransferQuest = {
            QuestId = quest.Id,
            BranchId = quest.BranchId,
            Step = #quest.Steps + 1,
            Count = 0,
            Ready = true,
            AppliedEvents = {},
            Proofs = proofs,
        },
    }
    character.Equipment.Weapon = "orc_training_fist"
    character.Equipment.Body = "ironroot_light_vest"

    own_orc_fighter_skills(character)
    own_spiritclaw_skills(character)
    return character
end

--[[
Returns the admitted Play client with a living character.

Args:
    None.

Returns:
    Player: Connected and combat-enabled Studio player.
]]
local function admitted_player()
    local player =
        Players:GetPlayers()[1]
        or Players.PlayerAdded:Wait()

    wait_for(function()
        local character = player.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")
        local root = character
            and character:FindFirstChild("HumanoidRootPart")

        return player:GetAttribute("DungeonCombatAllowed") == true
            and humanoid
            and humanoid.Health > 0
            and root
    end, "admitted player", 45)

    return player
end

--[[
Creates one disposable reviewed Marauder target.

Args:
    player (Player): Actual Play client.
    name (string): Unique target name.
    offset (Vector3): Position relative to the player.

Returns:
    Model: Live reviewed NPC target.
]]
local function rehearsal_enemy(player, name, offset)
    local player_root = assert(player.Character.HumanoidRootPart)
    local enemy = Instance.new("Model")
    enemy.Name = name
    enemy:SetAttribute("DungeonEnemyArchetypeId", "Marauder")
    enemy:SetAttribute("DungeonEncounterId", "TEMP_Spiritclaw")

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Anchored = true
    root.CanCollide = false
    root.CFrame = player_root.CFrame * CFrame.new(offset)
    root.Parent = enemy

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 7000
    humanoid.Health = 7000
    humanoid.Parent = enemy

    enemy.PrimaryPart = root
    enemy.Parent = Workspace
    return enemy
end

--[[
Faces the actual player toward one rehearsal target.

Args:
    player (Player): Actual source attacker.
    enemy (Model): Reviewed NPC target.

Returns:
    nil: Moves only the disposable Play character.
]]
local function face_enemy(player, enemy)
    local root = player.Character.HumanoidRootPart
    local position = enemy.PrimaryPart.Position

    root.CFrame = CFrame.lookAt(
        position + Vector3.new(0, 0, 6),
        position
    )
    root.AssemblyLinearVelocity = Vector3.zero
end

--[[
Waits just beyond one absolute source launch deadline.

Args:
    launch_at (number): Server os.clock launch deadline.

Returns:
    nil: Returns when source effect execution is ready.
]]
local function wait_for_launch(launch_at)
    while os.clock() < launch_at + 0.03 do
        task.wait(0.02)
    end
end

--[[
Returns the current live source charge count.

Args:
    bridge (BindableFunction): Spiritclaw live bridge.
    player (Player): Actual charge owner.

Returns:
    number: Current server-owned C4 charge count.
]]
local function charge_count(bridge, player)
    local result = bridge:Invoke("charge", {
        UserId = player.UserId,
    })
    assert(result.ok, tostring(result.reason))
    return result.result
end

--[[
Casts one reviewed physical family through the live bridge.

Args:
    bridge (BindableFunction): Live Spiritclaw bridge.
    player (Player): Actual source attacker.
    enemy (Model): Reviewed NPC target.
    skill_id (string): Creative physical skill.
    source_skill_id (number): Expected C4 source skill.
    source_rank (number): Expected source rank.
    cast_range (number): Exact source cast range.
    effect_range (number): Exact source effect range.
    sequence_id (number): Trusted combat sequence.

Returns:
    any: Live physical application evidence.
]]
local function cast_physical(
    bridge,
    player,
    enemy,
    skill_id,
    source_skill_id,
    source_rank,
    cast_range,
    effect_range,
    sequence_id
)
    face_enemy(player, enemy)

    local started = bridge:Invoke("begin_physical", {
        UserId = player.UserId,
        Target = enemy,
        SkillId = skill_id,
    })
    assert(started.ok, tostring(started.reason))

    local plan = started.result
    assert(
        plan.SourceSkillId == source_skill_id
            and plan.SourceRank == source_rank
            and plan.SourceCastRange == cast_range
            and plan.SourceEffectRange == effect_range,
        skill_id .. " source contract drifted"
    )

    wait_for_launch(plan.LaunchAt)

    local launched = bridge:Invoke("launch_physical", {
        UserId = player.UserId,
        CastId = plan.CastId,
        SequenceId = sequence_id,
    })
    assert(launched.ok, tostring(launched.reason))
    assert(
        launched.result.Kind == "C4ScheduledPhysicalCast"
            and launched.result.Application ~= nil,
        skill_id .. " did not reach live physical authority"
    )

    return launched.result.Application
end

--[[
Casts one scheduled Spiritclaw self effect.

Args:
    bridge (BindableFunction): Live Spiritclaw bridge.
    player (Player): Actual Spiritclaw.
    skill_id (string): Reviewed self-effect skill.
    source_skill_id (number): Expected source skill.

Returns:
    any: Applied live self-effect result.
]]
local function cast_self_effect(
    bridge,
    player,
    skill_id,
    source_skill_id
)
    local started = bridge:Invoke("begin_self", {
        UserId = player.UserId,
        SkillId = skill_id,
    })
    assert(started.ok, tostring(started.reason))
    assert(
        started.result.SourceSkillId == source_skill_id,
        skill_id .. " source identity drifted"
    )

    wait_for_launch(started.result.LaunchAt)
    local launched = bridge:Invoke("launch_self", {
        UserId = player.UserId,
        CastId = started.result.CastId,
    })
    assert(launched.ok, tostring(launched.reason))
    return launched.result.Application
end

--[[
Exercises inherited and Spiritclaw close-range physical skills.

Args:
    bridge (BindableFunction): Live Spiritclaw bridge.
    player (Player): Actual Spiritclaw.
    enemy (Model): Reviewed NPC target.

Returns:
    nil: Confirms inherited fist, class fist, stun and physical slow routes.
]]
local function rehearse_physical_skills(bridge, player, enemy)
    local inherited = cast_physical(
        bridge,
        player,
        enemy,
        "OrcIronPunch",
        29,
        9,
        40,
        400,
        6201
    )
    assert(
        inherited.Kind == "C4LiveNpcPhysicalSkill",
        "inherited Orc Iron Punch left the live physical route"
    )

    local iron_fist = cast_physical(
        bridge,
        player,
        enemy,
        "SpiritclawIronFist",
        29,
        18,
        40,
        400,
        6202
    )
    assert(
        iron_fist.Kind == "C4LiveNpcPhysicalSkill",
        "Spiritclaw Iron Fist left the live physical route"
    )

    local stun = cast_physical(
        bridge,
        player,
        enemy,
        "SpiritclawStunningFist",
        120,
        9,
        40,
        400,
        6203
    )
    local stun_roll = assert(
        stun.Stun,
        "Stunning Fist did not resolve its source stun roll"
    )
    assert(
        stun.Kind == "C4LiveNpcPhysicalStunSkill"
            and stun_roll.DurationSeconds == 9
            and type(stun_roll.Rate) == "number"
            and type(stun_roll.Roll) == "number"
            and stun_roll.Landed
                == (stun_roll.Roll < stun_roll.Rate),
        "Stunning Fist left the live stun authority"
    )

    if stun_roll.Landed then
        assert(
            stun.StunApplied
                and stun.Landed
                and stun.DurationSeconds == 9,
            "landed Stunning Fist did not apply its 9-second stun"
        )
    else
        assert(
            not stun.StunApplied
                and stun.Landed == false
                and stun.DurationSeconds == nil,
            "resisted Stunning Fist incorrectly applied stun state"
        )
    end

    local cripple = cast_physical(
        bridge,
        player,
        enemy,
        "SpiritclawCripplingPalm",
        95,
        3,
        40,
        400,
        6204
    )
    assert(
        cripple.Kind == "C4LiveNpcPhysicalMovementSlow"
            and type(cripple.SlowLanded) == "boolean"
            and cripple.SpeedMultiplier == 0.7
            and cripple.DurationSeconds == 120,
        "Crippling Palm left the live physical-slow authority"
    )

    if cripple.SlowLanded then
        assert(
            cripple.SlowApplied,
            "landed Crippling Palm did not apply movement slow"
        )
    else
        assert(
            not cripple.SlowApplied,
            "resisted Crippling Palm incorrectly applied movement slow"
        )
    end

    print(
        "[Spiritclaw Live] PHYSICAL_PASS "
            .. "inherited_fist_stun_cripple=true"
    )
end

--[[
Exercises exact Focus Force to Force Burst charge flow.

Args:
    bridge (BindableFunction): Live Spiritclaw bridge.
    player (Player): Actual Spiritclaw.
    enemy (Model): Reviewed NPC target.

Returns:
    nil: Confirms pre-cast rejection, charge creation and exact spend.
]]
local function rehearse_force_chain(bridge, player, enemy)
    assert(
        charge_count(bridge, player) == 0,
        "Spiritclaw live charge state did not start at zero"
    )

    face_enemy(player, enemy)
    local blocked = bridge:Invoke("begin_physical", {
        UserId = player.UserId,
        Target = enemy,
        SkillId = "SpiritclawForceBurst",
    })
    assert(
        not blocked.ok
            and blocked.reason == "C4SourceChargeInsufficient"
            and charge_count(bridge, player) == 0,
        "Force Burst did not fail before cast spend without a charge"
    )

    local focus = cast_self_effect(
        bridge,
        player,
        "SpiritclawForceFocus",
        50
    )
    assert(
        focus.Kind == "C4SourceCharge"
            and focus.ChargeBefore == 0
            and focus.ChargeAfter == 1
            and focus.MaximumCharges == 1
            and charge_count(bridge, player) == 1,
        "Focus Force did not create exactly one source charge"
    )

    -- Focus Force has an exact 1000 ms C4 reuse. The second cast tests
    -- maxCharges behavior, so it must not intentionally collide with reuse.
    task.wait(1.1)

    local capped = cast_self_effect(
        bridge,
        player,
        "SpiritclawForceFocus",
        50
    )
    assert(
        capped.ChargeBefore == 1
            and capped.ChargeAfter == 1
            and not capped.Added
            and charge_count(bridge, player) == 1,
        "Focus Force exceeded source maxCharges one"
    )

    local burst = cast_physical(
        bridge,
        player,
        enemy,
        "SpiritclawForceBurst",
        54,
        6,
        600,
        1100,
        6210
    )
    assert(
        burst.Kind == "C4LiveNpcChargedPhysicalSkill"
            and burst.RequiredCharges == 1
            and burst.RemainingCharges == 0
            and burst.SourceChargeDamageMultiplier == 0.8
            and burst.HealthDamage > 0
            and charge_count(bridge, player) == 0,
        "Force Burst did not consume one charge into exact 0.8 damage"
    )

    print(
        "[Spiritclaw Live] FORCE_PASS "
            .. "gate_focus_cap_burst=true"
    )
end

--[[
Exercises Bear and Wolf aspects one at a time in authoritative source state.

Args:
    bridge (BindableFunction): Live Spiritclaw bridge.
    player (Player): Actual Spiritclaw.

Returns:
    nil: Confirms both possession buffs reach live active-source state.
]]
local function rehearse_aspects(bridge, player)
    local bear = cast_self_effect(
        bridge,
        player,
        "SpiritclawBearAspect",
        76
    )
    assert(
        bear.Kind == "C4SourceTimedSelfBuff"
            and bear.Applied
            and bear.DurationSeconds == 120,
        "Bear Aspect did not preserve its exact source duration"
    )

    local bear_boundary = assert(
        Runtime.get_c4_resource_migration_boundary(player.UserId)
    )
    assert(
        bear_boundary.ActiveEffectsIntegrated
            and #bear_boundary.ReviewedActiveSourceRanks == 1
            and bear_boundary.ReviewedActiveSourceRanks[1].SkillId == 76,
        "Bear Aspect did not enter authoritative source state"
    )

    local cleared = bridge:Invoke("clear_owner", {
        UserId = player.UserId,
    })
    assert(cleared.ok, tostring(cleared.reason))

    local wolf = cast_self_effect(
        bridge,
        player,
        "SpiritclawWolfAspect",
        83
    )
    assert(
        wolf.Kind == "C4SourceTimedSelfBuff"
            and wolf.Applied
            and wolf.DurationSeconds == 120,
        "Wolf Aspect did not preserve its exact source duration"
    )

    local wolf_boundary = assert(
        Runtime.get_c4_resource_migration_boundary(player.UserId)
    )
    assert(
        wolf_boundary.ActiveEffectsIntegrated
            and #wolf_boundary.ReviewedActiveSourceRanks == 1
            and wolf_boundary.ReviewedActiveSourceRanks[1].SkillId == 83,
        "Wolf Aspect did not enter authoritative source state"
    )

    print(
        "[Spiritclaw Live] ASPECT_PASS bear_wolf=true"
    )
end

--[[
Exercises inherited Orc Relax through the live source toggle authority.

Args:
    bridge (BindableFunction): Live Spiritclaw bridge.
    player (Player): Actual Spiritclaw.

Returns:
    nil: Confirms inherited toggle activation and rollback.
]]
local function rehearse_relax(bridge, player)
    local humanoid =
        assert(player.Character:FindFirstChildOfClass("Humanoid"))
    humanoid.Sit = false
    humanoid.Health = math.max(1, humanoid.MaxHealth - 100)

    local enabled = bridge:Invoke("toggle", {
        UserId = player.UserId,
        SkillId = "OrcRelax",
    })
    assert(enabled.ok, tostring(enabled.reason))
    assert(
        enabled.result.Active
            and enabled.result.SourceSkillId == 226
            and enabled.result.SourceRank == 1
            and enabled.result.UpkeepKind == "Relax"
            and humanoid.Sit,
        "inherited Orc Relax did not activate live"
    )

    local disabled = bridge:Invoke("toggle", {
        UserId = player.UserId,
        SkillId = "OrcRelax",
    })
    assert(disabled.ok, tostring(disabled.reason))
    assert(
        disabled.result.Active == false,
        "inherited Orc Relax did not deactivate"
    )

    print("[Spiritclaw Live] RELAX_PASS inherited=true")
end

--[[
Runs the unpublished Spiritclaw Play rehearsal.

Args:
    None.

Returns:
    nil: Ends only after combat, force, aspects, Relax and rollback pass.
]]
local function run()
    print("[Spiritclaw Live] RUN_START")

    local player = admitted_player()
    local character = spiritclaw_character(player.UserId)
    local enemy = rehearsal_enemy(
        player,
        "TEMP_SpiritclawMarauder",
        Vector3.new(0, 0, -6)
    )

    Runtime.set_character(player.UserId, character)

    local boundary, reason =
        Runtime.get_c4_resource_migration_boundary(player.UserId)
    assert(
        boundary
            and reason == nil
            and boundary.ScopeId == "OrcMonk"
            and boundary.SourceBaseMaxHealth == 1230
            and boundary.SourceBaseMaxMana == 327
            and boundary.SourceBaseMaxCP == 617
            and boundary.CutoverPrerequisitesReady,
        "Spiritclaw source boundary is not live-rehearsal ready"
    )

    local cutover =
        ServerStorage:WaitForChild(CUTOVER_BRIDGE, 20)
    local bridge =
        ServerStorage:WaitForChild(LIVE_BRIDGE, 20)

    local enabled = cutover:Invoke("enable", {
        UserIds = {player.UserId},
        SourceUnitsPerStud = 1,
        IsNight = false,
    })
    assert(
        enabled.ok
            and enabled.snapshot.Enabled
            and enabled.snapshot.ActivePlayerCount == 1,
        "Spiritclaw source cutover failed"
    )

    local cast_enabled = bridge:Invoke("enable_casts")
    assert(
        cast_enabled.ok
            and cast_enabled.capability.PhysicalCastCurrentlyEnabled
            and cast_enabled.capability.SelfEffectCurrentlyEnabled
            and cast_enabled.capability.SourceToggleCurrentlyEnabled
            and cast_enabled.capability.SourceChargeAuthority,
        "Spiritclaw source bridges did not enable"
    )

    rehearse_physical_skills(bridge, player, enemy)
    rehearse_force_chain(bridge, player, enemy)
    rehearse_aspects(bridge, player)
    rehearse_relax(bridge, player)

    bridge:Invoke("disable_casts")
    local disabled = cutover:Invoke("disable")
    assert(
        disabled.ok and not disabled.snapshot.Enabled,
        "Spiritclaw source cutover rollback failed"
    )

    bridge:Invoke("clear_owner", {
        UserId = player.UserId,
    })
    Runtime.clear_character(player.UserId)

    if enemy.Parent then
        enemy:Destroy()
    end

    print(
        "[Spiritclaw Live] "
            .. "PHYSICAL_FORCE_ASPECT_RELAX_ROLLBACK_PASS"
    )
end

task.spawn(function()
    local ok, reason = pcall(run)

    local cutover =
        ServerStorage:FindFirstChild(CUTOVER_BRIDGE)
    if cutover and cutover:IsA("BindableFunction") then
        pcall(function()
            cutover:Invoke("disable")
        end)
    end

    local bridge =
        ServerStorage:FindFirstChild(LIVE_BRIDGE)
    if bridge and bridge:IsA("BindableFunction") then
        pcall(function()
            bridge:Invoke("disable_casts")
        end)
    end

    if not ok then
        warn("[Spiritclaw Live] FAIL " .. tostring(reason))
    end

    StudioTestService:EndTest(
        if ok then "PASS" else "FAIL " .. tostring(reason)
    )
end)

task.delay(TEST_TIMEOUT, function()
    StudioTestService:EndTest(
        "FAIL Spiritclaw live global timeout"
    )
end)
]==]

driver.Parent = ServerScriptService

--[[
Disables edit-only layout regressions that author duplicate synthetic content.

Args:
    None.

Returns:
    nil: Disables only disposable unpublished Studio copies.
]]
local function disable_conflicting_regressions()
    local tests = ServerScriptService.Dungeon:FindFirstChild("Tests")
    assert(tests, "Spiritclaw live Dungeon tests folder missing")

    for _, name in ipairs({
        "DungeonOptionalDepthPhysicalLayoutTest",
        "DungeonLateEventPhysicalLayoutTest",
    }) do
        local script_instance = tests:FindFirstChild(name)
        assert(
            script_instance and script_instance:IsA("Script"),
            "Spiritclaw regression script missing: " .. name
        )
        script_instance.Disabled = true
    end
end

disable_conflicting_regressions()

local ok, result = pcall(function()
    return StudioTestService:ExecutePlayModeAsync(
        "TEMP_C4SpiritclawLive"
    )
end)

driver:Destroy()

assert(
    ok and result == "PASS",
    "Spiritclaw live rehearsal failed: " .. tostring(result)
)

print("[Spiritclaw Live] VERIFIED_PLAY_MODE_PASS")

return true
