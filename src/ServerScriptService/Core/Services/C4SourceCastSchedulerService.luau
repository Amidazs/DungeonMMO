--!strict
-- Private source-only scheduler for authenticated C4 magic casts.

local C4SourceCastSchedulerService = {}
C4SourceCastSchedulerService.__index = C4SourceCastSchedulerService

--[[
Returns one deterministic server timestamp.

Args:
    supplied_now (number?): Optional test-controlled process time.

Returns:
    number: Finite nonnegative process timestamp.

Raises:
    error: When a supplied timestamp is invalid.
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
        "Source cast scheduler time must be finite and nonnegative"
    )
    return now
end

--[[
Checks one timing plan has a final source reuse value.

Args:
    timing (any): Authenticated source cast timing plan.

Returns:
    (number?, string?): Final reuse milliseconds or strict denial reason.
]]
local function final_reuse_ms(timing: any): (number?, string?)
    if timing.FinalReuseDelayReady ~= true
        or type(timing.FinalReuseDelayMs) ~= "number"
        or timing.FinalReuseDelayMs < 0
        or timing.FinalReuseDelayMs >= math.huge
    then
        return nil, timing.ReuseBlocker
            or "C4SourceCastFinalReuseUnavailable"
    end

    return timing.FinalReuseDelayMs, nil
end

--[[
Checks the resource-start receipt matches the captured timing identity.

Args:
    timing (any): Source timing plan captured before initial MP spend.
    started (any): Source resource receipt returned after initial MP spend.

Returns:
    boolean: True only when creative/source identity and ranks match.
]]
local function same_cast_identity(
    timing: any,
    started: any
): boolean
    return started.CreativeSkillId == timing.CreativeSkillId
        and started.CreativeRank == timing.CreativeRank
        and started.SourceSkillId == timing.SourceSkillId
        and started.SourceRank == timing.SourceRank
end

--[[
Creates detached scheduler evidence from one private pending record.

Args:
    record (any): Private scheduler record.

Returns:
    any: Read-only-style start evidence for tests/future server callers.
]]
local function begin_evidence(record: any): any
    return {
        CastId = record.CastId,
        CreativeSkillId = record.CreativeSkillId,
        CreativeRank = record.CreativeRank,
        SourceSkillId = record.SourceSkillId,
        SourceRank = record.SourceRank,
        StartedAt = record.StartedAt,
        InterruptAt = record.InterruptAt,
        LaunchAt = record.LaunchAt,
        FinalizerAt = record.FinalizerAt,
        ReuseReadyAt = record.ReuseReadyAt,
        FinalHitTimeMs = record.FinalHitTimeMs,
        FinalCoolTimeMs = record.FinalCoolTimeMs,
        FinalReuseDelayMs = record.FinalReuseDelayMs,
        SourceOnly = true,
        LiveDamageIntegrated = false,
        ShotStateConsumed = false,
    }
end

--[[
Builds a private scheduler around already-reviewed source timing/resources.

Args:
    resource_service (any): Split-MP source cast lifecycle.
    timing_service (any): Source cast timing/reuse planner.

Returns:
    any: Isolated server-owned scheduler.
]]
function C4SourceCastSchedulerService.new(
    resource_service: any,
    timing_service: any
): any
    assert(
        resource_service
            and type(resource_service.begin_cast) == "function"
            and type(resource_service.cancel_cast) == "function"
            and type(resource_service.commit_cast) == "function"
            and type(resource_service.clear_owner) == "function",
        "Source cast scheduler requires resource lifecycle authority"
    )
    assert(
        timing_service
            and type(timing_service.resolve) == "function",
        "Source cast scheduler requires timing authority"
    )

    return setmetatable({
        _resources = resource_service,
        _timing = timing_service,
        _pending_by_owner = {},
        _reuse_by_owner = {},
    }, C4SourceCastSchedulerService)
end

--[[
Returns one owner's private source reuse deadline for a creative skill.

Args:
    self (any): Scheduler instance.
    player (any): Server-owned cast owner.
    creative_skill_id (string): Creative skill key.

Returns:
    number: Absolute ready time, or zero when no reuse gate exists.
]]
function C4SourceCastSchedulerService:_reuse_ready_at(
    player: any,
    creative_skill_id: string
): number
    local by_skill = self._reuse_by_owner[player]
    if not by_skill then
        return 0
    end

    return by_skill[creative_skill_id] or 0
end

--[[
Stores one source reuse deadline at cast start.

Args:
    self (any): Scheduler instance.
    player (any): Server-owned cast owner.
    creative_skill_id (string): Creative skill key.
    ready_at (number): Absolute source reuse deadline.

Returns:
    nil: Updates only private server reuse state.
]]
function C4SourceCastSchedulerService:_set_reuse_ready_at(
    player: any,
    creative_skill_id: string,
    ready_at: number
)
    local by_skill = self._reuse_by_owner[player]
    if not by_skill then
        by_skill = {}
        self._reuse_by_owner[player] = by_skill
    end

    by_skill[creative_skill_id] = ready_at
end

--[[
Creates one private pending scheduler record from reviewed source plans.

Args:
    timing (any): Exact source timing plan.
    started (any): Exact source resource-start receipt.
    now (number): Server cast-start time.
    reuse_ms (number): Exact final source reuse milliseconds.

Returns:
    any: Private pending scheduler record.
]]
local function pending_record(
    timing: any,
    started: any,
    now: number,
    reuse_ms: number
): any
    local hit_seconds = timing.FinalHitTimeMs / 1000
    local interrupt_seconds = timing.CastInterruptTimeMs / 1000
    local cool_seconds = (timing.FinalCoolTimeMs or 0) / 1000

    return {
        CastId = started.CastId,
        CreativeSkillId = timing.CreativeSkillId,
        CreativeRank = timing.CreativeRank,
        SourceSkillId = timing.SourceSkillId,
        SourceRank = timing.SourceRank,
        StartedAt = now,
        InterruptAt = now + interrupt_seconds,
        LaunchAt = now + hit_seconds,
        FinalizerAt = now + hit_seconds + cool_seconds,
        ReuseReadyAt = now + reuse_ms / 1000,
        FinalHitTimeMs = timing.FinalHitTimeMs,
        FinalCoolTimeMs = timing.FinalCoolTimeMs,
        FinalReuseDelayMs = reuse_ms,
    }
end

--[[
Begins one source cast and captures immutable timing/reuse deadlines.

Timing must be fully source-ready before initial MP is spent. Source reuse
starts at cast start and survives later cancellation, matching the reviewed
C4 lifecycle.

Args:
    player (any): Server-owned cast owner with numeric UserId.
    creative_skill_id (string): Server-selected owned creative skill.
    supplied_now (number?): Optional deterministic process timestamp.

Returns:
    (any?, string?): Start evidence or strict denial reason.
]]
function C4SourceCastSchedulerService:begin_cast(
    player: any,
    creative_skill_id: string,
    supplied_now: number?
): (any?, string?)
    if type(player) ~= "table"
        and typeof(player) ~= "Instance"
    then
        return nil, "C4SourceCastOwnerInvalid"
    end
    if type(player.UserId) ~= "number" then
        return nil, "C4SourceCastOwnerInvalid"
    end
    if self._pending_by_owner[player] then
        return nil, "C4SourceCastAlreadyScheduled"
    end

    local now = resolve_now(supplied_now)
    if self:_reuse_ready_at(player, creative_skill_id) > now then
        return nil, "C4SourceCastReusePending"
    end

    local timing, timing_reason = self._timing:resolve(
        player.UserId,
        creative_skill_id
    )
    if not timing then
        return nil, timing_reason
    end

    local reuse_ms, reuse_reason = final_reuse_ms(timing)
    if reuse_ms == nil then
        return nil, reuse_reason
    end

    local started, start_reason = self._resources:begin_cast(
        player,
        creative_skill_id
    )
    if not started then
        return nil, start_reason
    end

    if not same_cast_identity(timing, started) then
        self._resources:cancel_cast(player, started.CastId)
        return nil, "C4SourceCastPlanChanged"
    end

    local record = pending_record(timing, started, now, reuse_ms)
    self._pending_by_owner[player] = record
    self:_set_reuse_ready_at(
        player,
        creative_skill_id,
        record.ReuseReadyAt
    )

    return begin_evidence(record), nil
end

--[[
Cancels one pending source cast without clearing its reuse deadline.

Args:
    player (any): Server-owned cast owner.
    cast_id (number): Private scheduler/resource receipt.

Returns:
    (boolean, string?): Cancellation result or strict receipt denial.
]]
function C4SourceCastSchedulerService:cancel_cast(
    player: any,
    cast_id: number
): (boolean, string?)
    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return false, "C4SourceCastReceiptInvalid"
    end

    self._pending_by_owner[player] = nil
    return self._resources:cancel_cast(player, cast_id)
end

--[[
Commits a pending cast only after its exact source hit deadline.

The scheduler clears its pending receipt before resource commit, so a failed
authority revalidation cannot be replayed. The source reuse gate remains active
because C4 starts reuse at cast start.

Args:
    player (any): Server-owned cast owner.
    cast_id (number): Private scheduler/resource receipt.
    supplied_now (number?): Optional deterministic process timestamp.

Returns:
    (any?, string?): Launch payload or strict not-ready/authority denial.
]]
function C4SourceCastSchedulerService:launch_if_ready(
    player: any,
    cast_id: number,
    supplied_now: number?
): (any?, string?)
    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return nil, "C4SourceCastReceiptInvalid"
    end

    local now = resolve_now(supplied_now)
    if now < record.LaunchAt then
        return nil, "C4SourceCastNotReady"
    end

    self._pending_by_owner[player] = nil
    local committed, commit_reason =
        self._resources:commit_cast(player, cast_id)
    if not committed then
        return nil, commit_reason
    end

    return table.freeze({
        CastId = record.CastId,
        CreativeSkillId = record.CreativeSkillId,
        CreativeRank = record.CreativeRank,
        SourceSkillId = record.SourceSkillId,
        SourceRank = record.SourceRank,
        StartedAt = record.StartedAt,
        LaunchAt = record.LaunchAt,
        FinalizerAt = record.FinalizerAt,
        ReuseReadyAt = record.ReuseReadyAt,
        LaunchCommittedAt = now,
        InitialMpSpent = committed.InitialMpSpent,
        LaunchMpSpent = committed.LaunchMpSpent,
        SourceOnly = true,
        ReadyForSourceEffectExecution = true,
        LiveDamageIntegrated = false,
        ShotStateConsumed = false,
    }), nil
end

--[[
Returns remaining private source reuse for one creative skill.

Args:
    player (any): Server-owned cast owner.
    creative_skill_id (string): Creative skill key.
    supplied_now (number?): Optional deterministic process timestamp.

Returns:
    number: Remaining source reuse in seconds, clamped to zero.
]]
function C4SourceCastSchedulerService:get_reuse_remaining(
    player: any,
    creative_skill_id: string,
    supplied_now: number?
): number
    local remaining = self:_reuse_ready_at(
        player,
        creative_skill_id
    ) - resolve_now(supplied_now)

    return math.max(0, remaining)
end

--[[
Returns detached pending scheduler state for tests/diagnostics.

Args:
    player (any): Server-owned cast owner.

Returns:
    any: Current private pending state summary.
]]
function C4SourceCastSchedulerService:snapshot(player: any): any
    local record = self._pending_by_owner[player]

    return {
        Pending = record ~= nil,
        CastId = if record then record.CastId else nil,
        CreativeSkillId = if record
            then record.CreativeSkillId else nil,
        LaunchAt = if record then record.LaunchAt else nil,
        ReuseReadyAt = if record
            then record.ReuseReadyAt else nil,
    }
end

--[[
Clears all ephemeral scheduler/resource state for a departing owner.

Args:
    player (any): Server-owned cast owner being removed.

Returns:
    nil: Clears pending cast and reuse records.
]]
function C4SourceCastSchedulerService:clear_owner(player: any)
    self._pending_by_owner[player] = nil
    self._reuse_by_owner[player] = nil
    self._resources:clear_owner(player)
end

--[[
Reports the deliberately source-only scheduler boundary.

Args:
    None.

Returns:
    any: Capability flags for staged source combat integration.
]]
function C4SourceCastSchedulerService.capability(): any
    return {
        Available = true,
        ServerOwnedDeadlines = true,
        ReuseStartsAtCastStart = true,
        EarlyLaunchRejected = true,
        CancellationKeepsReuse = true,
        ReplayRejected = true,
        SplitManaCommitAtLaunch = true,
        ReadyForSourceEffectExecution = true,
        ShotConsumptionIntegrated = false,
        LiveDamageIntegrated = false,
        ClientAuthority = false,
    }
end

return table.freeze(C4SourceCastSchedulerService)
