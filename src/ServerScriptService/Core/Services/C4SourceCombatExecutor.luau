--!strict
-- Disabled-by-default live player-vs-player C4 source-combat executor.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Services = ServerScriptService.Core.Services
local StatusEffects = require(
    ReplicatedStorage.Core.Shared.C4StatusEffectReference
)

local SourceCombat = require(
    Services.C4SourceCombatCalculationService
)
local NpcBoundaries = require(
    Services.C4NpcSourceBoundaryService
)

local C4SourceCombatExecutor = {}
C4SourceCombatExecutor.__index = C4SourceCombatExecutor

--[[
Returns one validated positive finite source-units-per-stud scale.

Args:
    value (number): Server-owned spatial conversion scale.

Returns:
    number: Validated positive conversion scale.
]]
local function validated_scale(value: number): number
    assert(
        type(value) == "number"
            and value == value
            and value > 0
            and value < math.huge,
        "C4 source units per stud must be finite and positive"
    )
    return value
end

--[[
Returns the current living Humanoid for one server-owned player object.

Args:
    player (any): Player-like server authority object.

Returns:
    (any?, string?): Living Humanoid or strict denial reason.
]]
local function default_humanoid_provider(
    player: any
): (any?, string?)
    local character = player and player.Character
    if not character then
        return nil, "C4LiveCombatCharacterUnavailable"
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return nil, "C4LiveCombatHumanoidUnavailable"
    end

    return humanoid, nil
end

--[[
Returns the authoritative combat Model for a player-like owner or NPC Model.

Args:
    actor (any): Player-like owner or direct server NPC Model.

Returns:
    Model?: Current combat Model, otherwise nil.
]]
local function combat_model(actor: any): Model?
    if typeof(actor) == "Instance" and actor:IsA("Model") then
        return actor
    end

    local ok, character = pcall(function()
        return actor and actor.Character
    end)
    if ok
        and typeof(character) == "Instance"
        and character:IsA("Model")
    then
        return character
    end

    return nil
end

--[[
Builds trusted C4 spatial context from authoritative Roblox character roots.

The Y difference is converted only through an explicitly configured
source-units-per-stud scale. No implicit Roblox-to-C4 conversion is used.

Args:
    service (any): Executor instance containing world conversion rules.
    attacker (any): Server-owned attacking player.
    defender (any): Server-owned defending player.

Returns:
    (any?, string?): Source spatial context or strict denial reason.
]]
local function default_spatial_context_provider(
    service: any,
    attacker: any,
    defender: any
): (any?, string?)
    if type(service._source_units_per_stud) ~= "number" then
        return nil, "C4SourceElevationScaleUnconfigured"
    end
    if type(service._night_provider) ~= "function" then
        return nil, "C4SourceNightProviderUnconfigured"
    end

    local attacker_character = combat_model(attacker)
    local defender_character = combat_model(defender)
    if not attacker_character or not defender_character then
        return nil, "C4LiveCombatCharacterUnavailable"
    end

    local attacker_root =
        attacker_character:FindFirstChild("HumanoidRootPart")
    local defender_root =
        defender_character:FindFirstChild("HumanoidRootPart")
    if not attacker_root or not defender_root then
        return nil, "C4LiveCombatRootUnavailable"
    end

    local night = service._night_provider()
    if type(night) ~= "boolean" then
        return nil, "InvalidC4SourceNightState"
    end

    return {
        AttackerPosition = attacker_root.Position,
        DefenderCFrame = defender_root.CFrame,
        HeightDeltaSourceUnits =
            (attacker_root.Position.Y - defender_root.Position.Y)
            * service._source_units_per_stud,
        IsNight = night,
    }, nil
end

--[[
Creates a separately gated live source-combat executor.

Dependencies are injectable for isolated server tests. Production callers
normally omit them and receive the accepted source calculation/resource
authorities.

Args:
    options (any?): Optional dependency and world-provider overrides.

Returns:
    any: Disabled executor instance.
]]
function C4SourceCombatExecutor.new(options: any?): any
    local config = options or {}

    return setmetatable({
        _enabled = false,
        _combat = config.CombatProvider or SourceCombat,
        _resources = config.ResourceAuthority,
        _npc_boundary_provider =
            config.NpcBoundaryProvider
            or NpcBoundaries.for_model,
        _npc_damage_observer = config.NpcDamageObserver,
        _humanoid_provider =
            config.HumanoidProvider or default_humanoid_provider,
        _spatial_context_provider =
            config.SpatialContextProvider
            or default_spatial_context_provider,
        _status_delay = config.DelayProvider or task.delay,
        _npc_periodic_statuses = {},
        _next_status_serial = 0,
        _source_units_per_stud = nil,
        _night_provider = nil,
    }, C4SourceCombatExecutor)
