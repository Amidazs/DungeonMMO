--!strict
-- Unpublished Play rehearsal for Duskseer / Elven Oracle level-30 skills.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Duskseer live rehearsal requires an unpublished local place"
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
        "Duskseer live runtime anchor missing"
    )

    assert(
        not string.find(
            source,
            original,
            first + #original,
            true
        ),
        "Duskseer live runtime anchor is ambiguous"
    )

    runtime_source.Source = source:sub(1, first - 1)
        .. replacement
        .. source:sub(first + #original)
end

local bridge_anchor = [==[
ProgressionService.bind_default(runtime.ProgressionService)
]==]

local bridge_replacement = [==[
if RunService:IsStudio()
    and game.PlaceId == 0
    and game.GameId == 0
then
    local ServerStorage = game:GetService("ServerStorage")
    local ManaService = require(
        ServerScriptService.Combat.ManaService
    )
    local name = "C4DuskseerLiveBridge_TEMP"
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
                reason = "C4DuskseerPlayerUnavailable",
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

        if action == "normal_attack_npc" then
            local result, reason =
                runtime.C4SourceCombatExecutor:normal_attack_npc(
                    player,
                    payload.Target,
                    payload.SequenceId
                )
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
            reason = "UnknownC4DuskseerLiveAction",
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
driver.Name = "C4DuskseerLiveServer_TEMP"
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
local LIVE_BRIDGE = "C4DuskseerLiveBridge_TEMP"
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

    error("[Duskseer Live] TIMEOUT " .. label)
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
Builds an authentic level-30 Duskseer first-transfer state.

Args:
    user_id (number): Actual connected Studio player ID.

Returns:
    any: Disposable Duskseer progression state.
]]
local function duskseer_character(user_id)
    local character =
        ProfileSchema.create_default(user_id).Characters.Slot1
    local quest = assert(QuestStages.get("ShillienOracle"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "DarkElf",
        BaseClassId = "Mage",
        ClassId = "Duskseer",
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
        OriginalFirstTransferChoiceId = "ShillienOracle",
        OriginalFirstTransferClassId = "Duskseer",
        OriginalFirstTransferReceiptId =
            "TEMP_DuskseerLive",
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

    for _, row in ipairs({
        {"DuskseerArcaneResistance", 6},
        {"DuskseerQuickPrayer", 2},
        {"DuskseerManaReservoir", 2},
        {"DuskseerFastCasting", 1},
        {"DuskseerManaRecovery", 1},
        {"DuskseerRobeTraining", 6},
        {"DuskseerLightArmorTraining", 6},
        {"DuskseerWeaponTraining", 5},
        {"DuskseerWindShackle", 3},
        {"DuskseerEmpower", 1},
        {"DuskseerManaRecharge", 2},
        {"DuskseerBloodRite", 1},
    }) do
        own_skill(character, row[1], row[2])
    end

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
    enemy.Name = "TEMP_DuskseerMarauder"
    enemy:SetAttribute("DungeonEnemyArchetypeId", "Marauder")
    enemy:SetAttribute("DungeonEncounterId", "TEMP_Duskseer")

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
    assert(charged.ok, "Duskseer Spiritshot charge failed")
end

--[[
Charges one real inventory-backed Soulshot.

Args:
    bridge (BindableFunction): Live rehearsal bridge.
    player (Player): Actual source attacker.

Returns:
    nil: Confirms one physical shot charge exists.
]]
local function charge_soulshot(bridge, player)
    local charged = bridge:Invoke("charge", {
        UserId = player.UserId,
        ShotKind = "Soulshot",
    })
    assert(charged.ok, tostring(charged.reason))
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
        SkillId = "DuskseerWindShackle",
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
        "[Duskseer Live] WIND_SHACKLE_PASS rate=0.2 duration=15"
    )
end

--[[
Casts Empower on the real source-active player.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual source caster and target.

Returns:
    nil: Confirms exact source buff identity and duration.
]]
local function cast_empower(bridge, player)
    charge_spiritshot(bridge, player)

    local before = assert(
        Runtime.get_c4_resource_migration_boundary(
            player.UserId
        )
    ).SourceStatCandidate.MAGICAL_ATTACK

    local started = bridge:Invoke("begin_support", {
        UserId = player.UserId,
        SkillId = "DuskseerEmpower",
    })
    assert(started.ok, tostring(started.reason))
    assert(
        started.result.SourceSkillId == 1059
            and started.result.SourceRank == 1
            and started.result.SourceCastRange == 400
            and started.result.SourceEffectRange == 900,
        "Empower source contract drifted"
    )

    wait_for_launch(started.result.LaunchAt)
    local launched = bridge:Invoke("launch_support", {
        UserId = player.UserId,
        CastId = started.result.CastId,
    })
    assert(launched.ok, tostring(launched.reason))

    local application = launched.result.Application
    local boundary = assert(
        Runtime.get_c4_resource_migration_boundary(
            player.UserId
        )
    )
    local after = boundary.SourceStatCandidate.MAGICAL_ATTACK

    assert(
        application.Applied
            and application.Kind == "C4LiveSupportBuff"
            and application.SourceSkillId == 1059
            and application.SourceRank == 1
            and application.DurationSeconds == 1200
            and after > before,
        "Empower did not increase authoritative source M.Atk"
    )

    print(
        "[Duskseer Live] EMPOWER_PASS duration=1200 matk="
            .. tostring(after)
    )
end

--[[
Casts Blood Rite and proves C4 non-bow melee life absorption.

Args:
    bridge (BindableFunction): Live cast/combat bridge.
    player (Player): Actual source-active Duskseer.
    enemy (Model): Reviewed NPC target.

Returns:
    nil: Confirms source 1268:1 and live 6 percent melee absorption.
]]
local function cast_blood_rite_and_absorb(
    bridge,
    player,
    enemy
)
    charge_spiritshot(bridge, player)

    local started = bridge:Invoke("begin_support", {
        UserId = player.UserId,
        SkillId = "DuskseerBloodRite",
    })
    assert(started.ok, tostring(started.reason))
    assert(
        started.result.SourceSkillId == 1268
            and started.result.SourceRank == 1
            and started.result.SourceCastRange == 400
            and started.result.SourceEffectRange == 900,
        "Blood Rite source contract drifted"
    )

    wait_for_launch(started.result.LaunchAt)
    local launched = bridge:Invoke("launch_support", {
        UserId = player.UserId,
        CastId = started.result.CastId,
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
            and application.SourceSkillId == 1268
            and application.SourceRank == 1
            and application.DurationSeconds == 1200
            and boundary.SourceStatCandidate
                .ABSORB_DAMAGE_PERCENT == 6,
        "Blood Rite did not reach active 6 percent source absorption"
    )

    local humanoid =
        assert(player.Character:FindFirstChildOfClass("Humanoid"))
    humanoid.Health = math.max(1, humanoid.MaxHealth - 100)

    face_enemy(player, enemy)
    charge_soulshot(bridge, player)

    local before = humanoid.Health
    local attacked = bridge:Invoke("normal_attack_npc", {
        UserId = player.UserId,
        Target = enemy,
        SequenceId = 4201,
    })
    assert(attacked.ok, tostring(attacked.reason))

    local result = attacked.result
    assert(
        result.Hit
            and result.Applied
            and result.AbsorbDamagePercent == 6
            and result.RequestedAbsorbHeal > 0
            and result.EffectiveAbsorbHeal > 0
            and humanoid.Health > before,
        "Blood Rite did not heal from a live non-bow source attack"
    )

    print(
        "[Duskseer Live] BLOOD_RITE_PASS absorb=6 healed="
            .. tostring(result.EffectiveAbsorbHeal)
    )
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
        SkillId = "DuskseerManaRecharge",
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
        "[Duskseer Live] MANA_RECHARGE_PASS restored="
            .. tostring(application.EffectiveRecharge)
    )
end

--[[
Runs the complete unpublished Duskseer Play rehearsal.

Args:
    None.

Returns:
    nil: Ends only after hostile/support/recharge paths and rollback pass.
]]
local function run()
    print("[Duskseer Live] RUN_START")
    local player = admitted_player()
    local enemy = rehearsal_enemy(player)
    face_enemy(player, enemy)

    Runtime.set_character(
        player.UserId,
        duskseer_character(player.UserId)
    )

    local boundary, reason =
        Runtime.get_c4_resource_migration_boundary(
            player.UserId
        )
    assert(
        boundary
            and reason == nil
            and boundary.ScopeId == "ShillienOracle"
            and boundary.CutoverPrerequisitesReady,
        "Duskseer source boundary is not live-rehearsal ready"
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
        "Duskseer source cutover failed"
    )

    local cast_enabled = bridge:Invoke("enable_casts")
    assert(
        cast_enabled.ok
            and cast_enabled.capability.DirectMagicCurrentlyEnabled
            and cast_enabled.capability.SupportMagicCurrentlyEnabled,
        "Duskseer cast bridges did not enable"
    )

    assert(bridge:Invoke("add_item", {
        UserId = player.UserId,
        ItemId = "mystic_charge",
        Quantity = 12,
    }).ok)
    assert(bridge:Invoke("add_item", {
        UserId = player.UserId,
        ItemId = "kinetic_charge",
        Quantity = 12,
    }).ok)

    cast_wind_shackle(bridge, player, enemy)
    cast_empower(bridge, player)
    cast_blood_rite_and_absorb(bridge, player, enemy)
    cast_mana_recharge(bridge, player)

    bridge:Invoke("disable_casts")
    local disabled = cutover:Invoke("disable")
    assert(
        disabled.ok and not disabled.snapshot.Enabled,
        "Duskseer source cutover rollback failed"
    )

    bridge:Invoke("clear_owner", {
        UserId = player.UserId,
    })
    Runtime.clear_character(player.UserId)

    if enemy.Parent then
        enemy:Destroy()
    end

    print(
        "[Duskseer Live] "
            .. "SHACKLE_PLUS_EMPOWER_PLUS_BLOOD_RITE_PLUS_RECHARGE_PASS"
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
        warn("[Duskseer Live] FAIL " .. tostring(reason))
    end

    StudioTestService:EndTest(
        if ok then "PASS" else "FAIL " .. tostring(reason)
    )
end)

task.delay(TEST_TIMEOUT, function()
    StudioTestService:EndTest(
        "FAIL Duskseer live global timeout"
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
    assert(tests, "Duskseer live Dungeon tests folder missing")

    for _, name in ipairs({
        "DungeonOptionalDepthPhysicalLayoutTest",
        "DungeonLateEventPhysicalLayoutTest",
    }) do
        local script_instance = tests:FindFirstChild(name)
        assert(
            script_instance and script_instance:IsA("Script"),
            "Duskseer regression script missing: " .. name
        )
        script_instance.Disabled = true
    end
end

disable_conflicting_regressions()

local ok, result = pcall(function()
    return StudioTestService:ExecutePlayModeAsync(
        "TEMP_C4DuskseerLive"
    )
end)

driver:Destroy()

assert(
    ok and result == "PASS",
    "Duskseer live rehearsal failed: " .. tostring(result)
)

print("[Duskseer Live] VERIFIED_PLAY_MODE_PASS")

return true
