--!strict
-- Scheduled Dark Elf Assassin / Veilblade active-skill bridge regression.

local ServerScriptService = game:GetService("ServerScriptService")

local VeilbladeCast = require(
    ServerScriptService.Core.Services.C4SourceVeilbladeCastService
)

local checks = 0
local next_cast_id = 30
local pending_skill = nil
local last_kind = nil
local last_rank = nil
local last_range = nil

local owner = {
    UserId = 938260,
}
local enemy = {}

local REVIEW = {
    VeilbladeUmbralSiphon = {70, 8, 600, 1100},
    VeilbladeDefenseAura = {91, 1, nil, nil},
    VeilbladeVenomHex = {129, 1, 600, 1100},
    VeilbladeMindRend = {2, 2, 600, 1100},
    VeilbladeCrimsonSting = {223, 6, 40, 400},
    VeilbladeAttackAura = {77, 1, nil, nil},
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

--[[
Records one routed executor family and rank.

Args:
    kind (string): Expected source executor family.
    rank (number): Creative purchased rank.

Returns:
    any: Successful fake live application.
]]
local function applied(kind: string, rank: number): any
    last_kind = kind
    last_rank = rank
    return {
        Applied = true,
        Kind = kind,
    }
end

function FakeExecutor.magic_drain_skill_npc(
    _self: any,
    _owner: any,
    _target: any,
    _skill_id: string,
    rank: number,
    _sequence: number?
): (any?, string?)
    return applied("Drain", rank), nil
end

function FakeExecutor.status_skill_npc(
    _self: any,
    _owner: any,
    _target: any,
    _skill_id: string,
    rank: number,
    _sequence: number?
): (any?, string?)
    return applied("Periodic", rank), nil
end

function FakeExecutor.confusion_skill_npc(
    _self: any,
    _owner: any,
    _target: any,
    _skill_id: string,
    rank: number,
    _sequence: number?
): (any?, string?)
    return applied("Confusion", rank), nil
end

function FakeExecutor.physical_status_skill_npc(
    _self: any,
    _owner: any,
    _target: any,
    _skill_id: string,
    rank: number,
    _sequence: number?
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
    assert(condition, "[C4 Veilblade Cast] " .. label)
end

--[[
Executes one reviewed Veilblade family through the bridge.

Args:
    bridge (any): Enabled Veilblade cast bridge.
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
    local target = if expected_kind == "SelfBuff"
        then nil
        else enemy

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
        720
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
Runs every Veilblade-specific active family through the private bridge.

Args:
    None.

Returns:
    nil: Prints focused bridge evidence.
]]
local function main()
    local bridge = VeilbladeCast.new(
        FakeScheduler,
        FakeExecutor
    )

    local disabled, disabled_reason = bridge:begin_cast(
        owner,
        enemy,
        "VeilbladeUmbralSiphon",
        10
    )
    check(
        disabled == nil
            and disabled_reason == "C4VeilbladeCastDisabled",
        "bridge starts disabled"
    )

    bridge:set_enabled(true)

    check_skill(
        bridge,
        "VeilbladeUmbralSiphon",
        "Drain",
        1100
    )
    check_skill(
        bridge,
        "VeilbladeDefenseAura",
        "SelfBuff",
        nil
    )
    check_skill(
        bridge,
        "VeilbladeVenomHex",
        "Periodic",
        1100
    )
    check_skill(
        bridge,
        "VeilbladeMindRend",
        "Confusion",
        1100
    )
    check_skill(
        bridge,
        "VeilbladeCrimsonSting",
        "PhysicalStatus",
        400
    )
    check_skill(
        bridge,
        "VeilbladeAttackAura",
        "SelfBuff",
        nil
    )

    local capability = bridge:capability()
    check(
        capability.ReviewedActiveSkillCount == 6
            and capability.Drain
            and capability.Poison
            and capability.Confusion
            and capability.PhysicalBleed
            and capability.SelfBuff
            and not capability.ClientAuthority,
        "capability reports six server-owned Veilblade active families"
    )

    print((
        "[C4 Veilblade Cast] PASS: %d assertions active=6"
    ):format(checks))
end

main()
