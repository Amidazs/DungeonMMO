--!strict
-- Disabled-by-default Dark Elf Assassin / Veilblade source cast bridge.

local C4SourceVeilbladeCastService = {}
C4SourceVeilbladeCastService.__index =
    C4SourceVeilbladeCastService

local REVIEWED = table.freeze({
    VeilbladeUmbralSiphon = table.freeze({
        SourceSkillId = 70,
        Kind = "Drain",
        CastRange = 600,
        EffectRange = 1100,
    }),
    VeilbladeDefenseAura = table.freeze({
        SourceSkillId = 91,
        Kind = "SelfBuff",
    }),
    VeilbladeVenomHex = table.freeze({
        SourceSkillId = 129,
        Kind = "Periodic",
        CastRange = 600,
        EffectRange = 1100,
    }),
    VeilbladeMindRend = table.freeze({
        SourceSkillId = 2,
        Kind = "Confusion",
        CastRange = 600,
        EffectRange = 1100,
    }),
    VeilbladeCrimsonSting = table.freeze({
        SourceSkillId = 223,
        Kind = "PhysicalStatus",
        CastRange = 40,
        EffectRange = 400,
    }),
    VeilbladeAttackAura = table.freeze({
        SourceSkillId = 77,
        Kind = "SelfBuff",
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
    return (
        type(player) == "table"
        or typeof(player) == "Instance"
    )
        and type(player.UserId) == "number"
        and player.UserId % 1 == 0
end

--[[
Creates the Veilblade scheduled cast bridge.

Args:
    scheduler (any): Source scheduler authority.
    executor (any): Live source executor authority.

Returns:
    any: Disabled Veilblade bridge.
]]
function C4SourceVeilbladeCastService.new(
    scheduler: any,
    executor: any
): any
    assert(
        scheduler
            and type(scheduler.begin_cast) == "function"
            and type(scheduler.cancel_cast) == "function"
            and type(scheduler.launch_if_ready) == "function"
            and type(scheduler.clear_owner) == "function",
        "Veilblade bridge requires source cast scheduler"
    )
    assert(
        executor
            and type(executor.can_magic_skill_npc) == "function"
            and type(executor.magic_drain_skill_npc) == "function"
            and type(executor.status_skill_npc) == "function"
            and type(executor.confusion_skill_npc) == "function"
            and type(executor.physical_status_skill_npc) == "function"
            and type(executor.self_buff_skill) == "function",
        "Veilblade bridge requires source combat executor"
    )

    return setmetatable({
        _enabled = false,
        _scheduler = scheduler,
        _executor = executor,
        _pending_by_owner = {},
    }, C4SourceVeilbladeCastService)
end

--[[
Changes the Veilblade cast feature gate.

Args:
    enabled (boolean): Desired bridge state.

Returns:
    nil: Updates only this bridge.
]]
function C4SourceVeilbladeCastService:set_enabled(enabled: boolean)
    assert(type(enabled) == "boolean")
    self._enabled = enabled
end

--[[
Reports the Veilblade cast feature gate.

Args:
    None.

Returns:
    boolean: Current bridge state.
]]
function C4SourceVeilbladeCastService:is_enabled(): boolean
    return self._enabled
end

--[[
Checks a reviewed Veilblade target before MP is spent.

Args:
    self (any): Veilblade bridge.
    player (any): Server-owned caster.
    target (any?): Reviewed NPC target for hostile skills.
    review (any): Reviewed skill metadata.
    range_key (string): CastRange or EffectRange.

Returns:
    (boolean, string?): Readiness or strict denial reason.
]]
local function preflight(
    self: any,
    player: any,
    target: any?,
    review: any,
    range_key: string
): (boolean, string?)
    if review.Kind == "SelfBuff" then
        return true, nil
    end

    if target == nil then
        return false, "C4VeilbladeTargetRequired"
    end

    return self._executor:can_magic_skill_npc(
        player,
        target,
        review[range_key]
    )
end

--[[
Begins one reviewed Veilblade source cast.

Args:
    player (any): Server-owned caster.
    target (any?): Private NPC target or nil for self buff.
    creative_skill_id (string): Reviewed Veilblade skill.
    supplied_now (number?): Optional deterministic scheduler time.

Returns:
    (any?, string?): Cast start evidence or strict denial reason.
]]
function C4SourceVeilbladeCastService:begin_cast(
    player: any,
    target: any?,
    creative_skill_id: string,
    supplied_now: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4VeilbladeCastDisabled"
    end
    if not valid_owner(player) then
        return nil, "C4VeilbladeCastOwnerInvalid"
    end
    if self._pending_by_owner[player] then
        return nil, "C4VeilbladeCastAlreadyPending"
    end

    local review = REVIEWED[creative_skill_id]
    if not review then
        return nil, "C4VeilbladeSkillNotReviewed"
    end

    local ready, ready_reason = preflight(
        self,
        player,
        target,
        review,
        "CastRange"
    )
    if not ready then
        return nil, ready_reason
    end

    local started, start_reason = self._scheduler:begin_cast(
        player,
        creative_skill_id,
        supplied_now
    )
    if not started then
        return nil, start_reason
    end

    if started.SourceSkillId ~= review.SourceSkillId then
        self._scheduler:cancel_cast(player, started.CastId)
        return nil, "C4VeilbladeReviewedSourceMismatch"
    end

    self._pending_by_owner[player] = {
        CastId = started.CastId,
        CreativeSkillId = started.CreativeSkillId,
        CreativeRank = started.CreativeRank,
        SourceSkillId = started.SourceSkillId,
        Kind = review.Kind,
        Target = target,
        EffectRange = review.EffectRange,
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
        TargetBoundServerSide = true,
        SourceOnly = true,
        ShotStateConsumed = false,
    }, nil
end

--[[
Cancels one pending Veilblade cast.

Args:
    player (any): Server-owned caster.
    cast_id (number): Private cast receipt.

Returns:
    (boolean, string?): Cancellation result.
]]
function C4SourceVeilbladeCastService:cancel_cast(
    player: any,
    cast_id: number
): (boolean, string?)
    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return false, "C4VeilbladeCastReceiptInvalid"
    end

    self._pending_by_owner[player] = nil
    return self._scheduler:cancel_cast(player, cast_id)
end

--[[
Executes one launched Veilblade active family.

Args:
    self (any): Veilblade bridge.
    player (any): Server-owned caster.
    record (any): Private reviewed cast record.
    sequence_id (number?): Trusted combat sequence.

Returns:
    (any?, string?): Live source application or denial reason.
]]
local function execute(
    self: any,
    player: any,
    record: any,
    sequence_id: number?
): (any?, string?)
    if record.Kind == "SelfBuff" then
        return self._executor:self_buff_skill(
            player,
            record.CreativeSkillId,
            record.CreativeRank
        )
    end
    if record.Kind == "Drain" then
        return self._executor:magic_drain_skill_npc(
            player,
            record.Target,
            record.CreativeSkillId,
            record.CreativeRank,
            sequence_id
        )
    end
    if record.Kind == "Periodic" then
        return self._executor:status_skill_npc(
            player,
            record.Target,
            record.CreativeSkillId,
            record.CreativeRank,
            sequence_id
        )
    end
    if record.Kind == "Confusion" then
        return self._executor:confusion_skill_npc(
            player,
            record.Target,
            record.CreativeSkillId,
            record.CreativeRank,
            sequence_id
        )
    end
    if record.Kind == "PhysicalStatus" then
        return self._executor:physical_status_skill_npc(
            player,
            record.Target,
            record.CreativeSkillId,
            record.CreativeRank,
            sequence_id
        )
    end

    return nil, "C4VeilbladeExecutionKindUnsupported"
end

--[[
Launches one ready Veilblade source cast.

Args:
    player (any): Server-owned caster.
    cast_id (number): Private cast receipt.
    supplied_now (number?): Optional deterministic scheduler time.
    sequence_id (number?): Trusted combat sequence.

Returns:
    (any?, string?): Applied Veilblade effect or denial reason.
]]
function C4SourceVeilbladeCastService:launch_if_ready(
    player: any,
    cast_id: number,
    supplied_now: number?,
    sequence_id: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4VeilbladeCastDisabled"
    end

    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return nil, "C4VeilbladeCastReceiptInvalid"
    end

    local review = REVIEWED[record.CreativeSkillId]
    local ready, ready_reason = preflight(
        self,
        player,
        record.Target,
        review,
        "EffectRange"
    )
    if not ready then
        self._pending_by_owner[player] = nil
        self._scheduler:cancel_cast(player, cast_id)
        return nil, ready_reason
    end

    local launch, launch_reason =
        self._scheduler:launch_if_ready(
            player,
            cast_id,
            supplied_now
        )
    if not launch then
        return nil, launch_reason
    end

    self._pending_by_owner[player] = nil
    if launch.CreativeSkillId ~= record.CreativeSkillId
        or launch.CreativeRank ~= record.CreativeRank
        or launch.SourceSkillId ~= record.SourceSkillId
        or launch.ReadyForSourceEffectExecution ~= true
    then
        return nil, "C4VeilbladeLaunchPlanChanged"
    end

    local applied, apply_reason = execute(
        self,
        player,
        record,
        sequence_id
    )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4ScheduledVeilbladeCast",
        CastId = cast_id,
        Launch = launch,
        Application = applied,
        Applied = applied.Applied == true,
        ClientAuthority = false,
    }, nil
end

--[[
Clears pending Veilblade scheduler state.

Args:
    player (any): Departing server-owned caster.

Returns:
    nil: Clears bridge and scheduler state.
]]
function C4SourceVeilbladeCastService:clear_owner(player: any)
    self._pending_by_owner[player] = nil
    self._scheduler:clear_owner(player)
end

--[[
Returns detached Veilblade cast capability metadata.

Args:
    None.

Returns:
    any: Reviewed active-family evidence.
]]
function C4SourceVeilbladeCastService:capability(): any
    local count = 0
    for _ in pairs(REVIEWED) do
        count += 1
    end

    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = self._enabled,
        ReviewedActiveSkillCount = count,
        Drain = true,
        Poison = true,
        Confusion = true,
        PhysicalBleed = true,
        SelfBuff = true,
        ClientAuthority = false,
    }
end

return C4SourceVeilbladeCastService
