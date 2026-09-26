--!strict
-- Disabled-by-default scheduled source self-magic bridge.

local C4SourceSelfMagicCastService = {}
C4SourceSelfMagicCastService.__index = C4SourceSelfMagicCastService

local REVIEWED_SELF_MAGIC = table.freeze({
    EmberweaverBloodToMana = table.freeze({
        SourceSkillId = 1157,
        ExecutionKind = "ManaHeal",
    }),
    GreenwardScoutElementalHeal = table.freeze({
        SourceSkillId = 58,
        ExecutionKind = "Heal",
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
Returns reviewed self-magic metadata.

Args:
    creative_skill_id (string): Server-selected creative skill.

Returns:
    any?: Reviewed metadata, otherwise nil.
]]
local function reviewed_skill(creative_skill_id: string): any?
    return REVIEWED_SELF_MAGIC[creative_skill_id]
end

--[[
Builds a scheduled self-magic bridge.

Args:
    scheduler (any): Source cast scheduler authority.
    executor (any): Source combat executor authority.

Returns:
    any: Disabled self-magic bridge.
]]
function C4SourceSelfMagicCastService.new(
    scheduler: any,
    executor: any
): any
    assert(
        scheduler
            and type(scheduler.begin_cast) == "function"
            and type(scheduler.cancel_cast) == "function"
            and type(scheduler.launch_if_ready) == "function"
            and type(scheduler.clear_owner) == "function",
        "Self magic bridge requires source cast scheduler"
    )
    assert(
        executor
            and type(executor.mana_heal_self) == "function"
            and type(executor.heal_skill) == "function",
        "Self magic bridge requires source combat executor"
    )

    return setmetatable({
        _enabled = false,
        _scheduler = scheduler,
        _executor = executor,
        _pending_by_owner = {},
    }, C4SourceSelfMagicCastService)
end

--[[
Changes the self-magic feature gate.

Args:
    enabled (boolean): Desired bridge state.

Returns:
    nil: Updates only this server-local feature gate.
]]
function C4SourceSelfMagicCastService:set_enabled(enabled: boolean)
    assert(type(enabled) == "boolean")
    self._enabled = enabled
end

--[[
Reports the self-magic feature gate.

Args:
    None.

Returns:
    boolean: Current bridge state.
]]
function C4SourceSelfMagicCastService:is_enabled(): boolean
    return self._enabled
end

--[[
Begins one reviewed self-targeted source cast.

Args:
    player (any): Server-owned caster.
    creative_skill_id (string): Reviewed self skill.
    supplied_now (number?): Optional deterministic scheduler time.

Returns:
    (any?, string?): Start evidence or strict denial reason.
]]
function C4SourceSelfMagicCastService:begin_cast(
    player: any,
    creative_skill_id: string,
    supplied_now: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4SelfMagicCastDisabled"
    end
    if not valid_owner(player) then
        return nil, "C4SelfMagicCastOwnerInvalid"
    end

    local review = reviewed_skill(creative_skill_id)
    if not review then
        return nil, "C4SelfMagicSkillNotReviewed"
    end
    if self._pending_by_owner[player] then
        return nil, "C4SelfMagicCastAlreadyPending"
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
        return nil, "C4SelfMagicReviewedSourceMismatch"
    end

    self._pending_by_owner[player] = {
        CastId = started.CastId,
        CreativeSkillId = started.CreativeSkillId,
        CreativeRank = started.CreativeRank,
        SourceSkillId = started.SourceSkillId,
        ExecutionKind = review.ExecutionKind,
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
Cancels one pending self-magic cast.

Args:
    player (any): Server-owned caster.
    cast_id (number): Private cast receipt.

Returns:
    (boolean, string?): Cancellation result.
]]
function C4SourceSelfMagicCastService:cancel_cast(
    player: any,
    cast_id: number
): (boolean, string?)
    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return false, "C4SelfMagicCastReceiptInvalid"
    end

    self._pending_by_owner[player] = nil
    return self._scheduler:cancel_cast(player, cast_id)
end

--[[
Launches one ready self-magic cast.

Args:
    player (any): Server-owned caster.
    cast_id (number): Private cast receipt.
    supplied_now (number?): Optional deterministic scheduler time.
    sequence_id (number?): Existing authoritative sequence.

Returns:
    (any?, string?): Live self-effect evidence or strict denial reason.
]]
function C4SourceSelfMagicCastService:launch_if_ready(
    player: any,
    cast_id: number,
    supplied_now: number?,
    sequence_id: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4SelfMagicCastDisabled"
    end

    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return nil, "C4SelfMagicCastReceiptInvalid"
    end

    local launch, reason = self._scheduler:launch_if_ready(
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
        return nil, "C4SelfMagicLaunchPlanChanged"
    end

    local applied
    local apply_reason

    if record.ExecutionKind == "Heal" then
        applied, apply_reason = self._executor:heal_skill(
            player,
            launch.CreativeSkillId,
            launch.CreativeRank
        )
    else
        applied, apply_reason = self._executor:mana_heal_self(
            player,
            launch.CreativeSkillId,
            launch.CreativeRank,
            sequence_id
        )
    end
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4ScheduledSelfMagic",
        CastId = cast_id,
        Launch = launch,
        Application = applied,
        Applied = applied.Applied == true,
        ShotConsumedBySourceCalculation = true,
        ClientAuthority = false,
    }, nil
end

--[[
Clears ephemeral self-cast state.

Args:
    player (any): Departing server-owned caster.

Returns:
    nil: Clears private bridge and scheduler state.
]]
function C4SourceSelfMagicCastService:clear_owner(player: any)
    self._pending_by_owner[player] = nil
    self._scheduler:clear_owner(player)
end

--[[
Returns detached self-magic capability metadata.

Args:
    None.

Returns:
    any: Default gate and reviewed family evidence.
]]
function C4SourceSelfMagicCastService:capability(): any
    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = self._enabled,
        ReviewedBloodToMana = true,
        ReviewedScoutElementalHeal = true,
        ServerTargetAuthority = true,
        ClientAuthority = false,
    }
end

return C4SourceSelfMagicCastService
