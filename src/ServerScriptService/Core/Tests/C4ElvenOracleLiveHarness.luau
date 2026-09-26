--!strict
-- Unpublished Play rehearsal for Lifebinder / Elven Oracle level-30 skills.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Lifebinder live rehearsal requires an unpublished local place"
)

local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")
local StudioTestService = game:GetService("StudioTestService")

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
        "Lifebinder live runtime anchor missing"
    )

    assert(
        not string.find(
            source,
            original,
            first + #original,
            true
        ),
        "Lifebinder live runtime anchor is ambiguous"
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
    local ManaService = require(
        ServerScriptService.Combat.ManaService
    )
    local name = "C4LifebinderLiveBridge_TEMP"
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
                reason = "C4LifebinderPlayerUnavailable",
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

        if action == "spend_mana" then
            return {
                ok = ManaService.try_spend(
                    player,
                    payload.Amount
                ),
                current = ManaService.get(player),
                maximum = ManaService.get_max(player),
            }
        end

        if action == "mana_snapshot" then
            return {
                ok = true,
                current = ManaService.get(player),
                maximum = ManaService.get_max(player),
            }
        end

        if action == "clear_owner" then
            cast_runtime:clear_owner(player)
            return {ok = true}
        end

        return {
            ok = false,
            reason = "UnknownC4LifebinderLiveAction",
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
driver.Name = "C4LifebinderLiveServer_TEMP"
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
local LIVE_BRIDGE = "C4LifebinderLiveBridge_TEMP"
local TEST_TIMEOUT = 100

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

    error("[Lifebinder Live] TIMEOUT " .. label)
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
Builds an authentic level-30 Lifebinder first-transfer state.

Args:
    user_id (number): Actual connected Studio player ID.

Returns:
    any: Disposable Lifebinder progression state.
]]
local function lifebinder_character(user_id)
    local character =
        ProfileSchema.create_default(user_id).Characters.Slot1
    local quest = assert(QuestStages.get("ElvenOracle"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "Elf",
        BaseClassId = "Mage",
        ClassId = "Lifebinder",
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
        OriginalFirstTransferChoiceId = "ElvenOracle",
        OriginalFirstTransferClassId = "Lifebinder",
        OriginalFirstTransferReceiptId =
            "TEMP_LifebinderLive",
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

    own_skill(character, "LifebinderQuickPrayer", 2)
    own_skill(character, "LifebinderWindShackle", 3)
    own_skill(character, "LifebinderAgility", 1)
    own_skill(character, "LifebinderManaRecharge", 2)

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
Creates one disposable reviewed Marauder target.

Args:
    player (Player): Actual Play client.

Returns:
    Model: Live reviewed Marauder target.
]]
local function rehearsal_enemy(player)
    local player_root =
        assert(player.Character.HumanoidRootPart)

    local enemy = Instance.new("Model")
    enemy.Name = "TEMP_LifebinderMarauder"
    enemy:SetAttribute("DungeonEnemyArchetypeId", "Marauder")
    enemy:SetAttribute("DungeonEncounterId", "TEMP_Lifebinder")

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
Faces the actual player toward one rehearsal NPC.

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
Waits just beyond one source launch deadline.

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
    assert(charged.ok, "Lifebinder Spiritshot charge failed")
end

