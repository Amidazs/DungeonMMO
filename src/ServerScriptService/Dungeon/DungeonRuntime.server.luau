--!strict
-- First real dungeon runtime: admission, two combat rooms, checkpoint, rewards, death/revive and wipe failure.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

Players.CharacterAutoLoads = false

local Core = ServerScriptService:WaitForChild("Core")
local Services = Core:WaitForChild("Services")
local Adapters = Core:WaitForChild("Adapters")
local Dungeon = ServerScriptService:WaitForChild("Dungeon")
local Combat = ServerScriptService:WaitForChild("Combat")
local SharedCore = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Shared")
local SharedCombat = ReplicatedStorage:WaitForChild("Combat"):WaitForChild("Shared")

local DungeonDefinitions = require(SharedCore:WaitForChild("DungeonDefinitions"))
local DungeonDifficultyDefinitions = require(
    SharedCore:WaitForChild("DungeonDifficultyDefinitions")
)
local DungeonModifierDefinitions = require(
    SharedCore:WaitForChild("DungeonModifierDefinitions")
)
local CharacterIdentityRules = require(
    SharedCore:WaitForChild("CharacterIdentityRules")
)
local CombatConfig = require(SharedCombat:WaitForChild("CombatConfig"))
local RuntimeServices = require(Services:WaitForChild("RuntimeServices"))
local DungeonDifficultyTuning = require(
    Services:WaitForChild("DungeonDifficultyTuning")
)
local ProgressionService = require(Services:WaitForChild("ProgressionService"))
local ProficiencyService = require(Services:WaitForChild("ProficiencyService"))
local ProfessionRuntime = require(Services:WaitForChild("ProfessionRuntime"))
local ProgressionRuntimeState = require(Services:WaitForChild("ProgressionRuntimeState"))
local RacePresentationService = require(
    Services:WaitForChild("RacePresentationService")
)
local ProgressionSnapshotBuilder = require(Services:WaitForChild("ProgressionSnapshotBuilder"))
local RevivePurchaseService = require(Services:WaitForChild("RevivePurchaseService"))
local RevivePurchaseRegistry = require(Services:WaitForChild("RevivePurchaseRegistry"))
local TeleportCoordinator = require(Services:WaitForChild("TeleportCoordinator"))
local RobloxTeleportAdapter = require(Adapters:WaitForChild("RobloxTeleportAdapter"))
local TestFailureSwitches = require(Core:WaitForChild("TestFailureSwitches"))
local DungeonAdmissionRules = require(Dungeon:WaitForChild("DungeonAdmissionRules"))
local StudioSessionFactory = require(Dungeon:WaitForChild("StudioSessionFactory"))
local EncounterService = require(Dungeon:WaitForChild("EncounterService"))
local CheckpointService = require(Dungeon:WaitForChild("CheckpointService"))
local DungeonRecoveryRules = require(Dungeon:WaitForChild("DungeonRecoveryRules"))
local DungeonEncounterRuntimeState = require(
    Dungeon:WaitForChild("DungeonEncounterRuntimeState")
)
local DungeonEncounterRuntimeController = require(
    Dungeon:WaitForChild("DungeonEncounterRuntimeController")
)
local DungeonSecretDiscoveryService = require(
    Services:WaitForChild("DungeonSecretDiscoveryService")
)
local DungeonOptionalBossPolicy = require(
    Dungeon:WaitForChild("DungeonOptionalBossPolicy")
)
local DungeonOptionalBossContent = require(
    Dungeon:WaitForChild("DungeonOptionalBossContent")
)
local DungeonRoomLayoutDefinitions = require(
    Dungeon:WaitForChild("DungeonRoomLayoutDefinitions")
)
local DungeonEncounterBindings = require(
    Dungeon:WaitForChild("DungeonEncounterBindings")
)
local DungeonEncounterFlow = require(
    Dungeon:WaitForChild("DungeonEncounterFlow")
)
local DungeonEncounterRecovery = require(
    Dungeon:WaitForChild("DungeonEncounterRecovery")
)
local DungeonProgressionBridge = require(Dungeon:WaitForChild("DungeonProgressionBridge"))
local DungeonContributionBridge = require(
    Dungeon:WaitForChild("DungeonContributionBridge")
)
local DungeonDeathService = require(
    Dungeon:WaitForChild("DungeonDeathService")
)
local DungeonDeathPresentation = require(
    Dungeon:WaitForChild("DungeonDeathPresentation")
)
local DungeonEnemyCleanup = require(Dungeon:WaitForChild("DungeonEnemyCleanup"))
local DungeonEncounterExecutionBootstrap = require(
    Dungeon:WaitForChild("DungeonEncounterExecutionBootstrap")
)
local DungeonEncounterExecutionController = require(
    Dungeon:WaitForChild("DungeonEncounterExecutionController")
)
local CompletionEligibilityRules = require(Dungeon:WaitForChild("CompletionEligibilityRules"))
local CompletionService = require(Dungeon:WaitForChild("CompletionService"))
local ReturnPortalService = require(Dungeon:WaitForChild("ReturnPortalService"))
local DungeonReplayService = require(Dungeon:WaitForChild("DungeonReplayService"))
local DungeonStudioEquipmentBootstrap = require(
    Dungeon:WaitForChild("DungeonStudioEquipmentBootstrap")
)
local DungeonRuntimeSelection = require(Dungeon:WaitForChild("DungeonRuntimeSelection"))
local DungeonEnvironmentRouter = require(
    Dungeon:WaitForChild("DungeonEnvironmentRouter")
)
local DungeonEncounterEnvironmentRuntime = require(
    Dungeon:WaitForChild("DungeonEncounterEnvironmentRuntime")
)
local DungeonOptionalEntranceGates = require(
    Dungeon:WaitForChild("DungeonOptionalEntranceGates")
)

local remotes = ReplicatedStorage:WaitForChild("Core"):WaitForChild("Remotes")
local dungeon_state = remotes:WaitForChild("DungeonStateChanged") :: RemoteEvent
local revive_request = remotes:WaitForChild("ReviveRequest") :: RemoteEvent
local revive_state = remotes:WaitForChild("ReviveStateChanged") :: RemoteEvent
local profile_snapshot = remotes:WaitForChild("ProfileSnapshot") :: RemoteEvent
local inventory_snapshot = remotes:WaitForChild("InventorySnapshot") :: RemoteEvent
local equipment_snapshot = remotes:WaitForChild("EquipmentSnapshot") :: RemoteEvent
local progression_snapshot = remotes:WaitForChild("ProgressionSnapshot") :: RemoteEvent
local progression_action_result = remotes:WaitForChild("ProgressionActionResult") :: RemoteEvent
local loadout_request = remotes:WaitForChild("LoadoutRequest") :: RemoteEvent
local return_request = remotes:WaitForChild("ReturnRequest") :: RemoteEvent

local runtime = RuntimeServices.new("Dungeon")
ProgressionService.bind_default(runtime.ProgressionService)
ProficiencyService.bind_default(runtime.ProficiencyService)
DungeonContributionBridge.bind_service(
    runtime.ContributionService
)
local profiles = runtime.ProfileService
local leases = runtime.LeaseService
local sessions = runtime.SessionService
local secret_discovery = DungeonSecretDiscoveryService.new(sessions)
local rewards = runtime.RewardService
local proficiency = runtime.ProficiencyService
local inventory = runtime.InventoryService
local attributes = runtime.AttributeService
local loadout = runtime.LoadoutService
local skills = runtime.SkillProgressionService
local identity = runtime.IdentityService
local equipment = runtime.EquipmentService
local professions = runtime.ProfessionService
local quests = runtime.QuestService

local active_dungeon_id, active_dungeon_error = DungeonRuntimeSelection.resolve(Players, Workspace, RunService, DungeonDefinitions, 15)
assert(active_dungeon_id ~= nil, "Dungeon selection failed: " .. tostring(active_dungeon_error))
local active_definition = assert(DungeonDefinitions.get(active_dungeon_id :: string), "Selected dungeon definition missing")
local environment = DungeonEnvironmentRouter.wait_for_ready(
    Workspace,
    active_definition.Id,
    15
)
assert(
    environment.ok,
    "Dungeon environment invalid: "
        .. tostring(environment.reason)
)

