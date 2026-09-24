local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local combat_folder = ReplicatedStorage:WaitForChild("Combat")
local shared_folder = combat_folder:WaitForChild("Shared")
local remotes_folder = combat_folder:WaitForChild("Remotes")
local core_shared_folder = ReplicatedStorage
    :WaitForChild("Core")
    :WaitForChild("Shared")

local EquipmentDefenseRules = require(
    core_shared_folder:WaitForChild("EquipmentDefenseRules")
)
local CombatConfig = require(
    shared_folder:WaitForChild("CombatConfig")
)
local CombatTypes = require(
    shared_folder:WaitForChild("CombatTypes")
)
local StateRules = require(
    shared_folder:WaitForChild("StateRules")
)
local AttackStepRules = require(
    shared_folder:WaitForChild("AttackStepRules")
)
local BasicAttackTimingRules = require(
    shared_folder:WaitForChild("BasicAttackTimingRules")
)
local HotbarConfig = require(
    shared_folder:WaitForChild("HotbarConfig")
)
local SkillDefinitions = require(
    shared_folder:WaitForChild("SkillDefinitions")
)
local RangerDrawRules = require(
    shared_folder:WaitForChild("RangerDrawRules")
)

local MeleeHitService = require(
    script.Parent:WaitForChild("MeleeHitService")
)
local DamageService = require(
    script.Parent:WaitForChild("DamageService")
)
local ThreatService = require(
    script.Parent:WaitForChild("ThreatService")
)
local SkillCooldownService = require(
    script.Parent:WaitForChild("SkillCooldownService")
)
local MendService = require(
    script.Parent:WaitForChild("MendService")
)
local StaggerService = require(
    script.Parent:WaitForChild("StaggerService")
)
local RogueBleedService = require(
    script.Parent:WaitForChild("RogueBleedService")
)
local StaminaService = require(
    script.Parent:WaitForChild("StaminaService")
)
local ScoutCriticalToggleService = require(
    script.Parent:WaitForChild("ScoutCriticalToggleService")
)
local IronvowCriticalToggleService = require(
    script.Parent:WaitForChild("IronvowCriticalToggleService")
)
local IronvowAccuracyToggleService = require(
    script.Parent:WaitForChild("IronvowAccuracyToggleService")
)
-- Passive source rank recovery is scheduled by its own server heartbeat.
require(script.Parent:WaitForChild("IronvowHealthRecoveryService"))
local IronvowEnduranceSurgeService = require(
    script.Parent:WaitForChild("IronvowEnduranceSurgeService")
)
local ScoutAccuracyToggleService = require(
    script.Parent:WaitForChild("ScoutAccuracyToggleService")
)
local ManaService = require(
    script.Parent:WaitForChild("ManaService")
)
local SpiritOrbService = require(
    script.Parent:WaitForChild("SpiritOrbService")
)
local WindStrikeService = require(
    script.Parent:WaitForChild("WindStrikeService")
)
local WardService = require(
    script.Parent:WaitForChild("WardService")
)
local MageHealService = require(
    script.Parent:WaitForChild("MageHealService")
)
local PartyHealService = require(
    script.Parent:WaitForChild("PartyHealService")
)
local PoisonStatusService = require(
    script.Parent:WaitForChild("PoisonStatusService")
)
local PlayerBleedStatusService = require(
    script.Parent:WaitForChild("PlayerBleedStatusService")
)
local CombatStatusService = require(
    script.Parent:WaitForChild("CombatStatusService")
)
local RangerDrawService = require(
    script.Parent:WaitForChild("RangerDrawService")
)
local RangerCombatService = require(
    script.Parent:WaitForChild("RangerCombatService")
)
local DefenseService = require(
    script.Parent:WaitForChild("DefenseService")
)
local DodgeDirectionRules = require(
    script.Parent:WaitForChild("DodgeDirectionRules")
)
local DodgeClearanceRules = require(
    script.Parent:WaitForChild("DodgeClearanceRules")
)
local CombatValidationService = require(
    script.Parent:WaitForChild("CombatValidationService")
)
local ProgressionRuntimeState = require(
    ServerScriptService:WaitForChild("Core"):WaitForChild("Services"):WaitForChild("ProgressionRuntimeState")
)
local DungeonProgressionBridge = require(
    ServerScriptService:WaitForChild("Dungeon"):WaitForChild("DungeonProgressionBridge")
)
local DungeonContributionBridge = require(
    ServerScriptService:WaitForChild("Dungeon"):WaitForChild("DungeonContributionBridge")
)

DamageService.set_damage_callback(function(
    context: any,
    applied_damage: number,
    lethal_hit: boolean
)
    DungeonContributionBridge.record_damage(
        context,
        applied_damage,
        lethal_hit
    )
    if context.attacker
        and context.target
        and context.target:IsA("Model")
        and applied_damage > 0
    then
        ThreatService.record_damage(
            context.target,
            context.attacker,
            applied_damage
        )
    end
end)

WardService.set_absorb_callback(function(
    caster: Player,
    target: Player,
    absorbed: number
)
    DungeonProgressionBridge.award_support(
        caster,
        "ArcaneWard",
        target,
        absorbed
    )
    DungeonContributionBridge.record_ward(
        caster,
        target,
        absorbed,
        "ArcaneWard"
    )
    ThreatService.record_support(caster, target, absorbed)
end)

MageHealService.set_heal_callback(function(
    caster: Player,
    target: Player,
    healed: number,
    skill_id: string
)
    DungeonProgressionBridge.award_heal(
        caster,
        skill_id,
        target,
        healed
    )
    DungeonContributionBridge.record_heal(
        caster,
        target,
        healed,
        skill_id
    )
    ThreatService.record_support(caster, target, healed)
end)

local attack_request = remotes_folder:WaitForChild(
    CombatConfig.REMOTES.ATTACK_REQUEST
) :: RemoteEvent
local state_changed = remotes_folder:WaitForChild(
    CombatConfig.REMOTES.STATE_CHANGED
) :: RemoteEvent
local defense_request = remotes_folder:WaitForChild(
    CombatConfig.REMOTES.DEFENSE_REQUEST
) :: RemoteEvent
local skill_request = remotes_folder:WaitForChild(
    CombatConfig.REMOTES.SKILL_REQUEST
) :: RemoteEvent

local State = CombatTypes.State
local BasicAttack = CombatConfig.BASIC_ATTACK

type PlayerCombatState = {
    state_name: string,
    state_started_at: number,
    current_attack_id: string?,
    current_skill_id: string?,
    next_attack_id: string,
    queued_attack: boolean,
    combo_expires_at: number,
    sequence_id: number,
    base_walk_speed: number,
    ranger_draw_tier: any?,
    skill_aim: Vector3?,
}

local player_states: {[Player]: PlayerCombatState} = {}
local has_spawned_character: {[Player]: boolean} = {}

type DodgeMovementProfile = {
    distance: number,
    duration: number,
    start_speed_multiplier: number,
    end_speed_multiplier: number,
}

type DodgeMovementRecord = {
    player: Player,
    character: Model,
    root_part: BasePart,
    velocity: LinearVelocity,
    raycast_params: RaycastParams,
    started_at: number,
    distance: number,
    duration: number,
    start_speed_multiplier: number,
    end_speed_multiplier: number,
    clearance: number,
    input_code: string,
    view_locked: boolean,
    unlocked_direction: Vector3?,
    heartbeat_connection: RBXScriptConnection?,
}

local dodge_movements: {[Player]: DodgeMovementRecord} = {}


--[[
Creates a fresh authoritative combat record for a player.

Args:
    base_walk_speed (number): Character walk speed outside attack states.

Returns:
    PlayerCombatState: New combat record in the Locomotion state.
]]
local function create_player_state(base_walk_speed: number): PlayerCombatState
    return {
        state_name = State.LOCOMOTION,
        state_started_at = os.clock(),
        current_attack_id = nil,
        current_skill_id = nil,
        next_attack_id = BasicAttack.ATTACK_ORDER[1],
        queued_attack = false,
        combo_expires_at = 0,
        sequence_id = 0,
        base_walk_speed = base_walk_speed,
        ranger_draw_tier = nil,
        skill_aim = nil,
    }
end


local function clear_wind_strike_charge(player: Player)
    local character = player.Character
    if not character then
        return
    end

    character:SetAttribute("WindStrikeCharging", false)
    character:SetAttribute("WindStrikeChargeEndsAt", 0)
end

--[[Returns the current committed offensive/support action label.]]
local function get_committed_action_label(
    record: PlayerCombatState
): string?
    if record.current_skill_id then
        return record.current_skill_id
    end

    if record.current_attack_id then
        return record.current_attack_id
    end

    if record.state_name == State.MENDING then
        return "Mend"
    end

    return nil
end


--[[Reports cancellation before a defensive action invalidates a sequence.]]
local function report_sequence_cancel(
    player: Player,
    record: PlayerCombatState,
    reason: string
)
    local action_label = get_committed_action_label(record)

    if action_label then
        CombatValidationService.emit(
            player,
            "SEQUENCE",
            "CANCELLED",
            action_label .. " by " .. reason,
            record.sequence_id
        )
    end
end


--[[
Gets the active humanoid and root part for a player.

Args:
    player (Player): Player whose character is required.

Returns:
    Humanoid?: Active Humanoid when available.
    BasePart?: Active HumanoidRootPart when available.
]]
local function get_character_parts(
    player: Player
): (Humanoid?, BasePart?)
    local character = player.Character

    if not character then
        return nil, nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root_part = character:FindFirstChild("HumanoidRootPart")

    if not root_part or not root_part:IsA("BasePart") then
        return humanoid, nil
    end

    return humanoid, root_part
end


--[[
Writes diagnostic combat attributes onto the active character.

Args:
    player (Player): Player whose character receives attributes.
    record (PlayerCombatState): Current authoritative combat record.

Returns:
    None.
]]
local function update_character_attributes(
    player: Player,
    record: PlayerCombatState
)
    local character = player.Character

    if not character then
        return
    end

    character:SetAttribute("CombatState", record.state_name)
    character:SetAttribute(
        "CurrentAttackId",
        record.current_attack_id or ""
    )
    character:SetAttribute(
        "CurrentSkillId",
        record.current_skill_id or ""
    )
    character:SetAttribute("AttackBuffered", record.queued_attack)
end


--[[
Applies state-specific movement commitment on the server.

Args:
    player (Player): Player whose Humanoid is updated.
    record (PlayerCombatState): Current authoritative combat record.

Returns:
    None.
]]
local function apply_movement_scale(
    player: Player,
    record: PlayerCombatState
)
    local humanoid = get_character_parts(player)

    if not humanoid then
        return
    end

    local scale = 1
    local weapon_tags =
        ProgressionRuntimeState.get_weapon_tags(
            player.UserId
        )

    if RangerDrawService.is_drawing(player) then
        scale = RangerDrawRules.DRAW_MOVEMENT_SCALE
    elseif record.current_attack_id
        and weapon_tags.ArcaneWand == true
        and (
            record.state_name == State.WIND_UP
            or record.state_name == State.ACTIVE
            or record.state_name == State.RECOVERY
        ) then
        scale = 0
    elseif record.current_attack_id == "RangerArrow"
        and weapon_tags.Longbow == true
        and (
            record.state_name == State.WIND_UP
            or record.state_name == State.ACTIVE
            or record.state_name == State.RECOVERY
        ) then
        scale = StateRules.get_movement_scale(
            record.state_name,
            CombatConfig.RANGER_LONGBOW.RELEASE
        )
    elseif record.state_name == State.DODGING
        or record.state_name == State.GUARD_BREAK
        or record.state_name == State.MENDING
        or record.state_name == State.DEAD then
        scale = 0
    elseif record.current_attack_id then
        local attack_definition = BasicAttack.ATTACKS[
            record.current_attack_id
        ]

        if attack_definition then
            scale = StateRules.get_movement_scale(
                record.state_name,
                attack_definition
            )
        end
    elseif record.current_skill_id then
        local skill_definition = SkillDefinitions.get(
            record.current_skill_id
        )

        if skill_definition then
            scale = StateRules.get_movement_scale(
                record.state_name,
                skill_definition
            )
        end
    end

    -- A purchased passive scales actual running speed without bypassing
    -- blocked movement during dodge, death, channel or casting.
    local scout_movement = ProgressionRuntimeState
        .get_movement_multiplier(player.UserId)
    local cast_movement = 1 + CombatStatusService.get(
        player.Character, "Movement"
    )
    humanoid.WalkSpeed = record.base_walk_speed
        * scale * scout_movement * cast_movement

    local movement_locked = scale <= 0
    humanoid.Jump = false
    humanoid:SetStateEnabled(
        Enum.HumanoidStateType.Jumping,
        not movement_locked
    )
