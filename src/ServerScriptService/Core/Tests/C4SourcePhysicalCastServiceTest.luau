--!strict
-- Scheduled source physical-cast bridge regression.

local ServerScriptService = game:GetService("ServerScriptService")
local Service = require(
    ServerScriptService.Core.Services.C4SourcePhysicalCastService
)

local OWNER = table.freeze({UserId = 938260})
local TARGET = table.freeze({Name = "TEMP_PhysicalTarget"})

local PLANS = table.freeze({
    OrcPowerStrike = table.freeze({
        SourceSkillId = 3,
        ExecutionKind = "SingleTarget",
    }),
    OrcIronPunch = table.freeze({
        SourceSkillId = 29,
        ExecutionKind = "SingleTarget",
    }),
    SpiritclawIronFist = table.freeze({
        SourceSkillId = 29,
        ExecutionKind = "SingleTarget",
    }),
    SpiritclawStunningFist = table.freeze({
        SourceSkillId = 120,
        ExecutionKind = "Stun",
    }),
    SpiritclawForceBurst = table.freeze({
        SourceSkillId = 54,
        ExecutionKind = "Charged",
        CastRange = 600,
        EffectRange = 1100,
    }),
    SpiritclawCripplingPalm = table.freeze({
        SourceSkillId = 95,
        ExecutionKind = "Slow",
    }),
    WarhowlCrushingBlow = table.freeze({
        SourceSkillId = 255,
        ExecutionKind = "SingleTarget",
    }),
    WarhowlSkullbreaker = table.freeze({
        SourceSkillId = 100,
        ExecutionKind = "Stun",
    }),
    WarhowlSweepingArc = table.freeze({
        SourceSkillId = 245,
        ExecutionKind = "Area",
        SourceRadius = 150,
    }),
})

local checks = 0
local next_cast_id = 400
local pending = {}
local cancelled_cast_id = nil
local last_preflight_range = nil
local last_execution = nil

local FakeScheduler = {}

--[[
Begins one deterministic physical cast schedule.

Args:
    owner (any): Expected disposable cast owner.
    skill_id (string): Reviewed physical skill.
    supplied_now (number?): Optional deterministic start time.

Returns:
    (any?, string?): Source-shaped start evidence.
]]
function FakeScheduler:begin_cast(
    owner: any,
    skill_id: string,
    supplied_now: number?
): (any?, string?)
    local plan = PLANS[skill_id]
    if owner ~= OWNER or not plan then
        return nil, "PhysicalTestPlanUnavailable"
    end

    next_cast_id += 1
    local now = supplied_now or 100
    pending[owner] = {
        CastId = next_cast_id,
        SkillId = skill_id,
    }

    return {
        CastId = next_cast_id,
        CreativeSkillId = skill_id,
        CreativeRank = 1,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = 1,
        StartedAt = now,
        InterruptAt = now + 0.5,
        LaunchAt = now + 1,
        FinalizerAt = now + 1.1,
        ReuseReadyAt = now + 13,
        SourceCastRange = plan.CastRange or 40,
        SourceEffectRange = plan.EffectRange or 400,
    }, nil
end

--[[
Cancels one deterministic physical cast.

Args:
    owner (any): Expected disposable cast owner.
    cast_id (number): Private cast receipt.

Returns:
    (boolean, string?): Cancellation result.
]]
function FakeScheduler:cancel_cast(
    owner: any,
    cast_id: number
): (boolean, string?)
    local record = pending[owner]
    if not record or record.CastId ~= cast_id then
        return false, "PhysicalTestReceiptInvalid"
    end

    pending[owner] = nil
    cancelled_cast_id = cast_id
    return true, nil
end

--[[
Launches one deterministic physical cast.

Args:
    owner (any): Expected disposable cast owner.
    cast_id (number): Private cast receipt.
    _supplied_now (number?): Optional deterministic launch time.

Returns:
    (any?, string?): Source-shaped launch evidence.
]]
function FakeScheduler:launch_if_ready(
    owner: any,
    cast_id: number,
    _supplied_now: number?
): (any?, string?)
    local record = pending[owner]
    if not record or record.CastId ~= cast_id then
        return nil, "PhysicalTestReceiptInvalid"
    end

    pending[owner] = nil
    local plan = assert(PLANS[record.SkillId])

    return {
        CastId = cast_id,
        CreativeSkillId = record.SkillId,
        CreativeRank = 1,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = 1,
        ReadyForSourceEffectExecution = true,
    }, nil