end

--[[
Configures the explicit server-owned Roblox-to-source spatial mapping.

This does not enable live source combat. Night state remains a server callback
so the game can later map its authoritative time system without client input.

Args:
    source_units_per_stud (number): Positive explicit height conversion scale.
    night_provider (any): Zero-argument server callback returning boolean.

Returns:
    nil: Stores only server-owned spatial rules.
]]
function C4SourceCombatExecutor:configure_spatial_rules(
    source_units_per_stud: number,
    night_provider: any
)
    self._source_units_per_stud =
        validated_scale(source_units_per_stud)
    assert(
        type(night_provider) == "function",
        "C4 source night provider must be a function"
    )
    self._night_provider = night_provider
end

--[[
Installs the trusted post-application NPC damage observer.

The observer is how a later combat adapter preserves contribution, quest and
threat bookkeeping after source damage has already been applied. An NPC live
action fails closed while no observer is installed.

Args:
    observer (any?): Server callback receiving context, damage and lethal flag.

Returns:
    nil: Replaces only this executor's NPC damage observer.
]]
function C4SourceCombatExecutor:set_npc_damage_observer(
    observer: any?
)
    assert(
        observer == nil or type(observer) == "function",
        "C4 NPC damage observer must be a function or nil"
    )
    self._npc_damage_observer = observer
end

--[[
Reports whether this executor may mutate live source-combat resources.

Args:
    None.

Returns:
    boolean: Explicit executor gate state.
]]
function C4SourceCombatExecutor:is_enabled(): boolean
    return self._enabled
end

--[[
Changes only the executor gate.

Enabling does not enable the source calculation provider or resource cutover.
Those independent gates must already be enabled by trusted server bootstrap.

Args:
    enabled (boolean): Desired live executor gate.

Returns:
    (boolean, string?): Success or configuration denial reason.
]]
function C4SourceCombatExecutor:set_enabled(
    enabled: boolean
): (boolean, string?)
    if type(enabled) ~= "boolean" then
        return false, "InvalidC4LiveCombatGate"
    end

    if enabled
        and (
            type(self._source_units_per_stud) ~= "number"
            or type(self._night_provider) ~= "function"
        )
    then
        return false, "C4LiveSpatialRulesUnconfigured"
    end
    if enabled and type(self._resources) ~= "table" then
        return false, "C4LiveResourceAuthorityUnavailable"
    end

    self._enabled = enabled
    return true, nil
end

--[[
Checks all independent authorities required before one live source attack.

Args:
    attacker (any): Server-owned attacking player.
    defender (any): Server-owned defending player.

Returns:
    (boolean, string?): Ready state or strict gate denial reason.
]]
function C4SourceCombatExecutor:_validate_participants(
    attacker: any,
    defender: any
): (boolean, string?)
    if not self._enabled then
        return false, "C4LiveCombatExecutorDisabled"
    end
    if type(attacker) ~= "userdata"
        and type(attacker) ~= "table"
    then
        return false, "InvalidC4LiveCombatAttacker"
    end
    if type(defender) ~= "userdata"
        and type(defender) ~= "table"
    then
        return false, "InvalidC4LiveCombatDefender"
    end
    if type(attacker.UserId) ~= "number"
        or type(defender.UserId) ~= "number"
        or attacker.UserId == defender.UserId
    then
        return false, "InvalidC4LiveCombatParticipants"
    end
    if not self._combat.is_enabled() then
        return false, "C4SourceCombatCalculationDisabled"
    end
    if type(self._resources) ~= "table" then
        return false, "C4LiveResourceAuthorityUnavailable"
    end
    if not self._resources.is_enabled() then
        return false, "C4ResourceCutoverDisabled"
    end
    if not self._resources.is_active(attacker)
        or not self._resources.is_active(defender)
    then
        return false, "C4LiveCombatParticipantNotCutOver"
    end

    return true, nil
end

