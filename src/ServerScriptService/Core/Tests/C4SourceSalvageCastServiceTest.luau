--!strict
-- Scheduled source Spoil/Sweep bridge regression.

local ServerScriptService = game:GetService("ServerScriptService")

local Service = require(
    ServerScriptService.Core.Services.C4SourceSalvageCastService
)

local OWNER = table.freeze({UserId = 956220})
local TARGET = table.freeze({Name = "TEMP_SalvageTarget"})
local AREA_A = table.freeze({Name = "TEMP_AreaA"})
local AREA_B = table.freeze({Name = "TEMP_AreaB"})

local PLANS = table.freeze({
    DwarfSalvageMark = table.freeze({
        SourceSkillId = 254,
        SourceRank = 1,
    }),
    DeepclaimerSalvageMark = table.freeze({
        SourceSkillId = 254,
        SourceRank = 2,
    }),
    DeepclaimerSalvageFestival = table.freeze({
        SourceSkillId = 302,
        SourceRank = 1,
    }),
    DwarfSalvageClaim = table.freeze({
        SourceSkillId = 42,
        SourceRank = 1,
    }),
})

local checks = 0
local next_cast_id = 900
local pending = {}
local target_dead = false
local marks = {}
local claims = 0
local last_area_radius = nil

local FakeScheduler = {}

--[[
Begins one deterministic source salvage schedule.

Args:
    owner (any): Expected disposable owner.
    skill_id (string): Reviewed creative salvage skill.
    supplied_now (number?): Optional deterministic time.

Returns:
    (any?, string?): Source-shaped cast start evidence.
]]
function FakeScheduler:begin_cast(
    owner: any,
    skill_id: string,
    supplied_now: number?
): (any?, string?)
    local plan = PLANS[skill_id]
    if owner ~= OWNER or not plan then
        return nil, "SalvageTestPlanUnavailable"
    end

    next_cast_id += 1
    pending[owner] = {
        CastId = next_cast_id,
        SkillId = skill_id,
    }
    local now = supplied_now or 100

    return {
        CastId = next_cast_id,
        CreativeSkillId = skill_id,
        CreativeRank = 1,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = plan.SourceRank,
        StartedAt = now,
        InterruptAt = now + 0.5,
        LaunchAt = now + 1,
        FinalizerAt = now + 1.1,
        ReuseReadyAt = now + 11,
    }, nil
end

