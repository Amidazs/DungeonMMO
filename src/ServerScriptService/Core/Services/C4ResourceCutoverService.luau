--!strict
-- Reversible, disabled-by-default live C4 HP/MP/CP authority.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared

local ResourceRegen = require(
    Shared.C4ResourceRegenSourceRules
)
local CombatPoints = require(
    ServerScriptService.Core.Services.C4CombatPointRuntime
)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)
local ManaService = require(
    ServerScriptService.Combat.ManaService
)

local C4ResourceCutoverService = {}

local REGEN_PERIOD_SECONDS = 3

local feature_enabled = false
local active_by_user_id: {[number]: any} = {}

--[[
Returns a bounded current/max resource ratio.

Args:
    current (number): Current authoritative resource amount.
    maximum (number): Current authoritative resource maximum.

Returns:
    number: Ratio from zero through one; one when no positive max exists.
]]
local function resource_fraction(
    current: number,
    maximum: number
): number
    if maximum <= 0 then
        return 1
    end

    return math.clamp(current / maximum, 0, 1)
end

--[[
Returns the living Humanoid currently owned by one player.

Args:
    player (Player): Authenticated server player.

Returns:
    Humanoid?: Current living humanoid, otherwise nil.
]]
local function living_humanoid(player: Player): Humanoid?
    local character = player.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if not humanoid or humanoid.Health <= 0 then
        return nil
    end

    return humanoid
end

--[[
Validates the authenticated source boundary required by live source mode.

Args:
    player (Player): Authenticated server player.

Returns:
    (any?, string?): Source-ready boundary or stable denial reason.
]]
local function source_boundary(
    player: Player
): (any?, string?)
    local boundary, reason =
        Runtime.get_c4_resource_migration_boundary(
            player.UserId
        )

    if not boundary then
        return nil, reason
    end

    local source = boundary.SourceStatCandidate

    if boundary.CutoverPrerequisitesReady ~= true
        or boundary.SourceStatCandidateReady ~= true
        or type(source) ~= "table"
    then
        return nil, "C4ResourceCutoverPrerequisitesIncomplete"
    end

    for _, stat_name in ipairs({
        "MAX_HP",
        "MAX_MP",
        "MAX_CP",
        "REG_HP_RATE",
        "REG_MP_RATE",
        "REG_CP_RATE",
    }) do
        local value = source[stat_name]

        if type(value) ~= "number"
            or value ~= value
            or value < 0
            or math.abs(value) >= math.huge
        then
            return nil, "InvalidC4ResourceSourceCandidate"
        end
    end

    if source.MAX_HP < 1 then
        return nil, "InvalidC4ResourceSourceCandidate"
    end

    return boundary, nil
end

--[[
Copies source maxima from a validated migration boundary into one record.

Args:
    record (any): Mutable active source-mode record.
    boundary (any): Validated migration boundary.

Returns:
    nil: Updates only authenticated source maxima and boundary reference.
]]
local function update_record_source(
    record: any,
    boundary: any
)
    local source = boundary.SourceStatCandidate

    record.Boundary = boundary
    record.MaxHealth = source.MAX_HP
    record.MaxMana = source.MAX_MP
    record.MaxCP = source.MAX_CP
end

--[[
Applies one health maximum while preserving a server-measured fraction.

Args:
    humanoid (Humanoid): Current authoritative resource owner.
    maximum (number): New authenticated health maximum.
    fraction (number): Prior server-measured current/max ratio.

Returns:
    nil: Updates MaxHealth and bounded Health together.
]]
local function apply_health_fraction(
    humanoid: Humanoid,
    maximum: number,
    fraction: number
)
    humanoid.MaxHealth = math.max(1, maximum)
    humanoid.Health = humanoid.MaxHealth
        * math.clamp(fraction, 0, 1)
end

--[[
Returns the current source-regeneration movement category.

DungeonMMO currently has no separate walk-mode toggle, so ordinary movement is
classified as C4 Running. Stationary and seated states remain distinct.

Args:
    humanoid (Humanoid): Current server-observed humanoid.

Returns:
    string: Sitting, Standing or Running C4 movement state.
]]
local function movement_state(humanoid: Humanoid): string
    if humanoid.Sit then
        return "Sitting"
    end

    if humanoid.MoveDirection.Magnitude > 0.1
        and humanoid.WalkSpeed > 0
    then
        return "Running"
    end

    return "Standing"
end

