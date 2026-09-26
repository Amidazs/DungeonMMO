--!strict
-- Lifebinder hostile direct-magic bridge routing regression.

local ServerScriptService = game:GetService("ServerScriptService")

local DirectMagic = require(
    ServerScriptService.Core.Services.C4SourceDirectMagicCastService
)

local checks = 0
local next_cast_id = 200
local pending_skill = nil
local last_preflight = nil
local last_execution = nil

local caster = {UserId = 730001}
local enemy = {}

local SOURCE = table.freeze({
    LifebinderExorcism = table.freeze({
        SourceSkillId = 1031,
        SourceRank = 6,
        CreativeRank = 6,
        CastRange = 400,
        EffectRange = 900,
    }),
    LifebinderSlumber = table.freeze({
        SourceSkillId = 1069,
        SourceRank = 6,
        CreativeRank = 6,
        CastRange = 600,
        EffectRange = 1100,
    }),
    LifebinderRootbind = table.freeze({
        SourceSkillId = 1201,
        SourceRank = 6,
        CreativeRank = 6,
        CastRange = 600,
        EffectRange = 1100,
    }),
    LifebinderWindShackle = table.freeze({
        SourceSkillId = 1206,
        SourceRank = 4,
        CreativeRank = 3,
        CastRange = 600,
        EffectRange = 1100,
    }),
})

local FakeScheduler = {}

--[[
Begins one deterministic Lifebinder hostile source schedule.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable caster.
    skill_id (string): Reviewed Lifebinder hostile skill.
    supplied_now (number?): Deterministic start time.

Returns:
    (any?, string?): Fake source schedule evidence.
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
Cancels one fake hostile schedule.

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
Launches one deterministic hostile schedule.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable caster.
    cast_id (number): Private cast receipt.
    _supplied_now (number?): Deterministic launch time.

Returns:
    (any?, string?): Fake scheduler launch evidence.
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
    nil: Clears pending test state.
]]
function FakeScheduler.clear_owner(
    _self: any,
    _owner: any
)
    pending_skill = nil
end

local FakeExecutor = {}

--[[
Records normal NPC preflight.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _enemy (any): Disposable enemy.
    source_range (number?): Reviewed source range.

Returns:
    (boolean, string?): Always-ready result.
]]
function FakeExecutor.can_magic_skill_npc(
    _self: any,
    _caster: any,
    _enemy: any,
    source_range: number?
): (boolean, string?)
    last_preflight = {
        Kind = "Normal",
        Range = source_range,
    }
    return true, nil
end

--[[
Records undead-only preflight.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _enemy (any): Disposable enemy.
    source_range (number?): Reviewed source range.

Returns:
    (boolean, string?): Always-ready result.
]]
function FakeExecutor.can_undead_magic_skill_npc(
    _self: any,
    _caster: any,
    _enemy: any,
    source_range: number?
): (boolean, string?)
    last_preflight = {
        Kind = "Undead",
        Range = source_range,
    }
    return true, nil
end

--[[
Returns a generic compatibility result for unused direct families.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _enemy (any): Disposable enemy.
    _skill_id (string): Creative skill identifier.
    _rank (number): Creative rank.
    _extra (any?): Radius or sequence.
    _sequence_id (number?): Optional sequence.

Returns:
    (any?, string?): Successful compatibility result.
]]
local function compatibility_result(
    _self: any,
    _caster: any,
    _enemy: any,
    _skill_id: string,
    _rank: number,
    _extra: any?,
    _sequence_id: number?
): (any?, string?)
    return {Applied = true}, nil
end

FakeExecutor.magic_skill_npc = compatibility_result
FakeExecutor.magic_slow_skill_npc = compatibility_result
FakeExecutor.magic_area_skill_npc = compatibility_result
FakeExecutor.magic_drain_skill_npc = compatibility_result
FakeExecutor.elemental_vulnerability_skill_npc =
    compatibility_result
FakeExecutor.physical_attack_weakening_skill_npc =
    compatibility_result

--[[
Records exact Sleep execution.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _enemy (any): Disposable enemy.
    skill_id (string): Reviewed Sleep skill.
    _rank (number): Creative rank.
    _sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Fake landed Sleep.
]]
function FakeExecutor.sleep_skill_npc(
    _self: any,
    _caster: any,
    _enemy: any,
    skill_id: string,
    _rank: number,
    _sequence_id: number?
): (any?, string?)
    last_execution = skill_id
    return {
        Applied = true,
        SleepApplied = true,
        Landed = true,
    }, nil
