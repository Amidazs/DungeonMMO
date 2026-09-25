--!strict
-- Human Wizard scheduled periodic-magic bridge regression.

local ServerScriptService = game:GetService("ServerScriptService")

local PeriodicMagic = require(
    ServerScriptService.Core.Services.C4SourcePeriodicMagicCastService
)

local USER_ID = 938196
local player = {
    UserId = USER_ID,
}
local enemy = {
    Name = "TEMP_SourcePeriodicMagicEnemy",
}
local checks = 0

local scheduler_state = {
    BeginCalls = 0,
    CancelCalls = 0,
    LaunchCalls = 0,
    ClearCalls = 0,
    NextCastId = 80,
    PendingCastId = nil,
    LaunchReason = nil,
    SourceSkillOverride = nil,
    LaunchRankOverride = nil,
}

local executor_state = {
    PreflightCalls = 0,
    StatusCalls = 0,
    TargetReady = true,
    TargetReason = nil,
    Landed = true,
    LastSequence = nil,
    LastRange = nil,
}

local FakeScheduler = {}

--[[
Begins one disposable Venom Hex source schedule.

Args:
    subject (any): Expected cast owner.
    creative_skill_id (string): Expected Venom Hex creative skill.
    supplied_now (number?): Deterministic scheduler timestamp.

Returns:
    (any?, string?): Source scheduler start evidence or denial reason.
]]
function FakeScheduler:begin_cast(
    subject: any,
    creative_skill_id: string,
    supplied_now: number?
): (any?, string?)
    scheduler_state.BeginCalls += 1

    if subject ~= player
        or creative_skill_id ~= "EmberweaverVenomHex"
    then
        return nil, "C4SourceCastOwnerInvalid"
    end

    scheduler_state.NextCastId += 1
    scheduler_state.PendingCastId =
        scheduler_state.NextCastId

    local now = supplied_now or 100
    return {
        CastId = scheduler_state.PendingCastId,
        CreativeSkillId = creative_skill_id,
        CreativeRank = 2,
        SourceSkillId =
            scheduler_state.SourceSkillOverride or 1168,
        SourceRank = 3,
        SourceCastRange = 600,
        SourceEffectRange = 1100,
        StartedAt = now,
        InterruptAt = now + 2,
        LaunchAt = now + 4,
        FinalizerAt = now + 4,
        ReuseReadyAt = now + 9,
    }, nil
end

--[[
Cancels one disposable periodic scheduler receipt.

Args:
    subject (any): Expected cast owner.
    cast_id (number): Private scheduler receipt.

Returns:
    (boolean, string?): Cancellation result or strict receipt denial.
]]
function FakeScheduler:cancel_cast(
    subject: any,
    cast_id: number
): (boolean, string?)
    scheduler_state.CancelCalls += 1

    if subject ~= player
        or scheduler_state.PendingCastId ~= cast_id
    then
        return false, "C4SourceCastReceiptInvalid"
    end

    scheduler_state.PendingCastId = nil
    return true, nil
end

--[[
Launches one disposable periodic scheduler receipt.

Args:
    subject (any): Expected cast owner.
    cast_id (number): Private scheduler receipt.
    supplied_now (number?): Deterministic scheduler timestamp.

Returns:
    (any?, string?): Source-effect-ready launch payload or configured denial.
]]
function FakeScheduler:launch_if_ready(
    subject: any,
    cast_id: number,
    _supplied_now: number?
): (any?, string?)
    scheduler_state.LaunchCalls += 1

    if subject ~= player
        or scheduler_state.PendingCastId ~= cast_id
    then
        return nil, "C4SourceCastReceiptInvalid"
    end
    if scheduler_state.LaunchReason then
        return nil, scheduler_state.LaunchReason
    end

    scheduler_state.PendingCastId = nil
    return {
        CastId = cast_id,
        CreativeSkillId = "EmberweaverVenomHex",
        CreativeRank =
            scheduler_state.LaunchRankOverride or 2,
        SourceSkillId = 1168,
        SourceRank = 3,
        SourceCastRange = 600,
        SourceEffectRange = 1100,
        ReadyForSourceEffectExecution = true,
        InitialMpSpent = 6,
        LaunchMpSpent = 21,
    }, nil