end


--[[
Publishes an authoritative state transition to diagnostics and the client.

Args:
    player (Player): Player whose state is changing.
    record (PlayerCombatState): Authoritative combat record.
    next_state (string): State to enter.

Returns:
    boolean: True when the transition was accepted.
]]
local function set_state(
    player: Player,
    record: PlayerCombatState,
    next_state: string
): boolean
    if record.state_name ~= next_state then
        local allowed = StateRules.can_transition(
            record.state_name,
            next_state
        )

        if not allowed then
            warn(
                string.format(
                    "[Combat] Rejected state transition %s -> %s for %s.",
                    record.state_name,
                    next_state,
                    player.Name
                )
            )
            return false
        end
    end

    record.state_name = next_state
    record.state_started_at = os.clock()

    apply_movement_scale(player, record)
    update_character_attributes(player, record)

    state_changed:FireClient(
        player,
        record.state_name,
        record.current_attack_id
            or record.current_skill_id
            or "",
        Workspace:GetServerTimeNow()
    )

    return true
end


--[[
Applies a brief planar velocity so attack commitment reads as a step.

Args:
    player (Player): Player whose character receives the step.
    distance (number): Requested forward travel in studs.
    attack_definition (table): Current attack timing definition.

Returns:
    None.
]]
local function apply_forward_step(
    player: Player,
    distance: number,
    attack_definition: any
)
    local character = player.Character
    local _, root_part = get_character_parts(player)

    if not character or not root_part then
        return
    end

    local forward = Vector3.new(
        root_part.CFrame.LookVector.X,
        0,
        root_part.CFrame.LookVector.Z
    )

    if forward.Magnitude < 0.001 then
        return
    end

    forward = forward.Unit

    local raycast_params = RaycastParams.new()
    raycast_params.FilterType =
        Enum.RaycastFilterType.Exclude
    raycast_params.FilterDescendantsInstances = {
        character,
    }
    raycast_params.IgnoreWater = true

    local result = Workspace:Raycast(
        root_part.Position,
        forward * distance,
        raycast_params
    )

    local obstacle_distance = nil

    if result then
        obstacle_distance = result.Distance
    end

    local allowed_distance =
        AttackStepRules.get_allowed_distance(
            distance,
            obstacle_distance
        )

    if allowed_distance <= 0 then
        return
    end

    local duration =
        AttackStepRules.get_step_duration(
            attack_definition
        )
    local speed =
        AttackStepRules.get_step_speed(
            allowed_distance,
            duration
        )

    local old_velocity = root_part:FindFirstChild(
        "CombatStepVelocity"
    )

    if old_velocity then
        old_velocity:Destroy()
    end

    local attachment = root_part:FindFirstChild(
        "CombatStepAttachment"
    )

    if not attachment
        or not attachment:IsA("Attachment") then
        attachment = Instance.new("Attachment")
        attachment.Name = "CombatStepAttachment"
        attachment.Parent = root_part
    end

    local velocity = Instance.new("LinearVelocity")

    velocity.Name = "CombatStepVelocity"
    velocity.Attachment0 = attachment
    velocity.RelativeTo =
        Enum.ActuatorRelativeTo.World
    velocity.VelocityConstraintMode =
        Enum.VelocityConstraintMode.Plane
    velocity.PrimaryTangentAxis =
        Vector3.new(1, 0, 0)
    velocity.SecondaryTangentAxis =
        Vector3.new(0, 0, 1)
    velocity.PlaneVelocity = Vector2.new(
        forward.X * speed,
        forward.Z * speed
    )
    velocity.ForceLimitsEnabled = false
    velocity.Parent = root_part

    task.delay(duration, function()
        if velocity.Parent then
            velocity:Destroy()
        end
    end)
end


--[[
Stops any active attack/skill forward-step velocity before a higher-priority
defensive movement begins.

Args:
    player (Player): Player whose attack step must be cancelled.

Returns:
    None.
]]
local function stop_attack_step(player: Player)
    local _, root_part = get_character_parts(player)

    if not root_part then
        return
    end

    local velocity = root_part:FindFirstChild("CombatStepVelocity")

    if velocity then
        velocity:Destroy()
    end
end


--[[
Returns the movement profile for one dodge input.

Pure A/D input uses the shorter lateral slide-dash only while View Lock is
active. Unlocked camera-relative dodges always use the forward-roll profile.

Args:
    input_code (string): Validated eight-way dodge input code.

Returns:
    DodgeMovementProfile: Server-owned distance, duration, and speed curve.
]]
local function get_dodge_profile(
    input_code: string,
    view_locked: boolean
): DodgeMovementProfile
    if DodgeDirectionRules.should_use_lateral_profile(
        input_code,
        view_locked
    ) then
        return {
            distance = CombatConfig.DEFENSE.SIDE_DASH_DISTANCE_STUDS,
            duration = CombatConfig.DEFENSE.SIDE_DASH_DURATION_SECONDS,
            start_speed_multiplier = CombatConfig.DEFENSE
                .SIDE_DASH_START_SPEED_MULTIPLIER,
            end_speed_multiplier = CombatConfig.DEFENSE
                .SIDE_DASH_END_SPEED_MULTIPLIER,
        }
    end

    return {
        distance = CombatConfig.DEFENSE.DODGE_DISTANCE_STUDS,
        duration = CombatConfig.DEFENSE.DODGE_DURATION_SECONDS,
        start_speed_multiplier = CombatConfig.DEFENSE
            .DODGE_START_SPEED_MULTIPLIER,
        end_speed_multiplier = CombatConfig.DEFENSE
            .DODGE_END_SPEED_MULTIPLIER,
    }
end


--[[
Returns the current dodge speed from normalized movement progress.

Args:
    movement (DodgeMovementRecord): Active dodge movement profile.
    progress (number): Normalized dodge progress from zero to one.

Returns:
    number: Desired planar dodge speed in studs per second.
]]
local function get_dodge_speed(
    movement: DodgeMovementRecord,
    progress: number
): number
    local clamped = math.clamp(progress, 0, 1)
    local eased = clamped * clamped * (3 - (2 * clamped))
    local multiplier = movement.start_speed_multiplier
        + (
            (movement.end_speed_multiplier
                - movement.start_speed_multiplier)
            * eased
        )
    local average_speed = movement.distance / movement.duration

    return average_speed * multiplier
end


--[[
Stops and removes the active dodge movement for one player.

Args:
    player (Player): Player whose dodge movement is stopped.

Returns:
    None.
]]
local function stop_dodge_movement(player: Player)
    local movement = dodge_movements[player]

    if not movement then
        return
    end

    dodge_movements[player] = nil

    if movement.heartbeat_connection then
        movement.heartbeat_connection:Disconnect()
        movement.heartbeat_connection = nil
    end

    if movement.velocity.Parent then
        movement.velocity:Destroy()
    end

    if movement.character.Parent then
        movement.character:SetAttribute(
            CombatConfig.DEFENSE.DODGE_DIRECTION_ATTRIBUTE,
            Vector3.zero
        )
        movement.character:SetAttribute(
            CombatConfig.DEFENSE.DODGE_STYLE_ATTRIBUTE,
            ""
        )
        movement.character:SetAttribute(
            CombatConfig.DEFENSE.DODGE_VIEW_LOCKED_ATTRIBUTE,
            false
        )
    end
end


--[[
Updates one steerable dodge movement from current movement input and facing.

Args:
    movement (DodgeMovementRecord): Active dodge movement record.
    delta_time (number): Server Heartbeat delta in seconds.

Returns:
    None.
]]
local function update_dodge_movement(
    movement: DodgeMovementRecord,
    delta_time: number
)
    if dodge_movements[movement.player] ~= movement then
        return
    end

    if movement.player.Character ~= movement.character
        or movement.root_part.Parent ~= movement.character
        or not movement.velocity.Parent then
        stop_dodge_movement(movement.player)
        return
    end

    local elapsed = os.clock() - movement.started_at

    if elapsed >= movement.duration then
        stop_dodge_movement(movement.player)
        return
    end

    local root_part = movement.root_part
    local direction = movement.unlocked_direction

    if DodgeDirectionRules.should_follow_facing_during_dodge(
        movement.view_locked
    ) then
        direction = DodgeDirectionRules.resolve(
            movement.input_code,
            root_part.CFrame.LookVector
        )
    elseif not direction then
        direction = DodgeDirectionRules.resolve(
            movement.input_code,
            root_part.CFrame.LookVector
        )
    end

    movement.character:SetAttribute(
        CombatConfig.DEFENSE.DODGE_DIRECTION_ATTRIBUTE,
        direction
    )

    local progress = elapsed / movement.duration
    local speed = get_dodge_speed(movement, progress)
    local safe_delta = math.max(delta_time, 1 / 240)
    local probe_size = DodgeClearanceRules.get_probe_size(
        root_part.Size,
        movement.clearance
    )

    local overlap_params = OverlapParams.new()
    overlap_params.FilterType =
        Enum.RaycastFilterType.Exclude
    overlap_params.FilterDescendantsInstances = {
        movement.character,
    }
    overlap_params.RespectCanCollide = true
    overlap_params.MaxParts = 1

    local initially_blocked =
        #Workspace:GetPartBoundsInBox(
            root_part.CFrame,
            probe_size,
            overlap_params
        ) > 0

    local safety_margin =
        DodgeClearanceRules.get_safety_margin(
            movement.clearance
        )
    local probe_distance =
        (speed * safe_delta) + safety_margin

    movement.raycast_params.RespectCanCollide = true

    local result = Workspace:Blockcast(
        root_part.CFrame,
        probe_size,
        direction * probe_distance,
        movement.raycast_params
    )

    speed = DodgeClearanceRules.limit_speed(
        speed,
        safe_delta,
        if result then result.Distance else nil,
        movement.clearance,
        initially_blocked
    )

    movement.velocity.PlaneVelocity = Vector2.new(
        direction.X * speed,
        direction.Z * speed
    )
end