--[[
Checks independent authorities required for one self-contained source action.

This is used for actions such as self-healing that have no separate defender.

Args:
    actor (any): Server-owned source-combat participant.

Returns:
    (boolean, string?): Ready state or strict gate denial reason.
]]
function C4SourceCombatExecutor:_validate_actor(
    actor: any
): (boolean, string?)
    if not self._enabled then
        return false, "C4LiveCombatExecutorDisabled"
    end
    if type(actor) ~= "userdata" and type(actor) ~= "table" then
        return false, "InvalidC4LiveCombatActor"
    end
    if type(actor.UserId) ~= "number" then
        return false, "InvalidC4LiveCombatActor"
    end
    if not self._combat.is_enabled() then
        return false, "C4SourceCombatCalculationDisabled"
    end
    if type(self._resources) ~= "table" then
        return false, "C4LiveResourceAuthorityUnavailable"
    end
    if not self._resources.is_enabled() then
        return false, "C4ResourceCutoverDisabled"
    end
    if not self._resources.is_active(actor) then
        return false, "C4LiveCombatParticipantNotCutOver"
    end

    return true, nil
end

--[[
Validates one player attacker and one current server-owned NPC target.

Args:
    attacker (any): Server-owned attacking player.
    enemy (any): Current server NPC Model.

Returns:
    (any?, string?): Reviewed NPC boundary or strict denial reason.
]]
function C4SourceCombatExecutor:_validate_npc_target(
    attacker: any,
    enemy: any
): (any?, string?)
    local ready, ready_reason = self:_validate_actor(attacker)
    if not ready then
        return nil, ready_reason
    end

    if typeof(enemy) ~= "Instance" or not enemy:IsA("Model") then
        return nil, "InvalidC4LiveNpcTarget"
    end
    if type(self._npc_boundary_provider) ~= "function" then
        return nil, "C4NpcSourceBoundaryUnavailable"
    end
    if type(self._npc_damage_observer) ~= "function" then
        return nil, "C4NpcDamageObserverUnavailable"
    end

    return self._npc_boundary_provider(enemy)
end

--[[
Applies one already-calculated player-versus-player source hit through CP then
HP.


Args:
    defender (any): Server-owned defending player.
    amount (number): Accepted source damage amount.

Returns:
    (any?, string?): Applied HP/CP result or strict denial reason.
]]
function C4SourceCombatExecutor:_apply_player_damage(
    defender: any,
    amount: number
): (any?, string?)
    if type(amount) ~= "number"
        or amount ~= amount
        or amount < 0
        or amount >= math.huge
    then
        return nil, "InvalidC4LiveCombatDamage"
    end

    local humanoid, humanoid_reason =
        self._humanoid_provider(defender)
    if not humanoid then
        return nil, humanoid_reason
    end

    local health_damage, cp_absorbed =
        self._resources.resolve_player_damage(
            defender,
            amount,
            true
        )

    if type(health_damage) ~= "number"
        or type(cp_absorbed) ~= "number"
        or health_damage < 0
        or cp_absorbed < 0
    then
        return nil, "InvalidC4LiveResourceResolution"
    end

    local health_before = humanoid.Health
    humanoid.Health = math.max(
        0,
        health_before - health_damage
    )

    return {
        RawDamage = amount,
        CPAbsorbed = cp_absorbed,
        HealthDamage = health_damage,
        HealthBefore = health_before,
        HealthAfter = humanoid.Health,
    }, nil
end

--[[
Applies one accepted source heal to server-owned Humanoid Health.

Args:
    actor (any): Server-owned healing participant.
    amount (number): Accepted source healing amount.

Returns:
    (any?, string?): Applied heal evidence or strict denial reason.
]]
function C4SourceCombatExecutor:_apply_player_heal(
    actor: any,
    amount: number
): (any?, string?)
    if type(amount) ~= "number"
        or amount ~= amount
        or amount < 0
        or amount >= math.huge
    then
        return nil, "InvalidC4LiveCombatHeal"
    end

    local humanoid, humanoid_reason =
        self._humanoid_provider(actor)
    if not humanoid then
        return nil, humanoid_reason
    end

    local health_before = humanoid.Health
    local max_health = humanoid.MaxHealth
    if type(max_health) ~= "number"
        or max_health ~= max_health
        or max_health <= 0
        or max_health >= math.huge
    then
        return nil, "InvalidC4LiveCombatMaximumHealth"
    end

    humanoid.Health = math.min(
        max_health,
        health_before + amount
    )

    return {
        RawHeal = amount,
        EffectiveHeal = humanoid.Health - health_before,
        HealthBefore = health_before,
        HealthAfter = humanoid.Health,
    }, nil
end