--[[
Cancels one deterministic source salvage schedule.

Args:
    owner (any): Expected disposable owner.
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
        return false, "SalvageTestReceiptInvalid"
    end

    pending[owner] = nil
    return true, nil
end

--[[
Launches one deterministic source salvage schedule.

Args:
    owner (any): Expected disposable owner.
    cast_id (number): Private cast receipt.
    _supplied_now (number?): Optional deterministic time.

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
        return nil, "SalvageTestReceiptInvalid"
    end

    pending[owner] = nil
    local plan = assert(PLANS[record.SkillId])

    return {
        CastId = cast_id,
        CreativeSkillId = record.SkillId,
        CreativeRank = 1,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = plan.SourceRank,
        ReadyForSourceEffectExecution = true,
    }, nil
end

--[[
Clears deterministic scheduler state.

Args:
    owner (any): Disposable owner.

Returns:
    nil: Removes pending fake cast state.
]]
function FakeScheduler:clear_owner(owner: any)
    pending[owner] = nil
end

local FakeSalvage = {}

--[[
Checks deterministic target state for mark operations.

Args:
    _self (any): Fake receiver.
    _owner (any): Expected owner.
    _target (any): Bound target.

Returns:
    (boolean, string?): Mark readiness.
]]
function FakeSalvage.can_mark(
    _self: any,
    _owner: any,
    _target: any
): (boolean, string?)
    if target_dead then
        return false, "C4SalvageTargetNotLivingEnemy"
    end
    return true, nil
end

--[[
Records one fake source Spoil mark.

Args:
    _self (any): Fake receiver.
    _owner (any): Expected owner.
    target (any): Marked target.
    source_skill_id (number): Exact source skill.
    source_rank (number): Exact source rank.

Returns:
    (any?, string?): Applied fake mark evidence.
]]
function FakeSalvage.mark(
    _self: any,
    _owner: any,
    target: any,
    source_skill_id: number,
    source_rank: number
): (any?, string?)
    table.insert(marks, {
        Target = target,
        SourceSkillId = source_skill_id,
        SourceRank = source_rank,
    })
    return {Applied = true}, nil
end

--[[
Checks deterministic target state for Sweep.

Args:
    _self (any): Fake receiver.
    _owner (any): Expected owner.
    _target (any): Bound target.

Returns:
    (boolean, string?): Claim readiness.
]]
function FakeSalvage.can_claim(
    _self: any,
    _owner: any,
    _target: any
): (boolean, string?)
    if not target_dead then
        return false, "C4SalvageTargetNotDeadEnemy"
    end
    return true, nil
end

--[[
Records one fake Sweep claim.

Args:
    _self (any): Fake receiver.
    _owner (any): Expected owner.
    _target (any): Bound corpse.

Returns:
    (any?, string?): Applied fake claim evidence.
]]
function FakeSalvage.claim(
    _self: any,
    _owner: any,
    _target: any
): (any?, string?)
    claims += 1
    return {
        Applied = true,
        ItemId = "dense_mineral_shard",
        Quantity = 1,
    }, nil
end

--[[
Resolves deterministic server-only Festival targets.

Args:
    _owner (any): Expected owner.
    _target (any): Bound area anchor.
    source_radius (number): Exact C4 source radius.

Returns:
    {any}: Two deterministic enemy targets.
]]
local function area_resolver(
    _owner: any,
    _target: any,
    source_radius: number
): {any}
    last_area_radius = source_radius
    return {AREA_A, AREA_B}
end

--[[
Counts one source salvage bridge assertion.

Args:
    valid (boolean): Expected scheduled bridge state.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the assertion count or raises.
]]
local function check(valid: boolean, label: string)
    checks += 1
    assert(valid, "[C4 Salvage Cast] " .. label)
end

--[[
Runs single Spoil, Festival and Sweep bridge acceptance.

Args:
    None.

Returns:
    nil: Prints bounded source salvage coverage.
]]
local function main()
    local bridge = Service.new(
        FakeScheduler,
        FakeSalvage,
        area_resolver
    )

    local disabled, disabled_reason = bridge:begin_cast(
        OWNER,
        TARGET,
        "DwarfSalvageMark",
        100
    )
    check(
        disabled == nil
            and disabled_reason == "C4SalvageCastDisabled",
        "source salvage bridge starts disabled"
    )

    bridge:set_enabled(true)

    local mark_start = assert(bridge:begin_cast(
        OWNER,
        TARGET,
        "DeepclaimerSalvageMark",
        110
    ))
    local marked = assert(bridge:launch_if_ready(
        OWNER,
        mark_start.CastId,
        111
    ))
    check(
        marked.Applied
            and marks[1].SourceSkillId == 254
            and marks[1].SourceRank == 2,
        "Deepclaimer Spoil rank continues exact source rank 2"
    )

    local festival_start = assert(bridge:begin_cast(
        OWNER,
        TARGET,
        "DeepclaimerSalvageFestival",
        120
    ))
    local festival = assert(bridge:launch_if_ready(
        OWNER,
        festival_start.CastId,
        121
    ))
    check(
        festival.Applied
            and festival.Application.MarkedCount == 2
            and festival.Application.SourceRadius == 200
            and last_area_radius == 200,
        "Spoil Festival preserves exact source radius 200"
    )

    target_dead = true
    local sweep_start = assert(bridge:begin_cast(
        OWNER,
        TARGET,
        "DwarfSalvageClaim",
        130
    ))
    local swept = assert(bridge:launch_if_ready(
        OWNER,
        sweep_start.CastId,
        131
    ))
    check(
        swept.Applied
            and claims == 1
            and swept.Application.ItemId == "dense_mineral_shard",
        "inherited Sweep reaches server salvage claim authority"
    )

    local capability = bridge:capability()
    check(
        capability.ReviewedSkillCount == 4
            and capability.SingleTargetSpoil
            and capability.SweepOwnedCorpse
            and capability.SpoilFestivalReviewed
            and capability.SpoilFestivalAreaResolverBound
            and not capability.ClientAuthority,
        "capability reports all reviewed Dwarf salvage families"
    )

    print(
        ("[C4 Salvage Cast] PASS: %d assertions")
            :format(checks)
    )
end

main()