--[[
Runs one collision-safe View-Lock-aware dodge movement.

With View Lock active, the server re-resolves the validated eight-way input
against current facing every frame so camera turns can steer the dodge. With
View Lock off, the server keeps one validated camera-relative world direction.
The local network owner handles the brief visual turn while movement begins.

Args:
    player (Player): Player performing the dodge.

Returns:
    None.
]]
local function apply_dodge_step(
    player: Player,
    input_code: string,
    profile: DodgeMovementProfile,
    view_locked: boolean,
    unlocked_direction: Vector3?
)
    local character = player.Character
    local _, root_part = get_character_parts(player)

    if not character or not root_part then
        return
    end

    stop_dodge_movement(player)

    local attachment = root_part:FindFirstChild(
        "CombatDodgeAttachment"
    )

    if not attachment
        or not attachment:IsA("Attachment") then
        attachment = Instance.new("Attachment")
        attachment.Name = "CombatDodgeAttachment"
        attachment.Parent = root_part
    end

    local old_velocity = root_part:FindFirstChild(
        "CombatDodgeVelocity"
    )

    if old_velocity then
        old_velocity:Destroy()
    end

    local velocity = Instance.new("LinearVelocity")

    velocity.Name = "CombatDodgeVelocity"
    velocity.Attachment0 = attachment
    velocity.RelativeTo =
        Enum.ActuatorRelativeTo.World
    velocity.VelocityConstraintMode =
        Enum.VelocityConstraintMode.Plane
    velocity.PrimaryTangentAxis =
        Vector3.new(1, 0, 0)
    velocity.SecondaryTangentAxis =
        Vector3.new(0, 0, 1)
    velocity.ForceLimitsEnabled = false
    velocity.Parent = root_part

    local raycast_params = RaycastParams.new()

    raycast_params.FilterType =
        Enum.RaycastFilterType.Exclude
    raycast_params.FilterDescendantsInstances = {
        character,
    }
    raycast_params.IgnoreWater = true

    local movement: DodgeMovementRecord = {
        player = player,
        character = character,
        root_part = root_part,
        velocity = velocity,
        raycast_params = raycast_params,
        started_at = os.clock(),
        distance = profile.distance,
        duration = profile.duration,
        start_speed_multiplier = profile.start_speed_multiplier,
        end_speed_multiplier = profile.end_speed_multiplier,
        clearance = CombatConfig.DEFENSE
            .DODGE_WALL_CLEARANCE_STUDS,
        input_code = input_code,
        view_locked = view_locked,
        unlocked_direction = unlocked_direction,
        heartbeat_connection = nil,
    }

    dodge_movements[player] = movement
    movement.heartbeat_connection = RunService.Heartbeat:Connect(
        function(delta_time: number)
            update_dodge_movement(movement, delta_time)
        end
    )

    update_dodge_movement(movement, 1 / 60)
end


--[[
Checks whether a delayed callback still belongs to the current attack.

Args:
    player (Player): Player owning the attack.
    record (PlayerCombatState): Combat record captured by the callback.
    sequence_id (number): Attack sequence identifier captured earlier.
    expected_state (string): State required for the callback to continue.

Returns:
    boolean: True when the callback is still current and valid.
]]
local function sequence_is_current(
    player: Player,
    record: PlayerCombatState,
    sequence_id: number,
    expected_state: string
): boolean
    return player:GetAttribute(
            CombatConfig.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
        ) ~= false
        and player_states[player] == record
        and record.sequence_id == sequence_id
        and record.state_name == expected_state
end


local start_attack


--[[
Finishes recovery, continuing a buffered chain or returning to movement.

Args:
    player (Player): Player whose attack is ending.
    record (PlayerCombatState): Authoritative combat record.
    sequence_id (number): Current attack sequence identifier.

Returns:
    None.
]]
local function finish_attack(
    player: Player,
    record: PlayerCombatState,
    sequence_id: number
)
    if not sequence_is_current(
        player,
        record,
        sequence_id,
        State.RECOVERY
    ) then
        return
    end

    local current_attack_id = record.current_attack_id

    if not current_attack_id then
        return
    end

    if current_attack_id == "RangerArrow" then
        record.ranger_draw_tier = nil
        record.next_attack_id = BasicAttack.ATTACK_ORDER[1]
        record.combo_expires_at = 0
        set_state(player, record, State.LOCOMOTION)
        record.current_attack_id = nil
        update_character_attributes(player, record)
        return
    end

    local next_attack_id = StateRules.get_next_attack_id(
        current_attack_id,
        BasicAttack.ATTACK_ORDER
    )

    if record.queued_attack then
        record.queued_attack = false
        update_character_attributes(player, record)
        start_attack(player, record, next_attack_id)
        return
    end

    record.next_attack_id = next_attack_id
    record.combo_expires_at = os.clock()
        + BasicAttack.COMBO_RESET_SECONDS

    set_state(player, record, State.LOCOMOTION)
    record.current_attack_id = nil
    update_character_attributes(player, record)
end


--[[
Enters recovery and schedules the end of the current attack.

Args:
    player (Player): Player performing the attack.
    record (PlayerCombatState): Authoritative combat record.
    sequence_id (number): Current attack sequence identifier.
    attack_definition (table): Configuration for the current attack.

Returns:
    None.
]]
local function enter_recovery(
    player: Player,
    record: PlayerCombatState,
    sequence_id: number,
    attack_definition: any
)
    if not sequence_is_current(
        player,
        record,
        sequence_id,
        State.ACTIVE
    ) then
        return
    end

    if not set_state(player, record, State.RECOVERY) then
        return
    end

    task.delay(attack_definition.RECOVERY_SECONDS, function()
        finish_attack(player, record, sequence_id)
    end)
end


--[[
Enters the active hit phase and applies the prototype forward step.

Args:
    player (Player): Player performing the attack.
    record (PlayerCombatState): Authoritative combat record.
    sequence_id (number): Current attack sequence identifier.
    attack_definition (table): Configuration for the current attack.

Returns:
    None.
]]
local function enter_active(
    player: Player,
    record: PlayerCombatState,
    sequence_id: number,
    attack_definition: any
)
    if not sequence_is_current(
        player,
        record,
        sequence_id,
        State.WIND_UP
    ) then
        return
    end

    if not set_state(player, record, State.ACTIVE) then
        return
    end

    local character = player.Character
    local attack_id = record.current_attack_id

    if character and attack_id then
        local weapon_tags =
            ProgressionRuntimeState.get_weapon_tags(
                player.UserId
            )

        if weapon_tags.ArcaneWand == true then
            local fired = SpiritOrbService.fire({
                attacker = player,
                character = character,
                attack_id = attack_id,
                attack_definition = attack_definition,
                magical_multiplier =
                    ProgressionRuntimeState
                        .get_magical_multiplier(
                            player.UserId
                        ),
                critical_chance =
                    ProgressionRuntimeState
                        .get_critical_chance(
                            player.UserId
                        ),
                critical_damage_multiplier =
                    ProgressionRuntimeState
                        .get_critical_damage_multiplier(
                            player.UserId
                        ),
                sequence_id = sequence_id,
            })

            CombatValidationService.emit(
                player,
                "SPIRIT_ORB",
                if fired then "FIRED" else "REJECT",
                attack_id,
                sequence_id
            )
        elseif weapon_tags.Longbow == true
            and attack_id == "RangerArrow" then
            local draw_tier = record.ranger_draw_tier
                or RangerDrawRules.classify(0)
            local fired = RangerCombatService.fire_basic(
                player,
                character,
                draw_tier,
                sequence_id
            )

            CombatValidationService.emit(
                player,
                "RANGER_ARROW",
                if fired then "FIRED" else "REJECT",
                tostring(draw_tier.Tier),
                sequence_id
            )
        else
            -- Sword and blunt use current prototype timing; a genuine
            -- Polearm receives its own long forward fan and per-swing cap.
            -- A polearm is two-handed and cannot equip an OffHand shield.
            local is_melee_weapon =
                weapon_tags.OneHandedSword == true
                or weapon_tags.OneHandedBlunt == true
                or weapon_tags.Polearm == true
            local melee_definition = attack_definition
            local base_damage =
                CombatConfig.PROTOTYPE_WEAPON.BASE_DAMAGE
                    * ProgressionRuntimeState
                        .get_physical_multiplier(
                            player.UserId
                        )

            if weapon_tags.Polearm == true then
                melee_definition = {}
                for key, value in pairs(attack_definition) do
                    melee_definition[key] = value
                end
                melee_definition.FORWARD_STEP_STUDS = math.min(
                    tonumber(attack_definition.FORWARD_STEP_STUDS) or 0,
                    0.70
                )
                melee_definition.REACH_STUDS = 7.0
                melee_definition.ARC_DEGREES = 130
                melee_definition.MAX_TARGETS = 5
                    + ProgressionRuntimeState.get_polearm_extra_targets(
                        player.UserId
                    )
                melee_definition.HITBOX = {
                    SIZE = Vector3.new(10.0, 5.0, 7.0),
                    FORWARD_OFFSET = 3.5,
                    SAMPLE_COUNT = 3,
                }
            elseif not is_melee_weapon then
                melee_definition = {}

                for key, value in pairs(attack_definition) do
                    melee_definition[key] = value
                end

                melee_definition.FORWARD_STEP_STUDS = math.min(
                    tonumber(attack_definition.FORWARD_STEP_STUDS) or 0,
                    0.55
                )
                melee_definition.REACH_STUDS = 4.0
                melee_definition.ARC_DEGREES = 85
                melee_definition.HITBOX = {
                    SIZE = Vector3.new(7.0, 4.5, 4.0),
                    FORWARD_OFFSET = 2.0,
                    SAMPLE_COUNT = 3,
                }
                base_damage =
                    4
                    * ProgressionRuntimeState
                        .get_physical_multiplier(
                            player.UserId
                        )
            end

            apply_forward_step(
                player,
                melee_definition.FORWARD_STEP_STUDS,
                melee_definition
            )

            MeleeHitService.begin_active_window({
                attacker = player,
                character = character,
                attack_id = attack_id,
                attack_definition = melee_definition,
                base_damage = base_damage,
                critical_chance =
                    ProgressionRuntimeState
                        .get_critical_chance(
                            player.UserId
                        ),
                critical_damage_multiplier =
                    ProgressionRuntimeState
                        .get_critical_damage_multiplier(
                            player.UserId
                        ),
                sequence_id = sequence_id,
                is_cancelled = function()
                    return not sequence_is_current(
                        player,
                        record,
                        sequence_id,
                        State.ACTIVE
                    )
                end,
                on_candidate_rejected = function(target: Model, reason: string)
                    CombatValidationService.emit(
                        player,
                        "HIT",
                        "REJECT",
                        attack_id .. " " .. target.Name .. " " .. reason,
                        sequence_id
                    )
                end,
                on_target_accepted = function(target: Model)
                    CombatValidationService.emit(
                        player,
                        "HIT",
                        "CONFIRMED",
                        attack_id .. " -> " .. target.Name,
                        sequence_id
                    )
                end,
                on_window_cancelled = function()
                    CombatValidationService.emit(
                        player,
                        "HIT_WINDOW",
                        "CANCELLED",
                        attack_id,
                        sequence_id
                    )
                end,
            })
        end
    end

    task.delay(attack_definition.ACTIVE_SECONDS, function()
        enter_recovery(
            player,
            record,
            sequence_id,
            attack_definition
        )
    end)
end

--[[
Starts one authoritative basic attack and schedules its wind-up.

Args:
    player (Player): Player performing the attack.
    record (PlayerCombatState): Authoritative combat record.
    attack_id (string): Server-selected attack identifier.

Returns:
    None.
]]
start_attack = function(
    player: Player,
    record: PlayerCombatState,
    attack_id: string
)
    local base_attack_definition =
        BasicAttack.ATTACKS[attack_id]

    if not base_attack_definition then
        warn("[Combat] Unknown attack id: " .. attack_id)
        return
    end

    local attack_rate =
        ProgressionRuntimeState
            .get_basic_attack_rate(
                player.UserId
            )

    local attack_definition =
        BasicAttackTimingRules
            .scale_definition(
                base_attack_definition,
                attack_rate
            )

    record.sequence_id += 1
    record.current_attack_id = attack_id
    record.current_skill_id = nil
    record.queued_attack = false

    local sequence_id = record.sequence_id

    if not set_state(player, record, State.WIND_UP) then
        return
    end

    CombatValidationService.emit(
        player,
        "ATTACK",
        "ACCEPT",
        attack_id,
        sequence_id
    )

    task.delay(attack_definition.WIND_UP_SECONDS, function()
        enter_active(
            player,
            record,
            sequence_id,
            attack_definition
        )
    end)
end