end

--[[
Clears one owner's deterministic scheduler state.

Args:
    owner (any): Departing disposable owner.

Returns:
    nil: Removes pending fake scheduler state.
]]
function FakeScheduler:clear_owner(owner: any)
    pending[owner] = nil
end

local FakeExecutor = {}

--[[
Checks one deterministic physical target and captures source range.

Args:
    owner (any): Expected cast owner.
    target (any): Expected private target.
    source_range (number?): Reviewed source range.

Returns:
    (boolean, string?): Ready result.
]]
function FakeExecutor:can_physical_skill_npc(
    owner: any,
    target: any,
    source_range: number?
): (boolean, string?)
    last_preflight_range = source_range

    if owner ~= OWNER or target ~= TARGET then
        return false, "PhysicalTestTargetInvalid"
    end

    return true, nil
end

--[[
Executes one deterministic physical hit.

Args:
    owner (any): Expected cast owner.
    target (any): Expected private target.
    skill_id (string): Reviewed creative skill.
    rank (number): Server-owned creative rank.
    sequence_id (number?): Trusted combat sequence.

Returns:
    (any?, string?): Successful live-shaped physical evidence.
]]
function FakeExecutor:physical_skill_npc(
    owner: any,
    target: any,
    skill_id: string,
    rank: number,
    sequence_id: number?
): (any?, string?)
    if owner ~= OWNER
        or target ~= TARGET
        or not PLANS[skill_id]
        or rank ~= 1
    then
        return nil, "PhysicalTestExecutionInvalid"
    end

    last_execution = {
        SkillId = skill_id,
        Rank = rank,
        SequenceId = sequence_id,
        Kind = "SingleTarget",
    }

    return {
        Kind = "C4LiveNpcPhysicalSkill",
        Applied = true,
        HealthDamage = 17,
    }, nil
end

--[[
Executes one deterministic stun-bearing physical hit.

Args:
    owner (any): Expected cast owner.
    target (any): Expected private target.
    skill_id (string): Reviewed creative skill.
    rank (number): Server-owned creative rank.
    sequence_id (number?): Trusted combat sequence.

Returns:
    (any?, string?): Successful live-shaped stun evidence.
]]
function FakeExecutor:physical_stun_skill_npc(
    owner: any,
    target: any,
    skill_id: string,
    rank: number,
    sequence_id: number?
): (any?, string?)
    if owner ~= OWNER
        or target ~= TARGET
        or (
            skill_id ~= "WarhowlSkullbreaker"
            and skill_id ~= "SpiritclawStunningFist"
        )
        or rank ~= 1
    then
        return nil, "PhysicalTestStunExecutionInvalid"
    end

    last_execution = {
        SkillId = skill_id,
        Rank = rank,
        SequenceId = sequence_id,
        Kind = "Stun",
    }

    return {
        Kind = "C4LiveNpcPhysicalStunSkill",
        Applied = true,
        StunApplied = true,
        Landed = true,
        DurationSeconds = 9,
    }, nil
end

--[[
Executes one deterministic physical target-area hit.

Args:
    owner (any): Expected cast owner.
    target (any): Expected private target.
    skill_id (string): Reviewed creative skill.
    rank (number): Server-owned creative rank.
    source_radius (number): Exact source skill radius.
    sequence_id (number?): Trusted combat sequence.

Returns:
    (any?, string?): Successful live-shaped area evidence.
]]
function FakeExecutor:physical_area_skill_npc(
    owner: any,
    target: any,
    skill_id: string,
    rank: number,
    source_radius: number,
    sequence_id: number?
): (any?, string?)
    if owner ~= OWNER
        or target ~= TARGET
        or skill_id ~= "WarhowlSweepingArc"
        or rank ~= 1
        or source_radius ~= 150
    then
        return nil, "PhysicalTestAreaExecutionInvalid"
    end

    last_execution = {
        SkillId = skill_id,
        Rank = rank,
        SequenceId = sequence_id,
        Kind = "Area",
        SourceRadius = source_radius,
    }

    return {
        Kind = "C4LiveNpcPhysicalArea",
        Applied = true,
        TargetCount = 2,
        TotalHealthDamage = 34,
        SourceSkillRadius = source_radius,
    }, nil
