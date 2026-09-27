--!strict
-- Unpublished Play rehearsal for Ashspeaker / Orc Shaman level-30 combat.

assert(
    game.PlaceId == 0 and game.GameId == 0,
    "Ashspeaker live rehearsal requires an unpublished local place"
)

print("[Ashspeaker Live] EDIT_START")

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
        "Ashspeaker live runtime anchor missing"
    )

    assert(
        not string.find(source, original, first + #original, true),
        "Ashspeaker live runtime anchor is ambiguous"
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
    local name = "C4AshspeakerLiveBridge_TEMP"
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

    local function cast_result(result, reason)
        return {
            ok = result ~= nil,
            reason = reason,
            result = result,
        }
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
            cast_runtime.DirectMagic:set_enabled(true)
            cast_runtime.SupportMagic:set_enabled(true)
            cast_runtime.PeriodicMagic:set_enabled(true)
            cast_runtime.SourceToggle:set_enabled(true)
            return {
                ok = true,
                capability = cast_runtime:capability(),
            }
        end

        if action == "disable_casts" then
            cast_runtime.PhysicalCast:set_enabled(false)
            cast_runtime.DirectMagic:set_enabled(false)
            cast_runtime.SupportMagic:set_enabled(false)
            cast_runtime.PeriodicMagic:set_enabled(false)
            cast_runtime.SourceToggle:set_enabled(false)
            return {ok = true}
        end

        local player = player_from_payload(payload)
        if not player then
            return {
                ok = false,
                reason = "C4AshspeakerPlayerUnavailable",
            }
        end

        if action == "begin_physical" then
            return cast_result(
                cast_runtime.PhysicalCast:begin_cast(
                    player,
                    payload.Target,
                    payload.SkillId,
                    nil
                )
            )
        end

        if action == "launch_physical" then
            return cast_result(
                cast_runtime.PhysicalCast:launch_if_ready(
                    player,
                    payload.CastId,
                    nil,
                    payload.SequenceId
                )
            )
        end

        if action == "begin_direct" then
            return cast_result(
                cast_runtime.DirectMagic:begin_cast(
                    player,
                    payload.Target,
                    payload.SkillId,
                    nil
                )
            )
        end

        if action == "launch_direct" then
            return cast_result(
                cast_runtime.DirectMagic:launch_if_ready(
                    player,
                    payload.CastId,
                    nil,
                    payload.SequenceId
                )
            )
        end

        if action == "begin_periodic" then
            return cast_result(
                cast_runtime.PeriodicMagic:begin_cast(
                    player,
                    payload.Target,
                    payload.SkillId,
                    nil
                )
            )
        end

        if action == "launch_periodic" then
            return cast_result(
                cast_runtime.PeriodicMagic:launch_if_ready(
                    player,
                    payload.CastId,
                    nil,
                    payload.SequenceId
                )
            )
        end

        if action == "begin_support" then
            return cast_result(
                cast_runtime.SupportMagic:begin_cast(
                    player,
                    payload.Target,
                    payload.SkillId,
                    nil
                )
            )
        end

        if action == "launch_support" then
            return cast_result(
                cast_runtime.SupportMagic:launch_if_ready(
                    player,
                    payload.CastId,
                    nil
                )
            )
        end

        if action == "toggle" then
            return cast_result(
                cast_runtime.SourceToggle:toggle(
                    player,
                    payload.SkillId
                )
            )
        end

        if action == "clear_owner" then
            cast_runtime:clear_owner(player)
            return {ok = true}
        end

        return {
            ok = false,
            reason = "UnknownC4AshspeakerLiveAction",
        }
    end
end

ProficiencyService.bind_default(runtime.ProficiencyService)
]==]

replace_once(bridge_anchor, bridge_replacement)
print("[Ashspeaker Live] EDIT_PATCHED")

Workspace:SetAttribute("DungeonMMOStudioDungeonId", "TestDungeon")
Workspace:SetAttribute("DungeonMMOEnvironmentMode", "Synthetic")
Workspace:SetAttribute("DungeonMMOStudioBaseClass", "Mage")
Workspace:SetAttribute(
    "DungeonMMOPlaceholderPhysicalContentEnabled",
    true
)
Workspace:SetAttribute(
    "DungeonMMOPlaceholderPlayableEnabled",
    true
)