--[[
Starts one Longbow release using a server-classified draw tier.

Only the short release/active/recovery definition is racial-rate scaled. The
0.45/0.80-second draw thresholds were already measured before this point and
remain identical for Human and Elf.

Args:
    player (Player): Ranger releasing the Longbow.
    record (PlayerCombatState): Current authoritative combat record.
    draw_tier (any): Server-classified draw tier.

Returns:
    None.
]]
local function start_ranger_release(
    player: Player,
    record: PlayerCombatState,
    draw_tier: any
)
    local attack_rate =
        ProgressionRuntimeState.get_basic_attack_rate(player.UserId)
    local attack_definition = BasicAttackTimingRules.scale_definition(
        CombatConfig.RANGER_LONGBOW.RELEASE,
        attack_rate
    )

    record.sequence_id += 1
    record.current_attack_id = "RangerArrow"
    record.current_skill_id = nil
    record.queued_attack = false
    record.ranger_draw_tier = draw_tier

    local sequence_id = record.sequence_id

    if not set_state(player, record, State.WIND_UP) then
        record.current_attack_id = nil
        record.ranger_draw_tier = nil
        update_character_attributes(player, record)
        return
    end

    CombatValidationService.emit(
        player,
        "RANGER_DRAW",
        "RELEASE",
        tostring(draw_tier.Tier),
        sequence_id
    )

    task.delay(attack_definition.WIND_UP_SECONDS, function()
        enter_active(
            player,
            record,
            sequence_id,
            attack_definition
        )
    end)
end

--[[
Handles one Longbow DrawStart/DrawRelease/DrawCancel request.

Args:
    player (Player): Ranger sending held basic-attack intent.
    record (PlayerCombatState): Current authoritative combat record.
    requested_action (any): Untrusted draw intent label.

Returns:
    None.
]]
local function handle_longbow_attack_request(
    player: Player,
    record: PlayerCombatState,
    requested_action: any
)
    if requested_action == "DrawCancel" then
        local cancelled = RangerDrawService.cancel(player)
        apply_movement_scale(player, record)

        CombatValidationService.emit(
            player,
            "RANGER_DRAW",
            if cancelled then "CANCELLED" else "IGNORED",
            "ClientCancel",
            record.sequence_id
        )
        return
    end

    if record.state_name ~= State.LOCOMOTION then
        CombatValidationService.emit(
            player,
            "RANGER_DRAW",
            "REJECT",
            "State=" .. record.state_name,
            record.sequence_id
        )
        return
    end

    if requested_action == "DrawStart" then
        local character = player.Character

        if not character then
            return
        end

        if not RangerDrawService.begin(player, character) then
            CombatValidationService.emit(
                player,
                "RANGER_DRAW",
                "REJECT",
                "AlreadyDrawing",
                record.sequence_id
            )
            return
        end

        apply_movement_scale(player, record)
        CombatValidationService.emit(
            player,
            "RANGER_DRAW",
            "START",
            "ServerTimed",
            record.sequence_id
        )
        return
    end

    if requested_action == "DrawRelease" then
        local elapsed = RangerDrawService.release(player)

        if elapsed == nil then
            CombatValidationService.emit(
                player,
                "RANGER_DRAW",
                "REJECT",
                "NoActiveDraw",
                record.sequence_id
            )
            return
        end

        apply_movement_scale(player, record)
        start_ranger_release(
            player,
            record,
            RangerDrawRules.classify(elapsed)
        )
        return
    end

    CombatValidationService.emit(
        player,
        "RANGER_DRAW",
        "REJECT",
        "MalformedRequest",
        record.sequence_id
    )
end

--[[
Handles a validated basic-attack request without trusting client attack data.

Args:
    player (Player): Player who requested a basic attack.

Returns:
    None.
]]
local function handle_attack_request(
    player: Player,
    requested_action: any
)
    if player:GetAttribute(
        CombatConfig.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
    ) == false then
        CombatValidationService.emit(
            player, "ATTACK", "REJECT", "DungeonMemberNotActive", nil
        )
        return
    end
    local record = player_states[player]

    if not record then
        return
    end

    local weapon_tags =
        ProgressionRuntimeState.get_weapon_tags(player.UserId)

    if weapon_tags.Longbow == true then
        handle_longbow_attack_request(
            player,
            record,
            requested_action
        )
        return
    end

    if record.state_name == State.LOCOMOTION then
        local attack_id = record.next_attack_id

        if os.clock() >= record.combo_expires_at then
            attack_id = BasicAttack.ATTACK_ORDER[1]
        end

        start_attack(player, record, attack_id)
        return
    end

    if record.state_name ~= State.RECOVERY then
        CombatValidationService.emit(
            player,
            "ATTACK",
            "REJECT",
            "State=" .. record.state_name,
            record.sequence_id
        )
        return
    end

    local current_attack_id = record.current_attack_id

    if not current_attack_id or record.queued_attack then
        CombatValidationService.emit(
            player,
            "ATTACK",
            "REJECT",
            "BufferUnavailable",
            record.sequence_id
        )
        return
    end

    local base_attack_definition =
        BasicAttack.ATTACKS[
            current_attack_id
        ]

    if not base_attack_definition then
        return
    end

    local attack_definition =
        BasicAttackTimingRules
            .scale_definition(
                base_attack_definition,
                ProgressionRuntimeState
                    .get_basic_attack_rate(
                        player.UserId
                    )
            )

    local recovery_elapsed =
        os.clock() - record.state_started_at

    local buffer_open =
        StateRules.is_buffer_window_open(
            recovery_elapsed,
            attack_definition.RECOVERY_SECONDS,
            BasicAttack.COMBO_BUFFER_SECONDS
        )

    if buffer_open then
        record.queued_attack = true
        update_character_attributes(player, record)
        CombatValidationService.emit(
            player,
            "ATTACK",
            "BUFFERED",
            current_attack_id,
            record.sequence_id
        )
    else
        CombatValidationService.emit(
            player,
            "ATTACK",
            "REJECT",
            "BufferClosed",
            record.sequence_id
        )
    end
end


--[[Returns server-observed weapon tags for the currently equipped Tool.]]
local function get_equipped_weapon_tags(player: Player): {[string]: boolean}
    local tags: {[string]: boolean} = {}
    local character = player.Character
    if not character then return tags end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            if child:GetAttribute("WeaponTagOneHandedSword") == true
                or child.Name == "PrototypeSword" then
                tags.OneHandedSword = true
            end
        end
    end
    return tags
end


--[[
Applies the server-owned health and stagger effects of Shield Bash.

Args:
    player (Player): Player who performed Shield Bash.
    character (Model): Attacking character model.
    skill_definition (table): Authoritative Shield Bash definition.
    target (Model): Valid NPC target accepted by melee acquisition.

Returns:
    None.
]]
local function apply_shield_bash_target(
    player: Player,
    character: Model,
    skill_definition: any,
    target: Model,
    sequence_id: number
)
    local applied_damage = DamageService.apply_damage({
        attacker = player,
        attacker_character = character,
        target = target,
        source_kind = "Skill",
        source_id = skill_definition.ID,
        attack_id = nil,
        base_damage = skill_definition.BASE_DAMAGE,
        multiplier = ProgressionRuntimeState.get_physical_multiplier(player.UserId),
        sequence_id = sequence_id,
    })

    local already_staggered = StaggerService.is_staggered(target)
    StaggerService.apply(target, skill_definition.STAGGER_SECONDS)
    DungeonProgressionBridge.award_damage(player, skill_definition.ID, target, applied_damage, 1)
    DungeonProgressionBridge.award_control(player, skill_definition.ID, target, "Stagger", not already_staggered)
end


--[[Applies one server-authoritative Arc Slash target hit.]]
local function apply_arc_slash_target(
    player: Player,
    character: Model,
    skill_definition: any,
    target: Model,
    sequence_id: number,
    target_index: number
)
    local applied_damage = DamageService.apply_damage({
        attacker = player,
        attacker_character = character,
        target = target,
        source_kind = "Skill",
        source_id = skill_definition.ID,
        attack_id = nil,
        base_damage = skill_definition.BASE_DAMAGE,
        multiplier = ProgressionRuntimeState.get_physical_multiplier(player.UserId),
        sequence_id = sequence_id,
    })
    DungeonProgressionBridge.award_damage(
        player,
        skill_definition.ID,
        target,
        applied_damage,
        target_index
    )
end


--[[
Applies optional skill-generated threat independently of health damage.

A future Taunt-style skill can set TAUNT_BONUS_THREAT while keeping
BASE_DAMAGE at zero. The server then moves that player above the current
threat leader for the exact accepted NPC target.

Args:
    player (Player): Authenticated skill user.
    skill_definition (table): Authoritative server skill definition.
    target (Model): Server-accepted hostile NPC target.

Returns:
    None.
]]
local function apply_skill_threat(
    player: Player,
    skill_definition: any,
    target: Model
)
    local fraction = tonumber(
        skill_definition.THREAT_REDUCTION_FRACTION
    ) or 0
    if fraction > 0 and fraction < math.huge
        and (skill_definition.BASE_DAMAGE or 0) == 0
    then
        local removed = ThreatService.reduce_threat(
            target, player, fraction
        )
        if removed > 0 then
            DungeonProgressionBridge.award_control(
                player, skill_definition.ID, target, "Charm", true
            )
        end
        CombatValidationService.emit(
            player, "THREAT", "CHARM",
            skill_definition.ID .. " -> " .. target.Name, nil
        )
        return
    end

    local bonus = tonumber(skill_definition.TAUNT_BONUS_THREAT) or 0
    if bonus <= 0 or bonus >= math.huge then
        return
    end

    ThreatService.taunt(target, player, bonus)
    -- Successful zero-damage taunts must earn skill mastery through
    -- meaningful server-confirmed control, not damage or spam.
    -- The encounter bridge enforces active membership and its per-skill cap.
    if (skill_definition.BASE_DAMAGE or 0) == 0 then
        DungeonProgressionBridge.award_control(
            player, skill_definition.ID, target, "Taunt", true
        )
    end
    CombatValidationService.emit(
        player,
        "THREAT",
        "TAUNT",
        skill_definition.ID .. " -> " .. target.Name,
        nil
    )
end