local resolved_difficulty_id = Workspace:GetAttribute(
    "DungeonMMOResolvedDifficultyId"
)
assert(
    type(resolved_difficulty_id) == "string"
        and resolved_difficulty_id ~= "",
    "Resolved dungeon difficulty is missing."
)

local runtime_root = Instance.new("Folder")
runtime_root.Name = "DungeonGameplayRuntime"
runtime_root.Parent = Workspace

local enemies_folder = Instance.new("Folder")
enemies_folder.Name = "DungeonEnemies"
enemies_folder.Parent = runtime_root

local active_session_id: string? = nil
local encounter_service: any = nil
local encounter_runtime_controller: any = nil
local encounter_execution_controller: any = nil
local active_execution: any = nil
local replay_service: any = nil
local encounter_flow: any = nil
local encounter_bindings: any = nil
local checkpoint_service: any = nil
local death_service: any = nil
local purchase_service: any = nil
local completion_service: any = nil
local return_service: any = nil
local force_return_failure = TestFailureSwitches.is_enabled(
    TestFailureSwitches.RETURN_ATTRIBUTE
)
local coordinator = TeleportCoordinator.new(
    RobloxTeleportAdapter.new({
        force_teleport_failure = force_return_failure,
        failure_reason = "TEST_ForcedReturnTeleportFailure",
    }),
    profiles,
    leases,
    sessions
)
if force_return_failure then
    warn("[TEST Failure Injection] Return-to-Base teleports are forced to fail.")
end
local loaded_users: {[number]: boolean} = {}
local bound_characters: {[Model]: boolean} = {}
local completion_pending = false
local completion_committed = false
local next_completion_retry_at = 0
local current_encounter_id = ""
local encounter_triggers_bound = false
local AUTOSAVE_SECONDS = 30
local LEASE_RENEW_SECONDS = 15
local SESSION_REFRESH_SECONDS = 30

local function current_session(): any?
    return if active_session_id then sessions:get(active_session_id) else nil
end

-- Returns the authoritative base encounter sequence for the admitted session.
local function base_encounter_sequence(session: any): {any}?
    local instance_state = session
        and session.InstanceState
    if type(instance_state) == "table"
        and type(instance_state.EncounterSequence) == "table"
        and #instance_state.EncounterSequence > 0
    then
        return instance_state.EncounterSequence
    end

    local difficulty_id = session
        and session.Difficulty
        and session.Difficulty.Id
    local difficulty = DungeonDifficultyDefinitions.resolve(
        active_definition.Id,
        if type(difficulty_id) == "string"
            then difficulty_id
            else nil
    )
    return difficulty and difficulty.EncounterSequence or nil
end

-- Admits only explicitly enabled, physically registered optional bosses.
local function optional_encounter_definitions(session: any): any
    local state = session.InstanceState
    local enabled = active_definition.OptionalBossRuntimeEnabled == true
        and type(state) == "table"
        and state.OptionalBossEnabled == true

    if not enabled then
        return DungeonOptionalBossPolicy.evaluate(
            active_definition, "", nil, false
        )
    end

    local difficulty_id = session.Difficulty
        and session.Difficulty.Id
    if type(difficulty_id) ~= "string"
        and type(state.DifficultyId) == "string"
    then
        difficulty_id = state.DifficultyId
    end
    local difficulty = DungeonDifficultyDefinitions.resolve(
        active_definition.Id, difficulty_id
    )
    local layout = difficulty
        and DungeonRoomLayoutDefinitions.get(
            active_definition.Id, difficulty.LayoutId
        )
    local allowed_slots = {}
    if layout and type(layout.Slots) == "table" then
        for slot_id, slot in pairs(layout.Slots) do
            allowed_slots[slot_id] = slot
        end
    end
    local optional = DungeonOptionalBossContent.for_difficulty(
        active_definition.Id, difficulty_id, state
    )
    return DungeonOptionalBossPolicy.evaluate(
        {OptionalEncounters = optional},
        difficulty_id,
        allowed_slots,
        enabled,
        state
    )
end

local LEGACY_CHECKPOINT_SLOTS = table.freeze({
    Room1Start = "Room1",
    Room2Start = "Room2",
    BossRoomStart = "Room3",
})

-- Returns the authoritative difficulty definition for one session.
local function session_difficulty_definition(
    session: any
): any?
    local difficulty_id = session
        and session.Difficulty
        and session.Difficulty.Id
    if type(difficulty_id) ~= "string"
        and type(session) == "table"
        and type(session.InstanceState) == "table"
    then
        difficulty_id = session.InstanceState.DifficultyId
    end

    return DungeonDifficultyDefinitions.resolve(
        active_definition.Id,
        if type(difficulty_id) == "string"
            then difficulty_id
            else nil
    )
end

-- Returns the currently persisted checkpoint ID, defaulting to Entrance.
local function persisted_checkpoint_id(session: any): string
    if type(session) == "table"
        and type(session.Checkpoint) == "table"
        and type(session.Checkpoint.Id) == "string"
    then
        return session.Checkpoint.Id
    end
    return "Entrance"
end

-- Creates one generic encounter controller over the session's frozen plan.
local function create_encounter_controller(
    session: any,
    base_sequence: {any}
): (any?, string?)
    local optional = optional_encounter_definitions(session)
    if optional.ok ~= true then
        return nil, optional.reason or "OptionalBossPolicyRejected"
    end
    return DungeonEncounterRuntimeController.new({
        session_service = sessions,
        session_id = session.SessionId,
        base_sequence = base_sequence,
        optional_encounters = optional.encounters,
    })
end

-- Initializes generic encounter authority against the selected physical layout.
local function initialize_encounter_runtime(
    session: any
): any
    local base_sequence = base_encounter_sequence(session)
    if not base_sequence then
        return {
            ok = false,
            reason = "EncounterSequenceMissing",
        }
    end

    local difficulty = session_difficulty_definition(session)
    if not difficulty
        or type(difficulty.LayoutId) ~= "string"
    then
        return {
            ok = false,
            reason = "DungeonLayoutIdMissing",
        }
    end

    local controller, controller_error =
        create_encounter_controller(session, base_sequence)
    if not controller then
        return {
            ok = false,
            reason = controller_error
                or "EncounterRuntimeCreationFailed",
        }
    end

    local bindings = DungeonEncounterBindings.resolve(
        active_definition.Id,
        difficulty.LayoutId,
        controller:encounters(),
        environment
    )
    if bindings.ok ~= true then
        return bindings
    end

    local latest = sessions:get(session.SessionId)
    if DungeonEncounterRuntimeState.from_session(latest) == nil then
        local recovery_snapshot =
            DungeonEncounterRecovery.snapshot_from_checkpoint(
                bindings,
                persisted_checkpoint_id(session),
                LEGACY_CHECKPOINT_SLOTS
            )
        if not recovery_snapshot then
            return {
                ok = false,
                reason = "EncounterRecoveryMigrationFailed",
            }
        end

        local persisted = DungeonEncounterRuntimeState.persist(
            sessions,
            session.SessionId,
            recovery_snapshot
        )
        if persisted.ok ~= true then
            return persisted
        end

        controller, controller_error =
            create_encounter_controller(session, base_sequence)
        if not controller then
            return {
                ok = false,
                reason = controller_error
                    or "EncounterRuntimeReloadFailed",
            }
        end
    end

    encounter_runtime_controller = controller
    encounter_bindings = bindings
    encounter_flow = DungeonEncounterFlow.new(
        controller,
        bindings
    )
    return {
        ok = true,
        reason = nil,
    }
end

local function send_objective(text: string, state_name: string?)
    for _, player in ipairs(Players:GetPlayers()) do
        if loaded_users[player.UserId] then
            dungeon_state:FireClient(player, {
                state = state_name or "Active",
                objective = text,
                session_id = active_session_id,
                encounter_id = current_encounter_id,
            })
        end
    end
    print("[Dungeon Runtime] " .. text)
end

local function build_progression_snapshot(user_id: number): any
    local c = profiles:get_character(user_id, 1)
    return ProgressionSnapshotBuilder.build(c)
end

local function send_progression(player: Player)
    progression_snapshot:FireClient(player, build_progression_snapshot(player.UserId))
end

runtime.ProgressionService:set_change_callback(function(user_id: number)
    local player = Players:GetPlayerByUserId(user_id)
    if player and loaded_users[user_id] then send_progression(player) end
end)

