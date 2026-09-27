--!strict
-- Disabled-by-default source Spoil/Sweep bridge for Dwarf salvage.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SkillEffects = require(
    ReplicatedStorage.Core.Shared.C4SkillEffectSource
)

local C4SourceSalvageCastService = {}
C4SourceSalvageCastService.__index =
    C4SourceSalvageCastService

local REVIEWED = table.freeze({
    DwarfSalvageMark = table.freeze({
        SourceSkillId = 254,
        Kind = "SingleMark",
    }),
    DeepclaimerSalvageMark = table.freeze({
        SourceSkillId = 254,
        Kind = "SingleMark",
    }),
    DeepclaimerSalvageFestival = table.freeze({
        SourceSkillId = 302,
        Kind = "AreaMark",
    }),
    DwarfSalvageClaim = table.freeze({
        SourceSkillId = 42,
        Kind = "Sweep",
    }),
})

--[[
Checks one server-owned player-like owner.

Args:
    owner (any): Player or disposable server test owner.

Returns:
    boolean: True when an integral numeric UserId is available.
]]
local function valid_owner(owner: any): boolean
    return (
        type(owner) == "table"
        or typeof(owner) == "Instance"
    )
        and type(owner.UserId) == "number"
        and owner.UserId % 1 == 0
end

--[[
Creates the scheduled Spoil/Sweep bridge.

Args:
    scheduler (any): Existing source cast scheduler.
    salvage (any): Server-owned Dwarf salvage authority.
    area_resolver ((any, any, number) -> {any})?: Optional server-only
        area target resolver for Spoil Festival.

Returns:
    any: Disabled source salvage cast bridge.
]]
function C4SourceSalvageCastService.new(
    scheduler: any,
    salvage: any,
    area_resolver: ((any, any, number) -> {any})?
): any
    assert(
        scheduler
            and type(scheduler.begin_cast) == "function"
            and type(scheduler.cancel_cast) == "function"
            and type(scheduler.launch_if_ready) == "function"
            and type(scheduler.clear_owner) == "function",
        "Salvage cast bridge requires source cast scheduler"
    )
    assert(
        salvage
            and type(salvage.can_mark) == "function"
            and type(salvage.mark) == "function"
            and type(salvage.can_claim) == "function"
            and type(salvage.claim) == "function",
        "Salvage cast bridge requires Dwarf salvage authority"
    )

    return setmetatable({
        _enabled = false,
        _scheduler = scheduler,
        _salvage = salvage,
        _area_resolver = area_resolver,
        _pending_by_owner = {},
    }, C4SourceSalvageCastService)
end

--[[
Changes the source salvage feature gate.

Args:
    enabled (boolean): Desired bridge state.

Returns:
    nil: Updates only this server-local gate.
]]
function C4SourceSalvageCastService:set_enabled(enabled: boolean)
    assert(type(enabled) == "boolean")
    self._enabled = enabled
end

--[[
Reports the source salvage feature gate.

Args:
    None.

Returns:
    boolean: Current bridge state.
]]
function C4SourceSalvageCastService:is_enabled(): boolean
    return self._enabled
end

--[[
Checks current target state before initial MP is spent.

Args:
    self (any): Source salvage bridge.
    owner (any): Server-owned caster.
    target (any): Server-bound creature target.
    review (any): Reviewed salvage family.

Returns:
    (boolean, string?): Readiness or strict denial.
]]
local function preflight(
    self: any,
    owner: any,
    target: any,
    review: any
): (boolean, string?)
    if review.Kind == "Sweep" then
        return self._salvage:can_claim(owner, target)
    end
    if review.Kind == "AreaMark" and not self._area_resolver then
        return false, "C4SalvageAreaResolverUnavailable"
    end
    return self._salvage:can_mark(owner, target)
end