local function apply_rogue_melee_target(
    player: Player,
    character: Model,
    skill_definition: any,
    target: Model,
    sequence_id: number,
    target_index: number
)
    local multiplier = ProgressionRuntimeState.get_physical_multiplier(
        player.UserId
    )

    local attacker_root = character:FindFirstChild("HumanoidRootPart")
    local target_root = target:FindFirstChild("HumanoidRootPart")
    local rear_multiplier = tonumber(skill_definition.REAR_MULTIPLIER) or 1
    if rear_multiplier > 1
        and attacker_root and attacker_root:IsA("BasePart")
        and target_root and target_root:IsA("BasePart")
    then
        local offset = attacker_root.Position - target_root.Position
        local planar = Vector3.new(offset.X, 0, offset.Z)
        local facing = Vector3.new(
            target_root.CFrame.LookVector.X,
            0,
            target_root.CFrame.LookVector.Z
        )
        if planar.Magnitude > 0.001
            and facing.Magnitude > 0.001
            and facing.Unit:Dot(planar.Unit) < -0.35
        then
            multiplier *= rear_multiplier
        end
    end

    local exposed_until = tonumber(target:GetAttribute("RogueExposeUntil")) or 0
    if exposed_until > os.clock() then
        multiplier *= 1.15
    end

    local critical_chance = ProgressionRuntimeState.get_critical_chance(
        player.UserId
    )
    local focus_rank = ProgressionRuntimeState.get_skill_rank(
        player.UserId,
        "CriticalFocus"
    )
    local mastery_rank = ProgressionRuntimeState.get_skill_rank(
        player.UserId,
        "DuelistCriticalMastery"
    )
    critical_chance = math.clamp(
        critical_chance + focus_rank * 0.01 + mastery_rank * 0.015,
        0,
        1
    )

    local applied_damage = DamageService.apply_damage({
        attacker = player,
        attacker_character = character,
        target = target,
        source_kind = "Skill",
        source_id = skill_definition.ID,
        attack_id = nil,
        base_damage = skill_definition.BASE_DAMAGE,
        multiplier = multiplier,
        sequence_id = sequence_id,
        critical_chance = critical_chance,
        critical_damage_multiplier = ProgressionRuntimeState
            .get_critical_damage_multiplier(player.UserId),
    })

    -- Only a confirmed damaging melee hit may apply the periodic
    -- effect. The service owns all later ticks and attribution.
    local bleed_damage = tonumber(
        skill_definition.BLEED_TICK_DAMAGE
    ) or 0
    if applied_damage > 0 and bleed_damage > 0 then
        RogueBleedService.apply(
            player, target, skill_definition.ID,
            bleed_damage,
            tonumber(skill_definition.BLEED_TICK_COUNT) or 0,
            tonumber(skill_definition.BLEED_TICK_INTERVAL) or 0
        )
    end

    local expose_seconds = tonumber(skill_definition.EXPOSE_SECONDS) or 0
    if expose_seconds > 0 then
        target:SetAttribute("RogueExposeUntil", os.clock() + expose_seconds)
    end

    local stagger_seconds = tonumber(
        skill_definition.STAGGER_SECONDS
    ) or 0
    if stagger_seconds > 0 then
        local target_humanoid = target:FindFirstChildOfClass("Humanoid")
        if target_humanoid and target_humanoid.Health > 0 then
            local already_staggered = StaggerService.is_staggered(target)
            -- Original Warrior blunt shock cannot re-stun or refresh
            -- a currently dazed target. Other authored skills retain
            -- their existing independent stagger behavior.
            local may_stagger = skill_definition.NO_STAGGER_REFRESH ~= true
                or (applied_damage > 0 and not already_staggered)
            if may_stagger then
                StaggerService.apply(target, stagger_seconds)
                DungeonProgressionBridge.award_control(
                    player, skill_definition.ID, target,
                    "Stagger", not already_staggered
                )
            end
        end
    end

    DungeonProgressionBridge.award_damage(
        player,
        skill_definition.ID,
        target,
        applied_damage,
        target_index
    )
end


--[[
Finishes active-skill recovery and returns the player to Locomotion.

Args:
    player (Player): Player whose active skill is ending.
    record (PlayerCombatState): Authoritative combat record.
    sequence_id (number): Skill sequence identifier captured at start.

Returns:
    None.
]]
local function finish_skill(
    player: Player,
    record: PlayerCombatState,
    sequence_id: number
)
    if not sequence_is_current(
        player,
        record,
        sequence_id,
        State.RECOVERY
    ) then
        return
    end

    record.current_skill_id = nil
    record.skill_aim = nil
    set_state(player, record, State.LOCOMOTION)
end


--[[
Enters active-skill recovery and schedules the final Locomotion transition.

Args:
    player (Player): Player using the skill.
    record (PlayerCombatState): Authoritative combat record.
    sequence_id (number): Skill sequence identifier captured at start.
    skill_definition (table): Authoritative active-skill definition.

Returns:
    None.
]]
local function enter_skill_recovery(
    player: Player,
    record: PlayerCombatState,
    sequence_id: number,
    skill_definition: any
)
    if not sequence_is_current(
        player,
        record,
        sequence_id,
        State.ACTIVE
    ) then
        return
    end

    if not set_state(player, record, State.RECOVERY) then
        return
    end

    task.delay(skill_definition.RECOVERY_SECONDS, function()
        finish_skill(player, record, sequence_id)
    end)
end


--[[
Resolves a heal target from the server's current character state. An
explicit self-renewal cannot be redirected to an ally by the client.

Args:
    player (Player): Server-authenticated skill caster.
    skill_definition (any): Authoritative rank-resolved heal definition.

Returns:
    Player?: Injured caster for self-only skills, or normal allied target.
]]
local function resolve_skill_heal_target(
    player: Player,
    skill_definition: any
): Player?
    local cure_tier = tonumber(
        skill_definition.CURE_POISON_TIER
    ) or 0
    local bleed_tier = tonumber(
        skill_definition.CURE_BLEED_TIER
    ) or 0
    if bleed_tier > 0 then
        local character = player.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")
        return if skill_definition.SELF_ONLY == true
            and character ~= nil
            and character:IsDescendantOf(workspace)
            and humanoid ~= nil and humanoid.Health > 0
            and PlayerBleedStatusService.is_bleeding(character)
            then player else nil
    end
    if skill_definition.SELF_ONLY ~= true then
        return MageHealService.find_target(
            player, skill_definition.RANGE_STUDS,
            cure_tier > 0
        )
    end
    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0
        and ((cure_tier > 0
            and PoisonStatusService.is_poisoned(character))
            or (cure_tier <= 0
                and humanoid.Health < humanoid.MaxHealth))
    then
        return player
    end
    return nil
end

--[[
Enters Shield Bash active frames and starts authoritative melee acquisition.

Args:
    player (Player): Player using Shield Bash.
    record (PlayerCombatState): Authoritative combat record.
    sequence_id (number): Skill sequence identifier captured at start.
    skill_definition (table): Authoritative Shield Bash definition.

Returns:
    None.
]]
local function enter_skill_active(
    player: Player,
    record: PlayerCombatState,
    sequence_id: number,
    skill_definition: any
)
    if not sequence_is_current(
        player,
        record,
        sequence_id,
        State.WIND_UP
    ) then
        return
    end

    -- All Mage projectile variants spend mana on release, including
    -- newly trained advanced spells. Never leave an alternate ID free.
    local is_magic_projectile =
        skill_definition.KIND == "MagicProjectile"

    if is_magic_projectile then
        if not ManaService.try_spend(
            player,
            skill_definition.MANA_COST
        ) then
            clear_wind_strike_charge(player)
            record.current_skill_id = nil
            set_state(player, record, State.LOCOMOTION)
            CombatValidationService.emit(
                player,
                "SKILL",
                "REJECT",
                "ManaAtRelease",
                sequence_id
            )
            return
        end

        SkillCooldownService.start(
            player,
            skill_definition.ID,
            skill_definition.COOLDOWN_SECONDS
        )
        clear_wind_strike_charge(player)
    end

    if not set_state(player, record, State.ACTIVE) then
        return
    end

    local character = player.Character

    if character then
        local evasion_seconds = tonumber(
            skill_definition.EVASION_IFRAME_SECONDS
        ) or 0
        if evasion_seconds > 0 then
            DefenseService.begin_dodge(player, character, os.clock())
            task.delay(evasion_seconds, function()
                if player.Character == character then
                    DefenseService.end_dodge(player)
                end
            end)
        end

        local aggro_seconds = tonumber(
            skill_definition.AGGRO_SUPPRESS_SECONDS
        ) or 0
        if aggro_seconds > 0 then
            character:SetAttribute(
                "RogueThreatDropUntil",
                os.clock() + aggro_seconds
            )
        end
    end

    if character and skill_definition.KIND == "Melee" then
        apply_forward_step(
            player,
            skill_definition.FORWARD_STEP_STUDS,
            skill_definition
        )

        MeleeHitService.begin_active_window({
            attacker = player,
            character = character,
            attack_id = skill_definition.ID,
            attack_definition = skill_definition,
            base_damage = skill_definition.BASE_DAMAGE,
            sequence_id = sequence_id,
            is_cancelled = function()
                return not sequence_is_current(
                    player,
                    record,
                    sequence_id,
                    State.ACTIVE
                )
            end,
            on_target = (function()
                local target_index = 0
                return function(target: Model)
                    target_index += 1
                    if ((skill_definition.TAUNT_BONUS_THREAT or 0) > 0
                        or (skill_definition.THREAT_REDUCTION_FRACTION
                            or 0) > 0)
                        and skill_definition.BASE_DAMAGE == 0 then
                        -- Only the first server-confirmed hostile target
                        -- receives threat. Taunt causes zero health damage
                        -- and cannot inflate reward contributions.
                        if target_index > 1 then
                            return
                        end
                    elseif skill_definition.ID == "ArcSlash" then
                        apply_arc_slash_target(
                            player,
                            character,
                            skill_definition,
                            target,
                            sequence_id,
                            target_index
                        )
                    elseif skill_definition.ID == "ShieldBash"
                        or skill_definition.ID == "ThornwardenBash"
                        or skill_definition.ID == "GuardBreaker" then
                        apply_shield_bash_target(
                            player,
                            character,
                            skill_definition,
                            target,
                            sequence_id
                        )
                    else
                        apply_rogue_melee_target(
                            player,
                            character,
                            skill_definition,
                            target,
                            sequence_id,
                            target_index
                        )
                    end
                    apply_skill_threat(
                        player,
                        skill_definition,
                        target
                    )
                end
            end)(),
            on_candidate_rejected = function(target: Model, reason: string)
                CombatValidationService.emit(
                    player,
                    "HIT",
                    "REJECT",
                    skill_definition.ID .. " " .. target.Name .. " " .. reason,
                    sequence_id
                )
            end,
            on_target_accepted = function(target: Model)
                CombatValidationService.emit(
                    player,
                    "HIT",
                    "CONFIRMED",
                    skill_definition.ID .. " -> " .. target.Name,
                    sequence_id
                )
            end,
            on_window_cancelled = function()
                CombatValidationService.emit(
                    player,
                    "HIT_WINDOW",
                    "CANCELLED",
                    skill_definition.ID,
                    sequence_id
                )
            end,
        })
    elseif character and skill_definition.KIND == "MagicProjectile" then
        local fired = WindStrikeService.fire({
            attacker = player,
            character = character,
            skill_definition = skill_definition,
            magical_multiplier =
                ProgressionRuntimeState
                    .get_magical_multiplier(player.UserId),
            critical_chance =
                ProgressionRuntimeState
                    .get_critical_chance(player.UserId),
            critical_damage_multiplier =
                ProgressionRuntimeState
                    .get_critical_damage_multiplier(player.UserId),
            sequence_id = sequence_id,
        })
        CombatValidationService.emit(
            player,
            "WIND_STRIKE",
            if fired then "FIRED" else "REJECT",
            skill_definition.ID,
            sequence_id
        )
    elseif character and skill_definition.KIND == "Ward" then
        local target = WardService.find_target(
            player,
            skill_definition.RANGE_STUDS
        )
        local amount =
            skill_definition.WARD_AMOUNT
            * ProgressionRuntimeState
                .get_support_multiplier(
                    player.UserId
                )

        if target and WardService.apply_ward(
            player,
            target,
            amount,
            skill_definition.DURATION_SECONDS
        ) then
            CombatValidationService.emit(
                player,
                "WARD",
                "APPLIED",
                string.format(
                    "%s -> %s %.1f",
                    skill_definition.ID,
                    target.Name,
                    amount
                ),
                sequence_id
            )
        else
            CombatValidationService.emit(
                player,
                "WARD",
                "REJECT",
                "TargetUnavailable",
                sequence_id
            )
        end
    elseif character and skill_definition.KIND == "RangerProjectile" then
        local fired = RangerCombatService.fire_projectile_skill(
            player,
            character,
            skill_definition,
            sequence_id
        )

        CombatValidationService.emit(
            player,
            "RANGER_PROJECTILE",
            if fired then "FIRED" else "REJECT",
            skill_definition.ID,
            sequence_id
        )
    elseif character and skill_definition.KIND == "RangerVolley" then
        local center = record.skill_aim
        record.skill_aim = nil
        local cast = false

        if center then
            cast = RangerCombatService.cast_volley(
                player,
                character,
                skill_definition,
                center,
                sequence_id
            )
        end

        CombatValidationService.emit(
            player,
            "VOLLEY",
            if cast then "CAST" else "REJECT",
            skill_definition.ID,
            sequence_id
        )
    elseif character and skill_definition.KIND == "Buff" then
        local applied = CombatStatusService.apply_self(
            player, skill_definition
        )
        if applied and skill_definition.BUFF_KIND == "Movement" then
            -- Combat state transitions remain the sole authority for
            -- immobilization. Apply immediately and recompute on expiry.
            apply_movement_scale(player, record)
            local buff_character = character
            task.delay(skill_definition.BUFF_SECONDS + 0.05, function()
                if player.Character == buff_character
                    and player_states[player] == record then
                    apply_movement_scale(player, record)
                end
            end)
        end
        CombatValidationService.emit(
            player,
            "BUFF",
            if applied then "APPLIED" else "REJECT",
            skill_definition.ID,
            sequence_id
        )
    elseif character and skill_definition.KIND == "MageHeal" then
        if skill_definition.PARTY_HEAL == true then
            local total_heal = skill_definition.TOTAL_HEAL
                * ProgressionRuntimeState.get_heal_multiplier(
                    player.UserId
                )
            local applied, members, effective = PartyHealService.cast(
                player, total_heal, skill_definition.RANGE_STUDS,
                skill_definition.ID
            )
            CombatValidationService.emit(
                player, "MAGE_PARTY_HEAL",
                if applied then "APPLIED" else "REJECT",
                if applied then string.format(
                    "%s members=%d actual=%.1f",
                    skill_definition.ID, members, effective
                ) else "NoEligiblePartyMember",
                sequence_id
            )
            task.delay(skill_definition.ACTIVE_SECONDS, function()
                enter_skill_recovery(
                    player, record, sequence_id, skill_definition
                )
            end)
            return
        end
        local target = resolve_skill_heal_target(
            player, skill_definition
        )
        local total_heal =
            skill_definition.TOTAL_HEAL
            * ProgressionRuntimeState
                .get_heal_multiplier(
                    player.UserId
                )

        if target and (tonumber(
            skill_definition.CURE_BLEED_TIER
        ) or 0) > 0 then
            local cleared = PlayerBleedStatusService.cure(
                target.Character, skill_definition.CURE_BLEED_TIER
            )
            CombatValidationService.emit(
                player, "MAGE_CURE",
                if cleared then "APPLIED" else "REJECT",
                if cleared then skill_definition.ID
                    else "BleedUnavailable",
                sequence_id
            )
        elseif target and (tonumber(
            skill_definition.CURE_POISON_TIER
        ) or 0) > 0 then
            local removed = PoisonStatusService.cure(
                target.Character,
                skill_definition.CURE_POISON_TIER
            )
            CombatValidationService.emit(
                player,
                "MAGE_CURE",
                if removed then "APPLIED" else "REJECT",
                if removed then skill_definition.ID
                    else "PoisonUnavailable",
                sequence_id
            )
        elseif target then
            local cast_ok, immediate_heal =
                MageHealService.cast(
                    player,
                    target,
                    total_heal,
                    ProgressionRuntimeState
                        .get_race_id(
                            player.UserId
                        ),
                    skill_definition
                )

            if cast_ok then
                CombatValidationService.emit(
                    player,
                    "MAGE_HEAL",
                    "APPLIED",
                    string.format(
                        "%s -> %s +%.1f initial",
                        skill_definition.ID,
                        target.Name,
                        immediate_heal
                    ),
                    sequence_id
                )
            else
                CombatValidationService.emit(
                    player,
                    "MAGE_HEAL",
                    "REJECT",
                    "TargetUnavailable",
                    sequence_id
                )
            end
        else
            CombatValidationService.emit(
                player,
                "MAGE_HEAL",
                "REJECT",
                "NoInjuredTarget",
                sequence_id
            )
        end
    end

    task.delay(skill_definition.ACTIVE_SECONDS, function()
        enter_skill_recovery(
            player,
            record,
            sequence_id,
            skill_definition
        )
    end)