--[[
Refreshes source maxima/effects while preserving current resource fractions.

Args:
    player (Player): Active source-mode player.
    record (any): Mutable current cutover record.

Returns:
    (boolean, string?): Success or source/CP refresh failure reason.
]]
local function refresh_source_record(
    player: Player,
    record: any
): (boolean, string?)
    local humanoid = living_humanoid(player)

    if not humanoid then
        return false, "C4ResourceOwnerUnavailable"
    end

    local boundary, reason = source_boundary(player)

    if not boundary then
        return false, reason
    end

    local health_fraction = resource_fraction(
        humanoid.Health,
        humanoid.MaxHealth
    )
    local mana_fraction = resource_fraction(
        ManaService.get(player),
        ManaService.get_max(player)
    )
    local cp_snapshot = CombatPoints.snapshot(player)
    local cp_fraction = if cp_snapshot.Configured
        then resource_fraction(
            cp_snapshot.CurrentCP,
            cp_snapshot.MaxCP
        )
        else 1

    local cp_ok, cp_reason =
        CombatPoints.configure_fraction_from_boundary(
            player,
            boundary,
            cp_fraction
        )

    if not cp_ok then
        return false, cp_reason
    end

    update_record_source(record, boundary)
    record.Character = player.Character

    ManaService.refresh_player(player, true)
    apply_health_fraction(
        humanoid,
        record.MaxHealth,
        health_fraction
    )

    return true, nil
end

--[[
Returns the optional source-resource override for progression readers.

Args:
    user_id (number): Server-owned selected character owner.

Returns:
    any?: Active source maxima, or nil while source mode is off.
]]
local function resource_override(user_id: number): any?
    if not feature_enabled then
        return nil
    end

    local record = active_by_user_id[user_id]

    if not record then
        return nil
    end

    return {
        Active = true,
        MaxHealth = record.MaxHealth,
        MaxMana = record.MaxMana,
        MaxCP = record.MaxCP,
    }
end

--[[
Applies one original three-second HP/MP/CP regeneration tick.

Args:
    player (Player): Active source-mode player.
    record (any): Refreshed source-mode record.

Returns:
    (boolean, string?): Success or source movement/stat denial reason.
]]
local function apply_regen_tick(
    player: Player,
    record: any
): (boolean, string?)
    local humanoid = living_humanoid(player)

    if not humanoid then
        return false, "C4ResourceOwnerUnavailable"
    end

    local source = record.Boundary
        and record.Boundary.SourceStatCandidate
    local tick, reason = ResourceRegen.apply_movement(
        source,
        movement_state(humanoid)
    )

    if not tick then
        return false, reason
    end

    humanoid.Health = math.min(
        humanoid.MaxHealth,
        humanoid.Health + tick.HP
    )
    ManaService.restore(player, tick.MP)

    local _, cp_reason = CombatPoints.restore(
        player,
        tick.CP
    )
    if cp_reason then
        return false, cp_reason
    end

    return true, nil
end

--[[
Reports whether the server-wide cutover gate is explicitly enabled.

Args:
    None.

Returns:
    boolean: False by default in production bootstrap.
]]
function C4ResourceCutoverService.is_enabled(): boolean
    return feature_enabled
end

--[[
Reports whether one player currently uses C4 resource authority.

Args:
    player (Player): Authenticated server player.

Returns:
    boolean: True only for an active record while the global gate is on.
]]
function C4ResourceCutoverService.is_active(
    player: Player
): boolean
    return feature_enabled
        and active_by_user_id[player.UserId] ~= nil
end

--[[
Changes the server-wide source-resource gate.

Disabling performs an immediate rollback for every active owner. Enabling does
not opt any player in automatically; an explicit server enable_player call is
still required.

Args:
    enabled (boolean): New server-wide source-resource gate.

Returns:
    nil: Updates the gate and rolls active owners back when disabling.
]]
function C4ResourceCutoverService.set_enabled(
    enabled: boolean
)
    assert(
        type(enabled) == "boolean",
        "C4 resource cutover gate must be boolean"
    )

    if feature_enabled == enabled then
        return
    end

    if not enabled then
        local owners = {}

        for _, record in pairs(active_by_user_id) do
            if record.Player then
                table.insert(owners, record.Player)
            end
        end

        for _, player in ipairs(owners) do
            C4ResourceCutoverService.disable_player(player)
        end
    end

    feature_enabled = enabled
end