--[[
Casts exact rank-three Wind Shackle into real NPC weakening authority.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual source caster.
    enemy (Model): Reviewed NPC target.

Returns:
    nil: Confirms exact rate-only weakening reaches live NPC state.
]]
local function cast_wind_shackle(bridge, player, enemy)
    face_enemy(player, enemy)
    charge_spiritshot(bridge, player)

    local started = bridge:Invoke("begin_direct", {
        UserId = player.UserId,
        Target = enemy,
        SkillId = "LifebinderWindShackle",
    })
    assert(started.ok, tostring(started.reason))
    local plan = started.result

    assert(
        plan.SourceSkillId == 1206
            and plan.SourceRank == 4
            and plan.SourceCastRange == 600
            and plan.SourceEffectRange == 1100,
        "Wind Shackle source contract drifted"
    )

    wait_for_launch(plan.LaunchAt)
    local launched = bridge:Invoke("launch_direct", {
        UserId = player.UserId,
        CastId = plan.CastId,
        SequenceId = 3201,
    })
    assert(launched.ok, tostring(launched.reason))

    local application = launched.result.Application
    assert(
        application.Applied
            and application.Landed
            and application.Calculation.SourceSkillId == 1206
            and application.Calculation.SourceRank == 4
            and application.PhysicalAttackSpeedMultiplier == 0.8
            and application.RateReductionFraction == 0.2
            and application.DurationSeconds == 15
            and enemy:GetAttribute("C4PowerWeakening") == 0
            and enemy:GetAttribute("C4RateWeakening") == 0.2,
        "Wind Shackle did not apply exact rate-only weakening"
    )

    print(
        "[Lifebinder Live] WIND_SHACKLE_PASS rate=0.2 duration=15"
    )
end

--[[
Casts Agility on the real source-active player.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual source caster and target.

Returns:
    nil: Confirms exact source buff identity and duration.
]]
local function cast_agility(bridge, player)
    charge_spiritshot(bridge, player)

    local started = bridge:Invoke("begin_support", {
        UserId = player.UserId,
        SkillId = "LifebinderAgility",
    })
    assert(started.ok, tostring(started.reason))
    assert(
        started.result.SourceSkillId == 1087
            and started.result.SourceRank == 1
            and started.result.SourceCastRange == 400
            and started.result.SourceEffectRange == 900,
        "Agility source contract drifted"
    )

    wait_for_launch(started.result.LaunchAt)
    local launched = bridge:Invoke("launch_support", {
        UserId = player.UserId,
        CastId = started.result.CastId,
    })
    assert(launched.ok, tostring(launched.reason))

    local application = launched.result.Application
    assert(
        application.Applied
            and application.Kind == "C4LiveSupportBuff"
            and application.SourceSkillId == 1087
            and application.SourceRank == 1
            and application.DurationSeconds == 1200,
        "Agility did not apply exact 20-minute source buff"
    )

    print("[Lifebinder Live] AGILITY_PASS duration=1200 evasion=+2")
end

--[[
Casts rank-two Mana Recharge on the real player after reducing MP.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual source caster and target.

Returns:
    nil: Confirms source power restores live ManaService state.
]]
local function cast_mana_recharge(bridge, player)
    local spent = bridge:Invoke("spend_mana", {
        UserId = player.UserId,
        Amount = 100,
    })
    assert(spent.ok, "Failed to create Mana Recharge headroom")

    charge_spiritshot(bridge, player)
    local started = bridge:Invoke("begin_support", {
        UserId = player.UserId,
        SkillId = "LifebinderManaRecharge",
    })
    assert(started.ok, tostring(started.reason))
    assert(
        started.result.SourceSkillId == 1013
            and started.result.SourceRank == 2
            and started.result.SourceCastRange == 400
            and started.result.SourceEffectRange == 900,
        "Mana Recharge source contract drifted"
    )

    wait_for_launch(started.result.LaunchAt)
    local launched = bridge:Invoke("launch_support", {
        UserId = player.UserId,
        CastId = started.result.CastId,
    })
    assert(launched.ok, tostring(launched.reason))

    local application = launched.result.Application
    assert(
        application.Applied
            and application.Kind == "C4LiveTargetManaRecharge"
            and application.SourceSkillId == 1013
            and application.SourceRank == 2
            and application.RawRecharge == 52
            and application.EffectiveRecharge > 0,
        "Mana Recharge did not restore authoritative live MP"
    )

    local snapshot = bridge:Invoke("mana_snapshot", {
        UserId = player.UserId,
    })
    assert(
        snapshot.ok
            and snapshot.current > 0
            and snapshot.current <= snapshot.maximum,
        "Mana Recharge left invalid live mana state"
    )

    print(
        "[Lifebinder Live] MANA_RECHARGE_PASS restored="
            .. tostring(application.EffectiveRecharge)
    )