end

--[[
Starts one authoritative active-skill sequence after request validation.

Args:
    player (Player): Player using the skill.
    record (PlayerCombatState): Authoritative combat record.
    skill_definition (table): Authoritative active-skill definition.

Returns:
    boolean: True when the skill entered WindUp.
]]
local function start_skill(
    player: Player,
    record: PlayerCombatState,
    skill_definition: any,
    skill_aim: Vector3?
): boolean
    record.sequence_id += 1
    record.current_attack_id = nil
    record.current_skill_id = skill_definition.ID
    record.skill_aim = skill_aim

    local wind_up_seconds = ProgressionRuntimeState
        .get_skill_wind_up_seconds(player.UserId, skill_definition)

    if skill_definition.ID == "WindStrike" then
        local character = player.Character
        if character then
            character:SetAttribute("WindStrikeCharging", true)
            character:SetAttribute(
                "WindStrikeChargeEndsAt",
                Workspace:GetServerTimeNow() + wind_up_seconds
            )
        end
    end

    local sequence_id = record.sequence_id

    if not set_state(player, record, State.WIND_UP) then
        clear_wind_strike_charge(player)
        record.current_skill_id = nil
        record.skill_aim = nil
        update_character_attributes(player, record)
        return false
    end

    CombatValidationService.emit(
        player,
        "SKILL",
        "ACCEPT",
        skill_definition.ID,
        sequence_id
    )

    task.delay(wind_up_seconds, function()
        enter_skill_active(
            player,
            record,
            sequence_id,
            skill_definition
        )
    end)

    return true
end


--[[
Finishes a Mend channel and returns the caster to Locomotion.

Args:
    player (Player): Player whose Mend is ending.
    record (PlayerCombatState): Authoritative combat record.
    sequence_id (number): Mend sequence captured at channel start.

Returns:
    None.
]]
local function finish_mend(
    player: Player,
    record: PlayerCombatState,
    sequence_id: number
)
    if not sequence_is_current(
        player,
        record,
        sequence_id,
        State.MENDING
    ) then
        return
    end

    MendService.cancel_channel(player)
    record.current_skill_id = nil
    set_state(player, record, State.LOCOMOTION)
end


--[[
Runs one scheduled Mend pulse against the locked support target.

Args:
    player (Player): Player performing Mend.
    record (PlayerCombatState): Authoritative combat record.
    sequence_id (number): Mend sequence captured at channel start.
    skill_definition (table): Authoritative Mend definition.
    pulse_index (number): One-based pulse number.

Returns:
    None.
]]
local function run_mend_pulse(
    player: Player,
    record: PlayerCombatState,
    sequence_id: number,
    skill_definition: any,
    pulse_index: number
)
    if not sequence_is_current(
        player,
        record,
        sequence_id,
        State.MENDING
    ) then
        return
    end

    local mend_target = MendService.get_channel_target(player)
    local valid, healed = MendService.apply_channel_pulse(
        player,
        skill_definition.PULSE_HEAL * ProgressionRuntimeState.get_heal_multiplier(player.UserId)
    )
    if valid and mend_target and healed > 0 then
        DungeonProgressionBridge.award_heal(
            player, skill_definition.ID, mend_target, healed
        )
        DungeonContributionBridge.record_heal(
            player, mend_target, healed, skill_definition.ID
        )
        ThreatService.record_support(player, mend_target, healed)
    end

    if not valid then
        CombatValidationService.emit(
            player,
            "MEND",
            "CANCELLED",
            "TargetInvalid",
            sequence_id
        )
        finish_mend(player, record, sequence_id)
        return
    end

    CombatValidationService.emit(
        player,
        "MEND",
        "PULSE",
        string.format(
            "%d/%d +%.1fHP",
            pulse_index,
            skill_definition.PULSE_COUNT,
            healed
        ),
        sequence_id
    )

    if pulse_index >= skill_definition.PULSE_COUNT then
        finish_mend(player, record, sequence_id)
    end
end


--[[
Starts one committed server-authoritative Mend channel.

The target is fixed when the channel starts. Cooldown is consumed once the
Mending state and target lock are both accepted. Five sequence-guarded pulse
callbacks then resolve over the full channel duration.

Args:
    player (Player): Player beginning Mend.
    record (PlayerCombatState): Authoritative combat record.
    skill_definition (table): Authoritative Mend definition.
    target (Player): Server-selected Mend recipient.

Returns:
    boolean: True when the Mend channel started.
]]
local function start_mend(
    player: Player,
    record: PlayerCombatState,
    skill_definition: any,
    target: Player
): boolean
    record.sequence_id += 1
    record.current_attack_id = nil
    record.current_skill_id = skill_definition.ID
    record.queued_attack = false

    local sequence_id = record.sequence_id

    if not set_state(player, record, State.MENDING) then
        record.current_skill_id = nil
        update_character_attributes(player, record)
        return false
    end

    if not MendService.start_channel(
        player,
        target,
        skill_definition.RANGE_STUDS
    ) then
        record.current_skill_id = nil
        set_state(player, record, State.LOCOMOTION)
        return false
    end

    SkillCooldownService.start(
        player,
        skill_definition.ID,
        skill_definition.COOLDOWN_SECONDS
    )

    CombatValidationService.emit(
        player,
        "MEND",
        "ACCEPT",
        target.Name,
        sequence_id
    )

    for pulse_index = 1, skill_definition.PULSE_COUNT do
        task.delay(
            pulse_index * skill_definition.PULSE_INTERVAL_SECONDS,
            function()
                run_mend_pulse(
                    player,
                    record,
                    sequence_id,
                    skill_definition,
                    pulse_index
                )
            end
        )
    end

    return true
end


