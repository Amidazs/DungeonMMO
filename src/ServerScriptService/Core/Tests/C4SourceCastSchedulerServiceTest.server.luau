--!strict
-- Private Human Wizard source cast scheduler transaction regression.

local ServerScriptService = game:GetService("ServerScriptService")

local Scheduler = require(
    ServerScriptService.Core.Services.C4SourceCastSchedulerService
)

local USER_ID = 938194
local player = {
    UserId = USER_ID,
}
local checks = 0

local timing_plan = {
    CreativeSkillId = "EmberweaverEmberBolt",
    CreativeRank = 6,
    SourceSkillId = 1220,
    SourceRank = 6,
    FinalHitTimeMs = 4000,
    CastInterruptTimeMs = 2000,
    FinalCoolTimeMs = 140,
    FinalReuseDelayMs = 4500,
    FinalReuseDelayReady = true,
    ReuseBlocker = nil,
}
local timing_reason: string? = nil
local timing_calls = 0

local FakeTiming = {}

--[[
Returns the current disposable source timing plan.

Args:
    user_id (number): Expected authenticated cast owner.
    creative_skill_id (string): Expected creative skill.

Returns:
    (any?, string?): Detached timing plan or configured denial reason.
]]
function FakeTiming:resolve(
    user_id: number,
    creative_skill_id: string
): (any?, string?)
    timing_calls += 1

    if user_id ~= USER_ID
        or creative_skill_id ~= "EmberweaverEmberBolt"
    then
        return nil, "CreativeCastSkillRankNotOwned"
    end
    if timing_reason then
        return nil, timing_reason
    end

    return table.clone(timing_plan), nil
end

local resource_state = {
    BeginCalls = 0,
    CancelCalls = 0,
    CommitCalls = 0,
    ClearCalls = 0,
    NextCastId = 40,
    PendingCastId = nil,
    SourceRankOverride = nil,
    CommitReason = nil,
}

local FakeResources = {}

--[[
Begins a disposable split-MP source transaction.

Args:
    subject (any): Expected scheduler owner.
    creative_skill_id (string): Expected creative skill.

Returns:
    (any?, string?): Matching resource receipt or owner denial.
]]
function FakeResources:begin_cast(
    subject: any,
    creative_skill_id: string
): (any?, string?)
    resource_state.BeginCalls += 1

    if subject ~= player
        or creative_skill_id ~= "EmberweaverEmberBolt"
    then
        return nil, "C4SourceCastOwnerInvalid"
    end

    resource_state.NextCastId += 1
    resource_state.PendingCastId = resource_state.NextCastId

    return {
        CastId = resource_state.PendingCastId,
        CreativeSkillId = creative_skill_id,
        CreativeRank = 6,
        SourceSkillId = 1220,
        SourceRank = resource_state.SourceRankOverride or 6,
        InitialMpSpent = 6,
        LaunchMpPending = 21,
    }, nil
end

--[[
Cancels the current disposable split-MP receipt.

Args:
    subject (any): Expected scheduler owner.
    cast_id (number): Private resource receipt.

Returns:
    (boolean, string?): Cancellation result.
]]
function FakeResources:cancel_cast(
    subject: any,
    cast_id: number
): (boolean, string?)
    resource_state.CancelCalls += 1

    if subject ~= player
        or resource_state.PendingCastId ~= cast_id
    then
        return false, "C4SourceCastReceiptInvalid"
    end

    resource_state.PendingCastId = nil
    return true, nil
end

--[[
Commits the current disposable launch-time MP spend.

Args:
    subject (any): Expected scheduler owner.
    cast_id (number): Private resource receipt.

Returns:
    (any?, string?): Launch resource evidence or configured denial.
]]
function FakeResources:commit_cast(
    subject: any,
    cast_id: number
): (any?, string?)
    resource_state.CommitCalls += 1

    if subject ~= player
        or resource_state.PendingCastId ~= cast_id
    then
        return nil, "C4SourceCastReceiptInvalid"
    end

    resource_state.PendingCastId = nil

    if resource_state.CommitReason then
        return nil, resource_state.CommitReason
    end

    return {
        CastId = cast_id,
        InitialMpSpent = 6,
        LaunchMpSpent = 21,
    }, nil
end

--[[
Clears the disposable resource receipt for owner teardown.

Args:
    subject (any): Expected scheduler owner.

Returns:
    nil: Clears only private test state.
]]
function FakeResources:clear_owner(subject: any)
    assert(subject == player)
    resource_state.ClearCalls += 1
    resource_state.PendingCastId = nil
end