--[[
Applies one accepted source hit to a server NPC and emits trusted bookkeeping.

Args:
    attacker (any): Authenticated server player.
    enemy (Model): Server-owned NPC target.
    amount (number): Accepted source damage.
    source_kind (string): Existing combat callback category.
    source_id (string): Server-owned attack or skill identifier.
    sequence_id (number?): Existing server action sequence.

Returns:
    (any?, string?): Applied NPC damage evidence or strict denial reason.
]]
function C4SourceCombatExecutor:_apply_npc_damage(
    attacker: any,
    enemy: Model,
    amount: number,
    source_kind: string,
    source_id: string,
    sequence_id: number?
): (any?, string?)
    if type(amount) ~= "number"
        or amount ~= amount
        or amount < 0
        or amount >= math.huge
    then
        return nil, "InvalidC4LiveCombatDamage"
    end
    if type(self._npc_damage_observer) ~= "function" then
        return nil, "C4NpcDamageObserverUnavailable"
    end

    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return nil, "C4LiveCombatNpcUnavailable"
    end

    local health_before = humanoid.Health
    humanoid:TakeDamage(amount)
    local health_after = humanoid.Health
    local applied_damage = math.max(
        0,
        health_before - health_after
    )
    local lethal = health_after <= 0

    if applied_damage > 0 then
        self._npc_damage_observer({
            attacker = attacker,
            attacker_character = combat_model(attacker),
            target = enemy,
            source_kind = source_kind,
            source_id = source_id,
            attack_id = source_id,
            base_damage = amount,
            multiplier = 1,
            sequence_id = sequence_id,
            C4SourceResolved = true,
        }, applied_damage, lethal)
    end

    return {
        RawDamage = amount,
        CPAbsorbed = 0,
        HealthDamage = applied_damage,
        HealthBefore = health_before,
        HealthAfter = health_after,
        Lethal = lethal,
    }, nil
end

--[[
Returns the current periodic-status record for one target/source skill.

Args:
    enemy (Model): Server-owned NPC target.
    source_skill_id (number): Reviewed source skill identifier.

Returns:
    any?: Current status record, otherwise nil.
]]
function C4SourceCombatExecutor:_npc_status_record(
    enemy: Model,
    source_skill_id: number
): any?
    local target_records = self._npc_periodic_statuses[enemy]
    if type(target_records) ~= "table" then
        return nil
    end

    return target_records[source_skill_id]
end

--[[
Clears one exact periodic-status generation.

Args:
    enemy (Model): Server-owned NPC target.
    source_skill_id (number): Reviewed source skill identifier.
    serial (number): Exact generation to clear.

Returns:
    nil: Removes only the matching source status generation.
]]
function C4SourceCombatExecutor:_clear_npc_status(
    enemy: Model,
    source_skill_id: number,
    serial: number
)
    local target_records = self._npc_periodic_statuses[enemy]
    if type(target_records) ~= "table" then
        return
    end

    local current = target_records[source_skill_id]
    if not current or current.Serial ~= serial then
        return
    end

    target_records[source_skill_id] = nil
    if next(target_records) == nil then
        self._npc_periodic_statuses[enemy] = nil
    end
end

--[[
Schedules the next exact source periodic-status tick.

Args:
    record (any): Current immutable-identity status record.

Returns:
    nil: Queues one server-owned delayed callback.
]]
function C4SourceCombatExecutor:_schedule_npc_status_tick(
    record: any
)
    self._status_delay(record.TickSeconds, function()
        self:_run_npc_status_tick(record)
    end)
end

--[[
Executes one nonlethal source periodic-status tick.

The live gates and NPC boundary are revalidated on every delayed callback.
Reapplication of the same source skill invalidates older callbacks by serial.

Args:
    record (any): Current scheduled status generation.

Returns:
    nil: Applies at most one nonlethal tick and reschedules if required.
]]
function C4SourceCombatExecutor:_run_npc_status_tick(
    record: any
)
    local current = self:_npc_status_record(
        record.Target,
        record.SourceSkillId
    )
    if current ~= record then
        return
    end

    local boundary = self:_validate_npc_target(
        record.Attacker,
        record.Target
    )
    if not boundary then
        self:_clear_npc_status(
            record.Target,
            record.SourceSkillId,
            record.Serial
        )
        return
    end

    local humanoid =
        record.Target:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        self:_clear_npc_status(
            record.Target,
            record.SourceSkillId,
            record.Serial
        )
        return
    end

    local planned = StatusEffects.nonlethal_tick(
        humanoid.Health,
        record.TickDamage
    )
    if not planned then
        self:_clear_npc_status(
            record.Target,
            record.SourceSkillId,
            record.Serial
        )
        return
    end

    local health_before = humanoid.Health
    if planned.AppliedDamage > 0 then
        humanoid:TakeDamage(planned.AppliedDamage)
    end
    local health_after = humanoid.Health
    local applied_damage = math.max(
        0,
        health_before - health_after
    )

    if applied_damage > 0 then
        self._npc_damage_observer({
            attacker = record.Attacker,
            attacker_character = combat_model(record.Attacker),
            target = record.Target,
            source_kind = record.SourceKind,
            source_id = record.CreativeSkillId,
            attack_id = record.CreativeSkillId,
            base_damage = record.TickDamage,
            multiplier = 1,
            sequence_id = nil,
            C4SourceResolved = true,
            C4PeriodicStatus = true,
            C4SourceSkillId = record.SourceSkillId,
            C4SourceRank = record.SourceRank,
            C4SourceCastSequenceId = record.SequenceId,
        }, applied_damage, false)
    end

    record.Remaining -= 1
    if record.Remaining <= 0 then
        self:_clear_npc_status(
            record.Target,
            record.SourceSkillId,
            record.Serial
        )
        return
    end

    self:_schedule_npc_status_tick(record)