--[[
Handles one active-skill request without trusting client combat results.

Args:
    player (Player): Player requesting an active skill.
    requested_skill_id (any): Client-provided skill identity only.

Returns:
    None.
]]
local function handle_skill_request(
    player: Player,
    requested_skill_id: any,
    aim_intent: any
)
    if player:GetAttribute(
        CombatConfig.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
    ) == false then
        CombatValidationService.emit(
            player, "SKILL", "REJECT", "DungeonMemberNotActive", nil
        )
        return
    end
    if type(requested_skill_id) ~= "string" then
        CombatValidationService.emit(
            player,
            "SKILL",
            "REJECT",
            "MalformedRequest",
            nil
        )
        return
    end

    local record = player_states[player]

    if not record or record.state_name ~= State.LOCOMOTION then
        CombatValidationService.emit(
            player,
            "SKILL",
            "REJECT",
            record and ("State=" .. record.state_name) or "NoState",
            record and record.sequence_id or nil
        )
        return
    end

    if RangerDrawService.is_drawing(player) then
        CombatValidationService.emit(
            player,
            "SKILL",
            "REJECT",
            "DrawActive",
            record.sequence_id
        )
        return
    end

    local base_definition = SkillDefinitions.get(
        requested_skill_id
    )

    if not base_definition then
        CombatValidationService.emit(
            player,
            "SKILL",
            "REJECT",
            "UnknownSkill",
            record.sequence_id
        )
        return
    end

    local usable, unusable_reason =
        ProgressionRuntimeState.is_skill_usable(
            player.UserId,
            requested_skill_id,
            get_equipped_weapon_tags(player)
        )

    if not usable then
        CombatValidationService.emit(
            player,
            "SKILL",
            "REJECT",
            unusable_reason or "SkillUnavailable",
            record.sequence_id
        )
        return
    end

    local rank = ProgressionRuntimeState.get_skill_rank(
        player.UserId,
        requested_skill_id
    )
    local skill_definition = SkillDefinitions.get_for_rank(
        requested_skill_id,
        rank
    )

    if not skill_definition then
        CombatValidationService.emit(
            player,
            "SKILL",
            "REJECT",
            "RankDefinitionMissing",
            record.sequence_id
        )
        return
    end

    local humanoid = get_character_parts(player)

    if not humanoid or humanoid.Health <= 0 then
        CombatValidationService.emit(
            player,
            "SKILL",
            "REJECT",
            "Dead",
            record.sequence_id
        )
        return
    end

    if skill_definition.KIND == "ScoutToggle"
        or skill_definition.KIND == "ScoutAccuracyToggle"
        or skill_definition.KIND == "IronvowCriticalToggle"
        or skill_definition.KIND == "IronvowAccuracyToggle"
    then
        -- A second genuine click must turn the existing stance off,
        -- without paying an activation cost or entering casting state.
        local toggles = if skill_definition.KIND == "ScoutToggle"
            then ScoutCriticalToggleService
            else if skill_definition.KIND == "IronvowCriticalToggle"
                then IronvowCriticalToggleService
                else if skill_definition.KIND == "IronvowAccuracyToggle"
                    then IronvowAccuracyToggleService
                    else ScoutAccuracyToggleService
        local changed, enabled, reason = toggles.toggle(
            player, skill_definition, rank
        )
        CombatValidationService.emit(
            player, "SCOUT_TOGGLE",
            if changed then "APPLIED" else "REJECT",
            if changed then requested_skill_id .. " "
                .. (if enabled then "ON" else "OFF")
                else reason,
            record.sequence_id
        )
        return
    end

    if not SkillCooldownService.is_ready(
        player,
        requested_skill_id
    ) then
        CombatValidationService.emit(
            player,
            "SKILL",
            "REJECT",
            "Cooldown",
            record.sequence_id
        )
        return
    end

    local resolved_skill_aim: Vector3? = nil

    if skill_definition.KIND == "RangerVolley" then
        local character = player.Character

        if not character then
            return
        end

        resolved_skill_aim = RangerCombatService.resolve_volley_ground(
            character,
            aim_intent,
            skill_definition.AIM_RANGE_STUDS
        )

        if not resolved_skill_aim then
            CombatValidationService.emit(
                player,
                "VOLLEY",
                "REJECT",
                "InvalidGroundAim",
                record.sequence_id
            )
            return
        end
    end

    if skill_definition.KIND == "HealthSurge" then
        if not IronvowEnduranceSurgeService.can_activate(player) then
            CombatValidationService.emit(
                player, "HEALTH_SURGE", "REJECT",
                "AlreadyActive", record.sequence_id
            )
            return
        end
        if not ManaService.try_spend(
            player, skill_definition.MANA_COST
        ) then
            CombatValidationService.emit(
                player, "HEALTH_SURGE", "REJECT",
                "Mana", record.sequence_id
            )
            return
        end
        if IronvowEnduranceSurgeService.activate(
            player, skill_definition, rank
        ) then
            SkillCooldownService.start(
                player, requested_skill_id,
                skill_definition.COOLDOWN_SECONDS
            )
            CombatValidationService.emit(
                player, "HEALTH_SURGE", "APPLIED",
                requested_skill_id, record.sequence_id
            )
        else
            CombatValidationService.emit(
                player, "HEALTH_SURGE", "REJECT",
                "InvalidOwner", record.sequence_id
            )
        end
        return
    end

    if skill_definition.KIND == "Support" then
        if skill_definition.ID ~= "Mend" then
            CombatValidationService.emit(
                player,
                "SKILL",
                "REJECT",
                "UnsupportedSupportSkill",
                record.sequence_id
            )
            return
        end

        local target = MendService.find_target(
            player,
            skill_definition.RANGE_STUDS
        )

        if not target then
            CombatValidationService.emit(
                player,
                "MEND",
                "REJECT",
                "NoInjuredTarget",
                record.sequence_id
            )
            return
        end

        if not StaminaService.try_spend(
            player,
            skill_definition.STAMINA_COST
        ) then
            CombatValidationService.emit(
                player,
                "SKILL",
                "REJECT",
                "Stamina",
                record.sequence_id
            )
            return
        end

        start_mend(
            player,
            record,
            skill_definition,
            target
        )
        return
    end

    if skill_definition.KIND == "MageHeal" then
        if skill_definition.PARTY_HEAL == true then
            if not PartyHealService.has_injured_member(
                player, skill_definition.RANGE_STUDS
            ) then
                CombatValidationService.emit(
                    player, "MAGE_PARTY_HEAL", "REJECT",
                    "NoEligiblePartyMember", record.sequence_id
                )
                return
            end
        else
            local target = resolve_skill_heal_target(
                player, skill_definition
            )
            if not target then
                CombatValidationService.emit(
                    player, "MAGE_HEAL", "REJECT",
                    "NoInjuredTarget", record.sequence_id
                )
                return
            end
        end
    end

    -- Live party membership is rechecked independently on release.

    local mana_cost =
        tonumber(skill_definition.MANA_COST) or 0
    local stamina_cost =
        tonumber(skill_definition.STAMINA_COST) or 0

    if skill_definition.KIND == "MagicProjectile" then
        if ManaService.get(player) < mana_cost then
            CombatValidationService.emit(
                player,
                "SKILL",
                "REJECT",
                "Mana",
                record.sequence_id
            )
            return
        end
    elseif mana_cost > 0 and not ManaService.try_spend(
        player,
        mana_cost
    ) then
        CombatValidationService.emit(
            player,
            "SKILL",
            "REJECT",
            "Mana",
            record.sequence_id
        )
        return
    end

    if stamina_cost > 0 and not StaminaService.try_spend(
        player,
        stamina_cost
    ) then
        CombatValidationService.emit(
            player,
            "SKILL",
            "REJECT",
            "Stamina",
            record.sequence_id
        )
        return
    end

    if skill_definition.KIND ~= "MagicProjectile" then
        SkillCooldownService.start(
            player,
            requested_skill_id,
            skill_definition.COOLDOWN_SECONDS
        )
    end

    start_skill(
        player,
        record,
        skill_definition,
        resolved_skill_aim
    )
end

--[[
Starts or ends authoritative defensive actions from client intent only.

Args:
    player (Player): Player requesting the defensive action.
    action (string): BlockStart, BlockEnd, or Dodge.
    dodge_input_code (any): Eight-way direction intent for Dodge only.
    view_locked_intent (any): Client View Lock presentation intent.
    dodge_world_direction (any): Camera-relative world direction intent.

Returns:
    None.
]]
local function handle_defense_request(
    player: Player,
    action: string,
    dodge_input_code: any,
    view_locked_intent: any,
    dodge_world_direction: any
)
    if player:GetAttribute(
        CombatConfig.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
    ) == false then
        CombatValidationService.emit(
            player, "DEFENSE", "REJECT", "DungeonMemberNotActive", nil
        )
        return
    end
    local record = player_states[player]

    if not record then
        return
    end

    if action == "BlockStart" then
        if StaminaService.get(player)
            < CombatConfig.DEFENSE.MIN_BLOCK_START_STAMINA
        then
            CombatValidationService.emit(
                player, "BLOCK", "REJECT", "InsufficientStamina",
                record.sequence_id
            )
            return
        end
        local equipment_effects =
            ProgressionRuntimeState.get_equipment_effects(player.UserId)

        if not EquipmentDefenseRules.can_block_with_weapon(
            equipment_effects.WeaponItemId
        ) then
            CombatValidationService.emit(
                player,
                "BLOCK",
                "REJECT",
                "WeaponRestricted",
                record.sequence_id
            )
            return
        end

        if not StateRules.can_transition(
            record.state_name,
            State.BLOCKING
        ) then
            CombatValidationService.emit(
                player,
                "BLOCK",
                "REJECT",
                "State=" .. record.state_name,
                record.sequence_id
            )
            return
        end

        local character = player.Character

        if not character then
            return
        end

        clear_wind_strike_charge(player)
        RangerDrawService.cancel(player)
        record.ranger_draw_tier = nil
        record.skill_aim = nil
        report_sequence_cancel(player, record, "Block")

        if record.state_name == State.MENDING then
            MendService.cancel_channel(player)
        end

        record.sequence_id += 1
        record.current_attack_id = nil
        record.current_skill_id = nil
        record.queued_attack = false
        record.next_attack_id = BasicAttack.ATTACK_ORDER[1]
        record.combo_expires_at = 0

        stop_attack_step(player)

        if not set_state(
            player,
            record,
            State.BLOCKING
        ) then
            return
        end

        StaminaService.set_regen_paused(
            player,
            true
        )
        DefenseService.begin_block(
            player,
            character,
            record.state_started_at
        )
        CombatValidationService.emit(
            player,
            "BLOCK",
            "ACCEPT",
            "ParryWindowOpen",
            record.sequence_id
        )
        return
    end

    if action == "BlockEnd" then
        if record.state_name ~= State.BLOCKING then
            return
        end

        DefenseService.end_block(player)
        StaminaService.set_regen_paused(
            player,
            false
        )
        set_state(
            player,
            record,
            State.LOCOMOTION
        )
        CombatValidationService.emit(player, "BLOCK", "END", "Released", record.sequence_id)
        return
    end

    if action ~= "Dodge" then
        CombatValidationService.emit(
            player,
            "DEFENSE",
            "REJECT",
            "UnknownAction=" .. tostring(action),
            record.sequence_id
        )
        return
    end

    -- Ultimate Defence is immobile. Reject the client Dodge remote
    -- before its dash movement or i-frames can bypass server anchoring.
    if CombatStatusService.get(
        player.Character, "Fortress"
    ) > 0 then
        CombatValidationService.emit(
            player, "DODGE", "REJECT",
            "FortressMovementLocked", record.sequence_id
        )
        return
    end

    if not StateRules.can_transition(
        record.state_name,
        State.DODGING
    ) then
        CombatValidationService.emit(
            player,
            "DODGE",
            "REJECT",
            "State=" .. record.state_name,
            record.sequence_id
        )
        return
    end

    local character = player.Character

    if not character then
        return
    end

    local resolved_input_code = dodge_input_code

    if resolved_input_code == nil then
        resolved_input_code = "Forward"
    end

    if not DodgeDirectionRules.is_valid_input_code(
        resolved_input_code
    ) then
        CombatValidationService.emit(player, "DODGE", "REJECT", "Direction", record.sequence_id)
        return
    end

    local view_locked = view_locked_intent == true
    local unlocked_direction: Vector3? = nil

    if not view_locked then
        unlocked_direction =
            DodgeDirectionRules.sanitize_world_direction(
                dodge_world_direction
            )

        if not unlocked_direction then
            local _, root_part = get_character_parts(player)

            if root_part then
                unlocked_direction =
                    DodgeDirectionRules.sanitize_world_direction(
                        root_part.CFrame.LookVector
                    )
            end
        end

        if not unlocked_direction then
            return
        end
    end

    local spent = StaminaService.try_spend(
        player,
        CombatConfig.STAMINA.DODGE_COST
    )

    if not spent then
        CombatValidationService.emit(player, "DODGE", "REJECT", "Stamina", record.sequence_id)
        return
    end

    local _, root_part = get_character_parts(player)

    if not root_part then
        return
    end

    local initial_direction = unlocked_direction

    if view_locked then
        initial_direction = DodgeDirectionRules.resolve(
            resolved_input_code,
            root_part.CFrame.LookVector
        )
    end

    if not initial_direction then
        return
    end

    local dodge_style = DodgeDirectionRules.get_dodge_style(
        resolved_input_code,
        view_locked
    )

    character:SetAttribute(
        CombatConfig.DEFENSE.DODGE_DIRECTION_ATTRIBUTE,
        initial_direction
    )
    character:SetAttribute(
        CombatConfig.DEFENSE.DODGE_STYLE_ATTRIBUTE,
        dodge_style
    )
    character:SetAttribute(
        CombatConfig.DEFENSE.DODGE_VIEW_LOCKED_ATTRIBUTE,
        view_locked
    )

    clear_wind_strike_charge(player)
    RangerDrawService.cancel(player)
    record.ranger_draw_tier = nil
    record.skill_aim = nil
    report_sequence_cancel(player, record, "Dodge")

    if record.state_name == State.MENDING then
        MendService.cancel_channel(player)
    end

    record.sequence_id += 1
    record.current_attack_id = nil
    record.current_skill_id = nil
    record.queued_attack = false
    record.next_attack_id = BasicAttack.ATTACK_ORDER[1]
    record.combo_expires_at = 0

    stop_attack_step(player)

    if not set_state(
        player,
        record,
        State.DODGING
    ) then
        character:SetAttribute(
            CombatConfig.DEFENSE.DODGE_DIRECTION_ATTRIBUTE,
            Vector3.zero
        )
        character:SetAttribute(
            CombatConfig.DEFENSE.DODGE_STYLE_ATTRIBUTE,
            ""
        )
        character:SetAttribute(
            CombatConfig.DEFENSE.DODGE_VIEW_LOCKED_ATTRIBUTE,
            false
        )
        return
    end

    local dodge_sequence = record.sequence_id
    local dodge_profile = get_dodge_profile(
        resolved_input_code,
        view_locked
    )

    DefenseService.begin_dodge(
        player,
        character,
        record.state_started_at
    )
    CombatValidationService.emit(
        player,
        "DODGE",
        "ACCEPT",
        resolved_input_code,
        dodge_sequence
    )
    apply_dodge_step(
        player,
        resolved_input_code,
        dodge_profile,
        view_locked,
        unlocked_direction
    )

    task.delay(
        dodge_profile.duration,
        function()
            if not sequence_is_current(
                player,
                record,
                dodge_sequence,
                State.DODGING
            ) then
                return
            end

            stop_dodge_movement(player)
            DefenseService.end_dodge(player)
            CombatValidationService.emit(
                player,
                "DODGE",
                "COMPLETE",
                resolved_input_code,
                dodge_sequence
            )
            set_state(
                player,
                record,
                State.LOCOMOTION
            )
        end
    )
