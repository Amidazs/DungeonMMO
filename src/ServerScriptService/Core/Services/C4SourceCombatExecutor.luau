--!strict
-- Disabled-by-default live player-vs-player C4 source-combat executor.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

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
local MovementSlow = require(
    ServerScriptService.Combat.RangerSlowService
)
local NpcSleep = require(
    ServerScriptService.Combat.C4NpcSleepService
)
local NpcElementalVulnerability = require(
    ServerScriptService.Combat.C4NpcElementalVulnerabilityService
)
local EnemyWeakening = require(
    ServerScriptService.Combat.EnemyWeakeningService
)
local ManaService = require(
    ServerScriptService.Combat.ManaService
)
local MageHealService = require(
    ServerScriptService.Combat.MageHealService
)
local PartyHealService = require(
    ServerScriptService.Combat.PartyHealService
)
local NpcRoot = require(
    ServerScriptService.Combat.C4NpcRootService
)
local ActiveSourceEffects = require(
    ServerScriptService.Core.Services.C4ActiveSourceEffectState
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
        _npc_corpse_boundary_provider =
            config.CorpseBoundaryProvider
            or NpcBoundaries.for_corpse_model,
        _npc_damage_observer = config.NpcDamageObserver,
        _movement_slow = config.MovementSlowProvider or MovementSlow,
        _npc_sleep = config.SleepProvider or NpcSleep,
        _npc_elemental_vulnerability =
            config.ElementalVulnerabilityProvider
            or NpcElementalVulnerability,
        _enemy_weakening =
            config.EnemyWeakeningProvider
            or EnemyWeakening,
        _mana = config.ManaProvider or ManaService,
        _player_heal = config.PlayerHealProvider or MageHealService,
        _party_heal = config.PartyHealProvider or PartyHealService,
        _player_resurrection =
            config.PlayerResurrectionProvider,
        _npc_root = config.RootProvider or NpcRoot,
        _active_source_effects =
            config.ActiveSourceEffectProvider
            or ActiveSourceEffects,
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
Installs the current Dungeon player-resurrection authority.

RuntimeServices creates the combat executor before a concrete Dungeon death
service exists, so the live Dungeon runtime installs this provider once its
session-bound death authority has been created.

Args:
    provider (any?): Object exposing can_skill_resurrect and
        request_skill_resurrection, or nil to clear the binding.

Returns:
    nil: Replaces only this executor's resurrection provider.
]]
function C4SourceCombatExecutor:set_player_resurrection_provider(
    provider: any?
)
    assert(
        provider == nil
            or (
                type(provider) == "table"
                and type(
                    provider.can_skill_resurrect
                ) == "function"
                and type(
                    provider.request_skill_resurrection
                ) == "function"
            ),
        "C4 resurrection provider contract is invalid"
    )
    self._player_resurrection = provider
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
Checks independent live/source gates for a self-targeted source skill.

Args:
    actor (any): Server-owned casting player.

Returns:
    (boolean, string?): Ready state or strict denial reason.
]]
function C4SourceCombatExecutor:_validate_self_actor(
    actor: any
): (boolean, string?)
    if not self._enabled then
        return false, "C4LiveCombatExecutorDisabled"
    end
    if type(actor) ~= "userdata"
        and type(actor) ~= "table"
    then
        return false, "InvalidC4LiveCombatAttacker"
    end
    if type(actor.UserId) ~= "number" then
        return false, "InvalidC4LiveCombatAttacker"
    end
    if not self._combat.is_enabled() then
        return false, "C4SourceCombatCalculationDisabled"
    end
    if type(self._resources) ~= "table"
        or self._resources.is_active(actor) ~= true
    then
        return false, "C4LiveCombatParticipantNotCutOver"
    end

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

    local boundary, boundary_reason =
        self._npc_boundary_provider(enemy)
    if not boundary then
        return nil, boundary_reason
    end

    if self._npc_elemental_vulnerability
        and type(
            self._npc_elemental_vulnerability.decorate_boundary
        ) == "function"
    then
        boundary =
            self._npc_elemental_vulnerability.decorate_boundary(
                enemy,
                boundary
            )
    end

    return boundary, nil
end

--[[
Validates one player caster and one current server-owned NPC corpse.

Args:
    attacker (any): Server-owned casting player.
    corpse (any): Current dead server NPC Model.

Returns:
    (any?, string?): Reviewed corpse boundary or strict denial reason.
]]
function C4SourceCombatExecutor:_validate_npc_corpse(
    attacker: any,
    corpse: any
): (any?, string?)
    local ready, ready_reason = self:_validate_actor(attacker)
    if not ready then
        return nil, ready_reason
    end

    if typeof(corpse) ~= "Instance"
        or not corpse:IsA("Model")
    then
        return nil, "InvalidC4LiveNpcCorpseTarget"
    end
    if type(self._npc_corpse_boundary_provider) ~= "function" then
        return nil, "C4NpcCorpseSourceBoundaryUnavailable"
    end

    return self._npc_corpse_boundary_provider(corpse)
end

--[[
Checks one corpse-target source cast without mutating the world.

Args:
    attacker (any): Server-owned casting player.
    corpse (any): Current reviewed NPC corpse.
    source_range (number?): Optional source-unit cast/effect range.

Returns:
    (boolean, string?): Readiness or strict denial reason.
]]
function C4SourceCombatExecutor:can_corpse_skill_npc(
    attacker: any,
    corpse: any,
    source_range: number?
): (boolean, string?)
    local boundary, reason =
        self:_validate_npc_corpse(attacker, corpse)
    if not boundary then
        return false, reason
    end

    if source_range ~= nil then
        return self:_validate_npc_source_range(
            attacker,
            corpse,
            source_range
        )
    end

    return true, nil
end

--[[
Checks one undead-only source magic target before any resource mutation.

Args:
    attacker (any): Server-owned casting player.
    enemy (any): Current reviewed server NPC.
    source_range (number?): Optional source-unit cast/effect range.

Returns:
    (boolean, string?): Readiness or strict undead/range denial reason.
]]
function C4SourceCombatExecutor:can_undead_magic_skill_npc(
    attacker: any,
    enemy: any,
    source_range: number?
): (boolean, string?)
    local boundary, boundary_reason =
        self:_validate_npc_target(attacker, enemy)
    if not boundary then
        return false, boundary_reason
    end
    if boundary.SourceNpcRace ~= "UNDEAD" then
        return false, "C4UndeadMagicTargetRequired"
    end

    if source_range ~= nil then
        return self:_validate_npc_source_range(
            attacker,
            enemy,
            source_range
        )
    end

    return true, nil
end