end

--[[
Checks whether one player-to-NPC source status launch is currently legal.

This is a read-only hit-time preflight. It does not roll status success,
consume a magical shot, schedule ticks or mutate HP.

Args:
    attacker (any): Server-owned casting player.
    enemy (any): Current reviewed server NPC Model.

Returns:
    (boolean, string?): Ready state or strict live/source denial reason.
]]
function C4SourceCombatExecutor:can_status_skill_npc(
    attacker: any,
    enemy: any
): (boolean, string?)
    local boundary, reason =
        self:_validate_npc_target(attacker, enemy)

    if not boundary then
        return false, reason
    end

    return true, nil
end

--[[
Executes one reviewed source DEBUFF cast against a server NPC.

A resisted cast schedules nothing. A successful cast replaces only an existing
generation of the same reviewed source skill and starts exact nonlethal ticks.

Args:
    attacker (any): Server-owned casting player.
    enemy (Model): Current reviewed server NPC.
    creative_skill_id (string): Server-selected creative status skill.
    creative_rank (number): Server-resolved purchased rank.
    sequence_id (number?): Existing authoritative cast sequence.

Returns:
    (any?, string?): Source status application evidence or denial reason.
]]
function C4SourceCombatExecutor:status_skill_npc(
    attacker: any,
    enemy: Model,
    creative_skill_id: string,
    creative_rank: number,
    sequence_id: number?
): (any?, string?)
    local boundary, boundary_reason =
        self:_validate_npc_target(attacker, enemy)
    if not boundary then
        return nil, boundary_reason
    end

    local calculated, combat_reason =
        self._combat.status_skill(
            attacker.UserId,
            boundary,
            creative_skill_id,
            creative_rank
        )
    if not calculated then
        return nil, combat_reason
    end

    if calculated.Landed ~= true then
        return {
            Kind = "C4LiveNpcPeriodicStatus",
            Calculation = calculated,
            Applied = false,
            StatusApplied = false,
            Landed = false,
            Scheduled = false,
            HealthDamage = 0,
        }, nil
    end

    local source_kind
    if calculated.EffectType == "BLEED" then
        source_kind = "StatusPhysical"
    elseif calculated.EffectType == "POISON" then
        source_kind = "StatusMagic"
    else
        return nil, "UnsupportedC4LivePeriodicStatusType"
    end

    self._next_status_serial += 1
    local record = {
        Serial = self._next_status_serial,
        Attacker = attacker,
        Target = enemy,
        CreativeSkillId = creative_skill_id,
        SourceSkillId = calculated.SourceSkillId,
        SourceRank = calculated.SourceRank,
        SourceKind = source_kind,
        TickDamage = calculated.TickDamage,
        TickSeconds = calculated.TickSeconds,
        Remaining = calculated.TickCount,
        SequenceId = sequence_id,
    }

    local target_records = self._npc_periodic_statuses[enemy]
    if type(target_records) ~= "table" then
        target_records = {}
        self._npc_periodic_statuses[enemy] = target_records
    end
    target_records[calculated.SourceSkillId] = record
    self:_schedule_npc_status_tick(record)

    return {
        Kind = "C4LiveNpcPeriodicStatus",
        Calculation = calculated,
        Applied = true,
        StatusApplied = true,
        Landed = true,
        Scheduled = true,
        SourceKind = source_kind,
        SourceSkillId = calculated.SourceSkillId,
        SourceRank = calculated.SourceRank,
        TickDamage = calculated.TickDamage,
        TickCount = calculated.TickCount,
        TickSeconds = calculated.TickSeconds,
        HealthDamage = 0,
    }, nil
