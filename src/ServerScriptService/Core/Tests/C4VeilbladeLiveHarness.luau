--!strict
-- Unpublished Play rehearsal for Dark Elf Assassin / Veilblade level-30 skills.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Veilblade live rehearsal requires an unpublished local place"
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
        "Veilblade live runtime anchor missing"
    )

    assert(
        not string.find(
            source,
            original,
            first + #original,
            true
        ),
        "Veilblade live runtime anchor is ambiguous"
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
    local name = "C4VeilbladeLiveBridge_TEMP"
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
            cast_runtime.VeilbladeCast:set_enabled(true)
            return {
                ok = true,
                capability = cast_runtime:capability(),
            }
        end

        if action == "disable_casts" then
            cast_runtime.VeilbladeCast:set_enabled(false)
            return {ok = true}
        end

        local player = player_from_payload(payload)
        if not player then
            return {
                ok = false,
                reason = "C4VeilbladePlayerUnavailable",
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
                cast_runtime.VeilbladeCast:begin_cast(
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
                cast_runtime.VeilbladeCast:launch_if_ready(
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
            reason = "UnknownC4VeilbladeLiveAction",
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
driver.Name = "C4VeilbladeLiveServer_TEMP"
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
local LIVE_BRIDGE = "C4VeilbladeLiveBridge_TEMP"
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

    error("[Veilblade Live] TIMEOUT " .. label)
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
Builds an authentic level-30 Veilblade first-transfer state.

Args:
    user_id (number): Actual connected Studio player ID.

Returns:
    any: Disposable Veilblade progression state.
]]
local function veilblade_character(user_id)
    local character =
        ProfileSchema.create_default(user_id).Characters.Slot1
    local quest = assert(QuestStages.get("DarkElfAssassin"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "DarkElf",
        BaseClassId = "Fighter",
        ClassId = "Veilblade",
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
        OriginalFirstTransferChoiceId = "DarkElfAssassin",
        OriginalFirstTransferClassId = "Veilblade",
        OriginalFirstTransferReceiptId = "TEMP_VeilbladeLive",
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
    character.Equipment.Weapon = "scout_dagger"

    own_skill(character, "VeilbladeDefenseAura", 1)
    own_skill(character, "VeilbladeUmbralSiphon", 8)
    own_skill(character, "VeilbladeCrimsonSting", 6)

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
    enemy.Name = "TEMP_VeilbladeMarauder"
    enemy:SetAttribute("DungeonEnemyArchetypeId", "Marauder")
    enemy:SetAttribute("DungeonEncounterId", "TEMP_Veilblade")

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
Casts Defense Aura through the real active-effect authority.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual Veilblade.

Returns:
    nil: Confirms exact source identity and 20-minute effect duration.
]]
local function cast_defense_aura(bridge, player)
    local started = bridge:Invoke("begin", {
        UserId = player.UserId,
        Target = nil,
        SkillId = "VeilbladeDefenseAura",
    })
    assert(started.ok, tostring(started.reason))
    assert(
        started.result.SourceSkillId == 91
            and started.result.SourceRank == 1,
        "Defense Aura source contract drifted"
    )

    wait_for_launch(started.result.LaunchAt)
    local launched = bridge:Invoke("launch", {
        UserId = player.UserId,
        CastId = started.result.CastId,
        SequenceId = 4501,
    })
    assert(launched.ok, tostring(launched.reason))

    local application = launched.result.Application
    assert(
        application.Applied
            and application.Kind == "C4LiveSelfBuff"
            and application.SourceSkillId == 91
            and application.SourceRank == 1
            and application.DurationSeconds == 1200,
        "Defense Aura did not reach live timed source-effect authority"
    )

    print("[Veilblade Live] DEFENSE_AURA_PASS duration=1200")
end

--[[
Casts Umbral Siphon into real NPC HP and caster healing.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual Veilblade.
    enemy (Model): Reviewed NPC target.

Returns:
    nil: Confirms source drain damage/heal bookkeeping.
]]
local function cast_umbral_siphon(bridge, player, enemy)
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
        SkillId = "VeilbladeUmbralSiphon",
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
        SequenceId = 4502,
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
        "Umbral Siphon did not apply live damage and drain healing"
    )

    print(
        "[Veilblade Live] UMBRAL_SIPHON_PASS damage="
            .. tostring(application.HealthDamage)
            .. " heal="
            .. tostring(application.EffectiveHeal)
    )
end

--[[
Casts Crimson Sting through the real physical-damage and status path.

Args:
    bridge (BindableFunction): Live cast bridge.
    player (Player): Actual Veilblade.
    enemy (Model): Reviewed NPC target.

Returns:
    nil: Confirms exact source rank and positive live physical damage.
]]
local function cast_crimson_sting(bridge, player, enemy)
    face_enemy(player, enemy)

    local target_humanoid =
        assert(enemy:FindFirstChildOfClass("Humanoid"))
    local before = target_humanoid.Health

    local started = bridge:Invoke("begin", {
        UserId = player.UserId,
        Target = enemy,
        SkillId = "VeilbladeCrimsonSting",
    })
    assert(started.ok, tostring(started.reason))
    assert(
        started.result.SourceSkillId == 223
            and started.result.SourceRank == 6
            and started.result.SourceCastRange == 40
            and started.result.SourceEffectRange == 400,
        "Crimson Sting source contract drifted"
    )

    wait_for_launch(started.result.LaunchAt)
    local launched = bridge:Invoke("launch", {
        UserId = player.UserId,
        CastId = started.result.CastId,
        SequenceId = 4503,
    })
    assert(launched.ok, tostring(launched.reason))

    local application = launched.result.Application
    assert(
        application.Applied
            and application.Kind == "C4LiveNpcPhysicalStatusSkill"
            and application.Damage.HealthDamage > 0
            and target_humanoid.Health < before,
        "Crimson Sting did not reach live physical damage authority"
    )

    print(
        "[Veilblade Live] CRIMSON_STING_PASS damage="
            .. tostring(application.Damage.HealthDamage)
            .. " bleed_landed="
            .. tostring(application.Landed == true)
    )
end

--[[
Runs the unpublished Veilblade Play rehearsal.

Args:
    None.

Returns:
    nil: Ends only after self-buff, drain, strike and rollback pass.
]]
local function run()
    print("[Veilblade Live] RUN_START")
    local player = admitted_player()
    local enemy = rehearsal_enemy(player)
    face_enemy(player, enemy)

    Runtime.set_character(
        player.UserId,
        veilblade_character(player.UserId)
    )

    local boundary, reason =
        Runtime.get_c4_resource_migration_boundary(
            player.UserId
        )
    assert(
        boundary
            and reason == nil
            and boundary.ScopeId == "DarkElfAssassin"
            and boundary.CutoverPrerequisitesReady,
        "Veilblade source boundary is not live-rehearsal ready"
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
        "Veilblade source cutover failed"
    )

    local cast_enabled = bridge:Invoke("enable_casts")
    assert(
        cast_enabled.ok
            and cast_enabled.capability.VeilbladeCastCurrentlyEnabled,
        "Veilblade cast bridge did not enable"
    )

    assert(bridge:Invoke("add_item", {
        UserId = player.UserId,
        ItemId = "mystic_charge",
        Quantity = 6,
    }).ok)

    cast_defense_aura(bridge, player)
    cast_umbral_siphon(bridge, player, enemy)
    cast_crimson_sting(bridge, player, enemy)

    bridge:Invoke("disable_casts")
    local disabled = cutover:Invoke("disable")
    assert(
        disabled.ok and not disabled.snapshot.Enabled,
        "Veilblade source cutover rollback failed"
    )

    bridge:Invoke("clear_owner", {
        UserId = player.UserId,
    })
    Runtime.clear_character(player.UserId)

    if enemy.Parent then
        enemy:Destroy()
    end

    print(
        "[Veilblade Live] "
            .. "AURA_PLUS_DRAIN_PLUS_STING_PASS"
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
        warn("[Veilblade Live] FAIL " .. tostring(reason))
    end

    StudioTestService:EndTest(
        if ok then "PASS" else "FAIL " .. tostring(reason)
    )
end)

task.delay(TEST_TIMEOUT, function()
    StudioTestService:EndTest(
        "FAIL Veilblade live global timeout"
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
    assert(tests, "Veilblade live Dungeon tests folder missing")

    for _, name in ipairs({
        "DungeonOptionalDepthPhysicalLayoutTest",
        "DungeonLateEventPhysicalLayoutTest",
    }) do
        local script_instance = tests:FindFirstChild(name)
        assert(
            script_instance and script_instance:IsA("Script"),
            "Veilblade regression script missing: " .. name
        )
        script_instance.Disabled = true
    end
end

disable_conflicting_regressions()

local ok, result = pcall(function()
    return StudioTestService:ExecutePlayModeAsync(
        "TEMP_C4VeilbladeLive"
    )
end)

driver:Destroy()

assert(
    ok and result == "PASS",
    "Veilblade live rehearsal failed: " .. tostring(result)
)

print("[Veilblade Live] VERIFIED_PLAY_MODE_PASS")

return true