end

--[[
Clears disposable scheduler state.

Args:
    subject (any): Expected cast owner.

Returns:
    nil: Clears only private test state.
]]
function FakeScheduler:clear_owner(subject: any)
    assert(subject == player)
    scheduler_state.ClearCalls += 1
    scheduler_state.PendingCastId = nil
end

local FakeExecutor = {}

--[[
Preflights one disposable periodic-magic NPC target.

Args:
    subject (any): Expected cast owner.
    target (any): Expected captured target.

Returns:
    (boolean, string?): Configured target readiness or denial reason.
]]
function FakeExecutor:can_status_skill_npc(
    subject: any,
    target: any,
    source_range: number?
): (boolean, string?)
    executor_state.PreflightCalls += 1
    executor_state.LastRange = source_range

    if subject ~= player or target ~= enemy then
        return false, "InvalidC4LiveNpcTarget"
    end
    if not executor_state.TargetReady then
        return false, executor_state.TargetReason
            or "C4NpcSourceBoundaryUnavailable"
    end

    return true, nil
end

--[[
Resolves one disposable Venom Hex status cast.

Args:
    subject (any): Expected cast owner.
    target (any): Expected captured NPC.
    creative_skill_id (string): Expected Venom Hex skill.
    creative_rank (number): Expected server-owned rank.
    sequence_id (number?): Existing trusted action sequence.

Returns:
    (any?, string?): Fake status resolution.
]]
function FakeExecutor:status_skill_npc(
    subject: any,
    target: any,
    creative_skill_id: string,
    creative_rank: number,
    sequence_id: number?
): (any?, string?)
    executor_state.StatusCalls += 1
    executor_state.LastSequence = sequence_id

    assert(subject == player)
    assert(target == enemy)
    assert(creative_skill_id == "EmberweaverVenomHex")
    assert(creative_rank == 2)

    return {
        Kind = "C4LiveNpcPeriodicStatus",
        Applied = executor_state.Landed,
        StatusApplied = executor_state.Landed,
        Landed = executor_state.Landed,
        Scheduled = executor_state.Landed,
        SourceSkillId = 1168,
        SourceRank = 3,
        TickDamage = 8,
        TickCount = 10,
        TickSeconds = 3,
    }, nil
end