end

--[[
Executes one live player-to-NPC source PDAM skill.

Args:
    attacker (any): Server-owned attacking player.
    enemy (Model): Current reviewed server NPC.
    creative_skill_id (string): Server-selected creative skill identifier.
    creative_rank (number): Server-resolved purchased rank.
    sequence_id (number?): Existing authoritative action sequence.

Returns:
    (any?, string?): Live NPC PDAM evidence or strict denial reason.
]]
function C4SourceCombatExecutor:physical_skill_npc(
    attacker: any,
    enemy: Model,
    creative_skill_id: string,
    creative_rank: number,
    sequence_id: number?
): (any?, string?)
    local boundary, boundary_reason =
        self:_validate_npc_target(attacker, enemy)
    if not boundary then
        return nil, boundary_reason
    end

    local spatial, spatial_reason =
        self._spatial_context_provider(
            self,
            attacker,
            enemy
        )
    if not spatial then
        return nil, spatial_reason
    end

    local calculated, combat_reason =
        self._combat.physical_skill(
            attacker.UserId,
            boundary,
            creative_skill_id,
            creative_rank,
            spatial
        )
    if not calculated then
        return nil, combat_reason
    end

    local applied, apply_reason = self:_apply_npc_damage(
        attacker,
        enemy,
        calculated.Amount,
        "Skill",
        creative_skill_id,
        sequence_id
    )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4LiveNpcPhysicalSkill",
        Calculation = calculated,
        Applied = true,
        CPAbsorbed = 0,
        HealthDamage = applied.HealthDamage,
        RawDamage = applied.RawDamage,
        HealthBefore = applied.HealthBefore,
        HealthAfter = applied.HealthAfter,
        Lethal = applied.Lethal,
    }, nil
end

--[[
Checks whether one player-to-NPC source magic launch is currently legal.

This is a read-only preflight used by the private cast scheduler handoff. It
does not calculate damage, consume a shot or mutate HP.

Args:
    attacker (any): Server-owned casting player.
    enemy (any): Current reviewed server NPC Model.

Returns:
    (boolean, string?): Ready state or strict live/source denial reason.
]]
function C4SourceCombatExecutor:can_magic_skill_npc(
    attacker: any,
    enemy: any
): (boolean, string?)
    local boundary, reason =
        self:_validate_npc_target(attacker, enemy)

    if not boundary then
        return false, reason
    end

    return true, nil
end

--[[
Executes one live player-to-NPC source MDAM skill.

Args:
    attacker (any): Server-owned casting player.
    enemy (Model): Current reviewed server NPC.
    creative_skill_id (string): Server-selected creative skill identifier.
    creative_rank (number): Server-resolved purchased rank.
    sequence_id (number?): Existing authoritative action sequence.

Returns:
    (any?, string?): Live NPC MDAM evidence or strict denial reason.
]]
function C4SourceCombatExecutor:magic_skill_npc(
    attacker: any,
    enemy: Model,
    creative_skill_id: string,
    creative_rank: number,
    sequence_id: number?
): (any?, string?)
    local boundary, boundary_reason =
        self:_validate_npc_target(attacker, enemy)
    if not boundary then
        return nil, boundary_reason
    end

    local calculated, combat_reason =
        self._combat.magic_skill(
            attacker.UserId,
            boundary,
            creative_skill_id,
            creative_rank
        )
    if not calculated then
        return nil, combat_reason
    end

    local applied, apply_reason = self:_apply_npc_damage(
        attacker,
        enemy,
        calculated.Amount,
        "MagicSkill",
        creative_skill_id,
        sequence_id
    )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4LiveNpcMagicSkill",
        Calculation = calculated,
        Applied = true,
        CPAbsorbed = 0,
        HealthDamage = applied.HealthDamage,
        RawDamage = applied.RawDamage,
        HealthBefore = applied.HealthBefore,
        HealthAfter = applied.HealthAfter,
        Lethal = applied.Lethal,
    }, nil
end