local driver = Instance.new("Script")
driver.Name = "C4AshspeakerLiveServer_TEMP"
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
local LIVE_BRIDGE = "C4AshspeakerLiveBridge_TEMP"
local TEST_TIMEOUT = 150

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

    error("[Ashspeaker Live] TIMEOUT " .. label)
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
Adds exact inherited Orc Mystic ranks through level 19.

Args:
    character (any): Mutable Ashspeaker character fixture.

Returns:
    nil: Adds authenticated class-49 inheritance.
]]
local function own_orc_mystic_skills(character)
    local skills = {
        {"OrcMysticMovement", 1},
        {"OrcMysticToughness", 1},
        {"OrcMysticArcaneResistance", 4},
        {"OrcMysticSpellcraft", 1},
        {"OrcMysticLucky", 1},
        {"OrcMysticManaRecovery", 1},
        {"OrcMysticWeaponTraining", 2},
        {"OrcMysticRobeTraining", 4},
        {"OrcMysticLightArmorTraining", 4},
        {"OrcMysticHeavyArmorTraining", 2},
        {"OrcMysticSoulCry", 2},
        {"OrcMysticBattleChant", 1},
        {"OrcMysticSoulShield", 1},
        {"OrcMysticLifeDrain", 2},
        {"OrcMysticFear", 1},
        {"OrcMysticVenom", 2},
        {"OrcMysticDreamingSpirit", 2},
        {"OrcMysticChillFlame", 2},
        {"OrcMysticCommonCraft", 1},
    }

    for _, row in ipairs(skills) do
        own_skill(character, row[1], row[2])
    end
end

--[[
Adds every reviewed Ashspeaker family through level 30.

Args:
    character (any): Mutable Ashspeaker character fixture.

Returns:
    nil: Adds exact class-50 creative ranks.
]]
local function own_ashspeaker_skills(character)
    local skills = {
        {"AshspeakerSkullshock", 9},
        {"AshspeakerArcaneResistance", 6},
        {"AshspeakerQuickPrayer", 2},
        {"AshspeakerManaReservoir", 2},
        {"AshspeakerFastCasting", 1},
        {"AshspeakerManaRecovery", 1},
        {"AshspeakerWeaponTraining", 5},
        {"AshspeakerRobeTraining", 6},
        {"AshspeakerLightArmorTraining", 6},
        {"AshspeakerHeavyArmorTraining", 6},
        {"AshspeakerSoulCry", 1},
        {"AshspeakerFlameChant", 1},
        {"AshspeakerWarPower", 1},
        {"AshspeakerFireChant", 1},
        {"AshspeakerBattleChant", 1},
        {"AshspeakerShieldingChant", 2},
        {"AshspeakerSoulShield", 1},
        {"AshspeakerLifeDrain", 3},
        {"AshspeakerFear", 3},
        {"AshspeakerVenom", 1},
        {"AshspeakerChaosSeal", 1},
        {"AshspeakerDreamingSpirit", 3},
        {"AshspeakerBlazeQuake", 1},
        {"AshspeakerAuraSink", 1},
        {"AshspeakerMadness", 3},
        {"AshspeakerFrostFlame", 2},
        {"AshspeakerBindingSeal", 2},
        {"AshspeakerPoisonSeal", 2},
        {"AshspeakerLifeChant", 3},
    }

    for _, row in ipairs(skills) do
        own_skill(character, row[1], row[2])
    end
end