--[[
Begins one reviewed source Spoil/Sweep cast.

Args:
    owner (any): Server-owned caster.
    target (any): Server-bound enemy/corpse target.
    creative_skill_id (string): Reviewed creative salvage skill.
    supplied_now (number?): Optional deterministic scheduler time.

Returns:
    (any?, string?): Cast start evidence or strict denial.
]]
function C4SourceSalvageCastService:begin_cast(
    owner: any,
    target: any,
    creative_skill_id: string,
    supplied_now: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4SalvageCastDisabled"
    end
    if not valid_owner(owner) then
        return nil, "C4SalvageCastOwnerInvalid"
    end
    if self._pending_by_owner[owner] then
        return nil, "C4SalvageCastAlreadyPending"
    end

    local review = REVIEWED[creative_skill_id]
    if not review then
        return nil, "C4SalvageSkillNotReviewed"
    end

    local ready, reason = preflight(
        self,
        owner,
        target,
        review
    )
    if not ready then
        return nil, reason
    end

    local started, start_reason =
        self._scheduler:begin_cast(
            owner,
            creative_skill_id,
            supplied_now
        )
    if not started then
        return nil, start_reason
    end
    if started.SourceSkillId ~= review.SourceSkillId then
        self._scheduler:cancel_cast(owner, started.CastId)
        return nil, "C4SalvageReviewedSourceMismatch"
    end

    self._pending_by_owner[owner] = {
        CastId = started.CastId,
        CreativeSkillId = started.CreativeSkillId,
        CreativeRank = started.CreativeRank,
        SourceSkillId = started.SourceSkillId,
        Kind = review.Kind,
        Target = target,
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
        TargetBoundServerSide = true,
        SourceOnly = true,
    }, nil
end

--[[
Cancels one pending salvage cast.

Args:
    owner (any): Server-owned caster.
    cast_id (number): Private source scheduler receipt.

Returns:
    (boolean, string?): Cancellation result.
]]
function C4SourceSalvageCastService:cancel_cast(
    owner: any,
    cast_id: number
): (boolean, string?)
    local record = self._pending_by_owner[owner]
    if not record or record.CastId ~= cast_id then
        return false, "C4SalvageCastReceiptInvalid"
    end

    self._pending_by_owner[owner] = nil
    return self._scheduler:cancel_cast(owner, cast_id)
end

--[[
Applies an area Spoil result through a server-only target resolver.

Args:
    self (any): Source salvage bridge.
    owner (any): Server-owned caster.
    record (any): Private reviewed cast record.
    source_rank (number): Exact source Spoil Festival rank.

Returns:
    (any?, string?): Area mark evidence or strict denial.
]]
local function apply_area_mark(
    self: any,
    owner: any,
    record: any,
    source_rank: number
): (any?, string?)
    local effect = SkillEffects.get_rank(
        record.SourceSkillId,
        source_rank
    )
    local radius = effect
        and effect.Sets
        and effect.Sets.skillRadius
    if type(radius) ~= "number" or radius <= 0 then
        return nil, "C4SalvageSourceRadiusUnavailable"
    end

    local targets = self._area_resolver(
        owner,
        record.Target,
        radius
    )
    if type(targets) ~= "table" then
        return nil, "C4SalvageAreaResolutionFailed"
    end

    local marked = 0
    for _, target in ipairs(targets) do
        local applied = self._salvage:mark(
            owner,
            target,
            record.SourceSkillId,
            source_rank
        )
        if applied then
            marked += 1
        end
    end

    return {
        Applied = true,
        Kind = "C4SourceAreaSalvageMark",
        SourceRadius = radius,
        MarkedCount = marked,
    }, nil
end

--[[
Executes one launched reviewed salvage family.

Args:
    self (any): Source salvage bridge.
    owner (any): Server-owned caster.
    record (any): Private reviewed cast record.
    source_rank (number): Exact launched source rank.

Returns:
    (any?, string?): Applied salvage evidence or strict denial.
]]
local function execute(
    self: any,
    owner: any,
    record: any,
    source_rank: number
): (any?, string?)
    if record.Kind == "Sweep" then
        return self._salvage:claim(owner, record.Target)
    end
    if record.Kind == "AreaMark" then
        return apply_area_mark(
            self,
            owner,
            record,
            source_rank
        )
    end
    return self._salvage:mark(
        owner,
        record.Target,
        record.SourceSkillId,
        source_rank
    )
end

--[[
Launches one ready source Spoil/Sweep cast.

Target state is checked again before launch-time MP is spent.

Args:
    owner (any): Server-owned caster.
    cast_id (number): Private source scheduler receipt.
    supplied_now (number?): Optional deterministic launch time.

Returns:
    (any?, string?): Applied source salvage result or strict denial.
]]
function C4SourceSalvageCastService:launch_if_ready(
    owner: any,
    cast_id: number,
    supplied_now: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4SalvageCastDisabled"
    end

    local record = self._pending_by_owner[owner]
    if not record or record.CastId ~= cast_id then
        return nil, "C4SalvageCastReceiptInvalid"
    end

    local review = REVIEWED[record.CreativeSkillId]
    local ready, ready_reason = preflight(
        self,
        owner,
        record.Target,
        review
    )
    if not ready then
        self._pending_by_owner[owner] = nil
        self._scheduler:cancel_cast(owner, cast_id)
        return nil, ready_reason
    end

    local launch, launch_reason =
        self._scheduler:launch_if_ready(
            owner,
            cast_id,
            supplied_now
        )
    if not launch then
        return nil, launch_reason
    end

    self._pending_by_owner[owner] = nil
    if launch.CreativeSkillId ~= record.CreativeSkillId
        or launch.CreativeRank ~= record.CreativeRank
        or launch.SourceSkillId ~= record.SourceSkillId
        or launch.ReadyForSourceEffectExecution ~= true
    then
        return nil, "C4SalvageLaunchPlanChanged"
    end

    local applied, apply_reason = execute(
        self,
        owner,
        record,
        launch.SourceRank
    )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4ScheduledSalvage",
        CastId = cast_id,
        Launch = launch,
        Application = applied,
        Applied = applied.Applied == true,
        ClientAuthority = false,
    }, nil
end

--[[
Clears one owner's pending source salvage cast state.

Args:
    owner (any): Departing server-owned caster.

Returns:
    nil: Clears only pending cast state; corpse ownership remains on models.
]]
function C4SourceSalvageCastService:clear_owner(owner: any)
    self._pending_by_owner[owner] = nil
    self._scheduler:clear_owner(owner)
end

--[[
Returns detached staged salvage capability metadata.

Args:
    None.

Returns:
    any: Gate and reviewed source-family evidence.
]]
function C4SourceSalvageCastService:capability(): any
    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = self._enabled,
        SingleTargetSpoil = true,
        SweepOwnedCorpse = true,
        SpoilFestivalReviewed = true,
        SpoilFestivalAreaResolverBound =
            self._area_resolver ~= nil,
        ReviewedSkillCount = 4,
        ClientAuthority = false,
    }
end

return C4SourceSalvageCastService
