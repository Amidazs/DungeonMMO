--!strict
-- Unpublished Play rehearsal for Moonweaver / Elven Wizard level-30 skills.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Moonweaver live rehearsal requires an unpublished local place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local StudioTestService = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local runtime_source =
    ServerScriptService.Dungeon.DungeonRuntime

--[[
Replaces one exact DungeonRuntime source span in the disposable Studio place.

Args:
    original (string): Exact source text expected once.
    replacement (string): Test-only replacement.

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
        "Moonweaver live runtime anchor missing"
    )

    assert(
        not string.find(
            source,
            original,
            first + #original,
            true
        ),
        "Moonweaver live runtime anchor is ambiguous"
    )

    runtime_source.Source = source:sub(1, first - 1)
        .. replacement
        .. source:sub(first + #original)
end

local bridge_anchor = [==[
C4CombatCutoverStudioBridge.bind(
    runtime.C4CombatCutoverCoordinator,
    nil,
    function(user_id: number): (any?, string?)
        return ProgressionRuntimeState
            .get_c4_resource_migration_boundary(user_id)
    end
)
ProgressionService.bind_default(runtime.ProgressionService)
]==]

local bridge_replacement = [==[
C4CombatCutoverStudioBridge.bind(
    runtime.C4CombatCutoverCoordinator,
    nil,
    function(user_id: number): (any?, string?)
        return ProgressionRuntimeState
            .get_c4_resource_migration_boundary(user_id)
    end
)

if RunService:IsStudio()
    and game.PlaceId == 0
    and game.GameId == 0
then
    local ServerStorage = game:GetService("ServerStorage")
    local name = "C4MoonweaverLiveBridge_TEMP"
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
            cast_runtime.CompanionMagic:set_enabled(true)
            return {
                ok = true,
                capability = cast_runtime:capability(),
            }
        end

        if action == "disable_casts" then
            cast_runtime.DirectMagic:set_enabled(false)
            cast_runtime.SupportMagic:set_enabled(false)
            cast_runtime.CompanionMagic:set_enabled(false)
            return {ok = true}
        end

        local player = player_from_payload(payload)
        if not player then
            return {
                ok = false,
                reason = "C4MoonweaverPlayerUnavailable",
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

        if action == "begin_companion" then
            local result, reason =
                cast_runtime.CompanionMagic:begin_cast(
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

        if action == "launch_companion" then
            local result, reason =
                cast_runtime.CompanionMagic:launch_if_ready(
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

        if action == "companion_snapshot" then
            return {
                ok = true,
                snapshot = cast_runtime.Companions:snapshot(
                    player
                ),
            }
        end

        if action == "prepare_companion" then
            local snapshot =
                cast_runtime.Companions:snapshot(player)
            local model = snapshot.Model
            local humanoid = model
                and model:FindFirstChildOfClass("Humanoid")

            if not model or not humanoid then
                return {
                    ok = false,
                    reason = "C4MoonweaverCompanionUnavailable",
                }
            end

            humanoid.Health = 35
            model:SetAttribute("C4CompanionMana", 20)
            return {
                ok = true,
                health = humanoid.Health,
                mana = model:GetAttribute("C4CompanionMana"),
            }
        end

        if action == "clear_owner" then
            cast_runtime:clear_owner(player)
            return {ok = true}
        end

        return {
            ok = false,
            reason = "UnknownC4MoonweaverLiveAction",
        }
    end
end

ProgressionService.bind_default(runtime.ProgressionService)
]==]

replace_once(bridge_anchor, bridge_replacement)

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
driver.Name = "C4MoonweaverLiveServer_TEMP"
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
local Threat = require(
    ServerScriptService.Combat.ThreatService
)

local CUTOVER_BRIDGE = "C4CombatCutoverRehearsalBridge"
local LIVE_BRIDGE = "C4MoonweaverLiveBridge_TEMP"
local TEST_TIMEOUT = 115

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

    error("[Moonweaver Live] TIMEOUT " .. label)
end

--[[
Adds one known purchased skill to a disposable character state.

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
Builds an authentic level-30 Moonweaver first-transfer state.

Args:
    user_id (number): Actual connected Studio player ID.

Returns:
    any: Disposable Moonweaver progression state.
]]
local function moonweaver_character(user_id)
    local character =
        ProfileSchema.create_default(user_id).Characters.Slot1
    local quest = assert(QuestStages.get("ElvenWizard"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "Elf",
        BaseClassId = "Mage",
        ClassId = "Moonweaver",
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
        OriginalFirstTransferChoiceId = "ElvenWizard",
        OriginalFirstTransferClassId = "Moonweaver",
        OriginalFirstTransferReceiptId =
            "TEMP_MoonweaverLive",
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
    character.Equipment.Weapon =
        "apprentice_arcane_wand"

    own_skill(character, "MoonweaverQuickWeave", 2)
    own_skill(character, "MoonweaverTidalBolt", 6)
    own_skill(character, "MoonweaverTidalWard", 1)
    own_skill(character, "MoonweaverManaCompanion", 3)
    own_skill(character, "MoonweaverServitorHeal", 9)
    own_skill(character, "MoonweaverServitorRecharge", 4)

    return character
end

--[[
Returns the actual admitted Play client.

Args:
    None.

Returns:
    Player: Connected player with a living admitted character.
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
Creates one disposable reviewed NPC target.

Args:
    player (Player): Actual Play client.

Returns:
    Model: Live reviewed Marauder target.
]]
local function rehearsal_enemy(player)
    local player_root =
        assert(player.Character.HumanoidRootPart)

    local enemy = Instance.new("Model")
    enemy.Name = "TEMP_MoonweaverMarauder"
    enemy:SetAttribute("DungeonEnemyArchetypeId", "Marauder")
    enemy:SetAttribute("DungeonEncounterId", "TEMP_Moonweaver")

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
Faces the actual player toward the rehearsal NPC.

Args:
    player (Player): Actual source caster.
    enemy (Model): Reviewed target.

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
    bridge (BindableFunction): Live rehearsal bridge.
    player (Player): Actual source caster.

Returns:
    nil: Confirms one charge exists.
]]
local function charge_spiritshot(bridge, player)
    local charged = bridge:Invoke("charge", {
        UserId = player.UserId,
        ShotKind = "Spiritshot",
    })
    assert(charged.ok, "Moonweaver Spiritshot charge failed")
end

--[[
Casts exact rank-six Tidal Bolt into real NPC HP.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual source caster.
    enemy (Model): Reviewed NPC target.

Returns:
    number: Applied real NPC HP damage.
]]
local function cast_tidal_bolt(bridge, player, enemy)
    face_enemy(player, enemy)
    charge_spiritshot(bridge, player)

    local started = bridge:Invoke("begin_direct", {
        UserId = player.UserId,
        Target = enemy,
        SkillId = "MoonweaverTidalBolt",
    })
    assert(started.ok, tostring(started.reason))
    local plan = started.result

    assert(
        plan.SourceSkillId == 1175
            and plan.SourceRank == 6
            and plan.SourceCastRange == 750
            and plan.SourceEffectRange == 1250,
        "Tidal Bolt source contract drifted"
    )

    local humanoid =
        assert(enemy:FindFirstChildOfClass("Humanoid"))
    local before = humanoid.Health
    wait_for_launch(plan.LaunchAt)

    local launched = bridge:Invoke("launch_direct", {
        UserId = player.UserId,
        CastId = plan.CastId,
        SequenceId = 3101,
    })
    assert(launched.ok, tostring(launched.reason))

    local application = launched.result.Application
    local calculation = application.Calculation
    assert(
        launched.result.Applied
            and application.HealthDamage > 0
            and humanoid.Health < before
            and calculation.SourceSkillId == 1175
            and calculation.SourceRank == 6
            and calculation.SourceElement == "WATER"
            and calculation.Spiritshot,
        "Tidal Bolt did not apply exact source WATER damage"
    )

    local shot = bridge:Invoke("shot_snapshot", {
        UserId = player.UserId,
    })
    assert(
        shot.ok and not shot.snapshot.Spiritshot,
        "Tidal Bolt did not consume exactly one Spiritshot"
    )

    print(
        "[Moonweaver Live] TIDAL_BOLT_PASS damage="
            .. tostring(application.HealthDamage)
    )
    return application.HealthDamage
end

--[[
Casts Tidal Ward on the real source-active player.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual source caster/target.

Returns:
    nil: Confirms exact timed-buff identity and duration.
]]
local function cast_tidal_ward(bridge, player)
    charge_spiritshot(bridge, player)

    local started = bridge:Invoke("begin_support", {
        UserId = player.UserId,
        SkillId = "MoonweaverTidalWard",
    })
    assert(started.ok, tostring(started.reason))
    local plan = started.result

    assert(
        plan.SourceSkillId == 1182
            and plan.SourceRank == 1
            and plan.SourceCastRange == 400
            and plan.SourceEffectRange == 900,
        "Tidal Ward source contract drifted"
    )

    wait_for_launch(plan.LaunchAt)
    local launched = bridge:Invoke("launch_support", {
        UserId = player.UserId,
        CastId = plan.CastId,
    })
    assert(launched.ok, tostring(launched.reason))

    local application = launched.result.Application
    assert(
        launched.result.Applied
            and application.Kind == "C4LiveSupportBuff"
            and application.SourceSkillId == 1182
            and application.SourceRank == 1
            and application.DurationSeconds == 1200,
        "Tidal Ward did not apply exact 20-minute source buff"
    )

    print("[Moonweaver Live] TIDAL_WARD_PASS duration=1200")
end

--[[
Summons and supports the real Moonweaver Mana Companion.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual owner.

Returns:
    nil: Confirms source NPC, reagent, heal and recharge behavior.
]]
local function rehearse_companion(bridge, player)
    local started = bridge:Invoke("begin_companion", {
        UserId = player.UserId,
        SkillId = "MoonweaverManaCompanion",
    })
    assert(started.ok, tostring(started.reason))
    assert(
        started.result.SourceSkillId == 1226
            and started.result.SourceRank == 3,
        "Moonweaver Mana Companion source contract drifted"
    )

    wait_for_launch(started.result.LaunchAt)
    local summoned = bridge:Invoke("launch_companion", {
        UserId = player.UserId,
        CastId = started.result.CastId,
    })
    assert(summoned.ok, tostring(summoned.reason))

    local application = summoned.result.Application
    assert(
        application.Applied
            and application.SourceSkillId == 1226
            and application.SourceNpcId == 12065
            and application.Role == "Mana"
            and application.ExpPenalty == 0.3
            and application.InitialReagentConsumed == 1,
        "Moonweaver Mana Companion live source identity drifted"
    )

    local prepared = bridge:Invoke("prepare_companion", {
        UserId = player.UserId,
    })
    assert(
        prepared.ok
            and prepared.health == 35
            and prepared.mana == 20,
        "Moonweaver companion preparation failed"
    )

    charge_spiritshot(bridge, player)
    local heal_start = bridge:Invoke("begin_companion", {
        UserId = player.UserId,
        SkillId = "MoonweaverServitorHeal",
    })
    assert(heal_start.ok, tostring(heal_start.reason))
    wait_for_launch(heal_start.result.LaunchAt)

    local healed = bridge:Invoke("launch_companion", {
        UserId = player.UserId,
        CastId = heal_start.result.CastId,
    })
    assert(
        healed.ok
            and healed.result.Application.Applied
            and healed.result.Application.SourceSkillId == 1127
            and healed.result.Application.EffectiveHeal > 0,
        "Moonweaver Servitor Heal did not reach owned companion"
    )

    charge_spiritshot(bridge, player)
    local recharge_start = bridge:Invoke("begin_companion", {
        UserId = player.UserId,
        SkillId = "MoonweaverServitorRecharge",
    })
    assert(recharge_start.ok, tostring(recharge_start.reason))
    wait_for_launch(recharge_start.result.LaunchAt)

    local recharged = bridge:Invoke("launch_companion", {
        UserId = player.UserId,
        CastId = recharge_start.result.CastId,
    })
    assert(
        recharged.ok
            and recharged.result.Application.Applied
            and recharged.result.Application.SourceSkillId == 1126
            and recharged.result.Application.ManaRestored > 0,
        "Moonweaver Servitor Recharge did not reach owned companion"
    )

    local snapshot = bridge:Invoke("companion_snapshot", {
        UserId = player.UserId,
    })
    assert(
        snapshot.ok
            and snapshot.snapshot.Active
            and snapshot.snapshot.SourceSkillId == 1226
            and snapshot.snapshot.SourceNpcId == 12065,
        "Moonweaver companion ownership snapshot drifted"
    )

    print(
        "[Moonweaver Live] COMPANION_PASS npc=12065 heal="
            .. tostring(healed.result.Application.EffectiveHeal)
            .. " mana="
            .. tostring(recharged.result.Application.ManaRestored)
    )
end

--[[
Runs the complete unpublished Moonweaver Play rehearsal.

Args:
    None.

Returns:
    nil: Ends only after direct/support/companion paths and rollback pass.
]]
local function run()
    local player = admitted_player()
    local enemy = rehearsal_enemy(player)
    face_enemy(player, enemy)

    Runtime.set_character(
        player.UserId,
        moonweaver_character(player.UserId)
    )

    local boundary, reason =
        Runtime.get_c4_resource_migration_boundary(
            player.UserId
        )
    assert(
        boundary
            and reason == nil
            and boundary.ScopeId == "ElvenWizard"
            and boundary.CutoverPrerequisitesReady,
        "Moonweaver source boundary is not live-rehearsal ready"
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
        "Moonweaver source cutover failed"
    )

    local cast_enabled = bridge:Invoke("enable_casts")
    assert(
        cast_enabled.ok
            and cast_enabled.capability.DirectMagicCurrentlyEnabled
            and cast_enabled.capability.SupportMagicCurrentlyEnabled
            and cast_enabled.capability.CompanionMagicCurrentlyEnabled,
        "Moonweaver cast bridges did not enable"
    )

    assert(bridge:Invoke("add_item", {
        UserId = player.UserId,
        ItemId = "mystic_charge",
        Quantity = 5,
    }).ok)
    assert(bridge:Invoke("add_item", {
        UserId = player.UserId,
        ItemId = "emberweaver_spirit_ore",
        Quantity = 5,
    }).ok)

    local damage = cast_tidal_bolt(
        bridge,
        player,
        enemy
    )
    assert(
        Threat.get_threat(enemy, player.UserId) >= damage,
        "Tidal Bolt bypassed live threat bookkeeping"
    )

    cast_tidal_ward(bridge, player)
    rehearse_companion(bridge, player)

    bridge:Invoke("disable_casts")
    local disabled = cutover:Invoke("disable")
    assert(
        disabled.ok and not disabled.snapshot.Enabled,
        "Moonweaver source cutover rollback failed"
    )

    bridge:Invoke("clear_owner", {
        UserId = player.UserId,
    })
    Runtime.clear_character(player.UserId)

    local snapshot = bridge:Invoke(
        "companion_snapshot",
        {UserId = player.UserId}
    )
    assert(
        snapshot.ok and not snapshot.snapshot.Active,
        "Moonweaver owner cleanup left companion state"
    )

    if enemy.Parent then
        enemy:Destroy()
    end

    print(
        "[Moonweaver Live] "
            .. "TIDAL_PLUS_WARD_PLUS_COMPANION_PASS"
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
        warn("[Moonweaver Live] FAIL " .. tostring(reason))
    end

    StudioTestService:EndTest(
        if ok then "PASS" else "FAIL " .. tostring(reason)
    )
end)

task.delay(TEST_TIMEOUT, function()
    StudioTestService:EndTest(
        "FAIL Moonweaver live global timeout"
    )
end)
]==]

driver.Parent = ServerScriptService

local ok, result = pcall(function()
    return StudioTestService:ExecutePlayModeAsync(
        "TEMP_C4MoonweaverLive"
    )
end)

driver:Destroy()

assert(
    ok and result == "PASS",
    "Moonweaver live rehearsal failed: " .. tostring(result)
)

print("[Moonweaver Live] VERIFIED_PLAY_MODE_PASS")