end

--[[
Runs the complete unpublished Lifebinder Play rehearsal.

Args:
    None.

Returns:
    nil: Ends only after hostile/support/recharge paths and rollback pass.
]]
local function run()
    print("[Lifebinder Live] RUN_START")
    local player = admitted_player()
    local enemy = rehearsal_enemy(player)
    face_enemy(player, enemy)

    Runtime.set_character(
        player.UserId,
        lifebinder_character(player.UserId)
    )

    local boundary, reason =
        Runtime.get_c4_resource_migration_boundary(
            player.UserId
        )
    assert(
        boundary
            and reason == nil
            and boundary.ScopeId == "ElvenOracle"
            and boundary.CutoverPrerequisitesReady,
        "Lifebinder source boundary is not live-rehearsal ready"
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
        "Lifebinder source cutover failed"
    )

    local cast_enabled = bridge:Invoke("enable_casts")
    assert(
        cast_enabled.ok
            and cast_enabled.capability.DirectMagicCurrentlyEnabled
            and cast_enabled.capability.SupportMagicCurrentlyEnabled,
        "Lifebinder cast bridges did not enable"
    )

    assert(bridge:Invoke("add_item", {
        UserId = player.UserId,
        ItemId = "mystic_charge",
        Quantity = 8,
    }).ok)

    cast_wind_shackle(bridge, player, enemy)
    cast_agility(bridge, player)
    cast_mana_recharge(bridge, player)

    bridge:Invoke("disable_casts")
    local disabled = cutover:Invoke("disable")
    assert(
        disabled.ok and not disabled.snapshot.Enabled,
        "Lifebinder source cutover rollback failed"
    )

    bridge:Invoke("clear_owner", {
        UserId = player.UserId,
    })
    Runtime.clear_character(player.UserId)

    if enemy.Parent then
        enemy:Destroy()
    end

    print(
        "[Lifebinder Live] "
            .. "SHACKLE_PLUS_AGILITY_PLUS_RECHARGE_PASS"
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
        warn("[Lifebinder Live] FAIL " .. tostring(reason))
    end

    StudioTestService:EndTest(
        if ok then "PASS" else "FAIL " .. tostring(reason)
    )
end)

task.delay(TEST_TIMEOUT, function()
    StudioTestService:EndTest(
        "FAIL Lifebinder live global timeout"
    )
end)
]==]

driver.Parent = ServerScriptService

--[[
Disables edit-only physical scripts that author duplicate synthetic anchors.

Args:
    None.

Returns:
    nil: Disables only disposable unpublished Studio copies.
]]
local function disable_conflicting_regressions()
    local tests = ServerScriptService.Dungeon:FindFirstChild("Tests")
    assert(tests, "Lifebinder live Dungeon tests folder missing")

    for _, name in ipairs({
        "DungeonOptionalDepthPhysicalLayoutTest",
        "DungeonLateEventPhysicalLayoutTest",
    }) do
        local script_instance = tests:FindFirstChild(name)
        assert(
            script_instance and script_instance:IsA("Script"),
            "Lifebinder regression script missing: " .. name
        )
        script_instance.Disabled = true
    end
end

disable_conflicting_regressions()

local ok, result = pcall(function()
    return StudioTestService:ExecutePlayModeAsync(
        "TEMP_C4LifebinderLive"
    )
end)

driver:Destroy()

assert(
    ok and result == "PASS",
    "Lifebinder live rehearsal failed: " .. tostring(result)
)

print("[Lifebinder Live] VERIFIED_PLAY_MODE_PASS")

return true
