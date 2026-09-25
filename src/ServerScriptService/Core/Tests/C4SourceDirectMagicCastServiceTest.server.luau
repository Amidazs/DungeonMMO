--!strict
-- Human Wizard direct-MDAM scheduler-to-executor bridge regression.

local ServerScriptService = game:GetService("ServerScriptService")

local DirectMagic = require(
    ServerScriptService.Core.Services.C4SourceDirectMagicCastService
)

local USER_ID = 938195
local player = {
    UserId = USER_ID,
}
local enemy = {
    Name = "TEMP_SourceDirectMagicEnemy",
}
local checks = 0

local REVIEWED_PLANS = table.freeze({
    EmberweaverEmberBolt = table.freeze({
        CreativeRank = 6,
        SourceSkillId = 1220,
        SourceRank = 6,
        CastRange = 750,
        EffectRange = 1250,
    }),
    EmberweaverFlameBurst = table.freeze({
        CreativeRank = 6,
        SourceSkillId = 1172,
        SourceRank = 6,
        CastRange = 150,
        EffectRange = 650,
    }),
    EmberweaverFocusedBolt = table.freeze({
        CreativeRank = 3,
        SourceSkillId = 1274,
        SourceRank = 3,
        CastRange = 400,
        EffectRange = 900,
    }),
})


local scheduler_state = {
    BeginCalls = 0,
    CancelCalls = 0,
    LaunchCalls = 0,
    ClearCalls = 0,
    NextCastId = 70,
    PendingCastId = nil,
    LaunchReason = nil,
    LaunchRankOverride = nil,
    SourceSkillOverride = nil,
    PendingSkillId = nil,
}

local executor_state = {
    PreflightCalls = 0,
    MagicCalls = 0,
    TargetReady = true,
    TargetReason = nil,
    LastEnemy = nil,
    LastRank = nil,
    LastSequence = nil,
    LastRange = nil,
}

local FakeScheduler = {}

--[[
Begins one disposable private source schedule.

Args:
    subject (any): Expected cast owner.
    creative_skill_id (string): Expected reviewed creative skill.
    supplied_now (number?): Deterministic scheduler time.

Returns:
    (any?, string?): Source scheduler start evidence or denial reason.
]]
function FakeScheduler:begin_cast(
    subject: any,
    creative_skill_id: string,
    supplied_now: number?
): (any?, string?)
    scheduler_state.BeginCalls += 1

    local plan = REVIEWED_PLANS[creative_skill_id]
    if subject ~= player or not plan then
        return nil, "C4SourceCastOwnerInvalid"
    end

    scheduler_state.NextCastId += 1
    scheduler_state.PendingCastId =
        scheduler_state.NextCastId
    scheduler_state.PendingSkillId = creative_skill_id

    local now = supplied_now or 100
    return {
        CastId = scheduler_state.PendingCastId,
        CreativeSkillId = creative_skill_id,
        CreativeRank = plan.CreativeRank,
        SourceSkillId =
            scheduler_state.SourceSkillOverride
            or plan.SourceSkillId,
        SourceRank = plan.SourceRank,
        SourceCastRange = plan.CastRange,
        SourceEffectRange = plan.EffectRange,
        StartedAt = now,
        InterruptAt = now + 2,
        LaunchAt = now + 4,
        FinalizerAt = now + 4.14,
        ReuseReadyAt = now + 4.5,
    }, nil
end