--[[
Counts one scheduler assertion.

Args:
    condition (boolean): Observed scheduler state.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the check count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Source Cast Scheduler] " .. label)
end

--[[
Restores all disposable dependency state between transaction scenarios.

Args:
    None.

Returns:
    nil: Resets fake timing/resource counters and plans.
]]
local function reset_fakes()
    timing_plan = {
        CreativeSkillId = "EmberweaverEmberBolt",
        CreativeRank = 6,
        SourceSkillId = 1220,
        SourceRank = 6,
        FinalHitTimeMs = 4000,
        CastInterruptTimeMs = 2000,
        FinalCoolTimeMs = 140,
        FinalReuseDelayMs = 4500,
        FinalReuseDelayReady = true,
        ReuseBlocker = nil,
    }
    timing_reason = nil
    timing_calls = 0

    resource_state.BeginCalls = 0
    resource_state.CancelCalls = 0
    resource_state.CommitCalls = 0
    resource_state.ClearCalls = 0
    resource_state.NextCastId = 40
    resource_state.PendingCastId = nil
    resource_state.SourceRankOverride = nil
    resource_state.CommitReason = nil
end

--[[
Checks exact deadlines, early rejection and successful source launch commit.

Args:
    None.

Returns:
    nil: Confirms source hit/cool/reuse times become private deadlines.
]]
local function check_normal_schedule()
    reset_fakes()
    local scheduler = Scheduler.new(FakeResources, FakeTiming)

    local started, reason = scheduler:begin_cast(
        player,
        "EmberweaverEmberBolt",
        100
    )
    check(
        started ~= nil
            and reason == nil
            and started.StartedAt == 100
            and started.InterruptAt == 102
            and started.LaunchAt == 104
            and math.abs(started.FinalizerAt - 104.14) < 0.000001
            and started.ReuseReadyAt == 104.5,
        "source timing plan creates exact private deadlines"
    )

    local early, early_reason = scheduler:launch_if_ready(
        player,
        started.CastId,
        103.999
    )
    check(
        early == nil
            and early_reason == "C4SourceCastNotReady"
            and resource_state.CommitCalls == 0
            and scheduler:snapshot(player).Pending,
        "launch-time MP cannot commit before exact hit deadline"
    )

    local launched, launch_reason = scheduler:launch_if_ready(
        player,
        started.CastId,
        104
    )
    check(
        launched ~= nil
            and launch_reason == nil
            and launched.LaunchMpSpent == 21
            and launched.ReadyForSourceEffectExecution
            and not launched.LiveDamageIntegrated
            and resource_state.CommitCalls == 1
            and not scheduler:snapshot(player).Pending,
        "deadline commit produces one source-effect-ready payload"
    )

    local replay, replay_reason = scheduler:launch_if_ready(
        player,
        started.CastId,
        104.1
    )
    check(
        replay == nil
            and replay_reason == "C4SourceCastReceiptInvalid"
            and resource_state.CommitCalls == 1,
        "launched scheduler receipt cannot be replayed"
    )

    check(
        math.abs(
            scheduler:get_reuse_remaining(
                player,
                "EmberweaverEmberBolt",
                104
            ) - 0.5
        ) < 0.000001,
        "source reuse continues after spell launch"
    )
end

--[[
Checks source reuse starts at cast start and survives cancellation.

Args:
    None.

Returns:
    nil: Prevents interrupted casts from bypassing source reuse.
]]
local function check_cancel_and_reuse()
    reset_fakes()
    local scheduler = Scheduler.new(FakeResources, FakeTiming)

    local started = assert(scheduler:begin_cast(
        player,
        "EmberweaverEmberBolt",
        200
    ))
    local cancelled, cancel_reason = scheduler:cancel_cast(
        player,
        started.CastId
    )
    check(
        cancelled
            and cancel_reason == nil
            and resource_state.CancelCalls == 1
            and not scheduler:snapshot(player).Pending,
        "cancellation clears pending cast through resource authority"
    )

    local blocked, blocked_reason = scheduler:begin_cast(
        player,
        "EmberweaverEmberBolt",
        204.499
    )
    check(
        blocked == nil
            and blocked_reason == "C4SourceCastReusePending"
            and resource_state.BeginCalls == 1,
        "cancelled source cast keeps its cast-start reuse gate"
    )

    local restarted, restart_reason = scheduler:begin_cast(
        player,
        "EmberweaverEmberBolt",
        204.5
    )
    check(
        restarted ~= nil
            and restart_reason == nil
            and resource_state.BeginCalls == 2,
        "source reuse deadline permits the next cast exactly when ready"
    )
end

--[[
Checks unresolved timing never spends initial MP.

Args:
    None.

Returns:
    nil: Keeps mastery/timing blockers ahead of resource mutation.
]]
local function check_unresolved_reuse()
    reset_fakes()
    local scheduler = Scheduler.new(FakeResources, FakeTiming)
    timing_plan.FinalReuseDelayReady = false
    timing_plan.FinalReuseDelayMs = nil
    timing_plan.ReuseBlocker =
        "OriginalSkillMasteryRollNotIntegrated"

    local started, reason = scheduler:begin_cast(
        player,
        "EmberweaverEmberBolt",
        300
    )
    check(
        started == nil
            and reason == "OriginalSkillMasteryRollNotIntegrated"
            and timing_calls == 1
            and resource_state.BeginCalls == 0,
        "unresolved final reuse rejects before split-MP cast start"
    )
end

--[[
Checks timing/resource identity mismatch fails closed and cancels receipt.

Args:
    None.

Returns:
    nil: Prevents a changed source rank from becoming a mixed cast plan.
]]
local function check_plan_change()
    reset_fakes()
    local scheduler = Scheduler.new(FakeResources, FakeTiming)
    resource_state.SourceRankOverride = 5

    local started, reason = scheduler:begin_cast(
        player,
        "EmberweaverEmberBolt",
        400
    )
    check(
        started == nil
            and reason == "C4SourceCastPlanChanged"
            and resource_state.BeginCalls == 1
            and resource_state.CancelCalls == 1
            and not scheduler:snapshot(player).Pending,
        "mismatched timing/resource source ranks are cancelled immediately"
    )
end

--[[
Checks authority failure at deadline clears the receipt without replay.

Args:
    None.

Returns:
    nil: Confirms failed launch revalidation cannot be retried.
]]
local function check_commit_failure()
    reset_fakes()
    local scheduler = Scheduler.new(FakeResources, FakeTiming)
    resource_state.CommitReason = "C4SourceCastAuthorityChanged"

    local started = assert(scheduler:begin_cast(
        player,
        "EmberweaverEmberBolt",
        500
    ))
    local launched, reason = scheduler:launch_if_ready(
        player,
        started.CastId,
        504
    )
    check(
        launched == nil
            and reason == "C4SourceCastAuthorityChanged"
            and resource_state.CommitCalls == 1
            and not scheduler:snapshot(player).Pending,
        "launch authority failure consumes the scheduler receipt once"
    )

    local replay, replay_reason = scheduler:launch_if_ready(
        player,
        started.CastId,
        505
    )
    check(
        replay == nil
            and replay_reason == "C4SourceCastReceiptInvalid"
            and resource_state.CommitCalls == 1,
        "failed launch authority cannot be replayed"
    )
end

--[[
Checks one owner cannot overlap two source casts.

Args:
    None.

Returns:
    nil: Confirms scheduler overlap gate precedes another resource spend.
]]
local function check_overlap_gate()
    reset_fakes()
    local scheduler = Scheduler.new(FakeResources, FakeTiming)

    local started = assert(scheduler:begin_cast(
        player,
        "EmberweaverEmberBolt",
        600
    ))
    local duplicate, reason = scheduler:begin_cast(
        player,
        "EmberweaverEmberBolt",
        600.1
    )
    check(
        duplicate == nil
            and reason == "C4SourceCastAlreadyScheduled"
            and resource_state.BeginCalls == 1,
        "one owner cannot overlap pending source casts"
    )

    scheduler:cancel_cast(player, started.CastId)
    scheduler:clear_owner(player)
    check(
        resource_state.ClearCalls == 1
            and scheduler:get_reuse_remaining(
                player,
                "EmberweaverEmberBolt",
                600.2
            ) == 0,
        "owner teardown clears scheduler reuse and resource state"
    )
end

--[[
Runs private Human Wizard source scheduler acceptance.

Args:
    None.

Returns:
    nil: Prints bounded source-only evidence after all scenarios pass.
]]
local function main()
    local capability =
        Scheduler.new(FakeResources, FakeTiming):capability()
    check(
        capability.Available
            and capability.ServerOwnedDeadlines
            and capability.ReuseStartsAtCastStart
            and capability.EarlyLaunchRejected
            and capability.CancellationKeepsReuse
            and capability.ReplayRejected
            and capability.SplitManaCommitAtLaunch
            and capability.ReadyForSourceEffectExecution
            and not capability.ShotConsumptionIntegrated
            and not capability.LiveDamageIntegrated
            and not capability.ClientAuthority,
        "capability keeps scheduler private and source-effect-only"
    )

    check_normal_schedule()
    check_cancel_and_reuse()
    check_unresolved_reuse()
    check_plan_change()
    check_commit_failure()
    check_overlap_gate()

    print((
        "[C4 Source Cast Scheduler] SOURCE_ONLY_PASS: %d assertions "
        .. "deadline=true reuse=true cancel=true replay=true live=false"
    ):format(checks))
end

main()