--[[
Builds an authentic level-30 Ashspeaker first-transfer state.

Args:
    user_id (number): Actual connected Studio player ID.

Returns:
    any: Disposable Ashspeaker progression state.
]]
local function ashspeaker_character(user_id)
    local character =
        ProfileSchema.create_default(user_id).Characters.Slot1
    local quest = assert(QuestStages.get("OrcShaman"))
    local proofs = {}

    for _, proof_id in ipairs(quest.RequiredProofIds) do
        proofs[proof_id] = true
    end

    character.Level = 30
    character.Identity = {
        Version = 1,
        RaceId = "Orc",
        BaseClassId = "Mage",
        ClassId = "Ashspeaker",
        CreationStage = "Complete",
    }
    character.ClassAdvancement = {
        Version = 1,
        OriginalFirstTransferChoiceId = "OrcShaman",
        OriginalFirstTransferClassId = "Ashspeaker",
        OriginalFirstTransferReceiptId = "TEMP_AshspeakerLive",
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
    character.ProfessionSlots.Creation = "Blacksmithing"
    character.Equipment.Weapon = "stonewatch_training_mace"

    own_orc_mystic_skills(character)
    own_ashspeaker_skills(character)
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
    enemy:SetAttribute(
        "DungeonEncounterId",
        player.Character:GetAttribute("DungeonEncounterId")
    )

    local root = Instance.new("Part")
    root.Name = "HumanoidRootPart"
    root.Anchored = true
    root.CanCollide = false
    root.CFrame = player_root.CFrame * CFrame.new(offset)
    root.Parent = enemy

    local humanoid = Instance.new("Humanoid")
    humanoid.MaxHealth = 9000
    humanoid.Health = 9000
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
Begins and launches one target-bound bridge action.

Args:
    bridge (BindableFunction): Ashspeaker live bridge.
    player (Player): Actual source owner.
    enemy (Model?): Optional reviewed target.
    family (string): Bridge family suffix.
    skill_id (string): Creative skill identifier.
    sequence_id (number?): Trusted combat sequence.

Returns:
    (any, any): Start and launched bridge results.
]]
local function cast(
    bridge,
    player,
    enemy,
    family,
    skill_id,
    sequence_id
)
    if typeof(enemy) == "Instance"
        and enemy:IsA("Model")
    then
        face_enemy(player, enemy)
    end

    local started = bridge:Invoke("begin_" .. family, {
        UserId = player.UserId,
        Target = enemy,
        SkillId = skill_id,
    })
    assert(started.ok, skill_id .. ": " .. tostring(started.reason))

    wait_for_launch(started.result.LaunchAt)

    local launched = bridge:Invoke("launch_" .. family, {
        UserId = player.UserId,
        CastId = started.result.CastId,
        SequenceId = sequence_id,
    })
    assert(launched.ok, skill_id .. ": " .. tostring(launched.reason))

    return started.result, launched.result
end

--[[
Exercises inherited magic plus Ashspeaker physical and hostile magic.

Args:
    bridge (BindableFunction): Live Ashspeaker bridge.
    player (Player): Actual Ashspeaker.
    enemies ({Model}): Nearby reviewed targets.

Returns:
    nil: Confirms inherited, stun, drain and fear authority.
]]
local function rehearse_core_combat(bridge, player, enemies)
    local _, inherited = cast(
        bridge,
        player,
        enemies[1],
        "direct",
        "OrcMysticLifeDrain",
        7101
    )
    assert(
        inherited.Application.Kind == "C4LiveNpcMagicDrain",
        "inherited Orc Mystic Life Drain left live authority"
    )

    local physical_start, skullshock = cast(
        bridge,
        player,
        enemies[1],
        "physical",
        "AshspeakerSkullshock",
        7102
    )
    assert(
        physical_start.SourceSkillId == 100
            and physical_start.SourceRank == 9
            and skullshock.Application.Kind
                == "C4LiveNpcPhysicalStunSkill",
        "Ashspeaker Skullshock source stun contract drifted"
    )

    local drain_start, drain = cast(
        bridge,
        player,
        enemies[1],
        "direct",
        "AshspeakerLifeDrain",
        7103
    )
    assert(
        drain_start.SourceSkillId == 1090
            and drain_start.SourceRank == 5
            and drain.Application.Kind == "C4LiveNpcMagicDrain",
        "Ashspeaker Life Drain source contract drifted"
    )

    local fear_start, fear = cast(
        bridge,
        player,
        enemies[1],
        "direct",
        "AshspeakerFear",
        7104
    )
    assert(
        fear_start.SourceSkillId == 1092
            and fear_start.SourceRank == 4
            and fear.Application.Kind == "C4LiveNpcFear"
            and type(fear.Application.Landed) == "boolean",
        "Ashspeaker Fear did not reach live fear authority"
    )

    print(
        "[Ashspeaker Live] CORE_COMBAT_PASS "
            .. "inherit_stun_drain_fear=true"
    )