--[[
Cancels one disposable source scheduler receipt.

Args:
    subject (any): Expected cast owner.
    cast_id (number): Private scheduler receipt.

Returns:
    (boolean, string?): Cancellation result or receipt denial.
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
    scheduler_state.PendingSkillId = nil
    return true, nil
end

--[[
Launches the disposable scheduler receipt when configured ready.

Args:
    subject (any): Expected cast owner.
    cast_id (number): Private scheduler receipt.
    supplied_now (number?): Deterministic scheduler time.

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

    local skill_id = scheduler_state.PendingSkillId
    local plan = assert(REVIEWED_PLANS[skill_id])

    scheduler_state.PendingCastId = nil
    scheduler_state.PendingSkillId = nil
    return {
        CastId = cast_id,
        CreativeSkillId = skill_id,
        CreativeRank =
            scheduler_state.LaunchRankOverride
            or plan.CreativeRank,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = plan.SourceRank,
        SourceCastRange = plan.CastRange,
        SourceEffectRange = plan.EffectRange,
        ReadyForSourceEffectExecution = true,
        InitialMpSpent = 6,
        LaunchMpSpent = 21,
    }, nil
end

--[[
Clears disposable scheduler state for owner teardown.

Args:
    subject (any): Expected cast owner.

Returns:
    nil: Clears private test state.
]]
function FakeScheduler:clear_owner(subject: any)
    assert(subject == player)
    scheduler_state.ClearCalls += 1
    scheduler_state.PendingCastId = nil
end

local FakeExecutor = {}

--[[
Preflights one disposable NPC source-magic target without mutation.

Args:
    subject (any): Expected cast owner.
    target (any): Expected captured target.

Returns:
    (boolean, string?): Configured target readiness or denial reason.
]]
function FakeExecutor:can_magic_skill_npc(
    subject: any,
    target: any,
    source_range: number?
): (boolean, string?)
    executor_state.PreflightCalls += 1
    executor_state.LastEnemy = target
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
Applies one disposable direct MDAM result.

Args:
    subject (any): Expected cast owner.
    target (any): Expected privately captured NPC.
    creative_skill_id (string): Reviewed creative direct spell.
    creative_rank (number): Server-owned purchased rank.
    sequence_id (number?): Existing trusted combat sequence.

Returns:
    (any?, string?): Fake source executor result.
]]
function FakeExecutor:magic_skill_npc(
    subject: any,
    target: any,
    creative_skill_id: string,
    creative_rank: number,
    sequence_id: number?
): (any?, string?)
    executor_state.MagicCalls += 1
    executor_state.LastEnemy = target
    executor_state.LastRank = creative_rank
    executor_state.LastSequence = sequence_id

    assert(subject == player)
    assert(target == enemy)
    assert(REVIEWED_PLANS[creative_skill_id] ~= nil)

    return {
        Kind = "C4LiveNpcMagicSkill",
        Applied = true,
        RawDamage = 8,
        HealthDamage = 8,
        Calculation = {
            Spiritshot = true,
            BlessedSpiritshot = false,
        },
    }, nil
end

--[[
Counts one direct-magic bridge assertion.

Args:
    condition (boolean): Observed bridge state.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Direct Magic Cast] " .. label)
end

--[[
Resets all fake scheduler and executor state between scenarios.

Args:
    None.

Returns:
    nil: Restores deterministic default fake state.
]]
local function reset_fakes()
    scheduler_state.BeginCalls = 0
    scheduler_state.CancelCalls = 0
    scheduler_state.LaunchCalls = 0
    scheduler_state.ClearCalls = 0
    scheduler_state.NextCastId = 70
    scheduler_state.PendingCastId = nil
    scheduler_state.LaunchReason = nil
    scheduler_state.LaunchRankOverride = nil
    scheduler_state.SourceSkillOverride = nil
    scheduler_state.PendingSkillId = nil

    executor_state.PreflightCalls = 0
    executor_state.MagicCalls = 0
    executor_state.TargetReady = true
    executor_state.TargetReason = nil
    executor_state.LastEnemy = nil
    executor_state.LastRank = nil
    executor_state.LastSequence = nil
    executor_state.LastRange = nil
end

--[[
Creates one fresh disabled direct-magic bridge.

Args:
    None.

Returns:
    any: Isolated bridge using fake scheduler/executor authorities.
]]
local function service(): any
    return DirectMagic.new(FakeScheduler, FakeExecutor)
end

--[[
Checks default-off and reviewed-skill allowlist behaviour.

Args:
    None.

Returns:
    nil: Prevents unreviewed skills from entering the live bridge.
]]
local function check_gate_and_allowlist()
    reset_fakes()
    local bridge = service()

    local disabled, disabled_reason = bridge:begin_cast(
        player,
        enemy,
        "EmberweaverEmberBolt",
        100
    )
    check(
        disabled == nil
            and disabled_reason == "C4DirectMagicCastDisabled"
            and scheduler_state.BeginCalls == 0
            and executor_state.PreflightCalls == 0,
        "direct magic bridge starts disabled before any source mutation"
    )

    bridge:set_enabled(true)
    local blocked, blocked_reason = bridge:begin_cast(
        player,
        enemy,
        "EmberweaverFrostLance",
        100
    )
    check(
        blocked == nil
            and blocked_reason == "C4DirectMagicSkillNotReviewed"
            and scheduler_state.BeginCalls == 0,
        "bridge rejects MDAM families with unimplemented side effects"
    )
end

--[[
Creates one enabled target-bound direct-MDAM cast fixture.

Args:
    start_time (number): Deterministic scheduler start timestamp.

Returns:
    (any, any): Enabled bridge and its successful start evidence.
]]
local function started_bridge(
    start_time: number,
    creative_skill_id: string?
): (any, any)
    reset_fakes()
    local bridge = service()
    bridge:set_enabled(true)

    local skill_id =
        creative_skill_id or "EmberweaverEmberBolt"
    local started = assert(bridge:begin_cast(
        player,
        enemy,
        skill_id,
        start_time
    ))

    return bridge, started
end

--[[
Checks target validation and private target binding at cast start.

Args:
    None.

Returns:
    nil: Confirms scheduler starts only after reviewed NPC validation.
]]
local function check_target_bound_start()
    local _, started = started_bridge(200)

    check(
        started.TargetBoundServerSide
            and started.CastId == 71
            and started.CreativeRank == 6
            and executor_state.PreflightCalls == 1
            and scheduler_state.BeginCalls == 1,
        "cast start validates then privately binds the reviewed NPC"
    )
end

--[[
Checks early launch rejection and one successful executor handoff.

Args:
    None.

Returns:
    nil: Confirms exact target/rank/sequence reaches the executor once.
]]
local function check_successful_launch()
    local bridge, started = started_bridge(200)

    scheduler_state.LaunchReason = "C4SourceCastNotReady"
    local early, early_reason = bridge:launch_if_ready(
        player,
        started.CastId,
        203.9,
        901
    )
    check(
        early == nil
            and early_reason == "C4SourceCastNotReady"
            and bridge:snapshot(player).Pending
            and executor_state.MagicCalls == 0,
        "early launch leaves target-bound cast pending without damage"
    )

    scheduler_state.LaunchReason = nil
    local applied = assert(bridge:launch_if_ready(
        player,
        started.CastId,
        204,
        901
    ))
    check(
        applied.Kind == "C4ScheduledDirectMagic"
            and applied.Applied
            and applied.ShotConsumedBySourceCalculation
            and executor_state.MagicCalls == 1
            and executor_state.LastEnemy == enemy
            and executor_state.LastRank == 6
            and executor_state.LastSequence == 901
            and executor_state.LastRange == 1250
            and not bridge:snapshot(player).Pending,
        "ready cast hands one bound rank-six spell to source executor"
    )
end

--[[
Checks invalid hit-time target cancels before launch MP or shot execution.

Args:
    None.

Returns:
    nil: Confirms target revalidation precedes scheduler launch commit.
]]
local function check_target_revalidation()
    reset_fakes()
    local bridge = service()
    bridge:set_enabled(true)

    local started = assert(bridge:begin_cast(
        player,
        enemy,
        "EmberweaverEmberBolt",
        300
    ))
    executor_state.TargetReady = false
    executor_state.TargetReason =
        "C4NpcSourceBoundaryUnavailable"

    local applied, reason = bridge:launch_if_ready(
        player,
        started.CastId,
        304,
        902
    )
    check(
        applied == nil
            and reason == "C4NpcSourceBoundaryUnavailable"
            and scheduler_state.CancelCalls == 1
            and scheduler_state.LaunchCalls == 0
            and executor_state.MagicCalls == 0
            and not bridge:snapshot(player).Pending,
        "invalid hit-time target cancels before launch MP and shot path"
    )
end

--[[
Checks explicit cancellation and stale receipt replay protection.

Args:
    None.

Returns:
    nil: Confirms a cancelled direct cast cannot later execute.
]]
local function check_cancel_and_replay()
    reset_fakes()
    local bridge = service()
    bridge:set_enabled(true)

    local started = assert(bridge:begin_cast(
        player,
        enemy,
        "EmberweaverEmberBolt",
        400
    ))
    local cancelled, cancel_reason = bridge:cancel_cast(
        player,
        started.CastId
    )
    check(
        cancelled
            and cancel_reason == nil
            and scheduler_state.CancelCalls == 1
            and not bridge:snapshot(player).Pending,
        "explicit cancellation clears bridge and scheduler receipt"
    )

    local replay, replay_reason = bridge:launch_if_ready(
        player,
        started.CastId,
        404,
        903
    )
    check(
        replay == nil
            and replay_reason == "C4DirectMagicCastReceiptInvalid"
            and executor_state.MagicCalls == 0,
        "cancelled direct-magic receipt cannot replay"
    )
end

--[[
Checks source plan drift fails after scheduler commit without damage replay.

Args:
    None.

Returns:
    nil: Prevents a changed scheduler rank from reaching the executor.
]]
local function check_launch_plan_change()
    reset_fakes()
    local bridge = service()
    bridge:set_enabled(true)

    local started = assert(bridge:begin_cast(
        player,
        enemy,
        "EmberweaverEmberBolt",
        500
    ))
    scheduler_state.LaunchRankOverride = 5

    local applied, reason = bridge:launch_if_ready(
        player,
        started.CastId,
        504,
        904
    )
    check(
        applied == nil
            and reason == "C4DirectMagicLaunchPlanChanged"
            and scheduler_state.LaunchCalls == 1
            and executor_state.MagicCalls == 0
            and not bridge:snapshot(player).Pending,
        "changed launch rank cannot execute direct source damage"
    )
end

--[[
Checks owner teardown clears both bridge and scheduler state.

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
        "EmberweaverEmberBolt",
        600
    ))
    bridge:clear_owner(player)

    check(
        scheduler_state.ClearCalls == 1
            and not bridge:snapshot(player).Pending,
        "owner cleanup clears target binding and scheduler state"
    )
end

--[[
Checks all pure single-target Human Wizard MDAM families enter the bridge.

Args:
    None.

Returns:
    nil: Confirms reviewed source IDs/ranks are accepted and target-bound.
]]
local function check_reviewed_direct_families()
    local skill_ids = {
        "EmberweaverEmberBolt",
        "EmberweaverFlameBurst",
        "EmberweaverFocusedBolt",
    }

    for index, skill_id in ipairs(skill_ids) do
        local bridge, started = started_bridge(
            150 + index,
            skill_id
        )
        local plan = assert(REVIEWED_PLANS[skill_id])

        check(
            started.CreativeSkillId == skill_id
                and started.CreativeRank == plan.CreativeRank
                and started.SourceSkillId == plan.SourceSkillId
                and started.SourceRank == plan.SourceRank
                and executor_state.LastRange == plan.CastRange,
            skill_id .. " enters the reviewed direct-MDAM bridge"
        )

        local cancelled = bridge:cancel_cast(
            player,
            started.CastId
        )
        check(
            cancelled,
            skill_id .. " reviewed bridge receipt cancels cleanly"
        )
    end
end

--[[
Checks a reviewed creative ID cannot drift to another historical source skill.

Args:
    None.

Returns:
    nil: Confirms cast start cancels mismatched source mapping immediately.
]]
local function check_reviewed_source_mismatch()
    reset_fakes()
    local bridge = service()
    bridge:set_enabled(true)
    scheduler_state.SourceSkillOverride = 9999

    local started, reason = bridge:begin_cast(
        player,
        enemy,
        "EmberweaverFocusedBolt",
        175
    )
    check(
        started == nil
            and reason == "C4DirectMagicReviewedSourceMismatch"
            and scheduler_state.CancelCalls == 1
            and not bridge:snapshot(player).Pending,
        "reviewed creative skill cannot drift to another source skill"
    )
end

--[[
Runs the direct Human Wizard MDAM bridge acceptance.

Args:
    None.

Returns:
    nil: Prints bounded test evidence for later Studio validation.
]]
local function main()
    local bridge = service()
    local capability = bridge:capability()

    check(
        capability.Available
            and capability.DefaultEnabled == false
            and not capability.CurrentlyEnabled
            and capability.ReviewedDirectMdamOnly
            and capability.ReviewedSkillCount == 3
            and #capability.ReviewedSkills == 3
            and capability.TargetBoundAtCastStart
            and capability.SourceCastRangeAtStart
            and capability.SourceEffectRangeAtLaunch
            and capability.TargetRevalidatedBeforeLaunchMp
            and capability.LaunchMpCommittedBeforeEffectExecution
            and capability.ShotConsumptionDelegatedToSourceCalculation
            and not capability.ClientTargetAuthority
            and not capability.ClientDamageAuthority,
        "capability keeps reviewed direct-MDAM bridge server-only"
    )

    check_gate_and_allowlist()
    check_reviewed_direct_families()
    check_reviewed_source_mismatch()
    check_target_bound_start()
    check_successful_launch()
    check_target_revalidation()
    check_cancel_and_replay()
    check_launch_plan_change()
    check_owner_cleanup()

    print((
        "[C4 Direct Magic Cast] TEST_PASS_PENDING_STUDIO: %d assertions "
        .. "target=true scheduler=true executor=true live_gate=false"
    ):format(checks))
end

main()
