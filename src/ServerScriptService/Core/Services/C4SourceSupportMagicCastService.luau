--!strict
-- Disabled-by-default scheduled Human Cleric friendly support bridge.

local C4SourceSupportMagicCastService = {}
C4SourceSupportMagicCastService.__index =
    C4SourceSupportMagicCastService

local REVIEWED = table.freeze({
    DawnkeeperHealingLight = table.freeze({
        SourceSkillId = 1011,
        Kind = "TargetHeal",
        CastRange = 600,
        EffectRange = 1100,
    }),
    DawnkeeperBattleMend = table.freeze({
        SourceSkillId = 1015,
        Kind = "TargetHeal",
        CastRange = 600,
        EffectRange = 1100,
    }),
    DawnkeeperGroupMend = table.freeze({
        SourceSkillId = 1027,
        Kind = "PartyHeal",
        SourceRadius = 1000,
    }),
    DawnkeeperMindWard = table.freeze({
        SourceSkillId = 1035,
        Kind = "TargetBuff",
        CastRange = 400,
        EffectRange = 900,
    }),
    DawnkeeperStoneWard = table.freeze({
        SourceSkillId = 1040,
        Kind = "TargetBuff",
        CastRange = 400,
        EffectRange = 900,
    }),
    DawnkeeperSacredEdge = table.freeze({
        SourceSkillId = 1043,
        Kind = "TargetBuff",
        CastRange = 400,
        EffectRange = 900,
    }),
    DawnkeeperMight = table.freeze({
        SourceSkillId = 1068,
        Kind = "TargetBuff",
        CastRange = 400,
        EffectRange = 900,
    }),
    DawnkeeperBreathBlessing = table.freeze({
        SourceSkillId = 1073,
        Kind = "TargetBuff",
        CastRange = 400,
        EffectRange = 900,
    }),
    DawnkeeperFocus = table.freeze({
        SourceSkillId = 1077,
        Kind = "TargetBuff",
        CastRange = 400,
        EffectRange = 900,
    }),
    DawnkeeperConcentration = table.freeze({
        SourceSkillId = 1078,
        Kind = "TargetBuff",
        CastRange = 400,
        EffectRange = 900,
    }),
    DawnkeeperInsight = table.freeze({
        SourceSkillId = 1085,
        Kind = "TargetBuff",
        CastRange = 400,
        EffectRange = 900,
    }),
    DawnkeeperFireWard = table.freeze({
        SourceSkillId = 1191,
        Kind = "TargetBuff",
        CastRange = 400,
        EffectRange = 900,
    }),
    DawnkeeperWindstep = table.freeze({
        SourceSkillId = 1204,
        Kind = "TargetBuff",
        CastRange = 400,
        EffectRange = 900,
    }),
})

--[[
Validates one server-owned cast owner.

Args:
    player (any): Candidate server player.

Returns:
    boolean: True when a numeric integral UserId is available.
]]
local function valid_owner(player: any): boolean
    if type(player) ~= "table"
        and typeof(player) ~= "Instance"
    then
        return false
    end

    return type(player.UserId) == "number"
        and player.UserId % 1 == 0
end

--[[
Creates the scheduled friendly-support bridge.

Args:
    scheduler (any): Source cast scheduler authority.
    executor (any): Live source combat executor authority.

Returns:
    any: Disabled support bridge.
]]
function C4SourceSupportMagicCastService.new(
    scheduler: any,
    executor: any
): any
    assert(
        scheduler
            and type(scheduler.begin_cast) == "function"
            and type(scheduler.cancel_cast) == "function"
            and type(scheduler.launch_if_ready) == "function"
            and type(scheduler.clear_owner) == "function",
        "Support magic bridge requires source cast scheduler"
    )
    assert(
        executor
            and type(
                executor.can_support_skill_player
            ) == "function"
            and type(executor.can_party_heal_skill) == "function"
            and type(executor.heal_skill_target) == "function"
            and type(
                executor.support_buff_skill_target
            ) == "function"
            and type(executor.party_heal_skill) == "function",
        "Support magic bridge requires source support executor"
    )

    return setmetatable({
        _enabled = false,
        _scheduler = scheduler,
        _executor = executor,
        _pending_by_owner = {},
    }, C4SourceSupportMagicCastService)
end

