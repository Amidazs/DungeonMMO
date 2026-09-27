--!strict
-- Server-owned Chronicle 4 cast interruption after trusted player damage.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local Formula = require(
    ReplicatedStorage.Core.Shared.C4CombatFormulaReference
)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local C4SourceCastInterruptionService = {}
C4SourceCastInterruptionService.__index =
    C4SourceCastInterruptionService

--[[
Returns the current authenticated source-stat migration boundary.

Args:
    user_id (number): Server-owned cast owner.

Returns:
    (any?, string?): Current source boundary or strict denial reason.
]]
local function default_boundary_provider(
    user_id: number
): (any?, string?)
    return Runtime.get_c4_resource_migration_boundary(user_id)
end

--[[
Checks one finite positive damage value.

Args:
    value (any): Candidate damage reaching player resources.

Returns:
    boolean: True only for a finite positive number.
]]
local function positive_damage(value: any): boolean
    return type(value) == "number"
        and value == value
        and value > 0
        and value < math.huge
end

--[[
Checks one finite signed numeric source modifier.

Args:
    value (any): Candidate ATTACK_CANCEL_RATE offset.

Returns:
    boolean: True only for a finite number.
]]
local function finite_number(value: any): boolean
    return type(value) == "number"
        and value == value
        and math.abs(value) < math.huge
end

--[[
Resolves an optional deterministic process timestamp.

Args:
    supplied_now (number?): Test-supplied clock value.

Returns:
    number: Finite process timestamp.
]]
local function resolve_now(supplied_now: number?): number
    local now = supplied_now
    if now == nil then
        now = os.clock()
    end

    assert(
        type(now) == "number"
            and now == now
            and now >= 0
            and now < math.huge,
        "Source cast interruption time must be finite"
    )
    return now
end

--[[
Builds the source interruption service around one cast scheduler.

Args:
    scheduler (any): Server-owned source cast scheduler.
    boundary_provider (any?): Optional deterministic source-stat provider.

Returns:
    any: Source cast interruption service.
]]
function C4SourceCastInterruptionService.new(
    scheduler: any,
    boundary_provider: any?,
    cancel_provider: any?
): any
    assert(
        scheduler
            and type(scheduler.snapshot) == "function"
            and type(scheduler.cancel_cast) == "function",
        "Source cast interruption requires scheduler authority"
    )
    assert(
        boundary_provider == nil
            or type(boundary_provider) == "function",
        "Source cast interruption boundary provider must be a function"
    )
    assert(
        cancel_provider == nil
            or type(cancel_provider) == "function",
        "Source cast interruption cancel provider must be a function"
    )

    return setmetatable({
        _scheduler = scheduler,
        _boundary_provider =
            boundary_provider or default_boundary_provider,
        _cancel_provider = cancel_provider,
        _random = Random.new(),
        _test_roll_provider = nil,
    }, C4SourceCastInterruptionService)
end

--[[
Installs a deterministic roll provider for unpublished Studio rehearsals.

Production servers reject this hook. The provider is server-local and cannot
be reached by a RemoteEvent or client payload.

Args:
    provider (any?): Zero-argument integer-roll provider, or nil to clear.

Returns:
    nil: Updates only this interruption service instance.
]]
function C4SourceCastInterruptionService:set_roll_provider_for_test(
    provider: any?
)
    assert(
        RunService:IsStudio(),
        "C4 cast interruption test rolls are Studio-only"
    )
    assert(
        provider == nil or type(provider) == "function",
        "C4 cast interruption test roll provider must be a function or nil"
    )
    self._test_roll_provider = provider
end

--[[
Returns one detached non-interruption result.

Args:
    reason (string): Stable explanation for skipping the roll.
    snapshot (any?): Current scheduler snapshot when available.

Returns:
    any: Non-mutating interruption evidence.
]]
local function skipped(reason: string, snapshot: any?): any
    return {
        Evaluated = false,
        Interrupted = false,
        Reason = reason,
        CastId = if snapshot then snapshot.CastId else nil,
        CreativeSkillId =
            if snapshot then snapshot.CreativeSkillId else nil,
    }
end

