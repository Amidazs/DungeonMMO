--!strict
-- Source-only final cast-time planner for authenticated magic skills.

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

local REUSE_BLOCKER = "OriginalSkillReuseRateNotIntegrated"

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
Validates the final source magic attack speed required by timing formulas.

Args:
    boundary (any): Authenticated source migration boundary.

Returns:
    (number?, string?): Positive M.Atk.Spd or strict denial reason.
]]
local function magic_attack_speed(
    boundary: any
): (number?, string?)
    local stats = boundary and boundary.SourceStatCandidate
    local value = type(stats) == "table"
        and stats.MAGICAL_ATTACK_SPEED or nil

    if boundary == nil
        or boundary.SourceStatCandidateReady ~= true
        or type(value) ~= "number"
        or value ~= value
        or value <= 0
        or value >= math.huge
    then
        return nil, "OriginalMagicAttackSpeedUnavailable"
    end

    return value, nil
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
Resolves exact final cast timing while leaving final reuse fail-closed.

Shot state is observed but never consumed. Authored reuse is scaled with the
neutral multiplier only as diagnostic evidence; final reuse cannot be
authorized until MAGICAL_SKILL_REUSE is present in the source stat candidate.

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
    local contract, contract_reason =
        self._cast_contract.resolve(
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

    local attack_speed, speed_reason =
        magic_attack_speed(boundary)
    if not attack_speed then
        return nil, speed_reason
    end

    local spiritshot, blessed_spiritshot =
        peek_magic_shots(self._shots, user_id)
    local hit_time = Rules.magic_cast_time(
        contract.SourceHitTimeMs,
        attack_speed,
        spiritshot,
        blessed_spiritshot
    )
    local cool_time = nil
    if contract.SourceCoolTimeMs ~= nil then
        cool_time = Rules.magic_cool_time(
            contract.SourceCoolTimeMs,
            attack_speed,
            spiritshot,
            blessed_spiritshot
        )
    end
    local unmodified_reuse = Rules.skill_reuse_delay(
        contract.SourceReuseDelayMs,
        attack_speed,
        1
    )

    return table.freeze({
        CreativeSkillId = creative_skill_id,
        CreativeRank = contract.CreativeRank,
        SourceScopeId = contract.SourceScopeId,
        SourceSkillId = contract.SourceSkillId,
        SourceRank = contract.SourceRank,
        SourceMagicAttackSpeed = attack_speed,
        SpiritshotCharged = spiritshot,
        BlessedSpiritshotCharged = blessed_spiritshot,
        SourceAuthoredHitTimeMs = contract.SourceHitTimeMs,
        FinalHitTimeMs = hit_time,
        CastInterruptTimeMs = math.floor(hit_time / 2),
        SourceAuthoredCoolTimeMs = contract.SourceCoolTimeMs,
        FinalCoolTimeMs = cool_time,
        SourceAuthoredReuseDelayMs =
            contract.SourceReuseDelayMs,
        UnmodifiedReuseDelayMs = unmodified_reuse,
        FinalReuseDelayReady = false,
        ReuseBlocker = REUSE_BLOCKER,
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
        UnmodifiedReuseDiagnosticIntegrated = true,
        FinalReuseDelayIntegrated = false,
        ReuseBlocker = REUSE_BLOCKER,
        LiveSchedulingIntegrated = false,
        ClientAuthority = false,
    }
end

return table.freeze(C4SourceCastTimingService)