end

--[[
Exercises caster-centred Root and accuracy seal auras.

Args:
    bridge (BindableFunction): Live Ashspeaker bridge.
    player (Player): Actual Ashspeaker.

Returns:
    nil: Confirms both seal families collect live nearby NPCs.
]]
local function rehearse_seals(bridge, player)
    local binding_start, binding = cast(
        bridge,
        player,
        nil,
        "direct",
        "AshspeakerBindingSeal",
        7110
    )
    assert(
        binding_start.SourceSkillId == 1208
            and binding_start.SourceRank == 2
            and binding.Application.Kind == "C4LiveNpcRootAura"
            and binding.Application.TargetCount >= 1,
        "Binding Seal left caster-centred Root Aura authority"
    )

    local chaos_start, chaos = cast(
        bridge,
        player,
        nil,
        "direct",
        "AshspeakerChaosSeal",
        7111
    )
    assert(
        chaos_start.SourceSkillId == 1096
            and chaos_start.SourceRank == 1
            and chaos.Application.Kind == "C4LiveNpcAccuracyAura"
            and chaos.Application.TargetCount >= 1,
        "Chaos Seal left caster-centred accuracy aura authority"
    )

    print(
        "[Ashspeaker Live] SEAL_PASS "
            .. "root_accuracy_aura=true"
    )
end

--[[
Exercises one exact Ashspeaker poison family.

Args:
    bridge (BindableFunction): Live Ashspeaker bridge.
    player (Player): Actual Ashspeaker.
    enemy (Model): Reviewed NPC target.

Returns:
    nil: Confirms periodic status resolution uses source authority.
]]
local function rehearse_periodic(bridge, player, enemy)
    local started, venom = cast(
        bridge,
        player,
        enemy,
        "periodic",
        "AshspeakerVenom",
        7120
    )
    assert(
        started.SourceSkillId == 1095
            and started.SourceRank == 3
            and venom.StatusResolved
            and type(venom.Landed) == "boolean",
        "Ashspeaker Venom left periodic source authority"
    )

    print("[Ashspeaker Live] PERIODIC_PASS venom=true")
end

--[[
Exercises target and party support plus regeneration.

Args:
    bridge (BindableFunction): Live Ashspeaker bridge.
    player (Player): Actual Ashspeaker.

Returns:
    nil: Confirms support routes execute through server roster authority.
]]
local function rehearse_support(bridge, player)
    local shield_start, shield = cast(
        bridge,
        player,
        player,
        "support",
        "AshspeakerSoulShield",
        nil
    )
    assert(
        shield_start.SourceSkillId == 1010
            and shield_start.SourceRank == 2
            and shield.Application.Applied,
        "Ashspeaker Soul Shield left target-buff authority"
    )

    local flame_start, flame = cast(
        bridge,
        player,
        nil,
        "support",
        "AshspeakerFlameChant",
        nil
    )
    assert(
        flame_start.SourceSkillId == 1002
            and flame.Application.Applied
            and flame.Application.AffectedPlayers >= 1,
        "Ashspeaker Flame Chant left party-buff authority"
    )

    local life_start, life = cast(
        bridge,
        player,
        nil,
        "support",
        "AshspeakerLifeChant",
        nil
    )
    assert(
        life_start.SourceSkillId == 1229
            and life_start.SourceRank == 3
            and life.Application.Applied
            and life.Application.Scheduled
            and life.Application.AffectedPlayers >= 1,
        "Ashspeaker Life Chant left party regeneration authority"
    )

    print(
        "[Ashspeaker Live] SUPPORT_PASS "
            .. "shield_chant_regen=true"
    )
end

