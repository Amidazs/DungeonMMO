--!strict
-- Disabled-by-default scheduled Human Wizard companion-skill bridge.

local C4SourceCompanionCastService = {}
C4SourceCompanionCastService.__index =
    C4SourceCompanionCastService

local REVIEWED = table.freeze({
    EmberweaverManaCompanion = table.freeze({
        SourceSkillId = 1111,
        Kind = "Summon",
        Role = "Mana",
    }),
    EmberweaverCombatCompanion = table.freeze({
        SourceSkillId = 1225,
        Kind = "Summon",
        Role = "Combat",
    }),
    EmberweaverServitorRecharge = table.freeze({
        SourceSkillId = 1126,
        Kind = "Recharge",
    }),
    EmberweaverServitorHeal = table.freeze({
        SourceSkillId = 1127,
        Kind = "Heal",
    }),
    MoonweaverManaCompanion = table.freeze({
        SourceSkillId = 1226,
        Kind = "Summon",
        Role = "Mana",
    }),
    MoonweaverCombatCompanion = table.freeze({
        SourceSkillId = 1227,
        Kind = "Summon",
        Role = "Combat",
    }),
    MoonweaverServitorRecharge = table.freeze({
        SourceSkillId = 1126,
        Kind = "Recharge",
    }),
    MoonweaverServitorHeal = table.freeze({
        SourceSkillId = 1127,
        Kind = "Heal",
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
Creates the scheduled companion-skill bridge.

Args:
    scheduler (any): Source cast scheduler authority.
    companions (any): Server-owned companion lifecycle authority.

Returns:
    any: Disabled companion-skill bridge.
]]
function C4SourceCompanionCastService.new(
    scheduler: any,
    companions: any
): any
    assert(
        scheduler
            and type(scheduler.begin_cast) == "function"
            and type(scheduler.cancel_cast) == "function"
            and type(scheduler.launch_if_ready) == "function"
            and type(scheduler.clear_owner) == "function",
        "Companion cast bridge requires source cast scheduler"
    )
    assert(
        companions
            and type(companions.summon) == "function"
            and type(companions.can_target_owned) == "function"
            and type(companions.heal_owned) == "function"
            and type(companions.recharge_owned) == "function",
        "Companion cast bridge requires companion authority"
    )

    return setmetatable({
        _enabled = false,
        _scheduler = scheduler,
        _companions = companions,
        _pending_by_owner = {},
    }, C4SourceCompanionCastService)
end

--[[
Changes the companion-cast feature gate.

Args:
    enabled (boolean): Desired bridge state.

Returns:
    nil: Updates only this server-local gate.
]]
function C4SourceCompanionCastService:set_enabled(enabled: boolean)
    assert(type(enabled) == "boolean")
    self._enabled = enabled
end

--[[
Reports the companion-cast feature gate.

Args:
    None.

Returns:
    boolean: Current bridge state.
]]
function C4SourceCompanionCastService:is_enabled(): boolean
    return self._enabled
end

--[[
Checks one reviewed skill's target state before spending initial MP.

Args:
    self (any): Companion cast bridge.
    player (any): Server-owned caster.
    review (any): Reviewed companion skill metadata.

Returns:
    (boolean, string?): Readiness or strict denial reason.
]]
local function preflight(
    self: any,
    player: any,
    review: any
): (boolean, string?)
    if review.Kind == "Summon" then
        local snapshot = self._companions:snapshot(player)
        if snapshot.Active then
            return false, "C4CompanionAlreadySummoned"
        end
        return true, nil
    end

    return self._companions:can_target_owned(player)
end

--[[
Begins one reviewed companion source cast.

Args:
    player (any): Server-owned caster.
    creative_skill_id (string): Reviewed companion skill.
    supplied_now (number?): Optional deterministic scheduler time.

Returns:
    (any?, string?): Cast start evidence or strict denial reason.
]]
function C4SourceCompanionCastService:begin_cast(
    player: any,
    creative_skill_id: string,
    supplied_now: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4CompanionCastDisabled"
    end
    if not valid_owner(player) then
        return nil, "C4CompanionCastOwnerInvalid"
    end
    if self._pending_by_owner[player] then
        return nil, "C4CompanionCastAlreadyPending"
    end

    local review = REVIEWED[creative_skill_id]
    if not review then
        return nil, "C4CompanionSkillNotReviewed"
    end

    local ready, ready_reason = preflight(
        self,
        player,
        review
    )
    if not ready then
        return nil, ready_reason
    end

    local started, start_reason =
        self._scheduler:begin_cast(
            player,
            creative_skill_id,
            supplied_now
        )
    if not started then
        return nil, start_reason
    end
    if started.SourceSkillId ~= review.SourceSkillId then
        self._scheduler:cancel_cast(player, started.CastId)
        return nil, "C4CompanionReviewedSourceMismatch"
    end

    self._pending_by_owner[player] = {
        CastId = started.CastId,
        CreativeSkillId = started.CreativeSkillId,
        CreativeRank = started.CreativeRank,
        SourceSkillId = started.SourceSkillId,
        Kind = review.Kind,
        Role = review.Role,
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
        CompanionTargetServerOwned = true,
        ShotStateConsumed = false,
    }, nil
end

--[[
Cancels one pending companion cast.

Args:
    player (any): Server-owned caster.
    cast_id (number): Private cast receipt.

Returns:
    (boolean, string?): Cancellation result.
]]
function C4SourceCompanionCastService:cancel_cast(
    player: any,
    cast_id: number
): (boolean, string?)
    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return false, "C4CompanionCastReceiptInvalid"
    end

    self._pending_by_owner[player] = nil
    return self._scheduler:cancel_cast(player, cast_id)
end

--[[
Applies one launched companion skill through its server authority.

Args:
    self (any): Companion cast bridge.
    player (any): Server-owned caster.
    record (any): Captured reviewed skill identity.

Returns:
    (any?, string?): Companion effect evidence or strict denial reason.
]]
local function execute(
    self: any,
    player: any,
    record: any
): (any?, string?)
    if record.Kind == "Summon" then
        return self._companions:summon(
            player,
            record.CreativeSkillId,
            record.CreativeRank,
            record.Role
        )
    end
    if record.Kind == "Heal" then
        return self._companions:heal_owned(
            player,
            record.CreativeSkillId,
            record.CreativeRank
        )
    end
    if record.Kind == "Recharge" then
        return self._companions:recharge_owned(
            player,
            record.CreativeSkillId,
            record.CreativeRank
        )
    end

    return nil, "C4CompanionExecutionKindUnsupported"
end

--[[
Launches one ready companion source cast.

Pet-target skills revalidate the current owned companion before launch-time MP.
Summons revalidate that the owner still has no companion.

Args:
    player (any): Server-owned caster.
    cast_id (number): Private cast receipt.
    supplied_now (number?): Optional deterministic scheduler time.

Returns:
    (any?, string?): Applied companion effect or strict denial reason.
]]
function C4SourceCompanionCastService:launch_if_ready(
    player: any,
    cast_id: number,
    supplied_now: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4CompanionCastDisabled"
    end

    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return nil, "C4CompanionCastReceiptInvalid"
    end

    local review = REVIEWED[record.CreativeSkillId]
    local ready, ready_reason = preflight(
        self,
        player,
        review
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
        return nil, "C4CompanionLaunchPlanChanged"
    end

    local applied, apply_reason = execute(
        self,
        player,
        record
    )
    if not applied then
        return nil, apply_reason
    end

    return {
        Kind = "C4ScheduledCompanionMagic",
        CastId = cast_id,
        Launch = launch,
        Application = applied,
        Applied = applied.Applied == true,
        ClientAuthority = false,
    }, nil
end

--[[
Clears pending companion-cast scheduler state.

Args:
    player (any): Departing server-owned caster.

Returns:
    nil: Clears bridge and scheduler state.
]]
function C4SourceCompanionCastService:clear_owner(player: any)
    self._pending_by_owner[player] = nil
    self._scheduler:clear_owner(player)
end

--[[
Returns detached companion-cast capability metadata.

Args:
    None.

Returns:
    any: Gate and reviewed skill-family evidence.
]]
function C4SourceCompanionCastService:capability(): any
    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = self._enabled,
        ManaCompanion = true,
        CombatCompanion = true,
        ServitorHeal = true,
        ServitorRecharge = true,
        ClientAuthority = false,
    }
end

return C4SourceCompanionCastService
