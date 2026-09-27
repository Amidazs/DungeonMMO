--!strict
-- Unpublished Play rehearsal for Nightweaver / Dark Wizard level-30 combat.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Nightweaver live rehearsal requires an unpublished local place"
)

print("[Nightweaver Live] EDIT_START")

local ServerScriptService = game:GetService("ServerScriptService")
local StudioTestService = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local runtime_source =
    ServerScriptService.Dungeon.DungeonRuntime

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
        "Nightweaver live runtime anchor missing"
    )

    assert(
        not string.find(source, original, first + #original, true),
        "Nightweaver live runtime anchor is ambiguous"
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
    local name = "C4NightweaverLiveBridge_TEMP"
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
            cast_runtime.DirectMagic:set_enabled(true)
            cast_runtime.SupportMagic:set_enabled(true)
            return {
                ok = true,
                capability = cast_runtime:capability(),
            }
        end

        if action == "disable_casts" then
            cast_runtime.DirectMagic:set_enabled(false)
            cast_runtime.SupportMagic:set_enabled(false)
            return {ok = true}
        end

        local player = player_from_payload(payload)
        if not player then
            return {
                ok = false,
                reason = "C4NightweaverPlayerUnavailable",
            }
        end

        if action == "add_item" then
            return runtime.InventoryService:add_item(
                player.UserId,
                payload.ItemId,
                payload.Quantity
            )
        end

        if action == "charge" then
            return cast_runtime.SourceShots:charge(
                player.UserId,
                payload.ShotKind
            )
        end

        if action == "shot_snapshot" then
            return {
                ok = true,
                snapshot = cast_runtime.SourceShots:snapshot(
                    player.UserId
                ),
            }
        end

        if action == "scheduler_snapshot" then
            return {
                ok = true,
                snapshot = cast_runtime.Scheduler:snapshot(player),
            }
        end

        if action == "set_interrupt_roll" then
            local roll = payload.Roll
            if roll == nil then
                cast_runtime.Interruption:set_roll_provider_for_test(nil)
            else
                assert(
                    type(roll) == "number"
                        and roll % 1 == 0
                        and roll >= 0
                        and roll <= 99
                )
                cast_runtime.Interruption:set_roll_provider_for_test(
                    function()
                        return roll
                    end
                )
            end
            return {ok = true}
        end

        if action == "begin_direct" then
            local result, reason =
                cast_runtime.DirectMagic:begin_cast(
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

        if action == "launch_direct" then
            local result, reason =
                cast_runtime.DirectMagic:launch_if_ready(
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

        if action == "begin_support" then
            local result, reason =
                cast_runtime.SupportMagic:begin_cast(
                    player,
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

        if action == "launch_support" then
            local result, reason =
                cast_runtime.SupportMagic:launch_if_ready(
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

        if action == "clear_owner" then
            cast_runtime.Interruption:set_roll_provider_for_test(nil)
            cast_runtime:clear_owner(player)
            return {ok = true}
        end

        return {
            ok = false,
            reason = "UnknownC4NightweaverLiveAction",
        }
    end
end

ProficiencyService.bind_default(runtime.ProficiencyService)
]==]

replace_once(bridge_anchor, bridge_replacement)
print("[Nightweaver Live] EDIT_PATCHED")

Workspace:SetAttribute(
    "DungeonMMOStudioDungeonId",
    "TestDungeon"
)
Workspace:SetAttribute(
    "DungeonMMOEnvironmentMode",
    "Synthetic"
)
Workspace:SetAttribute(
    "DungeonMMOStudioBaseClass",
    "Mage"
)
Workspace:SetAttribute(
    "DungeonMMOPlaceholderPhysicalContentEnabled",
    true
)
Workspace:SetAttribute(
    "DungeonMMOPlaceholderPlayableEnabled",
    true
)

local driver = Instance.new("Script")
driver.Name = "C4NightweaverLiveServer_TEMP"
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
local DamageService = require(
    ServerScriptService.Combat.DamageService
)
local Threat = require(
    ServerScriptService.Combat.ThreatService
)

local CUTOVER_BRIDGE = "C4CombatCutoverRehearsalBridge"
local LIVE_BRIDGE = "C4NightweaverLiveBridge_TEMP"
local TEST_TIMEOUT = 110

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

    error("[Nightweaver Live] TIMEOUT " .. label)
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
Adds the reviewed level-30 Nightweaver passive families.

Args:
    character (any): Mutable Nightweaver character fixture.

Returns:
    nil: Adds all eight genuine passive creative ranks.
]]
local function own_nightweaver_passives(character)
    local skills = {
        {"NightweaverArcaneResistance", 6},
        {"NightweaverQuickWeave", 2},
        {"NightweaverManaReservoir", 2},
        {"NightweaverRobeTraining", 6},
        {"NightweaverFocusTraining", 5},
        {"NightweaverManaChanneling", 6},
        {"NightweaverFastCasting", 1},
        {"NightweaverManaRecovery", 1},
    }

    for _, row in ipairs(skills) do
        own_skill(character, row[1], row[2])
    end
end

--[[
Builds an authentic level-30 Nightweaver first-transfer state.

Args:
    user_id (number): Actual connected Studio player ID.

Returns:
    any: Disposable Nightweaver progression state.
]]
local function nightweaver_character(user_id)
    local character =
        ProfileSchema.create_default(user_id).Characters.Slot1
    local quest = assert(QuestStages.get("DarkWizard"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "DarkElf",
        BaseClassId = "Mage",
        ClassId = "Nightweaver",
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
        OriginalFirstTransferChoiceId = "DarkWizard",
        OriginalFirstTransferClassId = "Nightweaver",
        OriginalFirstTransferReceiptId = "TEMP_NightweaverLive",
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
    character.Equipment.Weapon = "apprentice_arcane_wand"

    own_nightweaver_passives(character)
    own_skill(character, "NightweaverGaleBolt", 6)
    own_skill(character, "NightweaverShadowSpark", 2)
    own_skill(character, "NightweaverConcentration", 2)
    own_skill(character, "NightweaverVenomRend", 2)

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

Returns:
    Model: Live reviewed NPC target.
]]
local function rehearsal_enemy(player)
    local player_root =
        assert(player.Character.HumanoidRootPart)
    local enemy = Instance.new("Model")
    enemy.Name = "TEMP_NightweaverMarauder"
    enemy:SetAttribute("DungeonEnemyArchetypeId", "Marauder")
    enemy:SetAttribute("DungeonEncounterId", "TEMP_Nightweaver")

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Anchored = true
    root.CanCollide = false
    root.CFrame = player_root.CFrame * CFrame.new(0, 0, -6)
    root.Parent = enemy

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 5000
    humanoid.Health = 5000
    humanoid.Parent = enemy

    enemy.PrimaryPart = root
    enemy.Parent = Workspace
    return enemy
end

--[[
Faces the actual player toward one rehearsal target.

Args:
    player (Player): Actual source caster.
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
Charges one real inventory-backed Spiritshot.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual source caster.

Returns:
    nil: Confirms one charge exists.
]]
local function charge_spiritshot(bridge, player)
    local charged = bridge:Invoke("charge", {
        UserId = player.UserId,
        ShotKind = "Spiritshot",
    })
    assert(charged.ok, tostring(charged.reason))
end

--[[
Returns the current real source scheduler snapshot.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual source caster.

Returns:
    any: Detached scheduler state.
]]
local function scheduler_snapshot(bridge, player)
    local result = bridge:Invoke("scheduler_snapshot", {
        UserId = player.UserId,
    })
    assert(result.ok, tostring(result.reason))
    return result.snapshot
end

--[[
Applies one trusted EnemyMagic hit to the actual player.

Args:
    player (Player): Real source participant.
    amount (number): Legacy damage amount before trusted mitigation.

Returns:
    number: Real HP damage returned by DamageService.
]]
local function apply_enemy_magic_damage(player, amount)
    return DamageService.apply_damage({
        attacker = nil,
        attacker_character = nil,
        target = player.Character,
        source_kind = "EnemyMagic",
        source_id = "TEMP_NightweaverInterruptHit",
        attack_id = "TEMP_NightweaverInterruptHit",
        base_damage = amount,
        multiplier = 1,
    })
end

--[[
Begins exact rank-six Gale Bolt before Concentration is active.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual Nightweaver.
    enemy (Model): Reviewed NPC target.

Returns:
    any: Pending direct-cast plan.
]]
local function begin_gale_bolt(bridge, player, enemy)
    face_enemy(player, enemy)
    local started = bridge:Invoke("begin_direct", {
        UserId = player.UserId,
        Target = enemy,
        SkillId = "NightweaverGaleBolt",
    })
    assert(started.ok, tostring(started.reason))

    local plan = started.result
    assert(
        plan.SourceSkillId == 1178
            and plan.SourceRank == 6
            and plan.SourceCastRange == 750
            and plan.SourceEffectRange == 1250,
        "Gale Bolt source contract drifted"
    )
    return plan
end

--[[
Proves ordinary damage can interrupt a pending unprotected source cast.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual Nightweaver.
    enemy (Model): Reviewed NPC target.

Returns:
    nil: Confirms deterministic source interruption through DamageService.
]]
local function rehearse_unprotected_interrupt(
    bridge,
    player,
    enemy
)
    local plan = begin_gale_bolt(bridge, player, enemy)
    assert(scheduler_snapshot(bridge, player).Pending)

    assert(bridge:Invoke("set_interrupt_roll", {
        UserId = player.UserId,
        Roll = 5,
    }).ok)

    local damage = apply_enemy_magic_damage(player, 200)
    local after = scheduler_snapshot(bridge, player)
    bridge:Invoke("set_interrupt_roll", {
        UserId = player.UserId,
        Roll = nil,
    })

    assert(
        damage > 0
            and not after.Pending
            and after.CastId == nil,
        "unprotected Gale Bolt was not interrupted by trusted damage"
    )
    print(
        "[Nightweaver Live] INTERRUPT_PASS damage="
            .. tostring(damage)
            .. " cast="
            .. tostring(plan.CastId)
    )
end

--[[
Casts exact rank-two Concentration on the real Nightweaver.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual Nightweaver.

Returns:
    nil: Confirms timed effect and exact active source-stat offset.
]]
local function cast_concentration(bridge, player)
    charge_spiritshot(bridge, player)
    local started = bridge:Invoke("begin_support", {
        UserId = player.UserId,
        SkillId = "NightweaverConcentration",
    })
    assert(started.ok, tostring(started.reason))
    local plan = started.result

    assert(
        plan.SourceSkillId == 1078
            and plan.SourceRank == 2
            and plan.SourceCastRange == 400
            and plan.SourceEffectRange == 900,
        "Concentration source contract drifted"
    )

    wait_for_launch(plan.LaunchAt)
    local launched = bridge:Invoke("launch_support", {
        UserId = player.UserId,
        CastId = plan.CastId,
    })
    assert(launched.ok, tostring(launched.reason))

    local application = launched.result.Application
    local boundary = assert(
        Runtime.get_c4_resource_migration_boundary(
            player.UserId
        )
    )
    assert(
        application.Applied
            and application.Kind == "C4LiveSupportBuff"
            and application.SourceSkillId == 1078
            and application.SourceRank == 2
            and application.DurationSeconds == 1200
            and boundary.SourceMenBonus == 1.45
            and boundary.SourceStatCandidate.ATTACK_CANCEL_RATE == -25,
        "Concentration did not reach active source interruption state"
    )

    print("[Nightweaver Live] CONCENTRATION_PASS offset=-25")
end

--[[
Begins exact rank-two Shadow Spark with a charged Spiritshot.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual Nightweaver.
    enemy (Model): Reviewed NPC target.

Returns:
    any: Pending Shadow Spark plan.
]]
local function begin_shadow_spark(bridge, player, enemy)
    face_enemy(player, enemy)
    charge_spiritshot(bridge, player)

    local started = bridge:Invoke("begin_direct", {
        UserId = player.UserId,
        Target = enemy,
        SkillId = "NightweaverShadowSpark",
    })
    assert(started.ok, tostring(started.reason))
    local plan = started.result

    assert(
        plan.SourceSkillId == 1266
            and plan.SourceRank == 2
            and plan.SourceCastRange == 750
            and plan.SourceEffectRange == 1250,
        "Shadow Spark source contract drifted"
    )
    return plan
end

--[[
Proves Concentration protects a pending cast and that the cast still launches.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual Nightweaver.
    enemy (Model): Reviewed NPC target.

Returns:
    number: Real NPC HP damage from the surviving Shadow Spark.
]]
local function rehearse_protected_shadow_spark(
    bridge,
    player,
    enemy
)
    local plan = begin_shadow_spark(bridge, player, enemy)
    local humanoid =
        assert(enemy:FindFirstChildOfClass("Humanoid"))
    local before = humanoid.Health

    assert(bridge:Invoke("set_interrupt_roll", {
        UserId = player.UserId,
        Roll = 5,
    }).ok)
    local incoming = apply_enemy_magic_damage(player, 200)
    local pending = scheduler_snapshot(bridge, player)
    bridge:Invoke("set_interrupt_roll", {
        UserId = player.UserId,
        Roll = nil,
    })

    assert(
        incoming > 0
            and pending.Pending
            and pending.CastId == plan.CastId,
        "Concentration did not preserve the protected source cast"
    )

    wait_for_launch(plan.LaunchAt)
    local launched = bridge:Invoke("launch_direct", {
        UserId = player.UserId,
        CastId = plan.CastId,
        SequenceId = 4902,
    })
    assert(launched.ok, tostring(launched.reason))

    local application = launched.result.Application
    local calculation = application.Calculation
    assert(
        application.Applied
            and application.HealthDamage > 0
            and humanoid.Health < before
            and calculation.SourceSkillId == 1266
            and calculation.SourceRank == 2
            and calculation.SourceElement == "DARK"
            and calculation.Spiritshot,
        "protected Shadow Spark did not execute exact DARK source damage"
    )

    print(
        "[Nightweaver Live] PROTECTED_CAST_PASS damage="
            .. tostring(application.HealthDamage)
    )
    return application.HealthDamage
end

--[[
Casts Venom Rend through the real poison-vulnerability executor.

The source land roll remains genuinely server-random. Both landed and resisted
outcomes must retain exact source identity, MEN semantics and one-shot use.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual Nightweaver.
    enemy (Model): Reviewed NPC target.

Returns:
    nil: Confirms live poison-vulnerability routing and state when landed.
]]
local function cast_venom_rend(bridge, player, enemy)
    charge_spiritshot(bridge, player)
    local started = bridge:Invoke("begin_direct", {
        UserId = player.UserId,
        Target = enemy,
        SkillId = "NightweaverVenomRend",
    })
    assert(started.ok, tostring(started.reason))
    local plan = started.result

    assert(
        plan.SourceSkillId == 1224
            and plan.SourceRank == 2
            and plan.SourceCastRange == 750
            and plan.SourceEffectRange == 1250,
        "Venom Rend source contract drifted"
    )

    wait_for_launch(plan.LaunchAt)
    local launched = bridge:Invoke("launch_direct", {
        UserId = player.UserId,
        CastId = plan.CastId,
        SequenceId = 4903,
    })
    assert(launched.ok, tostring(launched.reason))

    local application = launched.result.Application
    local calculation = application.Calculation
    assert(
        calculation.SourceSkillId == 1224
            and calculation.SourceRank == 2
            and calculation.SaveVs == "MEN"
            and calculation.VulnerabilityStat == "POISON_VULN"
            and calculation.VulnerabilityMultiplier == 1.25
            and calculation.DurationSeconds == 15
            and calculation.Spiritshot,
        "Venom Rend live calculation drifted from exact source contract"
    )

    if calculation.Landed then
        assert(
            application.VulnerabilityApplied
                and enemy:GetAttribute(
                    "C4POISON_VULNMultiplier"
                ) == 1.25,
            "landed Venom Rend did not mutate live poison vulnerability"
        )
    else
        assert(
            not application.VulnerabilityApplied,
            "resisted Venom Rend unexpectedly mutated vulnerability"
        )
    end

    print(
        "[Nightweaver Live] VENOM_REND_PASS landed="
            .. tostring(calculation.Landed)
    )
end

--[[
Runs the complete unpublished Nightweaver Play rehearsal.

Args:
    None.

Returns:
    nil: Ends after cutover, interruption, buff, damage, Venom Rend and rollback.
]]
local function run()
    print("[Nightweaver Live] RUN_START")
    local player = admitted_player()
    local enemy = rehearsal_enemy(player)
    face_enemy(player, enemy)

    Runtime.set_character(
        player.UserId,
        nightweaver_character(player.UserId)
    )

    local boundary, reason =
        Runtime.get_c4_resource_migration_boundary(
            player.UserId
        )
    assert(
        boundary
            and reason == nil
            and boundary.ScopeId == "DarkWizard"
            and boundary.SourceBaseMaxHealth == 672
            and boundary.SourceBaseMaxMana == 482
            and boundary.SourceBaseMaxCP == 338
            and boundary.SourceStatCandidate.ATTACK_CANCEL_RATE == 0
            and boundary.CutoverPrerequisitesReady,
        "Nightweaver source boundary is not live-rehearsal ready"
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
        "Nightweaver source cutover failed"
    )

    local cast_enabled = bridge:Invoke("enable_casts")
    assert(
        cast_enabled.ok
            and cast_enabled.capability.DirectMagicCurrentlyEnabled
            and cast_enabled.capability.SupportMagicCurrentlyEnabled
            and cast_enabled.capability.SourceCastInterruption,
        "Nightweaver cast bridges did not enable"
    )

    assert(bridge:Invoke("add_item", {
        UserId = player.UserId,
        ItemId = "mystic_charge",
        Quantity = 8,
    }).ok)

    rehearse_unprotected_interrupt(bridge, player, enemy)
    cast_concentration(bridge, player)

    local damage = rehearse_protected_shadow_spark(
        bridge,
        player,
        enemy
    )
    assert(
        Threat.get_threat(enemy, player.UserId) >= damage,
        "Shadow Spark bypassed live threat bookkeeping"
    )

    cast_venom_rend(bridge, player, enemy)

    bridge:Invoke("disable_casts")
    local disabled = cutover:Invoke("disable")
    assert(
        disabled.ok and not disabled.snapshot.Enabled,
        "Nightweaver source cutover rollback failed"
    )

    bridge:Invoke("clear_owner", {
        UserId = player.UserId,
    })
    Runtime.clear_character(player.UserId)

    if enemy.Parent then
        enemy:Destroy()
    end

    print(
        "[Nightweaver Live] "
            .. "INTERRUPT_PLUS_CONCENTRATION_PLUS_DARK_PLUS_VENOM_PASS"
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
        pcall(function()
            bridge:Invoke("set_interrupt_roll", {
                UserId = Players:GetPlayers()[1]
                    and Players:GetPlayers()[1].UserId,
                Roll = nil,
            })
        end)
    end

    if not ok then
        warn("[Nightweaver Live] FAIL " .. tostring(reason))
    end

    StudioTestService:EndTest(
        if ok then "PASS" else "FAIL " .. tostring(reason)
    )
end)

task.delay(TEST_TIMEOUT, function()
    StudioTestService:EndTest(
        "FAIL Nightweaver live global timeout"
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
    assert(tests, "Nightweaver live Dungeon tests folder missing")

    for _, name in ipairs({
        "DungeonOptionalDepthPhysicalLayoutTest",
        "DungeonLateEventPhysicalLayoutTest",
    }) do
        local script_instance = tests:FindFirstChild(name)
        assert(
            script_instance and script_instance:IsA("Script"),
            "Nightweaver regression script missing: " .. name
        )
        script_instance.Disabled = true
    end
end

disable_conflicting_regressions()
print("[Nightweaver Live] EDIT_DRIVER_READY")

local ok, result = pcall(function()
    return StudioTestService:ExecutePlayModeAsync(
        "TEMP_C4NightweaverLive"
    )
end)

driver:Destroy()

assert(
    ok and result == "PASS",
    "Nightweaver live rehearsal failed: " .. tostring(result)
)

print("[Nightweaver Live] VERIFIED_PLAY_MODE_PASS")

return true