end


DefenseService.on_guard_break(function(player: Player)
    local record = player_states[player]

    if not record
        or record.state_name ~= State.BLOCKING then
        return
    end

    record.sequence_id += 1
    local guard_sequence = record.sequence_id

    DefenseService.end_block(player)
    StaminaService.set_regen_paused(
        player,
        false
    )

    if not set_state(
        player,
        record,
        State.GUARD_BREAK
    ) then
        return
    end

    task.delay(
        CombatConfig.DEFENSE.GUARD_BREAK_SECONDS,
        function()
            if not sequence_is_current(
                player,
                record,
                guard_sequence,
                State.GUARD_BREAK
            ) then
                return
            end

            set_state(
                player,
                record,
                State.LOCOMOTION
            )
        end
    )
end)


--[[
Cancels Mend channels targeting one player and releases their living casters.

Args:
    target (Player): Recipient who died or left the server.

Returns:
    None.
]]
local function cancel_mends_targeting_player(target: Player)
    local cancelled_casters = MendService.cancel_channels_for_target(target)

    for _, caster in cancelled_casters do
        local caster_record = player_states[caster]

        if caster_record
            and caster_record.state_name == State.MENDING then
            CombatValidationService.emit(
                caster,
                "MEND",
                "CANCELLED",
                "RecipientUnavailable",
                caster_record.sequence_id
            )
            caster_record.sequence_id += 1
            caster_record.current_skill_id = nil
            set_state(caster, caster_record, State.LOCOMOTION)
        end
    end
end


--[[
Terminates every runtime combat action owned by one dead character.

Args:
    player (Player): Player whose active character died.
    character (Model): Character that emitted the death event.
    record (PlayerCombatState): Combat record created for that character.

Returns:
    None.
]]
local function handle_character_death(
    player: Player,
    character: Model,
    record: PlayerCombatState
)
    if player_states[player] ~= record
        or player.Character ~= character then
        return
    end

    record.sequence_id += 1
    record.current_attack_id = nil
    record.current_skill_id = nil
    record.queued_attack = false
    record.next_attack_id = BasicAttack.ATTACK_ORDER[1]
    record.combo_expires_at = 0
    record.ranger_draw_tier = nil
    record.skill_aim = nil

    clear_wind_strike_charge(player)
    RangerDrawService.cancel(player)
    MendService.cancel_channel(player)
    WardService.cancel_player(player)
    MageHealService.cancel_player(player)
    cancel_mends_targeting_player(player)
    stop_dodge_movement(player)
    stop_attack_step(player)
    DefenseService.clear(player)
    IronvowEnduranceSurgeService.stop(player)
    StaminaService.set_regen_paused(player, false)
    SkillCooldownService.remove_owner(player)

    set_state(player, record, State.DEAD)
    CombatValidationService.emit(player, "LIFECYCLE", "DEAD", "CombatReset", record.sequence_id)
end


--[[
Temporarily suppresses Marauder target acquisition after a respawn.

This is not invulnerability: it only marks the character as ineligible for
new Marauder aggro while the short arena re-entry grace period is active.
]]
local function begin_respawn_aggro_grace(
    player: Player,
    character: Model,
    record: PlayerCombatState
)
    local marauder_config = CombatConfig.TRAINING_MARAUDER
    local attribute_name = marauder_config.AGGRO_SUPPRESSED_ATTRIBUTE
    local grace_seconds = marauder_config.RESPAWN_AGGRO_GRACE_SECONDS

    character:SetAttribute(attribute_name, true)
    CombatValidationService.emit(
        player,
        "LIFECYCLE",
        "AGGRO_GRACE",
        string.format("%.1fs", grace_seconds),
        record.sequence_id
    )

    task.delay(grace_seconds, function()
        if player.Character ~= character or not character.Parent then
            return
        end

        character:SetAttribute(attribute_name, false)
        CombatValidationService.emit(
            player,
            "LIFECYCLE",
            "AGGRO_READY",
            "RoomWide",
            record.sequence_id
        )
    end)
end


--[[
Resets authoritative combat state for a newly spawned character.

Args:
    player (Player): Player whose character spawned.
    character (Model): Newly spawned character model.

Returns:
    None.
]]
local function on_character_added(
    player: Player,
    character: Model
)
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    local record = create_player_state(humanoid.WalkSpeed)
    local is_respawn = has_spawned_character[player] == true

    has_spawned_character[player] = true
    character:SetAttribute(
        CombatConfig.TRAINING_MARAUDER.AGGRO_SUPPRESSED_ATTRIBUTE,
        false
    )

    stop_dodge_movement(player)
    player_states[player] = record
    RangerDrawService.reset_character(player, character)
    ScoutCriticalToggleService.stop(player)
    ScoutAccuracyToggleService.stop(player)
    IronvowCriticalToggleService.stop(player)
    IronvowAccuracyToggleService.stop(player)
    IronvowEnduranceSurgeService.stop(player)
    StaminaService.reset_player(player)
    ManaService.reset_player(player)
    ProgressionRuntimeState.apply_max_health(player)
    SkillCooldownService.remove_owner(player)
    DefenseService.clear(player)
    set_state(player, record, State.LOCOMOTION)
    CombatValidationService.emit(player, "LIFECYCLE", "RESPAWN", "Locomotion", record.sequence_id)

    if is_respawn then
        begin_respawn_aggro_grace(player, character, record)
    end

    humanoid.Died:Connect(function()
        handle_character_death(player, character, record)
    end)
end


--[[
Initialises combat state ownership for one player.

Args:
    player (Player): Player entering the server.

Returns:
    None.
]]
local function on_player_added(player: Player)
    StaminaService.initialize_player(player)
    ManaService.initialize_player(player)

    player.CharacterAdded:Connect(function(character)
        on_character_added(player, character)
    end)

    if player.Character then
        on_character_added(player, player.Character)
    end
end


-- This callback never trusts a client-supplied rank or toggle strength.
-- Any respec, loadout change, class/race change or Dungeon exclusion
-- invalidates the active effect and stops further upkeep.
ScoutCriticalToggleService.set_stamina_spender(function(
    player: Player, amount: number
): boolean
    return StaminaService.try_spend(player, amount)
end)
ScoutAccuracyToggleService.set_stamina_spender(function(
    player: Player, amount: number
): boolean
    return StaminaService.try_spend(player, amount)
end)
IronvowCriticalToggleService.set_mana_spender(function(
    player: Player, amount: number
): boolean
    return ManaService.try_spend(player, amount)
end)
IronvowAccuracyToggleService.set_mana_spender(function(
    player: Player, amount: number
): boolean
    return ManaService.try_spend(player, amount)
end)

ScoutCriticalToggleService.set_authorizer(function(
    player: Player, toggle_record: any
): boolean
    local usable = ProgressionRuntimeState.is_skill_usable(
        player.UserId, toggle_record.Definition.ID
    )
    return usable and ProgressionRuntimeState.get_skill_rank(
        player.UserId, toggle_record.Definition.ID
    ) == toggle_record.Rank and player:GetAttribute(
        CombatConfig.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
    ) ~= false
end)

IronvowEnduranceSurgeService.set_recalculator(function(player: Player)
    ProgressionRuntimeState.apply_max_health(player)
end)
IronvowEnduranceSurgeService.set_authorizer(function(
    player: Player, record: any
): boolean
    local usable = ProgressionRuntimeState.is_skill_usable(
        player.UserId, record.Definition.ID
    )
    return usable and ProgressionRuntimeState.get_skill_rank(
        player.UserId, record.Definition.ID
    ) == record.Rank and player:GetAttribute(
        CombatConfig.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
    ) ~= false
end)

IronvowAccuracyToggleService.set_authorizer(function(
    player: Player, toggle_record: any
): boolean
    local usable = ProgressionRuntimeState.is_skill_usable(
        player.UserId, toggle_record.Definition.ID
    )
    return usable and ProgressionRuntimeState.get_skill_rank(
        player.UserId, toggle_record.Definition.ID
    ) == toggle_record.Rank and player:GetAttribute(
        CombatConfig.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
    ) ~= false
end)

IronvowCriticalToggleService.set_authorizer(function(
    player: Player, toggle_record: any
): boolean
    local usable = ProgressionRuntimeState.is_skill_usable(
        player.UserId, toggle_record.Definition.ID
    )
    return usable and ProgressionRuntimeState.get_skill_rank(
        player.UserId, toggle_record.Definition.ID
    ) == toggle_record.Rank and player:GetAttribute(
        CombatConfig.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
    ) ~= false
end)

ScoutAccuracyToggleService.set_authorizer(function(
    player: Player, toggle_record: any
): boolean
    local usable = ProgressionRuntimeState.is_skill_usable(
        player.UserId, toggle_record.Definition.ID
    )
    return usable and ProgressionRuntimeState.get_skill_rank(
        player.UserId, toggle_record.Definition.ID
    ) == toggle_record.Rank and player:GetAttribute(
        CombatConfig.DUNGEON_COMBAT_ALLOWED_ATTRIBUTE
    ) ~= false
end)

attack_request.OnServerEvent:Connect(handle_attack_request)
defense_request.OnServerEvent:Connect(handle_defense_request)
skill_request.OnServerEvent:Connect(handle_skill_request)
Players.PlayerAdded:Connect(on_player_added)
Players.PlayerRemoving:Connect(function(player)
    ThreatService.remove_player(player.UserId)
    clear_wind_strike_charge(player)
    RangerDrawService.remove_player(player)
    MendService.cancel_channel(player)
    WardService.cancel_player(player)
    MageHealService.cancel_player(player)
    cancel_mends_targeting_player(player)
    stop_dodge_movement(player)
    DefenseService.clear(player)
    ScoutCriticalToggleService.stop(player)
    ScoutAccuracyToggleService.stop(player)
    IronvowCriticalToggleService.stop(player)
    IronvowAccuracyToggleService.stop(player)
    IronvowEnduranceSurgeService.stop(player)
    StaminaService.remove_player(player)
    ManaService.remove_player(player)
    SkillCooldownService.remove_owner(player)
    player_states[player] = nil
    has_spawned_character[player] = nil
    ProgressionRuntimeState.clear_character(player.UserId)
end)

for _, player in Players:GetPlayers() do
    on_player_added(player)
end
