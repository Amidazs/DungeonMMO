--!strict
-- Scheduled Warhowl self-effect bridge regression.

local ServerScriptService = game:GetService("ServerScriptService")
local Service = require(
    ServerScriptService.Core.Services.C4SourceSelfEffectCastService
)

local OWNER = table.freeze({
    UserId = 938270,
    Character = table.freeze({Name = "TEMP_WarhowlCharacter"}),
})

local PLANS = table.freeze({
    DeepclaimerFieldBandage = table.freeze({
        SourceSkillId = 34,
        SourceRank = 1,
    }),
    GearwrightFieldBandage = table.freeze({
        SourceSkillId = 34,
        SourceRank = 1,
    }),
    SpiritclawForceFocus = table.freeze({
        SourceSkillId = 50,
        SourceRank = 1,
    }),
    SpiritclawBearAspect = table.freeze({
        SourceSkillId = 76,
        SourceRank = 1,
    }),
    SpiritclawWolfAspect = table.freeze({
        SourceSkillId = 83,
        SourceRank = 1,
    }),
    WarhowlWoundbind = table.freeze({
        SourceSkillId = 34,
        SourceRank = 1,
    }),
    WarhowlFury = table.freeze({
        SourceSkillId = 94,
        SourceRank = 1,
    }),
    WarhowlWarRoar = table.freeze({
        SourceSkillId = 121,
        SourceRank = 1,
    }),
})

local checks = 0
local next_cast_id = 700
local pending = {}
local observed = {}
local deactivated = {}
local delayed = {}
local bleeding = true
local cured = 0
local refreshes = 0
local percent_heals = 0
local rolls = {30, 31, 30, 30}

local FakeScheduler = {}