--[[
Executes one live player-versus-player source PDAM skill.

The source calculation provider owns skill identity, criticals, shots,
vulnerability, PvP modifiers and shield arithmetic. This executor owns only
trusted spatial context and final CP/HP mutation.

Args:
    attacker (any): Server-owned attacking player.
    defender (any): Server-owned defending player.
    creative_skill_id (string): Server-selected creative skill identifier.
    creative_rank (number): Server-resolved purchased rank.

Returns:
    (any?, string?): Live PDAM application evidence or denial reason.
]]
function C4SourceCombatExecutor:physical_skill(
    attacker: any,
    defender: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    local ready, ready_reason =
        self:_validate_participants(attacker, defender)
    if not ready then
        return nil, ready_reason
    end

    local spatial, spatial_reason =
        self._spatial_context_provider(
            self,
            attacker,
            defender
        )
    if not spatial then
        return nil, spatial_reason
    end

    local calculated, combat_reason =
        self._combat.physical_skill(
            attacker.UserId,
            defender.UserId,
            creative_skill_id,
            creative_rank,
            spatial
        )
    if not calculated then
        return nil, combat_reason
    end

    local applied, apply_reason =
        self:_apply_player_damage(
            defender,
            calculated.Amount
        )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4LivePhysicalSkill",
        Calculation = calculated,
        Applied = true,
        CPAbsorbed = applied.CPAbsorbed,
        HealthDamage = applied.HealthDamage,
        RawDamage = applied.RawDamage,
        HealthBefore = applied.HealthBefore,
        HealthAfter = applied.HealthAfter,
    }, nil
end

--[[
Executes one live player-versus-player source MDAM skill.

Args:
    attacker (any): Server-owned casting player.
    defender (any): Server-owned defending player.
    creative_skill_id (string): Server-selected creative skill identifier.
    creative_rank (number): Server-resolved purchased rank.

Returns:
    (any?, string?): Live MDAM application evidence or denial reason.
]]
function C4SourceCombatExecutor:magic_skill(
    attacker: any,
    defender: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    local ready, ready_reason =
        self:_validate_participants(attacker, defender)
    if not ready then
        return nil, ready_reason
    end

    local calculated, combat_reason =
        self._combat.magic_skill(
            attacker.UserId,
            defender.UserId,
            creative_skill_id,
            creative_rank
        )
    if not calculated then
        return nil, combat_reason
    end

    local applied, apply_reason =
        self:_apply_player_damage(
            defender,
            calculated.Amount
        )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4LiveMagicSkill",
        Calculation = calculated,
        Applied = true,
        CPAbsorbed = applied.CPAbsorbed,
        HealthDamage = applied.HealthDamage,
        RawDamage = applied.RawDamage,
        HealthBefore = applied.HealthBefore,
        HealthAfter = applied.HealthAfter,
    }, nil
end

--[[
Executes one live source self-heal.

The current accepted source HEAL provider resolves a caster-owned heal rank
without a separate target. This executor therefore applies that result only to
the authenticated caster.

Args:
    caster (any): Server-owned healing player.
    creative_skill_id (string): Server-selected creative heal identifier.
    creative_rank (number): Server-resolved purchased rank.

Returns:
    (any?, string?): Live heal application evidence or denial reason.
]]
function C4SourceCombatExecutor:heal_skill(
    caster: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    local ready, ready_reason = self:_validate_actor(caster)
    if not ready then
        return nil, ready_reason
    end

    local calculated, combat_reason =
        self._combat.heal_skill(
            caster.UserId,
            creative_skill_id,
            creative_rank
        )
    if not calculated then
        return nil, combat_reason
    end

    local applied, apply_reason =
        self:_apply_player_heal(
            caster,
            calculated.Amount
        )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4LiveHealSkill",
        Calculation = calculated,
        Applied = true,
        RawHeal = applied.RawHeal,
        EffectiveHeal = applied.EffectiveHeal,
        HealthBefore = applied.HealthBefore,
        HealthAfter = applied.HealthAfter,
    }, nil
end