local function send_profile(player: Player)
    local character = profiles:get_character(player.UserId, 1)
    if not character then return end
    profile_snapshot:FireClient(player, {Slot = 1, Level = character.Level, XP = character.XP, Gold = character.Gold})
    inventory_snapshot:FireClient(player, character.Inventory)
    equipment_snapshot:FireClient(
        player,
        equipment:build_snapshot(player.UserId)
    )
    send_progression(player)
end

if active_definition.Id == active_definition.Id then
    ProfessionRuntime.attach({context="Dungeon",environment=environment,professions=professions,remotes=remotes,sessions=sessions,get_session_id=function():string? return active_session_id end,on_profile_changed=send_profile})
end

local function apply_race_presentation(
    player: Player,
    character_model: Model?
)
    local profile_character =
        profiles:get_character(
            player.UserId,
            1
        )

    local race_id =
        profile_character
        and profile_character.Identity
        and profile_character.Identity.RaceId
        or nil

    local target =
        character_model
        or player.Character

    if not target then
        return
    end

    local result =
        RacePresentationService.apply(
            target,
            race_id
        )

    if not result.ok
        and result.reason ~= "HeadNotFound"
    then
        warn(
            string.format(
                "[Dungeon Race Presentation] %s: %s",
                player.Name,
                tostring(result.reason)
            )
        )
    end
end


local function set_character_encounter(player: Player, encounter_id: string)
    local character = player.Character
    if character then
        character:SetAttribute(CombatConfig.TRAINING_MARAUDER.RUN_PARTICIPANT_ATTRIBUTE, true)
        character:SetAttribute(CombatConfig.TRAINING_MARAUDER.ENCOUNTER_ATTRIBUTE, encounter_id)
    end
end

local function sync_all_character_encounters(encounter_id: string)
    current_encounter_id = encounter_id
    for _, player in ipairs(Players:GetPlayers()) do
        if loaded_users[player.UserId] then
            set_character_encounter(player, encounter_id)
        end
    end
end

local function get_player_from_touch(hit: BasePart): Player?
    local character = hit:FindFirstAncestorOfClass("Model")
    if not character then return nil end
    local player = Players:GetPlayerFromCharacter(character)
    if not player or not loaded_users[player.UserId] then return nil end
    local session = current_session()
    if not session or session.State ~= "Active" then return nil end
    local member = session.Members[tostring(player.UserId)]
    if not member or member.Mode ~= "Active" then return nil end
    return player
end

local function active_modifier(): any?
    local session = current_session()
    local modifier_id = session
        and session.Modifier
        and session.Modifier.Id
    return if type(modifier_id) == "string"
        then DungeonModifierDefinitions.get(modifier_id)
        else nil
end

local function active_modifier_id(): string?
    local modifier = active_modifier()
    return if modifier then modifier.Id else nil
end

local function active_difficulty_tuning(): any
    local session = current_session()
    local difficulty_id = session
        and session.Difficulty
        and session.Difficulty.Id
    local tuning = DungeonDifficultyTuning.resolve(
        active_definition.Id,
        if type(difficulty_id) == "string"
            then difficulty_id
            else nil,
        active_modifier_id()
    )
    assert(
        tuning ~= nil,
        "Active dungeon difficulty tuning could not be resolved."
    )
    return tuning
end

local function member_user_ids(): {number}
    local result = {}
    local session = current_session()
    if not session then return result end
    for _, user_id in ipairs(session.MemberUserIds or {}) do
        table.insert(result, user_id)
    end
    return result
end

local function sync_encounter_members_from_session()
    local session = current_session()
    if not session or not encounter_service then return end
    for _, member in pairs(session.Members or {}) do
        encounter_service:mark_member_connected(member.UserId, member.Connected == true)
        encounter_service:mark_member_mode(member.UserId, member.Mode or "Active")
    end
end

local function active_instance_state(): any
    local session = current_session()
    return if session
        and type(session.InstanceState) == "table"
        then session.InstanceState
        else {}
end

-- Builds server-owned execution context for the current dungeon run.
local function encounter_execution_context(): any
    assert(
        active_session_id ~= nil,
        "Encounter execution requires an active session."
    )

    return {
        DungeonDefinition = active_definition,
        Tuning = active_difficulty_tuning(),
        InstanceState = active_instance_state(),
        Environment = environment,
        EnemiesFolder = enemies_folder,
        RuntimeRoot = runtime_root,
        SessionId = active_session_id,
    }
end

local function print_reward_result(result: any)
    if not result or not result.reward_result or not result.reward_result.member_results then return end
    for user_key, member_result in pairs(result.reward_result.member_results) do
        local user_id = tonumber(user_key)
        local player = if user_id then Players:GetPlayerByUserId(user_id) else nil
        if player then
            local saved, save_error = profiles:save(player.UserId, "MonsterReward")
            if not saved then
                warn(string.format("[Dungeon Runtime] Monster reward save failed for %s: %s", player.Name, tostring(save_error)))
            end
            send_profile(player)
            print(string.format(
                "[Dungeon Reward] %s +%d XP +%d Gold -> Level %d, %d XP carried.",
                player.Name,
                member_result.xp_granted or 0,
                member_result.gold_granted or 0,
                member_result.new_level or 1,
                member_result.carried_xp or 0
            ))
        end
    end
end

local function connected_member_user_ids(): {number}
    local ids = {}
    local session = current_session()
    if not session then return ids end
    for _, player in ipairs(Players:GetPlayers()) do
        local member = session.Members and session.Members[tostring(player.UserId)]
        if loaded_users[player.UserId] and member and member.Connected == true then
            table.insert(ids, player.UserId)
        end
    end
    table.sort(ids)
    return ids
end

local function connected_loaded_players(): {Player}
    local result = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if loaded_users[player.UserId] then table.insert(result, player) end
    end
    return result
end

local function send_boss_state(
    humanoid: Humanoid,
    boss_name: string,
    encounter_id: string
)
    for _, player in ipairs(Players:GetPlayers()) do
        if loaded_users[player.UserId] then
            dungeon_state:FireClient(player, {
                state = "Boss",
                objective = "Defeat " .. boss_name .. ".",
                session_id = active_session_id,
                encounter_id = encounter_id,
                boss_name = boss_name,
                boss_health = math.max(0, humanoid.Health),
                boss_max_health = humanoid.MaxHealth,
            })
        end
    end
end

local handle_run_cleared: (() -> ())? = nil

local function advance_checkpoint(checkpoint_id: string): boolean
    if not checkpoint_service or not active_session_id then
        return false
    end
    local advanced = checkpoint_service:activate(checkpoint_id)
    if not advanced.ok then
        warn(
            "[Dungeon Runtime] Checkpoint advance failed: "
                .. tostring(advanced.reason)
        )
        return false
    end
    return true
end

local function normal_start_rejection(reason: string?): boolean
    return reason == "EncounterAlreadyActive"
        or reason == "EncounterAlreadyCleared"
        or reason == "EncounterAlreadySkipped"
        or reason == "EncounterOutOfOrder"
        or reason == "AnotherEncounterActive"
end

