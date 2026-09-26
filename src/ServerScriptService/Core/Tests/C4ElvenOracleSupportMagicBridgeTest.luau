--!strict
-- Lifebinder friendly support-magic bridge routing regression.

local ServerScriptService = game:GetService("ServerScriptService")

local SupportMagic = require(
    ServerScriptService.Core.Services.C4SourceSupportMagicCastService
)

local checks = 0
local next_cast_id = 300
local pending_skill = nil
local last_preflight_range = nil
local last_execution = nil

local caster = {UserId = 730101}
local target = {UserId = 730102}

local SOURCE = table.freeze({
    LifebinderManaRecharge = table.freeze({
        SourceSkillId = 1013,
        SourceRank = 2,
        CreativeRank = 2,
        CastRange = 400,
        EffectRange = 900,
    }),
    LifebinderAgility = table.freeze({
        SourceSkillId = 1087,
        SourceRank = 1,
        CreativeRank = 1,
        CastRange = 400,
        EffectRange = 900,
    }),
    LifebinderWindstep = table.freeze({
        SourceSkillId = 1204,
        SourceRank = 2,
        CreativeRank = 2,
        CastRange = 400,
        EffectRange = 900,
    }),
})

local FakeScheduler = {}

--[[
Begins one deterministic Lifebinder support schedule.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable caster.
    skill_id (string): Reviewed Lifebinder support skill.
    supplied_now (number?): Deterministic start time.

Returns:
    (any?, string?): Fake source schedule.
]]
function FakeScheduler.begin_cast(
    _self: any,
    _owner: any,
    skill_id: string,
    supplied_now: number?
): (any?, string?)
    local plan = assert(SOURCE[skill_id])
    next_cast_id += 1
    pending_skill = skill_id
    local now = supplied_now or 100

    return {
        CastId = next_cast_id,
        CreativeSkillId = skill_id,
        CreativeRank = plan.CreativeRank,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = plan.SourceRank,
        StartedAt = now,
        InterruptAt = now + 1,
        LaunchAt = now + 2,
        FinalizerAt = now + 2,
        ReuseReadyAt = now + 6,
        SourceCastRange = plan.CastRange,
        SourceEffectRange = plan.EffectRange,
    }, nil
end

--[[
Cancels one fake support schedule.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable caster.
    _cast_id (number): Disposable receipt.

Returns:
    (boolean, string?): Successful cancellation.
]]
function FakeScheduler.cancel_cast(
    _self: any,
    _owner: any,
    _cast_id: number
): (boolean, string?)
    pending_skill = nil
    return true, nil
end

--[[
Launches one deterministic support schedule.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable caster.
    cast_id (number): Private cast receipt.
    _supplied_now (number?): Deterministic launch time.

Returns:
    (any?, string?): Fake scheduler launch.
]]
function FakeScheduler.launch_if_ready(
    _self: any,
    _owner: any,
    cast_id: number,
    _supplied_now: number?
): (any?, string?)
    local skill_id = assert(pending_skill)
    pending_skill = nil
    local plan = assert(SOURCE[skill_id])

    return {
        CastId = cast_id,
        CreativeSkillId = skill_id,
        CreativeRank = plan.CreativeRank,
        SourceSkillId = plan.SourceSkillId,
        SourceRank = plan.SourceRank,
        SourceCastRange = plan.CastRange,
        SourceEffectRange = plan.EffectRange,
        ReadyForSourceEffectExecution = true,
    }, nil
end

--[[
Clears fake scheduler state.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable caster.

Returns:
    nil: Clears only test state.
]]
function FakeScheduler.clear_owner(
    _self: any,
    _owner: any
)
    pending_skill = nil
end

local FakeExecutor = {}

--[[
Preflights one normal friendly target.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _target (any): Disposable target.
    source_range (number?): Reviewed source range.

Returns:
    (boolean, string?): Always-ready result.
]]
function FakeExecutor.can_support_skill_player(
    _self: any,
    _caster: any,
    _target: any,
    source_range: number?
): (boolean, string?)
    last_preflight_range = source_range
    return true, nil
end

--[[
Provides constructor compatibility for unused party healing.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _source_radius (number): Reviewed party radius.

Returns:
    (boolean, string?): Always-ready result.
]]
function FakeExecutor.can_party_heal_skill(
    _self: any,
    _caster: any,
    _source_radius: number
): (boolean, string?)
    return true, nil
end

--[[
Provides constructor compatibility for unused resurrection.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _target (any): Disposable target.
    _source_range (number): Reviewed source range.

Returns:
    (boolean, string?): Always-ready result.
]]
function FakeExecutor.can_resurrection_skill_player(
    _self: any,
    _caster: any,
    _target: any,
    _source_range: number
): (boolean, string?)
    return true, nil
