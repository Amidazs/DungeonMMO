--!strict
-- Disabled-by-default scheduled source self-effect bridge for Warhowl.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Shared = ReplicatedStorage.Core.Shared
local SkillEffects = require(Shared.C4SkillEffectSource)

local ActiveEffects = require(
    ServerScriptService.Core.Services.C4ActiveSourceEffectState
)
local ResourceCutover = require(
    ServerScriptService.Core.Services.C4ResourceCutoverService
)
local PlayerBleed = require(
    ServerScriptService.Combat.PlayerBleedStatusService
)

local C4SourceSelfEffectCastService = {}
C4SourceSelfEffectCastService.__index =
    C4SourceSelfEffectCastService

local REVIEWED = table.freeze({
    SpiritclawForceFocus = table.freeze({
        SourceSkillId = 50,
        Kind = "Charge",
    }),
    SpiritclawBearAspect = table.freeze({
        SourceSkillId = 76,
        Kind = "TimedBuff",
    }),
    SpiritclawWolfAspect = table.freeze({
        SourceSkillId = 83,
        Kind = "TimedBuff",
    }),
    WarhowlWoundbind = table.freeze({
        SourceSkillId = 34,
        Kind = "BleedCure",
    }),
    WarhowlFury = table.freeze({
        SourceSkillId = 94,
        Kind = "TimedBuff",
    }),
    WarhowlWarRoar = table.freeze({
        SourceSkillId = 121,
        Kind = "BattleRoar",
    }),
})

--[[
Returns whether one candidate can own private source-cast state.

Args:
    player (any): Player instance or disposable server test owner.

Returns:
    boolean: True when an integral numeric UserId is available.
]]
local function valid_owner(player: any): boolean
    return (
        type(player) == "table"
        or typeof(player) == "Instance"
    )
        and type(player.UserId) == "number"
        and player.UserId % 1 == 0
end

--[[
Finds the first positive duration represented by a source effect.

Args:
    effect (any): Exact rank-resolved C4 source effect.

Returns:
    number?: Duration in seconds, otherwise nil.
]]
local function source_duration(effect: any): number?
    for _, row in ipairs(effect.Effects or {}) do
        if type(row.time) == "number" and row.time > 0 then
            return row.time
        end
    end

    return nil
end

--[[
Finds an exact HealPercentage power from one C4 source effect.

Args:
    effect (any): Exact rank-resolved C4 source effect.

Returns:
    number?: Positive percentage, otherwise nil.
]]
local function heal_percentage(effect: any): number?
    for _, row in ipairs(effect.Effects or {}) do
        if row.name == "HealPercentage"
            and type(row.power) == "number"
            and row.power >= 0
        then
            return row.power
        end
    end

    return nil
end

--[[
Builds a scheduled self-effect bridge around explicit server authorities.

Args:
    scheduler (any): Existing source cast scheduler.
    options (any?): Optional test replacements for effect-state, bleed,
        resources, random roll, and delayed expiry.

Returns:
    any: Disabled server-owned Warhowl self-effect bridge.
]]
function C4SourceSelfEffectCastService.new(
    scheduler: any,
    options: any?
): any
    assert(
        scheduler
            and type(scheduler.begin_cast) == "function"
            and type(scheduler.cancel_cast) == "function"
            and type(scheduler.launch_if_ready) == "function"
            and type(scheduler.clear_owner) == "function",
        "Self-effect bridge requires source cast scheduler"
    )

    local config = options or {}
    local active_effects =
        config.ActiveEffects or ActiveEffects
    local bleed = config.Bleed or PlayerBleed
    local resources = config.Resources or ResourceCutover
    local charges = config.Charges
    local random_roll = config.RandomRoll
    local delay = config.Delay or task.delay

    if not random_roll then
        local random = Random.new()
        random_roll = function(minimum: number, maximum: number): number
            return random:NextInteger(minimum, maximum)
        end
    end

    assert(
        type(active_effects.observe_timed) == "function"
            and type(active_effects.deactivate) == "function",
        "Self-effect bridge requires active-effect authority"
    )
    assert(
        type(bleed.is_bleeding) == "function"
            and type(bleed.cure_source) == "function",
        "Self-effect bridge requires player bleed authority"
    )
    assert(
        type(resources.refresh_active_effects) == "function"
            and type(resources.heal_percent_max_health) == "function",
        "Self-effect bridge requires source resource authority"
    )
    assert(type(random_roll) == "function")
    assert(type(delay) == "function")

    return setmetatable({
        _enabled = false,
        _scheduler = scheduler,
        _active_effects = active_effects,
        _bleed = bleed,
        _resources = resources,
        _charges = charges,
        _random_roll = random_roll,
        _delay = delay,
        _pending_by_owner = {},
        _timed_by_owner = {},
        _next_serial = 0,
    }, C4SourceSelfEffectCastService)