--[[
Evaluates one trusted damage event against a pending source cast.

Only damage arriving before the source interrupt deadline can roll. MEN and
ATTACK_CANCEL_RATE come from the authenticated combined source-stat boundary,
so Concentration and later reviewed active effects cannot be client-forged.

Args:
    player (any): Server-owned damaged player.
    damage (number): Positive damage reaching HP/CP resources.
    supplied_roll (number?): Optional deterministic integer roll 0..99.
    supplied_now (number?): Optional deterministic process timestamp.

Returns:
    (any?, string?): Interruption evidence or invalid-input reason.
]]
function C4SourceCastInterruptionService:try_damage_interrupt(
    player: any,
    damage: number,
    supplied_roll: number?,
    supplied_now: number?
): (any?, string?)
    if not player
        or type(player.UserId) ~= "number"
        or player.UserId % 1 ~= 0
    then
        return nil, "InvalidC4SourceCastInterruptOwner"
    end

    if not positive_damage(damage) then
        return skipped("NoPositivePlayerDamage", nil), nil
    end

    local snapshot = self._scheduler:snapshot(player)
    if type(snapshot) ~= "table" or snapshot.Pending ~= true then
        return skipped("NoPendingC4SourceCast", snapshot), nil
    end

    local now = resolve_now(supplied_now)
    if not finite_number(snapshot.InterruptAt)
        or now >= snapshot.InterruptAt
    then
        return skipped(
            "C4SourceCastInterruptWindowClosed",
            snapshot
        ), nil
    end

    local boundary, boundary_reason =
        self._boundary_provider(player.UserId)
    local stats = boundary and boundary.SourceStatCandidate
    local men_bonus = boundary and boundary.SourceMenBonus
    local rate_offset = type(stats) == "table"
        and stats.ATTACK_CANCEL_RATE or nil

    if not boundary
        or boundary.SourceStatCandidateReady ~= true
        or boundary.SourceStatCandidateIncludesActiveEffects ~= true
        or not positive_damage(men_bonus)
        or not finite_number(rate_offset)
    then
        return skipped(
            boundary_reason
                or "C4SourceCastInterruptStatsUnavailable",
            snapshot
        ), nil
    end

    local roll = supplied_roll
    if roll == nil and self._test_roll_provider then
        roll = self._test_roll_provider()
    end
    if roll == nil then
        roll = self._random:NextInteger(0, 99)
    end

    local resolved = Formula.resolve_attack_cancel(
        damage,
        men_bonus,
        rate_offset,
        roll
    )

    if resolved.Interrupted then
        local cancelled
        local cancel_reason

        if self._cancel_provider then
            cancelled, cancel_reason =
                self._cancel_provider(
                    player,
                    snapshot.CastId
                )
        else
            cancelled, cancel_reason =
                self._scheduler:cancel_cast(
                    player,
                    snapshot.CastId
                )
        end

        if not cancelled then
            return nil, cancel_reason
                or "C4SourceCastInterruptCancellationFailed"
        end
    end

    return {
        Evaluated = true,
        Interrupted = resolved.Interrupted,
        Reason = nil,
        CastId = snapshot.CastId,
        CreativeSkillId = snapshot.CreativeSkillId,
        SourceSkillId = snapshot.SourceSkillId,
        SourceRank = snapshot.SourceRank,
        Damage = damage,
        MenBonus = men_bonus,
        AttackCancelRateOffset = rate_offset,
        RatePercent = resolved.RatePercent,
        Roll = resolved.Roll,
        InterruptAt = snapshot.InterruptAt,
        EvaluatedAt = now,
        ServerOwned = true,
    }, nil
end

--[[
Reports the interruption authority guarantees.

Args:
    None.

Returns:
    any: Detached capability metadata.
]]
function C4SourceCastInterruptionService:capability(): any
    return {
        Available = true,
        PendingSourceCastsOnly = true,
        SourceInterruptWindow = true,
        DamageScaledChance = true,
        SourceMenIntegrated = true,
        AttackCancelRateIntegrated = true,
        ServerOwnedRoll = true,
        SchedulerCancellationIntegrated = true,
        ClientAuthority = false,
    }
end

return C4SourceCastInterruptionService
