--!strict
-- Unpublished Play rehearsal for Palus Knight / Duskguard level-30 skills.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Duskguard live rehearsal requires an unpublished local place"
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
        "Duskguard live runtime anchor missing"
    )

    assert(
        not string.find(
            source,
            original,
            first + #original,
            true
        ),
        "Duskguard live runtime anchor is ambiguous"
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
    local name = "C4DuskguardLiveBridge_TEMP"
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
            cast_runtime.DuskguardCast:set_enabled(true)
            return {
                ok = true,
                capability = cast_runtime:capability(),
            }
        end

        if action == "disable_casts" then
            cast_runtime.DuskguardCast:set_enabled(false)
            return {ok = true}
        end

        local player = player_from_payload(payload)
        if not player then
            return {
                ok = false,
                reason = "C4DuskguardPlayerUnavailable",
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

        if action == "begin" then
            local result, reason =
                cast_runtime.DuskguardCast:begin_cast(
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

        if action == "launch" then
            local result, reason =
                cast_runtime.DuskguardCast:launch_if_ready(
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

        if action == "clear_owner" then
            cast_runtime:clear_owner(player)
            return {ok = true}
        end

        return {
            ok = false,
            reason = "UnknownC4DuskguardLiveAction",
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
    "Fighter"
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
driver.Name = "C4DuskguardLiveServer_TEMP"
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
local LIVE_BRIDGE = "C4DuskguardLiveBridge_TEMP"
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

    error("[Duskguard Live] TIMEOUT " .. label)
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
Builds an authentic level-30 Duskguard first-transfer state.

Args:
    user_id (number): Actual connected Studio player ID.

Returns:
    any: Disposable Duskguard progression state.
]]
local function duskguard_character(user_id)
    local character =
        ProfileSchema.create_default(user_id).Characters.Slot1
    local quest = assert(QuestStages.get("PalusKnight"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "DarkElf",
        BaseClassId = "Fighter",
        ClassId = "Duskguard",
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
        OriginalFirstTransferChoiceId = "PalusKnight",
        OriginalFirstTransferClassId = "Duskguard",
        OriginalFirstTransferReceiptId =
            "TEMP_DuskguardLive",
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
    character.Equipment.Weapon = "marauder_sword"

    own_skill(character, "DuskguardUmbralSiphon", 8)
    own_skill(character, "DuskguardChallenge", 6)
    own_skill(character, "DuskguardLastStand", 1)

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
    Model: Live reviewed NPC target.
]]
local function rehearsal_enemy(player)
    local player_root =
        assert(player.Character.HumanoidRootPart)

    local enemy = Instance.new("Model")
    enemy.Name = "TEMP_DuskguardMarauder"
    enemy:SetAttribute("DungeonEnemyArchetypeId", "Marauder")
    enemy:SetAttribute("DungeonEncounterId", "TEMP_Duskguard")

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
Casts exact rank-six Challenge into the real threat authority.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual Duskguard.
    enemy (Model): Reviewed NPC target.

Returns:
    nil: Confirms zero-damage threat application.
]]
local function cast_challenge(bridge, player, enemy)
    face_enemy(player, enemy)
    local started = bridge:Invoke("begin", {
        UserId = player.UserId,
        Target = enemy,
        SkillId = "DuskguardChallenge",
    })
    assert(started.ok, tostring(started.reason))
    assert(
        started.result.SourceSkillId == 28
            and started.result.SourceRank == 6
            and started.result.SourceCastRange == 400
            and started.result.SourceEffectRange == 900,
        "Challenge source contract drifted"
    )

    wait_for_launch(started.result.LaunchAt)
    local launched = bridge:Invoke("launch", {
        UserId = player.UserId,
        CastId = started.result.CastId,
        SequenceId = 4401,
    })
    assert(launched.ok, tostring(launched.reason))

    local application = launched.result.Application
    assert(
        application.Applied
            and application.Kind == "C4LiveNpcAggression"
            and application.HealthDamage == 0
            and application.ThreatPower == 803
            and Threat.get_threat(enemy, player.UserId) >= 803,
        "Challenge did not reach live zero-damage threat authority"
    )

    print("[Duskguard Live] CHALLENGE_PASS threat=803 damage=0")
end

--[[
Casts Last Stand through the real active-effect and immobility authorities.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual Duskguard.

Returns:
    nil: Confirms exact source identity and live root immobility.
]]
local function cast_last_stand(bridge, player)
    local started = bridge:Invoke("begin", {
        UserId = player.UserId,
        Target = nil,
        SkillId = "DuskguardLastStand",
    })
    assert(started.ok, tostring(started.reason))
    assert(
        started.result.SourceSkillId == 110
            and started.result.SourceRank == 1,
        "Last Stand source contract drifted"
    )

    wait_for_launch(started.result.LaunchAt)
    local launched = bridge:Invoke("launch", {
        UserId = player.UserId,
        CastId = started.result.CastId,
        SequenceId = 4402,
    })
    assert(launched.ok, tostring(launched.reason))

    local application = launched.result.Application
    local root =
        assert(player.Character.HumanoidRootPart)
    assert(
        application.Applied
            and application.Kind == "C4LiveSelfBuff"
            and application.SourceSkillId == 110
            and application.SourceRank == 1
            and application.DurationSeconds == 30
            and application.Immobile
            and root.Anchored
            and player.Character:GetAttribute("C4Immobile") == true,
        "Last Stand did not reach live immobility authority"
    )

    print("[Duskguard Live] LAST_STAND_PASS duration=30 immobile=true")
end

--[[
Casts Umbral Siphon into real NPC HP and caster healing.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual Duskguard.
    enemy (Model): Reviewed NPC target.

Returns:
    nil: Confirms source drain damage/heal bookkeeping.
]]
local function cast_umbral_siphon(bridge, player, enemy)
    local root =
        assert(player.Character.HumanoidRootPart)
    root.Anchored = false
    player.Character:SetAttribute("C4Immobile", false)
    face_enemy(player, enemy)

    local humanoid =
        assert(player.Character:FindFirstChildOfClass("Humanoid"))
    humanoid.Health = math.max(1, humanoid.MaxHealth - 60)

    local charged = bridge:Invoke("charge", {
        UserId = player.UserId,
        ShotKind = "Spiritshot",
    })
    assert(charged.ok, tostring(charged.reason))

    local target_humanoid =
        assert(enemy:FindFirstChildOfClass("Humanoid"))
    local target_before = target_humanoid.Health
    local caster_before = humanoid.Health

    local started = bridge:Invoke("begin", {
        UserId = player.UserId,
        Target = enemy,
        SkillId = "DuskguardUmbralSiphon",
    })
    assert(started.ok, tostring(started.reason))
    assert(
        started.result.SourceSkillId == 70
            and started.result.SourceRank == 10
            and started.result.SourceCastRange == 600
            and started.result.SourceEffectRange == 1100,
        "Umbral Siphon source contract drifted"
    )

    wait_for_launch(started.result.LaunchAt)
    local launched = bridge:Invoke("launch", {
        UserId = player.UserId,
        CastId = started.result.CastId,
        SequenceId = 4403,
    })
    assert(launched.ok, tostring(launched.reason))

    local application = launched.result.Application
    assert(
        application.Applied
            and application.Kind == "C4LiveNpcMagicDrain"
            and application.AbsorbPart == 0.2
            and application.HealthDamage > 0
            and target_humanoid.Health < target_before
            and humanoid.Health > caster_before
            and application.EffectiveHeal > 0,
        "Umbral Siphon did not apply live damage and source drain healing"
    )

    print(
        "[Duskguard Live] UMBRAL_SIPHON_PASS damage="
            .. tostring(application.HealthDamage)
            .. " heal="
            .. tostring(application.EffectiveHeal)
    )
end

--[[
Runs the unpublished Duskguard Play rehearsal.

Args:
    None.

Returns:
    nil: Ends only after threat, self-buff, drain and rollback pass.
]]
local function run()
    print("[Duskguard Live] RUN_START")
    local player = admitted_player()
    local enemy = rehearsal_enemy(player)
    face_enemy(player, enemy)

    Runtime.set_character(
        player.UserId,
        duskguard_character(player.UserId)
    )

    local boundary, reason =
        Runtime.get_c4_resource_migration_boundary(
            player.UserId
        )
    assert(
        boundary
            and reason == nil
            and boundary.ScopeId == "PalusKnight"
            and boundary.CutoverPrerequisitesReady,
        "Duskguard source boundary is not live-rehearsal ready"
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
        "Duskguard source cutover failed"
    )

    local cast_enabled = bridge:Invoke("enable_casts")
    assert(
        cast_enabled.ok
            and cast_enabled.capability.DuskguardCastCurrentlyEnabled,
        "Duskguard cast bridge did not enable"
    )

    assert(bridge:Invoke("add_item", {
        UserId = player.UserId,
        ItemId = "mystic_charge",
        Quantity = 6,
    }).ok)

    cast_challenge(bridge, player, enemy)
    cast_last_stand(bridge, player)
    cast_umbral_siphon(bridge, player, enemy)

    bridge:Invoke("disable_casts")
    local disabled = cutover:Invoke("disable")
    assert(
        disabled.ok and not disabled.snapshot.Enabled,
        "Duskguard source cutover rollback failed"
    )

    bridge:Invoke("clear_owner", {
        UserId = player.UserId,
    })
    Runtime.clear_character(player.UserId)

    if enemy.Parent then
        enemy:Destroy()
    end

    print(
        "[Duskguard Live] "
            .. "CHALLENGE_PLUS_LAST_STAND_PLUS_DRAIN_PASS"
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
        warn("[Duskguard Live] FAIL " .. tostring(reason))
    end

    StudioTestService:EndTest(
        if ok then "PASS" else "FAIL " .. tostring(reason)
    )
end)

task.delay(TEST_TIMEOUT, function()
    StudioTestService:EndTest(
        "FAIL Duskguard live global timeout"
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
    assert(tests, "Duskguard live Dungeon tests folder missing")

    for _, name in ipairs({
        "DungeonOptionalDepthPhysicalLayoutTest",
        "DungeonLateEventPhysicalLayoutTest",
    }) do
        local script_instance = tests:FindFirstChild(name)
        assert(
            script_instance and script_instance:IsA("Script"),
            "Duskguard regression script missing: " .. name
        )
        script_instance.Disabled = true
    end
end

disable_conflicting_regressions()

local ok, result = pcall(function()
    return StudioTestService:ExecutePlayModeAsync(
        "TEMP_C4DuskguardLive"
    )
end)

driver:Destroy()

assert(
    ok and result == "PASS",
    "Duskguard live rehearsal failed: " .. tostring(result)
)

print("[Duskguard Live] VERIFIED_PLAY_MODE_PASS")

return true