local function connect_enemy(enemy: Model, encounter_id: string)
    local humanoid = enemy:WaitForChild("Humanoid") :: Humanoid
    local fired = false
    humanoid.Died:Connect(function()
        if fired then return end
        fired = true
        local result = encounter_service:on_enemy_died(enemy)
        if result.ok ~= true then
            warn(string.format("[Dungeon Runtime] Enemy reward/clear failed: %s", tostring(result.reason)))
            return
        end
        print_reward_result(result)
        DungeonEnemyCleanup.retire(enemy)
        if result.cleared then
            if not encounter_flow then
                warn(
                    "[Dungeon Runtime] Generic encounter flow is missing."
                )
                return
            end

            local flow_clear =
                encounter_flow:clear_runtime(encounter_id)
            if flow_clear.ok ~= true then
                warn(
                    "[Dungeon Runtime] Generic encounter clear failed: "
                        .. tostring(flow_clear.reason)
                )
                return
            end

            local binding = flow_clear.binding
            if binding
                and type(binding.ExitBarrierAnchor) == "string"
            then
                local opened =
                    DungeonEncounterEnvironmentRuntime.set_exit_open(
                        binding,
                        environment,
                        true
                    )
                if type(opened) == "table"
                    and opened.ok == false
                then
                    warn(
                        "[Dungeon Runtime] Exit barrier update failed for "
                            .. binding.RoomSlotId
                            .. ": "
                            .. tostring(opened.reason)
                    )
                end
            end

            local updated_gates = DungeonOptionalEntranceGates.sync(
                Workspace:FindFirstChild("DungeonMMOPlaceholderPhysicalContent"),
                encounter_bindings, encounter_flow
            )
            if updated_gates.ok ~= true then
                warn("[Dungeon Runtime] Side-room gate update failed: "
                    .. tostring(updated_gates.reason))
            end

            sync_all_character_encounters("")

            if flow_clear.next_binding then
                advance_checkpoint(
                    flow_clear.next_binding.CheckpointId
                )
            end

            if active_session_id and binding then
                sessions:set_runtime_progress(
                    active_session_id,
                    binding.PlanEncounterId .. "Clear",
                    ""
                )
            end

            active_execution = nil
            if flow_clear.complete then
                if handle_run_cleared then
                    handle_run_cleared()
                end
            elseif flow_clear.next_binding then
                send_objective(
                    "Encounter cleared. "
                        .. flow_clear.next_binding.RoomSlotId
                        .. " unlocked; checkpoint moved."
                )
            end
        end
    end)
end

-- Starts, spawns and registers one physical slot as a single transaction.
local function start_executed_slot(room_slot_id: string): any?
    if not active_session_id
        or completion_pending
        or not encounter_execution_controller
        or not encounter_service
    then
        return nil
    end

    local next_binding = encounter_flow
        and encounter_flow:next_binding()
    if next_binding
        and next_binding.Kind == "SecretBoss"
        and next_binding.RoomSlotId ~= room_slot_id
    then
        local skipped = encounter_flow:skip_secret_before(
            room_slot_id
        )
        if skipped.ok ~= true then
            return nil
        end
        if skipped.next_binding
            and not advance_checkpoint(
                skipped.next_binding.CheckpointId
            )
        then
            warn("[Dungeon Runtime] Secret skip checkpoint failed.")
            return nil
        end
    end

    local context = encounter_execution_context()
    local started = encounter_execution_controller:start_slot(
        room_slot_id,
        context
    )
    if started.ok ~= true then
        if not normal_start_rejection(started.reason) then
            warn(
                "[Dungeon Runtime] Encounter execution rejected for "
                    .. room_slot_id
                    .. ": "
                    .. tostring(started.reason)
            )
        end
        return nil
    end

    local binding = started.Binding
    local execution = started.Execution
    local encounter_id = binding.RuntimeEncounterId
    local enemies = execution.Enemies

    if type(enemies) ~= "table" or #enemies == 0 then
        encounter_execution_controller:abort_slot(
            room_slot_id,
            execution,
            context
        )
        warn(
            "[Dungeon Runtime] Encounter executor returned no enemies for "
                .. tostring(binding.PlanEncounterId)
        )
        return nil
    end

    sync_all_character_encounters(encounter_id)
    sessions:set_runtime_progress(
        active_session_id,
        encounter_id,
        encounter_id
    )

    local service_started = encounter_service:start(
        encounter_id,
        member_user_ids(),
        enemies
    )
    if service_started.ok ~= true then
        local aborted = encounter_execution_controller:abort_slot(
            room_slot_id,
            execution,
            context
        )
        warn(
            "[Dungeon Runtime] EncounterService start failed for "
                .. encounter_id
                .. ": "
                .. tostring(service_started.reason)
                .. " | rollback="
                .. tostring(aborted.ok)
        )
        sync_all_character_encounters("")
        return nil
    end

    active_execution = started
    sync_encounter_members_from_session()
    for _, enemy in ipairs(enemies) do
        connect_enemy(enemy, encounter_id)
    end

    local objective = execution.Objective
    if type(objective) == "string" and objective ~= "" then
        send_objective(
            if execution.ObjectiveState == "Boss"
                then "BOSS: " .. objective
                else objective,
            execution.ObjectiveState
        )
    end

    local boss_humanoid = execution.BossHumanoid
    if typeof(boss_humanoid) == "Instance"
        and boss_humanoid:IsA("Humanoid")
    then
        local boss_name = if type(
            execution.BossDisplayName
        ) == "string"
            then execution.BossDisplayName
            else binding.PlanEncounterId

        boss_humanoid.HealthChanged:Connect(function()
            send_boss_state(
                boss_humanoid,
                boss_name,
                encounter_id
            )
        end)
        send_boss_state(
            boss_humanoid,
            boss_name,
            encounter_id
        )
    end

    return started
end

-- Args:
--   session: any; active session with an interrupted encounter.
-- Returns:
--   any: rollback result; cleared rooms and reward receipts are retained.
local function reset_wiped_encounter(session: any): any
    if session.State ~= "Active" or not active_execution
        or not encounter_execution_controller or not encounter_service
    then
        return {ok = false, reason = "NoActiveEncounterToRetry"}
    end
    local binding = active_execution.Binding
    local encounter_id = binding.RuntimeEncounterId
    if encounter_service:is_clear(encounter_id) then
        return {ok = false, reason = "EncounterAlreadyCleared"}
    end

    local cancelled = encounter_execution_controller:abort_slot(
        binding.RoomSlotId,
        active_execution.Execution,
        encounter_execution_context()
    )
    if not cancelled.ok then
        warn("[Dungeon Runtime] Wipe rollback failed: "
            .. tostring(cancelled.reason))
        return cancelled
    end

    local retired = encounter_service:cancel_active(encounter_id)
    if not retired.ok then
        warn("[Dungeon Runtime] Wipe encounter release failed: "
            .. tostring(retired.reason))
        return retired
    end

    active_execution = nil
    sync_all_character_encounters("")
    sessions:set_runtime_progress(
        session.SessionId,
        binding.PlanEncounterId .. "Ready",
        ""
    )
    send_objective(
        "Party wiped. Current room reset; return from checkpoint to retry.",
        "Active"
    )
    return {ok = true, checkpoint = checkpoint_service:get_active_checkpoint()}
end

local function send_completion_state(commit_result: any, return_at: number)
    for _, player in ipairs(Players:GetPlayers()) do
        if loaded_users[player.UserId] then
            local own = commit_result.member_results and commit_result.member_results[tostring(player.UserId)] or nil
            dungeon_state:FireClient(player, {
                state = "Complete",
                objective = "Dungeon complete. Return to Base or wait "
                    .. "for auto-return.",
                session_id = active_session_id,
                completion = own,
                completion_eligible = own ~= nil,
                return_at = return_at,
                server_time = os.time(),
            })
        end
    end
end

local function commit_and_open_completion()
    if completion_committed or not completion_pending or not active_session_id or not completion_service or not return_service then return end
    local committed = completion_service:commit(active_session_id)
    if not committed.ok then
        next_completion_retry_at = os.clock() + 5
        send_objective(
            "Dungeon cleared. Saving completion rewards before return...",
            "CompletionSaveError"
        )
        warn("[Dungeon Runtime] Completion save barrier failed: " .. tostring(committed.reason))
        return
    end

    local opened = return_service:open(active_session_id, committed)
    if not opened.ok then
        next_completion_retry_at = os.clock() + 5
        warn("[Dungeon Runtime] Return portal could not open: " .. tostring(opened.reason))
        return
    end

    completion_pending = false
    completion_committed = true
    for _, player in ipairs(Players:GetPlayers()) do
        if loaded_users[player.UserId] then send_profile(player) end
    end
    send_completion_state(committed, opened.return_at)
    print(
        "[Dungeon Runtime] Completion rewards committed; "
            .. "return available for 60 seconds."
    )
end

handle_run_cleared = function()
    if not active_session_id
        or completion_pending
        or completion_committed
    then
        return
    end

    local session = current_session()
    if not session or session.State ~= "Active" then
        return
    end

    if not encounter_flow or not encounter_flow:is_complete() then
        warn(
            "[Dungeon Runtime] Run clear rejected because "
                .. "required generic encounters are incomplete."
        )
        return
    end

    local recipients = CompletionEligibilityRules.build_snapshot(session, connected_member_user_ids())
    local marked = sessions:mark_complete(active_session_id, recipients)
    if not marked.ok then
        warn("[Dungeon Runtime] Session completion failed: " .. tostring(marked.reason))
        return
    end
    completion_pending = true
    commit_and_open_completion()