--[[
Checks one source-unit range against authoritative Roblox root positions.

The configured source-units-per-stud scale is the same explicit conversion
owned by the C4 combat cutover. No client position or range value is accepted.

Args:
    attacker (any): Server-owned casting player.
    enemy (any): Current reviewed server NPC Model.
    source_range (number): Reviewed C4 cast/effect range.

Returns:
    (boolean, string?): Range readiness or strict spatial denial reason.
]]
function C4SourceCombatExecutor:_validate_npc_source_range(
    attacker: any,
    enemy: any,
    source_range: number
): (boolean, string?)
    if type(source_range) ~= "number"
        or source_range ~= source_range
        or source_range <= 0
        or source_range >= math.huge
    then
        return false, "InvalidC4SourceCastRange"
    end
    if type(self._source_units_per_stud) ~= "number" then
        return false, "C4SourceCastRangeScaleUnconfigured"
    end

    local attacker_model = combat_model(attacker)
    local enemy_model = combat_model(enemy)
    if not attacker_model or not enemy_model then
        return false, "C4LiveCombatCharacterUnavailable"
    end

    local attacker_root =
        attacker_model:FindFirstChild("HumanoidRootPart")
    local enemy_root =
        enemy_model:FindFirstChild("HumanoidRootPart")
    if not attacker_root or not enemy_root then
        return false, "C4LiveCombatRootUnavailable"
    end

    local distance_source =
        (attacker_root.Position - enemy_root.Position).Magnitude
        * self._source_units_per_stud

    if distance_source > source_range then
        return false, "C4SourceCastTargetOutOfRange"
    end

    return true, nil
end

--[[
Checks a source-unit range between two server-owned players.

Args:
    caster (any): Server-owned support caster.
    target (any): Server-owned support target.
    source_range (number): Reviewed C4 cast/effect range.

Returns:
    (boolean, string?): Range readiness or strict spatial denial reason.
]]
function C4SourceCombatExecutor:_validate_player_source_range(
    caster: any,
    target: any,
    source_range: number
): (boolean, string?)
    if type(source_range) ~= "number"
        or source_range ~= source_range
        or source_range <= 0
        or source_range >= math.huge
    then
        return false, "InvalidC4SourceCastRange"
    end
    if type(self._source_units_per_stud) ~= "number" then
        return false, "C4SourceCastRangeScaleUnconfigured"
    end

    local caster_model = combat_model(caster)
    local target_model = combat_model(target)
    if not caster_model or not target_model then
        return false, "C4LiveCombatCharacterUnavailable"
    end

    local caster_root =
        caster_model:FindFirstChild("HumanoidRootPart")
    local target_root =
        target_model:FindFirstChild("HumanoidRootPart")
    if not caster_root or not target_root then
        return false, "C4LiveCombatRootUnavailable"
    end

    local distance_source =
        (caster_root.Position - target_root.Position).Magnitude
        * self._source_units_per_stud
    if distance_source > source_range then
        return false, "C4SourceCastTargetOutOfRange"
    end

    return true, nil
end

--[[
Validates one friendly source target, including self-targeting.

Both actors must be current source-cutover participants. Same-player support is
allowed because C4 TARGET_ONE support skills may be cast on self.

Args:
    caster (any): Server-owned support caster.
    target (any): Server-owned support target.
    source_range (number?): Optional reviewed source range.

Returns:
    (boolean, string?): Target readiness or strict denial reason.
]]
function C4SourceCombatExecutor:can_support_skill_player(
    caster: any,
    target: any,
    source_range: number?
): (boolean, string?)
    local caster_ready, caster_reason =
        self:_validate_actor(caster)
    if not caster_ready then
        return false, caster_reason
    end

    local target_ready, target_reason =
        self:_validate_actor(target)
    if not target_ready then
        return false, target_reason
    end

    if source_range ~= nil then
        return self:_validate_player_source_range(
            caster,
            target,
            source_range
        )
    end

    return true, nil
end

--[[
Returns the nearest ancestor Model containing a Humanoid.

Args:
    instance (Instance): Descendant returned by the server overlap query.

Returns:
    Model?: Combat model owning the part, otherwise nil.
]]
local function combat_model_from_descendant(
    instance: Instance
): Model?
    local current: Instance? = instance

    while current and current ~= Workspace do
        if current:IsA("Model")
            and current:FindFirstChildOfClass("Humanoid")
        then
            return current
        end
        current = current.Parent
    end

    return nil
end

--[[
Collects reviewed NPC targets for a source TARGET_AREA magic cast.

The pinned C4 TargetArea handler always keeps the selected primary target, then
checks other offensive targets against skillRadius from the caster. DungeonMMO
also requires secondary targets to share the primary target's encounter so an
instance cannot damage NPCs from another room/run.

Args:
    attacker (any): Server-owned casting player.
    primary (Model): Reviewed selected NPC target.
    primary_boundary (any): Already-validated primary source boundary.
    source_radius (number): C4 skillRadius in source units.

Returns:
    ({Model}?, {any}?, string?): Ordered models/boundaries or denial reason.
]]
function C4SourceCombatExecutor:_collect_npc_area_targets(
    attacker: any,
    primary: Model,
    primary_boundary: any,
    source_radius: number
): ({Model}?, {any}?, string?)
    if type(source_radius) ~= "number"
        or source_radius ~= source_radius
        or source_radius <= 0
        or source_radius >= math.huge
    then
        return nil, nil, "InvalidC4SourceAreaRadius"
    end
    if type(self._source_units_per_stud) ~= "number" then
        return nil, nil, "C4SourceCastRangeScaleUnconfigured"
    end

    local attacker_model = combat_model(attacker)
    if not attacker_model then
        return nil, nil, "C4LiveCombatCharacterUnavailable"
    end

    local attacker_root =
        attacker_model:FindFirstChild("HumanoidRootPart")
    if not attacker_root or not attacker_root:IsA("BasePart") then
        return nil, nil, "C4LiveCombatRootUnavailable"
    end

    local radius_studs =
        source_radius / self._source_units_per_stud
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {attacker_model}
    params.RespectCanCollide = false

    local primary_encounter =
        primary:GetAttribute("DungeonEncounterId")
    local models: {Model} = {primary}
    local boundaries = {primary_boundary}
    local seen: {[Model]: boolean} = {
        [primary] = true,
    }

    for _, part in Workspace:GetPartBoundsInRadius(
        attacker_root.Position,
        radius_studs,
        params
    ) do
        local candidate = combat_model_from_descendant(part)
        if not candidate or seen[candidate] then
            continue
        end
        seen[candidate] = true

        if candidate:GetAttribute("DungeonEncounterId")
            ~= primary_encounter
        then
            continue
        end

        local boundary =
            self:_validate_npc_target(attacker, candidate)
        if boundary then
            table.insert(models, candidate)
            table.insert(boundaries, boundary)
        end
    end

    return models, boundaries, nil
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
    if amount > 0
        and self._npc_sleep
        and type(self._npc_sleep.wake_on_damage) == "function"
    then
        self._npc_sleep.wake_on_damage(enemy)
    end
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
    source_range (number?): Optional reviewed source-unit range.

