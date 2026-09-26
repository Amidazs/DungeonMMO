--!strict
-- Scheduled Palus Knight / Duskguard active-skill bridge regression.

local ServerScriptService = game:GetService("ServerScriptService")

local DuskguardCast = require(
    ServerScriptService.Core.Services.C4SourceDuskguardCastService
)

local checks = 0
local next_cast_id = 10
local pending_skill = nil
local last_kind = nil
local last_rank = nil
local last_range = nil

local owner = {
    UserId = 938250,
}
local enemy = {}

local REVIEW = {
    DuskguardUmbralSiphon = {70, 8, 600, 1100},
    DuskguardDefenseAura = {91, 1, nil, nil},
    DuskguardLastStand = {110, 1, nil, nil},
    DuskguardVenomHex = {129, 1, 600, 1100},
    DuskguardMindRend = {2, 2, 600, 1100},
    DuskguardChallenge = {28, 6, 400, 900},
    DuskguardArrowWard = {112, 1, nil, nil},
    DuskguardCrimsonSting = {223, 6, 40, 400},
    DuskguardAttackAura = {77, 1, nil, nil},
}

local FakeScheduler = {}

--[[
Begins one deterministic source cast.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable owner.
    skill_id (string): Creative skill identity.
    supplied_now (number?): Deterministic start time.

Returns:
    (any?, string?): Fake source scheduler start.
]]
function FakeScheduler.begin_cast(
    _self: any,
    _owner: any,
    skill_id: string,
    supplied_now: number?
): (any?, string?)
    local review = assert(REVIEW[skill_id])
    next_cast_id += 1
    pending_skill = skill_id
    local now = supplied_now or 100

    return {
        CastId = next_cast_id,
        CreativeSkillId = skill_id,
        CreativeRank = review[2],
        SourceSkillId = review[1],
        SourceRank = review[2],
        SourceCastRange = review[3],
        SourceEffectRange = review[4],
        StartedAt = now,
        InterruptAt = now + 0.5,
        LaunchAt = now + 1,
        FinalizerAt = now + 1,
        ReuseReadyAt = now + 4,
    }, nil
end

--[[
Cancels one fake cast.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable owner.
    _cast_id (number): Disposable cast receipt.

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
Launches one deterministic ready cast.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable owner.
    cast_id (number): Cast receipt.
    _now (number?): Deterministic launch time.

Returns:
    (any?, string?): Fake source launch.
]]
function FakeScheduler.launch_if_ready(
    _self: any,
    _owner: any,
    cast_id: number,
    _now: number?
): (any?, string?)
    local skill_id = assert(pending_skill)
    local review = assert(REVIEW[skill_id])
    pending_skill = nil

    return {
        CastId = cast_id,
        CreativeSkillId = skill_id,
        CreativeRank = review[2],
        SourceSkillId = review[1],
        SourceRank = review[2],
        ReadyForSourceEffectExecution = true,
    }, nil
end

--[[
Clears fake scheduler state.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable owner.

Returns:
    nil: Clears test state.
]]
function FakeScheduler.clear_owner(
    _self: any,
    _owner: any
)
    pending_skill = nil
end

local FakeExecutor = {}

--[[
Records hostile cast/effect range preflight.

Args:
    _self (any): Fake executor receiver.
    _owner (any): Disposable caster.
    target (any): Expected private enemy.
    source_range (number?): Reviewed source range.

Returns:
    (boolean, string?): Readiness.
]]
function FakeExecutor.can_magic_skill_npc(
    _self: any,
    _owner: any,
    target: any,
    source_range: number?
): (boolean, string?)
    assert(target == enemy)
    last_range = source_range
    return true, nil
end

local function applied(
    kind: string,
    rank: number
): any
    last_kind = kind
    last_rank = rank
    return {Applied = true, Kind = kind}
end

function FakeExecutor.magic_drain_skill_npc(
    _self: any, _owner: any, _target: any,
    _skill_id: string, rank: number, _sequence: number?
): (any?, string?)
    return applied("Drain", rank), nil
end

function FakeExecutor.status_skill_npc(
    _self: any, _owner: any, _target: any,
    _skill_id: string, rank: number, _sequence: number?
): (any?, string?)
    return applied("Periodic", rank), nil