--[[
Enables authenticated source HP/MP/CP authority for one player.

The global gate must already have been explicitly enabled by server code.
Existing Health and Mana fractions are preserved; CP begins full when no prior
authoritative CP state exists.

Args:
    player (Player): Authenticated current server player.

Returns:
    (boolean, string?): Success or strict source/runtime denial reason.
]]
function C4ResourceCutoverService.enable_player(
    player: Player
): (boolean, string?)
    if not feature_enabled then
        return false, "C4ResourceCutoverDisabled"
    end

    if player.Parent ~= Players then
        return false, "C4ResourceOwnerUnavailable"
    end

    local humanoid = living_humanoid(player)

    if not humanoid then
        return false, "C4ResourceOwnerUnavailable"
    end

    local existing = active_by_user_id[player.UserId]

    if existing then
        return refresh_source_record(player, existing)
    end

    local boundary, reason = source_boundary(player)

    if not boundary then
        return false, reason
    end

    if ManaService.get_max(player) <= 0 then
        ManaService.initialize_player(player)
    end

    local health_fraction = resource_fraction(
        humanoid.Health,
        humanoid.MaxHealth
    )
    local mana_fraction = resource_fraction(
        ManaService.get(player),
        ManaService.get_max(player)
    )

    local cp_snapshot = CombatPoints.snapshot(player)
    local cp_fraction = if cp_snapshot.Configured
        then resource_fraction(
            cp_snapshot.CurrentCP,
            cp_snapshot.MaxCP
        )
        else 1

    local cp_ok, cp_reason =
        CombatPoints.configure_fraction_from_boundary(
            player,
            boundary,
            cp_fraction
        )

    if not cp_ok then
        return false, cp_reason
    end

    local record = {
        Player = player,
        Character = player.Character,
        Boundary = boundary,
        MaxHealth = 0,
        MaxMana = 0,
        MaxCP = 0,
        RegenElapsed = 0,
    }
    update_record_source(record, boundary)
    active_by_user_id[player.UserId] = record

    ManaService.refresh_player(player, true)
    apply_health_fraction(
        humanoid,
        record.MaxHealth,
        health_fraction
    )
    -- refresh_player preserves using the pre-cutover MP ratio. The local
    -- value is retained here as an explicit guard against future changes to
    -- ManaService's transition semantics.
    local actual_mana_fraction = resource_fraction(
        ManaService.get(player),
        ManaService.get_max(player)
    )
    if math.abs(actual_mana_fraction - mana_fraction) > 0.001 then
        active_by_user_id[player.UserId] = nil
        CombatPoints.clear(player)
        ManaService.refresh_player(player, true)
        return false, "C4ManaFractionTransitionFailed"
    end

    player:SetAttribute("C4ResourceCutoverActive", true)
    return true, nil
end

--[[
Disables source resource authority and rolls Health/Mana back by fraction.

CP has no pre-cutover DungeonMMO counterpart, so its server record is cleared.

Args:
    player (Player): Current or recently active source-mode player.

Returns:
    boolean: True when an active source-mode record was rolled back.
]]
function C4ResourceCutoverService.disable_player(
    player: Player
): boolean
    local record = active_by_user_id[player.UserId]

    if not record then
        player:SetAttribute("C4ResourceCutoverActive", false)
        CombatPoints.clear(player)
        return false
    end

    local humanoid = living_humanoid(player)
    local health_fraction = if humanoid
        then resource_fraction(
            humanoid.Health,
            humanoid.MaxHealth
        )
        else 1
    local mana_fraction = resource_fraction(
        ManaService.get(player),
        ManaService.get_max(player)
    )

    active_by_user_id[player.UserId] = nil
    CombatPoints.clear(player)

    if ManaService.get_max(player) > 0 then
        ManaService.refresh_player(player, true)
    end

    if humanoid then
        local custom_max = Runtime.get_max_health(
            player.UserId
        )
        apply_health_fraction(
            humanoid,
            custom_max,
            health_fraction
        )
    end

    if ManaService.get_max(player) > 0 then
        local restored_fraction = resource_fraction(
            ManaService.get(player),
            ManaService.get_max(player)
        )
        if math.abs(restored_fraction - mana_fraction) > 0.001 then
            ManaService.refresh_player(player, true)
        end
    end

    player:SetAttribute("C4ResourceCutoverActive", false)
    return true
end

