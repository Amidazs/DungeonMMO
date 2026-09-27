--!strict
-- Unpublished Play rehearsal for Warhowl / Orc Raider level-30 combat.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Warhowl live rehearsal requires an unpublished local place"
)

print("[Warhowl Live] EDIT_START")

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
        "Warhowl live runtime anchor missing"
    )

    assert(
        not string.find(source, original, first + #original, true),
        "Warhowl live runtime anchor is ambiguous"
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
    local name = "C4WarhowlLiveBridge_TEMP"
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
                reason = "C4WarhowlPlayerUnavailable",
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

        if action == "clear_owner" then
            cast_runtime:clear_owner(player)
            return {ok = true}
        end

        return {
            ok = false,
            reason = "UnknownC4WarhowlLiveAction",
        }
    end
end

ProficiencyService.bind_default(runtime.ProficiencyService)
]==]

replace_once(bridge_anchor, bridge_replacement)
print("[Warhowl Live] EDIT_PATCHED")

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
driver.Name = "C4WarhowlLiveServer_TEMP"
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
local LIVE_BRIDGE = "C4WarhowlLiveBridge_TEMP"
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

    error("[Warhowl Live] TIMEOUT " .. label)
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
Adds all inherited Orc Fighter ranks needed by the live Warhowl.

Args:
    character (any): Mutable Warhowl character fixture.

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
Adds reviewed Warhowl passive and active ranks through level 30.

Args:
    character (any): Mutable Warhowl character fixture.

Returns:
    nil: Adds exact class-45 ranks used by the live rehearsal.
]]
local function own_warhowl_skills(character)
    local skills = {
        {"WarhowlWoundbind", 1},
        {"WarhowlFury", 1},
        {"WarhowlSkullbreaker", 9},
        {"WarhowlWarRoar", 1},
        {"WarhowlEndurance", 1},
        {"WarhowlBloodFortitude", 2},
        {"WarhowlRecovery", 1},
        {"WarhowlPolearmTraining", 4},
        {"WarhowlLightArmorTraining", 7},
        {"WarhowlHeavyArmorTraining", 7},
        {"WarhowlSweepingArc", 9},
        {"WarhowlCrushingBlow", 9},
        {"WarhowlPrecisionStance", 1},
        {"WarhowlSteelAndStoneTraining", 4},
        {"WarhowlGreatWeaponTraining", 3},
        {"WarhowlPredatorStance", 3},
    }

    for _, row in ipairs(skills) do
        own_skill(character, row[1], row[2])
    end
end

--[[
Builds an authentic level-30 Warhowl first-transfer state.

Args:
    user_id (number): Actual connected Studio player ID.

Returns:
    any: Disposable Warhowl progression state.
]]
local function warhowl_character(user_id)
    local character =
        ProfileSchema.create_default(user_id).Characters.Slot1
    local quest = assert(QuestStages.get("OrcRaider"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "Orc",
        BaseClassId = "Fighter",
        ClassId = "Warhowl",
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
        OriginalFirstTransferChoiceId = "OrcRaider",
        OriginalFirstTransferClassId = "Warhowl",
        OriginalFirstTransferReceiptId = "TEMP_WarhowlLive",
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
    character.Equipment.Weapon = "stonewatch_training_mace"

    own_orc_fighter_skills(character)
    own_warhowl_skills(character)
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
    enemy:SetAttribute("DungeonEncounterId", "TEMP_Warhowl")

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Anchored = true
    root.CanCollide = false
    root.CFrame = player_root.CFrame * CFrame.new(offset)
    root.Parent = enemy

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 6000
    humanoid.Health = 6000
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
Reseeds authoritative runtime state with one reviewed weapon.

Args:
    player (Player): Actual source owner.
    character (any): Mutable Warhowl profile fixture.
    weapon_id (string): Reviewed DungeonMMO weapon ID.

Returns:
    nil: Replaces only the disposable runtime snapshot.
]]
local function equip_weapon(player, character, weapon_id)
    character.Equipment.Weapon = weapon_id
    Runtime.set_character(player.UserId, character)
end