end

--[[
Changes the self-effect cast feature gate.

Args:
    enabled (boolean): Desired bridge state.

Returns:
    nil: Updates only this server-local gate.
]]
function C4SourceSelfEffectCastService:set_enabled(
    enabled: boolean
)
    assert(type(enabled) == "boolean")
    self._enabled = enabled
end

--[[
Reports the self-effect cast feature gate.

Args:
    None.

Returns:
    boolean: Current gate state.
]]
function C4SourceSelfEffectCastService:is_enabled(): boolean
    return self._enabled
end

--[[
Begins one reviewed Warhowl source self cast.

Args:
    player (any): Server-owned caster.
    creative_skill_id (string): Reviewed creative skill.
    supplied_now (number?): Optional deterministic scheduler time.

Returns:
    (any?, string?): Start evidence or strict denial reason.
]]
function C4SourceSelfEffectCastService:begin_cast(
    player: any,
    creative_skill_id: string,
    supplied_now: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4SelfEffectCastDisabled"
    end
    if not valid_owner(player) then
        return nil, "C4SelfEffectCastOwnerInvalid"
    end
    if self._pending_by_owner[player] then
        return nil, "C4SelfEffectCastAlreadyPending"
    end

    local review = REVIEWED[creative_skill_id]
    if not review then
        return nil, "C4SelfEffectSkillNotReviewed"
    end

    local started, reason = self._scheduler:begin_cast(
        player,
        creative_skill_id,
        supplied_now
    )
    if not started then
        return nil, reason
    end

    if started.SourceSkillId ~= review.SourceSkillId then
        self._scheduler:cancel_cast(player, started.CastId)
        return nil, "C4SelfEffectReviewedSourceMismatch"
    end

    self._pending_by_owner[player] = {
        CastId = started.CastId,
        CreativeSkillId = started.CreativeSkillId,
        CreativeRank = started.CreativeRank,
        SourceSkillId = started.SourceSkillId,
        Kind = review.Kind,
    }

    return {
        CastId = started.CastId,
        CreativeSkillId = started.CreativeSkillId,
        CreativeRank = started.CreativeRank,
        SourceSkillId = started.SourceSkillId,
        SourceRank = started.SourceRank,
        StartedAt = started.StartedAt,
        InterruptAt = started.InterruptAt,
        LaunchAt = started.LaunchAt,
        FinalizerAt = started.FinalizerAt,
        ReuseReadyAt = started.ReuseReadyAt,
        SourceOnly = true,
        TargetBoundServerSide = true,
        ShotStateConsumed = false,
    }, nil
end

--[[
Cancels one pending self-effect cast.

Args:
    player (any): Server-owned caster.
    cast_id (number): Private scheduler receipt.

Returns:
    (boolean, string?): Cancellation result.
]]
function C4SourceSelfEffectCastService:cancel_cast(
    player: any,
    cast_id: number
): (boolean, string?)
    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return false, "C4SelfEffectCastReceiptInvalid"
    end

    self._pending_by_owner[player] = nil
    return self._scheduler:cancel_cast(player, cast_id)
end

--[[
Registers deterministic timed-effect expiry for one reviewed buff.

Args:
    self (any): Self-effect bridge.
    player (any): Server-owned buff owner.
    record (any): Private cast record.
    duration_seconds (number): Exact source duration.

Returns:
    nil: Later expiry clears only the same effect generation.
]]
local function schedule_expiry(
    self: any,
    player: any,
    record: any,
    duration_seconds: number
)
    self._next_serial += 1
    local serial = self._next_serial

    local by_skill = self._timed_by_owner[player]
    if not by_skill then
        by_skill = {}
        self._timed_by_owner[player] = by_skill
    end

    by_skill[record.CreativeSkillId] = {
        Serial = serial,
        Kind = record.Kind,
    }

    self._delay(duration_seconds, function()
        local current_by_skill =
            self._timed_by_owner[player]
        local current = current_by_skill
            and current_by_skill[record.CreativeSkillId]

        if not current or current.Serial ~= serial then
            return
        end

        current_by_skill[record.CreativeSkillId] = nil
        self._active_effects.deactivate(
            player,
            record.CreativeSkillId
        )

        if record.Kind == "BattleRoar" then
            self._resources.refresh_active_effects(player)
        end

        if next(current_by_skill) == nil then
            self._timed_by_owner[player] = nil
        end
    end)
end

--[[
Applies one successful Woundbind/Bandage source negate-effect roll.

Args:
    self (any): Self-effect bridge.
    player (any): Server-owned caster.
    effect (any): Exact source rank definition.

Returns:
    (any?, string?): Source cleanse evidence or denial.
]]
local function apply_bleed_cure(
    self: any,
    player: any,
    effect: any
): (any?, string?)
    local effect_power = effect.Sets.effectPower
    if type(effect_power) ~= "number"
        or effect_power < 0
        or effect_power > 100
    then
        return nil, "C4SelfEffectBleedPowerInvalid"
    end

    local bleeding =
        self._bleed.is_bleeding(player.Character)
    if not bleeding then
        return {
            Kind = "C4SourceBleedCure",
            Applied = true,
            BleedPresent = false,
            CureAttempted = false,
            Cured = false,
            EffectPower = effect_power,
        }, nil
    end

    local roll = self._random_roll(1, 100)
    if type(roll) ~= "number"
        or roll % 1 ~= 0
        or roll < 1
        or roll > 100
    then
        return nil, "C4SelfEffectBleedRollInvalid"
    end

    local landed = effect_power >= roll
    local cured = false

    if landed then
        cured = self._bleed.cure_source(player.Character)
    end

    return {
        Kind = "C4SourceBleedCure",
        Applied = true,
        BleedPresent = true,
        CureAttempted = true,
        Cured = cured,
        Landed = landed,
        EffectPower = effect_power,
        Roll = roll,
    }, nil
end

--[[
Applies one exact timed self buff to authoritative source-effect state.

Args:
    self (any): Self-effect bridge.
    player (any): Server-owned caster.
    record (any): Private reviewed cast record.
    effect (any): Exact source rank definition.

Returns:
    (any?, string?): Active-effect evidence or strict denial.
]]
local function apply_timed_buff(
    self: any,
    player: any,
    record: any,
    effect: any
): (any?, string?)
    local duration = source_duration(effect)
    if not duration then
        return nil, "C4SelfEffectDurationUnavailable"
    end

    local observed, reason =
        self._active_effects.observe_timed(
            player,
            record.CreativeSkillId,
            record.CreativeRank,
            duration
        )
    if not observed then
        return nil, reason
    end

    local heal = nil

    if record.Kind == "BattleRoar" then
        local refreshed, refresh_reason =
            self._resources.refresh_active_effects(player)
        if not refreshed then
            self._active_effects.deactivate(
                player,
                record.CreativeSkillId
            )
            return nil, refresh_reason
        end

        local percent = heal_percentage(effect)
        if percent == nil then
            self._active_effects.deactivate(
                player,
                record.CreativeSkillId
            )
            self._resources.refresh_active_effects(player)
            return nil, "C4BattleRoarHealPercentageUnavailable"
        end

        heal, reason =
            self._resources.heal_percent_max_health(
                player,
                percent
            )
        if not heal then
            self._active_effects.deactivate(
                player,
                record.CreativeSkillId
            )
            self._resources.refresh_active_effects(player)
            return nil, reason
        end
    end

    schedule_expiry(
        self,
        player,
        record,
        duration
    )

    return {
        Kind = "C4SourceTimedSelfBuff",
        Applied = true,
        DurationSeconds = duration,
        Heal = heal,
    }, nil
end

--[[
Executes one reviewed self-effect family.

Args:
    self (any): Self-effect bridge.
    player (any): Server-owned caster.
    record (any): Private reviewed cast record.
    source_rank (number): Exact launched source rank.

Returns:
    (any?, string?): Live self-effect evidence or denial.
]]
--[[
Adds one exact C4 Force Focus charge.

Args:
    self (any): Self-effect bridge.
    player (any): Server-owned caster.
    effect (any): Exact source rank definition.

Returns:
    (any?, string?): Server-owned charge evidence or strict denial.
]]
local function apply_charge(
    self: any,
    player: any,
    effect: any
): (any?, string?)
    if not self._charges
        or type(self._charges.add_one) ~= "function"
    then
        return nil, "C4SelfEffectChargeAuthorityUnavailable"
    end

    local maximum = effect.Sets.maxCharges
    if type(maximum) ~= "number"
        or maximum % 1 ~= 0
        or maximum < 1
    then
        return nil, "C4SelfEffectChargeMaximumInvalid"
    end

    local charged, reason =
        self._charges:add_one(player, maximum)
    if not charged then
        return nil, reason
    end

    return {
        Kind = "C4SourceCharge",
        Applied = true,
        ChargeBefore = charged.ChargeBefore,
        ChargeAfter = charged.ChargeAfter,
        MaximumCharges = charged.MaximumCharges,
        Added = charged.Added,
    }, nil
end

local function execute(
    self: any,
    player: any,
    record: any,
    source_rank: number
): (any?, string?)
    local effect = SkillEffects.get_rank(
        record.SourceSkillId,
        source_rank
    )
    if not effect then
        return nil, "C4SelfEffectSourceRankUnavailable"
    end

    if record.Kind == "Charge" then
        return apply_charge(
            self,
            player,
            effect
        )
    end

    if record.Kind == "BleedCure" then
        return apply_bleed_cure(
            self,
            player,
            effect
        )
    end

    return apply_timed_buff(
        self,
        player,
        record,
        effect
    )
end

--[[
Launches one ready Warhowl self-effect cast.

Args:
    player (any): Server-owned caster.
    cast_id (number): Private scheduler receipt.
    supplied_now (number?): Optional deterministic scheduler time.

Returns:
    (any?, string?): Applied source self-effect or strict denial.
]]
function C4SourceSelfEffectCastService:launch_if_ready(
    player: any,
    cast_id: number,
    supplied_now: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4SelfEffectCastDisabled"
    end

    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return nil, "C4SelfEffectCastReceiptInvalid"
    end

    local launch, reason =
        self._scheduler:launch_if_ready(
            player,
            cast_id,
            supplied_now
        )
    if not launch then
        return nil, reason
    end

    self._pending_by_owner[player] = nil

    if launch.CreativeSkillId ~= record.CreativeSkillId
        or launch.CreativeRank ~= record.CreativeRank
        or launch.SourceSkillId ~= record.SourceSkillId
        or launch.ReadyForSourceEffectExecution ~= true
    then
        return nil, "C4SelfEffectLaunchPlanChanged"
    end

    local applied, apply_reason = execute(
        self,
        player,
        record,
        launch.SourceRank
    )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4ScheduledSelfEffect",
        CastId = cast_id,
        Launch = launch,
        Application = applied,
        Applied = applied.Applied == true,
        ClientAuthority = false,
    }, nil
end

--[[
Clears pending and timed bridge state for one owner.

Args:
    player (any): Departing server-owned caster.

Returns:
    nil: Removes bridge state and reviewed source effects.
]]
function C4SourceSelfEffectCastService:clear_owner(player: any)
    self._pending_by_owner[player] = nil
    self._scheduler:clear_owner(player)

    local timed = self._timed_by_owner[player]
    if timed then
        for skill_id in pairs(timed) do
            self._active_effects.deactivate(
                player,
                skill_id
            )
        end
    end

    self._timed_by_owner[player] = nil
end

--[[
Returns detached reviewed self-effect capability metadata.

Args:
    None.

Returns:
    any: Gate and exact reviewed-family evidence.
]]
function C4SourceSelfEffectCastService:capability(): any
    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = self._enabled,
        ReviewedSkillCount = 6,
        SourceChargeBuilder = true,
        SpiritclawTimedAspects = true,
        BleedNegateEffectPowerRoll = true,
        TimedSourceBuffs = true,
        BattleRoarMaxHpThenPercentHeal = true,
        ClientAuthority = false,
    }
end

return C4SourceSelfEffectCastService