--[[
Reapplies an already-active source mode after character respawn.

CombatService calls this only after it has reset ordinary Health/Mana
lifecycle state. Source mode remains opt-in and does nothing for inactive
players.

Args:
    player (Player): Respawned authenticated player.

Returns:
    (boolean, string?): Success, inactive state, or strict source denial reason.
]]
function C4ResourceCutoverService.on_character_added(
    player: Player
): (boolean, string?)
    local record = active_by_user_id[player.UserId]

    if not feature_enabled or not record then
        CombatPoints.clear(player)
        return false, "C4ResourceCutoverInactive"
    end

    local humanoid = living_humanoid(player)

    if not humanoid then
        return false, "C4ResourceOwnerUnavailable"
    end

    local boundary, reason = source_boundary(player)

    if not boundary then
        C4ResourceCutoverService.disable_player(player)
        return false, reason
    end

    local cp_ok, cp_reason = CombatPoints.configure_from_boundary(
        player,
        boundary,
        true
    )

    if not cp_ok then
        C4ResourceCutoverService.disable_player(player)
        return false, cp_reason
    end

    update_record_source(record, boundary)
    record.Character = player.Character
    record.RegenElapsed = 0

    ManaService.refresh_player(player, false)
    humanoid.MaxHealth = math.max(1, record.MaxHealth)
    humanoid.Health = humanoid.MaxHealth
    player:SetAttribute("C4ResourceCutoverActive", true)

    return true, nil
end

--[[
Removes source-mode state for a player leaving the server.

Args:
    player (Player): Departing authenticated player.

Returns:
    nil: Clears private cutover and CP state without unnecessary rollback.
]]
function C4ResourceCutoverService.remove_player(
    player: Player
)
    active_by_user_id[player.UserId] = nil
    CombatPoints.clear(player)
end

--[[
Routes one already-mitigated player hit through source CP when mode is active.

Args:
    defender (Player): Player whose HP would receive the remaining hit.
    damage (number): Already validated non-negative incoming damage.
    attacker_is_playable (boolean): Server-known player/playable attacker flag.

Returns:
    (number, number): Remaining HP damage and CP absorbed.
]]
function C4ResourceCutoverService.resolve_player_damage(
    defender: Player,
    damage: number,
    attacker_is_playable: boolean
): (number, number)
    if not C4ResourceCutoverService.is_active(defender) then
        return damage, 0
    end

    local resolved = CombatPoints.resolve_damage(
        defender,
        damage,
        attacker_is_playable
    )

    if not resolved then
        return damage, 0
    end

    return resolved.HealthDamage, resolved.CPAbsorbed
end

--[[
Returns a detached server resource-cutover snapshot for tests/diagnostics.

Args:
    player (Player): Authenticated current player.

Returns:
    any: Gate, active state, source maxima and CP snapshot.
]]
function C4ResourceCutoverService.snapshot(
    player: Player
): any
    local record = active_by_user_id[player.UserId]

    return {
        GateEnabled = feature_enabled,
        Active = feature_enabled and record ~= nil,
        MaxHealth = if record then record.MaxHealth else nil,
        MaxMana = if record then record.MaxMana else nil,
        MaxCP = if record then record.MaxCP else nil,
        CombatPoints = CombatPoints.snapshot(player),
    }
end

--[[
Returns immutable cutover capability metadata.

Args:
    None.

Returns:
    any: Disabled-by-default authority guarantees for migration acceptance.
]]
function C4ResourceCutoverService.capability(): any
    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = feature_enabled,
        ExplicitPerPlayerEnable = true,
        FractionPreservingTransitions = true,
        SourceThreeSecondRegen = true,
        PlayableDamageUsesCP = true,
        NpcDamageBypassesCP = true,
        RespawnReapplySupported = true,
        RollbackSupported = true,
    }
end

Runtime.set_c4_resource_override_provider(resource_override)

RunService.Heartbeat:Connect(function(delta_time: number)
    if not feature_enabled then
        return
    end

    for user_id, record in pairs(active_by_user_id) do
        local player = record.Player

        if not player
            or player.Parent ~= Players
            or player.UserId ~= user_id
        then
            active_by_user_id[user_id] = nil
            continue
        end

        record.RegenElapsed += math.clamp(delta_time, 0, 1)

        while record.RegenElapsed >= REGEN_PERIOD_SECONDS do
            record.RegenElapsed -= REGEN_PERIOD_SECONDS

            local refreshed = refresh_source_record(
                player,
                record
            )

            if not refreshed then
                C4ResourceCutoverService.disable_player(player)
                break
            end

            local regenerated = apply_regen_tick(
                player,
                record
            )

            if not regenerated then
                C4ResourceCutoverService.disable_player(player)
                break
            end
        end
    end
end)

return table.freeze(C4ResourceCutoverService)
