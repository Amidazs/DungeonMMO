--!strict
-- Disabled-by-default direct MDAM handoff from source scheduler to executor.

local C4SourceDirectMagicCastService = {}
C4SourceDirectMagicCastService.__index =
    C4SourceDirectMagicCastService

local ALLOWED_DIRECT_MDAM = table.freeze({
    EmberweaverEmberBolt = table.freeze({
        SourceSkillId = 1220,
        CastRange = 750,
        EffectRange = 1250,
    }),
    EmberweaverFlameBurst = table.freeze({
        SourceSkillId = 1172,
        CastRange = 150,
        EffectRange = 650,
    }),
    EmberweaverFocusedBolt = table.freeze({
        SourceSkillId = 1274,
        CastRange = 400,
        EffectRange = 900,
    }),
    EmberweaverFrostLance = table.freeze({
        SourceSkillId = 1184,
        CastRange = 600,
        EffectRange = 1100,
        ExecutionKind = "MagicSlow",
    }),
})

local REVIEWED_SKILLS = table.freeze({
    "EmberweaverEmberBolt",
    "EmberweaverFlameBurst",
    "EmberweaverFocusedBolt",
    "EmberweaverFrostLance",
})

--[[
Validates one server-owned cast owner.

Args:
    player (any): Player-like server authority object.

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
Checks one creative skill is approved for the first direct-MDAM bridge.

Args:
    creative_skill_id (string): Creative skill selected by server code.

Returns:
    boolean: True only for the reviewed direct-MDAM family.
]]
local function reviewed_skill(
    creative_skill_id: string
): any?
    return ALLOWED_DIRECT_MDAM[creative_skill_id]
end

--[[
Builds detached start evidence from one private target-bound cast record.

Args:
    started (any): Source scheduler start evidence.

Returns:
    any: Source-only start evidence with no target mutation authority.
]]
local function start_evidence(started: any): any
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
        SourceOnly = true,
        TargetBoundServerSide = true,
        LiveDamageIntegrated = false,
        ShotStateConsumed = false,
    }
end

--[[
Builds one direct-magic bridge around private scheduler and live executor.

Args:
    scheduler (any): C4SourceCastSchedulerService-compatible authority.
    executor (any): C4SourceCombatExecutor-compatible live authority.

Returns:
    any: Disabled server-owned direct-MDAM bridge.
]]
function C4SourceDirectMagicCastService.new(
    scheduler: any,
    executor: any
): any
    assert(
        scheduler
            and type(scheduler.begin_cast) == "function"
            and type(scheduler.cancel_cast) == "function"
            and type(scheduler.launch_if_ready) == "function"
            and type(scheduler.clear_owner) == "function",
        "Direct magic bridge requires source cast scheduler"
    )
    assert(
        executor
            and type(executor.can_magic_skill_npc) == "function"
            and type(executor.magic_skill_npc) == "function"
            and type(executor.magic_slow_skill_npc) == "function",
        "Direct magic bridge requires source combat executor"
    )

    return setmetatable({
        _enabled = false,
        _scheduler = scheduler,
        _executor = executor,
        _pending_by_owner = {},
    }, C4SourceDirectMagicCastService)
end

--[[
Changes only the direct-MDAM bridge gate.

Args:
    enabled (boolean): Whether the reviewed bridge may be requested.

Returns:
    nil: Updates only this server-local feature gate.
]]
function C4SourceDirectMagicCastService:set_enabled(
    enabled: boolean
)
    assert(
        type(enabled) == "boolean",
        "Direct magic bridge gate must be boolean"
    )

    self._enabled = enabled
end

--[[
Reports whether the direct-MDAM bridge is currently enabled.

Args:
    None.

Returns:
    boolean: Current server-local bridge gate.
]]
function C4SourceDirectMagicCastService:is_enabled(): boolean
    return self._enabled
end

--[[
Stores one private target-bound record after the scheduler accepts the cast.

Args:
    self (any): Direct magic bridge instance.
    player (any): Server-owned cast owner.
    enemy (any): Reviewed NPC target captured at cast start.
    started (any): Source scheduler start evidence.

Returns:
    any: Private bridge record.
]]
local function store_pending(
    self: any,
    player: any,
    enemy: any,
    started: any
): any
    local record = {
        CastId = started.CastId,
        CreativeSkillId = started.CreativeSkillId,
        CreativeRank = started.CreativeRank,
        SourceSkillId = started.SourceSkillId,
        CastRange = started.SourceCastRange,
        EffectRange = started.SourceEffectRange,
        Enemy = enemy,
    }

    self._pending_by_owner[player] = record
    return record