end

-- Computes a server-derived distance from a player to a trigger's bounds.
-- Args: player (Player): Authoritatively resolved active dungeon member.
--       trigger (BasePart): Authored secret-encounter trigger.
-- Returns: number: Distance to the bounds, or infinity when unavailable.
local function trigger_distance(player: Player, trigger: BasePart): number
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not root:IsA("BasePart") then
        return math.huge
    end
    local position = trigger.CFrame:PointToObjectSpace(root.Position)
    local half = trigger.Size * 0.5
    local dx = math.max(math.abs(position.X) - half.X, 0)
    local dy = math.max(math.abs(position.Y) - half.Y, 0)
    local dz = math.max(math.abs(position.Z) - half.Z, 0)
    return Vector3.new(dx, dy, dz).Magnitude
end

-- Connects every resolved physical encounter trigger exactly once.
local function bind_encounter_triggers()
    if encounter_triggers_bound then
        return
    end
    assert(
        encounter_bindings ~= nil,
        "Encounter bindings must exist before trigger binding."
    )

    for _, binding in ipairs(encounter_bindings.ordered) do
        local trigger = environment:get(binding.TriggerAnchor)
        assert(
            trigger ~= nil,
            "Resolved encounter trigger disappeared: "
                .. tostring(binding.TriggerAnchor)
        )

        local room_slot_id = binding.RoomSlotId
        trigger.Touched:Connect(function(hit)
            local player = get_player_from_touch(hit)
            if not player then
                return
            end
            if binding.Kind == "SecretBoss" then
                local next_binding = encounter_flow
                    and encounter_flow:next_binding()
                local deferred = encounter_flow
                    and encounter_flow:state_for_slot(room_slot_id) == "Skipped"
                    and next_binding ~= nil
                    and not encounter_flow:is_complete()
                if not active_session_id or completion_pending
                    or (not deferred and (not next_binding
                        or next_binding.PlanEncounterId ~= binding.PlanEncounterId))
                then
                    return
                end
                local discovery = secret_discovery:discover(
                    active_session_id, player.UserId,
                    binding.PlanEncounterId,
                    trigger_distance(player, trigger)
                )
                if discovery.ok ~= true then
                    return
                end
            end
            start_executed_slot(room_slot_id)
        end)
    end

    -- Optional side arenas can be physically present even when the
    -- server-authoritative encounter plan did not select their boss.
    -- Provide a targeted, throttled explanation instead of a silent door;
    -- do not insert an encounter, enable an event, or reveal hidden rewards.
    local session = current_session()
    if active_definition.Id == "TestDungeon"
        and session and session.Difficulty
        and session.Difficulty.Id == "Depth1"
        and active_definition.OptionalBossRuntimeEnabled == true
    then
        for _, inactive in ipairs({
            {
                Slot = "EventArena",
                Anchor = "Temple.Event.Trigger",
                Message = "Event unavailable this run.",
            },
            {
                Slot = "SecretArena",
                Anchor = "Temple.Secret.Trigger",
                Message = "Secret route unavailable this run.",
            },
        }) do
            if encounter_bindings.by_slot[inactive.Slot] == nil then
                local marker = environment:get(inactive.Anchor)
                if marker and marker:IsA("BasePart") then
                    marker.CanTouch = true
                    marker.CanCollide = false
                    local last_notice: {[number]: number} = {}
                    marker.Touched:Connect(function(hit)
                        if completion_pending or not active_session_id then
                            return
                        end
                        local player = get_player_from_touch(hit)
                        if not player then return end
                        local now = os.clock()
                        if now - (last_notice[player.UserId] or -100) < 8 then
                            return
                        end
                        last_notice[player.UserId] = now
                        dungeon_state:FireClient(player, {
                            state = "Active",
                            objective = inactive.Message,
                            session_id = active_session_id,
                        })
                    end)
                end
            end
        end
    end

    -- Visible entrances are blocked independently of the invisible boss
    -- trigger. Tell the player WHY the gate is still closed when approached.
    local placeholder_root =
        Workspace:FindFirstChild("DungeonMMOPlaceholderPhysicalContent")
    if (active_definition.Id == "TestDungeon"
        or active_definition.Id == "AbandonedMine")
        and placeholder_root
    then
        for _, slot_id in ipairs({
            "EventArena", "EventArenaLate", "SecretArena"
        }) do
            local gate = DungeonOptionalEntranceGates.get(
                placeholder_root, slot_id
            )
            if gate then
                local last_notice: {[number]: number} = {}
                gate.Touched:Connect(function(hit)
                    if not gate.CanCollide or completion_pending
                        or not active_session_id
                    then
                        return
                    end
                    local player = get_player_from_touch(hit)
                    if not player then return end
                    local now = os.clock()
                    if now - (last_notice[player.UserId] or -100) < 8 then
                        return
                    end
                    local open, message = DungeonOptionalEntranceGates.status(
                        slot_id, encounter_bindings, encounter_flow
                    )
                    if open then return end
                    last_notice[player.UserId] = now
                    dungeon_state:FireClient(player, {
                        state = "Active",
                        objective = message,
                        session_id = active_session_id,
                    })
                end)
            end
        end
    end

    encounter_triggers_bound = true
end

local function emit_revive_state(user_id: number, payload: any)
    local player = Players:GetPlayerByUserId(user_id)
    if player then
        payload.server_time = os.time()
        revive_state:FireClient(player, payload)
    end
end

local function binding_for_checkpoint(
    checkpoint_id: string
): any?
    if not encounter_bindings then
        return nil
    end

    local legacy_slot =
        LEGACY_CHECKPOINT_SLOTS[checkpoint_id]
    if type(legacy_slot) == "string" then
        return encounter_bindings.by_slot[legacy_slot]
    end

    for _, binding in ipairs(encounter_bindings.ordered) do
        if binding.CheckpointId == checkpoint_id then
            return binding
        end
    end
    return nil
end

local function recovery_objective(
    binding: any?
): (string, string)
    if not binding then
        return "Enter the first encounter to begin the dungeon.",
            "Active"
    end

    if binding.ExecutorId == "Boss" then
        return "Boss encounter ready. Enter "
                .. binding.RoomSlotId
                .. ".",
            "Boss"
    end

    return "Enter "
            .. binding.RoomSlotId
            .. " to continue the dungeon.",
        "Active"
end

local function apply_recovery_plan(session: any): any
    local checkpoint_id = persisted_checkpoint_id(session)
    local checkpoint_binding =
        binding_for_checkpoint(checkpoint_id)

    if checkpoint_id ~= "Entrance"
        and not checkpoint_binding
    then
        warn(
            "[Dungeon Runtime] Unknown persisted checkpoint "
                .. tostring(checkpoint_id)
                .. "; presenting recovery from the next encounter."
        )
    end

    if encounter_bindings and encounter_flow then
        for _, binding in ipairs(
            encounter_bindings.ordered
        ) do
            if type(binding.ExitBarrierAnchor) == "string" then
                local state = encounter_flow:state_for_slot(
                    binding.RoomSlotId
                )
                local should_open = state == "Cleared"
                    or state == "Skipped"
                local updated =
                    DungeonEncounterEnvironmentRuntime.set_exit_open(
                        binding,
                        environment,
                        should_open
                    )
                if type(updated) == "table"
                    and updated.ok == false
                then
                    warn(
                        "[Dungeon Runtime] Recovery barrier update failed for "
                            .. binding.RoomSlotId
                            .. ": "
                            .. tostring(updated.reason)
                    )
                end
            end
        end
    end

    local recovered_gates = DungeonOptionalEntranceGates.sync(
        Workspace:FindFirstChild("DungeonMMOPlaceholderPhysicalContent"),
        encounter_bindings, encounter_flow
    )
    if recovered_gates.ok ~= true then
        warn("[Dungeon Runtime] Side-room gate recovery failed: "
            .. tostring(recovered_gates.reason))
    end
    sync_all_character_encounters("")
    local next_binding = encounter_flow
        and encounter_flow:next_binding()
        or nil
    local objective, objective_state =
        recovery_objective(next_binding)

    if active_session_id and next_binding then
        sessions:set_runtime_progress(
            active_session_id,
            next_binding.PlanEncounterId .. "Ready",
            ""
        )
    end

    return {
        valid_checkpoint = checkpoint_id == "Entrance"
            or checkpoint_binding ~= nil,
        spawn_checkpoint_id = checkpoint_id,
        runtime_room_id = next_binding
            and next_binding.PlanEncounterId .. "Ready"
            or "Complete",
        objective = objective,
        objective_state = objective_state,
    }