--[[
Changes the friendly-support feature gate.

Args:
    enabled (boolean): Desired bridge state.

Returns:
    nil: Updates only this server-local feature gate.
]]
function C4SourceSupportMagicCastService:set_enabled(enabled: boolean)
    assert(type(enabled) == "boolean")
    self._enabled = enabled
end

--[[
Reports the friendly-support feature gate.

Args:
    None.

Returns:
    boolean: Current bridge state.
]]
function C4SourceSupportMagicCastService:is_enabled(): boolean
    return self._enabled
end

--[[
Checks one support target before initial MP is spent.

Args:
    self (any): Support bridge instance.
    caster (any): Server-owned caster.
    target (any?): Server-owned friendly target for TARGET_ONE.
    review (any): Reviewed support skill metadata.

Returns:
    (boolean, string?): Readiness or strict denial reason.
]]
local function preflight(
    self: any,
    caster: any,
    target: any?,
    review: any
): (boolean, string?)
    if review.Kind == "PartyHeal" then
        return self._executor:can_party_heal_skill(
            caster,
            review.SourceRadius
        )
    end

    if target == nil then
        return false, "C4SupportMagicTargetRequired"
    end

    return self._executor:can_support_skill_player(
        caster,
        target,
        review.CastRange
    )
end

--[[
Begins one reviewed friendly-support cast.

For TARGET_ONE skills the target is captured privately and revalidated at hit
time. TARGET_PARTY healing is server-roster based and accepts no client target.

Args:
    caster (any): Server-owned support caster.
    target (any?): Server-owned TARGET_ONE player or nil for party heal.
    creative_skill_id (string): Reviewed Dawnkeeper support skill.
    supplied_now (number?): Optional deterministic scheduler time.

Returns:
    (any?, string?): Cast start evidence or strict denial reason.
]]
function C4SourceSupportMagicCastService:begin_cast(
    caster: any,
    target: any?,
    creative_skill_id: string,
    supplied_now: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4SupportMagicCastDisabled"
    end
    if not valid_owner(caster) then
        return nil, "C4SupportMagicCastOwnerInvalid"
    end
    if self._pending_by_owner[caster] then
        return nil, "C4SupportMagicCastAlreadyPending"
    end

    local review = REVIEWED[creative_skill_id]
    if not review then
        return nil, "C4SupportMagicSkillNotReviewed"
    end

    local ready, ready_reason = preflight(
        self,
        caster,
        target,
        review
    )
    if not ready then
        return nil, ready_reason
    end

    local started, start_reason =
        self._scheduler:begin_cast(
            caster,
            creative_skill_id,
            supplied_now
        )
    if not started then
        return nil, start_reason
    end

    if started.SourceSkillId ~= review.SourceSkillId then
        self._scheduler:cancel_cast(caster, started.CastId)
        return nil, "C4SupportMagicReviewedSourceMismatch"
    end
    if review.CastRange
        and (
            started.SourceCastRange ~= review.CastRange
            or started.SourceEffectRange ~= review.EffectRange
        )
    then
        self._scheduler:cancel_cast(caster, started.CastId)
        return nil, "C4SupportMagicReviewedRangeMismatch"
    end

    self._pending_by_owner[caster] = {
        CastId = started.CastId,
        CreativeSkillId = started.CreativeSkillId,
        CreativeRank = started.CreativeRank,
        SourceSkillId = started.SourceSkillId,
        Kind = review.Kind,
        Target = target,
        EffectRange = review.EffectRange,
        SourceRadius = review.SourceRadius,
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
        SourceCastRange = started.SourceCastRange,
        SourceEffectRange = started.SourceEffectRange,
        TargetBoundServerSide = review.Kind ~= "PartyHeal",
        PartyRosterServerSide = review.Kind == "PartyHeal",
        SourceOnly = true,
        ShotStateConsumed = false,
    }, nil
end

--[[
Cancels one pending friendly-support cast.

Args:
    caster (any): Server-owned caster.
    cast_id (number): Private cast receipt.

Returns:
    (boolean, string?): Cancellation result.
]]
function C4SourceSupportMagicCastService:cancel_cast(
    caster: any,
    cast_id: number
): (boolean, string?)
    local record = self._pending_by_owner[caster]
    if not record or record.CastId ~= cast_id then
        return false, "C4SupportMagicCastReceiptInvalid"
    end

    self._pending_by_owner[caster] = nil
    return self._scheduler:cancel_cast(caster, cast_id)
end

--[[
Revalidates one pending support target immediately before launch MP is spent.

Args:
    self (any): Support bridge instance.
    caster (any): Server-owned caster.
    record (any): Private pending cast record.

Returns:
    (boolean, string?): Launch-target readiness.
]]
local function revalidate(
    self: any,
    caster: any,
    record: any
): (boolean, string?)
    if record.Kind == "PartyHeal" then
        return self._executor:can_party_heal_skill(
            caster,
            record.SourceRadius
        )
    end

    return self._executor:can_support_skill_player(
        caster,
        record.Target,
        record.EffectRange
    )
end

--[[
Executes one launched support family.

Args:
    self (any): Support bridge instance.
    caster (any): Server-owned caster.
    record (any): Private reviewed cast record.

Returns:
    (any?, string?): Live support effect or strict denial reason.
]]
local function execute(
    self: any,
    caster: any,
    record: any
): (any?, string?)
    if record.Kind == "TargetHeal" then
        return self._executor:heal_skill_target(
            caster,
            record.Target,
            record.CreativeSkillId,
            record.CreativeRank
        )
    end
    if record.Kind == "TargetBuff" then
        return self._executor:support_buff_skill_target(
            caster,
            record.Target,
            record.CreativeSkillId,
            record.CreativeRank
        )
    end
    if record.Kind == "PartyHeal" then
        return self._executor:party_heal_skill(
            caster,
            record.CreativeSkillId,
            record.CreativeRank
        )
    end

    return nil, "C4SupportMagicExecutionKindUnsupported"
end

--[[
Launches one ready friendly-support cast.

Range/roster state is rechecked before scheduler launch, so a failed hit-time
target cannot spend launch MP or consume the magical shot.

Args:
    caster (any): Server-owned support caster.
    cast_id (number): Private cast receipt.
    supplied_now (number?): Optional deterministic scheduler time.

Returns:
    (any?, string?): Applied support effect or strict denial reason.
]]
function C4SourceSupportMagicCastService:launch_if_ready(
    caster: any,
    cast_id: number,
    supplied_now: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4SupportMagicCastDisabled"
    end

    local record = self._pending_by_owner[caster]
    if not record or record.CastId ~= cast_id then
        return nil, "C4SupportMagicCastReceiptInvalid"
    end

    local ready, ready_reason = revalidate(
        self,
        caster,
        record
    )
    if not ready then
        self._pending_by_owner[caster] = nil
        self._scheduler:cancel_cast(caster, cast_id)
        return nil, ready_reason
    end

    local launch, launch_reason =
        self._scheduler:launch_if_ready(
            caster,
            cast_id,
            supplied_now
        )
    if not launch then
        return nil, launch_reason
    end

    self._pending_by_owner[caster] = nil
    if launch.CreativeSkillId ~= record.CreativeSkillId
        or launch.CreativeRank ~= record.CreativeRank
        or launch.SourceSkillId ~= record.SourceSkillId
        or launch.ReadyForSourceEffectExecution ~= true
    then
        return nil, "C4SupportMagicLaunchPlanChanged"
    end

    local applied, apply_reason = execute(
        self,
        caster,
        record
    )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4ScheduledSupportMagic",
        CastId = cast_id,
        Launch = launch,
        Application = applied,
        Applied = applied.Applied == true,
        ShotConsumedBySourceCalculation = true,
        ClientAuthority = false,
    }, nil
end

--[[
Clears pending support-cast scheduler state.

Args:
    caster (any): Departing server-owned caster.

Returns:
    nil: Clears bridge and scheduler state.
]]
function C4SourceSupportMagicCastService:clear_owner(caster: any)
    self._pending_by_owner[caster] = nil
    self._scheduler:clear_owner(caster)
end

--[[
Returns detached support-cast capability metadata.

Args:
    None.

Returns:
    any: Gate and reviewed support-family evidence.
]]
function C4SourceSupportMagicCastService:capability(): any
    local count = 0
    for _ in pairs(REVIEWED) do
        count += 1
    end

    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = self._enabled,
        ReviewedSkillCount = count,
        TargetHeal = true,
        TargetBuff = true,
        PartyHeal = true,
        ServerTargetAuthority = true,
        ServerPartyRosterAuthority = true,
        ClientAuthority = false,
    }
end

return C4SourceSupportMagicCastService