end


local fake_charge_count = 1
local FakeCharges = {}

--[[
Consumes one deterministic source charge.

Args:
    owner (any): Expected charge owner.
    required (number): Exact source charge requirement.

Returns:
    (any?, string?): Deterministic charge spend evidence.
]]
function FakeCharges:consume(
    owner: any,
    required: number
): (any?, string?)
    if owner ~= OWNER or required ~= 1 or fake_charge_count < required then
        return nil, "C4SourceChargeInsufficient"
    end

    local before = fake_charge_count
    fake_charge_count -= required
    return {
        ChargeBefore = before,
        ChargeAfter = fake_charge_count,
        ChargesConsumed = required,
    }, nil
end

--[[
Executes one deterministic charged physical hit.

Args:
    owner (any): Expected cast owner.
    target (any): Expected private target.
    skill_id (string): Reviewed charged skill.
    rank (number): Server-owned creative rank.
    remaining_charges (number): Charges after exact source spend.
    sequence_id (number?): Trusted combat sequence.

Returns:
    (any?, string?): Successful charged application evidence.
]]
function FakeExecutor:charged_physical_skill_npc(
    owner: any,
    target: any,
    skill_id: string,
    rank: number,
    remaining_charges: number,
    sequence_id: number?
): (any?, string?)
    if owner ~= OWNER
        or target ~= TARGET
        or skill_id ~= "SpiritclawForceBurst"
        or rank ~= 1
        or remaining_charges ~= 0
    then
        return nil, "PhysicalTestChargedExecutionInvalid"
    end

    last_execution = {
        SkillId = skill_id,
        Rank = rank,
        SequenceId = sequence_id,
        Kind = "Charged",
    }

    return {
        Kind = "C4LiveNpcChargedPhysicalSkill",
        Applied = true,
        HealthDamage = 21,
        RequiredCharges = 1,
        RemainingCharges = 0,
        SourceChargeDamageMultiplier = 0.8,
    }, nil
end

--[[
Executes one deterministic non-damaging physical slow.

Args:
    owner (any): Expected cast owner.
    target (any): Expected private target.
    skill_id (string): Reviewed physical slow skill.
    rank (number): Server-owned creative rank.
    sequence_id (number?): Trusted combat sequence.

Returns:
    (any?, string?): Successful slow application evidence.
]]
function FakeExecutor:physical_slow_skill_npc(
    owner: any,
    target: any,
    skill_id: string,
    rank: number,
    sequence_id: number?
): (any?, string?)
    if owner ~= OWNER
        or target ~= TARGET
        or skill_id ~= "SpiritclawCripplingPalm"
        or rank ~= 1
    then
        return nil, "PhysicalTestSlowExecutionInvalid"
    end

    last_execution = {
        SkillId = skill_id,
        Rank = rank,
        SequenceId = sequence_id,
        Kind = "Slow",
    }

    return {
        Kind = "C4LiveNpcPhysicalMovementSlow",
        Applied = true,
        SlowLanded = true,
        SlowApplied = true,
        SpeedMultiplier = 0.7,
        DurationSeconds = 120,
    }, nil
end