end

--[[
Begins one target-bound direct-MDAM cast through the source scheduler.

The target is validated before any initial MP spend and then captured privately
so a later launch cannot be redirected to another NPC.

Args:
    player (any): Server-owned casting player.
    enemy (any): Current reviewed server NPC target.
    creative_skill_id (string): Reviewed direct-MDAM creative skill.
    supplied_now (number?): Optional deterministic scheduler timestamp.

Returns:
    (any?, string?): Start evidence or strict denial reason.
]]
function C4SourceDirectMagicCastService:begin_cast(
    player: any,
    enemy: any,
    creative_skill_id: string,
    supplied_now: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4DirectMagicCastDisabled"
    end
    if not valid_owner(player) then
        return nil, "C4DirectMagicCastOwnerInvalid"
    end
    local review = reviewed_skill(creative_skill_id)
    if not review then
        return nil, "C4DirectMagicSkillNotReviewed"
    end
    if self._pending_by_owner[player] then
        return nil, "C4DirectMagicCastAlreadyPending"
    end

    local target_ready, target_reason =
        self._executor:can_magic_skill_npc(
            player,
            enemy,
            review.CastRange
        )
    if not target_ready then
        return nil, target_reason
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
    if started.SourceSkillId ~= review.SourceSkillId
        or started.SourceCastRange ~= review.CastRange
        or started.SourceEffectRange ~= review.EffectRange
    then
        self._scheduler:cancel_cast(player, started.CastId)
        return nil, "C4DirectMagicReviewedSourceMismatch"
    end

    store_pending(self, player, enemy, started)
    return start_evidence(started), nil
end

--[[
Cancels one pending direct-MDAM cast and its source scheduler receipt.

Args:
    player (any): Server-owned casting player.
    cast_id (number): Private cast receipt.

Returns:
    (boolean, string?): Cancellation result or strict receipt denial.
]]
function C4SourceDirectMagicCastService:cancel_cast(
    player: any,
    cast_id: number
): (boolean, string?)
    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return false, "C4DirectMagicCastReceiptInvalid"
    end

    self._pending_by_owner[player] = nil
    return self._scheduler:cancel_cast(player, cast_id)
end

--[[
Revalidates the bound NPC target before any launch-time resource mutation.

Args:
    self (any): Direct magic bridge instance.
    player (any): Server-owned casting player.
    record (any): Private target-bound cast record.

Returns:
    (boolean, string?): Readiness state or strict target/live denial reason.
]]
local function revalidate_target(
    self: any,
    player: any,
    record: any
): (boolean, string?)
    return self._executor:can_magic_skill_npc(
        player,
        record.Enemy,
        record.EffectRange
    )
end

--[[
Cancels one target-bound cast when hit-time NPC validation fails.

Args:
    self (any): Direct magic bridge instance.
    player (any): Server-owned cast owner.
    record (any): Private target-bound cast record.

Returns:
    (boolean, string?): True when target remains valid, otherwise a strict
        denial reason.
]]
local function validate_launch_target(
    self: any,
    player: any,
    record: any
): (boolean, string?)
    local ready, reason =
        revalidate_target(self, player, record)

    if ready then
        return true, nil
    end

    self._pending_by_owner[player] = nil
    self._scheduler:cancel_cast(player, record.CastId)
    return false, reason
end

--[[
Checks the scheduler launch payload still matches the captured cast identity.

Args:
    record (any): Private target-bound cast record.
    launch (any): Source scheduler launch payload.

Returns:
    boolean: True only when creative identity/rank and readiness are unchanged.
]]
local function launch_plan_matches(
    record: any,
    launch: any
): boolean
    return launch.CreativeSkillId == record.CreativeSkillId
        and launch.CreativeRank == record.CreativeRank
        and launch.SourceSkillId == record.SourceSkillId
        and launch.SourceCastRange == record.CastRange
        and launch.SourceEffectRange == record.EffectRange
        and launch.ReadyForSourceEffectExecution == true
end

--[[
Executes one validated scheduler launch through the existing source executor.

Args:
    self (any): Direct magic bridge instance.
    player (any): Server-owned cast owner.
    record (any): Private target-bound cast record.
    launch (any): Source-effect-ready scheduler payload.
    sequence_id (number?): Existing trusted combat sequence.

Returns:
    (any?, string?): Direct-MDAM application evidence or executor denial.
]]
local function execute_launch(
    self: any,
    player: any,
    record: any,
    launch: any,
    sequence_id: number?
): (any?, string?)
    local review = assert(reviewed_skill(
        launch.CreativeSkillId
    ))
    local applied
    local reason

    if review.ExecutionKind == "MagicSlow" then
        applied, reason =
            self._executor:magic_slow_skill_npc(
                player,
                record.Enemy,
                launch.CreativeSkillId,
                launch.CreativeRank,
                sequence_id
            )
    else
        applied, reason =
            self._executor:magic_skill_npc(
                player,
                record.Enemy,
                launch.CreativeSkillId,
                launch.CreativeRank,
                sequence_id
            )
    end
    if not applied then
        return nil, reason
    end

    return {
        Kind = "C4ScheduledDirectMagic",
        CastId = record.CastId,
        CreativeSkillId = launch.CreativeSkillId,
        CreativeRank = launch.CreativeRank,
        SourceSkillId = launch.SourceSkillId,
        SourceRank = launch.SourceRank,
        Launch = launch,
        Application = applied,
        Applied = applied.Applied == true,
        SourceOnly = false,
        ShotConsumedBySourceCalculation = true,
        ClientAuthority = false,
    }, nil
end

--[[
Launches one ready direct-MDAM cast into the existing source executor.

The NPC is revalidated before the scheduler commits launch-time MP. The source
calculator inside the executor owns the one-use magical shot consumption at
effect execution, so this bridge never consumes or duplicates shot state.

Args:
    player (any): Server-owned casting player.
    cast_id (number): Private direct-magic/scheduler receipt.
    supplied_now (number?): Optional deterministic scheduler timestamp.
    sequence_id (number?): Existing trusted combat action sequence.

Returns:
    (any?, string?): Live direct-MDAM evidence or strict denial reason.
]]
function C4SourceDirectMagicCastService:launch_if_ready(
    player: any,
    cast_id: number,
    supplied_now: number?,
    sequence_id: number?
): (any?, string?)
    if not self._enabled then
        return nil, "C4DirectMagicCastDisabled"
    end

    local record = self._pending_by_owner[player]
    if not record or record.CastId ~= cast_id then
        return nil, "C4DirectMagicCastReceiptInvalid"
    end

    local target_ready, target_reason =
        validate_launch_target(self, player, record)
    if not target_ready then
        return nil, target_reason
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

    if not launch_plan_matches(record, launch) then
        return nil, "C4DirectMagicLaunchPlanChanged"
    end

    return execute_launch(
        self,
        player,
        record,
        launch,
        sequence_id
    )
end

--[[
Clears all private direct-magic/scheduler state for a departing owner.

Args:
    player (any): Server-owned cast owner being removed.

Returns:
    nil: Clears ephemeral cast state and delegates scheduler cleanup.
]]
function C4SourceDirectMagicCastService:clear_owner(
    player: any
)
    self._pending_by_owner[player] = nil
    self._scheduler:clear_owner(player)
end

--[[
Returns detached direct-magic pending state for tests and diagnostics.

Args:
    player (any): Server-owned cast owner.

Returns:
    any: Pending receipt and reviewed skill identity.
]]
function C4SourceDirectMagicCastService:snapshot(
    player: any
): any
    local record = self._pending_by_owner[player]

    return {
        Pending = record ~= nil,
        CastId = if record then record.CastId else nil,
        CreativeSkillId = if record
            then record.CreativeSkillId else nil,
    }
end

--[[
Reports the deliberately narrow direct-MDAM integration boundary.

Args:
    None.

Returns:
    any: Gate, target, shot and executor capability flags.
]]
function C4SourceDirectMagicCastService:capability(): any
    return {
        Available = true,
        DefaultEnabled = false,
        CurrentlyEnabled = self._enabled,
        ReviewedDirectMdamOnly = false,
        ReviewedTargetedMdam = true,
        ReviewedMovementSlowSideEffect = true,
        ReviewedSkillCount = #REVIEWED_SKILLS,
        ReviewedSkills = REVIEWED_SKILLS,
        TargetBoundAtCastStart = true,
        SourceCastRangeAtStart = true,
        SourceEffectRangeAtLaunch = true,
        TargetRevalidatedBeforeLaunchMp = true,
        LaunchMpCommittedBeforeEffectExecution = true,
        ShotConsumptionDelegatedToSourceCalculation = true,
        ClientTargetAuthority = false,
        ClientDamageAuthority = false,
    }
end

return C4SourceDirectMagicCastService