end

--[[
Returns compatibility evidence for an unused target heal.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _target (any): Disposable target.
    skill_id (string): Creative skill identifier.
    _rank (number): Creative rank.

Returns:
    (any?, string?): Fake heal evidence.
]]
function FakeExecutor.heal_skill_target(
    _self: any,
    _caster: any,
    _target: any,
    skill_id: string,
    _rank: number
): (any?, string?)
    last_execution = skill_id
    return {Applied = true}, nil
end

--[[
Records exact Lifebinder mana-recharge routing.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _target (any): Disposable target.
    skill_id (string): Reviewed recharge skill.
    rank (number): Creative rank.

Returns:
    (any?, string?): Fake recharge evidence.
]]
function FakeExecutor.mana_recharge_skill_target(
    _self: any,
    _caster: any,
    _target: any,
    skill_id: string,
    rank: number
): (any?, string?)
    last_execution = skill_id
    return {
        Applied = true,
        EffectiveRecharge = 52,
        SourceSkillId = 1013,
        SourceRank = rank,
    }, nil
end

--[[
Records exact Lifebinder timed-buff routing.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _target (any): Disposable target.
    skill_id (string): Reviewed support buff.
    rank (number): Creative rank.

Returns:
    (any?, string?): Fake timed-buff evidence.
]]
function FakeExecutor.support_buff_skill_target(
    _self: any,
    _caster: any,
    _target: any,
    skill_id: string,
    rank: number
): (any?, string?)
    last_execution = skill_id
    return {
        Applied = true,
        SourceRank = rank,
        DurationSeconds = 1200,
    }, nil
end

--[[
Provides constructor compatibility for party healing.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _skill_id (string): Creative skill identifier.
    _rank (number): Creative rank.

Returns:
    (any?, string?): Fake party-heal evidence.
]]
function FakeExecutor.party_heal_skill(
    _self: any,
    _caster: any,
    _skill_id: string,
    _rank: number
): (any?, string?)
    return {Applied = true}, nil
end

--[[
Provides constructor compatibility for resurrection.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _target (any): Disposable target.
    _skill_id (string): Creative skill identifier.
    _rank (number): Creative rank.

Returns:
    (any?, string?): Fake resurrection evidence.
]]
function FakeExecutor.resurrection_skill_player(
    _self: any,
    _caster: any,
    _target: any,
    _skill_id: string,
    _rank: number
): (any?, string?)
    return {Applied = true}, nil
end

--[[
Counts one Lifebinder support bridge assertion.

Args:
    condition (boolean): Observed routing state.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[Lifebinder Support Magic] " .. label
    )
end

--[[
Casts one reviewed support skill through the fake schedule.

Args:
    bridge (any): Enabled support bridge.
    skill_id (string): Reviewed Lifebinder support skill.
    start_time (number): Deterministic start time.

Returns:
    any: Applied bridge evidence.
]]
local function cast(
    bridge: any,
    skill_id: string,
    start_time: number
): any
    local started = assert(bridge:begin_cast(
        caster,
        target,
        skill_id,
        start_time
    ))
    check(
        last_preflight_range == 400,
        skill_id .. " keeps exact source cast range"
    )

    local launched = assert(bridge:launch_if_ready(
        caster,
        started.CastId,
        start_time + 2
    ))
    check(
        last_preflight_range == 900,
        skill_id .. " keeps exact source effect range"
    )
    return launched
end

--[[
Runs Lifebinder friendly support routing acceptance.

Args:
    None.

Returns:
    nil: Prints bounded support evidence.
]]
local function main()
    local bridge = SupportMagic.new(
        FakeScheduler,
        FakeExecutor
    )
    bridge:set_enabled(true)

    local recharge = cast(
        bridge,
        "LifebinderManaRecharge",
        100
    )
    check(
        last_execution == "LifebinderManaRecharge"
            and recharge.Application.EffectiveRecharge == 52,
        "Mana Recharge reaches exact recharge executor"
    )

    local agility = cast(
        bridge,
        "LifebinderAgility",
        200
    )
    check(
        last_execution == "LifebinderAgility"
            and agility.Application.DurationSeconds == 1200,
        "Agility reaches timed support-buff executor"
    )

    local windstep = cast(
        bridge,
        "LifebinderWindstep",
        300
    )
    check(
        last_execution == "LifebinderWindstep"
            and windstep.Application.DurationSeconds == 1200,
        "Windstep reuses timed support-buff executor"
    )

    print((
        "[Lifebinder Support Magic] PASS: %d assertions"
    ):format(checks))
end

main()