Returns:
    (boolean, string?): Ready state or strict live/source denial reason.
]]
function C4SourceCombatExecutor:can_status_skill_npc(
    attacker: any,
    enemy: any,
    source_range: number?
): (boolean, string?)
    local boundary, reason =
        self:_validate_npc_target(attacker, enemy)

    if not boundary then
        return false, reason
    end
    if source_range ~= nil then
        return self:_validate_npc_source_range(
            attacker,
            enemy,
            source_range
        )
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
Executes one live C4 TARGET_AREA periodic-status cast against server NPCs.

The selected NPC plus same-encounter reviewed NPCs inside the source radius are
calculated with one shared magical-shot snapshot. Each landed target receives
its own exact periodic status generation.

Args:
    attacker (any): Server-owned casting player.
    enemy (Model): Current reviewed selected NPC.
    creative_skill_id (string): Server-selected creative area status skill.
    creative_rank (number): Server-resolved purchased rank.
    source_radius (number): Reviewed C4 skillRadius in source units.
    sequence_id (number?): Existing authoritative cast sequence.

Returns:
    (any?, string?): Live area-status evidence or strict denial reason.
]]
function C4SourceCombatExecutor:status_area_skill_npc(
    attacker: any,
    enemy: Model,
    creative_skill_id: string,
    creative_rank: number,
    source_radius: number,
    sequence_id: number?
): (any?, string?)
    local primary_boundary, boundary_reason =
        self:_validate_npc_target(attacker, enemy)
    if not primary_boundary then
        return nil, boundary_reason
    end

    local targets, boundaries, area_reason =
        self:_collect_npc_area_targets(
            attacker,
            enemy,
            primary_boundary,
            source_radius
        )
    if not targets or not boundaries then
        return nil, area_reason
    end

    local calculated, combat_reason =
        self._combat.status_area_skill(
            attacker.UserId,
            boundaries,
            creative_skill_id,
            creative_rank
        )
    if not calculated then
        return nil, combat_reason
    end
    if calculated.SourceSkillRadius ~= source_radius
        or #calculated.Results ~= #targets
    then
        return nil, "C4PeriodicAreaCalculationContractMismatch"
    end

    local applications = {}
    for index, target in ipairs(targets) do
        local result = calculated.Results[index]
        if result.Landed ~= true then
            table.insert(applications, {
                Target = target,
                Calculation = result,
                Landed = false,
                StatusApplied = false,
            })
            continue
        end

        local source_kind = if result.EffectType == "POISON"
            then "StatusMagic"
            elseif result.EffectType == "BLEED"
            then "StatusPhysical"
            else nil
        if not source_kind then
            return nil, "UnsupportedC4LivePeriodicStatusType"
        end

        self._next_status_serial += 1
        local record = {
            Serial = self._next_status_serial,
            Attacker = attacker,
            Target = target,
            CreativeSkillId = creative_skill_id,
            SourceSkillId = result.SourceSkillId,
            SourceRank = result.SourceRank,
            SourceKind = source_kind,
            TickDamage = result.TickDamage,
            TickSeconds = result.TickSeconds,
            Remaining = result.TickCount,
            SequenceId = sequence_id,
        }

        local target_records = self._npc_periodic_statuses[target]
        if type(target_records) ~= "table" then
            target_records = {}
            self._npc_periodic_statuses[target] = target_records
        end
        target_records[result.SourceSkillId] = record
        self:_schedule_npc_status_tick(record)

        table.insert(applications, {
            Target = target,
            Calculation = result,
            Landed = true,
            StatusApplied = true,
        })
    end

    local landed_count = 0
    for _, application in ipairs(applications) do
        if application.Landed then
            landed_count += 1
        end
    end

    return {
        Kind = "C4LiveNpcPeriodicStatusArea",
        Calculation = calculated,
        Applications = applications,
        Applied = landed_count > 0,
        StatusApplied = landed_count > 0,
        TargetCount = #applications,
        LandedCount = landed_count,
        SourceSkillRadius = source_radius,
        Spiritshot = calculated.Spiritshot,
        BlessedSpiritshot = calculated.BlessedSpiritshot,
    }, nil
end

--[[
Executes one live C4 self MANAHEAL skill.

HP is consumed at hit time and is capped so the caster remains at least at one
HP, matching the source cast path. MP restoration is then clamped by the
authoritative ManaService. The source calculation owns one magical shot.

Args:
    caster (any): Server-owned casting player.
    creative_skill_id (string): Reviewed self mana-heal skill.
    creative_rank (number): Server-resolved purchased rank.
    _sequence_id (number?): Existing authoritative cast sequence.

Returns:
    (any?, string?): Live HP-to-MP evidence or strict denial reason.
]]
function C4SourceCombatExecutor:mana_heal_self(
    caster: any,
    creative_skill_id: string,
    creative_rank: number,
    _sequence_id: number?
): (any?, string?)
    local ready, ready_reason = self:_validate_self_actor(caster)
    if not ready then
        return nil, ready_reason
    end

    local calculated, combat_reason =
        self._combat.mana_heal_skill(
            caster.UserId,
            creative_skill_id,
            creative_rank
        )
    if not calculated then
        return nil, combat_reason
    end

    local humanoid, humanoid_reason =
        self._humanoid_provider(caster)
    if not humanoid then
        return nil, humanoid_reason
    end
    if not self._mana
        or type(self._mana.restore) ~= "function"
    then
        return nil, "C4LiveManaAuthorityUnavailable"
    end

    local health_before = humanoid.Health
    local hp_consumed = math.min(
        calculated.HpConsume,
        math.max(0, health_before - 1)
    )
    humanoid.Health = health_before - hp_consumed

    local mana_restored = self._mana.restore(
        caster,
        calculated.ManaRestore
    )

    return {
        Kind = "C4LiveManaHeal",
        Calculation = calculated,
        Applied = true,
        HpRequested = calculated.HpConsume,
        HpConsumed = hp_consumed,
        HealthBefore = health_before,
        HealthAfter = humanoid.Health,
        ManaRequested = calculated.ManaRestore,
        ManaRestored = mana_restored,
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
    source_range (number?): Optional reviewed source-unit range.

Returns:
    (boolean, string?): Ready state or strict live/source denial reason.
]]
function C4SourceCombatExecutor:can_magic_skill_npc(
    attacker: any,
    enemy: any,
    source_range: number?
): (boolean, string?)
    local boundary, reason =
        self:_validate_npc_target(attacker, enemy)

    if not boundary then
        return false, reason
    end
    if source_range ~= nil then
        return self:_validate_npc_source_range(
            attacker,
            enemy,
            source_range
        )
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
Executes one live player-to-NPC C4 TARGET_AREA MDAM cast.