--[[
Begins one deterministic reviewed self-effect cast.

Args:
    owner (any): Expected disposable owner.
    skill_id (string): Reviewed Warhowl skill.
    supplied_now (number?): Deterministic start time.

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
        return nil, "WarhowlSelfTestPlanUnavailable"
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
        SourceRank = plan.SourceRank,
        StartedAt = now,
        InterruptAt = now + 0.5,
        LaunchAt = now + 1,
        FinalizerAt = now + 1.1,
        ReuseReadyAt = now + 3,
        SourceOnly = true,
    }, nil
end

--[[
Cancels one deterministic pending cast.

Args:
    owner (any): Expected owner.
    cast_id (number): Private test receipt.

Returns:
    (boolean, string?): Cancellation result.
]]
function FakeScheduler:cancel_cast(
    owner: any,
    cast_id: number
): (boolean, string?)
    local record = pending[owner]
    if not record or record.CastId ~= cast_id then
        return false, "WarhowlSelfTestReceiptInvalid"
    end

    pending[owner] = nil
    return true, nil
end

--[[
Launches one deterministic reviewed self-effect cast.

Args:
    owner (any): Expected owner.
    cast_id (number): Private test receipt.
    _supplied_now (number?): Deterministic launch time.

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
        return nil, "WarhowlSelfTestReceiptInvalid"
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
Clears one owner's deterministic scheduler state.

Args:
    owner (any): Disposable owner.

Returns:
    nil: Removes fake pending state.
]]
function FakeScheduler:clear_owner(owner: any)
    pending[owner] = nil
end

local FakeActiveEffects = {}

--[[
Records one exact timed active source effect.

Args:
    _owner (any): Expected owner.
    skill_id (string): Creative Warhowl skill.
    rank (number): Purchased creative rank.
    duration (number): Exact source duration.

Returns:
    (boolean, string?): Successful fake observation.
]]
function FakeActiveEffects.observe_timed(
    _owner: any,
    skill_id: string,
    rank: number,
    duration: number
): (boolean, string?)
    observed[skill_id] = {
        Rank = rank,
        Duration = duration,
    }
    return true, nil
end

--[[
Records one source-effect deactivation.

Args:
    _owner (any): Expected owner.
    skill_id (string): Creative Warhowl skill.

Returns:
    nil: Records deactivation.
]]
function FakeActiveEffects.deactivate(
    _owner: any,
    skill_id: string
)
    deactivated[skill_id] = true
end

local FakeBleed = {}

--[[
Reports disposable bleed state.

Args:
    _character (any): Disposable character.

Returns:
    boolean: Current fake bleed state.
]]
function FakeBleed.is_bleeding(_character: any): boolean
    return bleeding
end

--[[
Clears disposable source bleed.

Args:
    _character (any): Disposable character.

Returns:
    boolean: True only when a fake bleed existed.
]]
function FakeBleed.cure_source(_character: any): boolean
    if not bleeding then
        return false
    end

    bleeding = false
    cured += 1
    return true
end

local FakeResources = {}

--[[
Records one active-effect resource refresh.

Args:
    _owner (any): Expected source owner.

Returns:
    (boolean, string?): Successful fake refresh.
]]
function FakeResources.refresh_active_effects(
    _owner: any
): (boolean, string?)
    refreshes += 1
    return true, nil
end

--[[
Records one Battle Roar percentage heal.

Args:
    _owner (any): Expected source owner.
    percent (number): Exact source heal percent.

Returns:
    (any?, string?): Fake heal evidence.
]]
function FakeResources.heal_percent_max_health(
    _owner: any,
    percent: number
): (any?, string?)
    percent_heals += 1
    return {
        RequestedHeal = 130,
        EffectiveHeal = 130,
        MaxHealth = 1300,
        Percent = percent,
    }, nil
end


local charge_count = 0
local FakeCharges = {}

--[[
Adds one deterministic Spiritclaw force charge.

Args:
    owner (any): Expected source owner.
    maximum (number): Exact source maximum.

Returns:
    (any?, string?): Deterministic charge evidence.
]]
function FakeCharges:add_one(
    owner: any,
    maximum: number
): (any?, string?)
    if owner ~= OWNER or maximum ~= 1 then
        return nil, "SelfEffectChargeTestInvalid"
    end

    local before = charge_count
    charge_count = math.min(maximum, charge_count + 1)

    return {
        ChargeBefore = before,
        ChargeAfter = charge_count,
        MaximumCharges = maximum,
        Added = charge_count > before,
    }, nil
end

--[[
Returns one queued deterministic source roll.

Args:
    minimum (number): Expected lower bound.
    maximum (number): Expected upper bound.

Returns:
    number: Next deterministic roll.
]]
local function random_roll(
    minimum: number,
    maximum: number
): number
    assert(minimum == 1 and maximum == 100)
    return table.remove(rolls, 1) or 100
end

--[[
Captures a delayed expiry callback without waiting in Studio.

Args:
    seconds (number): Exact requested delay.
    callback (() -> ()): Expiry callback.

Returns:
    nil: Stores deterministic delayed work.
]]
local function fake_delay(
    seconds: number,
    callback: () -> ()
)
    table.insert(delayed, {
        Seconds = seconds,
        Callback = callback,
    })
end

--[[
Counts one self-effect bridge assertion.

Args:
    condition (boolean): Required bridge condition.
    label (string): Failure description.

Returns:
    nil: Raises on mismatch and increments count.
]]
local function check(condition: boolean, label: string)
    checks += 1
    assert(condition, "[C4 Warhowl Self Effect] " .. label)
end

--[[
Creates one enabled bridge using deterministic fake authorities.

Args:
    None.

Returns:
    any: Enabled self-effect bridge.
]]
local function make_bridge(): any
    local bridge = Service.new(FakeScheduler, {
        ActiveEffects = FakeActiveEffects,
        Bleed = FakeBleed,
        Resources = FakeResources,
        Charges = FakeCharges,
        RandomRoll = random_roll,
        Delay = fake_delay,
    })
    bridge:set_enabled(true)
    return bridge
end

--[[
Checks exact Woundbind/Bandage effect-power probability.

Args:
    bridge (any): Enabled reviewed self-effect bridge.

Returns:
    nil: Confirms 30 succeeds and 31 fails for effectPower 30.
]]
local function check_woundbind(bridge: any)
    bleeding = true
    local success_start = assert(bridge:begin_cast(
        OWNER,
        "WarhowlWoundbind",
        100
    ))
    local success = assert(bridge:launch_if_ready(
        OWNER,
        success_start.CastId,
        101
    ))

    check(
        success.Application.EffectPower == 30
            and success.Application.Roll == 30
            and success.Application.Landed
            and success.Application.Cured
            and cured == 1,
        "Woundbind roll 30 cures exact active BLEED"
    )

    bleeding = true
    local fail_start = assert(bridge:begin_cast(
        OWNER,
        "WarhowlWoundbind",
        110
    ))
    local failed = assert(bridge:launch_if_ready(
        OWNER,
        fail_start.CastId,
        111
    ))

    check(
        failed.Application.Roll == 31
            and not failed.Application.Landed
            and not failed.Application.Cured
            and bleeding,
        "Woundbind roll 31 fails exact effectPower 30"
    )

    bleeding = true
    local bandage_start = assert(bridge:begin_cast(
        OWNER,
        "GearwrightFieldBandage",
        112
    ))
    local bandaged = assert(bridge:launch_if_ready(
        OWNER,
        bandage_start.CastId,
        113
    ))
    check(
        bandaged.Application.Roll == 30
            and bandaged.Application.Landed
            and bandaged.Application.Cured
            and cured == 2,
        "Gearwright Bandage reuses exact source negate bleed authority"
    )

    bleeding = true
    local deepclaimer_start = assert(bridge:begin_cast(
        OWNER,
        "DeepclaimerFieldBandage",
        114
    ))
    local deepclaimer_bandage = assert(bridge:launch_if_ready(
        OWNER,
        deepclaimer_start.CastId,
        115
    ))
    check(
        deepclaimer_bandage.Application.Roll == 30
            and deepclaimer_bandage.Application.Landed
            and deepclaimer_bandage.Application.Cured
            and cured == 3,
        "Deepclaimer Bandage reuses exact source negate bleed authority"
    )
end

--[[
Checks Fury and Battle Roar exact timed self-effect behavior.

Args:
    bridge (any): Enabled reviewed self-effect bridge.

Returns:
    nil: Confirms durations, HP refresh/heal and expiry cleanup.
]]
local function check_timed_buffs(bridge: any)
    local fury_start = assert(bridge:begin_cast(
        OWNER,
        "WarhowlFury",
        120
    ))
    local fury = assert(bridge:launch_if_ready(
        OWNER,
        fury_start.CastId,
        121
    ))
    check(
        fury.Application.DurationSeconds == 60
            and observed.WarhowlFury.Duration == 60
            and refreshes == 0,
        "Fury registers exact 60-second source buff"
    )

    local roar_start = assert(bridge:begin_cast(
        OWNER,
        "WarhowlWarRoar",
        130
    ))
    local roar = assert(bridge:launch_if_ready(
        OWNER,
        roar_start.CastId,
        131
    ))
    check(
        roar.Application.DurationSeconds == 600
            and observed.WarhowlWarRoar.Duration == 600
            and refreshes == 1
            and percent_heals == 1
            and roar.Application.Heal.Percent == 10,
        "War Roar refreshes Max HP then heals exact ten percent"
    )

    check(
        #delayed == 2
            and delayed[1].Seconds == 60
            and delayed[2].Seconds == 600,
        "timed buffs schedule exact source expiries"
    )

    delayed[1].Callback()
    delayed[2].Callback()
    check(
        deactivated.WarhowlFury
            and deactivated.WarhowlWarRoar
            and refreshes == 2,
        "expiry clears source effects and restores War Roar resources"
    )
end

--[[
Checks Spiritclaw Focus Force and both timed possession aspects.

Args:
    bridge (any): Enabled reviewed self-effect bridge.

Returns:
    nil: Confirms source charge cap and exact aspect durations.
]]
local function check_spiritclaw_effects(bridge: any)
    charge_count = 0

    local focus_start = assert(bridge:begin_cast(
        OWNER,
        "SpiritclawForceFocus",
        140
    ))
    local focus = assert(bridge:launch_if_ready(
        OWNER,
        focus_start.CastId,
        141
    ))
    check(
        focus.Application.Kind == "C4SourceCharge"
            and focus.Application.ChargeBefore == 0
            and focus.Application.ChargeAfter == 1
            and focus.Application.MaximumCharges == 1
            and focus.Application.Added,
        "Focus Force adds exactly one source charge"
    )

    local capped_start = assert(bridge:begin_cast(
        OWNER,
        "SpiritclawForceFocus",
        142
    ))
    local capped = assert(bridge:launch_if_ready(
        OWNER,
        capped_start.CastId,
        143
    ))
    check(
        capped.Application.ChargeBefore == 1
            and capped.Application.ChargeAfter == 1
            and not capped.Application.Added,
        "Focus Force cannot exceed source maxCharges one"
    )

    local bear_start = assert(bridge:begin_cast(
        OWNER,
        "SpiritclawBearAspect",
        150
    ))
    local bear = assert(bridge:launch_if_ready(
        OWNER,
        bear_start.CastId,
        151
    ))
    check(
        bear.Application.DurationSeconds == 120
            and observed.SpiritclawBearAspect.Duration == 120,
        "Bear Aspect preserves exact 120-second source duration"
    )

    local wolf_start = assert(bridge:begin_cast(
        OWNER,
        "SpiritclawWolfAspect",
        160
    ))
    local wolf = assert(bridge:launch_if_ready(
        OWNER,
        wolf_start.CastId,
        161
    ))
    check(
        wolf.Application.DurationSeconds == 120
            and observed.SpiritclawWolfAspect.Duration == 120,
        "Wolf Aspect preserves exact 120-second source duration"
    )

    check(
        #delayed == 4
            and delayed[3].Seconds == 120
            and delayed[4].Seconds == 120,
        "Spiritclaw aspects schedule exact source expiries"
    )

    delayed[3].Callback()
    delayed[4].Callback()
    check(
        deactivated.SpiritclawBearAspect
            and deactivated.SpiritclawWolfAspect,
        "Spiritclaw aspect expiry clears exact active source effects"
    )
end

--[[
Runs the Warhowl scheduled self-effect regression.

Args:
    None.

Returns:
    nil: Prints bounded exact-source self-effect coverage.
]]
local function main()
    local bridge = make_bridge()

    check_woundbind(bridge)
    check_timed_buffs(bridge)
    check_spiritclaw_effects(bridge)

    local capability = bridge:capability()
    check(
        capability.ReviewedSkillCount == 8
            and capability.SourceChargeBuilder
            and capability.SpiritclawTimedAspects
            and capability.BleedNegateEffectPowerRoll
            and capability.TimedSourceBuffs
            and capability.BattleRoarMaxHpThenPercentHeal
            and not capability.ClientAuthority,
        "capability reports all eight reviewed self-effect families"
    )

    print((
        "[C4 Self Effect] PASS: %d assertions reviewed=8"
    ):format(checks))
end

main()
