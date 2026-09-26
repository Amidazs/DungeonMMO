--!strict
-- Human Cleric hostile direct-magic bridge routing regression.

local ServerScriptService = game:GetService("ServerScriptService")

local DirectMagic = require(
    ServerScriptService.Core.Services.C4SourceDirectMagicCastService
)

local checks = 0
local next_cast_id = 100
local pending_skill = nil
local last_preflight = nil
local last_execution = nil

local caster = {UserId = 720001}
local enemy = {}

local SOURCE = table.freeze({
    DawnkeeperExorcism = {
        SourceSkillId = 1031,
        SourceRank = 6,
        CastRange = 400,
        EffectRange = 900,
    },
    DawnkeeperSlumber = {
        SourceSkillId = 1069,
        SourceRank = 6,
        CastRange = 600,
        EffectRange = 1100,
    },
    DawnkeeperRootbind = {
        SourceSkillId = 1201,
        SourceRank = 12,
        CastRange = 600,
        EffectRange = 1100,
    },
})

local FakeScheduler = {}

--[[
Begins one deterministic Cleric hostile source schedule.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable caster.
    skill_id (string): Reviewed Cleric hostile skill.
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
        CreativeRank = 6,
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
        CreativeRank = 6,
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
Records normal-NPC preflight.

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
Records undead-only preflight separately from generic NPC magic.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _enemy (any): Disposable enemy.
    source_range (number?): Reviewed source range.

Returns:
    (boolean, string?): Always-ready undead result.
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
Returns one generic magic result for constructor compatibility.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _enemy (any): Disposable enemy.
    _skill_id (string): Creative skill ID.
    _rank (number): Creative rank.
    _sequence_id (number?): Disposable sequence.

Returns:
    (any?, string?): Successful fake result.
]]
function FakeExecutor.magic_skill_npc(
    _self: any,
    _caster: any,
    _enemy: any,
    _skill_id: string,
    _rank: number,
    _sequence_id: number?
): (any?, string?)
    return {Applied = true}, nil
end

--[[
Returns compatibility results for unused Wizard execution families.

Args:
    _self (any): Fake executor receiver.
    _caster (any): Disposable caster.
    _enemy (any): Disposable enemy.
    _skill_id (string): Creative skill ID.
    _rank (number): Creative rank.
    _extra (any?): Source radius or sequence.
    _sequence_id (number?): Optional sequence.

Returns:
    (any?, string?): Successful fake result.
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
Records exact undead magic execution.

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
Counts one hostile Cleric bridge assertion.

Args:
    condition (boolean): Observed server routing.
    label (string): Failure diagnosis.

Returns:
    nil: Raises on mismatch.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[Human Cleric Direct Magic] " .. label)
end

--[[
Runs Exorcism, Slumber and Rootbind bridge acceptance.

Args:
    None.

Returns:
    nil: Prints bounded hostile Cleric routing evidence.
]]
local function main()
    local bridge = DirectMagic.new(
        FakeScheduler,
        FakeExecutor
    )
    bridge:set_enabled(true)

    local exorcism = assert(bridge:begin_cast(
        caster,
        enemy,
        "DawnkeeperExorcism",
        100
    ))
    check(
        last_preflight.Kind == "Undead"
            and last_preflight.Range == 400,
        "Exorcism requires undead preflight before initial MP"
    )
    assert(bridge:launch_if_ready(
        caster,
        exorcism.CastId,
        102
    ))
    check(
        last_preflight.Kind == "Undead"
            and last_preflight.Range == 900
            and last_execution == "DawnkeeperExorcism",
        "Exorcism rechecks undead effect range before source damage"
    )

    local slumber = assert(bridge:begin_cast(
        caster,
        enemy,
        "DawnkeeperSlumber",
        200
    ))
    assert(bridge:launch_if_ready(
        caster,
        slumber.CastId,
        202
    ))
    check(
        last_preflight.Kind == "Normal"
            and last_execution == "DawnkeeperSlumber",
        "Cleric Slumber reaches shared C4 Sleep executor"
    )

    local rootbind = assert(bridge:begin_cast(
        caster,
        enemy,
        "DawnkeeperRootbind",
        300
    ))
    assert(bridge:launch_if_ready(
        caster,
        rootbind.CastId,
        302
    ))
    check(
        last_execution == "DawnkeeperRootbind",
        "Rootbind reaches shared C4 Root executor"
    )

    print((
        "[Human Cleric Direct Magic] PASS: %d assertions"
    ):format(checks))
end

main()
