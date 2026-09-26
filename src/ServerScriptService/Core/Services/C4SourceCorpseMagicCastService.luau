--!strict
-- Disabled-by-default scheduled Human Wizard corpse-magic bridge.

local C4SourceCorpseMagicCastService = {}
C4SourceCorpseMagicCastService.__index =
    C4SourceCorpseMagicCastService

local REVIEWED_CORPSE_MAGIC = table.freeze({
    EmberweaverCorpseSiphon = table.freeze({
        SourceSkillId = 1151,
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
    return (
        type(player) == "table"
        or typeof(player) == "Instance"
    )
        and type(player.UserId) == "number"
        and player.UserId % 1 == 0
end

--[[
Builds a scheduled corpse-magic bridge.

Args:
    scheduler (any): Source cast scheduler authority.
    executor (any): Source combat executor authority.

Returns:
    any: Disabled corpse-magic bridge.
]]
function C4SourceCorpseMagicCastService.new(
    scheduler: any,
    executor: any
): any
    assert(
        scheduler
            and type(scheduler.begin_cast) == "function"
            and type(scheduler.cancel_cast) == "function"
            and type(scheduler.launch_if_ready) == "function"
            and type(scheduler.clear_owner) == "function",
        "Corpse magic bridge requires source cast scheduler"
    )
    assert(
        executor
            and type(executor.can_corpse_skill_npc) == "function"
            and type(executor.corpse_drain_skill_npc) == "function",
        "Corpse magic bridge requires source combat executor"
    )

    return setmetatable({
        _enabled = false,
        _scheduler = scheduler,
        _executor = executor,
        _pending_by_owner = {},
    }, C4SourceCorpseMagicCastService)
end

--[[
Changes the corpse-magic feature gate.

Args:
    enabled (boolean): Desired bridge state.

Returns:
    nil: Updates only this server-local feature gate.
]]
function C4SourceCorpseMagicCastService:set_enabled(enabled: boolean)
    assert(type(enabled) == "boolean")
    self._enabled = enabled
end

--[[
Reports the corpse-magic feature gate.

Args:
    None.

Returns:
    boolean: Current bridge state.
]]
function C4SourceCorpseMagicCastService:is_enabled(): boolean
    return self._enabled
end

--[[
Begins one reviewed corpse-target source cast.

Args:
    player (any): Server-owned caster.
    corpse (any): Current reviewed NPC corpse.
    creative_skill_id (string): Reviewed corpse skill.
    supplied_now (number?): Optional deterministic scheduler time.

Returns:
    (any?, string?): Start evidence or strict denial reason.
]]
function C4SourceCorpseMagicCastService:begin_cast(
    player: any,
    corpse: any,
    creative_skill_id: string,
    supplied_now: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4CorpseMagicCastDisabled"
    end
    if not valid_owner(player) then
        return nil, "C4CorpseMagicCastOwnerInvalid"
    end

    local review = REVIEWED_CORPSE_MAGIC[creative_skill_id]
    if not review then
        return nil, "C4CorpseMagicSkillNotReviewed"
    end
    if self._pending_by_owner[player] then
        return nil, "C4CorpseMagicCastAlreadyPending"
    end

    local ready, ready_reason =
        self._executor:can_corpse_skill_npc(
            player,
            corpse,
            review.CastRange
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
    if started.SourceSkillId ~= review.SourceSkillId
        or started.SourceCastRange ~= review.CastRange
        or started.SourceEffectRange ~= review.EffectRange
    then
        self._scheduler:cancel_cast(player, started.CastId)
        return nil, "C4CorpseMagicReviewedSourceMismatch"
    end

    self._pending_by_owner[player] = {
        CastId = started.CastId,
        CreativeSkillId = started.CreativeSkillId,
        CreativeRank = started.CreativeRank,
        SourceSkillId = started.SourceSkillId,
        Corpse = corpse,
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
Cancels one pending corpse-magic cast.

Args:
    player (any): Server-owned caster.
    cast_id (number): Private cast receipt.

Returns:
    (boolean, string?): Cancellation result.
]]
function C4SourceCorpseMagicCastService:cancel_cast(
    player: any,
    cast_id: number
): (boolean, string?)
    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return false, "C4CorpseMagicCastReceiptInvalid"
    end

    self._pending_by_owner[player] = nil
    return self._scheduler:cancel_cast(player, cast_id)
end

--[[
Launches one ready corpse-magic cast.

Args:
    player (any): Server-owned caster.
    cast_id (number): Private cast receipt.
    supplied_now (number?): Optional deterministic scheduler time.
    sequence_id (number?): Existing authoritative sequence.

Returns:
    (any?, string?): Live corpse-drain evidence or strict denial reason.
]]
function C4SourceCorpseMagicCastService:launch_if_ready(
    player: any,
    cast_id: number,
    supplied_now: number?,
    sequence_id: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4CorpseMagicCastDisabled"
    end

    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return nil, "C4CorpseMagicCastReceiptInvalid"
    end

    local ready, ready_reason =
        self._executor:can_corpse_skill_npc(
            player,
            record.Corpse,
            record.EffectRange
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
        return nil, "C4CorpseMagicLaunchPlanChanged"
    end

    local applied, apply_reason =
        self._executor:corpse_drain_skill_npc(
            player,
            record.Corpse,
            launch.CreativeSkillId,
            launch.CreativeRank,
            sequence_id
        )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4ScheduledCorpseMagic",
        CastId = cast_id,
        Launch = launch,
        Application = applied,
        Applied = applied.Applied == true,
        ShotConsumedBySourceCalculation = true,
        ClientAuthority = false,
    }, nil
end

--[[
Clears ephemeral corpse-cast state.

Args:
    player (any): Departing server-owned caster.

Returns:
    nil: Clears private bridge and scheduler state.
]]
function C4SourceCorpseMagicCastService:clear_owner(player: any)
    self._pending_by_owner[player] = nil
    self._scheduler:clear_owner(player)
end

--[[
Returns detached corpse-magic capability metadata.

Args:
    None.

Returns:
    any: Default gate and reviewed family evidence.
]]
function C4SourceCorpseMagicCastService:capability(): any
    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = self._enabled,
        ReviewedCorpseSiphon = true,
        CorpseTargetServerOwned = true,
        ClientAuthority = false,
    }
end

return C4SourceCorpseMagicCastService
