--!strict
-- Disabled-by-default scheduled source physical-skill bridge.

local C4SourcePhysicalCastService = {}
C4SourcePhysicalCastService.__index = C4SourcePhysicalCastService

local REVIEWED = table.freeze({
    DeepclaimerHammerShock = table.freeze({
        SourceSkillId = 100,
        CastRange = 40,
        EffectRange = 400,
        ExecutionKind = "Stun",
    }),
    DeepclaimerWildSweep = table.freeze({
        SourceSkillId = 245,
        CastRange = 40,
        EffectRange = 400,
        SourceRadius = 150,
        ExecutionKind = "Area",
    }),
    GearwrightHammerShock = table.freeze({
        SourceSkillId = 100,
        CastRange = 40,
        EffectRange = 400,
        ExecutionKind = "Stun",
    }),
    GearwrightWildSweep = table.freeze({
        SourceSkillId = 245,
        CastRange = 40,
        EffectRange = 400,
        SourceRadius = 150,
        ExecutionKind = "Area",
    }),
    OrcPowerStrike = table.freeze({
        SourceSkillId = 3,
        CastRange = 40,
        EffectRange = 400,
        ExecutionKind = "SingleTarget",
    }),
    OrcIronPunch = table.freeze({
        SourceSkillId = 29,
        CastRange = 40,
        EffectRange = 400,
        ExecutionKind = "SingleTarget",
    }),
    SpiritclawIronFist = table.freeze({
        SourceSkillId = 29,
        CastRange = 40,
        EffectRange = 400,
        ExecutionKind = "SingleTarget",
    }),
    SpiritclawStunningFist = table.freeze({
        SourceSkillId = 120,
        CastRange = 40,
        EffectRange = 400,
        ExecutionKind = "Stun",
    }),
    SpiritclawForceBurst = table.freeze({
        SourceSkillId = 54,
        CastRange = 600,
        EffectRange = 1100,
        ExecutionKind = "Charged",
        RequiredCharges = 1,
    }),
    SpiritclawCripplingPalm = table.freeze({
        SourceSkillId = 95,
        CastRange = 40,
        EffectRange = 400,
        ExecutionKind = "Slow",
    }),
    WarhowlCrushingBlow = table.freeze({
        SourceSkillId = 255,
        CastRange = 40,
        EffectRange = 400,
        ExecutionKind = "SingleTarget",
    }),
    WarhowlSkullbreaker = table.freeze({
        SourceSkillId = 100,
        CastRange = 40,
        EffectRange = 400,
        ExecutionKind = "Stun",
    }),
    AshspeakerSkullshock = table.freeze({
        SourceSkillId = 100,
        CastRange = 40,
        EffectRange = 400,
        ExecutionKind = "Stun",
    }),
    WarhowlSweepingArc = table.freeze({
        SourceSkillId = 245,
        CastRange = 40,
        EffectRange = 400,
        SourceRadius = 150,
        ExecutionKind = "Area",
    }),
})

--[[
Validates one server-owned physical cast owner.

Args:
    player (any): Candidate Player or disposable test owner.

Returns:
    boolean: True when an integral numeric UserId is present.
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
Creates the source physical-skill bridge.

Args:
    scheduler (any): Existing server-owned C4 cast scheduler.
    executor (any): Existing server-owned C4 combat executor.

Returns:
    any: Disabled physical bridge with private pending-cast state.
]]
function C4SourcePhysicalCastService.new(
    scheduler: any,
    executor: any,
    charges: any?
): any
    assert(
        scheduler
            and type(scheduler.begin_cast) == "function"
            and type(scheduler.cancel_cast) == "function"
            and type(scheduler.launch_if_ready) == "function"
            and type(scheduler.clear_owner) == "function",
        "Physical bridge requires source cast scheduler"
    )
    assert(
        executor
            and type(executor.can_physical_skill_npc) == "function"
            and type(executor.physical_skill_npc) == "function",
        "Physical bridge requires source combat executor"
    )

    return setmetatable({
        _enabled = false,
        _scheduler = scheduler,
        _executor = executor,
        _charges = charges,
        _pending_by_owner = {},
    }, C4SourcePhysicalCastService)
end

