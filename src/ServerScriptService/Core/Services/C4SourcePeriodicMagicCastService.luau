--!strict
-- Disabled-by-default scheduled Human Wizard periodic magic bridge.

local C4SourcePeriodicMagicCastService = {}
C4SourcePeriodicMagicCastService.__index =
    C4SourcePeriodicMagicCastService

local REVIEWED_PERIODIC_MAGIC = table.freeze({
    EmberweaverVenomHex = table.freeze({
        SourceSkillId = 1168,
        CastRange = 600,
        EffectRange = 1100,
    }),
})

--[[
Validates one server-owned cast owner.

Args:
    player (any): Player-like server authority object.

Returns:
    boolean: True when a numeric integral UserId is available.
]]
local function valid_owner(player: any): boolean
    if type(player) ~= "table"
        and typeof(player) ~= "Instance"
    then
        return false
    end

    return type(player.UserId) == "number"
        and player.UserId % 1 == 0
end

--[[
Returns reviewed periodic-magic metadata for one creative skill.

Args:
    creative_skill_id (string): Server-selected creative skill.

Returns:
    any?: Reviewed source identity, otherwise nil.
]]
local function reviewed_skill(
    creative_skill_id: string
): any?
    return REVIEWED_PERIODIC_MAGIC[creative_skill_id]
end

--[[
Stores one private target-bound periodic cast record.

Args:
    self (any): Periodic magic bridge instance.
    player (any): Server-owned cast owner.
    enemy (any): Reviewed NPC target.
    started (any): Source scheduler start evidence.

Returns:
    any: Private pending bridge record.
]]
local function store_pending(
    self: any,
    player: any,
    enemy: any,
    started: any
): any
    local record = {
        CastId = started.CastId,
        CreativeSkillId = started.CreativeSkillId,
        CreativeRank = started.CreativeRank,
        SourceSkillId = started.SourceSkillId,
        CastRange = started.SourceCastRange,
        EffectRange = started.SourceEffectRange,
        Enemy = enemy,
    }

    self._pending_by_owner[player] = record
    return record
end

--[[
Builds detached start evidence for one periodic magic cast.

Args:
    started (any): Source scheduler start evidence.

Returns:
    any: Target-bound source-only cast evidence.
]]
local function start_evidence(started: any): any
    return {
        CastId = started.CastId,
        CreativeSkillId = started.CreativeSkillId,
        CreativeRank = started.CreativeRank,
        SourceSkillId = started.SourceSkillId,
        SourceRank = started.SourceRank,
        StartedAt = started.StartedAt,
        InterruptAt = started.InterruptAt,
        LaunchAt = started.LaunchAt,
        FinalizerAt = started.FinalizerAt,
        ReuseReadyAt = started.ReuseReadyAt,
        SourceCastRange = started.SourceCastRange,
        SourceEffectRange = started.SourceEffectRange,
        TargetBoundServerSide = true,
        SourceOnly = true,
        StatusResolved = false,
        ShotStateConsumed = false,
    }
end

--[[
Builds one periodic-magic bridge from scheduler and live executor authorities.

Args:
    scheduler (any): Source cast scheduler authority.
    executor (any): Source combat executor authority.

Returns:
    any: Disabled server-owned periodic magic bridge.
]]
function C4SourcePeriodicMagicCastService.new(
    scheduler: any,
    executor: any
): any
    assert(
        scheduler
            and type(scheduler.begin_cast) == "function"
            and type(scheduler.cancel_cast) == "function"
            and type(scheduler.launch_if_ready) == "function"
            and type(scheduler.clear_owner) == "function",
        "Periodic magic bridge requires source cast scheduler"
    )
    assert(
        executor
            and type(executor.can_status_skill_npc) == "function"
            and type(executor.status_skill_npc) == "function",
        "Periodic magic bridge requires source combat executor"
    )

    return setmetatable({
        _enabled = false,
        _scheduler = scheduler,
        _executor = executor,
        _pending_by_owner = {},
    }, C4SourcePeriodicMagicCastService)
end