end

-- Registers stable encounter checkpoints plus legacy Depth1 aliases.
local function register_encounter_checkpoints()
    assert(
        checkpoint_service ~= nil,
        "Checkpoint service must exist before registration."
    )
    assert(
        encounter_bindings ~= nil,
        "Encounter bindings must exist before registration."
    )

    checkpoint_service:register(
        "Entrance",
        0,
        environment:checkpoint_cframe(
            encounter_bindings.entrance_anchor
        )
    )

    for _, binding in ipairs(encounter_bindings.ordered) do
        checkpoint_service:register(
            binding.CheckpointId,
            binding.CheckpointSequence,
            environment:checkpoint_cframe(
                binding.CheckpointAnchor
            )
        )
    end

    for legacy_id, room_slot_id in pairs(
        LEGACY_CHECKPOINT_SLOTS
    ) do
        local binding =
            encounter_bindings.by_slot[room_slot_id]
        if binding then
            checkpoint_service:register(
                legacy_id,
                binding.CheckpointSequence,
                environment:checkpoint_cframe(
                    binding.CheckpointAnchor
                )
            )
        end
    end
end

local function initialize_session_services(session: any): (any?, boolean)
    if active_session_id and active_session_id ~= session.SessionId then
        error("Reserved Dungeon server received more than one SessionId")
    end
    if encounter_service then return nil, false end
    active_session_id = session.SessionId
    encounter_service = EncounterService.new(
        rewards,
        session.SessionId,
        session.Modifier and session.Modifier.Id or nil
    )
    DungeonProgressionBridge.bind({
        proficiency_service = proficiency,
        encounter_service = encounter_service,
    })

    local encounter_runtime_result =
        initialize_encounter_runtime(session)
    if encounter_runtime_result.ok ~= true then
        error(
            "Generic encounter runtime failed: "
                .. tostring(encounter_runtime_result.reason)
        )
    end

    local execution_registry =
        DungeonEncounterExecutionBootstrap.create()
    encounter_execution_controller =
        DungeonEncounterExecutionController.new(
            encounter_flow,
            execution_registry
        )

    checkpoint_service = CheckpointService.new(
        sessions,
        session.SessionId
    )
    register_encounter_checkpoints()
    bind_encounter_triggers()
    if type(environment.apply_instance_state)=="function" then environment:apply_instance_state(session.InstanceState) end
    local completion_reward=active_definition.CompletionReward
    if active_definition.Id=="AbandonedMine" and type(session.InstanceState)=="table" then
        if session.InstanceState.EventActive==true then completion_reward=active_definition.EventCompletionReward elseif session.InstanceState.RareStateId=="CrystalBloom" then completion_reward=active_definition.RareCompletionReward end
        print(string.format("[Second Dungeon State] %s | Module1=%s | Module2=%s | Rare=%s | Event=%s",active_definition.DisplayName,tostring(session.InstanceState.Module1Id),tostring(session.InstanceState.Module2Id),tostring(session.InstanceState.RareStateId),tostring(session.InstanceState.EventId)))
    end
    local tuning = active_difficulty_tuning()
    completion_reward =
        DungeonDifficultyTuning.scale_completion_reward(
            completion_reward,
            tuning
        )

    local recovery_plan = apply_recovery_plan(session)
    completion_service = CompletionService.new(
        sessions,
        rewards,
        profiles,
        completion_reward,
        if active_definition.Id == DungeonDefinitions.TEST_DUNGEON.Id then skills else nil,
        quests,
        runtime.GuildService,
        runtime.DungeonDifficultyProgressionService
    )
    return_service = ReturnPortalService.new(sessions, coordinator, {
        is_studio = RunService:IsStudio(),
        auto_return_seconds = 60,
    })
    replay_service = DungeonReplayService.new(sessions, coordinator, {
        is_studio = RunService:IsStudio(),
        destination_place_id = game.PlaceId,
        is_player_ready = function(player: Player): boolean
            return loaded_users[player.UserId] == true
                and Players:GetPlayerByUserId(player.UserId) == player
        end,
    })

    local death_ref: any = nil
    purchase_service = RevivePurchaseService.new(sessions, {
        is_studio = RunService:IsStudio(),
        on_granted = function(user_id: number, session_id: string)
            if session_id ~= active_session_id or not death_ref then return end
            local player = Players:GetPlayerByUserId(user_id)
            if player then
                local revived = death_ref:complete_paid_revive(player)
                if not revived.ok then warn("[Dungeon Runtime] Paid revive spawn failed: " .. tostring(revived.reason)) end
            end
        end,
    })
    RevivePurchaseRegistry.set(purchase_service)

    death_service = DungeonDeathService.new(sessions, checkpoint_service, session.SessionId, {
        emit_state = emit_revive_state,
        paid_offer_provider = function(user_id: number)
            local latest = sessions:get(session.SessionId)
            return if latest then purchase_service:get_current_offer(latest, user_id) else nil
        end,
        on_member_mode = function(user_id: number, mode: string)
            encounter_service:mark_member_mode(user_id, mode)
        end,
        on_recoverable_wipe = reset_wiped_encounter,
    })
    death_ref = death_service
    return recovery_plan, true
end

local function claim_published_handoff(player: Player, session: any): (boolean, string?)
    local nonce = sessions:get_handoff_nonce(session.SessionId, player.UserId)
    if not nonce then
        -- A fresh Base -> Dungeon handoff always needs its one-time
        -- nonce. Only this already-bound server can readmit a genuine
        -- departed member whose initial handoff was previously claimed.
        -- ProfileService:load independently reacquires the writer lease.
        local reconnect = DungeonAdmissionRules.same_server_reconnect(
            session,
            player.UserId,
            active_session_id
        )
        if reconnect.ok then
            return true, nil
        end
        return false, "MissingHandoffNonce"
    end
    local claimed = leases:claim_handoff(player.UserId, nonce)
    if not claimed.ok then return false, claimed.reason end
    sessions:clear_handoff_nonce(session.SessionId, player.UserId)
    return true, nil
end

local function bind_character(player: Player, character: Model)
    if bound_characters[character] then return end
    bound_characters[character] = true

    apply_race_presentation(
        player,
        character
    )
    character:SetAttribute(CombatConfig.TRAINING_MARAUDER.RUN_PARTICIPANT_ATTRIBUTE, true)
    character:SetAttribute(CombatConfig.TRAINING_MARAUDER.ENCOUNTER_ATTRIBUTE, current_encounter_id)
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    local root = character:WaitForChild("HumanoidRootPart") :: BasePart
    local handled = false
    humanoid.Died:Connect(function()
        if handled or not death_service then
            return
        end
        handled = true
        DungeonDeathPresentation.disable_view_lock(player)
        local death_result = death_service:on_player_died(
            player,
            root.CFrame
        )
        if not death_result.ok then warn("[Dungeon Runtime] Death handling failed: " .. tostring(death_result.reason)) end
    end)
end

local function load_character_at(player: Player, target: CFrame)
    player:LoadCharacter()
    local character = player.Character or player.CharacterAdded:Wait()
    bind_character(player, character)
    character:PivotTo(target)
end

local function member_is_reconnecting(session: any, user_id: number): boolean
    local members = if type(session) == "table" then session.Members else nil
    local member = if type(members) == "table" then members[tostring(user_id)] else nil
    return type(member) == "table" and member.LastConnectedAt ~= nil
end

local function reconnect_objective(plan: any): (string, string)
    if current_encounter_id ~= ""
        and encounter_flow
    then
        local binding = encounter_flow:binding_for_runtime(
            current_encounter_id
        )
        if binding then
            if binding.ExecutorId == "Boss" then
                return "BOSS: Resume "
                        .. binding.PlanEncounterId
                        .. ".",
                    "Boss"
            end
            return "Resume "
                    .. binding.PlanEncounterId
                    .. ".",
                "Active"
        end
    end

    return plan.objective, plan.objective_state