--[[
Casts one reviewed physical family through the live bridge.

Args:
    bridge (BindableFunction): Live Warhowl bridge.
    player (Player): Actual source attacker.
    enemy (Model): Reviewed NPC target.
    skill_id (string): Creative physical skill.
    source_skill_id (number): Expected C4 source skill.
    source_rank (number): Expected source rank.
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
            and plan.SourceCastRange == 40
            and plan.SourceEffectRange == 400,
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
Exercises inherited Orc and Warhowl physical families with real weapons.

Args:
    bridge (BindableFunction): Live Warhowl bridge.
    player (Player): Actual Warhowl.
    character (any): Mutable runtime profile fixture.
    enemies ({Model}): Reviewed nearby NPC targets.

Returns:
    nil: Confirms fist, blunt and polearm routes in Play mode.
]]
local function rehearse_physical_skills(
    bridge,
    player,
    character,
    enemies
)
    equip_weapon(player, character, "orc_training_fist")
    local punch = cast_physical(
        bridge,
        player,
        enemies[1],
        "OrcIronPunch",
        29,
        9,
        6101
    )
    assert(
        punch.Kind == "C4LiveNpcPhysicalSkill",
        "Orc Iron Punch left the live single-target route"
    )

    equip_weapon(player, character, "stonewatch_training_mace")
    local stun = cast_physical(
        bridge,
        player,
        enemies[1],
        "WarhowlSkullbreaker",
        100,
        9,
        6102
    )
    assert(
        stun.Kind == "C4LiveNpcPhysicalStunSkill"
            and stun.DurationSeconds == 9,
        "Warhowl Skullbreaker left the live stun route"
    )

    local smash = cast_physical(
        bridge,
        player,
        enemies[1],
        "WarhowlCrushingBlow",
        255,
        9,
        6103
    )
    assert(
        smash.Kind == "C4LiveNpcPhysicalSkill",
        "Warhowl Crushing Blow left the live physical route"
    )

    equip_weapon(player, character, "ironroot_training_halberd")
    local sweep = cast_physical(
        bridge,
        player,
        enemies[1],
        "WarhowlSweepingArc",
        245,
        9,
        6104
    )
    assert(
        sweep.Kind == "C4LiveNpcPhysicalArea"
            and sweep.SourceSkillRadius == 150
            and sweep.TargetCount >= 1,
        "Warhowl Sweeping Arc left the live area route"
    )

    print(
        "[Warhowl Live] PHYSICAL_PASS "
            .. "fist_blunt_stun_polearm=true"
    )
end

--[[
Casts one scheduled Warhowl self effect.

Args:
    bridge (BindableFunction): Live Warhowl bridge.
    player (Player): Actual Warhowl.
    skill_id (string): Reviewed self effect.
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
Exercises Woundbind, Fury and War Roar in live source state.

Args:
    bridge (BindableFunction): Live Warhowl bridge.
    player (Player): Actual Warhowl.

Returns:
    nil: Confirms all three self-effect families execute in Play.
]]
local function rehearse_self_effects(bridge, player)
    local woundbind = cast_self_effect(
        bridge,
        player,
        "WarhowlWoundbind",
        34
    )
    assert(
        woundbind.Kind == "C4SourceBleedCure"
            and woundbind.Applied
            and not woundbind.BleedPresent,
        "Warhowl Woundbind did not reach live bleed authority"
    )

    local fury = cast_self_effect(
        bridge,
        player,
        "WarhowlFury",
        94
    )
    assert(
        fury.Kind == "C4SourceTimedSelfBuff"
            and fury.Applied
            and fury.DurationSeconds == 60,
        "Warhowl Fury did not preserve its 60-second source buff"
    )

    local humanoid =
        assert(player.Character:FindFirstChildOfClass("Humanoid"))
    humanoid.Health = math.max(1, humanoid.MaxHealth - 200)

    local roar = cast_self_effect(
        bridge,
        player,
        "WarhowlWarRoar",
        121
    )
    assert(
        roar.Kind == "C4SourceTimedSelfBuff"
            and roar.Applied
            and roar.DurationSeconds == 600
            and roar.Heal
            and roar.Heal.Percent == 10,
        "Warhowl War Roar did not preserve source heal/buff semantics"
    )

    print(
        "[Warhowl Live] SELF_EFFECT_PASS "
            .. "woundbind_fury_roar=true"
    )
end

--[[
Toggles one reviewed source stance and validates its source identity.

Args:
    bridge (BindableFunction): Live Warhowl bridge.
    player (Player): Actual Warhowl.
    skill_id (string): Creative toggle identifier.
    source_skill_id (number): Expected source skill.
    source_rank (number): Expected source rank.

Returns:
    any: Toggle-on evidence.
]]
local function toggle_on(
    bridge,
    player,
    skill_id,
    source_skill_id,
    source_rank
)
    local result = bridge:Invoke("toggle", {
        UserId = player.UserId,
        SkillId = skill_id,
    })
    assert(result.ok, tostring(result.reason))
    assert(
        result.result.Active
            and result.result.SourceSkillId == source_skill_id
            and result.result.SourceRank == source_rank,
        skill_id .. " source toggle identity drifted"
    )
    return result.result
end

--[[
Turns off one reviewed source stance.

Args:
    bridge (BindableFunction): Live Warhowl bridge.
    player (Player): Actual Warhowl.
    skill_id (string): Creative toggle identifier.

Returns:
    nil: Confirms the source stance becomes inactive.
]]
local function toggle_off(bridge, player, skill_id)
    local result = bridge:Invoke("toggle", {
        UserId = player.UserId,
        SkillId = skill_id,
    })
    assert(result.ok, tostring(result.reason))
    assert(
        result.result.Active == false,
        skill_id .. " did not deactivate"
    )