The selected NPC is always included after normal cast/effect range validation.
Additional reviewed NPCs are collected within the source skillRadius around the
caster, matching the pinned C4 TargetArea semantics. One magical shot snapshot
is shared across every target calculation and consumed once for the cast.

Args:
    attacker (any): Server-owned casting player.
    enemy (Model): Current reviewed selected NPC.
    creative_skill_id (string): Server-selected creative area spell.
    creative_rank (number): Server-resolved purchased rank.
    source_radius (number): Reviewed C4 skillRadius in source units.
    sequence_id (number?): Existing authoritative action sequence.

Returns:
    (any?, string?): Live area application evidence or denial reason.
]]
function C4SourceCombatExecutor:magic_area_skill_npc(
    attacker: any,
    enemy: Model,
    creative_skill_id: string,
    creative_rank: number,
    source_radius: number,
    sequence_id: number?
): (any?, string?)
    local primary_boundary, boundary_reason =
        self:_validate_npc_target(attacker, enemy)
    if not primary_boundary then
        return nil, boundary_reason
    end

    local targets, boundaries, area_reason =
        self:_collect_npc_area_targets(
            attacker,
            enemy,
            primary_boundary,
            source_radius
        )
    if not targets or not boundaries then
        return nil, area_reason
    end

    local calculated, combat_reason =
        self._combat.magic_area_skill(
            attacker.UserId,
            boundaries,
            creative_skill_id,
            creative_rank
        )
    if not calculated then
        return nil, combat_reason
    end
    if calculated.SourceSkillRadius ~= source_radius
        or #calculated.Results ~= #targets
    then
        return nil, "C4MagicAreaCalculationContractMismatch"
    end

    local applications = {}
    local total_damage = 0

    for index, target in ipairs(targets) do
        local humanoid = target:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            continue
        end

        local result = calculated.Results[index]
        local applied, apply_reason = self:_apply_npc_damage(
            attacker,
            target,
            result.Amount,
            "MagicArea",
            creative_skill_id,
            sequence_id
        )
        if not applied then
            return nil, apply_reason
        end

        total_damage += applied.HealthDamage
        table.insert(applications, {
            Target = target,
            Calculation = result,
            HealthDamage = applied.HealthDamage,
            RawDamage = applied.RawDamage,
            HealthBefore = applied.HealthBefore,
            HealthAfter = applied.HealthAfter,
            Lethal = applied.Lethal,
        })
    end

    return {
        Kind = "C4LiveNpcMagicArea",
        Calculation = calculated,
        Applications = applications,
        Applied = #applications > 0,
        TargetCount = #applications,
        TotalHealthDamage = total_damage,
        SourceSkillRadius = source_radius,
        Spiritshot = calculated.Spiritshot,
        BlessedSpiritshot = calculated.BlessedSpiritshot,
    }, nil
end