--[[
Executes one complete live player-vs-player C4 ordinary attack.

All transforms, elevation mapping, night state, calculation rolls, shield state,
critical state, shot state and resource mutation remain server-owned.

Args:
    attacker (any): Server-owned attacking player.
    defender (any): Server-owned defending player.

Returns:
    (any?, string?): Live attack evidence or strict denial reason.
]]
--[[
Executes one complete live player-to-NPC C4 ordinary attack.

Args:
    attacker (any): Server-owned attacking player.
    enemy (Model): Current reviewed server NPC.
    sequence_id (number?): Existing authoritative action sequence.

Returns:
    (any?, string?): Live NPC ordinary-attack evidence or denial reason.
]]
function C4SourceCombatExecutor:normal_attack_npc(
    attacker: any,
    enemy: Model,
    sequence_id: number?
): (any?, string?)
    local boundary, boundary_reason =
        self:_validate_npc_target(attacker, enemy)
    if not boundary then
        return nil, boundary_reason
    end

    local spatial, spatial_reason =
        self._spatial_context_provider(
            self,
            attacker,
            enemy
        )
    if not spatial then
        return nil, spatial_reason
    end

    local calculated, combat_reason =
        self._combat.normal_attack(
            attacker.UserId,
            boundary,
            spatial
        )
    if not calculated then
        return nil, combat_reason
    end

    if calculated.Miss then
        return {
            Kind = "C4LiveNpcNormalAttack",
            Hit = false,
            Miss = true,
            Calculation = calculated,
            Applied = false,
            CPAbsorbed = 0,
            HealthDamage = 0,
        }, nil
    end

    local applied, apply_reason = self:_apply_npc_damage(
        attacker,
        enemy,
        calculated.Amount,
        "Melee",
        "C4NormalAttack",
        sequence_id
    )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4LiveNpcNormalAttack",
        Hit = true,
        Miss = false,
        Calculation = calculated,
        Applied = true,
        CPAbsorbed = 0,
        HealthDamage = applied.HealthDamage,
        RawDamage = applied.RawDamage,
        HealthBefore = applied.HealthBefore,
        HealthAfter = applied.HealthAfter,
        Lethal = applied.Lethal,
    }, nil
end

function C4SourceCombatExecutor:normal_attack(
    attacker: any,
    defender: any
): (any?, string?)
    local ready, ready_reason =
        self:_validate_participants(attacker, defender)
    if not ready then
        return nil, ready_reason
    end

    local spatial, spatial_reason =
        self._spatial_context_provider(
            self,
            attacker,
            defender
        )
    if not spatial then
        return nil, spatial_reason
    end

    local calculated, combat_reason =
        self._combat.normal_attack(
            attacker.UserId,
            defender.UserId,
            spatial
        )
    if not calculated then
        return nil, combat_reason
    end

    if calculated.Miss then
        return {
            Kind = "C4LiveNormalAttack",
            Hit = false,
            Miss = true,
            Calculation = calculated,
            Applied = false,
            CPAbsorbed = 0,
            HealthDamage = 0,
        }, nil
    end

    local applied, apply_reason =
        self:_apply_player_damage(
            defender,
            calculated.Amount
        )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4LiveNormalAttack",
        Hit = true,
        Miss = false,
        Calculation = calculated,
        Applied = true,
        CPAbsorbed = applied.CPAbsorbed,
        HealthDamage = applied.HealthDamage,
        RawDamage = applied.RawDamage,
        HealthBefore = applied.HealthBefore,
        HealthAfter = applied.HealthAfter,
    }, nil
end

--[[
Returns detached executor capability metadata.

Args:
    None.

Returns:
    any: Gate, authority and fail-closed guarantees.
]]
function C4SourceCombatExecutor:capability(): any
    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = self._enabled,
        ExplicitSpatialScaleRequired = true,
        ServerNightProviderRequired = true,
        RequiresSourceCalculationGate = true,
        RequiresResourceCutoverGate = true,
        ResourceAuthorityConfigured =
            type(self._resources) == "table",
        RequiresPerPlayerResourceCutover = true,
        ServerSpatialContext = true,
        PlayableDamageRoutesThroughCP = true,
        ClientDamageAuthority = false,
        ClientHitAuthority = false,
        ClientCriticalAuthority = false,
        ClientShieldAuthority = false,
        ClientShotAuthority = false,
        NormalAttackLiveApplication = true,
        PhysicalSkillLiveApplication = true,
        MagicSkillLiveApplication = true,
        SelfHealLiveApplication = true,
        NpcBoundaryProviderConfigured =
            type(self._npc_boundary_provider) == "function",
        NpcDamageObserverConfigured =
            type(self._npc_damage_observer) == "function",
        NpcNormalAttackLiveApplication = true,
        NpcPhysicalSkillLiveApplication = true,
        NpcMagicSkillLiveApplication = true,
        NpcMagicSkillReadOnlyPreflight = true,
        NpcStatusSkillReadOnlyPreflight = true,
        NpcPeriodicStatusLiveApplication = true,
        NpcPeriodicStatusNonlethal = true,
        NpcPeriodicStatusRefreshBySourceSkill = true,
        NpcDamageBypassesCombatPoints = true,
        NpcDamageCallbackPreservation = true,
    }
end

return C4SourceCombatExecutor