end

--[[
Exercises Precision, Predator and inherited Orc Relax toggles.

Args:
    bridge (BindableFunction): Live Warhowl bridge.
    player (Player): Actual Warhowl.

Returns:
    nil: Confirms all reviewed toggles activate and rollback in Play.
]]
local function rehearse_toggles(bridge, player)
    toggle_on(
        bridge,
        player,
        "WarhowlPrecisionStance",
        256,
        1
    )
    toggle_on(
        bridge,
        player,
        "WarhowlPredatorStance",
        312,
        3
    )
    toggle_off(bridge, player, "WarhowlPrecisionStance")
    toggle_off(bridge, player, "WarhowlPredatorStance")

    local humanoid =
        assert(player.Character:FindFirstChildOfClass("Humanoid"))
    humanoid.Sit = false
    humanoid.Health = math.max(1, humanoid.MaxHealth - 100)

    local relax = toggle_on(
        bridge,
        player,
        "OrcRelax",
        226,
        1
    )
    assert(
        relax.UpkeepKind == "Relax"
            and humanoid.Sit,
        "inherited Orc Relax did not force the live owner to sit"
    )
    toggle_off(bridge, player, "OrcRelax")

    print(
        "[Warhowl Live] TOGGLE_PASS "
            .. "precision_predator_relax=true"
    )
end

--[[
Runs the unpublished Warhowl Play rehearsal.

Args:
    None.

Returns:
    nil: Ends only after physical, self-effect, toggle and rollback pass.
]]
local function run()
    print("[Warhowl Live] RUN_START")

    local player = admitted_player()
    local character = warhowl_character(player.UserId)
    local enemies = {
        rehearsal_enemy(
            player,
            "TEMP_WarhowlMarauderA",
            Vector3.new(0, 0, -6)
        ),
        rehearsal_enemy(
            player,
            "TEMP_WarhowlMarauderB",
            Vector3.new(4, 0, -7)
        ),
    }

    Runtime.set_character(player.UserId, character)

    local boundary, reason =
        Runtime.get_c4_resource_migration_boundary(
            player.UserId
        )
    assert(
        boundary
            and reason == nil
            and boundary.ScopeId == "OrcRaider"
            and boundary.SourceBaseMaxHealth == 1269
            and boundary.SourceBaseMaxMana == 327
            and boundary.SourceBaseMaxCP == 884
            and boundary.CutoverPrerequisitesReady,
        "Warhowl source boundary is not live-rehearsal ready"
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
        "Warhowl source cutover failed"
    )

    local cast_enabled = bridge:Invoke("enable_casts")
    assert(
        cast_enabled.ok
            and cast_enabled.capability.PhysicalCastCurrentlyEnabled
            and cast_enabled.capability.SelfEffectCurrentlyEnabled
            and cast_enabled.capability.SourceToggleCurrentlyEnabled,
        "Warhowl source bridges did not enable"
    )

    rehearse_physical_skills(
        bridge,
        player,
        character,
        enemies
    )
    rehearse_self_effects(bridge, player)
    rehearse_toggles(bridge, player)

    bridge:Invoke("disable_casts")
    local disabled = cutover:Invoke("disable")
    assert(
        disabled.ok and not disabled.snapshot.Enabled,
        "Warhowl source cutover rollback failed"
    )

    bridge:Invoke("clear_owner", {
        UserId = player.UserId,
    })
    Runtime.clear_character(player.UserId)

    for _, enemy in ipairs(enemies) do
        if enemy.Parent then
            enemy:Destroy()
        end
    end

    print(
        "[Warhowl Live] "
            .. "PHYSICAL_SELF_TOGGLE_ROLLBACK_PASS"
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
        warn("[Warhowl Live] FAIL " .. tostring(reason))
    end

    StudioTestService:EndTest(
        if ok then "PASS" else "FAIL " .. tostring(reason)
    )
end)

task.delay(TEST_TIMEOUT, function()
    StudioTestService:EndTest(
        "FAIL Warhowl live global timeout"
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
    assert(tests, "Warhowl live Dungeon tests folder missing")

    for _, name in ipairs({
        "DungeonOptionalDepthPhysicalLayoutTest",
        "DungeonLateEventPhysicalLayoutTest",
    }) do
        local script_instance = tests:FindFirstChild(name)
        assert(
            script_instance and script_instance:IsA("Script"),
            "Warhowl regression script missing: " .. name
        )
        script_instance.Disabled = true
    end
end

disable_conflicting_regressions()

local ok, result = pcall(function()
    return StudioTestService:ExecutePlayModeAsync(
        "TEMP_C4WarhowlLive"
    )
end)

driver:Destroy()

assert(
    ok and result == "PASS",
    "Warhowl live rehearsal failed: " .. tostring(result)
)

print("[Warhowl Live] VERIFIED_PLAY_MODE_PASS")

return true
