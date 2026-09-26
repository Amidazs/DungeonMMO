--!strict
-- Unpublished Play rehearsal for staged Human Wizard source casts.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Human Wizard targeted cast rehearsal requires unpublished Studio"
)

local ServerScriptService = game:GetService("ServerScriptService")
local StudioTestService = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local runtime_source =
    ServerScriptService.Dungeon.DungeonRuntime

--[[
Replaces one exact DungeonRuntime source span in the disposable place.

Args:
    original (string): Exact source text expected once.
    replacement (string): Test-only in-memory replacement.

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
        "Wizard rehearsal runtime source anchor missing"
    )

    assert(
        not string.find(
            source,
            original,
            first + #original,
            true
        ),
        "Wizard rehearsal runtime source anchor is ambiguous"
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
    local name = "C4HumanWizardTargetedCastBridge_TEMP"
    local old = ServerStorage:FindFirstChild(name)

    if old then
        old:Destroy()
    end

    local cast_bridge = Instance.new("BindableFunction")
    cast_bridge.Name = name
    cast_bridge.Parent = ServerStorage

    local function player_from_payload(payload)
        local user_id = type(payload) == "table"
            and payload.UserId or nil

        if type(user_id) ~= "number" then
            return nil
        end

        return Players:GetPlayerByUserId(user_id)
    end

    cast_bridge.OnInvoke = function(action, payload)
        local cast_runtime = runtime.C4SourceCastRuntime

        if not cast_runtime then
            return {
                ok = false,
                reason = "C4SourceCastRuntimeUnavailable",
            }
        end

        if action == "capability" then
            return {
                ok = true,
                capability = cast_runtime:capability(),
            }
        end

        if action == "enable_casts" then
            cast_runtime.DirectMagic:set_enabled(true)
            cast_runtime.PeriodicMagic:set_enabled(true)
            return {
                ok = true,
                capability = cast_runtime:capability(),
            }
        end

        if action == "disable_casts" then
            cast_runtime.DirectMagic:set_enabled(false)
            cast_runtime.PeriodicMagic:set_enabled(false)
            return {
                ok = true,
                capability = cast_runtime:capability(),
            }
        end

        local player = player_from_payload(payload)
        if not player then
            return {
                ok = false,
                reason = "C4WizardRehearsalPlayerUnavailable",
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
            local started, reason =
                cast_runtime.DirectMagic:begin_cast(
                    player,
                    payload.Target,
                    payload.SkillId,
                    nil
                )
            return {
                ok = started ~= nil,
                reason = reason,
                result = started,
            }
        end

        if action == "launch_direct" then
            local launched, reason =
                cast_runtime.DirectMagic:launch_if_ready(
                    player,
                    payload.CastId,
                    nil,
                    payload.SequenceId
                )
            return {
                ok = launched ~= nil,
                reason = reason,
                result = launched,
            }
        end

        if action == "begin_periodic" then
            local started, reason =
                cast_runtime.PeriodicMagic:begin_cast(
                    player,
                    payload.Target,
                    payload.SkillId,
                    nil
                )
            return {
                ok = started ~= nil,
                reason = reason,
                result = started,
            }
        end

        if action == "launch_periodic" then
            local launched, reason =
                cast_runtime.PeriodicMagic:launch_if_ready(
                    player,
                    payload.CastId,
                    nil,
                    payload.SequenceId
                )
            return {
                ok = launched ~= nil,
                reason = reason,
                result = launched,
            }
        end

        if action == "reuse_remaining" then
            return {
                ok = true,
                remaining =
                    cast_runtime.Scheduler:get_reuse_remaining(
                        player,
                        payload.SkillId,
                        nil
                    ),
            }
        end

        if action == "clear_owner" then
            cast_runtime:clear_owner(player)
            return {
                ok = true,
            }
        end

        return {
            ok = false,
            reason = "UnknownC4WizardRehearsalAction",
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
driver.Name = "C4HumanWizardTargetedCastServer_TEMP"
driver.Source = [==[
local Players = game:GetService("Players")
local ReplicatedStorage =
    game:GetService("ReplicatedStorage")
local ServerScriptService =
    game:GetService("ServerScriptService")
local ServerStorage =
    game:GetService("ServerStorage")
local StudioTestService =
    game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")

local Shared = ReplicatedStorage.Core.Shared
local ProfileSchema = require(Shared.ProfileSchema)
local QuestStages = require(
    Shared.C4OriginalFirstTransferQuestStages
)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)
local Mana = require(
    ServerScriptService.Combat.ManaService
)
local Threat = require(
    ServerScriptService.Combat.ThreatService
)

local CUTOVER_BRIDGE =
    "C4CombatCutoverRehearsalBridge"
local CAST_BRIDGE =
    "C4HumanWizardTargetedCastBridge_TEMP"
local TEST_TIMEOUT = 115

local DIRECT_CASES = {
    {
        SkillId = "EmberweaverEmberBolt",
        Rank = 6,
        SourceSkillId = 1220,
        InitialMp = 6,
        LaunchMp = 21,
        CastRange = 750,
        EffectRange = 1250,
    },
    {
        SkillId = "EmberweaverFlameBurst",
        Rank = 6,
        SourceSkillId = 1172,
        InitialMp = 6,
        LaunchMp = 21,
        CastRange = 150,
        EffectRange = 650,
    },
    {
        SkillId = "EmberweaverFocusedBolt",
        Rank = 3,
        SourceSkillId = 1274,
        InitialMp = 3,
        LaunchMp = 11,
        CastRange = 400,
        EffectRange = 900,
    },
}

--[[
Polls one live server condition with a bounded deadline.

Args:
    predicate (any): Callback returning the desired truthy value.
    label (string): Failure diagnostic.
    seconds (number): Maximum wait in seconds.

Returns:
    any: First truthy value returned by the predicate.
]]
local function wait_for(
    predicate,
    label,
    seconds
)
    local deadline = os.clock() + seconds

    repeat
        local value = predicate()
        if value then
            return value
        end
        task.wait(0.05)
    until os.clock() >= deadline

    error("[Wizard Targeted Cast Live] TIMEOUT " .. label)
end

--[[
Adds one known purchased skill to a disposable character state.

Args:
    character (any): Mutable profile-shaped character.
    skill_id (string): Creative skill identifier.
    rank (number): Purchased creative rank.

Returns:
    nil: Adds only server-owned test progression state.
]]
local function own_skill(
    character,
    skill_id,
    rank
)
    character.Progression.Skills[skill_id] = {
        Known = true,
        StarterGranted = false,
        PurchasedRank = rank,
        Proficiency = 0,
    }
end

--[[
Builds an authentic level-30 Human Wizard first-transfer state.

Args:
    user_id (number): Actual connected Studio player ID.

Returns:
    any: Disposable Emberweaver progression state.
]]
local function wizard_character(user_id)
    local character =
        ProfileSchema.create_default(user_id).Characters.Slot1
    local quest = assert(QuestStages.get("HumanWizard"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "Human",
        BaseClassId = "Mage",
        ClassId = "Emberweaver",
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
        OriginalFirstTransferChoiceId = "HumanWizard",
        OriginalFirstTransferClassId = "Emberweaver",
        OriginalFirstTransferReceiptId =
            "TEMP_WizardTargetedCastLive",
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

    own_skill(character, "EmberweaverQuickWeave", 2)
    own_skill(character, "EmberweaverEmberBolt", 6)
    own_skill(character, "EmberweaverFlameBurst", 6)
    own_skill(character, "EmberweaverFocusedBolt", 3)
    own_skill(character, "EmberweaverVenomHex", 2)

    return character
end

--[[
Returns the actual admitted Play client and living character.

Args:
    None.

Returns:
    (Player, Model): Connected player and server-owned character.
]]
local function admitted_player()
    local player =
        Players:GetPlayers()[1]
        or Players.PlayerAdded:Wait()

    local character = wait_for(function()
        local model = player.Character
        local humanoid = model
            and model:FindFirstChildOfClass("Humanoid")
        local root = model
            and model:FindFirstChild("HumanoidRootPart")

        if player:GetAttribute("DungeonCombatAllowed") == true
            and humanoid
            and humanoid.Health > 0
            and root
        then
            return model
        end
    end, "admitted live player", 45)

    return player, character
end

--[[
Creates one disposable live NPC using an actually reviewed source archetype.

The model is a real Workspace Humanoid target. Only its server-created
DungeonEnemyArchetypeId selects the pinned source NPC boundary.

Args:
    player (Player): Admitted real Studio player.

Returns:
    Model: Live source-reviewed Marauder rehearsal target.
]]
local function rehearsal_enemy(player)
    local character = assert(player.Character)
    local player_root = assert(
        character:FindFirstChild("HumanoidRootPart")
    )

    local enemy = Instance.new("Model")
    enemy.Name = "TEMP_C4WizardRehearsalMarauder"
    enemy:SetAttribute("DungeonEnemyArchetypeId", "Marauder")
    enemy:SetAttribute("C4RehearsalTarget", true)

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Anchored = true
    root.CanCollide = false
    root.Size = Vector3.new(2, 2, 1)
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
Places the real player comfortably inside all reviewed cast ranges.

Args:
    player (Player): Real source caster.
    enemy (Model): Reviewed physical NPC target.

Returns:
    nil: Moves only the disposable Studio character.
]]
local function face_enemy(player, enemy)
    local root =
        player.Character.HumanoidRootPart
    local target_position = enemy.PrimaryPart.Position

    root.CFrame = CFrame.lookAt(
        target_position + Vector3.new(0, 0, 6),
        target_position
    )
    root.AssemblyLinearVelocity = Vector3.zero
end

--[[
Waits until the source scheduler's absolute launch deadline.

Args:
    launch_at (number): Server os.clock deadline.

Returns:
    nil: Returns just after the source hit deadline.
]]
local function wait_for_launch(launch_at)
    while os.clock() < launch_at + 0.03 do
        task.wait(0.02)
    end
end

--[[
Charges one real inventory-backed Spiritshot.

Args:
    cast_bridge (BindableFunction): Runtime cast rehearsal bridge.
    player (Player): Actual source caster.

Returns:
    nil: Confirms one magical charge is present before the cast.
]]
local function charge_spiritshot(
    cast_bridge,
    player
)
    local charged = cast_bridge:Invoke("charge", {
        UserId = player.UserId,
        ShotKind = "Spiritshot",
    })
    assert(
        charged.ok,
        "Spiritshot charge failed: "
            .. tostring(charged.reason)
    )

    local snapshot =
        cast_bridge:Invoke("shot_snapshot", {
            UserId = player.UserId,
        })
    assert(
        snapshot.ok
            and snapshot.snapshot.Spiritshot == true,
        "Spiritshot did not remain charged before cast"
    )
end

--[[
Runs one real targeted direct-MDAM spell through the live source runtime.

Args:
    cast_bridge (BindableFunction): Real staged cast runtime bridge.
    player (Player): Actual source-cutover participant.
    enemy (Model): Actual reviewed Dungeon NPC.
    case (any): Exact reviewed skill/rank/cost/range vector.
    sequence_id (number): Trusted server action sequence.

Returns:
    number: Positive applied NPC health damage.
]]
local function cast_direct(
    cast_bridge,
    player,
    enemy,
    case,
    sequence_id
)
    face_enemy(player, enemy)
    charge_spiritshot(cast_bridge, player)

    local mana_before = Mana.get(player)
    local started = cast_bridge:Invoke("begin_direct", {
        UserId = player.UserId,
        Target = enemy,
        SkillId = case.SkillId,
    })
    assert(
        started.ok,
        case.SkillId .. " start failed: "
            .. tostring(started.reason)
    )

    local plan = started.result
    assert(
        plan.SourceSkillId == case.SourceSkillId
            and plan.SourceCastRange == case.CastRange
            and plan.SourceEffectRange == case.EffectRange,
        case.SkillId .. " source identity/range drifted"
    )
    assert(
        math.abs(
            mana_before
                - Mana.get(player)
                - case.InitialMp
        ) < 0.001,
        case.SkillId .. " initial MP split is wrong"
    )

    local humanoid =
        assert(enemy:FindFirstChildOfClass("Humanoid"))
    local hp_before = humanoid.Health

    wait_for_launch(plan.LaunchAt)

    local launched =
        cast_bridge:Invoke("launch_direct", {
            UserId = player.UserId,
            CastId = plan.CastId,
            SequenceId = sequence_id,
        })
    assert(
        launched.ok,
        case.SkillId .. " launch failed: "
            .. tostring(launched.reason)
    )

    local result = launched.result
    local application = result.Application
    local calculation = application.Calculation

    assert(
        result.Applied
            and application.HealthDamage > 0
            and humanoid.Health < hp_before,
        case.SkillId .. " did not reduce real NPC HP"
    )
    assert(
        result.Launch.InitialMpSpent == case.InitialMp
            and result.Launch.LaunchMpSpent == case.LaunchMp,
        case.SkillId .. " split-MP launch evidence drifted"
    )
    assert(
        calculation.SourceSkillId == case.SourceSkillId
            and calculation.Spiritshot
            and not calculation.BlessedSpiritshot,
        case.SkillId .. " did not use the charged source Spiritshot"
    )

    local shot_after =
        cast_bridge:Invoke("shot_snapshot", {
            UserId = player.UserId,
        })
    assert(
        shot_after.ok
            and not shot_after.snapshot.Spiritshot,
        case.SkillId .. " did not consume Spiritshot once"
    )

    print(
        "[Wizard Targeted Cast Live] "
            .. case.SkillId
            .. " PASS damage="
            .. tostring(application.HealthDamage)
    )

    return application.HealthDamage
end

--[[
Runs one real Venom Hex source cast and verifies resolution/shot authority.

The source land roll is intentionally random. A resisted cast is still a valid
source result; when it lands, the test additionally verifies the first exact
24-damage nonlethal tick.

Args:
    cast_bridge (BindableFunction): Real staged cast runtime bridge.
    player (Player): Actual source-cutover participant.
    enemy (Model): Actual reviewed Dungeon NPC.

Returns:
    nil: Confirms exact source resolution and optional live tick.
]]
local function cast_venom_hex(
    cast_bridge,
    player,
    enemy
)
    face_enemy(player, enemy)
    charge_spiritshot(cast_bridge, player)

    local started =
        cast_bridge:Invoke("begin_periodic", {
            UserId = player.UserId,
            Target = enemy,
            SkillId = "EmberweaverVenomHex",
        })
    assert(
        started.ok,
        "Venom Hex start failed: "
            .. tostring(started.reason)
    )

    local plan = started.result
    assert(
        plan.SourceSkillId == 1168
            and plan.SourceRank == 3
            and plan.SourceCastRange == 600
            and plan.SourceEffectRange == 1100,
        "Venom Hex source plan drifted"
    )

    local humanoid =
        assert(enemy:FindFirstChildOfClass("Humanoid"))
    local health_before = humanoid.Health

    wait_for_launch(plan.LaunchAt)

    local launched =
        cast_bridge:Invoke("launch_periodic", {
            UserId = player.UserId,
            CastId = plan.CastId,
            SequenceId = 2401,
        })
    assert(
        launched.ok,
        "Venom Hex launch failed: "
            .. tostring(launched.reason)
    )

    local result = launched.result
    local resolution = result.Resolution
    local calculation = resolution.Calculation

    assert(
        result.StatusResolved
            and calculation.SourceSkillId == 1168
            and calculation.SourceRank == 3
            and calculation.TickDamage == 24
            and calculation.TickCount == 10
            and calculation.TickSeconds == 3
            and calculation.Spiritshot,
        "Venom Hex did not resolve exact source Poison rank three"
    )

    local shot_after =
        cast_bridge:Invoke("shot_snapshot", {
            UserId = player.UserId,
        })
    assert(
        shot_after.ok
            and not shot_after.snapshot.Spiritshot,
        "Venom Hex did not consume its Spiritshot once"
    )

    if result.Landed then
        wait_for(function()
            return humanoid.Health
                <= health_before - 24
        end, "Venom Hex first exact tick", 4.5)

        print(
            "[Wizard Targeted Cast Live] "
                .. "EmberweaverVenomHex LANDED_PASS"
        )
    else
        assert(
            humanoid.Health == health_before,
            "Resisted Venom Hex unexpectedly damaged the NPC"
        )
        print(
            "[Wizard Targeted Cast Live] "
                .. "EmberweaverVenomHex RESISTED_SOURCE_PASS"
        )
    end
end

--[[
Executes the complete live Human Wizard targeted-cast rehearsal.

Args:
    None.

Returns:
    nil: Ends only after real cast/resource/shot/NPC paths succeed.
]]
local function run()
    local player = admitted_player()
    local enemy = rehearsal_enemy(player)
    face_enemy(player, enemy)

    Runtime.set_character(
        player.UserId,
        wizard_character(player.UserId)
    )

    local boundary, boundary_reason =
        Runtime.get_c4_resource_migration_boundary(
            player.UserId
        )
    if not boundary
        or boundary_reason ~= nil
        or boundary.ScopeId ~= "HumanWizard"
        or not boundary.CutoverPrerequisitesReady
        or not boundary.ReviewedSourceItemIds
        or boundary.ReviewedSourceItemIds.Weapon ~= 6
    then
        local blockers = boundary
            and boundary.ActivationBlockers or {}
        error(
            "Emberweaver source boundary not rehearsal-ready: "
                .. "reason="
                .. tostring(boundary_reason)
                .. " scope="
                .. tostring(boundary and boundary.ScopeId)
                .. " cutover="
                .. tostring(
                    boundary
                        and boundary.CutoverPrerequisitesReady
                )
                .. " statReady="
                .. tostring(
                    boundary
                        and boundary.SourceStatCandidateReady
                )
                .. " weapon="
                .. tostring(
                    boundary
                        and boundary.ReviewedSourceItemIds
                        and boundary.ReviewedSourceItemIds.Weapon
                )
                .. " blockers="
                .. table.concat(blockers, ",")
        )
    end

    local cutover_bridge =
        ServerStorage:WaitForChild(
            CUTOVER_BRIDGE,
            20
        )
    local cast_bridge =
        ServerStorage:WaitForChild(
            CAST_BRIDGE,
            20
        )

    local diagnosed =
        cutover_bridge:Invoke("diagnose", {
            UserIds = {player.UserId},
        })
    assert(
        diagnosed.ok
            and #diagnosed.players == 1
            and diagnosed.players[1]
                .CutoverPrerequisitesReady == true,
        "Live Emberweaver cutover diagnostics failed"
    )

    local enabled = cutover_bridge:Invoke("enable", {
        UserIds = {player.UserId},
        SourceUnitsPerStud = 1,
        IsNight = false,
    })
    assert(
        enabled.ok
            and enabled.snapshot.Enabled
            and enabled.snapshot.ActivePlayerCount == 1,
        "Live Emberweaver source cutover failed: "
            .. tostring(enabled.reason)
    )

    local cast_enabled =
        cast_bridge:Invoke("enable_casts")
    assert(
        cast_enabled.ok
            and cast_enabled.capability
                .DirectMagicCurrentlyEnabled
            and cast_enabled.capability
                .PeriodicMagicCurrentlyEnabled,
        "Staged Wizard cast bridges did not enable"
    )

    local granted = cast_bridge:Invoke("add_item", {
        UserId = player.UserId,
        ItemId = "mystic_charge",
        Quantity = 4,
    })
    assert(
        granted.ok,
        "Could not grant disposable Studio Spiritshots"
    )

    local humanoid =
        assert(enemy:FindFirstChildOfClass("Humanoid"))
    local start_health = humanoid.Health
    local total_direct_damage = 0

    for index, case in ipairs(DIRECT_CASES) do
        total_direct_damage += cast_direct(
            cast_bridge,
            player,
            enemy,
            case,
            2300 + index
        )
    end

    assert(
        total_direct_damage > 0
            and humanoid.Health
                <= start_health - total_direct_damage + 0.01,
        "Three direct Wizard casts did not preserve real NPC damage"
    )

    local threat = Threat.get_threat(
        enemy,
        player.UserId
    )
    assert(
        threat >= total_direct_damage,
        "Wizard source damage bypassed live threat bookkeeping"
    )

    cast_venom_hex(
        cast_bridge,
        player,
        enemy
    )

    local disabled_casts =
        cast_bridge:Invoke("disable_casts")
    assert(
        disabled_casts.ok
            and not disabled_casts.capability
                .DirectMagicCurrentlyEnabled
            and not disabled_casts.capability
                .PeriodicMagicCurrentlyEnabled,
        "Wizard cast bridges did not roll back"
    )

    local disabled =
        cutover_bridge:Invoke("disable")
    assert(
        disabled.ok
            and not disabled.snapshot.Enabled,
        "Wizard source cutover rollback failed"
    )

    cast_bridge:Invoke("clear_owner", {
        UserId = player.UserId,
    })
    Runtime.clear_character(player.UserId)

    print(
        "[Wizard Targeted Cast Live] "
            .. "THREE_DIRECT_PLUS_POISON_PASS"
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

    local cast =
        ServerStorage:FindFirstChild(CAST_BRIDGE)
    if cast and cast:IsA("BindableFunction") then
        pcall(function()
            cast:Invoke("disable_casts")
        end)
    end

    if not ok then
        warn(
            "[Wizard Targeted Cast Live] FAIL "
                .. tostring(reason)
        )
    end

    StudioTestService:EndTest(
        if ok then "PASS"
        else "FAIL " .. tostring(reason)
    )
end)

task.delay(TEST_TIMEOUT, function()
    StudioTestService:EndTest(
        "FAIL Wizard targeted cast global timeout"
    )
end)
]==]

driver.Parent = ServerScriptService

local ok, result = pcall(function()
    return StudioTestService:ExecutePlayModeAsync(
        "TEMP_C4HumanWizardTargetedCastLive"
    )
end)

driver:Destroy()

assert(
    ok and result == "PASS",
    "Human Wizard targeted cast rehearsal failed: "
        .. tostring(result)
)

print(
    "[Wizard Targeted Cast Live] VERIFIED_PLAY_MODE_PASS"
)
