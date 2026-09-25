--!strict
-- Source-only final cast-time/reuse planner for authenticated magic skills.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Rules = require(
    ReplicatedStorage.Core.Shared.C4SkillRuntimeRules
)
local DefaultCastContract = require(
    ServerScriptService.Core.Services.C4SourceCastContractService
)
local Runtime = require(
    ServerScriptService.Core.Services.ProgressionRuntimeState
)

local C4SourceCastTimingService = {}
C4SourceCastTimingService.__index = C4SourceCastTimingService

local MASTERY_BLOCKER = "OriginalSkillMasteryRollNotIntegrated"

--[[
Returns the default authenticated source stat boundary.

Args:
    user_id (number): Current server-owned character owner.

Returns:
    (any?, string?): Current source migration boundary or denial reason.
]]
local function default_boundary_provider(
    user_id: number
): (any?, string?)
    return Runtime.get_c4_resource_migration_boundary(user_id)
end

--[[
Reads one finite source stat from a ready migration candidate.

Args:
    boundary (any): Authenticated source migration boundary.
    stat_id (string): Exact source stat key.
    allow_zero (boolean): Whether zero is a valid value.

Returns:
    (number?, string?): Valid value or a field-specific strict denial.
]]
local function source_stat(
    boundary: any,
    stat_id: string,
    allow_zero: boolean
): (number?, string?)
    local stats = boundary and boundary.SourceStatCandidate
    local value = type(stats) == "table"
        and stats[stat_id] or nil
    local minimum_ok = if allow_zero
        then type(value) == "number" and value >= 0
        else type(value) == "number" and value > 0

    if boundary == nil
        or boundary.SourceStatCandidateReady ~= true
        or not minimum_ok
        or value ~= value
        or value >= math.huge
    then
        return nil, "OriginalSourceStatUnavailable:" .. stat_id
    end

    return value, nil
end

--[[
Resolves all authenticated source stats required for magic timing/reuse.

Args:
    boundary (any): Current source migration boundary.

Returns:
    (any?, string?): Attack speed, reuse multiplier and mastery stat.
]]
local function timing_stats(boundary: any): (any?, string?)
    local attack_speed, speed_reason = source_stat(
        boundary,
        "MAGICAL_ATTACK_SPEED",
        false
    )
    if attack_speed == nil then
        return nil, speed_reason
    end

    local reuse_multiplier, reuse_reason = source_stat(
        boundary,
        "MAGICAL_SKILL_REUSE",
        true
    )
    if reuse_multiplier == nil then
        return nil, reuse_reason
    end

    local mastery, mastery_reason = source_stat(
        boundary,
        "SKILL_MASTERY",
        true
    )
    if mastery == nil then
        return nil, mastery_reason
    end

    return {
        MagicAttackSpeed = attack_speed,
        MagicReuseMultiplier = reuse_multiplier,
        SkillMastery = mastery,
    }, nil
end

--[[
Reads magical shot state without consuming either one-use charge.

Args:
    shot_authority (any): Server-owned source shot authority.
    user_id (number): Authenticated cast owner.

Returns:
    (boolean, boolean): Spiritshot and Blessed Spiritshot charge flags.
]]
local function peek_magic_shots(
    shot_authority: any,
    user_id: number
): (boolean, boolean)
    local snapshot = shot_authority:snapshot(user_id)

    return snapshot.Spiritshot == true,
        snapshot.BlessedSpiritshot == true
end

--[[
Calculates final hit/cool timing from source stats and read-only shot state.

Args:
    contract (any): Exact authenticated source cast contract.
    stats (any): Authenticated source timing stats.
    spiritshot (boolean): Current ordinary Spiritshot charge.
    blessed_spiritshot (boolean): Current blessed charge.

Returns:
    any: Final hit/cool/interrupt timing.
]]
local function cast_times(
    contract: any,
    stats: any,
    spiritshot: boolean,
    blessed_spiritshot: boolean
): any
    local hit_time = Rules.magic_cast_time(
        contract.SourceHitTimeMs,
        stats.MagicAttackSpeed,
        spiritshot,
        blessed_spiritshot
    )
    local cool_time = nil

    if contract.SourceCoolTimeMs ~= nil then
        cool_time = Rules.magic_cool_time(
            contract.SourceCoolTimeMs,
            stats.MagicAttackSpeed,
            spiritshot,
            blessed_spiritshot
        )
    end

    return {
        HitTimeMs = hit_time,
        CoolTimeMs = cool_time,
        InterruptTimeMs = math.floor(hit_time / 2),
    }
end

--[[
Calculates source reuse and blocks only when a mastery roll can still alter it.

Args:
    contract (any): Exact authenticated source cast contract.
    stats (any): Authenticated source reuse/mastery stats.

Returns:
    any: Pre-mastery reuse plus conditional exact final reuse state.
]]
local function reuse_plan(contract: any, stats: any): any
    local delay = Rules.skill_reuse_delay(
        contract.SourceReuseDelayMs,
        stats.MagicAttackSpeed,
        stats.MagicReuseMultiplier
    )
    local mastery_possible = stats.SkillMastery > 0

    return {
        PreMasteryReuseDelayMs = delay,
        FinalReuseDelayMs = if mastery_possible
            then nil else delay,
        FinalReuseDelayReady = not mastery_possible,
        ReuseBlocker = if mastery_possible
            then MASTERY_BLOCKER else nil,
    }