--[[
Counts one physical bridge assertion.

Args:
    condition (boolean): Expected bridge condition.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch and increments the check count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Physical Cast] " .. label)
end

--[[
Checks default gating and unsupported-skill denial.

Args:
    bridge (any): Disabled physical bridge.

Returns:
    nil: Confirms fail-closed defaults.
]]
local function check_gate(bridge: any)
    check(
        not bridge:is_enabled(),
        "physical bridge starts disabled"
    )

    local started, reason = bridge:begin_cast(
        OWNER,
        TARGET,
        "UnknownPhysicalSkill",
        100
    )
    check(
        started == nil and reason == "C4PhysicalCastDisabled",
        "disabled bridge rejects before skill disclosure"
    )

    bridge:set_enabled(true)
    local unknown, unknown_reason = bridge:begin_cast(
        OWNER,
        TARGET,
        "UnknownPhysicalSkill",
        100
    )
    check(
        unknown == nil
            and unknown_reason == "C4PhysicalSkillNotReviewed",
        "enabled bridge still rejects unreviewed physical skills"
    )
end

--[[
Checks all reviewed single-target physical families.

Args:
    bridge (any): Enabled physical bridge.

Returns:
    nil: Confirms cast range, launch and executor routing.
]]
local function check_reviewed_skills(bridge: any)
    local skill_ids = {
        "OrcPowerStrike",
        "OrcIronPunch",
        "SpiritclawIronFist",
        "SpiritclawStunningFist",
        "SpiritclawForceBurst",
        "SpiritclawCripplingPalm",
        "WarhowlCrushingBlow",
        "WarhowlSkullbreaker",
        "WarhowlSweepingArc",
    }

    for index, skill_id in ipairs(skill_ids) do
        local started = assert(bridge:begin_cast(
            OWNER,
            TARGET,
            skill_id,
            110 + index
        ))
        check(
            started.SourceSkillId == PLANS[skill_id].SourceSkillId
                and last_preflight_range
                    == (PLANS[skill_id].CastRange or 40),
            skill_id .. " preserves exact source cast identity/range"
        )

        local launched = assert(bridge:launch_if_ready(
            OWNER,
            started.CastId,
            120 + index,
            500 + index
        ))
        local plan = PLANS[skill_id]
        check(
            launched.Applied
                and last_preflight_range
                    == (plan.EffectRange or 400)
                and last_execution.SkillId == skill_id
                and last_execution.SequenceId == 500 + index
                and last_execution.Kind == plan.ExecutionKind,
            skill_id .. " reaches the reviewed live physical executor"
        )

        if plan.ExecutionKind == "Stun" then
            check(
                launched.Application.StunApplied
                    and launched.Application.DurationSeconds == 9,
                skill_id .. " preserves the stun-bearing executor route"
            )
        elseif plan.ExecutionKind == "Charged" then
            check(
                launched.Application.RequiredCharges == 1
                    and launched.Application.RemainingCharges == 0
                    and launched.Application.SourceChargeDamageMultiplier
                        == 0.8,
                "Force Burst consumes one charge before exact damage scaling"
            )
        elseif plan.ExecutionKind == "Slow" then
            check(
                launched.Application.SlowApplied
                    and launched.Application.SpeedMultiplier == 0.7
                    and launched.Application.DurationSeconds == 120,
                "Crippling Palm preserves exact movement slow routing"
            )
        elseif plan.ExecutionKind == "Area" then
            check(
                launched.Application.SourceSkillRadius == 150
                    and launched.Application.TargetCount == 2,
                "Sweeping Arc preserves the exact 150 source radius"
            )
        else
            check(
                launched.Application.HealthDamage == 17,
                skill_id .. " preserves single-target damage routing"
            )
        end
    end
end

--[[
Checks private receipts and cleanup cannot leak between owners.

Args:
    bridge (any): Enabled physical bridge.

Returns:
    nil: Confirms cancellation and teardown semantics.
]]
local function check_cancellation(bridge: any)
    local started = assert(bridge:begin_cast(
        OWNER,
        TARGET,
        "OrcPowerStrike",
        200
    ))

    local cancelled = bridge:cancel_cast(
        OWNER,
        started.CastId
    )
    check(
        cancelled and cancelled_cast_id == started.CastId,
        "private physical receipt cancels through shared scheduler"
    )

    bridge:clear_owner(OWNER)
    local result, reason = bridge:launch_if_ready(
        OWNER,
        started.CastId,
        205,
        999
    )
    check(
        result == nil
            and reason == "C4PhysicalCastReceiptInvalid",
        "cleared physical receipt cannot be replayed"
    )
end

--[[
Runs the reviewed source physical-cast bridge regression.

Args:
    None.

Returns:
    nil: Prints bounded bridge coverage after all assertions pass.
]]
local function main()
    local bridge = Service.new(
        FakeScheduler,
        FakeExecutor,
        FakeCharges
    )

    check_gate(bridge)
    check_reviewed_skills(bridge)
    check_cancellation(bridge)

    local capability = bridge:capability()
    check(
        capability.ReviewedActiveSkillCount == 9
            and capability.SingleTargetPdam
            and capability.StunPdam
            and capability.ChargedPdam
            and capability.PhysicalMovementSlow
            and capability.TargetAreaPdam
            and not capability.StunPdamPending
            and not capability.TargetAreaPdamPending
            and not capability.ClientAuthority,
        "capability reports all nine reviewed Orc physical families"
    )

    print((
        "[C4 Physical Cast] PASS: %d assertions reviewed=9"
    ):format(checks))
end

main()