end

local function admit_player(player: Player)
    local session: any = nil
    local teleport_data: any = nil

    if RunService:IsStudio() then
        local studio = StudioSessionFactory.create_for_players(
            {player},
            sessions,
            active_definition.Id,
            resolved_difficulty_id
        )
        if not studio.ok then
            player:Kick("Studio dungeon session failed: " .. tostring(studio.reason))
            return
        end
        session = studio.session
        teleport_data = studio.teleport_data
    else
        teleport_data = player:GetJoinData().TeleportData
        if type(teleport_data) ~= "table" or type(teleport_data.SessionId) ~= "string" then
            player:Kick("Missing dungeon session routing data.")
            return
        end
        session = sessions:get(teleport_data.SessionId)
    end

    local admission = DungeonAdmissionRules.validate(
        session,
        teleport_data,
        player.UserId,
        active_definition.Id
    )
    if not admission.ok then
        player:Kick("Dungeon admission rejected: " .. tostring(admission.reason))
        return
    end

    if not RunService:IsStudio() then
        local claimed, claim_error = claim_published_handoff(player, session)
        if not claimed then
            player:Kick("Profile handoff rejected: " .. tostring(claim_error))
            return
        end
    end

    local loaded, load_error = profiles:load(player.UserId)
    if not loaded then
        player:Kick("Profile load failed: " .. tostring(load_error))
        return
    end

    local identity_character =
        profiles:get_character(
            player.UserId,
            1
        )

    if (
        not identity_character
        or not CharacterIdentityRules
            .is_complete(identity_character)
    ) then
        if RunService:IsStudio() then
            local race_result =
                identity:select_race(
                    player.UserId,
                    "Human"
                )

            if not race_result.ok then
                profiles:release(
                    player.UserId,
                    "DungeonAdmissionFailed"
                )

                player:Kick(
                    "Studio identity bootstrap failed: "
                        .. tostring(
                            race_result.reason
                        )
                )

                return
            end

            identity_character =
                profiles:get_character(
                    player.UserId,
                    1
                )

            local creation_stage =
                identity_character
                and identity_character.Identity
                and identity_character
                    .Identity
                    .CreationStage

            if creation_stage == "ClassSelection" then
                local requested_studio_class = Workspace:GetAttribute(
                    "DungeonMMOStudioBaseClass"
                )
                local studio_class_id = "Mage"

                if requested_studio_class == "Fighter" then
                    studio_class_id = "Fighter"
                elseif requested_studio_class == "Mage" then
                    studio_class_id = "Mage"
                elseif requested_studio_class == "Ranger" then
                    studio_class_id = "Ranger"
                elseif requested_studio_class == "Rogue" then
                    studio_class_id = "Rogue"
                end

                local class_result =
                    identity:select_base_class(
                        player.UserId,
                        studio_class_id
                    )

                if not class_result.ok then
                    profiles:release(
                        player.UserId,
                        "DungeonAdmissionFailed"
                    )

                    player:Kick(
                        "Studio class bootstrap failed: "
                            .. tostring(
                                class_result.reason
                            )
                    )

                    return
                end
            end

            identity_character =
                profiles:get_character(
                    player.UserId,
                    1
                )

            if (
                not identity_character
                or not CharacterIdentityRules
                    .is_complete(
                        identity_character
                    )
            ) then
                profiles:release(
                    player.UserId,
                    "DungeonAdmissionFailed"
                )

                player:Kick(
                    "Studio identity bootstrap remained incomplete."
                )

                return
            end

            print(
                string.format(
                    "[Dungeon Runtime] Studio-only identity bootstrap: %s / %s for %s.",
                    tostring(
                        identity_character
                            .Identity
                            .RaceId
                    ),
                    tostring(
                        identity_character
                            .Identity
                            .ClassId
                    ),
                    player.Name
                )
            )
        else
            profiles:release(
                player.UserId,
                "IdentityIncomplete"
            )

            player:Kick(
                "Dungeon admission rejected: IdentityIncomplete"
            )

            return
        end
    end

    if RunService:IsStudio() then
        local seeded = 0
        local seeded_ok, seeded_error = profiles:mutate(
            player.UserId,
            function(profile: any)
                local character = profile.Characters
                    and profile.Characters.Slot1

                seeded = DungeonStudioEquipmentBootstrap.seed(
                    character
                )
            end
        )

        if not seeded_ok then
            profiles:release(
                player.UserId,
                "DungeonAdmissionFailed"
            )
            player:Kick(
                "Studio equipment bootstrap failed: "
                    .. tostring(seeded_error)
            )
            return
        end

        if seeded > 0 then
            print(
                string.format(
                    "[Dungeon Runtime] Studio-only equipment bootstrap: "
                        .. "%d representative slots seeded for %s.",
                    seeded,
                    player.Name
                )
            )
        end
    end

    local reconnecting = member_is_reconnecting(session, player.UserId)
    local recovery_plan, runtime_created = initialize_session_services(session)
    local connected = sessions:mark_connected(session.SessionId, player.UserId)
    if not connected.ok then
        profiles:release(player.UserId, "DungeonAdmissionFailed")
        player:Kick("Session connection failed: " .. tostring(connected.reason))
        return
    end
    if reconnecting then
        local latest_session = sessions:get(session.SessionId)
        local latest_member = latest_session and latest_session.Members[tostring(player.UserId)]
        local recovery_mode = DungeonRecoveryRules.member_mode_on_reconnect(latest_member)
        if latest_member and latest_member.Mode ~= recovery_mode then
            local normalized = sessions:set_member_mode(session.SessionId, player.UserId, recovery_mode)
            if not normalized.ok then
                profiles:release(player.UserId, "DungeonAdmissionFailed")
                player:Kick("Session recovery failed: " .. tostring(normalized.reason))
                return
            end
        end
        if encounter_service then encounter_service:mark_member_mode(player.UserId, recovery_mode) end
    end
    loaded_users[player.UserId] = true
    local loaded_character = profiles:get_character(player.UserId, 1)
    if loaded_character then ProgressionRuntimeState.set_character(player.UserId, loaded_character) end
    if encounter_service then
        encounter_service:mark_member_connected(player.UserId, true)
    end
    if not reconnecting
        and checkpoint_service
        and encounter_flow
    then
        local first_binding =
            encounter_flow:first_binding()
        if first_binding then
            local initial_checkpoint =
                checkpoint_service:activate(
                    first_binding.CheckpointId
                )
            if not initial_checkpoint.ok then
                warn(
                    "[Dungeon Runtime] Initial encounter checkpoint failed: "
                        .. tostring(initial_checkpoint.reason)
                )
            end
        end
    end

    player.CharacterAdded:Connect(function(character)
        task.defer(ProgressionRuntimeState.apply_runtime_stats, player)
        task.defer(function()
            if character.Parent then
                bind_character(player, character)
            end
        end)
    end)

    local spawn_cframe = environment:checkpoint_cframe(
        assert(
            encounter_bindings
                and encounter_bindings.entrance_anchor,
            "Encounter entrance binding is missing."
        )
    )
    if reconnecting and checkpoint_service then
        spawn_cframe = checkpoint_service:get_active_checkpoint().CFrame
    end
    load_character_at(player, spawn_cframe)
    ProgressionRuntimeState.apply_runtime_stats(player)
    send_profile(player)

    if reconnecting then
        local plan = recovery_plan
        if not plan then
            local next_binding = encounter_flow
                and encounter_flow:next_binding()
                or nil
            local objective, objective_state =
                recovery_objective(next_binding)
            plan = {
                spawn_checkpoint_id = "Entrance",
                objective = objective,
                objective_state = objective_state,
            }
        end
        local objective, state_name = reconnect_objective(plan)
        send_objective(objective, state_name)
        if runtime_created then
            print(string.format(
                "[Dungeon Runtime] %s reconstructed %s from checkpoint %s; current encounter reset.",
                player.Name,
                session.SessionId,
                tostring(plan.spawn_checkpoint_id)
            ))
        end
    else
        local first_binding = encounter_flow
            and encounter_flow:first_binding()
            or nil
        local objective, state_name =
            recovery_objective(first_binding)
        send_objective(objective, state_name)
    end

    -- Rehydrate the new client from the server-owned member record.
    -- A reconnecting spectator must see their existing revive decision,
    -- not a new free revive just because LoadCharacter created a model.
    if death_service then
        local refreshed = death_service:send_member_state(player)
        if not refreshed.ok then
            warn("[Dungeon Runtime] Revive-state sync failed: "
                .. tostring(refreshed.reason))
        end
    end

    print(string.format("[Dungeon Runtime] %s admitted to %s.", player.Name, session.SessionId))