--[[
Exercises exact Ashspeaker Soul Cry toggle activation and rollback.

Args:
    bridge (BindableFunction): Live Ashspeaker bridge.
    player (Player): Actual Ashspeaker.

Returns:
    nil: Confirms source toggle identity and clean deactivation.
]]
local function rehearse_soul_cry(bridge, player)
    local enabled = bridge:Invoke("toggle", {
        UserId = player.UserId,
        SkillId = "AshspeakerSoulCry",
    })
    assert(
        enabled.ok
            and enabled.result.Active
            and enabled.result.SourceSkillId == 1001
            and enabled.result.SourceRank == 3,
        "Ashspeaker Soul Cry did not activate exact source toggle"
    )

    local disabled = bridge:Invoke("toggle", {
        UserId = player.UserId,
        SkillId = "AshspeakerSoulCry",
    })
    assert(
        disabled.ok and disabled.result.Active == false,
        "Ashspeaker Soul Cry did not deactivate cleanly"
    )

    print("[Ashspeaker Live] TOGGLE_PASS soul_cry=true")
end

--[[
Runs the unpublished Ashspeaker Play rehearsal.

Args:
    None.

Returns:
    nil: Ends after combat, support, toggle and rollback all pass.
]]
local function run()
    print("[Ashspeaker Live] RUN_START")

    local player = admitted_player()
    local character = ashspeaker_character(player.UserId)
    local enemies = {
        rehearsal_enemy(
            player,
            "TEMP_AshspeakerMarauderA",
            Vector3.new(0, 0, -6)
        ),
        rehearsal_enemy(
            player,
            "TEMP_AshspeakerMarauderB",
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
            and boundary.ScopeId == "OrcShaman"
            and boundary.SourceBaseMaxHealth == 869
            and boundary.SourceBaseMaxMana == 504
            and boundary.SourceBaseMaxCP == 436
            and boundary.CutoverPrerequisitesReady,
        "Ashspeaker source boundary is not live-rehearsal ready"
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
        "Ashspeaker source cutover failed"
    )

    local cast_enabled = bridge:Invoke("enable_casts")
    local capability = cast_enabled.capability
    assert(
        cast_enabled.ok
            and capability.PhysicalCastCurrentlyEnabled
            and capability.DirectMagicCurrentlyEnabled
            and capability.SupportMagicCurrentlyEnabled
            and capability.PeriodicMagicCurrentlyEnabled
            and capability.SourceToggleCurrentlyEnabled,
        "Ashspeaker source bridges did not enable"
    )

    rehearse_core_combat(bridge, player, enemies)
    rehearse_seals(bridge, player)
    rehearse_periodic(bridge, player, enemies[1])
    rehearse_support(bridge, player)
    rehearse_soul_cry(bridge, player)

    bridge:Invoke("disable_casts")
    local disabled = cutover:Invoke("disable")
    assert(
        disabled.ok and not disabled.snapshot.Enabled,
        "Ashspeaker source cutover rollback failed"
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
        "[Ashspeaker Live] "
            .. "COMBAT_SUPPORT_AURA_TOGGLE_ROLLBACK_PASS"
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
        warn("[Ashspeaker Live] FAIL " .. tostring(reason))
    end

    StudioTestService:EndTest(
        if ok then "PASS" else "FAIL " .. tostring(reason)
    )
end)

task.delay(TEST_TIMEOUT, function()
    StudioTestService:EndTest(
        "FAIL Ashspeaker live global timeout"
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
    assert(tests, "Ashspeaker live Dungeon tests folder missing")

    for _, name in ipairs({
        "DungeonOptionalDepthPhysicalLayoutTest",
        "DungeonLateEventPhysicalLayoutTest",
    }) do
        local script_instance = tests:FindFirstChild(name)
        assert(
            script_instance and script_instance:IsA("Script"),
            "Ashspeaker regression script missing: " .. name
        )
        script_instance.Disabled = true
    end
end

disable_conflicting_regressions()

local ok, result = pcall(function()
    return StudioTestService:ExecutePlayModeAsync(
        "TEMP_C4AshspeakerLive"
    )
end)

driver:Destroy()

assert(
    ok and result == "PASS",
    "Ashspeaker live rehearsal failed: " .. tostring(result)
)

print("[Ashspeaker Live] VERIFIED_PLAY_MODE_PASS")

return true