--[[
Changes only the periodic-magic bridge feature gate.

Args:
    enabled (boolean): Whether reviewed periodic casts may be requested.

Returns:
    nil: Updates only this server-local gate.
]]
function C4SourcePeriodicMagicCastService:set_enabled(
    enabled: boolean
)
    assert(
        type(enabled) == "boolean",
        "Periodic magic bridge gate must be boolean"
    )

    self._enabled = enabled
end

--[[
Reports whether the periodic-magic bridge is enabled.

Args:
    None.

Returns:
    boolean: Current bridge gate.
]]
function C4SourcePeriodicMagicCastService:is_enabled(): boolean
    return self._enabled
end

--[[
Begins one reviewed target-bound periodic magic cast.

The target is preflighted before scheduler/resource mutation. The reviewed
source skill ID must also match the scheduler's authenticated source mapping.

Args:
    player (any): Server-owned casting player.
    enemy (any): Current reviewed server NPC target.
    creative_skill_id (string): Reviewed periodic creative skill.
    supplied_now (number?): Optional deterministic scheduler timestamp.

Returns:
    (any?, string?): Start evidence or strict denial reason.
]]
function C4SourcePeriodicMagicCastService:begin_cast(
    player: any,
    enemy: any,
    creative_skill_id: string,
    supplied_now: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4PeriodicMagicCastDisabled"
    end
    if not valid_owner(player) then
        return nil, "C4PeriodicMagicCastOwnerInvalid"
    end

    local review = reviewed_skill(creative_skill_id)
    if not review then
        return nil, "C4PeriodicMagicSkillNotReviewed"
    end
    if self._pending_by_owner[player] then
        return nil, "C4PeriodicMagicCastAlreadyPending"
    end

    local target_ready, target_reason =
        self._executor:can_status_skill_npc(
            player,
            enemy,
            review.CastRange
        )
    if not target_ready then
        return nil, target_reason
    end

    local started, start_reason =
        self._scheduler:begin_cast(
            player,
            creative_skill_id,
            supplied_now
        )
    if not started then
        return nil, start_reason
    end
    if started.SourceSkillId ~= review.SourceSkillId
        or started.SourceCastRange ~= review.CastRange
        or started.SourceEffectRange ~= review.EffectRange
    then
        self._scheduler:cancel_cast(player, started.CastId)
        return nil, "C4PeriodicMagicReviewedSourceMismatch"
    end

    store_pending(self, player, enemy, started)
    return start_evidence(started), nil
end

--[[
Cancels one pending periodic magic cast.

Args:
    player (any): Server-owned cast owner.
    cast_id (number): Private bridge/scheduler receipt.

Returns:
    (boolean, string?): Cancellation result or receipt denial.
]]
function C4SourcePeriodicMagicCastService:cancel_cast(
    player: any,
    cast_id: number
): (boolean, string?)
    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return false, "C4PeriodicMagicCastReceiptInvalid"
    end

    self._pending_by_owner[player] = nil
    return self._scheduler:cancel_cast(player, cast_id)
end

--[[
Checks one pending periodic cast still has a valid bound NPC target.

Args:
    self (any): Periodic magic bridge instance.
    player (any): Server-owned cast owner.
    record (any): Private target-bound record.

Returns:
    (boolean, string?): Current target readiness or strict denial reason.
]]
local function revalidate_target(
    self: any,
    player: any,
    record: any
): (boolean, string?)
    return self._executor:can_status_skill_npc(
        player,
        record.Enemy,
        record.EffectRange
    )
end

--[[
Checks a scheduler launch still matches the captured periodic cast identity.

Args:
    record (any): Private target-bound cast record.
    launch (any): Source scheduler launch payload.

Returns:
    boolean: True only when skill/source identity is unchanged and ready.
]]
local function launch_plan_matches(
    record: any,
    launch: any
): boolean
    return launch.CreativeSkillId == record.CreativeSkillId
        and launch.CreativeRank == record.CreativeRank
        and launch.SourceSkillId == record.SourceSkillId
        and launch.SourceCastRange == record.CastRange
        and launch.SourceEffectRange == record.EffectRange
        and launch.ReadyForSourceEffectExecution == true
end

--[[
Launches one ready periodic magic cast into the source status executor.

The target is revalidated before launch-time MP. Magical shot consumption and
the final poison success roll remain owned by the existing source calculator.

Args:
    player (any): Server-owned casting player.
    cast_id (number): Private bridge/scheduler receipt.
    supplied_now (number?): Optional deterministic scheduler timestamp.
    sequence_id (number?): Existing trusted combat sequence.

Returns:
    (any?, string?): Periodic status resolution or strict denial reason.
]]
function C4SourcePeriodicMagicCastService:launch_if_ready(
    player: any,
    cast_id: number,
    supplied_now: number?,
    sequence_id: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4PeriodicMagicCastDisabled"
    end

    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return nil, "C4PeriodicMagicCastReceiptInvalid"
    end

    local target_ready, target_reason =
        revalidate_target(self, player, record)
    if not target_ready then
        self._pending_by_owner[player] = nil
        self._scheduler:cancel_cast(player, cast_id)
        return nil, target_reason
    end

    local launch, launch_reason =
        self._scheduler:launch_if_ready(
            player,
            cast_id,
            supplied_now
        )
    if not launch then
        return nil, launch_reason
    end

    self._pending_by_owner[player] = nil
    if not launch_plan_matches(record, launch) then
        return nil, "C4PeriodicMagicLaunchPlanChanged"
    end

    local resolved, resolve_reason =
        self._executor:status_skill_npc(
            player,
            record.Enemy,
            launch.CreativeSkillId,
            launch.CreativeRank,
            sequence_id
        )
    if not resolved then
        return nil, resolve_reason
    end

    return {
        Kind = "C4ScheduledPeriodicMagic",
        CastId = cast_id,
        CreativeSkillId = launch.CreativeSkillId,
        CreativeRank = launch.CreativeRank,
        SourceSkillId = launch.SourceSkillId,
        SourceRank = launch.SourceRank,
        Launch = launch,
        Resolution = resolved,
        StatusResolved = true,
        Landed = resolved.Landed == true,
        StatusApplied = resolved.StatusApplied == true,
        ShotConsumedBySourceCalculation = true,
        ClientAuthority = false,
    }, nil
end

--[[
Clears private periodic and scheduler state for a departing owner.

Args:
    player (any): Server-owned cast owner being removed.

Returns:
    nil: Clears only ephemeral server cast state.
]]
function C4SourcePeriodicMagicCastService:clear_owner(
    player: any
)
    self._pending_by_owner[player] = nil
    self._scheduler:clear_owner(player)
end

--[[
Returns detached pending periodic-cast state.

Args:
    player (any): Server-owned cast owner.

Returns:
    any: Current bridge receipt and skill identity.
]]
function C4SourcePeriodicMagicCastService:snapshot(
    player: any
): any
    local record = self._pending_by_owner[player]

    return {
        Pending = record ~= nil,
        CastId = if record then record.CastId else nil,
        CreativeSkillId = if record
            then record.CreativeSkillId else nil,
    }
end

--[[
Reports the narrow periodic-magic integration boundary.

Args:
    None.

Returns:
    any: Gate, target, shot and reviewed-family capability flags.
]]
function C4SourcePeriodicMagicCastService:capability(): any
    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = self._enabled,
        ReviewedPeriodicMagicOnly = true,
        ReviewedSkill = "EmberweaverVenomHex",
        ReviewedSourceSkillId = 1168,
        TargetBoundAtCastStart = true,
        SourceCastRangeAtStart = true,
        SourceEffectRangeAtLaunch = true,
        TargetRevalidatedBeforeLaunchMp = true,
        LaunchMpCommittedBeforeStatusResolution = true,
        ShotConsumptionDelegatedToSourceCalculation = true,
        ClientTargetAuthority = false,
        ClientStatusAuthority = false,
    }
end

return C4SourcePeriodicMagicCastService