end

--[[
Records exact undead execution.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _enemy (any): Disposable enemy.
    skill_id (string): Reviewed undead spell.
    _rank (number): Creative rank.
    _sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Fake undead damage.
]]
function FakeExecutor.magic_undead_skill_npc(
    _self: any,
    _caster: any,
    _enemy: any,
    skill_id: string,
    _rank: number,
    _sequence_id: number?
): (any?, string?)
    last_execution = skill_id
    return {Applied = true, HealthDamage = 30}, nil
end

--[[
Records exact Root execution.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _enemy (any): Disposable enemy.
    skill_id (string): Reviewed Root skill.
    _rank (number): Creative rank.
    _sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Fake landed Root.
]]
function FakeExecutor.root_skill_npc(
    _self: any,
    _caster: any,
    _enemy: any,
    skill_id: string,
    _rank: number,
    _sequence_id: number?
): (any?, string?)
    last_execution = skill_id
    return {
        Applied = true,
        RootApplied = true,
        Landed = true,
    }, nil
end

--[[
Records exact Wind Shackle execution.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _enemy (any): Disposable enemy.
    skill_id (string): Reviewed Wind Shackle skill.
    rank (number): Creative rank.
    sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Fake landed cadence weakening.
]]
function FakeExecutor.physical_attack_rate_weakening_skill_npc(
    _self: any,
    _caster: any,
    _enemy: any,
    skill_id: string,
    rank: number,
    sequence_id: number?
): (any?, string?)
    last_execution = skill_id
    return {
        Applied = true,
        WeakeningApplied = true,
        Landed = true,
        PhysicalAttackSpeedMultiplier = 0.8,
        RateReductionFraction = 0.2,
        CreativeRank = rank,
        SequenceId = sequence_id,
    }, nil
end

--[[
Counts one Lifebinder hostile bridge assertion.

Args:
    condition (boolean): Observed server routing.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[Lifebinder Direct Magic] " .. label
    )
end

--[[
Casts one reviewed hostile skill through the fake schedule.

Args:
    bridge (any): Enabled direct-magic bridge.
    skill_id (string): Reviewed Lifebinder skill.
    start_time (number): Deterministic start timestamp.

Returns:
    any: Applied fake executor result.
]]
local function cast(
    bridge: any,
    skill_id: string,
    start_time: number
): any
    local started = assert(bridge:begin_cast(
        caster,
        enemy,
        skill_id,
        start_time
    ))
    return assert(bridge:launch_if_ready(
        caster,
        started.CastId,
        start_time + 2,
        4400 + checks
    ))
end

--[[
Runs Lifebinder hostile source-bridge acceptance.

Args:
    None.

Returns:
    nil: Prints bounded routing evidence.
]]
local function main()
    local bridge = DirectMagic.new(
        FakeScheduler,
        FakeExecutor
    )
    bridge:set_enabled(true)

    cast(bridge, "LifebinderExorcism", 100)
    check(
        last_preflight.Kind == "Undead"
            and last_preflight.Range == 900
            and last_execution == "LifebinderExorcism",
        "Exorcism keeps undead-only launch revalidation"
    )

    cast(bridge, "LifebinderSlumber", 200)
    check(
        last_preflight.Kind == "Normal"
            and last_execution == "LifebinderSlumber",
        "Slumber reaches shared C4 Sleep executor"
    )

    cast(bridge, "LifebinderRootbind", 300)
    check(
        last_execution == "LifebinderRootbind",
        "Rootbind reaches shared C4 Root executor"
    )

    local shackle = cast(
        bridge,
        "LifebinderWindShackle",
        400
    )
    check(
        last_execution == "LifebinderWindShackle"
            and shackle.Application
                .PhysicalAttackSpeedMultiplier == 0.8
            and shackle.Application
                .RateReductionFraction == 0.2,
        "Wind Shackle reaches exact attack-rate weakening executor"
    )

    print((
        "[Lifebinder Direct Magic] PASS: %d assertions"
    ):format(checks))
end

main()