--[[
Counts one periodic-magic bridge assertion.

Args:
    condition (boolean): Observed bridge state.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Periodic Magic Cast] " .. label)
end

--[[
Restores deterministic fake scheduler and executor state.

Args:
    None.

Returns:
    nil: Resets all counters and configured overrides.
]]
local function reset_fakes()
    scheduler_state.BeginCalls = 0
    scheduler_state.CancelCalls = 0
    scheduler_state.LaunchCalls = 0
    scheduler_state.ClearCalls = 0
    scheduler_state.NextCastId = 80
    scheduler_state.PendingCastId = nil
    scheduler_state.LaunchReason = nil
    scheduler_state.SourceSkillOverride = nil
    scheduler_state.LaunchRankOverride = nil

    executor_state.PreflightCalls = 0
    executor_state.StatusCalls = 0
    executor_state.TargetReady = true
    executor_state.TargetReason = nil
    executor_state.Landed = true
    executor_state.LastSequence = nil
    executor_state.LastRange = nil
end

--[[
Creates one fresh disabled periodic-magic bridge.

Args:
    None.

Returns:
    any: Isolated bridge using fake scheduler/executor authorities.
]]
local function service(): any
    return PeriodicMagic.new(FakeScheduler, FakeExecutor)
end

--[[
Checks default-off and reviewed-family gates.

Args:
    None.

Returns:
    nil: Prevents unrelated status/AOE skills entering the bridge.
]]
local function check_gate_and_review()
    reset_fakes()
    local bridge = service()

    local disabled, disabled_reason = bridge:begin_cast(
        player,
        enemy,
        "EmberweaverVenomHex",
        100
    )
    check(
        disabled == nil
            and disabled_reason == "C4PeriodicMagicCastDisabled"
            and scheduler_state.BeginCalls == 0,
        "periodic magic bridge starts disabled"
    )

    bridge:set_enabled(true)
    local blocked, blocked_reason = bridge:begin_cast(
        player,
        enemy,
        "EmberweaverVenomCloud",
        100
    )
    check(
        blocked == nil
            and blocked_reason == "C4PeriodicMagicSkillNotReviewed"
            and scheduler_state.BeginCalls == 0,
        "area poison remains outside first periodic bridge"
    )
end

--[[
Checks cast start and source identity binding.

Args:
    None.

Returns:
    nil: Confirms Venom Hex 2 resolves source Poison 1168 rank 3.
]]
local function check_start_identity()
    reset_fakes()
    local bridge = service()
    bridge:set_enabled(true)

    local started = assert(bridge:begin_cast(
        player,
        enemy,
        "EmberweaverVenomHex",
        200
    ))
    check(
        started.CreativeRank == 2
            and started.SourceSkillId == 1168
            and started.SourceRank == 3
            and started.TargetBoundServerSide
            and executor_state.PreflightCalls == 1
            and executor_state.LastRange == 600
            and scheduler_state.BeginCalls == 1,
        "Venom Hex binds exact source Poison rank before launch"
    )
end

--[[
Checks early rejection and one successful landed periodic status handoff.

Args:
    None.

Returns:
    nil: Confirms scheduler readiness gates the source status executor.
]]
local function check_landed_launch()
    reset_fakes()
    local bridge = service()
    bridge:set_enabled(true)

    local started = assert(bridge:begin_cast(
        player,
        enemy,
        "EmberweaverVenomHex",
        300
    ))

    scheduler_state.LaunchReason = "C4SourceCastNotReady"
    local early, early_reason = bridge:launch_if_ready(
        player,
        started.CastId,
        303.9,
        951
    )
    check(
        early == nil
            and early_reason == "C4SourceCastNotReady"
            and executor_state.StatusCalls == 0
            and bridge:snapshot(player).Pending,
        "early Venom Hex launch cannot roll or schedule poison"
    )

    scheduler_state.LaunchReason = nil
    local resolved = assert(bridge:launch_if_ready(
        player,
        started.CastId,
        304,
        951
    ))
    check(
        resolved.StatusResolved
            and resolved.Landed
            and resolved.StatusApplied
            and resolved.ShotConsumedBySourceCalculation
            and executor_state.StatusCalls == 1
            and executor_state.LastSequence == 951
            and executor_state.LastRange == 1100
            and not bridge:snapshot(player).Pending,
        "ready Venom Hex resolves one source poison application"
    )
end

--[[
Checks a resisted source poison still completes the cast exactly once.

Args:
    None.

Returns:
    nil: Confirms resistance is a resolved cast, not a retryable failure.
]]
local function check_resisted_launch()
    reset_fakes()
    local bridge = service()
    bridge:set_enabled(true)
    executor_state.Landed = false

    local started = assert(bridge:begin_cast(
        player,
        enemy,
        "EmberweaverVenomHex",
        400
    ))
    local resolved = assert(bridge:launch_if_ready(
        player,
        started.CastId,
        404,
        952
    ))
    check(
        resolved.StatusResolved
            and not resolved.Landed
            and not resolved.StatusApplied
            and executor_state.StatusCalls == 1
            and not bridge:snapshot(player).Pending,
        "resisted Venom Hex completes without a replayable receipt"
    )
end

--[[
Checks hit-time target failure cancels before scheduler launch.

Args:
    None.

Returns:
    nil: Confirms invalid target spends no launch MP and consumes no shot.
]]
local function check_target_revalidation()
    reset_fakes()
    local bridge = service()
    bridge:set_enabled(true)

    local started = assert(bridge:begin_cast(
        player,
        enemy,
        "EmberweaverVenomHex",
        500
    ))
    executor_state.TargetReady = false
    executor_state.TargetReason =
        "C4NpcSourceBoundaryUnavailable"

    local resolved, reason = bridge:launch_if_ready(
        player,
        started.CastId,
        504,
        953
    )
    check(
        resolved == nil
            and reason == "C4NpcSourceBoundaryUnavailable"
            and scheduler_state.CancelCalls == 1
            and scheduler_state.LaunchCalls == 0
            and executor_state.StatusCalls == 0
            and not bridge:snapshot(player).Pending,
        "invalid poison target cancels before launch MP and shot resolution"
    )
end

--[[
Checks reviewed source drift is cancelled before storing bridge state.

Args:
    None.

Returns:
    nil: Prevents Venom Hex mapping to an unexpected source skill.
]]
local function check_source_mismatch()
    reset_fakes()
    local bridge = service()
    bridge:set_enabled(true)
    scheduler_state.SourceSkillOverride = 9999

    local started, reason = bridge:begin_cast(
        player,
        enemy,
        "EmberweaverVenomHex",
        600
    )
    check(
        started == nil
            and reason == "C4PeriodicMagicReviewedSourceMismatch"
            and scheduler_state.CancelCalls == 1
            and not bridge:snapshot(player).Pending,
        "periodic bridge rejects unexpected historical source mapping"
    )
end

--[[
Checks launch rank drift fails without status execution.

Args:
    None.

Returns:
    nil: Prevents a stale rank from reaching the source status executor.
]]
local function check_launch_plan_change()
    reset_fakes()
    local bridge = service()
    bridge:set_enabled(true)

    local started = assert(bridge:begin_cast(
        player,
        enemy,
        "EmberweaverVenomHex",
        700
    ))
    scheduler_state.LaunchRankOverride = 1

    local resolved, reason = bridge:launch_if_ready(
        player,
        started.CastId,
        704,
        954
    )
    check(
        resolved == nil
            and reason == "C4PeriodicMagicLaunchPlanChanged"
            and executor_state.StatusCalls == 0
            and not bridge:snapshot(player).Pending,
        "periodic bridge rejects changed launch rank"
    )
end

--[[
Checks owner teardown clears bridge and scheduler state.

Args:
    None.

Returns:
    nil: Confirms disconnect cleanup delegates to scheduler authority.
]]
local function check_owner_cleanup()
    reset_fakes()
    local bridge = service()
    bridge:set_enabled(true)

    assert(bridge:begin_cast(
        player,
        enemy,
        "EmberweaverVenomHex",
        800
    ))
    bridge:clear_owner(player)

    check(
        scheduler_state.ClearCalls == 1
            and not bridge:snapshot(player).Pending,
        "periodic owner cleanup clears bridge and scheduler state"
    )
end

--[[
Runs scheduled Human Wizard periodic-magic acceptance.

Args:
    None.

Returns:
    nil: Prints bounded pending-Studio evidence after all assertions.
]]
local function main()
    local bridge = service()
    local capability = bridge:capability()

    check(
        capability.Available
            and capability.DefaultEnabled == false
            and not capability.CurrentlyEnabled
            and capability.ReviewedPeriodicMagicOnly
            and capability.ReviewedSkill == "EmberweaverVenomHex"
            and capability.ReviewedSourceSkillId == 1168
            and capability.TargetBoundAtCastStart
            and capability.SourceCastRangeAtStart
            and capability.SourceEffectRangeAtLaunch
            and capability.TargetRevalidatedBeforeLaunchMp
            and capability.LaunchMpCommittedBeforeStatusResolution
            and capability.ShotConsumptionDelegatedToSourceCalculation
            and not capability.ClientTargetAuthority
            and not capability.ClientStatusAuthority,
        "capability keeps periodic poison bridge narrow and server-only"
    )

    check_gate_and_review()
    check_start_identity()
    check_landed_launch()
    check_resisted_launch()
    check_target_revalidation()
    check_source_mismatch()
    check_launch_plan_change()
    check_owner_cleanup()

    print((
        "[C4 Periodic Magic Cast] TEST_PASS_PENDING_STUDIO: %d assertions "
        .. "poison=true scheduler=true executor=true live_gate=false"
    ):format(checks))
end

main()
