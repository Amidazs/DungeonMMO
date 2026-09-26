--!strict
-- Scheduled Human Wizard companion cast bridge regression.

local ServerScriptService = game:GetService("ServerScriptService")

local CompanionCast = require(
    ServerScriptService.Core.Services.C4SourceCompanionCastService
)

local checks = 0
local next_cast_id = 40
local pending_skill = nil
local companion_active = false
local last_action = nil

local owner = {
    UserId = 938212,
}

local SOURCE_IDS = {
    EmberweaverManaCompanion = 1111,
    EmberweaverCombatCompanion = 1225,
    EmberweaverServitorRecharge = 1126,
    EmberweaverServitorHeal = 1127,
}

local FakeScheduler = {}

--[[
Begins one deterministic source schedule.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Expected cast owner.
    skill_id (string): Creative skill identifier.
    supplied_now (number?): Deterministic start time.

Returns:
    (any?, string?): Fake scheduler start evidence.
]]
function FakeScheduler.begin_cast(
    _self: any,
    _owner: any,
    skill_id: string,
    supplied_now: number?
): (any?, string?)
    next_cast_id += 1
    pending_skill = skill_id
    local now = supplied_now or 100

    return {
        CastId = next_cast_id,
        CreativeSkillId = skill_id,
        CreativeRank = 1,
        SourceSkillId = SOURCE_IDS[skill_id],
        SourceRank = 1,
        StartedAt = now,
        InterruptAt = now + 1,
        LaunchAt = now + 2,
        FinalizerAt = now + 2,
        ReuseReadyAt = now + 10,
    }, nil
end

--[[
Cancels the disposable source schedule.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Expected owner.
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
Launches one deterministic ready source schedule.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Expected owner.
    cast_id (number): Disposable cast receipt.
    _supplied_now (number?): Deterministic launch time.

Returns:
    (any?, string?): Fake launch evidence.
]]
function FakeScheduler.launch_if_ready(
    _self: any,
    _owner: any,
    cast_id: number,
    _supplied_now: number?
): (any?, string?)
    local skill_id = assert(pending_skill)
    pending_skill = nil

    return {
        CastId = cast_id,
        CreativeSkillId = skill_id,
        CreativeRank = 1,
        SourceSkillId = SOURCE_IDS[skill_id],
        SourceRank = 1,
        ReadyForSourceEffectExecution = true,
    }, nil
end

--[[
Clears fake scheduler state.

Args:
    _self (any): Fake scheduler receiver.
    _owner (any): Disposable owner.

Returns:
    nil: Clears only test state.
]]
function FakeScheduler.clear_owner(
    _self: any,
    _owner: any
)
    pending_skill = nil
end

local FakeCompanions = {}

--[[
Returns current fake companion state.

Args:
    _self (any): Fake authority receiver.
    _owner (any): Disposable owner.

Returns:
    any: Active-state snapshot.
]]
function FakeCompanions.snapshot(
    _self: any,
    _owner: any
): any
    return {Active = companion_active}
end

--[[
Preflights current fake companion target.

Args:
    _self (any): Fake authority receiver.
    _owner (any): Disposable owner.

Returns:
    (boolean, string?): Target state.
]]
function FakeCompanions.can_target_owned(
    _self: any,
    _owner: any
): (boolean, string?)
    if companion_active then
        return true, nil
    end
    return false, "C4OwnedCompanionUnavailable"
end

--[[
Applies one fake companion summon.

Args:
    _self (any): Fake authority receiver.
    _owner (any): Disposable owner.
    skill_id (string): Reviewed summon skill.
    _rank (number): Creative rank.
    role (string): Reviewed companion role.

Returns:
    (any?, string?): Fake summon evidence.
]]
function FakeCompanions.summon(
    _self: any,
    _owner: any,
    skill_id: string,
    _rank: number,
    role: string
): (any?, string?)
    companion_active = true
    last_action = skill_id
    return {Applied = true, Role = role}, nil
end

--[[
Applies one fake Servitor Heal.

Args:
    _self (any): Fake authority receiver.
    _owner (any): Disposable owner.
    skill_id (string): Reviewed skill.
    _rank (number): Creative rank.

Returns:
    (any?, string?): Fake heal evidence.
]]
function FakeCompanions.heal_owned(
    _self: any,
    _owner: any,
    skill_id: string,
    _rank: number
): (any?, string?)
    last_action = skill_id
    return {Applied = true, EffectiveHeal = 50}, nil
end

--[[
Applies one fake Servitor Recharge.

Args:
    _self (any): Fake authority receiver.
    _owner (any): Disposable owner.
    skill_id (string): Reviewed skill.
    _rank (number): Creative rank.

Returns:
    (any?, string?): Fake recharge evidence.
]]
function FakeCompanions.recharge_owned(
    _self: any,
    _owner: any,
    skill_id: string,
    _rank: number
): (any?, string?)
    last_action = skill_id
    return {Applied = true, ManaRestored = 41}, nil
end

--[[
Counts one companion-cast assertion.

Args:
    condition (boolean): Observed bridge state.
    label (string): Failure description.

Returns:
    nil: Raises on failure and increments the assertion count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Companion Cast] " .. label)
end

--[[
Runs summon and pet-support bridge acceptance.

Args:
    None.

Returns:
    nil: Prints green regression evidence.
]]
local function main()
    local bridge = CompanionCast.new(
        FakeScheduler,
        FakeCompanions
    )

    local disabled, disabled_reason = bridge:begin_cast(
        owner,
        "EmberweaverManaCompanion",
        100
    )
    check(
        disabled == nil
            and disabled_reason == "C4CompanionCastDisabled",
        "companion cast bridge starts disabled"
    )

    bridge:set_enabled(true)
    local started = assert(bridge:begin_cast(
        owner,
        "EmberweaverManaCompanion",
        100
    ))
    local summoned = assert(bridge:launch_if_ready(
        owner,
        started.CastId,
        102
    ))
    check(
        summoned.Applied
            and companion_active
            and last_action == "EmberweaverManaCompanion",
        "scheduled Mana Companion reaches server companion authority"
    )

    local duplicate, duplicate_reason = bridge:begin_cast(
        owner,
        "EmberweaverCombatCompanion",
        200
    )
    check(
        duplicate == nil
            and duplicate_reason == "C4CompanionAlreadySummoned",
        "second summon is rejected before initial MP spend"
    )

    local heal_start = assert(bridge:begin_cast(
        owner,
        "EmberweaverServitorHeal",
        300
    ))
    local healed = assert(bridge:launch_if_ready(
        owner,
        heal_start.CastId,
        302
    ))
    check(
        healed.Applied
            and last_action == "EmberweaverServitorHeal",
        "scheduled Servitor Heal reaches owned companion"
    )

    local recharge_start = assert(bridge:begin_cast(
        owner,
        "EmberweaverServitorRecharge",
        400
    ))
    local recharged = assert(bridge:launch_if_ready(
        owner,
        recharge_start.CastId,
        402
    ))
    check(
        recharged.Applied
            and last_action == "EmberweaverServitorRecharge",
        "scheduled Servitor Recharge reaches owned companion"
    )

    companion_active = false
    local missing, missing_reason = bridge:begin_cast(
        owner,
        "EmberweaverServitorHeal",
        500
    )
    check(
        missing == nil
            and missing_reason == "C4OwnedCompanionUnavailable",
        "pet-target support fails closed without owned companion"
    )

    print((
        "[C4 Companion Cast] PASS: %d assertions"
    ):format(checks))
end

main()