end

--[[
Builds a source timing planner around server-owned contract/stat/shot state.

Args:
    shot_authority (any): Authority exposing read-only snapshot(user_id).
    options (any?): Optional CastContract and BoundaryProvider overrides.

Returns:
    any: Isolated source-only timing planner.
]]
function C4SourceCastTimingService.new(
    shot_authority: any,
    options: any?
): any
    assert(
        shot_authority
            and type(shot_authority.snapshot) == "function",
        "Source cast timing service requires shot snapshot authority"
    )

    local config = options or {}
    local cast_contract =
        config.CastContract or DefaultCastContract
    local boundary_provider =
        config.BoundaryProvider or default_boundary_provider

    assert(
        type(cast_contract.resolve) == "function",
        "Source cast timing service requires cast-contract authority"
    )
    assert(
        type(boundary_provider) == "function",
        "Source cast timing service requires source boundary authority"
    )

    return setmetatable({
        _shots = shot_authority,
        _cast_contract = cast_contract,
        _boundary_provider = boundary_provider,
    }, C4SourceCastTimingService)
end

--[[
Resolves exact source magic timing and conditional final reuse.

Shot state is observed but never consumed. Reuse uses the authenticated
MAGICAL_SKILL_REUSE value. A nonzero SKILL_MASTERY value keeps final reuse
blocked until the source mastery roll is integrated.

Args:
    user_id (number): Authenticated source-ready cast owner.
    creative_skill_id (string): Server-selected owned creative skill.

Returns:
    (any?, string?): Source-only timing plan or strict denial reason.
]]
function C4SourceCastTimingService:resolve(
    user_id: number,
    creative_skill_id: string
): (any?, string?)
    local contract, contract_reason = self._cast_contract.resolve(
        user_id,
        creative_skill_id
    )
    if not contract then
        return nil, contract_reason
    end
    if not contract.SourceIsMagic then
        return nil, "OriginalMagicTimingRequired"
    end

    local boundary, boundary_reason =
        self._boundary_provider(user_id)
    if not boundary then
        return nil, boundary_reason
    end
    if boundary.ScopeId ~= contract.SourceScopeId then
        return nil, "OriginalCastSourceScopeMismatch"
    end

    local stats, stats_reason = timing_stats(boundary)
    if not stats then
        return nil, stats_reason
    end

    local spiritshot, blessed = peek_magic_shots(
        self._shots,
        user_id
    )
    local times = cast_times(
        contract,
        stats,
        spiritshot,
        blessed
    )
    local reuse = reuse_plan(contract, stats)

    return table.freeze({
        CreativeSkillId = creative_skill_id,
        CreativeRank = contract.CreativeRank,
        SourceScopeId = contract.SourceScopeId,
        SourceSkillId = contract.SourceSkillId,
        SourceRank = contract.SourceRank,
        SourceMagicAttackSpeed = stats.MagicAttackSpeed,
        SourceMagicReuseMultiplier = stats.MagicReuseMultiplier,
        SourceSkillMastery = stats.SkillMastery,
        SpiritshotCharged = spiritshot,
        BlessedSpiritshotCharged = blessed,
        SourceAuthoredHitTimeMs = contract.SourceHitTimeMs,
        FinalHitTimeMs = times.HitTimeMs,
        CastInterruptTimeMs = times.InterruptTimeMs,
        SourceAuthoredCoolTimeMs = contract.SourceCoolTimeMs,
        FinalCoolTimeMs = times.CoolTimeMs,
        SourceAuthoredReuseDelayMs = contract.SourceReuseDelayMs,
        PreMasteryReuseDelayMs = reuse.PreMasteryReuseDelayMs,
        FinalReuseDelayMs = reuse.FinalReuseDelayMs,
        FinalReuseDelayReady = reuse.FinalReuseDelayReady,
        ReuseBlocker = reuse.ReuseBlocker,
        ShotStateConsumed = false,
        SourceOnly = true,
        LiveSchedulingIntegrated = false,
        ClientAuthority = false,
    }), nil
end

--[[
Reports which source timing boundaries are complete and intentionally open.

Args:
    None.

Returns:
    any: Immutable staged-integration capability flags.
]]
function C4SourceCastTimingService.capability(): any
    return {
        Available = true,
        FinalMagicCastTimeIntegrated = true,
        FinalMagicCoolTimeIntegrated = true,
        ReadOnlyShotAccelerationIntegrated = true,
        CastInterruptWindowIntegrated = true,
        MagicReuseMultiplierIntegrated = true,
        ZeroMasteryFinalReuseIntegrated = true,
        SkillMasteryRollIntegrated = false,
        MasteryReuseBlocker = MASTERY_BLOCKER,
        LiveSchedulingIntegrated = false,
        ClientAuthority = false,
    }
end

return table.freeze(C4SourceCastTimingService)