--[[
Executes one live player-to-NPC C4 DRAIN skill.

For reviewed living NPCs the pinned source drain amount is exactly the target HP
removed by the magic hit, capped naturally by remaining HP. The caster then
receives absorbAbs plus absorbPart times that drained HP, capped at MaxHealth.

Args:
    attacker (any): Server-owned casting player.
    enemy (Model): Current reviewed server NPC.
    creative_skill_id (string): Server-selected creative drain skill.
    creative_rank (number): Server-resolved purchased rank.
    sequence_id (number?): Existing authoritative action sequence.

Returns:
    (any?, string?): Live damage/heal evidence or strict denial reason.
]]
function C4SourceCombatExecutor:magic_drain_skill_npc(
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
        self._combat.drain_skill(
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
        "MagicDrain",
        creative_skill_id,
        sequence_id
    )
    if not applied then
        return nil, apply_reason
    end

    local requested_heal =
        calculated.AbsorbAbs
        + calculated.AbsorbPart * applied.HealthDamage
    local healed, heal_reason = self:_apply_player_heal(
        attacker,
        requested_heal
    )
    if not healed then
        return nil, heal_reason
    end

    return {
        Kind = "C4LiveNpcMagicDrain",
        Calculation = calculated,
        Applied = true,
        CPAbsorbed = 0,
        HealthDamage = applied.HealthDamage,
        RawDamage = applied.RawDamage,
        HealthBefore = applied.HealthBefore,
        HealthAfter = applied.HealthAfter,
        Lethal = applied.Lethal,
        DrainableHealthDamage = applied.HealthDamage,
        RequestedHeal = requested_heal,
        EffectiveHeal = healed.EffectiveHeal,
        CasterHealthBefore = healed.HealthBefore,
        CasterHealthAfter = healed.HealthAfter,
        AbsorbPart = calculated.AbsorbPart,
        AbsorbAbs = calculated.AbsorbAbs,
    }, nil
end

--[[
Executes one live C4 corpse-target drain.

The source fixed absorption heals the caster, then the reviewed dead NPC corpse
is consumed so it cannot be drained repeatedly.

Args:
    attacker (any): Server-owned casting player.
    corpse (Model): Current reviewed dead NPC.
    creative_skill_id (string): Reviewed corpse-drain skill.
    creative_rank (number): Server-resolved purchased rank.
    _sequence_id (number?): Existing authoritative cast sequence.

Returns:
    (any?, string?): Live corpse-drain evidence or strict denial reason.
]]
function C4SourceCombatExecutor:corpse_drain_skill_npc(
    attacker: any,
    corpse: Model,
    creative_skill_id: string,
    creative_rank: number,
    _sequence_id: number?
): (any?, string?)
    local boundary, boundary_reason =
        self:_validate_npc_corpse(attacker, corpse)
    if not boundary then
        return nil, boundary_reason
    end

    local calculated, combat_reason =
        self._combat.corpse_drain_skill(
            attacker.UserId,
            boundary,
            creative_skill_id,
            creative_rank
        )
    if not calculated then
        return nil, combat_reason
    end

    local healed, heal_reason = self:_apply_player_heal(
        attacker,
        calculated.HealAmount
    )
    if not healed then
        return nil, heal_reason
    end

    corpse:SetAttribute("C4CorpseConsumed", true)
    corpse:Destroy()

    return {
        Kind = "C4LiveNpcCorpseDrain",
        Calculation = calculated,
        Applied = true,
        CorpseConsumed = true,
        RequestedHeal = calculated.HealAmount,
        EffectiveHeal = healed.EffectiveHeal,
        CasterHealthBefore = healed.HealthBefore,
        CasterHealthAfter = healed.HealthAfter,
    }, nil
end

--[[
Executes one live player-to-NPC C4 Sleep control skill.

A resisted cast applies no control state. A landed cast delegates to the
server-owned NPC sleep authority, which suppresses movement/actions and is
cleared by normal direct damage in the same ordering as the pinned source.

Args:
    attacker (any): Server-owned casting player.
    enemy (Model): Current reviewed server NPC.
    creative_skill_id (string): Server-selected creative Sleep skill.
    creative_rank (number): Server-resolved purchased rank.
    sequence_id (number?): Existing authoritative cast sequence.

Returns:
    (any?, string?): Live Sleep evidence or strict denial reason.
]]
function C4SourceCombatExecutor:sleep_skill_npc(
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
        self._combat.sleep_skill(
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
            Kind = "C4LiveNpcSleep",
            Calculation = calculated,
            Applied = false,
            SleepApplied = false,
            Landed = false,
            SequenceId = sequence_id,
        }, nil
    end

    if not self._npc_sleep
        or type(self._npc_sleep.apply) ~= "function"
    then
        return nil, "C4NpcSleepAuthorityUnavailable"
    end

    local applied = self._npc_sleep.apply(
        enemy,
        calculated.DurationSeconds
    )
    if applied ~= true then
        return nil, "C4NpcSleepApplicationFailed"
    end

    return {
        Kind = "C4LiveNpcSleep",
        Calculation = calculated,
        Applied = true,
        SleepApplied = true,
        Landed = true,
        DurationSeconds = calculated.DurationSeconds,
        BreaksOnDamage = calculated.BreaksOnDamage,
        StopsMovement = calculated.StopsMovement,
        StopsAttacks = calculated.StopsAttacks,
        StopsCasting = calculated.StopsCasting,
        SequenceId = sequence_id,
    }, nil
end

--[[
Executes one live player-to-NPC elemental-vulnerability debuff.

A resisted cast changes no runtime state. A landed cast installs the exact
source multiplier and duration in the shared NPC elemental authority. Future
source magic calculations receive a decorated boundary, so elemental damage
uses the debuff without mutating the immutable source reference table.

Args:
    attacker (any): Server-owned casting player.
    enemy (Model): Current reviewed server NPC.
    creative_skill_id (string): Server-selected creative debuff.
    creative_rank (number): Server-resolved purchased rank.
    sequence_id (number?): Existing authoritative cast sequence.

Returns:
    (any?, string?): Live vulnerability evidence or strict denial reason.
]]
function C4SourceCombatExecutor:elemental_vulnerability_skill_npc(
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
        self._combat.elemental_vulnerability_skill(
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
            Kind = "C4LiveNpcElementalVulnerability",
            Calculation = calculated,
            Applied = false,
            VulnerabilityApplied = false,
            Landed = false,
            SequenceId = sequence_id,
        }, nil
    end

    local authority = self._npc_elemental_vulnerability
    if not authority or type(authority.apply) ~= "function" then
        return nil, "C4NpcElementalVulnerabilityAuthorityUnavailable"
    end

    local applied = authority.apply(
        enemy,
        calculated.VulnerabilityStat,
        calculated.VulnerabilityMultiplier,
        calculated.DurationSeconds
    )
    if applied ~= true then
        return nil, "C4NpcElementalVulnerabilityApplicationFailed"
    end

    return {
        Kind = "C4LiveNpcElementalVulnerability",
        Calculation = calculated,
        Applied = true,
        VulnerabilityApplied = true,
        Landed = true,
        VulnerabilityStat = calculated.VulnerabilityStat,
        VulnerabilityMultiplier =
            calculated.VulnerabilityMultiplier,
        DurationSeconds = calculated.DurationSeconds,
        SequenceId = sequence_id,
    }, nil
end

--[[
Executes one live player-to-NPC physical-attack weakening debuff.

A resisted cast changes no runtime state. A landed cast delegates to the
shared NPC weakening authority with only a power reduction; attack cadence is
left unchanged because source Curse: Weakness modifies PHYSICAL_ATTACK only.

Args:
    attacker (any): Server-owned casting player.
    enemy (Model): Current reviewed server NPC.
    creative_skill_id (string): Server-selected creative weakening debuff.
    creative_rank (number): Server-resolved purchased rank.
    sequence_id (number?): Existing authoritative cast sequence.

Returns:
    (any?, string?): Live weakening evidence or strict denial reason.
]]
function C4SourceCombatExecutor:physical_attack_weakening_skill_npc(
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
        self._combat.physical_attack_weakening_skill(
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
            Kind = "C4LiveNpcPhysicalAttackWeakening",
            Calculation = calculated,
            Applied = false,
            WeakeningApplied = false,
            Landed = false,
            SequenceId = sequence_id,
        }, nil
    end

    local authority = self._enemy_weakening
    if not authority or type(authority.apply) ~= "function" then
        return nil, "C4NpcPhysicalAttackWeakeningAuthorityUnavailable"
    end

    local applied = authority.apply(
        enemy,
        calculated.PowerReductionFraction,
        0,
        calculated.DurationSeconds
    )
    if applied ~= true then
        return nil, "C4NpcPhysicalAttackWeakeningApplicationFailed"
    end

    return {
        Kind = "C4LiveNpcPhysicalAttackWeakening",
        Calculation = calculated,
        Applied = true,
        WeakeningApplied = true,
        Landed = true,
        PhysicalAttackMultiplier =
            calculated.PhysicalAttackMultiplier,
        PowerReductionFraction =
            calculated.PowerReductionFraction,
        DurationSeconds = calculated.DurationSeconds,
        SequenceId = sequence_id,
    }, nil
end

--[[
Executes one live player-to-NPC physical-attack-speed weakening debuff.

A resisted cast changes no runtime state. A landed cast delegates to the
shared NPC weakening authority with zero power reduction and the exact source
cadence reduction.

Args:
    attacker (any): Server-owned casting player.
    enemy (Model): Current reviewed server NPC.
    creative_skill_id (string): Server-selected creative weakening debuff.
    creative_rank (number): Server-resolved purchased rank.
    sequence_id (number?): Existing authoritative cast sequence.

Returns:
    (any?, string?): Live cadence-weakening evidence or denial reason.
]]
function C4SourceCombatExecutor:physical_attack_rate_weakening_skill_npc(
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
        self._combat.physical_attack_rate_weakening_skill(
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
            Kind = "C4LiveNpcPhysicalAttackRateWeakening",
            Calculation = calculated,
            Applied = false,
            WeakeningApplied = false,
            Landed = false,
            SequenceId = sequence_id,
        }, nil
    end

    local authority = self._enemy_weakening
    if not authority or type(authority.apply) ~= "function" then
        return nil, "C4NpcPhysicalAttackRateWeakeningAuthorityUnavailable"
    end

    local applied = authority.apply(
        enemy,
        0,
        calculated.RateReductionFraction,
        calculated.DurationSeconds
    )
    if applied ~= true then
        return nil, "C4NpcPhysicalAttackRateWeakeningApplicationFailed"
    end

    return {
        Kind = "C4LiveNpcPhysicalAttackRateWeakening",
        Calculation = calculated,
        Applied = true,
        WeakeningApplied = true,
        Landed = true,
        PhysicalAttackSpeedMultiplier =
            calculated.PhysicalAttackSpeedMultiplier,
        RateReductionFraction =
            calculated.RateReductionFraction,
        DurationSeconds = calculated.DurationSeconds,
        SequenceId = sequence_id,
    }, nil
end

--[[
Executes one live player-to-NPC MDAM skill with a reviewed movement slow.

Damage is applied through the normal source NPC bookkeeping path. A landed
slow is applied only if the NPC survives that damage, using the shared
non-stacking server movement-slow authority.

Args:
    attacker (any): Server-owned casting player.
    enemy (Model): Current reviewed server NPC.
    creative_skill_id (string): Server-selected creative slow spell.
    creative_rank (number): Server-resolved purchased rank.
    sequence_id (number?): Existing authoritative action sequence.

Returns:
    (any?, string?): Live damage/slow evidence or strict denial reason.
]]
function C4SourceCombatExecutor:magic_slow_skill_npc(
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
        self._combat.magic_slow_skill(
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

    local slow_applied = false
    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
    if calculated.SlowLanded
        and humanoid
        and humanoid.Health > 0
        and self._movement_slow
        and type(self._movement_slow.apply) == "function"
    then
        slow_applied = self._movement_slow.apply(
            enemy,
            calculated.SlowFraction,
            calculated.DurationSeconds
        ) == true
    end

    return {
        Kind = "C4LiveNpcMagicMovementSlow",
        Calculation = calculated,
        Applied = true,
        CPAbsorbed = 0,
        HealthDamage = applied.HealthDamage,
        RawDamage = applied.RawDamage,
        HealthBefore = applied.HealthBefore,
        HealthAfter = applied.HealthAfter,
        Lethal = applied.Lethal,
        SlowLanded = calculated.SlowLanded,
        SlowApplied = slow_applied,
        SpeedMultiplier = calculated.SpeedMultiplier,
        SlowFraction = calculated.SlowFraction,
        DurationSeconds = calculated.DurationSeconds,
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
Executes one live source heal on a friendly player target.

The source calculation consumes the caster's one magical shot. Actual health
mutation uses the existing heal authority so contribution/support callbacks
remain intact.

Args:
    caster (any): Server-owned healing player.
    target (any): Server-owned friendly target.
    creative_skill_id (string): Server-selected creative heal.
    creative_rank (number): Server-resolved purchased rank.

Returns:
    (any?, string?): Live targeted-heal evidence or denial reason.
]]
function C4SourceCombatExecutor:heal_skill_target(
    caster: any,
    target: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    local ready, ready_reason =
        self:can_support_skill_player(caster, target)
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

    local provider = self._player_heal
    if not provider
        or type(provider.apply_heal) ~= "function"
    then
        return nil, "C4LivePlayerHealAuthorityUnavailable"
    end

    local effective = provider.apply_heal(
        caster,
        target,
        calculated.Amount,
        creative_skill_id
    )
    if type(effective) ~= "number"
        or effective < 0
        or effective ~= effective
    then
        return nil, "InvalidC4LivePlayerHealResult"
    end

    return {
        Kind = "C4LiveTargetHealSkill",
        Calculation = calculated,
        Applied = true,
        RawHeal = calculated.Amount,
        EffectiveHeal = effective,
        SourceSkillId = calculated.SourceSkillId,
        SourceRank = calculated.SourceRank,
    }, nil
end

--[[
Executes one live source mana recharge on a friendly player target.

The source calculation owns the one magical shot and exact target
RECHARGE_MP_RATE. The existing ManaService owns clamping and current MP.

Args:
    caster (any): Server-owned recharge caster.
    target (any): Server-owned friendly target.
    creative_skill_id (string): Reviewed creative recharge skill.
    creative_rank (number): Server-resolved purchased rank.

Returns:
    (any?, string?): Live recharge evidence or strict denial reason.
]]
function C4SourceCombatExecutor:mana_recharge_skill_target(
    caster: any,
    target: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    local ready, ready_reason =
        self:can_support_skill_player(caster, target)
    if not ready then
        return nil, ready_reason
    end

    local calculated, combat_reason =
        self._combat.mana_recharge_skill(
            caster.UserId,
            target.UserId,
            creative_skill_id,
            creative_rank
        )
    if not calculated then
        return nil, combat_reason
    end

    if not self._mana
        or type(self._mana.restore) ~= "function"
    then
        return nil, "C4LiveManaAuthorityUnavailable"
    end

    local restored = self._mana.restore(
        target,
        calculated.Amount
    )
    if type(restored) ~= "number"
        or restored < 0
        or restored ~= restored
    then
        return nil, "InvalidC4LiveManaRechargeResult"
    end

    return {
        Kind = "C4LiveTargetManaRecharge",
        Calculation = calculated,
        Applied = true,
        RawRecharge = calculated.Amount,
        EffectiveRecharge = restored,
        SourceSkillId = calculated.SourceSkillId,
        SourceRank = calculated.SourceRank,
        TargetUserId = target.UserId,
    }, nil
end

--[[
Executes one live source support buff on a friendly player target.

The target active-effect registry receives only the server-resolved C4 source
identity. That lets existing unified source stats consume the exact modifiers
without requiring the target to own the caster's skill.

Args:
    caster (any): Server-owned buff caster.
    target (any): Server-owned friendly target.
    creative_skill_id (string): Reviewed creative support buff.
    creative_rank (number): Server-resolved purchased rank.

Returns:
    (any?, string?): Live timed-buff evidence or denial reason.
]]
function C4SourceCombatExecutor:support_buff_skill_target(
    caster: any,
    target: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    local ready, ready_reason =
        self:can_support_skill_player(caster, target)
    if not ready then
        return nil, ready_reason
    end

    local calculated, combat_reason =
        self._combat.support_buff_skill(
            caster.UserId,
            creative_skill_id,
            creative_rank
        )
    if not calculated then
        return nil, combat_reason
    end

    local authority = self._active_source_effects
    if not authority
        or type(
            authority.observe_external_timed
        ) ~= "function"
    then
        return nil, "C4LiveSupportBuffAuthorityUnavailable"
    end

    local observed, observe_reason =
        authority.observe_external_timed(
            target,
            creative_skill_id,
            creative_rank,
            calculated.SourceSkillId,
            calculated.SourceRank,
            calculated.DurationSeconds
        )
    if not observed then
        return nil, observe_reason
    end

    return {
        Kind = "C4LiveSupportBuff",
        Calculation = calculated,
        Applied = true,
        DurationSeconds = calculated.DurationSeconds,
        SourceSkillId = calculated.SourceSkillId,
        SourceRank = calculated.SourceRank,
        TargetUserId = target.UserId,
    }, nil
end

--[[
Checks whether a reviewed C4 party heal currently has an eligible target.

The server-owned party roster, life state, range and line-of-sight remain in
the existing PartyHealService. This preflight does not spend MP or consume a
magical shot.

Args:
    caster (any): Server-owned healing player.
    source_radius (number): Reviewed C4 party radius in source units.

Returns:
    (boolean, string?): Readiness or strict denial reason.
]]
function C4SourceCombatExecutor:can_party_heal_skill(
    caster: any,
    source_radius: number
): (boolean, string?)
    local ready, ready_reason = self:_validate_actor(caster)
    if not ready then
        return false, ready_reason
    end

    if type(source_radius) ~= "number"
        or source_radius ~= source_radius
        or source_radius <= 0
        or source_radius >= math.huge
    then
        return false, "InvalidC4SourcePartyHealRadius"
    end
    if type(self._source_units_per_stud) ~= "number"
        or self._source_units_per_stud <= 0
    then
        return false, "C4SourceCastRangeScaleUnconfigured"
    end

    local provider = self._party_heal
    if not provider
        or type(provider.has_injured_member) ~= "function"
    then
        return false, "C4LivePartyHealAuthorityUnavailable"
    end

    local radius_studs =
        source_radius / self._source_units_per_stud
    if not provider.has_injured_member(
        caster,
        radius_studs
    ) then
        return false, "C4LivePartyHealNoEligibleTargets"
    end

    return true, nil
end

--[[
Checks whether one dead friendly player is a legal resurrection target.

The live Dungeon death service owns party membership and dead-member state.
This preflight does not spend MP or consume a magical shot.

Args:
    caster (any): Living server-owned support caster.
    target (any): Dead server-owned party target.
    source_range (number): Reviewed C4 cast/effect range.

Returns:
    (boolean, string?): Readiness or strict denial reason.
]]
function C4SourceCombatExecutor:can_resurrection_skill_player(
    caster: any,
    target: any,
    source_range: number
): (boolean, string?)
    local ready, ready_reason = self:_validate_actor(caster)
    if not ready then
        return false, ready_reason
    end
    if not target
        or type(target.UserId) ~= "number"
        or target == caster
    then
        return false, "InvalidC4ResurrectionTarget"
    end

    local authority = self._player_resurrection
    if not authority then
        return false, "C4PlayerResurrectionAuthorityUnavailable"
    end

    local legal, legal_reason =
        authority:can_skill_resurrect(caster, target)
    if not legal then
        return false, legal_reason
    end

    return self:_validate_player_source_range(
        caster,
        target,
        source_range
    )
end

--[[
Executes one C4 Resurrection cast as a target-confirmed proposal.

The cast consumes the caster's magical shot and then asks the Dungeon death
authority to create a resurrection offer. It never silently revives a player.

Args:
    caster (any): Living server-owned support caster.
    target (any): Dead server-owned party target.
    creative_skill_id (string): Reviewed Resurrection skill.
    creative_rank (number): Server-resolved purchased rank.

Returns:
    (any?, string?): Proposal evidence or strict denial reason.
]]
function C4SourceCombatExecutor:resurrection_skill_player(
    caster: any,
    target: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    local authority = self._player_resurrection
    if not authority then
        return nil, "C4PlayerResurrectionAuthorityUnavailable"
    end

    local calculated, combat_reason =
        self._combat.resurrection_skill(
            caster.UserId,
            creative_skill_id,
            creative_rank
        )
    if not calculated then
        return nil, combat_reason
    end

    local result = authority:request_skill_resurrection(
        caster,
        target,
        calculated.RestoreExperiencePower
    )
    if type(result) ~= "table" or result.ok ~= true then
        return nil, if type(result) == "table"
            then result.reason
            else "C4PlayerResurrectionRequestFailed"
    end

    return {
        Kind = "C4LivePlayerResurrectionOffer",
        Calculation = calculated,
        Applied = true,
        OfferCreated = true,
        RequiresTargetAcceptance = true,
        RestoreExperiencePower =
            calculated.RestoreExperiencePower,
        TargetUserId = target.UserId,
        SourceSkillId = calculated.SourceSkillId,
        SourceRank = calculated.SourceRank,
    }, nil
end

--[[
Executes one live source TARGET_PARTY heal.

The source calculator consumes the caster's one magical shot and returns the
exact C4 radius. The existing server party-heal authority owns roster,
line-of-sight and actual health mutation.

Args:
    caster (any): Server-owned healing player.
    creative_skill_id (string): Reviewed party-heal skill.
    creative_rank (number): Server-resolved purchased rank.

Returns:
    (any?, string?): Live party-heal evidence or strict denial reason.
]]
function C4SourceCombatExecutor:party_heal_skill(
    caster: any,
    creative_skill_id: string,
    creative_rank: number
): (any?, string?)
    local ready, ready_reason = self:_validate_actor(caster)
    if not ready then
        return nil, ready_reason
    end

    local calculated, combat_reason =
        self._combat.party_heal_skill(
            caster.UserId,
            creative_skill_id,
            creative_rank
        )
    if not calculated then
        return nil, combat_reason
    end

    if type(self._source_units_per_stud) ~= "number"
        or self._source_units_per_stud <= 0
    then
        return nil, "C4SourceCastRangeScaleUnconfigured"
    end

    local provider = self._party_heal
    if not provider or type(provider.cast) ~= "function" then
        return nil, "C4LivePartyHealAuthorityUnavailable"
    end

    local radius_studs =
        calculated.SourceSkillRadius
        / self._source_units_per_stud
    local applied, affected, total =
        provider.cast(
            caster,
            calculated.Amount,
            radius_studs,
            creative_skill_id
        )
    if applied ~= true then
        return nil, "C4LivePartyHealNoEligibleTargets"
    end

    return {
        Kind = "C4LivePartyHeal",
        Calculation = calculated,
        Applied = true,
        AffectedPlayers = affected,
        EffectiveHeal = total,
        RadiusStuds = radius_studs,
        SourceSkillId = calculated.SourceSkillId,
        SourceRank = calculated.SourceRank,
    }, nil
end

--[[
Executes one live C4 Root control skill against an NPC.

A resisted cast changes no NPC runtime state. A landed cast delegates to the
root authority, which suppresses movement only and remains through damage.

Args:
    attacker (any): Server-owned casting player.
    enemy (Model): Current reviewed server NPC.
    creative_skill_id (string): Reviewed creative Root skill.
    creative_rank (number): Server-resolved purchased rank.
    sequence_id (number?): Existing authoritative cast sequence.

Returns:
    (any?, string?): Live Root evidence or strict denial reason.
]]
function C4SourceCombatExecutor:root_skill_npc(
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
        self._combat.root_skill(
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
            Kind = "C4LiveNpcRoot",
            Calculation = calculated,
            Applied = false,
            RootApplied = false,
            Landed = false,
            SequenceId = sequence_id,
        }, nil
    end

    local authority = self._npc_root
    if not authority or type(authority.apply) ~= "function" then
        return nil, "C4NpcRootAuthorityUnavailable"
    end

    local applied = authority.apply(
        enemy,
        calculated.DurationSeconds
    )
    if applied ~= true then
        return nil, "C4NpcRootApplicationFailed"
    end

    return {
        Kind = "C4LiveNpcRoot",
        Calculation = calculated,
        Applied = true,
        RootApplied = true,
        Landed = true,
        DurationSeconds = calculated.DurationSeconds,
        BreaksOnDamage = false,
        SequenceId = sequence_id,
    }, nil
end

--[[
Executes one reviewed C4 undead-only MDAM spell against an NPC.

Args:
    attacker (any): Server-owned casting player.
    enemy (Model): Current reviewed server NPC.
    creative_skill_id (string): Reviewed undead-only spell.
    creative_rank (number): Server-resolved purchased rank.
    sequence_id (number?): Existing authoritative sequence.

Returns:
    (any?, string?): Live magic damage evidence or strict denial reason.
]]
function C4SourceCombatExecutor:magic_undead_skill_npc(
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
    if boundary.SourceNpcRace ~= "UNDEAD" then
        return nil, "C4UndeadMagicTargetRequired"
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
        "Magic",
        creative_skill_id,
        sequence_id
    )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4LiveNpcUndeadMagic",
        Calculation = calculated,
        Applied = true,
        HealthDamage = applied.HealthDamage,
        RawDamage = applied.RawDamage,
        HealthBefore = applied.HealthBefore,
        HealthAfter = applied.HealthAfter,
        Lethal = applied.Lethal,
    }, nil
end

--[[
Executes one complete live player-vs-player C4 ordinary attack.

All transforms, elevation mapping, night state, calculation rolls,
shield state,
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
        TargetHealLiveApplication = true,
        PartyHealLiveApplication = true,
        PlayerResurrectionOfferLiveApplication = true,
        PlayerResurrectionRequiresTargetAcceptance = true,
        PlayerResurrectionAuthorityConfigured =
            self._player_resurrection ~= nil,
        SupportBuffLiveApplication = true,
        TargetHealLiveApplication = true,
        TargetManaRechargeLiveApplication = true,
        PlayerSupportBuffLiveApplication = true,
        ExternalTimedSourceEffectsIntegrated = true,
        SelfManaHealLiveApplication = true,
        ManaAuthorityConfigured = type(self._mana) == "table",
        NpcBoundaryProviderConfigured =
            type(self._npc_boundary_provider) == "function",
        NpcDamageObserverConfigured =
            type(self._npc_damage_observer) == "function",
        NpcNormalAttackLiveApplication = true,
        NpcPhysicalSkillLiveApplication = true,
        NpcMagicSkillLiveApplication = true,
        NpcMagicAreaLiveApplication = true,
        NpcMagicAreaCasterRadiusSourceSemantics = true,
        NpcMagicAreaSingleShotSnapshot = true,
        NpcMagicDrainLiveApplication = true,
        NpcMagicDrainUsesAppliedHealthDamage = true,
        NpcCorpseDrainLiveApplication = true,
        NpcCorpseDrainConsumesCorpse = true,
        NpcCorpseBoundaryProviderConfigured =
            type(self._npc_corpse_boundary_provider) == "function",
        NpcSleepLiveApplication = true,
        NpcSleepBreaksOnDirectDamage = true,
        NpcRootLiveApplication = true,
        NpcRootMovementOnly = true,
        NpcRootBreaksOnDamage = false,
        NpcUndeadMagicLiveApplication = true,
        NpcUndeadMagicReadOnlyPreflight = true,
        NpcSleepAuthorityConfigured =
            type(self._npc_sleep) == "table",
        NpcElementalVulnerabilityLiveApplication = true,
        NpcElementalVulnerabilityBoundaryDecoration = true,
        NpcElementalVulnerabilityAuthorityConfigured =
            type(self._npc_elemental_vulnerability) == "table",
        NpcPhysicalAttackWeakeningLiveApplication = true,
        NpcPhysicalAttackWeakeningUsesOutgoingDamageRules = true,
        NpcPhysicalAttackWeakeningLeavesAttackRateNeutral = true,
        NpcPhysicalAttackWeakeningAuthorityConfigured =
            type(self._enemy_weakening) == "table",
        NpcPhysicalAttackRateWeakeningLiveApplication = true,
        NpcPhysicalAttackRateWeakeningUsesOutgoingCadenceRules = true,
        NpcPhysicalAttackRateWeakeningLeavesPowerNeutral = true,
        NpcMagicMovementSlowLiveApplication = true,
        NpcMagicMovementSlowSharedNonStackingAuthority = true,
        NpcMagicSkillReadOnlyPreflight = true,
        NpcStatusSkillReadOnlyPreflight = true,
        NpcSourceRangePreflight = true,
        NpcPeriodicStatusLiveApplication = true,
        NpcPeriodicStatusAreaLiveApplication = true,
        NpcPeriodicStatusAreaSingleShotSnapshot = true,
        NpcPeriodicStatusNonlethal = true,
        NpcPeriodicStatusRefreshBySourceSkill = true,
        NpcDamageBypassesCombatPoints = true,
        NpcDamageCallbackPreservation = true,
    }
end

return C4SourceCombatExecutor