end

local function request_return(players_to_return: {Player})
    if not return_service or not active_session_id or not completion_committed then
        return {ok = false, reason = "ReturnNotReady"}
    end
    local returned = return_service:request_return(active_session_id, players_to_return)
    if returned.ok and returned.simulated == true then
        for _, player in ipairs(players_to_return) do
            if loaded_users[player.UserId] then
                dungeon_state:FireClient(player, {
                    state = "Complete",
                    objective = "Studio return simulated. Published TEST will teleport you back to Base.",
                    return_simulated = true,
                })
            end
        end
    elseif not returned.ok then
        warn("[Dungeon Runtime] Return request failed: " .. tostring(returned.reason))
    end
    return returned
end

return_request.OnServerEvent:Connect(function(
    player: Player,
    action: any
)
    if not loaded_users[player.UserId] then
        return
    end
    if action == "PlayAgain" then
        if not replay_service or not active_session_id then
            emit_revive_state(player.UserId, {error = "ReplayNotReady"})
            return
        end
        local replay = replay_service:request(
            active_session_id, player, connected_loaded_players()
        )
        if not replay.ok then
            local recipients = if replay.votes_reset == true
                then connected_loaded_players()
                else {player}
            for _, recipient in ipairs(recipients) do
                dungeon_state:FireClient(recipient, {
                    state = "ReplayError",
                    objective = "Unable to start replay: "
                        .. tostring(replay.reason),
                    replay_error = replay.reason,
                })
            end
        elseif replay.waiting then
            dungeon_state:FireClient(player, {
                state = "ReplayWaiting",
                objective = string.format(
                    "Waiting for %d party member(s) to select Play again.",
                    replay.waiting
                ),
                waiting = replay.waiting,
            })
        elseif replay.simulated then
            for _, recipient in ipairs(connected_loaded_players()) do
                dungeon_state:FireClient(recipient, {
                    state = "ReplaySimulated",
                    objective = "Studio replay simulated; new run is not published.",
                })
            end
        end
        return
    end
    if action == "Abandon" then
        if not return_service or not active_session_id then
            emit_revive_state(player.UserId, {error = "ReturnNotReady"})
            return
        end
        local session = current_session()
        local abandoned = if session and session.State == "Failed"
            then return_service:request_failed_return(
                active_session_id,
                {player}
            )
            else return_service:request_abandon(
                active_session_id,
                {player}
            )
        if not abandoned.ok then
            emit_revive_state(
                player.UserId,
                {error = abandoned.reason}
            )
        elseif abandoned.simulated == true then
            dungeon_state:FireClient(player, {
                state = "Failed",
                objective = "Studio Return to Lobby simulated.",
                return_simulated = true,
            })
        end
        return
    end
    request_return({player})
end)

profile_snapshot.OnServerEvent:Connect(function(player: Player, action: any)
    if action == "Request" and loaded_users[player.UserId] then send_profile(player) end
end)

progression_snapshot.OnServerEvent:Connect(function(player: Player, action: any)
    if action == "Request" and loaded_users[player.UserId] then send_progression(player) end
end)

loadout_request.OnServerEvent:Connect(function(player: Player, first: any, second: any)
    if not loaded_users[player.UserId] then return end
    local context = "DungeonClear"
    if encounter_service and current_encounter_id ~= "" and not encounter_service:is_clear(current_encounter_id) then
        context = "DungeonActive"
    end
    local result:any
    if type(first)=="string" then
        result=loadout:move_to_slot(player.UserId,first,second,context)
    elseif type(first)=="table" and second==nil then
        result=loadout:set(player.UserId,first,context)
    else
        result={ok=false,reason="InvalidLoadoutRequest"}
    end
    progression_action_result:FireClient(player, {action = "Loadout", ok = result.ok == true, reason = result.reason})
    if result.ok then send_progression(player) end
end)

revive_request.OnServerEvent:Connect(function(player: Player, action: any)
    if not death_service or not loaded_users[player.UserId] then return end
    if action == "Free" then
        local result = death_service:request_free_revive(player)
        if not result.ok then emit_revive_state(player.UserId, {error = result.reason}) end
    elseif action == "Paid" then
        if RunService:IsStudio() then
            local result = purchase_service:simulate_approved_purchase(player.UserId, active_session_id)
            if not result.ok then emit_revive_state(player.UserId, {error = result.reason}) end
        else
            emit_revive_state(player.UserId, {error = "PaidRevivesLiveDisabled"})
        end
    end
end)

Players.PlayerAdded:Connect(function(player) task.spawn(admit_player, player) end)
for _, player in ipairs(Players:GetPlayers()) do task.spawn(admit_player, player) end

Players.PlayerRemoving:Connect(function(player)
    local user_id = player.UserId
    if not loaded_users[user_id] then return end
    loaded_users[user_id] = nil
    ProgressionRuntimeState.clear_character(user_id)
    if encounter_service then encounter_service:mark_member_connected(user_id, false) end
    local session = current_session()
    if active_session_id and session and session.State == "Active" then sessions:mark_disconnected(active_session_id, user_id) end

    if coordinator:is_pending(user_id) then
        local forgot, forget_error = profiles:forget_for_handoff(user_id)
        if not forgot then warn("[Dungeon Runtime] Return handoff forget failed: " .. tostring(forget_error)) end
        coordinator:acknowledge_departure(user_id)
        return
    end

    local released, release_error = profiles:release(user_id, "DungeonPlayerRemoving")
    if not released then warn("[Dungeon Runtime] Profile release failed: " .. tostring(release_error)) end
end)

task.spawn(function()
    while true do
        task.wait(0.25)
        if death_service then
            local result = death_service:tick(os.time())
            if result.failed then
                sync_all_character_encounters("")
                send_objective("Dungeon failed: revive window expired.", "Failed")
            end
        end
        if completion_pending and not completion_committed and os.clock() >= next_completion_retry_at then
            commit_and_open_completion()
        end
        if completion_committed and return_service and active_session_id
            and not (replay_service and replay_service:is_launching())
        then
            local auto = return_service:tick(active_session_id, connected_loaded_players())
            if auto.triggered and auto.result and auto.result.ok and auto.result.simulated == true then
                send_objective("Studio auto-return simulated. Published TEST will return remaining players to Base.", "Complete")
            elseif auto.triggered and auto.result and not auto.result.ok then
                warn("[Dungeon Runtime] Automatic return failed: " .. tostring(auto.result.reason))
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(LEASE_RENEW_SECONDS)
        for user_id in pairs(loaded_users) do
            if not coordinator:is_pending(user_id) then
                local result = leases:renew(user_id)
                if not result.ok then warn(string.format("[Dungeon Runtime] Lease renewal failed for %d: %s", user_id, tostring(result.reason))) end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(AUTOSAVE_SECONDS)
        for user_id in pairs(loaded_users) do
            if not coordinator:is_pending(user_id) then
                local ok, err = profiles:save(user_id, "DungeonAutosave")
                if not ok then warn(string.format("[Dungeon Runtime] Autosave failed for %d: %s", user_id, tostring(err))) end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(SESSION_REFRESH_SECONDS)
        if active_session_id then sessions:refresh(active_session_id) end
    end
end)

game:BindToClose(function()
    RevivePurchaseRegistry.set(nil)
    for user_id in pairs(loaded_users) do
        if coordinator:is_pending(user_id) then
            profiles:forget_for_handoff(user_id)
        else
            local session = current_session()
            if active_session_id and session and session.State == "Active" then sessions:mark_disconnected(active_session_id, user_id) end
            profiles:release(user_id, "DungeonBindToClose")
        end
    end
end)

print(
    "[Dungeon Runtime] Full Phase 2A dungeon loop ready: "
        .. "room-start checkpoints, Captain, completion and return."
)
