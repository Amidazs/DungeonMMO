--!strict
-- Damage-driven C4 source cast interruption regression.

local ServerScriptService = game:GetService("ServerScriptService")

local Interruption = require(
    ServerScriptService.Core.Services.C4SourceCastInterruptionService
)

local checks = 0
local attack_cancel_rate_offset = 0
local boundary_active_ready = true

local scheduler_state = {
    Pending = false,
    CastId = 41,
    CreativeSkillId = "NightweaverGaleBolt",
    SourceSkillId = 1172,
    SourceRank = 6,
    InterruptAt = 102,
    LaunchAt = 104,
    ReuseReadyAt = 106,
    CancelCalls = 0,
}

local FakeScheduler = {}

--[[
Returns detached fake pending source-cast state.

Args:
    _player (any): Disposable cast owner.

Returns:
    any: Current scheduler test snapshot.
]]
function FakeScheduler:snapshot(_player: any): any
    return table.clone(scheduler_state)
end

--[[
Cancels the current fake source cast once.

Args:
    _player (any): Disposable cast owner.
    cast_id (number): Expected private cast receipt.

Returns:
    (boolean, string?): Cancellation state.
]]
function FakeScheduler:cancel_cast(
    _player: any,
    cast_id: number
): (boolean, string?)
    if not scheduler_state.Pending
        or cast_id ~= scheduler_state.CastId
    then
        return false, "C4SourceCastReceiptInvalid"
    end

    scheduler_state.Pending = false
    scheduler_state.CancelCalls += 1
    return true, nil
end

--[[
Returns the deterministic combined source-stat boundary.

Args:
    _user_id (number): Disposable authenticated owner.

Returns:
    (any?, string?): Source MEN and attack-cancel modifier state.
]]
local function boundary_provider(
    _user_id: number
): (any?, string?)
    return {
        SourceStatCandidateReady = true,
        SourceStatCandidateIncludesActiveEffects =
            boundary_active_ready,
        SourceMenBonus = 1.45,
        SourceStatCandidate = {
            ATTACK_CANCEL_RATE =
                attack_cancel_rate_offset,
        },
    }, nil
end

--[[
Resets fake scheduler and boundary state.

Args:
    pending (boolean): Whether a cast is currently pending.
    rate_offset (number): Signed source ATTACK_CANCEL_RATE offset.

Returns:
    nil: Restores deterministic test state.
]]
local function reset(
    pending: boolean,
    rate_offset: number
)
    scheduler_state.Pending = pending
    scheduler_state.InterruptAt = 102
    scheduler_state.CancelCalls = 0
    attack_cancel_rate_offset = rate_offset
    boundary_active_ready = true
end

--[[
Counts one cast-interruption assertion.

Args:
    condition (boolean): Expected interruption behavior.
    label (string): Diagnostic failure description.

Returns:
    nil: Increments the count or raises.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(
        condition,
        "[C4 Cast Interruption] " .. label
    )
end

--[[
Runs exact damage, MEN, Concentration and deadline interruption checks.

Args:
    None.

Returns:
    nil: Prints bounded source-interruption acceptance evidence.
]]
local function main()
    local service = Interruption.new(
        FakeScheduler,
        boundary_provider
    )
    local player = {
        UserId = 938199,
    }

    reset(false, 0)
    local idle = assert(service:try_damage_interrupt(
        player,
        400,
        0,
        100
    ))
    check(
        not idle.Evaluated
            and not idle.Interrupted
            and idle.Reason == "NoPendingC4SourceCast",
        "damage cannot interrupt when no source cast is pending"
    )

    reset(true, 0)
    local neutral = assert(service:try_damage_interrupt(
        player,
        400,
        42,
        100
    ))
    check(
        neutral.Evaluated
            and neutral.Interrupted
            and neutral.RatePercent > 42
            and neutral.RatePercent < 43
            and scheduler_state.CancelCalls == 1
            and not scheduler_state.Pending,
        "neutral Dark Wizard cast is cancelled by a successful C4 roll"
    )

    reset(true, -25)
    local protected = assert(service:try_damage_interrupt(
        player,
        400,
        18,
        100
    ))
    check(
        protected.Evaluated
            and not protected.Interrupted
            and protected.AttackCancelRateOffset == -25
            and protected.RatePercent > 17
            and protected.RatePercent < 18
            and scheduler_state.CancelCalls == 0
            and scheduler_state.Pending,
        "Concentration rank two reduces the same damage interrupt chance"
    )

    local protected_break = assert(
        service:try_damage_interrupt(
            player,
            400,
            17,
            100
        )
    )
    check(
        protected_break.Interrupted
            and scheduler_state.CancelCalls == 1,
        "Concentration still obeys the final source interruption roll"
    )

    reset(true, 0)
    local late = assert(service:try_damage_interrupt(
        player,
        400,
        0,
        102
    ))
    check(
        not late.Evaluated
            and late.Reason
                == "C4SourceCastInterruptWindowClosed"
            and scheduler_state.CancelCalls == 0,
        "damage at the interrupt deadline cannot cancel the cast"
    )

    reset(true, -25)
    boundary_active_ready = false
    local unresolved = assert(
        service:try_damage_interrupt(
            player,
            400,
            0,
            100
        )
    )
    check(
        not unresolved.Evaluated
            and unresolved.Reason
                == "C4SourceCastInterruptStatsUnavailable"
            and scheduler_state.CancelCalls == 0,
        "missing authoritative active state cannot fake interruption stats"
    )

    reset(true, 0)
    service:set_roll_provider_for_test(function()
        return 42
    end)
    local injected = assert(service:try_damage_interrupt(
        player,
        400,
        nil,
        100
    ))
    service:set_roll_provider_for_test(nil)
    check(
        injected.Interrupted
            and injected.Roll == 42
            and scheduler_state.CancelCalls == 1,
        "Studio-only roll provider drives the real server roll path"
    )

    local capability = service:capability()
    check(
        capability.PendingSourceCastsOnly
            and capability.SourceInterruptWindow
            and capability.DamageScaledChance
            and capability.SourceMenIntegrated
            and capability.AttackCancelRateIntegrated
            and capability.ServerOwnedRoll
            and capability.SchedulerCancellationIntegrated
            and not capability.ClientAuthority,
        "interruption capability remains entirely server-owned"
    )

    print((
        "[C4 Cast Interruption] PASS: %d assertions "
        .. "damage=true men=true concentration=true deadline=true"
    ):format(checks))
end

main()