end

function FakeExecutor.confusion_skill_npc(
    _self: any, _owner: any, _target: any,
    _skill_id: string, rank: number, _sequence: number?
): (any?, string?)
    return applied("Confusion", rank), nil
end

function FakeExecutor.aggro_skill_npc(
    _self: any, _owner: any, _target: any,
    _skill_id: string, rank: number, _sequence: number?
): (any?, string?)
    return applied("Aggression", rank), nil
end

function FakeExecutor.physical_status_skill_npc(
    _self: any, _owner: any, _target: any,
    _skill_id: string, rank: number, _sequence: number?
): (any?, string?)
    return applied("PhysicalStatus", rank), nil
end

function FakeExecutor.self_buff_skill(
    _self: any,
    _owner: any,
    _skill_id: string,
    rank: number
): (any?, string?)
    return applied("SelfBuff", rank), nil
end

--[[
Counts one cast-bridge assertion.

Args:
    condition (boolean): Observed bridge state.
    label (string): Failure description.

Returns:
    nil: Raises on mismatch.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Duskguard Cast] " .. label)
end

--[[
Executes one reviewed Duskguard family through the bridge.

Args:
    bridge (any): Enabled Duskguard cast bridge.
    skill_id (string): Creative skill identity.
    expected_kind (string): Expected executor family.
    expected_range (number?): Launch effect range.

Returns:
    nil: Confirms routing and private target binding.
]]
local function check_skill(
    bridge: any,
    skill_id: string,
    expected_kind: string,
    expected_range: number?
)
    last_kind = nil
    last_rank = nil
    last_range = nil

    local review = assert(REVIEW[skill_id])
    local target = if expected_kind == "SelfBuff" then nil else enemy
    local started = assert(bridge:begin_cast(
        owner,
        target,
        skill_id,
        100
    ))
    local launched = assert(bridge:launch_if_ready(
        owner,
        started.CastId,
        101,
        700
    ))

    check(
        launched.Applied
            and last_kind == expected_kind
            and last_rank == review[2]
            and (
                expected_range == nil
                or last_range == expected_range
            ),
        skill_id .. " reaches its exact reviewed executor"
    )
end

--[[
Runs every Duskguard active family through the private scheduler bridge.

Args:
    None.

Returns:
    nil: Prints focused bridge evidence.
]]
local function main()
    local bridge = DuskguardCast.new(
        FakeScheduler,
        FakeExecutor
    )

    local disabled, disabled_reason = bridge:begin_cast(
        owner,
        enemy,
        "DuskguardUmbralSiphon",
        10
    )
    check(
        disabled == nil
            and disabled_reason == "C4DuskguardCastDisabled",
        "bridge starts disabled"
    )

    bridge:set_enabled(true)

    check_skill(
        bridge,
        "DuskguardUmbralSiphon",
        "Drain",
        1100
    )
    check_skill(
        bridge,
        "DuskguardVenomHex",
        "Periodic",
        1100
    )
    check_skill(
        bridge,
        "DuskguardMindRend",
        "Confusion",
        1100
    )
    check_skill(
        bridge,
        "DuskguardChallenge",
        "Aggression",
        900
    )
    check_skill(
        bridge,
        "DuskguardCrimsonSting",
        "PhysicalStatus",
        400
    )
    check_skill(
        bridge,
        "DuskguardDefenseAura",
        "SelfBuff",
        nil
    )
    check_skill(
        bridge,
        "DuskguardLastStand",
        "SelfBuff",
        nil
    )
    check_skill(
        bridge,
        "DuskguardArrowWard",
        "SelfBuff",
        nil
    )
    check_skill(
        bridge,
        "DuskguardAttackAura",
        "SelfBuff",
        nil
    )

    local capability = bridge:capability()
    check(
        capability.ReviewedActiveSkillCount == 9
            and capability.Drain
            and capability.Poison
            and capability.Confusion
            and capability.Aggression
            and capability.PhysicalBleed
            and capability.SelfBuff,
        "capability exposes all nine active Duskguard families"
    )

    print((
        "[C4 Duskguard Cast] PASS: %d assertions"
    ):format(checks))
end

main()