--[[
Changes the physical cast feature gate.

Args:
    enabled (boolean): Desired bridge state.

Returns:
    nil: Updates only this bridge.
]]
function C4SourcePhysicalCastService:set_enabled(enabled: boolean)
    assert(type(enabled) == "boolean")
    self._enabled = enabled
end

--[[
Reports the physical cast feature gate.

Args:
    None.

Returns:
    boolean: Current bridge state.
]]
function C4SourcePhysicalCastService:is_enabled(): boolean
    return self._enabled
end

--[[
Checks one reviewed physical target at a source range.

Args:
    self (any): Physical bridge.
    player (any): Server-owned attacker.
    target (any): Reviewed NPC target.
    source_range (number): Exact source cast/effect range.

Returns:
    (boolean, string?): Readiness or strict denial reason.
]]
local function preflight(
    self: any,
    player: any,
    target: any,
    source_range: number
): (boolean, string?)
    if target == nil then
        return false, "C4PhysicalTargetRequired"
    end

    return self._executor:can_physical_skill_npc(
        player,
        target,
        source_range
    )
end

--[[
Begins one reviewed source physical cast.

Args:
    player (any): Server-owned attacking player.
    target (any): Private reviewed NPC target.
    creative_skill_id (string): Reviewed creative physical skill.
    supplied_now (number?): Optional deterministic scheduler time.

Returns:
    (any?, string?): Cast start evidence or strict denial reason.
]]
function C4SourcePhysicalCastService:begin_cast(
    player: any,
    target: any,
    creative_skill_id: string,
    supplied_now: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4PhysicalCastDisabled"
    end
    if not valid_owner(player) then
        return nil, "C4PhysicalCastOwnerInvalid"
    end
    if self._pending_by_owner[player] then
        return nil, "C4PhysicalCastAlreadyPending"
    end

    local review = REVIEWED[creative_skill_id]
    if not review then
        return nil, "C4PhysicalSkillNotReviewed"
    end

    if review.RequiredCharges ~= nil then
        if not self._charges
            or type(self._charges.get) ~= "function"
        then
            return nil, "C4PhysicalChargeAuthorityUnavailable"
        end

        local charge_count, charge_reason =
            self._charges:get(player)
        if charge_count == nil then
            return nil, charge_reason
        end
        if charge_count < review.RequiredCharges then
            return nil, "C4SourceChargeInsufficient"
        end
    end

    local ready, ready_reason = preflight(
        self,
        player,
        target,
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

    if started.SourceSkillId ~= review.SourceSkillId then
        self._scheduler:cancel_cast(player, started.CastId)
        return nil, "C4PhysicalReviewedSourceMismatch"
    end

    self._pending_by_owner[player] = {
        CastId = started.CastId,
        CreativeSkillId = started.CreativeSkillId,
        CreativeRank = started.CreativeRank,
        SourceSkillId = started.SourceSkillId,
        Target = target,
        EffectRange = review.EffectRange,
        ExecutionKind = review.ExecutionKind,
        SourceRadius = review.SourceRadius,
        RequiredCharges = review.RequiredCharges,
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
        ExecutionKind = review.ExecutionKind,
        SourceRadius = review.SourceRadius,
        SourceOnly = true,
        ShotStateConsumed = false,
    }, nil
end

--[[
Cancels one pending physical cast.

Args:
    player (any): Server-owned cast owner.
    cast_id (number): Private scheduler receipt.

Returns:
    (boolean, string?): Cancellation result.
]]
function C4SourcePhysicalCastService:cancel_cast(
    player: any,
    cast_id: number
): (boolean, string?)
    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return false, "C4PhysicalCastReceiptInvalid"
    end

    self._pending_by_owner[player] = nil
    return self._scheduler:cancel_cast(player, cast_id)
end

--[[
Executes one reviewed physical launch through its exact source family.

Args:
    self (any): Physical bridge.
    player (any): Server-owned attacking player.
    record (any): Private reviewed bridge record.
    launch (any): Scheduler-approved source launch.
    sequence_id (number?): Existing authoritative combat sequence.

Returns:
    (any?, string?): Live physical application or strict denial reason.
]]
local function execute_reviewed(
    self: any,
    player: any,
    record: any,
    launch: any,
    sequence_id: number?
): (any?, string?)
    if record.ExecutionKind == "Charged" then
        if not self._charges
            or type(self._charges.consume) ~= "function"
        then
            return nil, "C4PhysicalChargeAuthorityUnavailable"
        end
        if type(
            self._executor.charged_physical_skill_npc
        ) ~= "function"
        then
            return nil, "C4ChargedPhysicalExecutorUnavailable"
        end

        local consumed, consume_reason =
            self._charges:consume(
                player,
                record.RequiredCharges
            )
        if not consumed then
            return nil, consume_reason
        end

        return self._executor:charged_physical_skill_npc(
            player,
            record.Target,
            launch.CreativeSkillId,
            launch.CreativeRank,
            consumed.ChargeAfter,
            sequence_id
        )
    end

    if record.ExecutionKind == "Slow" then
        if type(
            self._executor.physical_slow_skill_npc
        ) ~= "function"
        then
            return nil, "C4PhysicalSlowExecutorUnavailable"
        end

        return self._executor:physical_slow_skill_npc(
            player,
            record.Target,
            launch.CreativeSkillId,
            launch.CreativeRank,
            sequence_id
        )
    end

    if record.ExecutionKind == "Stun" then
        if type(self._executor.physical_stun_skill_npc) ~= "function" then
            return nil, "C4PhysicalStunExecutorUnavailable"
        end

        return self._executor:physical_stun_skill_npc(
            player,
            record.Target,
            launch.CreativeSkillId,
            launch.CreativeRank,
            sequence_id
        )
    end

    if record.ExecutionKind == "Area" then
        if type(self._executor.physical_area_skill_npc) ~= "function" then
            return nil, "C4PhysicalAreaExecutorUnavailable"
        end

        return self._executor:physical_area_skill_npc(
            player,
            record.Target,
            launch.CreativeSkillId,
            launch.CreativeRank,
            record.SourceRadius,
            sequence_id
        )
    end

    return self._executor:physical_skill_npc(
        player,
        record.Target,
        launch.CreativeSkillId,
        launch.CreativeRank,
        sequence_id
    )
end

--[[
Launches one ready source physical cast.

Args:
    player (any): Server-owned attacking player.
    cast_id (number): Private scheduler receipt.
    supplied_now (number?): Optional deterministic scheduler time.
    sequence_id (number?): Existing authoritative combat sequence.

Returns:
    (any?, string?): Live source PDAM evidence or strict denial reason.
]]
function C4SourcePhysicalCastService:launch_if_ready(
    player: any,
    cast_id: number,
    supplied_now: number?,
    sequence_id: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4PhysicalCastDisabled"
    end

    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return nil, "C4PhysicalCastReceiptInvalid"
    end

    local ready, ready_reason = preflight(
        self,
        player,
        record.Target,
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
        return nil, "C4PhysicalLaunchPlanChanged"
    end

    local applied, apply_reason = execute_reviewed(
        self,
        player,
        record,
        launch,
        sequence_id
    )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4ScheduledPhysicalCast",
        CastId = cast_id,
        Launch = launch,
        Application = applied,
        Applied = applied.Applied == true,
        ShotConsumedBySourceCalculation = true,
        ClientAuthority = false,
    }, nil
end

--[[
Clears ephemeral physical-cast state for one owner.

Args:
    player (any): Departing server-owned player.

Returns:
    nil: Clears bridge and scheduler records.
]]
function C4SourcePhysicalCastService:clear_owner(player: any)
    self._pending_by_owner[player] = nil
    self._scheduler:clear_owner(player)
end

--[[
Returns detached source physical-cast capability metadata.

Args:
    None.

Returns:
    any: Current gate and reviewed-family evidence.
]]
function C4SourcePhysicalCastService:capability(): any
    local count = 0
    for _ in pairs(REVIEWED) do
        count += 1
    end

    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = self._enabled,
        ReviewedActiveSkillCount = count,
        SingleTargetPdam = true,
        StunPdam = true,
        ChargedPdam = true,
        PhysicalMovementSlow = true,
        TargetAreaPdam = true,
        StunPdamPending = false,
        TargetAreaPdamPending = false,
        ServerTargetAuthority = true,
        ClientAuthority = false,
    }
end

return C4SourcePhysicalCastService
